local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Controller = {
	Name = script.Name,
}

local MusicFolder = SoundService.Music

local Previous
local Toggled = true

function Controller:Toggle()
	Toggled = not Toggled

	for i, v in MusicFolder:GetChildren() do
		if v:IsA("Sound") then
			v.Volume = Toggled and 0 or 0.5
		end
	end
end

function Controller.Start()
	local function playNextSong()
		if Previous then
			Previous:Stop()
		end

		local Songs = MusicFolder:GetChildren()
		if #Songs == 0 then
			return
		end

		local Song = Songs[math.random(1, #Songs)]
		if Song == Previous then
			playNextSong()
			return 
		end

		Song:Play()
		Previous = Song

		Song.Ended:Once(function()
			playNextSong()
		end)
	end

	playNextSong()
end

return Controller
