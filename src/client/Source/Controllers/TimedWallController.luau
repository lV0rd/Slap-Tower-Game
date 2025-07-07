local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Controller = {
	Name = script.Name,
}

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Map = workspace:WaitForChild("Map")
local Lobby = Map:WaitForChild("Lobby")
local GroupWall = Lobby:WaitForChild("Timed", 5)

local Format = require(Shared.Utils.Format)

local TIME_TO_WAIT = 60 * 15

function Controller.Start()
	local JoinTime = LocalPlayer:GetAttribute("JoinTime") :: number
	if not JoinTime then
		JoinTime = workspace:GetServerTimeNow()
	end

	Lobby.ChildAdded:Connect(function(child)
		if child.Name == "Timed" then
			GroupWall = child

			local TimeLeft = JoinTime + TIME_TO_WAIT - workspace:GetServerTimeNow()
			if TimeLeft <= 0 then
				if GroupWall then
					GroupWall:Destroy()
				end

				return
			end
		end
	end)

	local connection

	connection = RunService.PreSimulation:Connect(function()
		local TimeLeft = JoinTime + TIME_TO_WAIT - workspace:GetServerTimeNow()
		if GroupWall then
			GroupWall.SurfaceGui.Timer.Text = "UNLOCK IN: "..Format.time(TimeLeft)
			GroupWall.SurfaceGui.Bar.Progress.Size = UDim2.fromScale((TIME_TO_WAIT - TimeLeft)/TIME_TO_WAIT, 1)
		end

		if TimeLeft <= 0 then
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if GroupWall then
				GroupWall:Destroy()
			end
		end
	end)
end

return Controller
