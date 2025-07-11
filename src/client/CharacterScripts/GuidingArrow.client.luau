local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Char = script.Parent.Parent
local Assets = ReplicatedStorage.Assets
local World = Assets.World

local BeamTemplate = World.GuideBeam

local NewBeam

local LocalPlayer = Players.LocalPlayer
if LocalPlayer:GetAttribute("PassedSpawn") then
    return
end

LocalPlayer:GetAttributeChangedSignal("PassedSpawn"):Connect(function()
    if LocalPlayer:GetAttribute("PassedSpawn") then
        if NewBeam then
            NewBeam:Destroy()
            NewBeam = nil
        end
    end
end)

NewBeam = BeamTemplate:Clone()
NewBeam.Attachment0 = Char.HumanoidRootPart.RootAttachment
NewBeam.Attachment1 = workspace.Terrain.PointTarget

NewBeam.Parent = Char

local function isOnTop(pos1, pos2)
    local horizontalThreshold = 100
    local minHeightDifference = 1
    
    local horizontalDistance = (Vector3.new(pos1.X, 0, pos1.Z) - Vector3.new(pos2.X, 0, pos2.Z)).Magnitude
    local heightDifference = pos1.Y - pos2.Y
    
    return horizontalDistance <= horizontalThreshold and heightDifference >= minHeightDifference
end

while not LocalPlayer:GetAttribute("PassedSpawn") do
    local charPos = Char:GetPivot().Position
    local targetPos = workspace.Terrain.PointTarget.WorldPosition
    
    if isOnTop(charPos, targetPos) then
        LocalPlayer:SetAttribute("PassedSpawn", true)
        if NewBeam then
            NewBeam:Destroy()
            NewBeam = nil
        end
        break
    end

    task.wait(0.2)
end
