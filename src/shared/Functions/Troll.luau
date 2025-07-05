local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Function("Troll", function(TargetPlayer)
    return Guard.String(TargetPlayer)
end, function(result)
    return Guard.Boolean(result)
end)