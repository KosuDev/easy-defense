local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local EnemyServer = {}
EnemyServer.__index = EnemyServer

type EnemyStats = Enemies.EnemyStats

export type EnemyServer = typeof(setmetatable(
	{} :: {
		dist: number,
		pos: Vector3,
		health: number,
		speed: number,
		maxHealth: number,
		dead: boolean,
		killed: boolean,
		path: any,
		uniqueId: number,
		baseStats: EnemyStats,
	},
	EnemyServer
))

local uniqueIdCounter = 0
local function getUniqueId(): number
	uniqueIdCounter += 1
	return uniqueIdCounter
end

function EnemyServer.new(enemyStats: EnemyStats): EnemyServer
	local self = setmetatable({
		baseStats = enemyStats,
		uniqueId = getUniqueId(),
		dist = 0,
		pos = Vector3.new(),
		dead = false,
		killed = false,
		health = enemyStats.health,
		maxHealth = enemyStats.health,
		speed = enemyStats.speed,
	}, EnemyServer)

	return self
end

function EnemyServer.damage(self: EnemyServer, amt: number): ()
	self.health -= amt
	if self.health <= 0 then
		self.dead = true
		self.killed = true
	end
end

function EnemyServer.update(self: EnemyServer, dt: number): ()
	self.dist += self.speed * dt
	self.pos = PathUtils.getPosFromDist(self.path, self.dist)
end

return EnemyServer
