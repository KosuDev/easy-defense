local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local EnemyServer = require(script.Parent.EnemyServer)
local TowerServer = require(script.Parent.TowerServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)

type TowerServer = TowerServer.TowerServer
type EnemyServer = EnemyServer.EnemyServer
type Path = PathUtils.Path

local SPAWN_COOLDOWN = 3
local SORT_COOLDOWN = 1
local DefenseServer = {}
DefenseServer.__index = DefenseServer

export type DefenseServer = typeof(setmetatable(
	{} :: {
		path: Path,
		towers: { [string]: TowerServer },
		enemies: { EnemyServer },
		index: number,
		player: Player,
		networker: Networker.Server,
		updateConn: RBXScriptConnection?,
		sortCooldown: number,
		strength: number,
		spawnCd: number,
	},
	DefenseServer
))

function DefenseServer.new(index: number, player: Player): DefenseServer
	local self = setmetatable({
		towers = {},
		enemies = {},
		index = index,
		player = player,
		sortCooldown = SORT_COOLDOWN,
		strength = 0,
		spawnCd = SPAWN_COOLDOWN,
	}, DefenseServer)

	self.networker = Networker.server.new("Defense" .. index, self, {})
	self:start()

	return self
end

function DefenseServer.spawnEnemy(self: DefenseServer)
	local enemyStats = Enemies.getEnemyForStrength(self.strength)
	local enemy = EnemyServer.new(enemyStats)
	self:addEnemy(enemy)
end

function DefenseServer.strengthChanged(self: DefenseServer)
	local strength = 0
	for _, tower in self.towers do
		strength += tower.dps
	end
	self.strength = strength
end

function DefenseServer.updatePath(self: DefenseServer, defenseModel: Model & any)
	local path = PathUtils.calcpath(defenseModel)
	self.path = path

	for _, enemy in self.enemies do
		enemy.path = path
	end

	self.networker:fireAll("pathUpdated", path)
end

function DefenseServer.start(self: DefenseServer)
	if self.updateConn then
		return
	end

	self.updateConn = RunService.Heartbeat:Connect(function(dt)
		self:update(dt)
	end)
end

function DefenseServer.stop(self: DefenseServer)
	if self.updateConn then
		self.updateConn:Disconnect()
		self.updateConn = nil
	end
end

function DefenseServer.removeTower(self: DefenseServer, uniqueId: string)
	local tower = self.towers[uniqueId]
	if not tower then
		warn("Attempted to remove non-existent tower: " .. uniqueId)
		return
	end
	self.towers[uniqueId] = nil
	self.networker:fireAll("towerRemoved", tower.node)
	self:strengthChanged()
end

function DefenseServer.getUniqueIdByNode(self: DefenseServer, node: number): string?
	for uniqueId, tower in self.towers do
		if tower.node == node then
			return uniqueId
		end
	end
	return nil
end

function DefenseServer.addTower(self: DefenseServer, uniqueId: string, tower: TowerServer, dontReplicate: boolean?)
	tower.enemies = self.enemies
	tower.networker = self.networker
	self.towers[uniqueId] = tower
	if not dontReplicate then
		self.networker:fireAll("towerAdded", tower.node, tower.cf, tower.data)
	end
	self:strengthChanged()
end

function DefenseServer.addEnemy(self: DefenseServer, enemy: EnemyServer)
	enemy.path = self.path
	table.insert(self.enemies, enemy)
	self.networker:fireAll("enemyAdded", enemy.uniqueId, enemy.baseStats)
end

function DefenseServer.update(self: DefenseServer, dt: number): ()
	self.spawnCd -= dt
	if self.spawnCd <= 0 then
		self:spawnEnemy()
		self.spawnCd = SPAWN_COOLDOWN
	end

	for i = #self.enemies, 1, -1 do
		local enemy = self.enemies[i]
		enemy:update(dt)

		if enemy.dead then
			table.remove(self.enemies, i)
			if enemy.killed then
				DataService:update(self.player, "currency", function(amt: number)
					return amt + enemy.maxHealth
				end)
			end
		elseif enemy.dist >= self.path.length then
			enemy.dead = true
			table.remove(self.enemies, i)
		end
	end

	for _, tower in self.towers do
		tower:update(dt)
	end

	self.sortCooldown -= dt
	if self.sortCooldown <= 0 then
		table.sort(self.enemies, function(a: EnemyServer, b: EnemyServer): boolean
			return a.dist > b.dist
		end)
		self.sortCooldown = SORT_COOLDOWN
	end
end

function DefenseServer.destroy(self: DefenseServer)
	self.networker:destroy()
	self:stop()
end

return DefenseServer
