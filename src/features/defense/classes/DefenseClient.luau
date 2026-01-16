local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EnemyClient = require(script.Parent.EnemyClient)
local TowerClient = require(script.Parent.TowerClient)
local Networker = require(ReplicatedStorage.Packages.Networker)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type TowerData = DataTemplate.TowerData

local DefenseClient = {}
DefenseClient.__index = DefenseClient

export type DefenseClient = typeof(setmetatable(
	{} :: {
		towers: { [number]: any },
		enemies: { any },
		index: number,
		player: Player,
		networker: Networker.Client,
		path: PathUtils.Path,
		updateConn: RBXScriptConnection?,
	},
	DefenseClient
))

function DefenseClient.new(index: number, player: Player): DefenseClient
	local self = setmetatable({
		towers = {},
		enemies = {},
		index = index,
		player = player,
	}, DefenseClient)

	self.networker = Networker.client.new("Defense" .. index, self)
	self:start()

	return self
end

function DefenseClient.start(self: DefenseClient)
	if self.updateConn then
		return
	end

	self.updateConn = RunService.Heartbeat:Connect(function(dt)
		self:update(dt)
	end)
end

function DefenseClient.stop(self: DefenseClient)
	if self.updateConn then
		self.updateConn:Disconnect()
		self.updateConn = nil
	end
end

function DefenseClient.pathUpdated(self: DefenseClient, path: PathUtils.Path): ()
	self.path = path
	for _, enemy in self.enemies do
		enemy.path = path
	end
end

function DefenseClient.towerAdded(self: DefenseClient, node: number, pos: Vector3, data: TowerData): ()
	local tower = TowerClient.new(node, pos, data)
	self.towers[node] = tower
end

function DefenseClient.enemyAdded(self: DefenseClient, uniqueId: number, enemyId: number): ()
	local enemy = EnemyClient.new(enemyId, uniqueId, self.path)
	self.enemies[uniqueId] = enemy
end

function DefenseClient.removeEnemy(self: DefenseClient, uniqueId: number): ()
	local enemy = self.enemies[uniqueId]
	if enemy then
		enemy:destroy()
		self.enemies[uniqueId] = nil
	end
end

function DefenseClient.towerAttack(self: DefenseClient, node: number, enemyUniqueId: number, damage: number): ()
	local enemy = self.enemies[enemyUniqueId]
	local tower = self.towers[node]
	tower:attack(enemy, damage)
	if enemy.dead then
		self:removeEnemy(enemyUniqueId)
	end
end

function DefenseClient.update(self: DefenseClient, dt: number): ()
	for _, enemy in self.enemies do
		enemy:update(dt)
		if enemy.reachedEnd then
			self:removeEnemy(enemy.uniqueId)
		end
	end
end

function DefenseClient.destroy(self: DefenseClient): ()
	self.networker:destroy()
	self:stop()
	for _, enemy in self.enemies do
		enemy:destroy()
	end
	for _, tower in self.towers do
		tower:destroy()
	end
end

return DefenseClient
