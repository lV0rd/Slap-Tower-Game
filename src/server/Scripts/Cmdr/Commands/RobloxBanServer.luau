local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Future = require(ReplicatedStorage.Packages.Future)

return function(context, Player: Player, Duration : number, Reason : string)
	local Success = Future.Try(function()
		Players:BanAsync({
			UserIds = {Player.UserId},
			ApplyToUniverse = true,
			Duration = Duration,
			DisplayReason = Reason,
			PrivateReason = "Banned by devs"
		})
	end):Await()

	if Success then
		return "Banned successfully!"
	else
		return "Error banning."
	end
end
