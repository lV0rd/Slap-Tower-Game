local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source
local Services = Source.Services

local Packages = ReplicatedStorage.Packages

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

local PlayerService = require(Services.PlayerService)

function module.new(instance: Model)
	local self = setmetatable({
		Instance = instance :: Model,
		Janitor = Janitor.new(),
		Debounce = {} :: { [Player]: boolean },
		DebounceTime = 3,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)

	local ProximityPart = self.Instance:FindFirstChild("ProximityPart")
	if not ProximityPart then
		warn("ProximityPart not found in instance", self.Instance)
		return
	end

	local ProximityPrompt = ProximityPart:FindFirstChildOfClass("ProximityPrompt")
	if not ProximityPrompt then
		warn("ProximityPrompt not found in ProximityPart", ProximityPart)
		return
	end

	local Destination = self.Instance:FindFirstChild("Destination") :: BasePart?
	if not Destination then
		warn("Destination not found in instance", self.Instance)
		return
	end

	local Coins = self.Instance:GetAttribute("Coins")

	self.Janitor:Add(ProximityPrompt.Triggered:Connect(function(Player: Player)
		local Character = Player.Character
		if not Character then
			return
		end

		if self.Debounce[Player] then
			return
		end

		self.Debounce[Player] = true

		task.delay(self.DebounceTime, function()
			self.Debounce[Player] = nil
		end)

		Character:PivotTo(Destination.CFrame * CFrame.new(0, 1.5, 0))
		
		if Coins then
			local PlayerData = PlayerService:GetPlayer(Player)
			if not PlayerData then
				return
			end

			local Replica = PlayerData.Replica
			local Data = Replica.Data

			Replica:Set({"Coins"}, Data.Coins + Coins)
		end
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
