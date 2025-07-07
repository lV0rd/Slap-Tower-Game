local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Tools = Assets.Tools

return {
	--[[
    OnSpawn ONLY WHEN ITS SUPPOSED TO RUN AFTER CHARACTER SPAWN
    OnJoin ONLY WHEN ITS SUPPOSED TO RUN ON JOIN

    You cannot have both OnJoin and OnSpawn set to true for the same gamepass.
    If you want to run something on join and spawn, use OnSpawn ONLY!
    ]]

	["Admin"] = {
		ID = 1283546720,
		OnJoin = true,
		OnSpawn = false,
		Callback = function(Player: Player, PlayerData: any)
			-- Admin gamepass logic here
		end,
	},

	["Rainbow Slap"] = {
		ID = 1285162695,
		OnJoin = false,
		OnSpawn = true,
		Callback = function(Player: Player, PlayerData: any)
			local Tool = Tools:FindFirstChild("Rainbow Slap") :: Tool?
			if not Tool then
				return
			end

            if Player.Backpack:FindFirstChild(Tool.Name) then
                return
            end

			local NewTool = Tool:Clone()
			NewTool.Parent = Player.Backpack
		end,
	},

    ["Magic Carpet"] = {
		ID = 1284700673,
		OnJoin = false,
		OnSpawn = true,
		Callback = function(Player: Player, PlayerData: any)
			local Tool = Tools:FindFirstChild("Magic Carpet") :: Tool?
			if not Tool then
				return
			end

            if Player.Backpack:FindFirstChild(Tool.Name) then
                return
            end

			local NewTool = Tool:Clone()
			NewTool.Parent = Player.Backpack
		end,
	},

    ["Gravity Coil"] = {
		ID = 1284316761,
		OnJoin = false,
		OnSpawn = true,
		Callback = function(Player: Player, PlayerData: any)
			local Tool = Tools:FindFirstChild("Gravity Coil") :: Tool?
			if not Tool then
				return
			end

            if Player.Backpack:FindFirstChild(Tool.Name) then
                return
            end

			local NewTool = Tool:Clone()
			NewTool.Parent = Player.Backpack
		end,
	},

	["Laser Gun"] = {
		ID = 1299452491,
		OnJoin = false,
		OnSpawn = true,
		Callback = function(Player: Player, PlayerData: any)
			local Tool = Tools:FindFirstChild("Laser Gun") :: Tool?
			if not Tool then
				return
			end

			if Player.Backpack:FindFirstChild(Tool.Name) then
				return
			end

			local NewTool = Tool:Clone()
			NewTool.Parent = Player.Backpack
		end,
	},

	["Grapple Hook"] = {
		ID = 1299166934,
		OnJoin = false,
		OnSpawn = true,
		Callback = function(Player: Player, PlayerData: any)
			local Tool = Tools:FindFirstChild("Grapple Hook") :: Tool?
			if not Tool then
				return
			end

			if Player.Backpack:FindFirstChild(Tool.Name) then
				return
			end

			local NewTool = Tool:Clone()
			NewTool.Parent = Player.Backpack
		end,
	},
}
