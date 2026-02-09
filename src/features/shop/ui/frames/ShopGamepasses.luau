local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

type GamepassFrameProps = {
	product: MonetizationServiceUtils.MonetizationProduct,
	Image: string,
	LayoutOrder: number,
	ImagePosition: UDim2,
	ImageSize: UDim2,
	Text: string,
	TitleGradient: ColorSequence,
	Description: string,
	StrokeColor: Color3,
	Frame: any,
}

local function GamepassFrame(props: GamepassFrameProps)
	return e(props.Frame, {
		Size = UDim2.fromOffset(376, 208),
		LayoutOrder = props.LayoutOrder,
	}, {
		e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3, Color = props.StrokeColor },
			ZIndex = 3,
			Gradient = {
				Rotation = 90,
				Color = props.TitleGradient,
			},
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		}),

		e(TextLabel, {
			Text = props.Description,
			TextSize = 30,
			Size = UDim2.fromScale(0.6, 0.4),
			Position = UDim2.fromScale(0.67, 0.42),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = { Thickness = 2 },
			TextWrapped = true,
			ZIndex = 2,
		}),

		e("ImageLabel", {
			Image = props.Image,
			Size = props.ImageSize,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = props.ImagePosition,
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			ZIndex = 1,
		}),

		e(RobuxButton, {
			product = props.product,
			Position = UDim2.fromScale(0.89, 0.94),
			AnchorPoint = Vector2.new(1, 1),
			ZIndex = 3,
		}),
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Gamepasses",
		LayoutOrder = 10,
	}, {
		e(GamepassFrame, {
			product = Products.goldHunter,
			LayoutOrder = 1,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.currency,
			Frame = ShopFrame.Gold,
			Text = "Gold Hunter",
			Description = "More gold mutations!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 187, 0)),
			}),
			StrokeColor = Color3.fromRGB(46, 31, 0),
		}),
		e(GamepassFrame, {
			product = Products.doubleCrates,
			LayoutOrder = 2,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.shoppingCart,
			Frame = ShopFrame.Blue,
			Text = "Double Crates",
			Description = "Spawn an extra crate!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255)),
			}),
			StrokeColor = Color3.fromRGB(0, 46, 91),
		}),
	})
end
