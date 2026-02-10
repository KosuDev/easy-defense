local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
local ShopUtils = {}

local MINUTE = 60
local HOUR = 60 * MINUTE
local instaOpenProducts = {
	MINUTE,
	5 * MINUTE,
	15 * MINUTE,
	30 * MINUTE,
	45 * MINUTE,
	60 * MINUTE,
	90 * MINUTE,
	2 * HOUR,
	3 * HOUR,
	5 * HOUR,
}

function ShopUtils.getInstaOpenTimeFromN(n: number): number
	return instaOpenProducts[n]
end

function ShopUtils.getProductFromTimeRemaining(
	timeRemaining: number
): (MonetizationServiceUtils.MonetizationProduct?, number?)
	if timeRemaining <= 5 then
		return
	end

	for i, t in instaOpenProducts do
		if timeRemaining <= t then
			return Products["insta" .. i], i
		end
	end

	return Products.insta10, 10
end

return ShopUtils
