local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local Signal = require(ReplicatedStorage.Packages.Signal)
local CrateClient = require(ReplicatedStorage.Source.Features.Crates.Classes.CrateClient)
local InventoryServiceUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceUtils)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local PlotClient = {}
PlotClient.__index = PlotClient

type Crate = CrateClient.Crate
type ClientNode = PlotTypes.ClientNode
type TowerData = DataTemplate.TowerData

export type PlotClient = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		plotModel: Model,
		networker: Networker.Client,
		buttonSpring: Ripple.Spring<number>,
		timeOfLastCrateSpawn: number,
		crates: { Crate },
		conveyorSpeed: Charm.Atom<number>,
		crateSpawnCf: CFrame,
		nodes: { ClientNode },
		nodesUpdated: Signal.Signal<>,
		defenseJanitor: Janitor.Janitor,
		nodeUpdateThread: thread,
	},
	PlotClient
))

function PlotClient.new(plotData: PlotTypes.PlotData): PlotClient
	local self = setmetatable({
		cf = plotData.cf,
		index = plotData.index,
		player = plotData.player,
		plotModel = plotData.plotModel,
		timeOfLastCrateSpawn = 0,
		janitor = Janitor.new(),
		crates = {},
		nodes = plotData.nodes,
		currentCrate = nil,
		previousCrate = nil,
		nodesUpdated = Signal.new(),
		crateIndex = 0,
		crateSpawnCf = (plotData.plotModel:FindFirstChild("CrateStart", true) :: any).CFrame,
		buttonSpring = Ripple.createSpring(0, { start = true, damping = 0.5, frequency = 6 }),
		conveyorSpeed = Charm.atom(0),
		defenseJanitor = Janitor.new(),
	}, PlotClient)

	self.janitor:Add(self.buttonSpring, "destroy")
	self.networker = Networker.client.new("Plot" .. self.index, self)
	if self.player == Players.LocalPlayer then
		self:initModel()
	end

	self:loadDefense()
	self:updateNodeModels()

	self.nodeUpdateThread = task.spawn(function()
		while true do
			task.wait(1)
			self:updateNodeModels()
		end
	end)

	return self
end

function PlotClient.updateNodeModels(self: PlotClient)
	local isLocalBase = self.player == Players.LocalPlayer
	local char = Players.LocalPlayer.Character
	local pos = char:GetPivot().Position
	local dist = (pos - self.cf.Position).Magnitude
	local shouldRender = dist < 200 or isLocalBase

	for _, nodeData in self.nodes do
		local model = nodeData.model
		if model and not shouldRender then
			model.Parent = nil
		elseif model and shouldRender then
			model.Parent = self.plotModel
		end

		local itemData = nodeData.data
		if not model and shouldRender then
			if not itemData then
				continue
			end

			local newModel = InventoryServiceUtils.getModel(itemData)
			newModel:PivotTo(CFrame.new(nodeData.pos) * CFrame.new(0, 1, 0))
			newModel.Parent = self.plotModel
			nodeData.model = newModel
			print("added new model")
		elseif not itemData and model then
			model:Destroy()
			nodeData.model = nil
			print("destroying model")
		end
	end
end

function PlotClient.nodeUpdated(self: PlotClient, node: number, nodeData: ClientNode)
	local oldNodeData = self.nodes[node]
	if oldNodeData and oldNodeData.model then
		oldNodeData.model:Destroy()
	end

	self.nodes[node] = nodeData
	self.nodesUpdated:Fire()
	if self.player ~= Players.LocalPlayer then
		return
	end

	self:updateNodeModels()
	print(nodeData)
	if nodeData.data and nodeData.data.crateId then
		PlotSlice.actions.addCrate(nodeData.root, nodeData.data)
	end
end

function PlotClient.crateOpened(self: PlotClient, node: number, towerData: TowerData)
	local nodeData = self.nodes[node]
	local crateModel = nodeData.model
	PlotSlice.actions.removeCrate(nodeData.root)
	nodeData.data = nil
	nodeData.model = nil
	self.nodesUpdated:Fire()

	--do some aniamation
	task.wait(1)
	crateModel:Destroy()

	--place tower now
end

function PlotClient.loadDefense(self: PlotClient)
	self.defenseJanitor:Cleanup()

	local isLocalPlot = self.player == Players.LocalPlayer
	if not isLocalPlot then
		return
	end

	for _, nodePart in self.plotModel:QueryDescendants(".TowerPlacement") do
		local node = nodePart:GetAttribute("Index") :: number
		local attach = Instance.new("Attachment")
		attach.CFrame = CFrame.new(0, 4, 0)
		attach.Parent = nodePart
		local prox = Instance.new("ProximityPrompt")
		prox.RequiresLineOfSight = false
		prox.MaxActivationDistance = 10
		prox.HoldDuration = 0.5
		prox.ActionText = "Build"
		prox.Parent = attach

		local function updateText()
			local nodeData = self.nodes[node]
			prox.Enabled = true
			if nodeData.data and nodeData.data.crateId then
				prox.ActionText = "Open"
			elseif nodeData.data and not nodeData.data.crateId then
				prox.ActionText = "Remove"
			elseif InventorySlice.state.equippedItemUniqueId() ~= nil then
				prox.ActionText = "Place"
			else
				prox.Enabled = false
			end
		end

		prox.Triggered:Connect(function()
			if prox.ActionText == "Open" then
				self.networker:fire("requestOpenCrate", node)
			elseif prox.ActionText == "Remove" then
				self.networker:fire("requestRemove", node)
			elseif prox.ActionText == "Place" then
				local equippedItemUniqueId = InventorySlice.state.equippedItemUniqueId()
				if not equippedItemUniqueId then
					return
				end
				self.networker:fire("requestBuild", node, equippedItemUniqueId)
			end
		end)

		self.defenseJanitor:Add(Charm.subscribe(InventorySlice.state.equippedItemUniqueId, updateText))
		self.defenseJanitor:Add(self.nodesUpdated:Connect(updateText))
		self.defenseJanitor:Add(prox)
	end
end

function PlotClient.attemptCrateSpawn(self: PlotClient)
	if os.clock() - self.timeOfLastCrateSpawn < CRATE_SPAWN_CD then
		return
	end

	self.timeOfLastCrateSpawn = os.clock()
	self.networker:fire("spawnCrate")
	self.buttonSpring:setGoal(0.5)
	local disconnect
	disconnect = self.buttonSpring:onComplete(function()
		disconnect()
		self.buttonSpring:setGoal(0)
	end)
end

function PlotClient.cratesChanged(self: PlotClient, crateIds: { string })
	for _, prevCrate in self.crates do
		prevCrate:despawn()
	end

	local isLocalPlayer = self.player == Players.LocalPlayer
	self.crates = {}
	self.conveyorSpeed(3.6)
	for i, crateId in crateIds do
		local crate = CrateClient.new(self.crateSpawnCf, i, #crateIds, crateId, isLocalPlayer)
		self.crates[i] = crate
		if isLocalPlayer then
			function crate.onBought()
				self.networker:fire("buyCrate", i)
			end
		end
	end
	task.delay(1.1, function()
		self.conveyorSpeed(0)
	end)
end

function PlotClient.crateBought(self: PlotClient, crateIndex: number)
	local crate = self.crates[crateIndex]
	if crate then
		crate:destroy()
		self.crates[crateIndex] = nil
	end
end

function PlotClient.initModel(self: PlotClient)
	local spawnerButton = self.plotModel:FindFirstChild("SpawnerButton", true) :: BasePart
	local originalCFrame = spawnerButton.CFrame

	self.buttonSpring:onChange(function(v: number)
		spawnerButton.CFrame = originalCFrame * CFrame.new(0, 0, -math.min(v, 0.5))
	end)

	local conveyorBeam = self.plotModel:FindFirstChild("ConveyorBeam", true) :: Beam
	conveyorBeam.TextureSpeed = self.conveyorSpeed()
	self.janitor:Add(Charm.subscribe(self.conveyorSpeed, function(speed: number)
		conveyorBeam.TextureSpeed = speed
	end))

	local clicker = Instance.new("ClickDetector")
	clicker.Parent = spawnerButton
	clicker.MouseClick:Connect(function()
		self:attemptCrateSpawn()
	end)
end

function PlotClient.destroy(self: PlotClient)
	self.networker:destroy()
	self.janitor:Destroy()
	task.cancel(self.nodeUpdateThread)
end

return PlotClient
