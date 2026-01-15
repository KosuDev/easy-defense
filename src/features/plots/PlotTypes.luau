local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
export type PlotSpawn = { part: BasePart, index: number, fakePlot: Model, owner: Player? }

export type Node = {
	root: BasePart,
	pos: Vector3,
	data: DataTemplate.NodeData?,
}

export type PlotData = {
	cf: CFrame,
	index: number,
	player: Player,
	plotModel: Model,
	nodes: { Node },
}

export type ClientNode = Node & {
	model: Model & any,
}

return nil
