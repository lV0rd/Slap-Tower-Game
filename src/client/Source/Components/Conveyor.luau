local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

	local Speed = self.Instance:GetAttribute("Speed") or 40
	local StartAttachment = self.Instance:FindFirstChild("Start")
	local Beam = StartAttachment:FindFirstChild("Beam")
	if not Beam then
		warn("Beam not found in instance", self.Instance)
		return
	end
	
	Beam.TextureSpeed = Speed / Beam.TextureLength
	self.Instance.Velocity = self.Instance.CFrame.LookVector * Speed
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
