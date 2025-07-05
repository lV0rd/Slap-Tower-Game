local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui
local Frames = Canvas.Frames

local TrollFrame = Frames.Troll
local CloseButton = TrollFrame.Close

local Trolls = TrollFrame.Buttons
local Spectate = TrollFrame.Spectate

local Next = Spectate.Next
local Previous = Spectate.Previous
local Username = Spectate.Username

local Fusion = require(Packages.Fusion)

local TrollFunction = require(Shared.Functions.Troll)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local Products = require(Shared.Data.Products)

local Debounce = false

function Controller.Start()
	local GuiController = require(Controllers.GuiController)

	local TargetPlayer = scope:Value(LocalPlayer.Name)

	local observer = scope:Observer(TargetPlayer)

	GuiController.CloseSignal:Connect(function(Frame)
		if Frame ~= TrollFrame then
			return
		end

		TargetPlayer:set(LocalPlayer.Name)
	end)

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Close(TrollFrame)

			TargetPlayer:set(LocalPlayer.Name)
		end,
	})

	scope:Hydrate(Username.TextLabel)({
		Text = TargetPlayer,
	})

	--fix next and previous, and allow them to infinitly loop through players
	scope:Hydrate(Next)({
		[OnEvent("Activated")] = function()
			local PlayersList = Players:GetPlayers()
			local currentName = peek(TargetPlayer)
			local CurrentIndex = 1
			for i, player in ipairs(PlayersList) do
				if player.Name == currentName then
					CurrentIndex = i
					break
				end
			end
			local NextIndex = (CurrentIndex % #PlayersList) + 1

			TargetPlayer:set(PlayersList[NextIndex].Name)
		end,
	})

	scope:Hydrate(Previous)({
		[OnEvent("Activated")] = function()
			local PlayersList = Players:GetPlayers()
			local currentName = peek(TargetPlayer)
			local CurrentIndex = 1
			for i, player in ipairs(PlayersList) do
				if player.Name == currentName then
					CurrentIndex = i
					break
				end
			end
			local PreviousIndex = (CurrentIndex - 2) % #PlayersList + 1

			TargetPlayer:set(PlayersList[PreviousIndex].Name)
		end,
	})

	observer:onChange(function(newPlayerName)
		if peek(TargetPlayer) == LocalPlayer.Name then
			local Character = LocalPlayer.Character
			if not Character then
				return
			end

			camera.CameraSubject = Character.Humanoid
			camera.CameraType = Enum.CameraType.Custom

			return
		end

		local player = Players:FindFirstChild(peek(TargetPlayer))
		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = player.Character.Humanoid
		end
	end)

	--Trolls
	for i, v in Trolls:GetChildren() do
		if not v:IsA("GuiButton") then
			continue
		end

		local ProductData = Products[v.Name]
		if not ProductData then
			warn("No product data found for ", v.Name)
			continue
		end

		scope:Hydrate(v)({
			[OnEvent("Activated")] = function()
				if peek(TargetPlayer) == LocalPlayer.Name then
					return
				end

				if Debounce then
					return
				end

				Debounce = true

				local Success, Result = TrollFunction:Call(peek(TargetPlayer)):Await()

				Debounce = false

				if not Success then
					warn("Failed to troll player: ", peek(TargetPlayer))
					return
				end

				if not Result then
					return
				end

				MarketplaceService:PromptProductPurchase(LocalPlayer, ProductData.ID)
			end,
		})
	end
end

return Controller
