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
local Utils = Shared.Utils

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Sides = RootGui.Sides :: Folder
local Right = Sides.Right :: Frame
local Stats = Right.Stats

local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local Format = require(Utils.Format)

local scope = Fusion.scoped(Fusion)


function Controller.Start()
	local DataController = require(Controllers.DataController)
	local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	local Data = Replica.Data :: ProfileTemplate.data

	local DataValues = {
		Wins = scope:Value(Data.Wins),
		Coins = scope:Value(Data.Coins),
	}

	Replica:OnSet({"Wins"}, function()
		DataValues["Wins"]:set(Data.Wins)
	end)

	Replica:OnSet({"Coins"}, function()
		DataValues["Coins"]:set(Data.Coins)
	end)

	for i, Button: GuiButton in Stats:GetChildren() do
		if not Button:IsA("TextLabel") then
			continue
		end

		local StatData = Button.Name
		if not Data[StatData] then
			warn("No data found for", StatData)
			continue
		end

		local DataValue = DataValues[StatData]
		if not DataValue then
			warn("No data value found for", StatData)
			continue
		end

		scope:Hydrate(Button.Amount)({
			Text = scope:Computed(function(use)
				return Format.abbreviate(use(DataValue))
			end)
		})
	end
end

return Controller
