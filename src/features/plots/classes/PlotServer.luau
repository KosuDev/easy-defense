local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local PlotModel = ReplicatedStorage.Assets.Misc.Plot
local PlotDefenses = ReplicatedStorage.Assets.PlotDefenses

local MAX_CRATES = 3
local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local CHAR_SPAWN_OFFSET = CFrame.new(0, 20, 0) * CFrame.Angles(0, math.pi, 0)

local PlotServer = {}
PlotServer.__index = PlotServer

type TowerData = DataTemplate.TowerData
type CrateData = DataTemplate.CrateData
type PlotSpawn = PlotTypes.PlotSpawn
export type Plot = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		plotModel: Model,
		defenseLevel: number,
		defenseModel: Model,
		networker: Networker.Server,
		janitor: Janitor.Janitor,
		crates: { string? },
		timeOfLastCrateSpawn: number,
		nodes: { DataTemplate.PlotNode },
	},
	PlotServer
))

function PlotServer.new(plotSpawn: PlotSpawn, player: Player): PlotSpawn
	local self = setmetatable({
		player = player,
		cf = plotSpawn.part.CFrame,
		index = plotSpawn.index,
		crates = {},
		nodes = {},
		janitor = Janitor.new(),
		timeOfLastCrateSpawn = 0,
		defenseLevel = 1,
		spawnCrate = PlotServer.spawnCrate,
		buyCrate = PlotServer.buyCrate,
		requestBuild = PlotServer.requestBuild,
		requestOpenCrate = PlotServer.requestOpenCrate,
	}, PlotServer)

	local networker = Networker.server.new("Plot" .. self.index, self, {
		self.spawnCrate,
		self.buyCrate,
		self.requestBuild,
		self.requestOpenCrate,
	})
	self.networker = networker

	local plotModel: Model & any = PlotModel:Clone()

	plotModel:PivotTo(self.cf)
	plotModel.Parent = workspace
	self.plotModel = plotModel

	self:loadDefense()
	self:charInit()

	return self
end

function PlotServer.loadDefense(self: Plot)
	if self.defenseModel then
		self.defenseModel:Destroy()
	end

	local plotModel = self.plotModel
	local defense: Model & any = PlotDefenses[tostring(self.defenseLevel)]:Clone()
	defense:PivotTo(plotModel.DefenseSpawn.CFrame)
	defense.Parent = plotModel

	local nodes = {}
	for _, node in defense:QueryDescendants(".TowerPlacement") do
		local index = node:GetAttribute("Index") :: number
		local pos = node.CFrame.Position
		nodes[index] = {
			root = node,
			pos = pos,
			crateData = nil,
			itemData = nil,
		}
	end

	self.defenseModel = defense
	self.nodes = nodes

	local userNodes: DataTemplate.PlotNodes = DataService:get(self.player, "plotNodes")
	for i, nodeData in userNodes do
		local index = tonumber(i)
		self:build(index, nodeData)
	end
end

function PlotServer.isValidNode(self: Plot, node: number)
	return self.nodes[node] ~= nil
end

function PlotServer.isOccupied(self: Plot, node: number)
	local nodeData = self.nodes[node]
	return nodeData and (nodeData.crateData ~= nil or nodeData.itemData ~= nil)
end

function PlotServer.isOwner(self: Plot, player: Player): boolean
	return self.player == player
end

function PlotServer.build(self: Plot, node: number, data: CrateData & TowerData)
	local nodeData = self.nodes[node]
	if data.crateId then
		nodeData.crateData = data
	else
		nodeData.towerData = data
	end

	self.networker:fireAll("nodeUpdated", node, nodeData)
end

function PlotServer.requestOpenCrate(self: Plot, player: Player, node: number)
	assert(self.player == player, "Player is not the owner of this plot")
	assert(self:isValidNode(node), "Invalid node" .. node)
	local nodeData = self.nodes[node]
	assert(nodeData, "Node data does not exist for node " .. node)
	assert(nodeData.crateData, "Crate data does not exist for node " .. node)
	local openTime = Crates.getCrateInfo(nodeData.crateData.crateId).openTime
	local timeRemaining = openTime - (workspace:GetServerTimeNow() - nodeData.crateData.timeBuilt)
	assert(timeRemaining <= 0, "Crate is not ready to be opened")
	print("success opening crate") --TODO actually open
end

function PlotServer.requestBuild(self: Plot, player: Player, node: number, uniqueId: string)
	assert(player == self.player, "Player is not the owner of this plot")
	assert(self:isValidNode(node), "Invalid node" .. node)
	assert(not self:isOccupied(node), "Node is already occupied")

	local itemData: DataTemplate.ItemData = DataService:get(self.player, { "inventory", uniqueId })
	assert(itemData, "Item data does not exist for uniqueId " .. uniqueId)

	if itemData.crateId then -- trying to build a crate
		if itemData.amt <= 0 then
			return
		end

		DataService:update(self.player, { "inventory", uniqueId, "amt" }, function(value)
			return value - 1
		end)

		local crateData: CrateData = {
			crateId = itemData.crateId,
			timeBuilt = workspace:GetServerTimeNow(),
		}

		self:build(node, crateData)
		DataService:set(self.player, { "plotNodes", tostring(node) }, crateData)
	end
end

function PlotServer.get(self: Plot): PlotTypes.PlotData
	return {
		index = self.index,
		player = self.player,
		cf = self.cf,
		plotModel = self.plotModel,
		nodes = self.nodes,
	}
end

function PlotServer.charInit(self: Plot)
	local startingChar = self.player.Character or self.player.CharacterAdded:Wait()
	startingChar:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)

	self.janitor:Add(self.player.CharacterAdded:Connect(function(char)
		char:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)
	end))
end

function PlotServer.spawnCrate(self: Plot, player: Player): boolean
	if not self:isOwner(player) then
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

function PlotServer.buyCrate(self: Plot, player: Player, crateIndex: number): boolean
	if not self:isOwner(player) then
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

	DataService:update(player, "currency", function(value)
		return value - cost
	end)

	self.crates[crateIndex] = nil
	self.networker:fireAll("crateBought", crateIndex)

	InventoryServiceServer:addCrate(player, crateId)

	return true
end

function PlotServer.destroy(self: Plot)
	self.plotModel:Destroy()
	self.defenseModel:Destroy()
	self.janitor:Destroy()
	self.networker:destroy()
end

return PlotServer
