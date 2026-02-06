local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local PlotServer = require(ServerScriptService.Features.Plots.Classes.PlotServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)

type Plot = PlotServer.PlotServer
type PlotSpawn = PlotTypes.PlotSpawn

local PlotServiceServer = {}

local PLAYER_DATA_TEMPLATE = {
	plot = nil,
}

type PlayerData = {
	plot: Plot,
}

function PlotServiceServer.init(self: PlotServiceServer)
	self.networker = Networker.server.new("PlotService", self, { self.rebirth, self.tpToBase, self.tpToSell })
	self.playerData = ServicePlayerData.new(PLAYER_DATA_TEMPLATE :: PlayerData, self)
	self.plotSpawns = {}

	for _, plotSpawn: BasePart in CollectionService:GetTagged("PlotSpawn") do
		plotSpawn.Transparency = 1
		local index = plotSpawn:GetAttribute("Index") :: number
		local fakePlot: Model & any = ReplicatedStorage.Assets.Misc.Plot:Clone()
		local fakeDefense: Model = ReplicatedStorage.Assets.PlotDefenses["1"]:Clone()
		fakeDefense:PivotTo(fakePlot.DefenseSpawn.CFrame)
		fakeDefense.Parent = fakePlot
		fakePlot:PivotTo(plotSpawn.CFrame)
		fakePlot.Parent = workspace
		self.plotSpawns[index] = { part = plotSpawn, index = index, fakePlot = fakePlot, owner = nil }
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

			plotSpawn.fakePlot.Parent = ServerStorage
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

	DataService:waitForData(player)
	local plot = PlotServer.new(plotSpawn, player)
	playerData.plot = plot
	self.networker:fireAll("initPlot", plot:get())
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
		plotSpawn.fakePlot.Parent = workspace
	end

	self.networker:fireAll("removePlot", index)
end

function PlotServiceServer.rebirth(_self: PlotServiceServer, player: Player): (boolean | any, string?)
	local rebirths: number = DataService:get(player, "rebirths")
	if RebirthUtils.isMaxedRebirths(rebirths) then
		return false, "Max rebirths reached"
	end

	local reqs = RebirthUtils.getRequirements(rebirths)
	if DataService:get(player, "currency") < reqs.currency then
		return false, "Not enough money"
	end

	local hasUnlockedTower = DataService:get(player, { "towerIndex", "normal", reqs.towerId }) ~= nil
	if not hasUnlockedTower then
		return false, "Required tower not unlocked"
	end

	DataService:set(player, "currency", 0)
	DataService:update(player, "rebirths", function(oldRebirths: number)
		return oldRebirths + 1
	end)

	return RebirthUtils.rebirthRewards[rebirths + 1]
end

function PlotServiceServer.tpToBase(self: PlotServiceServer, player: Player)
	local playerData = self.playerData:get(player)
	if not playerData then
		return
	end

	local plot = playerData.plot
	if not plot then
		return
	end

	plot:tpChar()
end

function PlotServiceServer.tpToSell(_self: PlotServiceServer, player: Player)
	local sellTpPart = CollectionService:GetTagged("SellTp")[1] :: BasePart
	local char = player.Character
	if char then
		char:PivotTo(sellTpPart.CFrame)
	end
end

type PlotServiceServer = typeof(PlotServiceServer) & {
	plotSpawns: { PlotSpawn },
	networker: Networker.Server,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
}

return PlotServiceServer :: PlotServiceServer
