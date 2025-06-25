local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {},
}
local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")

local Modules = Source:WaitForChild("Modules")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = Shared.Data

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local LocalPlayer = Players.LocalPlayer

local GamepassData = require(Data.Gamepass)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Sides = RootGui.Sides :: Folder
local Left = Sides.Left :: Frame
local Buttons = Left.Buttons

local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local Types = {
	["Gamepass"] = function(Button : GuiButton, Data : ProfileTemplate.data)
		local GamepassName = Button.Name
		local gamepassData = GamepassData[GamepassName]

		if not gamepassData then
			warn("No gamepass data found for", gamepassData)
			return
		end

		scope:Hydrate(Button)({
			[OnEvent("MouseButton1Click")] = function()
				if Data.Gamepasses[tostring(gamepassData.ID)] then
					return
				end

				MarketplaceService:PromptGamePassPurchase(LocalPlayer, gamepassData.ID)
			end,
		})
	end,
}

function Controller.Start()
	local DataController = require(Controllers.DataController)
	local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	local Data = Replica.Data :: ProfileTemplate.data

	for i, Button: GuiButton in Buttons:GetChildren() do
		if Button:IsA("GuiButton") then
			if not Button:GetAttribute("Type") then
                return
			end

            Types[Button:GetAttribute("Type")](Button, Data)
		end
	end
end

return Controller
