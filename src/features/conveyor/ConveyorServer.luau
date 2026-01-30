--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local ConveyorUpgrades = require(ReplicatedStorage.Source.Game.Items.ConveyorUpgrades)

local Conveyors = ReplicatedStorage.Assets.Conveyors
local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local MAX_CRATES = 3

local ConveyorServer = {}
ConveyorServer.__index = ConveyorServer

type PlotSpawn = PlotTypes.PlotSpawn

export type ConveyorServer = typeof(setmetatable(
	{} :: {
		plotModel: Model & any,
		level: number,
		player: Player,
		timeOfLastCrateSpawn: number,
		crates: { string? },
		janitor: Janitor.Janitor,
		model: Model?,
		networker: Networker.Server,
	},
	ConveyorServer
))

function ConveyorServer.new(index: number, plotModel: Model, player: Player): ConveyorServer
	local self = setmetatable({
		plotModel = plotModel,
		player = player,
		level = DataService:get(player, "conveyorLevel"),
		timeOfLastCrateSpawn = 0,
		crates = {},
		model = nil,
		janitor = Janitor.new(),
	}, ConveyorServer)

	self.networker = Networker.server.new("Conveyor" .. index, self, {
		self.spawnCrate,
		self.buyCrate :: any,
		self.requestUpgrade,
	})
	self.janitor:Add(DataService:getChangedSignal(player, "conveyorLevel"):Connect(function(newLevel: number)
		self.level = newLevel
		self.networker:fireAll("setLevel", newLevel)
		self:update()
	end))

	self:update()

	return self
end

function ConveyorServer.update(self: ConveyorServer)
	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	local model: Model & any = (Conveyors:FindFirstChild(tostring(self.level)) or Conveyors:FindFirstChild("1")):Clone()
	model:PivotTo(self.plotModel.ConveyorSpawn.CFrame)
	model.Parent = self.plotModel
	self.model = model
	self.networker:fireAll("setModel", model)
end

function ConveyorServer.requestUpgrade(self: ConveyorServer, player: Player)
	if self.player ~= player then
		return
	end

	local nextLevel = self.level + 1
	local conveyorInfo = ConveyorUpgrades[nextLevel]
	if not conveyorInfo then
		return
	end

	if DataService:get(player, "currency") < conveyorInfo.cost then
		return
	end

	DataService:update(player, "currency", function(value: number)
		return value - conveyorInfo.cost
	end)

	DataService:set(player, "conveyorLevel", nextLevel)
end

function ConveyorServer.spawnCrate(self: ConveyorServer, player: Player): boolean
	if self.player ~= player then
		return false
	end

	if os.clock() - self.timeOfLastCrateSpawn < CRATE_SPAWN_CD then
		return false
	end

	local crateRolls = 1 -- TODO: Make this depend on some level
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

function ConveyorServer.destroy(self: ConveyorServer)
	self.janitor:Destroy()
	self.networker:destroy()
end

return ConveyorServer
