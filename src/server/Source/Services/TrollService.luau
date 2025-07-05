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
