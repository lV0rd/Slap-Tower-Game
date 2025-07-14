local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Source = ServerStorage.Source
local Services = Source.Services

local PlayerService = require(Services.PlayerService)
local Gamepasses = require(ReplicatedStorage.Shared.Data.Gamepass)

local function match(t, c)
	for i, e in t do
		if c(i, e) then
			return i, e
		end
	end

    return nil
end

return function(context, Gamepass: number, player: Player?)
	local Player = if player then player else context.Executor

	local PlayerData = PlayerService:GetPlayer(Player)
	if not PlayerData then
		return "Player data not found."
	end

	local _name, GamepassData = match(Gamepasses, function(i, v)
		return v.ID == Gamepass
	end)

	if not GamepassData then
		return "Invalid ID!"
	end

	if not PlayerData.Replica.Data.Gamepasses[tostring(GamepassData.ID)] then
		return "Already owned."
	end

	PlayerData.Replica:Set({ "Gamepasses", tostring(GamepassData.ID) }, true)

	return "Gamepass granted!"
end
