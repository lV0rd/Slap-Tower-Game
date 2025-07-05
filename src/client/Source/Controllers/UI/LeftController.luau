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

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Frames = RootGui.Frames
local Sides = RootGui.Sides :: Folder
local Left = Sides.Left :: Frame
local Buttons = Left.Buttons

local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local GuiController = require(Controllers.GuiController)

local Types = {
	["Open"] = function(Button : GuiButton, Data : ProfileTemplate.data)
		scope:Hydrate(Button)({
			[OnEvent("MouseButton1Click")] = function()
				GuiController:Toggle(Frames:FindFirstChild(Button.Name))
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
