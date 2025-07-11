local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

--[[
Triggered when the player slaps another.
]]
return Red.Event("FriendJoined", function(name)
    return Guard.String(name)
end)