--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ConveyorClient = require(ReplicatedStorage.Source.Features.Conveyor.ConveyorClient)
local CrateOpenVfx = require(ReplicatedStorage.Source.Features.Crates.Modules.CrateOpenVfx)
local DefenseClient = require(ReplicatedStorage.Source.Features.Defense.Classes.DefenseClient)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventoryServiceUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceUtils)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local PlotClient = {}
PlotClient.__index = PlotClient

type ClientNode = PlotTypes.ClientNode
type Node = PlotTypes.Node
type TowerData = DataTemplate.TowerData

export type PlotClient = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		plotModel: Model,
		janitor: Janitor.Janitor,
		nodes: { { ClientNode } },
		defense: DefenseClient.DefenseClient,
		defenseJanitor: Janitor.Janitor,
		networker: Networker.Client,
		nodesUpdated: Signal.Signal<>,
	},
	PlotClient
))

function PlotClient.new(plotData: PlotTypes.PlotData): PlotClient
	local self: PlotClient = setmetatable({
		cf = plotData.cf,
		index = plotData.index,
		player = plotData.player,
		plotModel = plotData.plotModel,
		nodes = plotData.nodes,
		janitor = Janitor.new(),
		defense = DefenseClient.new(plotData.index, plotData.player),
		conveyor = ConveyorClient.new(),
		defenseJanitor = Janitor.new(),
		nodesUpdated = Signal.new(),
	}, PlotClient) :: any

	self.defense:pathsUpdated(plotData.paths)
	self.networker = Networker.client.new("Plot" .. plotData.index, self :: any)
	self:loadDefense()

	return self
end

function PlotClient.attemptBuild(self: PlotClient, floor: number, node: number)
	local equippedItemUniqueId = InventorySlice.state.equippedItemUniqueId()
	if not equippedItemUniqueId then
		return
	end

	self.networker:fire("requestBuild", floor, node, equippedItemUniqueId)
	local data = DataService:get({ "inventory", equippedItemUniqueId }) :: DataTemplate.ItemData
	if data.itemId or (data.crateId and data.amt <= 0) then
		InventoryServiceClient:unequipItem()
	end
end

function PlotClient.loadDefense(self: PlotClient, nodes: { { ClientNode } }?)
	if nodes then
		self:setNodes(nodes)
	end

	self.defenseJanitor:Cleanup()
	if self.player ~= Players.LocalPlayer then
		return
	end

	for floor, floorNodes in self.nodes do
		for nodeIndex, node in floorNodes do
			self:_initProxForNode(node, floor, nodeIndex)
		end
	end
end

function PlotClient.setNodes(self: PlotClient, nodes: { { Node } })
	for floorIndex, floor in nodes do
		for nodeIndex, node in floor do
			self:setNode(floorIndex, nodeIndex, node)
		end
	end
end

function PlotClient.setNode(self: PlotClient, floor: number, node: number, nodeData: Node)
	local current = self.nodes[floor][node]
	if current and current.model then
		PlotSlice.actions.removeCrate(current.root)
		current.model:Destroy()
	end

	local clientNode: ClientNode = nodeData :: any
	if nodeData.data and nodeData.data.crateId then
		local crateModel = InventoryServiceUtils.getModel(nodeData.data :: any)
		crateModel:PivotTo(nodeData.cf * CFrame.new(0, 1, 0))
		crateModel.Parent = self.plotModel
		clientNode.model = crateModel
		PlotSlice.actions.addCrate(nodeData.root, nodeData.data)
	end

	self.nodes[floor][node] = clientNode
	self.nodesUpdated:Fire()
end

function PlotClient.crateOpened(self: PlotClient, floor: number, node: number, towerData: TowerData, towerCf: CFrame)
	local nodeData = self.nodes[floor][node]
	local crateModel = nodeData.model
	PlotSlice.actions.removeCrate(nodeData.root)
	nodeData.data = nil
	nodeData.model = nil :: any
	self.nodesUpdated:Fire()

	crateModel:Destroy()
	CrateOpenVfx(nodeData.cf, towerData)

	self.defense:towerAdded(floor, node, towerCf, towerData)
end

function PlotClient._initProxForNode(self: PlotClient, node: ClientNode, floor: number, nodeIndex: number)
	local root = node.root
	local attach = Instance.new("Attachment")
	attach.CFrame = CFrame.new(0, 4, 0)
	attach.Parent = root
	local prox = Instance.new("ProximityPrompt")
	prox.RequiresLineOfSight = false
	prox.MaxActivationDistance = 10
	prox.HoldDuration = 0.5
	prox.ActionText = "Build"
	prox.Parent = attach

	local function update()
		local data = self.nodes[floor][nodeIndex].data
		prox.Enabled = true
		if data and data.crateId then
			prox.ActionText = "Open"
		elseif data and not data.crateId then
			prox.ActionText = "Remove"
		elseif InventorySlice.state.equippedItemUniqueId() ~= nil then
			prox.ActionText = "Place"
		else
			prox.Enabled = false
		end
	end

	prox.Triggered:Connect(function()
		if prox.ActionText == "Open" then
			self.networker:fire("requestOpenCrate", floor, nodeIndex)
		elseif prox.ActionText == "Remove" then
			self.networker:fire("requestRemove", floor, nodeIndex)
		elseif prox.ActionText == "Place" then
			self:attemptBuild(floor, nodeIndex)
		end
	end)

	update()
	self.defenseJanitor:Add(prox)
	self.defenseJanitor:Add(self.nodesUpdated:Connect(update))
	self.defenseJanitor:Add(Charm.subscribe(InventorySlice.state.equippedItemUniqueId, update))
end

function PlotClient.destroy(self: PlotClient)
	self.janitor:Destroy()
	self.plotModel:Destroy()
	self.defense:stop()
	self.defenseJanitor:Destroy()
end

return PlotClient
