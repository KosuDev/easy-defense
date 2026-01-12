local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CrateClient = require(script.Parent.CrateClient)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)

local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local PlotClient = {}
PlotClient.__index = PlotClient

type Crate = CrateClient.Crate

export type PlotClient = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		plotModel: Model,
		networker: Networker.Client,
		buttonSpring: Ripple.Spring<number>,
		timeOfLastCrateSpawn: number,
		currentCrate: Crate?,
		crateSpawnCf: CFrame,
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
		currentCrate = nil,
		previousCrate = nil,
		crateIndex = 0,
		crateSpawnCf = (plotData.plotModel:FindFirstChild("CrateStart", true) :: any).CFrame,
		buttonSpring = Ripple.createSpring(0, { start = true, damping = 0.5, frequency = 6 }),
	}, PlotClient)

	self.janitor:Add(self.buttonSpring, "destroy")
	self.networker = Networker.client.new("Plot" .. self.index, self)
	if self.player == Players.LocalPlayer then
		self:initModel()
	end

	return self
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

function PlotClient.cratesChanged(self: PlotClient, currentCrate: string)
	if self.currentCrate then
		self.currentCrate:setState("despawning")
	end

	self.currentCrate = CrateClient.new(currentCrate, self.crateSpawnCf)
end

function PlotClient.initModel(self: PlotClient)
	local spawnerButton = self.plotModel:FindFirstChild("SpawnerButton", true) :: BasePart
	local originalCFrame = spawnerButton.CFrame

	self.buttonSpring:onChange(function(v: number)
		spawnerButton.CFrame = originalCFrame * CFrame.new(0, 0, -math.min(v, 0.5))
	end)

	local clicker = Instance.new("ClickDetector")
	clicker.Parent = spawnerButton
	clicker.MouseClick:Connect(function()
		self:attemptCrateSpawn()
	end)
end

function PlotClient.destroy(self: PlotClient)
	self.networker:destroy()
	self.janitor:Destroy()
end

return PlotClient
