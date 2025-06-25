local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		for _, Part in pairs(Character:GetDescendants()) do
			if Part:IsA("BasePart") then
				Part.CollisionGroup = "Players"
			end
		end
	end)
end)