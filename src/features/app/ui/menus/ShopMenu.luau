local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

return function()
	return e(Menu.Component, {
		menuName = "Shop",
		Title = "Shop",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(700, 530),
		Prefix = {
			Image = ImageIds.shoppingCart,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {})
end
