-- ShopMenu.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local Menu = require(script.Parent.Menu)
local ShopContent = require(ReplicatedStorage.Source.Features.Shop.UI.ShopContent)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

return function()
	return Menu.Component({
		menuName = "Shop",
		Title = "Shop",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(800, 600),
		Prefix = {
			Image = ImageIds.shoppingCart,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},

		children = {
			create("ScrollingFrame")({
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				Size = UDim2.fromOffset(780, 550),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,

				create("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 10),
					Wraps = true,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Horizontal,
				}),

				create("UIPadding")({
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				}),

				ShopContent(),
			}),
		},
	})
end
