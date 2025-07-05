local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {},
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")
local Modules = Source:WaitForChild("Modules")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local GROUP_WALL_NAME = "Group"

local Map = workspace:WaitForChild("Map")
local Lobby = Map:WaitForChild("Lobby")
local GroupWall = Lobby:WaitForChild(GROUP_WALL_NAME, 5)

function toggle(p, bool)
    if not p then
        return
    end

    p.Transparency = bool and 1 or 0.75
    p.CanCollide = if bool then false else true
    p:FindFirstChild("SurfaceGui").Enabled = if bool then false else true
end

--pls bear with me, streamingenabled is pretty dog water so i have to do this
workspace.Map.Lobby.ChildAdded:Connect(function(child)
    if child.Name == GROUP_WALL_NAME then
        GroupWall = child
    end
end)

function Controller.Start()
    local DataController = require(Controllers.DataController)
    local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
    local Data = Replica.Data :: ProfileTemplate.data

    --InGroup updates in real time btw
    Replica:OnSet({"InGroup"}, function()
        if Data.InGroup then
            toggle(GroupWall, true)
        else
            warn(LocalPlayer, "left the group!!!! >:(")
            toggle(GroupWall, false)
        end
    end)

    if Data.InGroup then
        toggle(GroupWall, true)
    end
end

return Controller