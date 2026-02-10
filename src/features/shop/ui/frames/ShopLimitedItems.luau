local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)

local e = React.createElement

local function LimitedFrame(props)
	return e(ShopFrame.Blue, {
		Size = UDim2.fromOffset(376, 416),
		LayoutOrder = props.LayoutOrder,
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Limited Towers",
		LayoutOrder = 10,
	}, {

		e(ShopFrame.Blue, {
			Size = UDim2.fromOffset(768, 300),
			LayoutOrder = 3,
		}),
	})
end
