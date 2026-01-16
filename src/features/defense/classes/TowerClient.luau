local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		model: Model?,
	},
	TowerClient
))

function TowerClient.new(node: number, pos: Vector3, data: TowerData)
	local self = setmetatable({
		node = node,
		data = data,
		pos = pos,
	}, TowerClient)

	return self
end

function TowerClient.attack(self: TowerClient, enemy: EnemyClient.EnemyClient, damage: number): ()
	local pos = enemy.pos
	enemy:damage(damage)
	print("attacking", pos)
end

function TowerClient.destroy(self: TowerClient): ()
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end

return TowerClient
