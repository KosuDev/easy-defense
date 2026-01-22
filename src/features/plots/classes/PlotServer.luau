---!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local DefenseServer = require(ServerScriptService.Features.Defense.Classes.DefenseServer)
local TowerServer = require(ServerScriptService.Features.Defense.Classes.TowerServer)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
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
type CrateNode = DataTemplate.CrateNode
type PlotSpawn = PlotTypes.PlotSpawn
type PlotNode = DataTemplate.PlotNode
type NodeData = DataTemplate.NodeData
type Node = PlotTypes.Node

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
		nodes: { Node },
		defense: DefenseServer.DefenseServer,
		serviceNetworker: Networker.Server,
	},
	PlotServer
))

function PlotServer.new(plotSpawn: PlotSpawn, player: Player): Plot
	local self = setmetatable({
		player = player,
		cf = plotSpawn.part.CFrame,
		index = plotSpawn.index,
		crates = {},
		nodes = {},
		janitor = Janitor.new(),
		timeOfLastCrateSpawn = 0,
		defenseLevel = 1,
		defense = DefenseServer.new(plotSpawn.index, player),
		spawnCrate = PlotServer.spawnCrate,
		buyCrate = PlotServer.buyCrate,
		requestBuild = PlotServer.requestBuild,
		requestOpenCrate = PlotServer.requestOpenCrate,
		requestRemove = PlotServer.requestRemove,
		serviceNetworker = InventoryServiceServer.networker,
	}, PlotServer)

	local networker = Networker.server.new("Plot" .. self.index, self, {
		self.spawnCrate,
		self.buyCrate,
		self.requestBuild,
		self.requestOpenCrate,
		self.requestRemove,
	})

	self.networker = networker

	local plotModel: Model & any = PlotModel:Clone()

	plotModel:PivotTo(self.cf)
	plotModel.Parent = workspace
	self.plotModel = plotModel

	self:loadDefense()
	self:charInit()
	self.defense:updatePath(self.defenseModel)

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
		local cf = node.CFrame
		nodes[index] = {
			root = node,
			cf = cf * CFrame.Angles(0, math.rad(90), 0),
			data = nil,
		}
	end

	self.defenseModel = defense
	self.nodes = nodes

	local userNodes: DataTemplate.PlotNodes = DataService:get(self.player, "plotNodes")
	for i, nodeData in userNodes do
		local index = tonumber(i)
		self:build(index, nodeData, true)
	end
end

function PlotServer.isValidNode(self: Plot, node: number)
	return self.nodes[node] ~= nil
end

function PlotServer.isOccupied(self: Plot, node: number)
	local nodeData = self.nodes[node]
	return nodeData and nodeData.data ~= nil
end

function PlotServer.isOwner(self: Plot, player: Player): boolean
	return self.player == player
end

function PlotServer.remove(self: Plot, uniqueId: string): ()
	local node: number? = nil
	for nodeString, uId in DataService:get(self.player, "plotNodes") do
		if uId == uniqueId then
			node = tonumber(nodeString)
			break
		end
	end

	if not node then
		return
	end

	self.defense:removeTower(uniqueId)
	self.nodes[node].data = nil
	self.networker:fireAll("nodeUpdated", node, self.nodes[node])
	DataService:set(self.player, { "plotNodes", tostring(node) }, nil)
end

function PlotServer.build(self: Plot, node: number, plotNode: PlotNode, fromLoad: boolean?)
	local nodeData = self.nodes[node]
	if plotNode.crateId then
		nodeData.data = plotNode
	elseif typeof(plotNode) == "string" then
		local towerData: TowerData? = DataService:get(self.player, { "inventory", plotNode })
		assert(towerData, "Tower data does not exist for uniqueId " .. plotNode)
		nodeData.data = towerData
		if not fromLoad then
			self:remove(plotNode)
		end

		local tower = TowerServer.new(node, nodeData.cf, towerData :: TowerData)
		self.defense:addTower(plotNode, tower)
		DataService:set(self.player, { "plotNodes", tostring(node) }, plotNode)
	else
		warn(plotNode)
		error("Invalid plotNode data")
	end

	self.networker:fireAll("nodeUpdated", node, nodeData)
end

function PlotServer.requestOpenCrate(self: Plot, player: Player, node: number)
	assert(self.player == player, "Player is not the owner of this plot")
	assert(self:isValidNode(node), "Invalid node" .. node)
	local nodeData = self.nodes[node]
	assert(nodeData, "Node data does not exist for node " .. node)
	local crateData: CrateNode? = nodeData.data
	assert(crateData, "No data at node " .. node)
	local crateId, timeBuilt = crateData.crateId, crateData.timeBuilt
	assert(crateId and timeBuilt, "No crate to open at node " .. node)
	local openTime = Crates.getCrateInfo(crateId).openTime
	local timeRemaining = openTime - (workspace:GetServerTimeNow() - timeBuilt)
	assert(timeRemaining <= 0, "Crate is not ready to be opened")

	DataService:set(self.player, { "plotNodes", tostring(node) }, nil)
	self.nodes[node].data = nil

	local towerId = Towers.rollTowerId(1)
	local towerData: TowerData = { itemId = towerId, level = 1 }
	local uniqueId = InventoryServiceServer:addTower(self.player, towerData)
	nodeData.data = towerData

	local tower = TowerServer.new(node, nodeData.cf, towerData)
	self.defense:addTower(uniqueId, tower, true)
	DataService:set(self.player, { "plotNodes", tostring(node) }, uniqueId)
	self.networker:fireAll("crateOpened", node, towerData, nodeData.cf)
	self.networker:fireAll("nodeUpdated", node, nodeData)
end

function PlotServer.requestRemove(self: Plot, player: Player, node: number)
	assert(player == self.player, "Player is not the owner of this plot")
	local nodeData = self.nodes[node]
	if not nodeData or not nodeData.data or nodeData.data.crateId then
		return
	end

	local uniqueId = DataService:get(self.player, { "plotNodes", tostring(node) })
	if not uniqueId then
		return
	end

	self.defense:removeTower(uniqueId)
	self.nodes[node].data = nil
	self.networker:fireAll("nodeUpdated", node, nodeData)
	DataService:set(self.player, { "plotNodes", tostring(node) }, nil)
	self.serviceNetworker:fire(self.player, "addToHotbar", uniqueId)
end

function PlotServer.requestBuild(self: Plot, player: Player, node: number, uniqueId: string)
	assert(player == self.player, "Player is not the owner of this plot")
	assert(self:isValidNode(node), "Invalid node" .. node)
	assert(not self:isOccupied(node), "Node is already occupied")

	local itemData: DataTemplate.ItemData = DataService:get(self.player, { "inventory", uniqueId })
	assert(itemData, "Item data does not exist for uniqueId " .. uniqueId)

	if itemData.itemId then
		self:build(node, uniqueId)
		return
	end

	if not itemData.crateId then
		error("Invalid item data for uniqueId " .. uniqueId)
	end

	if itemData.amt <= 0 then
		return
	end

	DataService:update(self.player, { "inventory", uniqueId, "amt" }, function(value)
		return value - 1
	end)

	local crateData: CrateNode = {
		crateId = itemData.crateId,
		timeBuilt = workspace:GetServerTimeNow(),
	}

	self:build(node, crateData)
	DataService:set(self.player, { "plotNodes", tostring(node) }, crateData)
end

function PlotServer.get(self: Plot): PlotTypes.PlotData
	return {
		index = self.index,
		player = self.player,
		cf = self.cf,
		plotModel = self.plotModel,
		nodes = self.nodes,
		defensePath = self.defense.path,
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
	self.serviceNetworker:fire(player, "addToHotbar", crateId)

	return true
end

function PlotServer.destroy(self: Plot)
	self.plotModel:Destroy()
	self.defenseModel:Destroy()
	self.janitor:Destroy()
	self.networker:destroy()
end

return PlotServer
