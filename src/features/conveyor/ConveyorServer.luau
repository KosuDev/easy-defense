local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local ConveyorServer = {}
ConveyorServer.__index = ConveyorServer

type PlotSpawn = PlotTypes.PlotSpawn

export type ConveyorServer = typeof(setmetatable(
	{} :: {
		index: number,
		player: Player,
	},
	ConveyorServer
))

function ConveyorServer.new(plotSpawn: PlotSpawn, player: Player): ConveyorServer
	local self = setmetatable({
		index = plotSpawn.index,
		player = player,
	}, ConveyorServer)

	return self
end

return ConveyorServer
