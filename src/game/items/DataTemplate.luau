local NULL = "NULL"

export type CrateData = {
	crateId: string,
	amt: number?,
	fav: boolean?,
	mutations: Mutations?,
}

export type Mutations = {
	gold: boolean?,
	diamond: boolean?,
}

export type TowerData = {
	itemId: string,
	level: number,
	fav: boolean?,
	mutations: Mutations?,
}

export type ItemData = CrateData & TowerData

export type CrateNode = {
	crateId: string,
	timeBuilt: number,
	mutations: Mutations?,
}

export type NodeData = CrateNode & TowerData
export type PlotNode = CrateNode & string
export type PlotNodes = { [string]: PlotNode }

export type OccupiedNode = CrateNode & string
export type OccupiedNodes = { [string]: OccupiedNode }

return {
	currency = 500,
	rebirths = 0,
	conveyorLevel = 1,
	towerIndex = {
		normal = {},
		gold = {},
		diamond = {},
	},
	plotNodes = {},
	inventory = {},
	hotbar = {
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
	},
}
