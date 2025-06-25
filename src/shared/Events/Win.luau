local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
--local Guard = require(ReplicatedStorage.Packages.Guard)

--[[
Triggered when the player beats the tower.
]]
return Red.Event("Win", function()
    return
end)