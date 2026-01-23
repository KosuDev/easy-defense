local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

return function()
	return e(Menu.Component, {
		menuName = "RebirthMenu",
		Title = "Rebirth",
		Prefix = {
			Image = ImageIds.rebirth,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		Requirements = e(TextLabel, {
			Text = "- YOU NEED -",
			Size = UDim2.fromScale(1, 0.11),
			Position = UDim2.fromScale(0.5, 0.01),
			AnchorPoint = Vector2.new(0.5, 0),
			Stroke = { Thickness = 3 },
		}),

		reqs = e(InsetFrame, {
			Size = UDim2.fromScale(0.9, 0.3),
			Position = UDim2.fromScale(0.5, 0.15),
			AnchorPoint = Vector2.new(0.5, 0),
		}),
	})
end
