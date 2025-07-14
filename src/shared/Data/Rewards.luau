local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Gifts = {
		{
			Time = 60 * 2,
			Title = "+300 Coins",

			Reward = function(Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 300)
				Player.leaderstats.Coins.Value = PlayerData.Replica.Data.Coins
			end,

			Image = "rbxassetid://17613785372",
		},

		{
			Time = 60 * 7,
			Title = "+700 Coins",

			Reward = function(Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 700)
				Player.leaderstats.Coins.Value = PlayerData.Replica.Data.Coins
			end,

			Image = "rbxassetid://17613785372",
		},

		{
			Time = 60 * 10,
			Title = "+1000 Coins",

			Reward = function(Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 1000)
				Player.leaderstats.Coins.Value = PlayerData.Replica.Data.Coins
			end,

			Image = "rbxassetid://17613785372",
		},

		{
			Time = 60 * 15,
			Title = "OP ROOM",

			Reward = function(Player: Player, PlayerData)
				
			end,

			Image = "rbxassetid://99174903737611",
		},

		{
			Time = 60 * 20,
			Title = "+3000 Coins",

			Reward = function(Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 3000)
				Player.leaderstats.Coins.Value = PlayerData.Replica.Data.Coins
			end,

			Image = "rbxassetid://17613785372",
		},

		{
			Time = 60 * 25,
			Title = "Admin",

			Reward = function(Player: Player, PlayerData)
				local rank = "Mod"
				local rankType = "Server"

				local hdModule : ModuleScript = ReplicatedStorage:WaitForChild("HDAdminSetup")
                if not hdModule then
                    return
                end

                local required = require(hdModule) :: {any}

                local hdMain = required:GetMain()
				local hd = hdMain:GetModule("API")
				local rankId = tonumber(rank) or hd:GetRankId(rank)
				local rankName = hd:GetRankName(rankId)

                local plrRankId = hd:GetRank(Player)
				if plrRankId < rankId then
					hd:SetRank(Player, rankId, rankType)
				else
					local errorMessage = "Your rank is already higher than '"..rankName.."'!"
					if plrRankId == rankId then
						errorMessage = "You've already been ranked to '"..rankName.."'!"
					end
					hd:Error(Player, errorMessage)
				end
			end,

			Image = "rbxassetid://4563944921",
		},
	},
}
