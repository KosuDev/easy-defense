--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EnemyClient = require(script.Parent.EnemyClient)
local TowerClient = require(script.Parent.TowerClient)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type TowerData = DataTemplate.TowerData

local DefenseClient = {}
DefenseClient.__index = DefenseClient

export type DefenseClient = typeof(setmetatable(
	{} :: {
		towers: { { TowerClient.TowerClient } },
		enemies: { EnemyClient.EnemyClient },
		index: number,
		player: Player,
		networker: Networker.Client,
		paths: { PathUtils.Path },
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
		paths = {},
	}, DefenseClient)

	self.networker = Networker.client.new("Defense" .. index, self :: any)
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

function DefenseClient.pathsUpdated(self: DefenseClient, paths: { PathUtils.Path }): ()
	self.paths = paths
	for _, enemy in self.enemies do
		enemy.path = self.paths[enemy.floor]
	end
end

function DefenseClient.towerRemoved(self: DefenseClient, floor: number, node: number): ()
	local tower = self.towers[floor][node]
	if tower then
		tower:destroy()
		self.towers[floor][node] = nil
	end
end

function DefenseClient.towerAdded(self: DefenseClient, floor: number, node: number, cf: CFrame, data: TowerData): ()
	local tower = TowerClient.new(node, cf, data)
	if not self.towers[floor] then
		self.towers[floor] = {}
	end
	self.towers[floor][node] = tower
end

function DefenseClient.towerUpdated(self: DefenseClient, floor: number, node: number, data: TowerData): ()
	local tower = self.towers[floor][node]
	if tower then
		tower:setData(data)
	end
end

function DefenseClient.enemyAdded(
	self: DefenseClient,
	floor: number,
	uniqueId: number,
	enemyStats: Enemies.EnemyStats
): ()
	local enemy = EnemyClient.new(floor, enemyStats, uniqueId, self.paths[floor])
	self.enemies[uniqueId] = enemy
end

function DefenseClient.removeEnemy(self: DefenseClient, uniqueId: number): ()
	local enemy = self.enemies[uniqueId]
	if enemy then
		enemy:destroy()
		self.enemies[uniqueId] = nil
	end
end

function DefenseClient.towerAttack(
	self: DefenseClient,
	floor: number,
	node: number,
	enemyUniqueId: number,
	damage: number
): ()
	local enemy = self.enemies[enemyUniqueId]
	local tower = self.towers[floor][node]
	tower:attack(enemy, damage)
	if enemy.dead then
		task.defer(function()
			self:removeEnemy(enemyUniqueId)
		end)
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
	for _, floorTowers in self.towers do
		for _, tower in floorTowers do
			tower:destroy()
		end
	end
end

return DefenseClient
