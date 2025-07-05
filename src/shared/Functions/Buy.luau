local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Function("Buy", function(SelectedItem)
    return Guard.String(SelectedItem)
end, function(result)
    return Guard.Boolean(result)
end)