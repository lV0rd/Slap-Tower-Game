local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

local LocalPlayer = Players.LocalPlayer

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

	local Force = self.Instance:GetAttribute("Force") or 40
	local VFX = self.Instance:FindFirstChild("VFX")
	if not VFX then
		warn("jump pad VFX not found in instance", self.Instance)
		return
	end

	self.Janitor:Add(self.Instance.Touched:Connect(function(hit)
		local Character = hit.Parent
		if Character ~= LocalPlayer.Character then
			return
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		for i, v in VFX:GetChildren() do
			if v:IsA("ParticleEmitter") then
				v:Emit(20)
			elseif v:IsA("Sound") then
				v:Play()
			end
		end

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		BodyVelocity.Velocity = Vector3.new(0, Force, 0)
		BodyVelocity.Parent = Humanoid.RootPart
		Debris:AddItem(BodyVelocity, 0.15)
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
