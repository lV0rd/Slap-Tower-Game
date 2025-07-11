local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {}

local Assets = ReplicatedStorage.Assets :: Folder
local Animations = Assets.Animations :: Folder

ContentProvider:PreloadAsync(Animations:GetChildren())

return Controller