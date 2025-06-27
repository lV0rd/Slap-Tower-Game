local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

function module.new(instance: BasePart)
	local self = setmetatable({
		Instance = instance :: BasePart,
		Janitor = Janitor.new(),
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)
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

RunService.Stepped:Connect(function(t, dt)
	for i, component in Components do
		local part = component.Instance
		if part:IsA("BasePart") then
			local hue = (t * 0.2 + i * 0.1) % 1

			local color = Color3.fromHSV(hue, 1, 1)
			part.Color = color
		end
	end
end)

return module
