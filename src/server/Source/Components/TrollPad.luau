local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

function module.new(instance: Model)
	local DebounceTime = instance:GetAttribute("DebounceTime") or 0 :: number
	local self = setmetatable({
		Instance = instance :: Model,
		Janitor = Janitor.new(),
		Debounce = false :: boolean,

		DebounceTime = DebounceTime > 10 and DebounceTime or 10,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)

	local Button = self.Instance:FindFirstChild("Button")
	if not Button then
		warn("Button not found in instance", self.Instance)
		return
	end

	local AffectedParts = self.Instance:FindFirstChild("AffectedParts")
	if not AffectedParts then
		warn("AffectedParts attribute not set in instance", self.Instance)
		return
	end

	local Reverse = Button:GetAttribute("Reverse") or false

	for i, v in AffectedParts:GetChildren() do
		if v:IsA("BasePart") then
			v.Transparency = if Reverse then 0.5 else 0
			v.CanCollide = if Reverse then false else true
		end
	end

    Button.Color = Color3.fromRGB(23, 170, 23)

	self.Janitor:Add(Button.Touched:Connect(function(hit: BasePart)
		local Character = hit.Parent
		local Humanoid = Character:FindFirstChild("Humanoid")

		if not Humanoid then
			return
		end

		local Player = Players:GetPlayerFromCharacter(Character)
		if not Player then
			return
		end

		if self.Debounce then
			return
		end

		self.Debounce = true
		task.delay(self.DebounceTime, function()
			self.Debounce = false
		end)

        Button.Color = Color3.fromRGB(150, 18, 18)

		for i, v in AffectedParts:GetChildren() do
			if v:IsA("BasePart") then
				v.Transparency = Reverse and 0 or 0.5
				v.CanCollide = if Reverse then true else false
			end
		end

		task.wait(2)

		for i, v in AffectedParts:GetChildren() do
			if v:IsA("BasePart") then
				v.Transparency = Reverse and 0.5 or 0
				v.CanCollide = if Reverse then false else true
			end
		end

        Button.Color = Color3.fromRGB(23, 170, 23)
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
