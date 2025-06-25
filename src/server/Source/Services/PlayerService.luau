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
--local GamepassData = require(Data.Gamepass)

local PlayerStore

local MOCK_DATASTORE = true

if MOCK_DATASTORE and RunService:IsStudio() then
	PlayerStore = ProfileStore.New("MockData", Template).Mock
else
	PlayerStore = ProfileStore.New("GameData", Template)
end

local PlayerDataReplicaToken = ReplicaServer.Token("PlayerData")
--local LocalDataReplicaToken = ReplicaServer.Token("LocalData")

--local SpinDebounce = {} --Debonce for the timed spin reward

local GROUP_ID = Constants.GROUP_ID

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
			v.Callback(Player, PlayerData)
		end
	end
	
	Humanoid.Died:Once(function()
		
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
        --[[
        Private session player data
		LocalData = ReplicaServer.New({
			Token = LocalDataReplicaToken,
			Tags = {
				Player = Player,
			},
			Data = {
				Gifts = {},
				SpinHistory = {},

				WinsMultiplier = 1,
				CoinsMultiplier = 1,
				KillsMultipler = 1,
				HealthMultiplier = 1,
				SpinDebounce = true,
			},
            
		}),
        ]]
	}

	Data.Replica:Replicate()
	--Data.LocalData:Replicate()

	self.Players[Player] = Data

    
	task.spawn(function()
		local Replica = Data.Replica
		local ReplicaData = Replica.Data
		local Gamepasses = ReplicaData.Gamepasses
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
	end)
    

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Wins = Instance.new("IntValue")
	Wins.Name = "Wins"
	Wins.Value = Profile.Data.Wins or 0
	Wins.Parent = leaderstats

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
	if workspace:GetServerTimeNow() - lastElapse < 4 then
		return
	end

	lastElapse = workspace:GetServerTimeNow()

	for i, v in Service.Players do
		local Replica = v.Replica
		if not Replica.Data.InGroup then

			local Success, GroupInfo = Future.Try(function()
				return GroupService:GetGroupsAsync(i.UserId)
			end):Await()

			if not Success then
				continue
			end

			if GroupInfo then
				for _, group in GroupInfo do
					if group.Id == GROUP_ID then
						Replica:Set({"InGroup" }, true)
						Service.GroupJoined:Fire(i)
						break
					end
				end
			end
		end
	end
end)

return Service