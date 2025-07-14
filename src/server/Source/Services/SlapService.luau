local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Service = {
	Name = script.Name,
}

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared
local Events = Shared.Events
local Functions = Shared.Functions
local Data = Shared.Data

local SlapEvent = require(Events.Slap):Server()
local KnockbackEvent = require(Events.Knockback):Server()

local BuyFunction = require(Functions.Buy)
local EquipFunction = require(Functions.Equip)

local SlapData = require(Data.Slap)

local Tools = ReplicatedStorage.Assets.Tools

local Debounces = {} :: { [number]: boolean }

function Service.Start()
	local PlayerService = require(Services.PlayerService)

	SlapEvent:On(function(Player: Player, HitHumanoid: Humanoid)
		if not HitHumanoid:IsA("Humanoid") then
			warn(Player, "suspicious remote event")
			return
		end

		local UserId = Player.UserId
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?
		local RootPart = Humanoid.RootPart

		if Debounces[UserId] then
			return
		end

		local Tool = Character:FindFirstChildOfClass("Tool")
		if not Tool then
			return
		end

		local ToolData = SlapData[Tool.Name]
		if not ToolData then
			return
		end

		if
			HitHumanoid.Sit
			or HitHumanoid:GetState() == Enum.HumanoidStateType.Physics
			or HitHumanoid:GetState() == Enum.HumanoidStateType.Seated
			or HitHumanoid:GetState() == Enum.HumanoidStateType.PlatformStanding
			or HitHumanoid:GetState() == Enum.HumanoidStateType.None
			or HitHumanoid:GetState() == Enum.HumanoidStateType.Dead
		then
			return
		end

		Debounces[UserId] = true

		task.delay(1, function()
			Debounces[UserId] = nil
		end)

		if Humanoid.Health <= 0 then
			return
		end

		local HitCharacter = HitHumanoid.Parent
		local HitPlayer = Players:GetPlayerFromCharacter(HitCharacter)

		if not HitCharacter then
			return
		end

		if HitCharacter:GetAttribute("Immunity") then
			return
		end

		if not (Humanoid.RootPart and HitHumanoid.RootPart) then
			return
		end

		local Distance = (Humanoid.RootPart.Position - HitHumanoid.RootPart.Position)
		if Distance.Magnitude > 10 * (ToolData.Reach or 1) then
			return
		end

		HitHumanoid:SetAttribute("Tag", Player.Name)
		HitHumanoid:TakeDamage(ToolData.Damage)

		local SlapSound = Tool.Handle:FindFirstChild("Hit") :: Sound?
		if SlapSound then
			SlapSound:Play()
		end

		local Force = ToolData.Force :: number

		local ImpulseVector = (RootPart.CFrame.LookVector + RootPart.CFrame.UpVector * 1.2).Unit

		HitHumanoid.Sit = true

		if HitPlayer then
			KnockbackEvent:Fire(HitPlayer, ImpulseVector * Force)
		else
			HitHumanoid.RootPart:ApplyImpulse(ImpulseVector * Force)
		end

		local Callback = ToolData.Callback
		if Callback then
			task.spawn(Callback, Humanoid, HitHumanoid)
		end

		task.wait(0.5)
		HitHumanoid.Sit = false
	end)

	BuyFunction:SetCallback(function(Player, SelectedItem: string)
		local SelectedData = SlapData[SelectedItem]
		if not SelectedData then
			warn("No slap data found for", SelectedItem)
			return
		end

		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			warn("No player data found for", Player.Name, debug.traceback())
			return
		end

		local Replica = PlayerData.Replica

		if Replica.Data.Coins < (SelectedData.Price or 0) then
			print("Not enough coins to buy item:", SelectedItem, "Player Coins:", Replica.Data.Coins)
			return
		end

		if Replica.Data.SlapsOwned[SelectedItem] then
			warn("Player already owns this item:", SelectedItem)
			return
		end

		Replica:Set({ "Coins" }, Replica.Data.Coins - (SelectedData.Price or 0))
		Player.leaderstats.Coins.Value = Replica.Data.Coins
		Replica:Set({ "SlapsOwned", SelectedItem }, true)
		print("Finalized purchase for", Player.Name, "Item:", SelectedItem)
		return true
	end)

	EquipFunction:SetCallback(function(Player: Player, SelectedItem: string)
		local SelectedData = SlapData[SelectedItem]
		if not SelectedData then
			warn("No slap data found for", SelectedItem, debug.traceback())
			return
		end

		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			warn("No player data found for", Player.Name, debug.traceback())
			return
		end

		local Replica = PlayerData.Replica

		if Debounces[Player] then
			return
		end

		Debounces[Player] = true

		task.delay(0.5, function()
			Debounces[Player] = nil
		end)

		if not Replica.Data.SlapsOwned[SelectedItem] then
			warn("Slap not owned")
			return
		end

		local name = string.gsub(SelectedItem, " ", "_")
		Player:SetAttribute(name, true)

		local Character = Player.Character
		local FoundTool = Player.Backpack:FindFirstChild(SelectedItem) or Character:FindFirstChild(SelectedItem)
		if FoundTool then
			return
		end

		local NewTool = Tools:FindFirstChild(SelectedItem):Clone()
		NewTool.Parent = Player.Backpack

		return true, name
	end)
end

return Service
