local rebirthRewards = {
	[1] = {
		towerSlots = 1,
		currencyMultiplier = 1.1,
	},
	[2] = {
		towerSlots = 1,
		currencyMultiplier = 1.1,
	},
	[3] = {
		towerSlots = 1,
		currencyMultiplier = 1.1,
	},
	[4] = {
		towerSlots = 1,
		currencyMultiplier = 1.1,
	},
	[5] = {
		towerSlots = 1,
		currencyMultiplier = 1.1,
	},
}

local RebirthUtils = {
	rebirthRewards = rebirthRewards,
}

function RebirthUtils.getRebirthCost(rebirths: number)
	return 1e3 * (2 ^ rebirths)
end

function RebirthUtils.getRebirthTowerRequirement(_rebirths: number)
	return "crossbow" -- Placeholder for future expansion
end

function RebirthUtils.getRequirements(rebirths: number)
	local currency = RebirthUtils.getRebirthCost(rebirths)
	local towerIdReq = RebirthUtils.getRebirthTowerRequirement(rebirths)
	return {
		towerId = towerIdReq,
		currency = currency,
	}
end

return RebirthUtils
