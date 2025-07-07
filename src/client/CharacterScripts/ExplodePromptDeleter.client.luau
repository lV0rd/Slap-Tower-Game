local Players = game:GetService("Players")

local Character = script.Parent.Parent
local LocalPlayer = Players.LocalPlayer
if LocalPlayer.Character ~= Character then
    return
end

local prox = Character.HumanoidRootPart:WaitForChild("ExplodePrompt", 10)
if prox then
    prox:Destroy()
end

Character.HumanoidRootPart.ChildAdded:Connect(function(inst)
    if inst:IsA("ProximityPrompt") and inst.Name == "ExplodePrompt" then
        inst:Destroy()
    end
end)
