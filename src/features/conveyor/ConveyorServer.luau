local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local MonetizationServiceServer = require(ServerScriptService.Features.Monetization.MonetizationServiceServer)
local MutationServiceServer = require(ServerScriptService.Features.Mutations.MutationServiceServer)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local ConveyorUpgrades = require(ReplicatedStorage.Source.Game.Items.ConveyorUpgrades)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local Conveyors = ReplicatedStorage.Assets.Conveyors
local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local MAX_CRATES = 3

local ConveyorServer = {}
ConveyorServer.__index = ConveyorServer

type PlotSpawn = PlotTypes.PlotSpawn
type CrateData = DataTemplate.CrateData

export type ConveyorServer = typeof(setmetatable(
	{} :: {
		plotModel: Model & any,
		level: number,
		player: Player,
		timeOfLastCrateSpawn: number,
		crates: { CrateData? },
		janitor: Janitor.Janitor,
		luckyRollOdds: number,
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
		luckyRollOdds = 0,
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

	if MonetizationServiceServer:ownsGamepass(player, Products.fastConveyor) then
		self.networker:set(player, "speedMultiplier", PlotServiceUtils.enums.factConveyorSpeed)
	end

	self.janitor:Add(
		MonetizationServiceServer:getPassOwnshipChanged(player, Products.fastConveyor):Connect(function(owns)
			if owns then
				self.networker:set(player, "speedMultiplier", PlotServiceUtils.enums.factConveyorSpeed)
			end
		end)
	)

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

	local speed = if MonetizationServiceServer:ownsGamepass(player, Products.fastConveyor)
		then PlotServiceUtils.enums.factConveyorSpeed
		else 1
	if os.clock() - self.timeOfLastCrateSpawn < CRATE_SPAWN_CD / speed then
		return false
	end

	DataService:update(player, { "stats", "crateRolls" }, function(amt: number)
		return amt + 1
	end, true)

	local isLuckyRoll = math.random() < self.luckyRollOdds
	if isLuckyRoll then
		self.luckyRollOdds *= 0.1
	else
		self.luckyRollOdds += 0.01
	end

	local ownsDouble = MonetizationServiceServer:ownsGamepass(self.player, Products.doubleCrates)
	local ownsTriple = MonetizationServiceServer:ownsGamepass(self.player, Products.tripleCrates)
	local crateRolls = if ownsDouble and ownsTriple then 3 else if ownsDouble or ownsTriple then 2 else 1
	local conveyorLuck = ConveyorUpgrades[self.level].luck

	for i = 1, MAX_CRATES do
		if i <= crateRolls then
			local luckThisRoll = if isLuckyRoll and i == 1 then conveyorLuck * 500 else conveyorLuck
			self.crates[i] = {
				crateId = Towers.rollTowerId(luckThisRoll),
				mutations = MutationServiceServer:rollMutations(self.player),
				amt = 1,
			}
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

	local crateData = self.crates[crateIndex]
	if not crateData then
		return false
	end

	local info = Towers.getTowerInfo(crateData.crateId)
	local cost = info.crateCost
	if DataService:get(player, "currency") < cost then
		return false
	end

	DataService:update(player, "currency", function(value: number)
		return value - cost
	end)

	self.crates[crateIndex] = nil
	self.networker:fireAll("crateBought", crateIndex)

	local uniqueId = InventoryServiceServer:addCrate(player, crateData)
	InventoryServiceServer:addToHotBar(player, uniqueId)

	return true
end

function ConveyorServer.destroy(self: ConveyorServer)
	self.janitor:Destroy()
	self.networker:destroy()
end

return ConveyorServer
