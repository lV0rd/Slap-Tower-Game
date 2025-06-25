local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")
local Modules = Source:WaitForChild("Modules")

local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage.Packages

local Shared = ReplicatedStorage.Shared
local Data = Shared.Data

local GamepassData = require(Data.Gamepass)

local Janitor = require(Packages.Janitor)

local ReplicaClient = require(Modules.ReplicaClient)

local DataController = require(Controllers.DataController)
local PlayerData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica

local module = { Tag = script.Name }
module.__index = module

local Components = {}

local Debounce = false

function module.new(instance: Model)

    local Data = GamepassData[instance.Name]
    if not Data then
        warn("no gamepass data found for ", instance)
        return
    end

	local self = setmetatable({
		Instance = instance :: Model,
        Data = Data,
		Janitor = Janitor.new(),
		DebounceTime = 3,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)

	local TouchPart = self.Instance:FindFirstChild("TouchPart")
	if not TouchPart then
		warn("TouchPart not found in instance", self.Instance)
		return
	end



	self.Janitor:Add(TouchPart.Touched:Connect(function(Hit : BasePart)
		local Character = Hit.Parent
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end
		
		local Player = Players:GetPlayerFromCharacter(Character)
		if Player.UserId ~= LocalPlayer.UserId then
			return
		end

		if PlayerData.Data.Gamepasses[tostring(self.Data.ID)] then
			return
		end

		if Debounce then
			return
		end

		Debounce = true

		task.delay(self.DebounceTime, function()
			Debounce = nil
		end)

		MarketplaceService:PromptGamePassPurchase(LocalPlayer, self.Data.ID)
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
