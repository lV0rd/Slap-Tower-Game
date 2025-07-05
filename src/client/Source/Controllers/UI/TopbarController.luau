local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
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

local Packages = ReplicatedStorage.Packages

local TopbarPlus = require(Packages.TopbarPlus)

function Controller.Start()
	local DataController = require(Controllers.DataController)
	local MusicController = require(Controllers.MusicController)
	local Replica = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	local Data = Replica.Data :: ProfileTemplate.data

	local section = TopbarPlus.new()

	section:setLabel("MORE!"):setMenu({
		TopbarPlus.new()
			:setLabel("Premium Glove!")
			:setImage(6071020687)
			:bindEvent("selected", function()
				if Data.HasPremium then
					return
				end

				MarketplaceService:PromptPremiumPurchase(LocalPlayer)
			end)
			:oneClick(),

		TopbarPlus.new()
			:setLabel("Invite Friends!")
			:setImage(17349099636)
			:bindEvent("selected", function()
				local inviteOptions = Instance.new("ExperienceInviteOptions")
				inviteOptions.PromptMessage = "Invite friends for a reward!"
				SocialService:PromptGameInvite(LocalPlayer, inviteOptions)
			end)
			:oneClick(),
	})

	local MusicIcon = TopbarPlus.new()

	MusicIcon
		:setCaption("Toggle music!")
		:setImage(476273349)
		:bindEvent("selected", function()
			MusicController:Toggle()
		end)
		:oneClick()
		:align("Right")
end

return Controller
