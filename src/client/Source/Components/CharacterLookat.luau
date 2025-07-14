local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local module = { Tag = script.Name }
module.__index = module

local LocalPlayer = Players.LocalPlayer
local Components = {}

local MAX_DISTANCE = 20
local MAX_YAW = math.rad(35)
local RETURN_SPEED = 0.1

local function isInFront(npcHRP, targetPos)
	local lookVector = npcHRP.CFrame.LookVector
	local toTarget = (targetPos - npcHRP.Position).Unit
	return lookVector:Dot(toTarget) > 0 -- dot > 0 = in front
end

local function getYawToTarget(originCFrame: CFrame, targetPos: Vector3)
	local direction = (targetPos - originCFrame.Position)
	local flatDirection = Vector3.new(direction.X, 0, direction.Z)
	if flatDirection.Magnitude == 0 then
		return 0
	end
	flatDirection = flatDirection.Unit

	local forward = originCFrame.LookVector
	local flatForward = Vector3.new(forward.X, 0, forward.Z).Unit

	local angle = math.acos(flatForward:Dot(flatDirection))
	local cross = flatForward:Cross(flatDirection)

	if cross.Y < 0 then
		angle = -angle
	end

	return angle
end

RunService.RenderStepped:Connect(function()
	for _, comp in ipairs(Components) do
		local neck = comp.Neck
		local originalC0 = comp.OriginalC0
		local hrp = comp.HumanoidRootPart

		local playerChar = LocalPlayer.Character
		local playerHRP = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
		if not (neck and originalC0 and hrp and playerHRP) then
			continue
		end

		local distance = (playerHRP.Position - hrp.Position).Magnitude
		local inFront = isInFront(hrp, playerHRP.Position)

		if distance <= MAX_DISTANCE and inFront then
			local yaw = getYawToTarget(hrp.CFrame, playerHRP.Position)
			yaw = math.clamp(yaw, -MAX_YAW, MAX_YAW)
			neck.C0 = neck.C0:Lerp(originalC0 * CFrame.Angles(0, 0, yaw), RETURN_SPEED)
		else
			neck.C0 = neck.C0:Lerp(originalC0, RETURN_SPEED)
		end
	end
end)

function module.new(model: Model)
	local torso = model:FindFirstChild("Torso")
	local head = model:FindFirstChild("Head")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not (torso and head and hrp) then
		return
	end

	local neck = torso:FindFirstChild("Neck")
	if not (neck and neck:IsA("Motor6D")) then
		return
	end

	local self = setmetatable({}, module)
	self.Instance = model
	self.Neck = neck
	self.OriginalC0 = neck.C0
	self.HumanoidRootPart = hrp

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

	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
