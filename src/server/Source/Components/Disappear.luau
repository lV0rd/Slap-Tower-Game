local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Janitor = require(Packages.Janitor)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

function module.new(instance: BasePart)
	local self = setmetatable({
		Instance = instance :: BasePart,
		Janitor = Janitor.new(),
		Debounce = false :: boolean,

        WaitTime = instance:GetAttribute("WaitTime") or 3,
        Speed = instance:GetAttribute("Speed") or 0.1,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)
	
    self.Janitor:Add(self.Instance.Touched:Connect(function(hit: BasePart)
        local Character = hit.Parent
        local Humanoid = Character:FindFirstChild("Humanoid")

        if not Humanoid then
            return
        end

        local Player = Players:GetPlayerFromCharacter(Character)
        if not Player then
            return
        end

        if self.Debounce then
            return
        end

        self.Debounce = true

        for i = 1, 10 do
            task.wait(self.Speed)
            self.Instance.Transparency = i / 10
        end

        self.Instance.CanCollide = false

        task.wait(self.WaitTime)

        self.Instance.Transparency = 0
        self.Instance.CanCollide = true

        self.Debounce = false
    end))
end

function module:_cleanup()
	if table.find(Components, self) then
		table.remove(Components, table.find(Components, self))
	end

	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module