local NULL = "NULL"

export type ItemData = {
	crateId: string?,
	itemId: string?,
	amt: number?,
}

return {
	currency = 100,
	inventory = {
		wooden = {
			crateId = "wooden",
			amt = 1,
		},
		silver = {
			crateId = "silver",
			amt = 1,
		},
		gold = {
			crateId = "gold",
			amt = 1,
		},
		diamond = {
			crateId = "diamond",
			amt = 1,
		},
	},
	hotbar = {
		"wooden",
		NULL,
		NULL,
		NULL,
		"silver",
		NULL,
		NULL,
		NULL,
		NULL,
	},
}
