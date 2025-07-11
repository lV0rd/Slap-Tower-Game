local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui
local Frames = Canvas.Frames

local GiftsFrame = Frames.Gifts.Main
local CloseButton = GiftsFrame.Top.Close

local GiftsButton = RootGui.Sides.Left.Buttons.Gifts

local GiftsData = require(Shared.Data.Rewards).Gifts

local Assets = ReplicatedStorage.Assets
local UIAssets = Assets.UI
local GiftTemplate = UIAssets.GiftTemplate

local Start = LocalPlayer:GetAttribute("JoinTime") or workspace:GetServerTimeNow() :: number

local GiftNotification = GiftsButton.Notification
local GiftTimer = GiftsButton.Amount

local Elements = GiftsFrame.Elements

local Fusion = require(Packages.Fusion)
local Format = require(Shared.Utils.Format)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local GiftsFunction = require(Shared.Functions.Gifts)

local Claimed = {}
local Claimable = {}

local Connection

function ClaimReward(Name, Button)
	local Index = tonumber(Name)

	if not Claimable[Index] then
		return
	end

	if Claimed[Index] then
		return
	end

	local Rewarded, Message = GiftsFunction:Call(Index)

	if not Rewarded then
		print("Error: " .. Message)
		return
	end

	Claimable[Index] = nil
	Claimed[Index] = true

	Button.Claimed.Visible = true
end

function InitRewards()
	for i, v in GiftsData do
		local newFrame = GiftTemplate:Clone()
		newFrame.Name = i
		local Image = newFrame.ImageLabel
		local Timer = newFrame.Timer
		local Title = newFrame.Title

		Title.Text = v.Title
		Image.Image = v.Image
		Timer.Text = Format.time(v.Time)
		newFrame.Parent = Elements
	end
end

function StartRewards()
	for i, v in Elements:GetChildren() do
		if not v:IsA("GuiButton") then
			continue
		end

		local Button = v

		scope:Hydrate(Button)({
			[OnEvent("Activated")] = function()
				ClaimReward(v.Name, Button)
			end,
		})
	end
end

function UpdateUi()
	local Latest = nil
	for i, v in Elements:GetChildren() do
		if not v:IsA("GuiButton") then
			continue
		end

		local Index = tonumber(v.Name)

		local Button = v
		local Timer = Button.Timer

		local Info = GiftsData[Index]

		if Claimed[Index] then
			Timer.Text = "Claimed!"
			continue
		end

		if Claimable[Index] then
			Timer.Text = "Claim!"
			continue
		end

		local now = workspace:GetServerTimeNow()
		local StartTime = LocalPlayer:GetAttribute("StartTime") or Start
		local TimeLeft = math.clamp(Info.Time - (now - StartTime), 0, Info.Time)

		if TimeLeft <= 0 then
			Claimable[Index] = true
		end

		if not Latest then
			if Timer.Text ~= "Claim!" and Timer.Text ~= "Claimed!" and Timer.Text ~= "XX:XX" then
				Latest = TimeLeft
			end
		end

		Timer.Text = Format.time(TimeLeft)
	end

	NotifyUi(Latest)
end

function NotifyUi(Latest)
	--wip
	local ClaimableSize = 0
	for i, v in Claimable do
		ClaimableSize += 1
	end

	local ClaimedSize = 0
	for i, v in Claimed do
		ClaimedSize += 1
	end

	local RewardsSize = 0
	for i, v in GiftsData do
		RewardsSize += 1
	end

	GiftNotification.Visible = (ClaimableSize > 0)

	if ClaimedSize == RewardsSize then
		GiftTimer.Text = "Claimed!"
		GiftsButton.Icon.Image = "rbxassetid://132624202106451"
		Connection:Disconnect()
		Connection = nil
	else
		GiftTimer.Text = GiftNotification.Visible and "Claim" or (Latest and Latest > 0) and Format.time(Latest) or "Claim!"
	end
end

function Controller.Start()
	local GuiController = require(Controllers.GuiController)
    --local DataController = require(Controllers.DataController)

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Close(GiftsFrame.Parent)
		end,
	})

	--Main
	InitRewards()
	StartRewards()
	Connection = RunService.PostSimulation:Connect(UpdateUi)
end

return Controller