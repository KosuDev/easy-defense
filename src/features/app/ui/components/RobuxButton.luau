-- RobuxButton.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local StudButton = require(script.Parent.StudButton)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local useProduct = require(ReplicatedStorage.Source.Features.Monetization.Hooks.useProduct)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
local ShopSlice = require(ReplicatedStorage.Source.Features.Shop.ShopSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

type MonetizationProduct = MonetizationServiceUtils.MonetizationProduct

export type RobuxButtonProps = {
	product: MonetizationProduct,
	children: { any }?,
	Position: UDim2?,
	HideGift: boolean?,
	AnchorPoint: Vector2?,
	Scale: number?,
	Size: UDim2?,
	ButtonSize: UDim2?,
	ZIndex: number?,
}

return function(props: RobuxButtonProps)
	local product = useProduct(props.product)
	local giftId = if props.HideGift then nil else product.giftId
	local cost = MonetizationServiceClient:getProductCostString(props.product)
	local scale = props.Scale or 1
	local size = props.Size or UDim2.fromOffset(160 * scale, 50 * scale)

	return create("Frame")({
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = size,
		BackgroundTransparency = 1,
		ZIndex = props.ZIndex,

		create("Frame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,

			create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),

			StudButton.Green({
				Size = props.ButtonSize or UDim2.fromScale(1, 1),
				Text = cost,
				LayoutOrder = 2,
				Activated = function()
					MonetizationServiceClient:promptProduct(props.product :: any)
				end,
			}),

			if giftId
				then StudButton.Purple({
					hoverScale = 1.1,
					Size = UDim2.fromScale(0.9, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					LayoutOrder = 1,
					Activated = function()
						ShopSlice.state.giftingProduct(props.product)
						Menu.setOpenedMenu("GiftingMenu")
					end,

					children = {
						create("ImageLabel")({
							Size = UDim2.fromScale(0.67, 0.67),
							ScaleType = Enum.ScaleType.Fit,
							Position = UDim2.fromScale(0.5, 0.475),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = ImageIds.gift,
						}),
					},
				})
				else nil,

			props.children,
		}),
	})
end
