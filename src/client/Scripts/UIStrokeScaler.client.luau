local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui", 100)

for i, v in RootGui:GetDescendants() do
	if v:IsA("UIStroke") then
		local BASE_SIZE = 1200
		local uiStroke = v
		local initialStrokeThickness = uiStroke.Thickness
		local camera = game:GetService("Workspace").CurrentCamera
		local function updateStrokeThickness()
			uiStroke.Thickness = initialStrokeThickness * camera.ViewportSize.X / BASE_SIZE
		end
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateStrokeThickness)
		updateStrokeThickness()
	end
end