local NULL = "NULL"

export type CrateData = {
	crateId: string,
	amt: number,
}

export type TowerData = {
	itemId: string,
	level: number,
}

export type ItemData = CrateData & TowerData

export type CrateNode = {
	crateId: string,
	timeBuilt: number,
}

export type NodeData = CrateNode & TowerData
export type PlotNode = CrateNode & string
export type PlotNodes = { [string]: PlotNode }

return {
	currency = 100,
	plotNodes = {},
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
