local Character = script.Parent.Parent
local prox = Character.HumanoidRootPart:WaitForChild("ExplodePrompt", 10)
if prox then
    prox:Destroy()
end

Character.HumanoidRootPart.ChildAdded:Connect(function(inst)
    if inst:IsA("ProximityPrompt") and inst.Name == "ExplodePrompt" then
        inst:Destroy()
    end
end)
