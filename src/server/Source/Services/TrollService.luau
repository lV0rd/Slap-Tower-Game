local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = {
	Name = script.Name,
}

local Shared = ReplicatedStorage.Shared
local Functions = Shared.Functions

local KnockbackEvent = require(Functions.Troll)

local Debounces = {} :: { [number]: boolean }

function Service.Start()
	KnockbackEvent:SetCallback(function(Player, TargetPlayer)
		if type(TargetPlayer) ~= "string" then
			warn(Player, "suspicious remote event")
			return
		end

		if TargetPlayer == Player.Name then
			return
		end

		local Target = Players:FindFirstChild(TargetPlayer)
		local TargetCharacter = Target and Target.Character
		if not Target or not TargetCharacter then
			warn(Player, "target player not found")
			return
		end

		if TargetCharacter.Humanoid.Health <= 0 then
			warn(Player, "target player is dead")
			return
		end

		if Debounces[Player] then
			return
		end

		Debounces[Player] = true
		task.delay(1, function()
			Debounces[Player] = nil
		end)

		Player:SetAttribute("TargetPlayer", TargetPlayer)

		return true
	end)
end

return Service
