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
		Debounce = {} :: {[Player] : boolean},

        DebounceTime = instance:GetAttribute("DebounceTime") or 0.2,
        Damage = instance:GetAttribute("Damage") or 10,
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

        if self.Debounce[Player] then
            return
        end

        self.Debounce[Player] = true
        task.delay(self.DebounceTime, function()
            self.Debounce[Player] = false
        end)

        Humanoid:TakeDamage(self.Damage)
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