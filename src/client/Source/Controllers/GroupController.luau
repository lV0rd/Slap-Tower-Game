local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {},
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")

local Modules = Source:WaitForChild("Modules")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local Map = workspace:WaitForChild("Map")
local Lobby = Map:WaitForChild("Lobby")
local GroupWall = Lobby:WaitForChild("Group", 200)

function Controller.Start()
    local DataController = require(Controllers.DataController)
    local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
    local Data = Replica.Data :: ProfileTemplate.data

    Replica:OnSet({"InGroup"}, function()
        print(Data.InGroup and "Yay" or "Left?")
        if Data.InGroup then
            GroupWall:Destroy()
        end
    end)

    if Data.InGroup then
        GroupWall:Destroy()
    end
end

return Controller