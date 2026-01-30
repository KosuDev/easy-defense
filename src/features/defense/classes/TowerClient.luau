local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local DefenseSlice = require(ReplicatedStorage.Source.Features.Defense.DefenseSlice)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local TowerBillboardGui = require(ReplicatedStorage.Source.Features.Defense.UI.Screens.TowerBillboardGui)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local EnemyClient = require(script.Parent.EnemyClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local TowerClient = {}
TowerClient.__index = TowerClient

type TowerData = DataTemplate.TowerData

export type TowerClient = typeof(setmetatable(
	{} :: {
		node: number,
		data: TowerData,
		cf: CFrame,
		model: Model & any,
		attackAnim: any,
		janitor: Janitor.Janitor,
		gui: TowerBillboardGui.TowerGui,
	},
	TowerClient
))

function TowerClient.new(node: number, cf: CFrame, data: TowerData)
	local self = setmetatable({
		node = node,
		data = data,
		cf = cf,
		janitor = Janitor.new(),
	}, TowerClient)

	local model = Towers.getTowerModel(data.itemId, data.mutations)
	model.Parent = workspace
	model:PivotTo(cf * CFrame.new(0, 0.5, 0))
	self.model = model
	self.model:ScaleTo(PlotServiceUtils.getScaleFromLevel(data.level))
	local gui = TowerBillboardGui.new(data)
	gui.Parent = model.PrimaryPart
	self.gui = gui

	local attackAnimModule = script.Parent.Parent.TowerAnimations:FindFirstChild(data.itemId)
	if attackAnimModule then
		self.attackAnim = require(attackAnimModule)
	end

	return self
end

function TowerClient.setData(self: TowerClient, data: TowerData): ()
	self.data = data
	self.model:ScaleTo(PlotServiceUtils.getScaleFromLevel(data.level))
	TowerBillboardGui.update(self.gui, data)
end

function TowerClient.attack(self: TowerClient, enemy: EnemyClient.EnemyClient, damage: number): ()
	enemy:damage(damage)
	if self.attackAnim then
		self.attackAnim(self, enemy)
	end
end

function TowerClient.destroy(self: TowerClient): ()
	DefenseSlice.actions.removeTower(self.model.PrimaryPart)
	self.janitor:Destroy()
	if self.model then
		self.model:Destroy()
	end
end

return TowerClient
