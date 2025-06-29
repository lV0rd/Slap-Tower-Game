local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Data = Shared.Data
local Products = require(Data.Products)

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

local SKIP_TROLL_ID = Products.SkipTroll.ID

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

	self.Janitor:Add(ProximityPrompt.Triggered:Connect(function(Player : Player)
		if self.Debounce[Player] then
			return
		end

		self.Debounce[Player] = true

		task.delay(self.DebounceTime, function()
			self.Debounce[Player] = nil
		end)

		Player:SetAttribute("SkipTrollCFrame", Destination.CFrame)
		MarketplaceService:PromptProductPurchase(Player, SKIP_TROLL_ID)
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
