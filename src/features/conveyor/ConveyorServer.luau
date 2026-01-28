--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)

local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local MAX_CRATES = 3

local ConveyorServer = {}
ConveyorServer.__index = ConveyorServer

type PlotSpawn = PlotTypes.PlotSpawn

export type ConveyorServer = typeof(setmetatable(
	{} :: {
		index: number,
		player: Player,
		timeOfLastCrateSpawn: number,
		crates: { string? },
		networker: Networker.Server,
	},
	ConveyorServer
))

function ConveyorServer.new(plotSpawn: PlotSpawn, player: Player, networker: Networker.Server): ConveyorServer
	local self = setmetatable({
		index = plotSpawn.index,
		player = player,
		timeOfLastCrateSpawn = 0,
		crates = {},
		networker = networker,
	}, ConveyorServer)

	self.networker:addClientAccess(self, { self.spawnCrate })

	return self
end

function ConveyorServer.spawnCrate(self: ConveyorServer, player: Player): boolean
	if self.player ~= player then
		return false
	end

	if os.clock() - self.timeOfLastCrateSpawn < CRATE_SPAWN_CD then
		return false
	end

	local crateRolls = 3
	for i = 1, MAX_CRATES do
		if i <= crateRolls then
			self.crates[i] = Crates.rollCrateId(1)
		else
			self.crates[i] = nil
		end
	end

	self.timeOfLastCrateSpawn = os.clock()
	self.networker:fireAll("cratesChanged", self.crates)

	return true
end

function ConveyorServer.buyCrate(self: ConveyorServer, player: Player, crateIndex: number): boolean
	if self.player ~= player then
		return false
	end

	local crateId = self.crates[crateIndex]
	if not crateId then
		return false
	end

	local crateInfo = Crates.getCrateInfo(crateId)
	local cost = crateInfo.cost
	if DataService:get(player, "currency") < cost then
		return false
	end

	DataService:update(player, "currency", function(value: number)
		return value - cost
	end)

	self.crates[crateIndex] = nil
	self.networker:fireAll("crateBought", crateIndex)

	InventoryServiceServer:addCrate(player, crateId)
	InventoryServiceServer:addToHotBar(player, crateId)

	return true
end

return ConveyorServer
