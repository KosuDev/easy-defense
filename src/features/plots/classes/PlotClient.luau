local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local CrateClient = require(ReplicatedStorage.Source.Features.Crates.Classes.CrateClient)
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
		crates: { Crate },
		conveyorSpeed: Charm.Atom<number>,
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
		conveyorSpeed = Charm.atom(0),
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

function PlotClient.cratesChanged(self: PlotClient, crateIds: { string })
	for _, prevCrate in self.crates do
		prevCrate:despawn()
	end

	local isLocalPlayer = self.player == Players.LocalPlayer
	self.crates = {}
	for i, crateId in crateIds do
		local crate = CrateClient.new(self.crateSpawnCf, i, #crateIds, crateId, isLocalPlayer)
		self.crates[i] = crate
		if isLocalPlayer then
			function crate.onBought()
				self.networker:fire("buyCrate", i)
			end
		end
	end
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
end

return PlotClient
