local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Modules = Source:WaitForChild("Modules")
local Controllers = Source:WaitForChild("Controllers")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui
local Frames = Canvas.Frames

local ShopFrame = Frames.Shop.Main
local CloseButton = ShopFrame.Top.Close

local Gamepasses = ShopFrame.Elements

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local Gamepass = require(Shared.Data.Gamepass)

local Fusion = require(Packages.Fusion)
local Future = require(Packages.Future)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

function Controller.Start()
	local GuiController = require(Controllers.GuiController)
    local DataController = require(Controllers.DataController)
    local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
    local Data = Replica.Data :: ProfileTemplate.data

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Close(ShopFrame.Parent)
		end,
	})

	--Gamepasses
	for i, v in Gamepasses:GetChildren() do
		if not v:IsA("GuiButton") then
			continue
		end

		local GamepassData = Gamepass[v.Name]
		if not GamepassData then
			warn("No gamepass data found for ", v.Name)
			continue
		end

		local GamepassRobloxInfo = Future.new(function()
			return MarketplaceService:GetProductInfo(GamepassData.ID, Enum.InfoType.GamePass)
		end):Await()

		local Price = GamepassRobloxInfo.PriceInRobux
		v.Price.TextLabel.Text = "R$"..Price
		v.Title.Text = v.Name
		v.Icon.Image = "rbxassetid://"..GamepassRobloxInfo.IconImageAssetId

		scope:Hydrate(v) {
			[OnEvent "MouseButton1Click"] = function()
                if Data.Gamepasses[v.Name] then
                    return
                end
                
				MarketplaceService:PromptGamePassPurchase(LocalPlayer, GamepassData.ID)
			end
		}
	end
end

return Controller