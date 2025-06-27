local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

--[[
Triggered when the player slaps another.
]]
return Red.Event("Knockback", function(KnockImpulseVector)
    return Guard.Vector3(KnockImpulseVector)
end)