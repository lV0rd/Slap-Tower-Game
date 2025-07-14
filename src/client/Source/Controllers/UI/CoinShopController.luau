local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")
local Modules = Source:WaitForChild("Modules")

local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui
local Frames = Canvas.Frames

local CoinShopFrame = Frames.CoinShop.Main
local CloseButton = CoinShopFrame.Top.Close

local Preview = CoinShopFrame.Preview
local Elements = CoinShopFrame.Elements

--workspace stuff
local Map = workspace:WaitForChild("Map")
local Stands = Map.Stands
local ShopStand = Stands:WaitForChild("CoinShop") --this model is persistent

local ProximityPart = ShopStand.ProximityPart
local ProximityPrompt = ProximityPart.ProximityPrompt :: ProximityPrompt

local Functions = Shared.Functions

local ReplicaClient = require(Modules.ReplicaClient)
local ProfileTemplate = require(Shared.Data.ProfileTemplate)

local Fusion = require(Packages.Fusion)

local BuyFunction = require(Functions.Buy)
local EquipFunction = require(Functions.Equip)

local Slaps = require(Shared.Data.Slap)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

function Controller.Start()
	local GuiController = require(Controllers.GuiController)
	local DataController = require(Controllers.DataController)
	local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	local Data = Replica.Data :: ProfileTemplate.data

	local SelectedItem = scope:Value(nil)

	local observer = scope:Observer(SelectedItem)

	local SlapsOwned = {}

	Preview.Visible = false

	for i, v in Data.SlapsOwned do
		if Slaps[i] then
			table.insert(SlapsOwned, i)
		end
	end

	local function updatePreview()
		local ItemData = Slaps[peek(SelectedItem)]
		if not ItemData then
			Preview.Visible = false
			return
		end

		Preview.ItemName.Text = peek(SelectedItem)
		Preview.Image.Image = Elements[peek(SelectedItem)].Image.Image

		if ItemData.Description then
			Preview.Description.Text = ItemData.Description
		else
			Preview.Description.Text = "No description available."
		end

		local name = string.gsub(peek(SelectedItem), " ", "_")
		local hasAttribute = LocalPlayer:GetAttribute(name)

		if table.find(SlapsOwned, peek(SelectedItem)) then
			Preview.Buy.TextLabel.Text = hasAttribute and "Equipped" or "Equip"
			Preview.Buy.BackgroundColor3 = Color3.fromRGB(217, 255, 0)
			Preview.Buy.UIStroke.Color = Color3.fromRGB(190, 190, 0)
			Preview.Buy.Active = if hasAttribute then false else true
		else
			Preview.Buy.TextLabel.Text = "Buy for " .. tostring(ItemData.Price or 0) .. " coins"
			Preview.Buy.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			Preview.Buy.UIStroke.Color = Color3.fromRGB(0, 158, 0)
		end

		Preview.Visible = true
	end

	Replica:OnChange(function(action, path, value)
		if action ~= "Set" then
			return
		end

		if path[1] ~= "SlapsOwned" then
			return
		end

		if not value then
			return
		end

		local found = table.find(SlapsOwned, path[2])
		if found then
			return
		end

		table.insert(SlapsOwned, path[2])

		if peek(SelectedItem) == path[2] then
			updatePreview()
		end
	end)

	scope:Hydrate(CloseButton)({
		[OnEvent("MouseButton1Click")] = function()
			GuiController:Close(CoinShopFrame.Parent)
		end,
	})

	GuiController.CloseSignal:Connect(function(Frame)
		if Frame ~= CoinShopFrame then
			return
		end

		SelectedItem:set(nil)
	end)

	ProximityPrompt.Triggered:Connect(function(Triggerer)
		if Triggerer ~= LocalPlayer then
			return
		end

		GuiController:Toggle(CoinShopFrame.Parent)

		if peek(SelectedItem) then
			SelectedItem:set(nil)
		end
	end)

	observer:onChange(function()
		if peek(SelectedItem) then
			updatePreview()
		else
			Preview.Visible = false
		end
	end)

	scope:Hydrate(Preview.Buy)({
		[OnEvent("MouseButton1Click")] = function()
			if not peek(SelectedItem) then
				return
			end

			if table.find(SlapsOwned, peek(SelectedItem)) then
				--EQUIP
				local Success, Result = EquipFunction:Call(peek(SelectedItem)):Await()
				if not Success then
					warn("Failed to equip item: ", Result)
					return
				end

				updatePreview()
			else
				--BUY
				local SelectedData = Slaps[peek(SelectedItem)]
				if not SelectedData then
					warn("No item data found for ", peek(SelectedItem))
					return
				end

				if Data.Coins < (SelectedData.Price or 0) then
					warn("Not enough coins to buy item: ", peek(SelectedItem))
					return
				end

				local Success, Result = BuyFunction:Call(peek(SelectedItem)):Await()
				if not Success then
					warn("Failed to buy item: ", Result, debug.traceback())
					return
				end

				if not Result then
					warn("Failed to buy item: ", peek(SelectedItem), debug.traceback())
					return
				end

				if Result then
					print("Successfully bought item: ", peek(SelectedItem), debug.traceback())

					local S, R = EquipFunction:Call(peek(SelectedItem)):Await()
					print("hi?")
					if not S then
						warn("Failed to equip item: ", R)
						return
					else
						print("hi????")
						print(R)
					end

					updatePreview()
				end
			end
		end,
	})

	for i, v in Elements:GetChildren() do
		if not v:IsA("GuiButton") then
			continue
		end

		local ItemData = Slaps[v.Name]
		if not ItemData then
			warn("No item data found for ", v.Name)
			continue
		end

		v.ItemName.Text = v.Name
		v.Price.Text = tostring(ItemData.Price or 0) .. "$"
		v.LayoutOrder = ItemData.Price or 0
		v.Image.Image = ItemData.Image or "rbxassetid://103366768458485"

		scope:Hydrate(v)({
			[OnEvent("MouseButton1Click")] = function()
				if peek(SelectedItem) == v.Name then
					SelectedItem:set(nil)
				else
					SelectedItem:set(v.Name)
				end

				for i, v in SlapsOwned do
					print(i, v)
				end
			end,
		})
	end
end

return Controller
