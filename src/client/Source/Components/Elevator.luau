local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

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

	local MaxForce = self.Instance:GetAttribute("MaxForce") or math.huge
	local Speed = self.Instance:GetAttribute("Speed") or 40

	self.Janitor:Add(self.Instance.Touched:Connect(function(Hit: BasePart)
		local Character = Hit.Parent
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		local Player = Players:GetPlayerFromCharacter(Character)

		if Player.UserId ~= LocalPlayer.UserId then
			return
		end

		local ElevatorForce = Humanoid.RootPart:FindFirstChild("ElevatorForce")
		if ElevatorForce then
			return
		end

		ElevatorForce = Instance.new("BodyVelocity")
		ElevatorForce.Name = "ElevatorForce"

		local UpVector = self.Instance.CFrame.UpVector
		local MaxForceVector = Vector3.new(0, MaxForce, 0)

		if UpVector.X ~= 0 then
			MaxForceVector = Vector3.new(MaxForce, MaxForceVector.Y, MaxForceVector.Z)
		end
		if UpVector.Z ~= 0 then
			MaxForceVector = Vector3.new(MaxForceVector.X, MaxForceVector.Y, MaxForce)
		end

		ElevatorForce.MaxForce = MaxForceVector
		ElevatorForce.Velocity = self.Instance.CFrame.UpVector * Speed
		ElevatorForce.Parent = Humanoid.RootPart
	end))

	self.Janitor:Add(self.Instance.TouchEnded:Connect(function(Hit: BasePart)
		local Character = Hit.Parent
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		local ElevatorForce = Humanoid.RootPart:FindFirstChild("ElevatorForce")
		if not ElevatorForce then
			return
		end

		ElevatorForce:Destroy()
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
