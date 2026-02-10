local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
type MonetizationProduct = MonetizationServiceUtils.MonetizationProduct

local products = {
	doubleUnlockSpeed = {
		id = 1704367518,
		giftId = 3532524902,
		isPass = true,
	} :: MonetizationProduct,

	starterPack = {
		id = 1704401477,
		giftId = 3532526931,
		isPass = true,
	} :: MonetizationProduct,

	doubleMoney = {
		id = 1704403366,
		giftId = 3532526815,
		isPass = true,
	} :: MonetizationProduct,

	doubleDamage = {
		id = 1704025700,
		giftId = 3532526673,
		isPass = true,
	} :: MonetizationProduct,

	diamondHunter = {
		id = 1703826017,
		giftId = 3532526534,
		isPass = true,
	} :: MonetizationProduct,

	goldHunter = {
		id = 1704067647,
		giftId = 3532526375,
		isPass = true,
	} :: MonetizationProduct,

	fastConveyor = {
		id = 1704474361,
		giftId = 3532526228,
		isPass = true,
	} :: MonetizationProduct,

	doubleCrates = {
		id = 1704291427,
		giftId = 3532525858,
		isPass = true,
	} :: MonetizationProduct,

	tripleCrates = {
		id = 1704095646,
		giftId = 3532526057,
		isPass = true,
	} :: MonetizationProduct,

	ultraLuck = {
		id = 1704275544,
		giftId = 3532524696,
		isPass = true,
	} :: MonetizationProduct,

	superLuck = {
		id = 1704321547,
		giftId = 3532524696,
		isPass = true,
	} :: MonetizationProduct,

	currency1 = {
		id = 1704321547,
		isPass = true,
	} :: MonetizationProduct,
}

return products -- :: { [keyof<typeof(products)>]: MonetizationProduct }
