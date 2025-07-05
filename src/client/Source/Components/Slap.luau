local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage.Packages

local Shared = ReplicatedStorage.Shared
local Events = Shared.Events
local Data = Shared.Data

local SlapEvent = require(Events.Slap):Client()

local SlapData = require(Data.Slap)

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

local PLAYER_DETECTION_ONLY = false

function weld(p1, p2)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p1
	weldConstraint.Part1 = p2
	weldConstraint.Parent = p1
end

function module.new(instance: Tool)
	local Data = SlapData[instance.Name]
	if not Data then
		warn("no slap data found for ", instance)
		return
	end

	local self = setmetatable({
		Instance = instance :: Tool,
		Data = Data,
		Janitor = Janitor.new(),
		debounce = false :: boolean,
		DebounceTime = Data.DebounceTime or 1,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)

	--Check ownership
	if self.Instance.Parent ~= LocalPlayer.Backpack and self.Instance.Parent ~= LocalPlayer.Character then
		return
	end

	self.Janitor:Add(self.Instance.Activated:Connect(function()
		local Hitbox
		local connection

		if self.debounce then
			return
		end
		self.debounce = true

		task.delay(self.DebounceTime, function()
			self.debounce = nil
		end)

		local Character = LocalPlayer.Character
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		local Animation = Animator and Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Swing)
		if Animation then
			Animation:Play()
		end

		if self.Instance.Parent ~= Character then
			return
		end

		local RootPart = Humanoid.RootPart
		Hitbox = Instance.new("Part")
		Hitbox.Size = Vector3.new(8, 5, 6)
		Hitbox.Transparency = 1
		Hitbox.CanCollide = false
		Hitbox.Anchored = false
		Hitbox.Massless = true
		Hitbox.CFrame = CFrame.new(RootPart.Position + RootPart.CFrame.LookVector * (Hitbox.Size.Z / 2) * 1.25)
			* CFrame.Angles(0, RootPart.Orientation.Y * math.pi / 180, 0)
		Hitbox.Parent = workspace
		weld(Hitbox, RootPart)

		task.delay(0.5, function()
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if Hitbox then
				Hitbox:Destroy()
			end
		end)

		connection = RunService.Heartbeat:Connect(function()
			local parts = workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size, nil)

			for _, part in ipairs(parts) do
				local char = part:FindFirstAncestorOfClass("Model")
				local hum = char and char:FindFirstChildOfClass("Humanoid")

				if hum and char ~= Character and not char:GetAttribute("Immunity") then
					local hitPlayer = Players:GetPlayerFromCharacter(char)

					if PLAYER_DETECTION_ONLY then
						if hitPlayer then
							if connection then
								connection:Disconnect()
								connection = nil
							end

							if Hitbox then
								Hitbox:Destroy()
							end

							SlapEvent:Fire(hum)
							break
						end
					else
						if connection then
								connection:Disconnect()
								connection = nil
							end

							if Hitbox then
								Hitbox:Destroy()
							end

							SlapEvent:Fire(hum)
						break
					end
				end
			end
		end)
	end))
end

function module:_cleanup()
	if table.find(Components, self) then
		table.remove(Components, table.find(Components, self))
	end

	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
