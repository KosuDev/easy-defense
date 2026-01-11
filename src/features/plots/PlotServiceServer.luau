local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlotServer = require(ServerScriptService.Features.Plots.Classes.PlotServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)

type Plot = PlotServer.Plot
type PlotSpawn = PlotTypes.PlotSpawn

local PlotServiceServer = {}

local PLAYER_DATA_TEMPLATE = {
	plot = nil,
}

type PlayerData = {
	plot: Plot,
}

function PlotServiceServer.init(self: PlotServiceServer)
	self.networker = Networker.server.new("PlotService", self, {})
	self.playerData = ServicePlayerData.new(PLAYER_DATA_TEMPLATE :: PlayerData, self)
	self.plotSpawns = {}

	for _, plotSpawn: BasePart in CollectionService:GetTagged("PlotSpawn") do
		local index = plotSpawn:GetAttribute("Index") :: number
		self.plotSpawns[index] = { part = plotSpawn, index = index, owner = nil }
	end
end

function PlotServiceServer.claimPlot(self: PlotServiceServer, player: Player): PlotSpawn?
	while player.Parent do
		for _, plotSpawn in self.plotSpawns do
			if plotSpawn.owner then
				if plotSpawn.owner == player then
					return
				end
				continue
			end

			plotSpawn.owner = player
			return plotSpawn
		end
		task.wait(1)
	end

	return
end

function PlotServiceServer.playerAdded(self: PlotServiceServer, player: Player, playerData: PlayerData)
	local plotSpawn = self:claimPlot(player)
	if not plotSpawn then
		return
	end

	local plot = PlotServer.new(plotSpawn, player)
	playerData.plot = plot
end

function PlotServiceServer.playerRemoving(self: PlotServiceServer, player: Player, playerData: PlayerData)
	local plot = playerData.plot
	if not plot then
		return
	end

	local index = plot.index
	plot:destroy()
	local plotSpawn = self.plotSpawns[index]
	if plotSpawn.owner == player then
		plotSpawn.owner = nil
	end
end

type PlotServiceServer = typeof(PlotServiceServer) & {
	plotSpawns: { PlotSpawn },
	networker: Networker.Server,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
}

return PlotServiceServer :: PlotServiceServer
