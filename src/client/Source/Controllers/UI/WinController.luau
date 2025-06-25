local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Controller = {
	Name = script.Name,

	States = {},
}

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Events = Shared.Events

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Frames = RootGui.Frames :: Folder
local WinFrame = Frames.Win :: CanvasGroup

local WinStar = WinFrame.Star :: ImageLabel
local WinMessage = WinFrame.Message :: TextLabel

local WinEvent = require(Events.Win):Client()

local Debounce = false

function Controller.Start()
    WinEvent:On(function()
        if Debounce then
            return
        end

        Debounce = true

        local WinFrameTween1 = TweenService:Create(
            WinFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {GroupTransparency = 0}
        )

        local WinFrameTween2 = TweenService:Create(
            WinFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {GroupTransparency = 1}
        )

        local StarTween = TweenService:Create(
            WinStar,
            TweenInfo.new(10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            {Rotation = 360 * 10, Size = UDim2.fromScale(.6, .6)}
        )

        local WinMessageTween = TweenService:Create(
            WinMessage,
            TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {TextTransparency = 0}
        )

        WinFrameTween1:Play()
        WinFrameTween1.Completed:Wait()

        StarTween:Play()
        StarTween.Completed:Wait()
        
        WinStar.ImageTransparency = 1

        WinMessageTween:Play()
        task.wait(2)

        WinFrameTween2:Play()
        WinFrameTween2.Completed:Wait()

        WinStar.Rotation = 0
        WinStar.Size = UDim2.fromScale(0.3, 0.3)
        WinStar.ImageTransparency = 0
        WinMessage.TextTransparency = 1

        Debounce = false
    end)
end

return Controller