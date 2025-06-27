local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = {
	Name = script.Name,
}

local Shared = ReplicatedStorage.Shared
local Events = Shared.Events
local Data = Shared.Data

local SlapEvent = require(Events.Slap):Server()
local KnockbackEvent = require(Events.Knockback):Server()

local SlapData = require(Data.Slap)

local Debounces = {} :: { [number]: boolean }

function Service.Start()
	-- body
	SlapEvent:On(function(Player: Player, HitHumanoid: Humanoid)
		if not HitHumanoid:IsA("Humanoid") then
			warn(Player, "suspicious remote event")
			return
		end

		local UserId = Player.UserId
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?
		local RootPart = Humanoid.RootPart

		if Debounces[UserId] then
			return
		end

		local Tool = Character:FindFirstChildOfClass("Tool")
		if not Tool then
			return
		end

		local ToolData = SlapData[Tool.Name]
		if not ToolData then
			return
		end

		if
			HitHumanoid.Sit
			or HitHumanoid:GetState() == Enum.HumanoidStateType.Physics
			or HitHumanoid:GetState() == Enum.HumanoidStateType.Seated
			or HitHumanoid:GetState() == Enum.HumanoidStateType.PlatformStanding
			or HitHumanoid:GetState() == Enum.HumanoidStateType.None
			or HitHumanoid:GetState() == Enum.HumanoidStateType.Dead
		then
			return
		end

		Debounces[UserId] = true

		task.delay(1, function()
			Debounces[UserId] = nil
		end)

		if Humanoid.Health <= 0 then
			return
		end

		local HitCharacter = HitHumanoid.Parent
		local HitPlayer = Players:GetPlayerFromCharacter(HitCharacter)

		if not HitCharacter then
			return
		end

		if not (Humanoid.RootPart and HitHumanoid.RootPart) then
			return
		end

		local Distance = (Humanoid.RootPart.Position - HitHumanoid.RootPart.Position)
		if Distance.Magnitude > 9 then
			return
		end

		HitHumanoid:SetAttribute("Tag", Player.Name)
		HitHumanoid:TakeDamage(ToolData.Damage)

		local SlapSound = Tool.Handle:FindFirstChild("Hit") :: Sound?
		if SlapSound then
			SlapSound:Play()
		end

		local Force = ToolData.Force :: number

		local ImpulseVector = (RootPart.CFrame.LookVector + RootPart.CFrame.UpVector * 1.2).Unit

		HitHumanoid.Sit = true

		if HitPlayer then
			KnockbackEvent:Fire(HitPlayer, ImpulseVector * Force)
		else
			HitHumanoid.RootPart:ApplyImpulse(ImpulseVector * Force)
		end

		task.wait(0.5)
		HitHumanoid.Sit = false
	end)
end

return Service
