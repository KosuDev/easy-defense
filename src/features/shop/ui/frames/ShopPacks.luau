local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)

local e = React.createElement

return function()
	return e(ShopContentFrame, {
		Text = "Exclusive Packs",
		LayoutOrder = 0,
	}, {
		-- Lucky Blocks
		-- starter pack
		-- server luck?
	})
end
