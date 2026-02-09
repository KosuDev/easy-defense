local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ShopGamepasses = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopGamepasses)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		e(ShopGamepasses),
	})
end
