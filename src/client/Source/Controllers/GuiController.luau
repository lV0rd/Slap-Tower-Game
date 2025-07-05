local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Controller = {
	Name = script.Name,

	States = {
		CurrentOpenMenu = nil,
	},
}

local Sounds = SoundService.UI

local Camera = workspace.CurrentCamera
local Blur = Lighting:FindFirstChild("Blur") or Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local Utils = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utils")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Spr = require(Utils.spr)
local Signal = require(Packages.Signal)

Controller.OpenSignal = Signal.new()
Controller.CloseSignal = Signal.new()

function open(Frame: Frame)
	Spr.stop(Frame)
	Frame.Position = UDim2.fromScale(0.5, 0.55)
	Frame.Visible = true

	Spr.target(Frame, 1, 4, {
		Position = UDim2.fromScale(0.5, 0.5),
	})

	if not Frame:GetAttribute("NoBlur") then
		Spr.target(Camera, 0.7, 4, {
			FieldOfView = 63,
		})
		Spr.target(Blur, 0.7, 4, {
			Size = 24,
		})
	end
	
	Controller.OpenSignal:Fire(Frame)
end

function close(Frame: Frame)
	Frame.Visible = false

	if not Frame:GetAttribute("NoBlur") then
		Spr.target(Camera, 0.7, 4, {
			FieldOfView = 70,
		})
		Spr.target(Blur, 0.7, 4, {
			Size = 0,
		})
	end

	Controller.CloseSignal:Fire(Frame)
end

function Controller:Toggle(Frame)
	if Controller.States.CurrentOpenMenu == nil then
		Controller.States.CurrentOpenMenu = Frame
		open(Frame)
	else
		if Controller.States.CurrentOpenMenu == Frame then
			close(Controller.States.CurrentOpenMenu)
			Controller.States.CurrentOpenMenu = nil
			return
		end
		close(Controller.States.CurrentOpenMenu)
		Controller.States.CurrentOpenMenu = Frame
		open(Frame)
	end
end

function Controller:Close(Frame)
	if Controller.States.CurrentOpenMenu == Frame then
		close(Controller.States.CurrentOpenMenu)
		Controller.States.CurrentOpenMenu = nil
		return
	end
end

function Controller.Start()
	if Controller.States.CurrentOpenMenu then
		close(Controller.States.CurrentOpenMenu)
	end
end

return Controller
