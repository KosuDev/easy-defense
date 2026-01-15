local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
export type PlotSpawn = { part: BasePart, index: number, fakePlot: Model, owner: Player? }

export type PlotData = {
	cf: CFrame,
	index: number,
	player: Player,
	plotModel: Model,
	nodes: { DataTemplate.PlotNode },
}

export type ClientNode = {
	root: BasePart,
	pos: Vector3,
	towerData: DataTemplate.TowerData?,
	crateData: DataTemplate.CrateData?,
	model: Model & any,
}

return nil
