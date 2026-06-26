-- HudRoot.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local BottomBar = require(script.Parent.BottomBar)
local LeftSideBar = require(script.Parent.LeftSideBar)
local TopBar = require(script.Parent.TopBar)

local create = Vide.create

return function()
	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		BottomBar(),
		LeftSideBar(),
		TopBar(),
	})
end
