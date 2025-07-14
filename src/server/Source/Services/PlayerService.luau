--[[
PlayerService.luau 2025/05/13

Handling player data, badges (welcome badge) and automatic
gamepass indexing

Features auto group join detection, player data replication, and playtime tracking.

Mock datastore for testing in studio.
]]
--local MarketplaceService = game:GetService("MarketplaceService")
local GroupService = game:GetService("GroupService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Source = ServerStorage.Source
local Modules = Source.Modules

local Packages = ReplicatedStorage.Packages

local Shared = ReplicatedStorage.Shared
local Data = Shared.Data

local Future = require(Packages.Future)
local Signal = require(Packages.Signal)
local Timer = require(Packages.Timer)

local ProfileStore = require(Modules.ProfileStore)
local ReplicaServer = require(Modules.ReplicaServer)

local Template = require(Data.ProfileTemplate)
local Constants = require(Data.Constants)
local Gamepass = require(Data.Gamepass)
local Products = require(Data.Products)
--local GamepassData = require(Data.Gamepass)

local PlayerStore

local MOCK_DATASTORE = true

if MOCK_DATASTORE and RunService:IsStudio() then
	PlayerStore = ProfileStore.New("MockData", Template).Mock
else
	PlayerStore = ProfileStore.New("GameData", Template)
end

local PlayerDataReplicaToken = ReplicaServer.Token("PlayerData")
local LocalDataReplicaToken = ReplicaServer.Token("LocalData")

local FriendJoined = require(Shared.Events.FriendJoined):Server()

--local SpinDebounce = {} --Debonce for the timed spin reward

local Tools = ReplicatedStorage.Assets.Tools

local GROUP_ID = Constants.GROUP_ID
local EXPLODE_ID = Products.Explode.ID

local Service = {
	Name = script.Name,
	Players = {} :: { [Player]: PlayerData },
	PlayerJoinSignal = Signal.new(),
	PlayerLeaveSignal = Signal.new(),
	GroupJoined = Signal.new(), -- Signal for when a player joins the group ( very cool but very hacky :( )
}

export type PlayerData = {
	Player: Player,
	Connections: { RBXScriptConnection },
	Profile: ProfileStore.Profile<any>,
	Replica: ReplicaServer.Replica,
	--LocalData: ReplicaServer.Replica,
}

function characterSpawn(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local PlayerData = Service:GetPlayer(Player)
	local Replica = PlayerData.Replica

	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

	for i, v in Gamepass do
		if Replica.Data.Gamepasses[tostring(v.ID)] and v.OnSpawn then
			task.spawn(v.Callback, Player, PlayerData)
		end
	end

	--Tool attributes (slaps only rn)
	for i, v in Player:GetAttributes() do
		if string.match(i, "Slap") and v then
			local name = string.gsub(i, "_", " ")
			local FoundSlap = Character:FindFirstChild(name) or Player.Backpack:FindFirstChild(name)
			if FoundSlap then
				continue
			end

			local Slap = Tools:FindFirstChild(name)
			if not Slap then
				warn(name, "not found in Tools")
				continue
			end

			local SlapClone = Slap:Clone()
			SlapClone.Parent = Player.Backpack
		end
	end

	--Premium stuff
	if Replica.Data.HasPremium then
		local PremiumSlap = Tools:FindFirstChild("Premium Slap")
		if not PremiumSlap then
			error("Premium Slap not found in Tools")
		end

		local PremiumSlapClone = PremiumSlap:Clone()
		PremiumSlapClone.Parent = Player.Backpack
	end

	--Explode proximity prompt
	local foundPrompt = Character.HumanoidRootPart:FindFirstChild("ExplodePrompt") --this should never happen.
	if foundPrompt then
		foundPrompt:Destroy()
	end

	local ExplodePrompt = Instance.new("ProximityPrompt")
	ExplodePrompt.ActionText = "🎇Explode?"
	ExplodePrompt.Name = "ExplodePrompt"
	ExplodePrompt.HoldDuration = 0.2
	ExplodePrompt.KeyboardKeyCode = Enum.KeyCode.F
	ExplodePrompt.RequiresLineOfSight = false
	ExplodePrompt.ObjectText = "Troll this person ! 😈"

	ExplodePrompt.Triggered:Connect(function(Triggerer)
		Triggerer:SetAttribute("TargetPlayer", Player.Name)
		MarketplaceService:PromptProductPurchase(Triggerer, EXPLODE_ID)
	end)

	ExplodePrompt.Parent = Character.HumanoidRootPart

	Humanoid.Died:Once(function()
		Player:SetAttribute("TargetPlayer", nil)
	end)
end

function Service:GetAllPlayers(): { [Player]: PlayerData }
	return self.Players
end

function Service:GetPlayer(Player): PlayerData?
	if self:CheckPlayer(Player) then
		return self.Players[Player]
	end

	return nil
end

function Service:CheckPlayer(Player)
	return self.Players[Player] and true or false
end

function Service:PlayerJoin(Player: Player)
	Player:SetAttribute("JoinTime", workspace:GetServerTimeNow())
	--Player:SetAttribute("SpinTime", workspace:GetServerTimeNow())

	local Connections = {}

	local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	if not Profile then
		Player:Kick("Profile not loaded, please rejoin later.")
		warn(`{Player.Name}'s profile was not loaded.`)
		return
	end

	Profile:AddUserId(Player.UserId)
	Profile:Reconcile()

	Profile.OnSessionEnd:Connect(function()
		self.Players[Player].Profile = nil
		Player:Kick("Data possibly loaded in another server. (102)")
	end)

	if not Player:IsDescendantOf(Players) then
		Profile:EndSession()
		return
	end

	local Data = {
		Player = Player,
		Connections = Connections,
		Profile = Profile,

		Replica = ReplicaServer.New({
			Token = PlayerDataReplicaToken,
			Tags = {
				Player = Player,
			},
			Data = Profile.Data,
		}),

		LocalData = ReplicaServer.New({
			Token = LocalDataReplicaToken,
			Tags = {
				Player = Player,
			},

			Data = {
				Gifts = {},
			},
		}),
	}

	Data.Replica:Replicate()
	Data.LocalData:Replicate()

	self.Players[Player] = Data

	local Replica = Data.Replica
	local ReplicaData = Replica.Data
	local Gamepasses = ReplicaData.Gamepasses

	task.spawn(function()
		local others = Players:GetPlayers()
		for _, otherPlayer in ipairs(others) do
			if otherPlayer ~= Player then
				if otherPlayer:IsFriendsWith(Player.UserId) then
					FriendJoined:Fire(otherPlayer, Player.Name)

					local otherData = Service:GetPlayer(otherPlayer)
					if not otherData then
						continue
					end

					otherData.Replica:Set({ "Coins" }, Replica.Data.Coins + 1000)
					otherPlayer.leaderstats.Coins.Value = Replica.Data.Coins
				end
			end
		end
	end)

	for name, gamepass in Gamepass do
		local Success, Owns = Future.Try(function()
			return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, tonumber(gamepass.ID))
		end):Await()

		if not Success then
			Owns = false
		end

		local CurrentState = Gamepasses[tostring(gamepass.ID)]

		if Owns then
			if not CurrentState then
				Replica:Set({ "Gamepasses", tostring(gamepass.ID) }, true)
			end

			if gamepass.OnJoin then
				gamepass.Callback(Player, Data)
			end
		elseif CurrentState == nil then
			Replica:Set({ "Gamepasses", tostring(gamepass.ID) }, false)
		end
	end

	if Player.MembershipType == Enum.MembershipType.Premium and not Replica.Data.HasPremium then
		Replica:Set({ "HasPremium" }, true)
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local Wins = Instance.new("IntValue")
	Wins.Name = "Wins"
	Wins.Value = Profile.Data.Wins or 0
	Wins.Parent = leaderstats

	local Coins = Instance.new("IntValue")
	Coins.Name = "Coins"
	Coins.Value = Profile.Data.Coins or 0
	Coins.Parent = leaderstats

	leaderstats.Parent = Player

	if Data.Replica.Data.FirstLogin == 0 then
		Data.Replica:Set({ "FirstLogin" }, workspace:GetServerTimeNow())
	end

	if Player.Character then
		characterSpawn(Player.Character)
	end

	Connections.Character = Player.CharacterAdded:Connect(characterSpawn)

	self.PlayerJoinSignal:Fire(Player)
end

for i, Player in Players:GetPlayers() do
	if Player:IsDescendantOf(Players) then
		Service:PlayerJoin(Player)
	end
end

Players.PlayerAdded:Connect(function(Player)
	--[[
    Welcome badge
	task.spawn(function()
		local _, OwnWelcomeBadge = Future.Try(function()
			return BadgeService:UserHasBadgeAsync(Player.UserId, WelcomeBadgeId)
		end):Await()
		if not OwnWelcomeBadge then
			BadgeService:AwardBadge(Player.UserId, WelcomeBadgeId)
		end
	end)
    ]]

	Service:PlayerJoin(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
	if Service.Players[Player] then
		Service.Players[Player].Profile:EndSession()

		if Service.Players[Player].Connections then
			for i, v in Service.Players[Player].Connections do
				v:Disconnect()
				v = nil
			end
			Service.Players[Player] = nil
		end
	end

	Service.PlayerLeaveSignal:Fire(Player)
end)

local PlaytimeClock = Timer.new(1)

PlaytimeClock.Tick:Connect(function()
	for i, v in Service.Players do
		if v.Profile then
			v.Replica:Set({ "Playtime" }, v.Replica.Data.Playtime + 1)
		end
	end
end)

--[[
Timed spin reward
RunService.Heartbeat:Connect(function()
	local now = workspace:GetServerTimeNow()

	for Player, PlayerData in Service.Players do
		if SpinDebounce[Player] then
			continue
		end

		local SpinTime = Player:GetAttribute("SpinTime")
		local Time = math.clamp(Settings.SPIN_TIME_REWARD - (now - SpinTime), 0, Settings.SPIN_TIME_REWARD)

		if Time <= 0 then
			SpinDebounce[Player] = true
			task.delay(1, function()
				SpinDebounce[Player] = false
			end)

			Player:SetAttribute("SpinTime", now)
			PlayerData.Replica:Set({ "Spins" }, PlayerData.Replica.Data.Spins + 1)
			Notify:Fire(Player, "You got a spin!")
		end
	end
end)
--]]

PlaytimeClock:Start()

--ROBLOX PLS ADD AN EVENT FOR THIS THIS IS SO DOOKY
local lastElapse = 0
RunService.PostSimulation:Connect(function()
	if workspace:GetServerTimeNow() - lastElapse < 5 then
		return
	end

	lastElapse = workspace:GetServerTimeNow()

	for i, v in Service.Players do
		local Replica = v.Replica

		local Success, GroupInfo = Future.Try(function()
			return GroupService:GetGroupsAsync(i.UserId)
		end):Await()

		if not Success then
			continue
		end

		local found

		if GroupInfo then
			for _, group in GroupInfo do
				if group.Id == GROUP_ID then
					found = true
					if not Replica.Data.InGroup then
						Replica:Set({ "InGroup" }, true)
						Service.GroupJoined:Fire(i)
					end
				end
			end
		end

		if not found and Replica.Data.InGroup then
			Replica:Set({ "InGroup" }, false)
		end
	end
end)

return Service
