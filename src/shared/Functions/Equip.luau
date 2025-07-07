local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Function("Equip", function(SelectedItem)
    return Guard.String(SelectedItem)
end, function(result, name)
    return Guard.Boolean(result), Guard.String(name)
end)