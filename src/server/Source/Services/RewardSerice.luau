local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared
local Functions = Shared.Functions

local Rewards = require(Shared.Data.Rewards)

local Gifts = require(Functions.Gifts)

local Service = {
	Name = script.Name,
}

function Service.Start()
	local PlayerService = require(Services.PlayerService)
    
    Gifts:SetCallback(function(Player: Player, Index: number)
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			return false
		end

		local Info = Rewards.Gifts[Index]

		if not Info then
			return false
		end

		local now = workspace:GetServerTimeNow()
		local StartTime = Player:GetAttribute("JoinTime")

		if not StartTime then
			Player:Kick("Please rejoin, data not loaded.")
			return false
		end

		local Time = math.clamp(Info.Time - (now - StartTime), 0, Info.Time)

		if Time > 0 then
			return false
		end

		local Gifts = PlayerData.LocalData.Data.Gifts
		local Name = tostring(Index)

		if Gifts[Name] == true then
			return false
		end

        print("Claiming gift:", Name, "for player:", Player.Name)

		PlayerData.LocalData:Set({ "Gifts", Name }, true)
		Info.Reward(Player, PlayerData)

		return true
	end)
end

return Service