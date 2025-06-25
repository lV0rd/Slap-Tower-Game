local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = {
	Name = script.Name,
}

local Shared = ReplicatedStorage.Shared
local Events = Shared.Events
local Data = Shared.Data

local SlapEvent = require(Events.Slap):Server()

local SlapData = require(Data.Slap)

local Debounces = {} :: { [number]: boolean }

function Service.Start()
	-- body
	SlapEvent:On(function(Player : Player, HitHumanoid : Humanoid)
        if not HitHumanoid:IsA("Humanoid") then
            warn(Player, "suspicious remote event")
            return
        end

		local UserId = Player.UserId
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?

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

		Debounces[UserId] = true

		task.delay(math.clamp(ToolData.DebounceTime - 0.5, 0, math.huge), function()
			Debounces[UserId] = nil
		end)

		if Humanoid.Health <= 0 then
			return
		end

		local HitCharacter = HitHumanoid.Parent
		--local HitPlayer = Players:GetPlayerFromCharacter(HitCharacter)

		if not HitCharacter then
			return
		end

		if not (Humanoid.RootPart and HitHumanoid.RootPart) then
			return
		end

		local Distance = (Humanoid.RootPart.Position - HitHumanoid.RootPart.Position)
		if Distance.Magnitude > 10 then
			return
		end

		HitHumanoid:SetAttribute("Tag", Player.Name)

		HitHumanoid:TakeDamage(ToolData.Damage)

		local BV = Instance.new("BodyVelocity")
		BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

		local Force = ToolData.Force

		BV.Velocity = (Character.HumanoidRootPart.CFrame.LookVector * Force
			+ Character.HumanoidRootPart.CFrame.UpVector * Force)
        
        HitHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		BV.Parent = HitHumanoid.RootPart
		Debris:AddItem(BV, 0.05)
		task.wait(1)
		HitHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	end)
end

return Service
