local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local EnemyServer = require(script.Parent.EnemyServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local XZ = Vector3.new(1, 0, 1)
local MAX_HEIGHT_DIFF = 6

local TowerServer = {}
TowerServer.__index = TowerServer

type TowerData = DataTemplate.TowerData
type EnemyServer = EnemyServer.EnemyServer

export type TowerServer = typeof(setmetatable(
	{} :: {
		node: number,
		data: TowerData,
		pos: Vector3,
		cd: number,
		towerInfo: Towers.TowerInfo,
		enemies: { EnemyServer },
		networker: Networker.Server,
	},
	TowerServer
))

function TowerServer.new(node: number, pos: Vector3, data: TowerData): TowerServer
	local self = setmetatable({
		node = node,
		data = data,
		pos = pos,
		towerInfo = Towers.getTowerInfo(data.itemId),
		enemies = nil :: any,
		networker = nil :: any,
	}, TowerServer)

	self.cd = 1 / self.towerInfo.firerate

	return self
end

function TowerServer.attack(self: TowerServer, enemy: EnemyServer): ()
	local damage = self.towerInfo.damage
	enemy:damage(damage)
	self.cd = 1 / self.towerInfo.firerate
	self.networker:fireAll("towerAttack", self.node, enemy.uniqueId, damage)
end

function TowerServer.update(self: TowerServer, dt: number): ()
	self.cd -= dt
	if self.cd > 0 then
		return
	end

	for _, enemy in self.enemies do
		local dist = ((enemy.pos - self.pos) * XZ).Magnitude
		local heightDiff = math.abs(enemy.pos.Y - self.pos.Y)
		if dist > self.towerInfo.range or heightDiff > MAX_HEIGHT_DIFF then
			continue
		end

		self:attack(enemy)
		break
	end
end

return TowerServer
