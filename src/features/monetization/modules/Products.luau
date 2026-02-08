local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
type MonetizationProduct = MonetizationServiceUtils.MonetizationProduct

local products = {
	superLucky = {
		id = 1,
		giftId = 1,
		isPass = true,
	},

	ultraLucky = {
		id = 1,
		giftId = 1,
		isPass = true,
	},
}

return products :: { [keyof<typeof(products)>]: MonetizationProduct }
