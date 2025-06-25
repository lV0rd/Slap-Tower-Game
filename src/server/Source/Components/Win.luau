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

function module.new(instance: BasePart)
	local self = setmetatable({
		Instance = instance :: BasePart,
		Janitor = Janitor.new(),
		Debounce = {} :: {[Player] : boolean},

        DebounceTime = 10,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)
	
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

        local Replica = PlayerData.Replica
        Replica:Set({"Wins"}, Replica.Data.Wins + 1)
        Player.leaderstats.Wins.Value = Replica.Data.Wins

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