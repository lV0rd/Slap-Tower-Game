local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source
local Services = Source.Services

local Packages = ReplicatedStorage.Packages

local Events = ReplicatedStorage.Shared.Events

local WinEvent = require(Events.Win):Server()

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

local PlayerService = require(Services.PlayerService)

local Tools = ReplicatedStorage.Assets.Tools

local spawns = workspace.Map.Lobby.Spawns:GetChildren()

local Constants = require(ReplicatedStorage.Shared.Data.Constants)

--incase u want something to happen whenever a player beats a certain tower or smth idk lol
--put _ instead of spaces in the name, cuz roblox dumb and doesnt allow spaces in attribute names
--eg: Something_Slap => "Something Slap"
local functions = {
	["Default"] = function(Player: Player, PlayerData: PlayerService.PlayerData)
		print(Player.Name, "Won!")
		local Character = Player.Character
		Player:SetAttribute("Winner_Slap", true)

		local FoundSlap = Character:FindFirstChild("Winner Slap") or Player.Backpack:FindFirstChild("Winner Slap")
		if FoundSlap then
			return
		end

		local Slap = Tools:FindFirstChild("Winner Slap")
		if not Slap then
			warn("Winner Slap", "not found in Tools")
			return
		end

		local SlapClone = Slap:Clone()
		SlapClone.Parent = Player.Backpack
	end,
}

function module.new(instance: BasePart)
	local self = setmetatable({
		Instance = instance :: BasePart,
		Janitor = Janitor.new(),
		Debounce = {} :: { [Player]: boolean },

		DebounceTime = 20,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)

	local winPartName = "Default" --self.Instance.Name
	local CoinsAmount = self.Instance:GetAttribute("Coins") or 1000

	self.Janitor:Add(self.Instance.Touched:Connect(function(hit: BasePart)
		local Character = hit.Parent
		local Humanoid = Character:FindFirstChild("Humanoid")

		if not Humanoid then
			return
		end

		local Player = Players:GetPlayerFromCharacter(Character)
		if not Player then
			return
		end

		if self.Debounce[Player] then
			return
		end

		self.Debounce[Player] = true
		task.delay(self.DebounceTime, function()
			self.Debounce[Player] = false
		end)

		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			return
		end

		if not BadgeService:UserHasBadgeAsync(Player.UserId, Constants.WIN_BADGE) then
			BadgeService:AwardBadge(Player.UserId, Constants.WIN_BADGE)
		end

		local Replica = PlayerData.Replica
		Replica:Set({ "Wins" }, Replica.Data.Wins + 1)
		Replica:Set({ "Coins" }, Replica.Data.Coins + CoinsAmount)
		Player.leaderstats.Wins.Value = Replica.Data.Wins

		functions[winPartName](Player, PlayerData)

		local RandomSpawn = spawns[math.random(#spawns)]

		Character:PivotTo(RandomSpawn.CFrame)
		WinEvent:Fire(Player)
	end))
end

function module:_cleanup()
	if table.find(Components, self) then
		table.remove(Components, table.find(Components, self))
	end

	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
