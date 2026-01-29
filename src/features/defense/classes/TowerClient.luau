local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local DefenseSlice = require(ReplicatedStorage.Source.Features.Defense.DefenseSlice)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local EnemyClient = require(script.Parent.EnemyClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)
local TowerClient = {}
TowerClient.__index = TowerClient

type TowerData = DataTemplate.TowerData
type TowerGui = BillboardGui & {
	Dps: Frame & {
		TextLabel: TextLabel & {
			Gradient: UIGradient,
			Stroke: UIStroke,
		},
	},
	Rarity: Frame & {
		TextLabel: TextLabel & {
			Gradient: UIGradient,
			Stroke: UIStroke,
		},
	},
	TowerName: Frame & {
		TextLabel: TextLabel & {
			Stroke: UIStroke,
		},
	},
}

export type TowerClient = typeof(setmetatable(
	{} :: {
		node: number,
		data: TowerData,
		cf: CFrame,
		model: Model & any,
		attackAnim: any,
		janitor: Janitor.Janitor,
		gui: TowerGui,
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

	local model = Towers.getTowerModel(data.itemId)
	model.Parent = workspace
	model:PivotTo(cf * CFrame.new(0, 0.5, 0))
	self.model = model
	self.model:ScaleTo(PlotServiceUtils.getScaleFromLevel(data.level))
	local gui = ReplicatedStorage.Assets.VFX.TowerBillboard:Clone()
	gui.Parent = model.PrimaryPart
	self.gui = gui
	self:updateGui()

	local attackAnimModule = script.Parent.Parent.TowerAnimations:FindFirstChild(data.itemId)
	if attackAnimModule then
		self.attackAnim = require(attackAnimModule)
	end

	return self
end

function TowerClient.setData(self: TowerClient, data: TowerData): ()
	self.data = data
	self.model:ScaleTo(PlotServiceUtils.getScaleFromLevel(data.level))
	self:updateGui()
end

function TowerClient.updateGui(self: TowerClient): ()
	local info = Towers.getTowerInfo(self.data.itemId)
	local rarityTier = Tiers.getTierForOdds(info.odds)
	local scale = PlotServiceUtils.getScaleFromLevel(self.data.level)
	self.gui.StudsOffsetWorldSpace = Vector3.new(0, info.height * scale, 0)
	self.gui.TowerName.TextLabel.Text = info.name
	self.gui.Rarity.TextLabel.Text = rarityTier.name
	self.gui.Rarity.TextLabel.Gradient.Color = rarityTier.gradient
	self.gui.Dps.TextLabel.Text = `💪 {Abbreviate(PlotServiceUtils.getDps(self.data))}`
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
