local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
export type PlotSpawn = { part: BasePart, index: number, fakePlot: Model, owner: Player? }

export type Node = {
	root: BasePart,
	cf: CFrame,
	data: DataTemplate.NodeData?,
}

export type PlotData = {
	cf: CFrame,
	index: number,
	player: Player,
	plotModel: Model,
	nodes: { { Node } },
	paths: any,
	conveyorModel: (Model & any)?,
	conveyorLevel: number,
	currencyMult: number,
	damageMult: number,
}

export type ClientNode = Node & {
	model: Model & any,
}

return nil
