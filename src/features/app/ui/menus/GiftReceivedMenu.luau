-- GiftReceivedMenu.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Menu = require(script.Parent.Menu)
local DisplayNameWithIcons = require(ReplicatedStorage.Source.Core.UI.DisplayNameWithIcons)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local ShopSlice = require(ReplicatedStorage.Source.Features.Shop.ShopSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

return function()
	local receivedData = VideCharm.useSignalState(ShopSlice.state.giftReceivedData)

	return Menu.Component({
		menuName = "GiftReceivedMenu",
		Title = "Gift Received",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(450, 300),
		Prefix = {
			Image = ImageIds.shoppingCart,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},

		children = {
			function()
				local data = receivedData()
				if not data then
					return nil
				end

				local playerName = "UNKNOWN"
				local sender = Players:GetPlayerByUserId(data.giftData.fromUserId)
				if sender then
					playerName = DisplayNameWithIcons(sender)
				end

				local productInfo = MonetizationServiceClient:getProductInfo(data.product)

				return {
					TextLabel({
						Text = `{playerName} has gifted you:\n<font size="60">{productInfo.Name}</font>`,
						TextSize = 30,
						TextScaled = false,
						Size = UDim2.fromScale(0.8, 0.4),
						Position = UDim2.fromScale(0.5, 0.24),
						AnchorPoint = Vector2.new(0.5, 0),
						RichText = true,
						Stroke = { Thickness = 2 },
					}),

					StudButton.Green({
						Text = "Claim",
						Size = UDim2.fromOffset(120, 50),
						Position = UDim2.fromScale(0.5, 0.75),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Activated = function()
							Menu.setOpenedMenu(nil)
							ShopSlice.state.giftReceivedData(nil)
						end,
					}),
				}
			end,
		},
	})
end
