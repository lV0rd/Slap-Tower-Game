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

			local Explosion = Instance.new("Explosion")
			Explosion.Position = HumanoidRootPart.Position
			Explosion.BlastRadius = 0.1
			Explosion.BlastPressure = 100
			Explosion.Parent = workspace

			Player:SetAttribute("TargetPlayer", nil)

			return true
		end,
	},
}
