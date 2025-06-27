local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {},
}

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared.Events

local KnockbackEvent = require(Events.Knockback):Client()

function Controller.Start()
	KnockbackEvent:On(function(KnockImpulseVector: Vector3)
		local Character = LocalPlayer.Character
		if not Character then
			return
		end

		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		if not RootPart then
			return
		end

		RootPart:ApplyImpulse(KnockImpulseVector)
	end)
end

return Controller
