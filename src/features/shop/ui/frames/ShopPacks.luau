local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)

local e = React.createElement

local function LuckyBlockFrame(props)
	local info = Towers.getTowerInfo(props.id)
	local luck: number = info.luck

	return e(props.Frame, {
		Size = UDim2.fromOffset(368 * 2 / 3, 380),
		LayoutOrder = props.LayoutOrder,
	}, {
		Title = e(TextLabel, {
			Text = "Lucky Block",
			Size = UDim2.fromScale(1, 0.125),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}),

		Sub = e(TextLabel, {
			Text = props.SubText,
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0, 0.125),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
			Gradient = {
				Color = props.SubTextGradient,
				Rotation = -90,
			},
		}),

		Icon = e("ImageLabel", {
			Image = info.crateImage,
			Size = UDim2.fromScale(0.9, 0.9),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}),

		Description = e(TextLabel, {
			Text = `X{luck} LUCK!`,
			TextSize = 30,
			Size = UDim2.fromScale(0.9, 0.2),
			Position = UDim2.fromScale(0.5, 0.89),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 3 },
			TextWrapped = true,
			ZIndex = 2,
		}),

		RbxButton = e(RobuxButton, {
			Scale = 0.95,
			Position = UDim2.fromScale(0.5, 0.975),
			AnchorPoint = Vector2.new(0.5, 1),
			product = props.product,
			ButtonSize = UDim2.fromScale(0.8, 1),
		}, {
			e(StudButton.Green, {
				hoverScale = 1.1,
				Size = UDim2.fromScale(0.9, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 3,
				Activated = function()
					MonetizationServiceClient:promptProduct(props.threeProduct)
				end,
			}, {
				e(TextLabel, {
					Text = "X3",
					Stroke = {},
					Size = UDim2.fromScale(0.9, 0.6),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
				}),
			}),
		}),
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Exclusive Packs",
		LayoutOrder = 0,
	}, {
		e(LuckyBlockFrame, {
			Frame = ShopFrame.Gold,
			id = "luckyBlock1",
			product = Products.luckyBlock1,
			threeProduct = Products.threeLuckyBlock1,
			SubText = "EXOTIC",
			SubTextGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
			}),
		}),
		e(LuckyBlockFrame, {
			Frame = ShopFrame.Red,
			id = "luckyBlock2",
			product = Products.luckyBlock2,
			threeProduct = Products.threeLuckyBlock2,
			SubText = "SECRET",
			SubTextGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 85)),
			}),
		}),
		e(LuckyBlockFrame, {
			Frame = ShopFrame.Purple,
			id = "luckyBlock3",
			product = Products.luckyBlock3,
			threeProduct = Products.threeLuckyBlock3,
			SubText = "DIVINE",
			SubTextGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 255)),
			}),
		}),
	})
end
