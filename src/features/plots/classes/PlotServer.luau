local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local PlotModel = ReplicatedStorage.Assets.Misc.Plot
local PlotDefenses = ReplicatedStorage.Assets.PlotDefenses

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
		janitor: Janitor.Janitor,
	},
	PlotServer
))

function PlotServer.new(plotSpawn: PlotSpawn, player: Player): PlotSpawn
	local self = setmetatable({
		player = player,
		cf = plotSpawn.part.CFrame,
		index = plotSpawn.index,
		janitor = Janitor.new(),
	}, PlotServer)

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

function PlotServer.charInit(self: Plot)
	local startingChar = self.player.Character or self.player.CharacterAdded:Wait()
	startingChar:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)

	self.janitor:Add(self.player.CharacterAdded:Connect(function(char)
		char:PivotTo(self.plotModel:GetPivot() * CHAR_SPAWN_OFFSET)
	end))
end

function PlotServer.destroy(self: Plot)
	self.plotModel:Destroy()
	self.defenseModel:Destroy()
	self.janitor:Destroy()
end

return PlotServer
