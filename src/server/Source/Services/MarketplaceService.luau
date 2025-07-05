--[[
MarketplaceService.luau 2025/05/13

Handling gamepass and dev products purchasing safely
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared
local Data = Shared.Data

local Products = require(Data.Products)
local Gamepasses = require(Data.Gamepass)

local Service = {
	Name = script.Name,
}

local PURCHASE_ID_CACHE_SIZE = 100

function match(t, c)
    for i, e in t do
        if c(e) then
            return e
        end
    end

    return nil
end

local function PurchaseIdCheckAsync(profile, purchase_id, grant_product): Enum.ProductPurchaseDecision
	profile = profile

	if profile:IsActive() == true then
		local purchase_id_cache = profile.Data.PurchaseIdCache
		if purchase_id_cache == nil then
			purchase_id_cache = {}
			profile.Data.PurchaseIdCache = purchase_id_cache
		end

		if table.find(purchase_id_cache, purchase_id) == nil then
			local success, result = pcall(grant_product)
			if success ~= true then
				warn(`Failed to process receipt:`, profile.Key, purchase_id, result)
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end

			while #purchase_id_cache >= PURCHASE_ID_CACHE_SIZE do
				table.remove(purchase_id_cache, 1)
			end

			table.insert(purchase_id_cache, purchase_id)
		end

		local function is_purchase_saved()
			local saved_cache = profile.LastSavedData.PurchaseIdCache
			return if saved_cache ~= nil then table.find(saved_cache, purchase_id) ~= nil else false
		end

		if is_purchase_saved() == true then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		while profile:IsActive() == true do
			local last_saved_data = profile.LastSavedData

			profile:Save()

			if profile.LastSavedData == last_saved_data then
				profile.OnAfterSave:Wait()
			end

			if is_purchase_saved() == true then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end

			if profile:IsActive() == true then
				task.wait(10)
			end
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function Service.Start()
	local PlayerService = require(Services.PlayerService)

	local function Handle(ReceiptInfo)
		local player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)
		
		if player ~= nil then
			print("player does exist")
			local profile = PlayerService:GetPlayer(player)

			while profile == nil and player.Parent == Players do
				profile = PlayerService:GetPlayer(player)
				if profile ~= nil then
					break
				end
				task.wait()
			end

			if not profile then
				warn("no profile?")
				return
			end

            local ProductData = match(Products, function(v)
                return v.ID == ReceiptInfo.ProductId
            end)

			if not ProductData then
				warn(`Product with ID {ReceiptInfo.ProductId} not found in Products`)
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end

			return PurchaseIdCheckAsync(profile.Profile, ReceiptInfo.PurchaseId, function()
				ProductData.Callback(player, profile)
			end)
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local function GamepassHandle(Player: Player, GamepassId: number, Purchased: boolean)
		if Purchased == true then
			local PlayerData = PlayerService:GetPlayer(Player)
			if not PlayerData then
				return
			end

			for i, v in Gamepasses do
				if PlayerData.Replica.Data.Gamepasses[v.ID] ~= nil then
					continue
				end

				if v.ID == tostring(GamepassId) then
					PlayerData.Replica:Set({ "Gamepasses", v.ID }, true)
					continue
				end

				PlayerData.Replica:Set({ "Gamepasses", v.ID }, false)
			end

			if not PlayerData.Replica.Data.Gamepasses[tostring(GamepassId)] then
				PlayerData.Replica:Set({ "Gamepasses", tostring(GamepassId) }, true)
			else
				return
			end

            local gamepassData= match(Gamepasses, function(v)
                return v.ID == GamepassId
            end)

			if not gamepassData then
				return
			end

			gamepassData.Callback(Player, PlayerData)
		end
	end
		
	local function PremiumHandle(Player)
		if Player.MembershipType == Enum.MembershipType.Premium then
			local PlayerData = PlayerService:GetPlayer(Player)
			if not PlayerData then
				return
			end

			PlayerData.Replica:Set({ "HasPremium" }, true)

			local PremiumSlap = ReplicatedStorage.Tools:FindFirstChild("Premium Slap")
			if not PremiumSlap then
				error("Premium Slap not found in Tools")
			end

			local PremiumSlapClone = PremiumSlap:Clone()
			PremiumSlapClone.Parent = Player.Backpack
		end
	end

	MarketplaceService.ProcessReceipt = Handle
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(GamepassHandle)
	Players.PlayerMembershipChanged:Connect(PremiumHandle)
end

return Service