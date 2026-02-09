local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local StudFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.StudFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

local function Content()
	return e(StudFrame, {
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 208),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 192)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 212, 69)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 137, 27)),
		}),
	})
end

return function()
	return e(Menu.Component, {
		menuName = "Shop",
		Title = "Shop",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(800, 600),
		Prefix = {
			Image = ImageIds.shoppingCart,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		ScrollingFrame = e("ScrollingFrame", {
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			ScrollBarImageTransparency = 1,
			Size = UDim2.fromOffset(780, 550),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
				Wraps = true,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			Padding = e("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			}),
		}, e(Content)),
	})
end
