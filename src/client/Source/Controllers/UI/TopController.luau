local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {},
}

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = Shared.Data

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Sides = RootGui.Sides :: Folder
local Up = Sides.Up :: Frame
local ServerTrolls = Up.ServerTrolls

local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local Products = require(Data.Products)

function Controller.Start()
	for i, Button: GuiButton in ServerTrolls:GetChildren() do
		if not Button:IsA("GuiButton") then
			continue
		end

		local ProductData = Products[Button.Name]
		if not ProductData then
			warn("No product data found for", Button.Name)
			continue
		end

		scope:Hydrate(Button)({
			[OnEvent "MouseButton1Click"] = function()
				local ProductId = ProductData.ID
				if not ProductId then
					warn("No ProductId found for", Button.Name)
					return
				end

				MarketplaceService:PromptProductPurchase(LocalPlayer, ProductId)
			end
		})
	end
end

return Controller
