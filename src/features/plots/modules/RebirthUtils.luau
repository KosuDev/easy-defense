local rebirthRewards = {
	[1] = {
		towerSlots = 2,
	},
	[2] = {
		towerSlots = 2,
		floors = 1,
	},
	[3] = {
		towerSlots = 2,
	},
	[4] = {
		towerSlots = 2,
	},
	[5] = {
		towerSlots = 2,
	},
}

local rebirthRequirements = {
	[1] = {
		towerId = "turret",
		currency = 25e3,
	},
	[2] = {
		towerId = "orbOfLight",
		currency = 500e3,
	},
	[3] = {
		towerId = "crossbow",
		currency = 4e3,
	},
	[4] = {
		towerId = "crossbow",
		currency = 8e3,
	},
	[5] = {
		towerId = "crossbow",
		currency = 16e3,
	},
}

local RebirthUtils = {
	rebirthRewards = rebirthRewards,
}

function RebirthUtils.getRebirthCost(rebirths: number)
	return rebirthRequirements[rebirths + 1].currency
end

function RebirthUtils.getRebirthTowerRequirement(rebirths: number)
	return rebirthRequirements[rebirths + 1].towerId
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
