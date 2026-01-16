local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local EnemyClient = require(script.Parent.EnemyClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local TowerClient = {}
TowerClient.__index = TowerClient

type TowerData = DataTemplate.TowerData

export type TowerClient = typeof(setmetatable(
	{} :: {
		node: number,
		data: TowerData,
		pos: Vector3,
		model: Model & any,
		attackAnim: any,
		janitor: Janitor.Janitor,
	},
	TowerClient
))

function TowerClient.new(node: number, pos: Vector3, data: TowerData)
	local self = setmetatable({
		node = node,
		data = data,
		pos = pos,
		janitor = Janitor.new(),
	}, TowerClient)

	local model = Towers.getTowerModel(data.itemId)
	model.Parent = workspace
	model:PivotTo(CFrame.new(pos) * CFrame.new(0, 0.5, 0))
	self.model = model

	local attackAnimModule = script.Parent.Parent.TowerAnimations:FindFirstChild(data.itemId)
	if attackAnimModule then
		self.attackAnim = require(attackAnimModule)
	end

	return self
end

function TowerClient.attack(self: TowerClient, enemy: EnemyClient.EnemyClient, damage: number): ()
	enemy:damage(damage)
	if self.attackAnim then
		self.attackAnim(self, enemy)
	end
end

function TowerClient.destroy(self: TowerClient): ()
	self.janitor:Destroy()
	if self.model then
		self.model:Destroy()
	end
end

return TowerClient
