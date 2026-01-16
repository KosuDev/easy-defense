local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local EnemyClient = {}
EnemyClient.__index = EnemyClient

export type EnemyClient = typeof(setmetatable(
	{} :: {
		dist: number,
		enemyId: number,
		uniqueId: number,
		pos: Vector3,
		health: number,
		maxHealth: number,
		speed: number,
		model: Model?,
		dead: boolean,
		reachedEnd: boolean,
		path: PathUtils.Path,
	},
	EnemyClient
))

function EnemyClient.new(enemyId: number, uniqueId: number, path: PathUtils.Path): EnemyClient
	local self = setmetatable({
		dist = 0,
		path = path,
		enemyId = enemyId,
		uniqueId = uniqueId,
		pos = Vector3.new(),
		health = 100,
		speed = 5,
		dead = false,
		maxHealth = 100,
		reachedEnd = false,
	}, EnemyClient)

	local model = Instance.new("Part")
	model.Size = Vector3.new(4, 4, 4)
	model.Anchored = true
	model.Parent = workspace
	self.model = model

	return self
end

function EnemyClient.damage(self: EnemyClient, amt: number): ()
	self.health -= amt
	if self.health < 0 then
		self.dead = true
	end
end

function EnemyClient.update(self: EnemyClient, dt: number): ()
	self.dist += dt * self.speed
	self.pos = PathUtils.getPosFromDist(self.path, self.dist)

	if self.model then
		self.model:PivotTo(CFrame.new(self.pos))
	end

	if self.dist >= self.path.length then
		self.reachedEnd = true
	end
end

function EnemyClient.destroy(self: EnemyClient): ()
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end

return EnemyClient
