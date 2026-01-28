--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local ConveyorServer = require(ServerScriptService.Features.Conveyor.ConveyorServer)
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

local CHAR_SPAWN_OFFSET = CFrame.new(0, 20, 0) * CFrame.Angles(0, math.pi, 0)
local NODE_OFFSET = CFrame.Angles(0, math.rad(90), 0)

local PlotServer = {}
PlotServer.__index = PlotServer

type OccupiedNodes = DataTemplate.OccupiedNodes
type OccupiedNode = DataTemplate.OccupiedNode
type PlotSpawn = PlotTypes.PlotSpawn
type Node = PlotTypes.Node
type NodeData = DataTemplate.NodeData
type ItemData = DataTemplate.ItemData
type CrateNode = DataTemplate.CrateNode

export type PlotServer = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		janitor: Janitor.Janitor,
		conveyor: ConveyorServer.ConveyorServer,
		defense: DefenseServer.DefenseServer,
		networker: Networker.Server,
		plotModel: Model & any,
		defenseModel: (Model & any) | nil,
		nodes: { { Node } },
	},
	PlotServer
))

local function newPlotModel(cf: CFrame): Model & any
	local plotModel = PlotModel:Clone()
	plotModel:PivotTo(cf)
	plotModel.Parent = workspace
	return plotModel
end

local function newDefenseModel(cf: CFrame, rebirths: number): Model & any
	local defenseModel = PlotDefenses[tostring(rebirths + 1)]:Clone()
	defenseModel:PivotTo(cf)
	return defenseModel
end

function PlotServer.new(plotSpawn: PlotSpawn, player: Player): PlotServer
	local self = setmetatable({
		cf = plotSpawn.part.CFrame,
		index = plotSpawn.index,
		player = player,
		janitor = Janitor.new(),
		nodes = {},
		conveyor = ConveyorServer.new(plotSpawn, player),
		defense = DefenseServer.new(plotSpawn.index, player),
		plotModel = newPlotModel(plotSpawn.part.CFrame),
	}, PlotServer)

	self.networker = Networker.server.new("Plot" .. plotSpawn.index, self, {})
	self:charInit()
	self:loadDefense()
	self.janitor:Add(DataService:getChangedSignal(player, "rebirths"):Connect(function()
		self:loadDefense()
	end))

	return self
end

function PlotServer.charInit(self: PlotServer)
	local startingChar = self.player.Character or self.player.CharacterAdded:Wait()
	startingChar:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)

	self.janitor:Add(self.player.CharacterAdded:Connect(function(char)
		char:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)
	end))
end

function PlotServer.loadDefense(self: PlotServer): ()
	if self.defenseModel then
		self.defenseModel:Destroy()
	end

	local rebirths: number = DataService:get(self.player, "rebirths")
	local defenseModel = newDefenseModel(self.cf, rebirths)
	defenseModel.Parent = self.plotModel
	self.defenseModel = defenseModel

	local nodes = {}
	for _, nodePart: any in defenseModel:QueryDescendants(".TowerPlacement") do
		local index = nodePart:GetAttribute("Index") :: number
		local floor = nodePart:GetAttribute("Floor") :: number
		local cf: CFrame = nodePart.CFrame

		if not nodes[floor] then
			nodes[floor] = {}
		end

		nodes[floor][index] = {
			root = nodePart,
			cf = cf * NODE_OFFSET,
			data = nil,
		}
	end

	self.defense:removeAll()
	self.defense:updatePaths(defenseModel)

	local occupiedNodes: OccupiedNodes = DataService:get(self.player, "occupiedNodes")
	for floorNodeStr, occupiedNode in occupiedNodes do
		local floor, node = PlotServiceUtils.stringToFloorNode(floorNodeStr)
		self:build(floor, node, occupiedNode, true)
	end
end

function PlotServer.build(
	self: PlotServer,
	floor: number,
	node: number,
	occupiedNode: OccupiedNode | any,
	fromLoad: boolean?,
	dontReplicate: boolean?
): ()
	local isTower = type(occupiedNode) == "string"
	local nodeData: NodeData = if isTower
		then DataService:get(self.player, { "inventory", occupiedNode })
		else occupiedNode

	if not self.nodes[floor] then
		warn("Invalid floor: " .. floor)
		return
	elseif not self.nodes[floor][node] then
		warn("Invalid node: " .. node)
		return
	elseif not nodeData then
		warn("nodeData not found: ")
		print(occupiedNode)
		return
	end

	local nodeInfo = self.nodes[floor][node]
	nodeInfo.data = nodeData

	if not fromLoad then
		local floorNodeStr = PlotServiceUtils.floorNodeToString(floor, node)
		DataService:set(self.player, { "occupiedNodes", floorNodeStr }, occupiedNode)
	end

	if isTower then
		local uniqueId: string = occupiedNode
		if not fromLoad then
			self:remove(uniqueId) -- Remove existing tower if present
		end

		local tower = TowerServer.new(floor, node, nodeInfo.cf, nodeData)
		self.defense:addTower(uniqueId, tower, dontReplicate)
	end
end

function PlotServer.remove(self: PlotServer, uniqueId: string)
	local floor: number, node: number
	local occupiedNodes: OccupiedNodes = DataService:get(self.player, "occupiedNodes")
	for floorNodeStr, occupiedNode in occupiedNodes do
		if type(occupiedNode) == "string" and occupiedNode == uniqueId then
			floor, node = PlotServiceUtils.stringToFloorNode(floorNodeStr)
			break
		end
	end

	if not floor or not node then
		return
	end

	self.defense:removeTower(uniqueId)
	self.nodes[floor][node].data = nil
	DataService:set(self.player, { "occupiedNodes", PlotServiceUtils.floorNodeToString(floor, node) }, nil)
end

function PlotServer.isValidNode(self: PlotServer, floor: number, node: number): boolean
	if not self.nodes[floor] then
		return false
	elseif not self.nodes[floor][node] then
		return false
	end
	return true
end

function PlotServer.isOccupied(self: PlotServer, floor: number, node: number): boolean
	if not self:isValidNode(floor, node) then
		return false
	end
	return self.nodes[floor][node].data ~= nil
end

function PlotServer.isOwner(self: PlotServer, player: Player): boolean
	return self.player == player
end

function PlotServer.requestBuild(self: PlotServer, player: Player, floor: number, node: number, uniqueId: string): ()
	assert(self:isOwner(player), "Player is not the owner of this plot")
	assert(self:isValidNode(floor, node), "Invalid floor or node")
	assert(not self:isOccupied(floor, node), "Node is already occupied")

	local itemData: ItemData = DataService:get(player, { "inventory", uniqueId })
	assert(itemData, "Item data not found")

	if itemData.itemId then
		self:build(floor, node, uniqueId)
		return
	end

	if not itemData.crateId then
		return
	end

	if itemData.amt <= 0 then
		return
	end

	DataService:update(player, { "inventory", uniqueId, "amt" }, function(amt: number)
		return amt - 1
	end)

	local crateData: CrateNode = {
		crateId = itemData.crateId,
		timeBuilt = workspace:GetServerTimeNow(),
	}

	self:build(floor, node, crateData)
end

function PlotServer.requestRemove(self: PlotServer, player: Player, floor: number, node: number): ()
	assert(self:isOwner(player), "Player is not the owner of this plot")
	assert(self:isValidNode(floor, node), "Invalid floor or node")
	assert(self:isOccupied(floor, node), "Node is not occupied")
	local floorNodeStr = PlotServiceUtils.floorNodeToString(floor, node)
	local uniqueId = DataService:get(self.player, { "occupiedNodes", floorNodeStr })
	if type(uniqueId) == "string" then
		self:remove(uniqueId)
		InventoryServiceServer:addToHotBar(self.player, uniqueId)
	end
end

function PlotServer.requestOpenCrate(self: PlotServer, player: Player, floor: number, node: number): ()
	assert(self:isOwner(player), "Player is not the owner of this plot")
	assert(self:isValidNode(floor, node), "Invalid floor or node")
	local nodeInfo = self.nodes[floor][node]
	assert(nodeInfo.data and nodeInfo.data.crateId, "No crate to open at this node")
	local crateData: CrateNode = nodeInfo.data
	local crateId, timeBuilt = crateData.crateId, crateData.timeBuilt
	assert(crateId and timeBuilt, "No crate to open at node " .. node)
	local openTime = Crates.getCrateInfo(crateId).openTime
	local timeRemaining = openTime - (workspace:GetServerTimeNow() - timeBuilt)
	assert(timeRemaining <= 0, "Crate is not ready to be opened")

	nodeInfo.data = nil
	local floorNodeStr = PlotServiceUtils.floorNodeToString(floor, node)
	DataService:set(self.player, { "occupiedNodes", floorNodeStr }, nil)

	local towerId = Towers.rollTowerId(1)
	local towerData: DataTemplate.TowerData = { itemId = towerId, level = 1 }
	local uniqueId = InventoryServiceServer:addTower(self.player, towerData)
	self.networker:fireAll("crateOpened", node, towerData, nodeInfo.cf)
	self:build(floor, node, uniqueId, nil, true)
end

function PlotServer.destroy(self: PlotServer): ()
	self.janitor:Destroy()
	self.plotModel:Destroy()
	self.defense:destroy()
	self.networker:destroy()
	if self.defenseModel then
		self.defenseModel:Destroy()
	end
end

return PlotServer
