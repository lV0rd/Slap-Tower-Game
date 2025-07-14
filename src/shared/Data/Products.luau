local function randomForce(min, max)
	return math.random(min, max) * (math.random(1, 2) == 1 and -1 or 1)
end

return {
	["SkipTroll"] = {
		ID = 3320291590,
		Callback = function(Player, PlayerData)
			local TargetCFrame = Player:GetAttribute("SkipTrollCFrame")
			if not TargetCFrame then
				warn(Player, "target cframe for skip troll not found.")
				return
			end

			local Character = Player.Character
			if not Character then
				warn(Player, "character not found for skip troll.")
				return
			end

			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				warn(Player, "humanoid root part not found for skip troll.")
				return
			end

			HumanoidRootPart.CFrame = TargetCFrame
			Player:SetAttribute("SkipTrollCFrame", nil)

			return true
		end,
	},

	["SkipTower"] = {
		ID= 3333535950,
		Callback = function(Player, PlayerData)
			local Character = Player.Character
			if not Character then
				return
			end

			Character:PivotTo(workspace.Map.End.CFrame)
		end
	},

	["Explode"] = {
		ID = 3322885540,
		Callback = function(Player, PlayerData)
			local TargetPlayerName = Player:GetAttribute("TargetPlayer")
			if not TargetPlayerName then
				warn(Player, "target cframe for skip troll not found.")
				return
			end

			local TargetPlayer = game.Players:FindFirstChild(TargetPlayerName)
			if not TargetPlayer then
				warn(Player, "target player not found for skip troll.")
				return
			end

			local Character = TargetPlayer.Character
			if not Character then
				warn(Player, "character not found for skip troll.")
				return
			end

			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				warn(TargetPlayer, "humanoid root part not found for skip troll.")
				return
			end

			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				warn(TargetPlayer, "humanoid not found for skip troll.")
				return
			end

			local Explosion = Instance.new("Explosion")
			Explosion.Position = HumanoidRootPart.Position
			Explosion.BlastRadius = 0
			Explosion.Parent = workspace
			Humanoid.Health = 0

			Player:SetAttribute("TargetPlayer", nil)

			return true
		end,
	},

	["Kill"] = {
		ID = 3324732417,
		Callback = function(Player, PlayerData)
			local TargetPlayerName = Player:GetAttribute("TargetPlayer")
			if not TargetPlayerName then
				warn(Player, "target cframe for skip troll not found.")
				return
			end

			local TargetPlayer = game.Players:FindFirstChild(TargetPlayerName)
			if not TargetPlayer then
				warn(Player, "target player not found for skip troll.")
				return
			end

			local Character = TargetPlayer.Character
			if not Character then
				warn(Player, "character not found for skip troll.")
				return
			end

			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				warn(TargetPlayer, "humanoid not found for skip troll.")
				return
			end

			Humanoid.Health = 0

			Player:SetAttribute("TargetPlayer", nil)

			return true
		end,
	},

	["Fling"] = {
		ID = 3324732418,
		Callback = function(Player, PlayerData)
			local TargetPlayerName = Player:GetAttribute("TargetPlayer")
			if not TargetPlayerName then
				warn(Player, "target player name not found.")
				return
			end

			local TargetPlayer = game.Players:FindFirstChild(TargetPlayerName)
			if not TargetPlayer then
				warn(Player, "target player not found for skip troll.")
				return
			end

			local Character = TargetPlayer.Character
			if not Character then
				warn(Player, "character not found for troll.")
				return
			end

			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				warn(TargetPlayer, "humanoid root part not found for skip troll.")
				return
			end

			for _, v in ipairs(HumanoidRootPart:GetChildren()) do
				if v:IsA("LinearVelocity") and v.Name == "FlingForce" then
					v:Destroy()
				end
			end

			local flingForce = Instance.new("LinearVelocity")
			flingForce.Name = "FlingForce"
			flingForce.Attachment0 = HumanoidRootPart.RootAttachment
			flingForce.MaxForce = math.huge
			flingForce.RelativeTo = Enum.ActuatorRelativeTo.World
			flingForce.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector

			local randomVelocity = Vector3.new(randomForce(300, 1000), math.random(500, 1200), randomForce(300, 1000))

			flingForce.VectorVelocity = randomVelocity
			flingForce.Parent = HumanoidRootPart

			task.delay(0.2, function()
				if flingForce and flingForce.Parent then
					flingForce:Destroy()
				end
			end)

			Player:SetAttribute("TargetPlayer", nil)

			return true
		end,
	},

	["Kill All"] = {
		ID = 3326617051,
		Callback = function(Player, PlayerData)
			for _, v in ipairs(game.Players:GetPlayers()) do
				if v.Character then
					local Humanoid = v.Character:FindFirstChildOfClass("Humanoid")
					if Humanoid then
						Humanoid.Health = 0
					end
				end
			end

			return true
		end,
	},

	["Explode All"] = {
		ID = 3326617050,
		Callback = function(Player, PlayerData)
			for _, v in ipairs(game.Players:GetPlayers()) do
				if v.Character then
					local HumanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						local Explosion = Instance.new("Explosion")
						Explosion.Position = HumanoidRootPart.Position
						Explosion.BlastRadius = 0
						Explosion.BlastPressure = 0
						Explosion.Parent = workspace
						v.Character.Humanoid.Health = 0
					end
				end
			end

			return true
		end,
	},

	["Fling All"] = {
		ID = 3326617052,
		Callback = function(Player, PlayerData)
			for _, v in ipairs(game.Players:GetPlayers()) do
				if v.Character then
					local HumanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						for _, child in ipairs(HumanoidRootPart:GetChildren()) do
							if child:IsA("LinearVelocity") and child.Name == "FlingForce" then
								child:Destroy()
							end
						end

						local flingForce = Instance.new("LinearVelocity")
						flingForce.Name = "FlingForce"
						flingForce.Attachment0 = HumanoidRootPart.RootAttachment
						flingForce.MaxForce = math.huge
						flingForce.RelativeTo = Enum.ActuatorRelativeTo.World
						flingForce.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector

						local randomVelocity = Vector3.new(randomForce(300, 1000), math.random(500, 1200), randomForce(300, 1000))

						flingForce.VectorVelocity = randomVelocity
						flingForce.Parent = HumanoidRootPart

						task.delay(0.2, function()
							if flingForce and flingForce.Parent then
								flingForce:Destroy()
							end
						end)
					end
				end
			end

			return true
		end,
	},
}
