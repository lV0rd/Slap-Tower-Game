local RunService = game:GetService("RunService")

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
	["Void Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
	},

    ["Diamond Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
	},

	["Freeze Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
		Callback = function(Humanoid : Humanoid, HitHumanoid : Humanoid) --this will fire in its own thread.
			local HitCharacter = HitHumanoid.Parent
			if not HitCharacter then
				return
			end

            local OldColors = {} :: {[string] : Color3}

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
	},

    ["Lava Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
		Callback = function(Humanoid, HitHumanoid) --this will fire in its own thread.
			local connection
            local start = workspace:GetServerTimeNow()
            local debounce = 0
            
            connection = RunService.PreSimulation:Connect(function()
                local servertime = workspace:GetServerTimeNow()
                if servertime - start >= 4 then
                    connection:Disconnect()
                    connection = nil
                    return
                end

                if servertime - debounce <= 0.5 then
                    return
                end

                debounce = servertime

                HitHumanoid:TakeDamage(7)
            end)
		end,
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
	},

	--Premium
	["Premium Slap"] = {
		Force = 850,
		Damage = 15,
		DebounceTime = 7,
	},
}
