local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local Controller = {
	Name = script.Name,

	States = {},
}

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Sides = RootGui.Sides :: Folder
local Down = Sides.Down :: Frame
local FriendPopup = Down.FriendPopup

local PlayerHeadshot = FriendPopup.PlayerHeadshot
local Description = FriendPopup.Description

local Close = FriendPopup.Close
local Invite = FriendPopup.Invite

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Events = Shared.Events

local FriendJoined = require(Events.FriendJoined):Client()

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local Prompted = false

local NO_FRIENDS_COOLDOWN = 5
local POP_UP_COOLDOWN = 120

local Friend

function Controller.Start()
	local function prompt()
		if Prompted then
			return
		end
		Prompted = true

		local OnlineFriends = LocalPlayer:GetFriendsOnline()
		if #OnlineFriends == 0 then
			Prompted = false
			task.delay(NO_FRIENDS_COOLDOWN, prompt)
			return
		end

		Friend = OnlineFriends[math.random(1, #OnlineFriends)]

		if not Friend then
			warn("no friend found")
			Prompted = false
			Friend = nil --js to be safe lol
			task.delay(NO_FRIENDS_COOLDOWN, prompt)
			return
		end

		for i, v in Players:GetPlayers() do
			if v.UserId == Friend.VisitorId then
				Prompted = false
				Friend = nil --js to be safe lol
				task.delay(NO_FRIENDS_COOLDOWN, prompt)
				break
			end
		end

		local Image =
			Players:GetUserThumbnailAsync(Friend.VisitorId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		PlayerHeadshot.Image = Image
		Description.Text = string.format("%s is online! Invite them to play and win a reward!", Friend.DisplayName)

		FriendPopup.Visible = true
	end

	scope:Hydrate(Close)({
		[OnEvent("Activated")] = function()
			if not Prompted then
				return
			end

			FriendPopup.Visible = false
			Prompted = false
			Friend = nil

			task.delay(POP_UP_COOLDOWN, prompt)
		end,
	})

	scope:Hydrate(Invite)({
		[OnEvent("Activated")] = function()
			if (not Friend) or not Prompted then
				return
			end

			local invOptions = Instance.new("ExperienceInviteOptions")
			invOptions.InviteUser = Friend.VisitorId
			invOptions.PromptMessage = "Invite a friend and beat the tower together! (free reward for invites) "

			local success, errorMessage = pcall(function()
				SocialService:PromptGameInvite(LocalPlayer, invOptions)
			end)

			if not success then
				warn("Failed to prompt join request:", errorMessage)
			end

			FriendPopup.Visible = false
			Prompted = false
			Friend = nil
			task.delay(POP_UP_COOLDOWN, prompt)
		end,
	})

	FriendJoined:On(function(friendName)
		game.StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = friendName .. " (your friend) just joined the game! Here's 1k!",
			Color = Color3.fromRGB(0, 255, 0),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size24,
		})
	end)

	prompt()
end

return Controller
