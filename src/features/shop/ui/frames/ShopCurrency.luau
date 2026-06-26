-- ShopCurrency.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local FormatCurrency = require(ReplicatedStorage.Source.Core.UI.FormatCurrency)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local ShopUtils = require(ReplicatedStorage.Source.Features.Shop.ShopUtils)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

local CURRENCY_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
})

type MoneyFrameProps = {
	tier: number,
	product: any,
	Text: string,
	LayoutOrder: number,
	Size: UDim2?,
	ImageLeft: boolean?,
	ImageRight: boolean?,
}

local function MoneyFrame(props: MoneyFrameProps)
	local rebirths = useDataState("rebirths")

	return ShopFrame.Green({
		Size = props.Size or UDim2.fromOffset(376, 190),
		LayoutOrder = props.LayoutOrder,

		children = {
			if props.ImageLeft
				then create("ImageLabel")({
					Image = ImageIds.currency,
					Size = UDim2.fromScale(0.7, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.fromScale(0.05, 0.6),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
				})
				else nil,

			if props.ImageRight
				then create("ImageLabel")({
					Image = ImageIds.currency,
					Size = UDim2.fromScale(0.7, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.fromScale(0.95, 0.6),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
				})
				else nil,

			TextLabel({
				Text = props.Text,
				Size = UDim2.fromScale(1, 0.2),
				Position = UDim2.fromScale(0, 0),
				Stroke = { Thickness = 3 },
				ZIndex = 3,
				BackgroundTransparency = 0.7,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
			}),

			TextLabel({
				Size = UDim2.fromScale(1, 0.35),
				Text = function()
					local amt = ShopUtils.getCurrencyAmtFromRebirth(props.tier, rebirths())
					return "+" .. FormatCurrency(amt)
				end,
				Position = UDim2.fromScale(0.5, 0.4),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 4, Color = Color3.fromRGB(24, 55, 7) },
				Gradient = {
					Rotation = 90,
					Color = CURRENCY_GRADIENT,
				},
			}),

			RobuxButton({
				product = props.product,
				Position = UDim2.fromScale(0.5, 0.94),
				AnchorPoint = Vector2.new(0.5, 1),
				ZIndex = 3,
				Scale = if props.Size then 1.2 else nil,
			}),
		},
	})
end

return function()
	return ShopContentFrame({
		Text = "Money",
		LayoutOrder = 30,

		children = {
			MoneyFrame({
				LayoutOrder = 1,
				tier = 1,
				product = Products.currency1,
				Text = "Small",
			}),

			MoneyFrame({
				LayoutOrder = 2,
				tier = 2,
				product = Products.currency2,
				Text = "Medium",
			}),

			MoneyFrame({
				LayoutOrder = 3,
				tier = 3,
				product = Products.currency3,
				Text = "TONS of Money!!",
				Size = UDim2.fromOffset(768, 190),
				ImageLeft = true,
				ImageRight = true,
			}),
		},
	})
end
