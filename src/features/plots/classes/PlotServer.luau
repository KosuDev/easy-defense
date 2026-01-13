local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local PlotModel = ReplicatedStorage.Assets.Misc.Plot
local PlotDefenses = ReplicatedStorage.Assets.PlotDefenses

local MAX_CRATES = 3
local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown
local CHAR_SPAWN_OFFSET = CFrame.new(0, 20, 0) * CFrame.Angles(0, math.pi, 0)

local PlotServer = {}
PlotServer.__index = PlotServer

type PlotSpawn = PlotTypes.PlotSpawn
export type Plot = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		plotModel: Model,
		defenseModel: Model,
		networker: Networker.Server,
		janitor: Janitor.Janitor,
		crates: { string? },
		timeOfLastCrateSpawn: number,
	},
	PlotServer
))

function PlotServer.new(plotSpawn: PlotSpawn, player: Player): PlotSpawn
	local self = setmetatable({
		player = player,
		cf = plotSpawn.part.CFrame,
		index = plotSpawn.index,
		crates = {},
		janitor = Janitor.new(),
		timeOfLastCrateSpawn = 0,
		spawnCrate = PlotServer.spawnCrate,
		buyCrate = PlotServer.buyCrate,
	}, PlotServer)

	local networker = Networker.server.new("Plot" .. self.index, self, { self.spawnCrate, self.buyCrate })
	self.networker = networker

	local plotModel: Model & any = PlotModel:Clone()
	local defense: Model = PlotDefenses["1"]:Clone()
	defense:PivotTo(plotModel.DefenseSpawn.CFrame)
	defense.Parent = plotModel
	plotModel:PivotTo(self.cf)
	plotModel.Parent = workspace
	self.plotModel = plotModel
	self.defenseModel = defense
	self:charInit()

	return self
end

function PlotServer.get(self: Plot): PlotTypes.PlotData
	return {
		index = self.index,
		player = self.player,
		cf = self.cf,
		plotModel = self.plotModel,
	}
end

function PlotServer.charInit(self: Plot)
	local startingChar = self.player.Character or self.player.CharacterAdded:Wait()
	startingChar:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)

	self.janitor:Add(self.player.CharacterAdded:Connect(function(char)
		char:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)
	end))
end

function PlotServer.isOwner(self: Plot, player: Player): boolean
	return self.player == player
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

	-- add to player's inventory here

	return true
end

function PlotServer.destroy(self: Plot)
	self.plotModel:Destroy()
	self.defenseModel:Destroy()
	self.janitor:Destroy()
	self.networker:destroy()
end

return PlotServer
