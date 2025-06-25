local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Assets = ReplicatedStorage.Assets
local Tools = Assets.Tools

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

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
		if not Player then
			return
		end

		local FoundTool = Player.Backpack:FindFirstChild(self.Instance.Name) or Player.Character:FindFirstChild(self.Instance.Name)
		if FoundTool then
			return
		end

		if self.Debounce[Player] then
			return
		end

		self.Debounce[Player] = true

		task.delay(self.DebounceTime, function()
			self.Debounce[Player] = nil
		end)

		local NewTool = Tools:FindFirstChild(self.Instance.Name):Clone()
		NewTool.Parent = Player.Backpack
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
