local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local DanceSlapEmote = Animations.DanceSlapEmote

return {
	--Free
	["Slap"] = {
		Force = 550,
		Damage = 1,
		DebounceTime = 15,
	},

	["OP Slap"] = {
		Force = 750,
		Damage = 6,
		DebounceTime = 10,
	},

	["Punch Slap"] = {
		Force = 750,
		Damage = 6,
		DebounceTime = 10,
	},

	["Void Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
	},

	["Dance Slap"] = {
		Force = 750,
		Damage = 6,
		DebounceTime = 10,
		Callback = function(Humanoid: Humanoid, HitHumanoid: Humanoid) --this will fire in its own thread.
			if HitHumanoid.Health <= 0 then
				return
			end

			local Animator = HitHumanoid:FindFirstChildOfClass("Animator")
			if not Animator then
				return
			end

			local Animation = Animator:LoadAnimation(DanceSlapEmote)
			Animation.Looped = true
			Animation:Play()

			task.delay(5, function()
				if Animation.IsPlaying then
					Animation:Stop()
				end
			end)
		end,
	},

	--Win
	["Winner Slap"] = {
		Force = 650,
		Damage = 10,
		DebounceTime = 6,
	},

	--Gamepasss
	["Rainbow Slap"] = {
		Force = 11650,
		Damage = 60,
		DebounceTime = 6,
	},

	--Paid
	["Diamond Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,

		Description = "A slap made of pure diamond, it sparkles and shines.",
		Price = 1000,
	},

	["Freeze Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
		Callback = function(Humanoid: Humanoid, HitHumanoid: Humanoid) --this will fire in its own thread.
			local HitCharacter = HitHumanoid.Parent
			if not HitCharacter then
				return
			end

			local OldColors = {} :: { [string]: Color3 }

			for i, v in HitCharacter:GetChildren() do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
					OldColors[v.Name] = v.Color
					v.Color = Color3.fromRGB(69, 117, 172)
				end
			end

			HitHumanoid.PlatformStand = true

			task.wait(2)

			for i, v in HitCharacter:GetChildren() do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
					v.Color = OldColors[v.Name] or Color3.fromRGB(255, 255, 255)
				end
			end

			HitHumanoid.PlatformStand = false
		end,

		Description = "Freezes players for 2 seconds, makes them chill.",
		Price = 7500
	},

	["Lava Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
		Callback = function(Humanoid, HitHumanoid) --this will fire in its own thread.
			local connection
			local start = workspace:GetServerTimeNow()
			local debounce = 0

			local Fire = Instance.new("Fire", HitHumanoid.RootPart)

			connection = RunService.PreSimulation:Connect(function()
				local servertime = workspace:GetServerTimeNow()
				if servertime - start >= 4 then
					connection:Disconnect()
					connection = nil

					if Fire then
						Fire:Destroy()
					end

					return
				end

				if servertime - debounce <= 0.5 then
					return
				end

				debounce = servertime

				HitHumanoid:TakeDamage(7)
			end)
		end,

		Description = "Burns players for 4 seconds, dealing 7 damage every 0.5 seconds.",
		Price = 15000,
	},

	["Steel Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
		Callback = function(Humanoid, HitHumanoid) --this will fire in its own thread.
			HitHumanoid.WalkSpeed -= 10

			task.delay(3, function()
				HitHumanoid.WalkSpeed += 10
			end)
		end,
		
		Description = "Slows down players for 3 seconds, making them feel heavy.",
		Price = 3000,
	},

	--Premium
	["Premium Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
	},
}
