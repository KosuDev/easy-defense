-- ShopContent.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local ShopCodes = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopCodes)
local ShopCurrency = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopCurrency)
local ShopGamepasses = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopGamepasses)
local ShopLimitedItems = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopLimitedItems)
local ShopPacks = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopPacks)

local create = Vide.create

return function()
	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		ShopGamepasses(),
		ShopPacks(),
		ShopLimitedItems(),
		ShopCurrency(),
		ShopCodes(),
	})
end
