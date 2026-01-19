local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)

local ANIMATION = ReplicatedStorage.Assets.Animations.EnemyMovement

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
		model: Model & any,
		dead: boolean,
		reachedEnd: boolean,
		path: PathUtils.Path,
		destroyed: Signal.Signal<>,
	},
	EnemyClient
))

function EnemyClient.new(enemyId: number, uniqueId: number, path: PathUtils.Path): EnemyClient
	local self = setmetatable({
		dist = 0,
		path = path,
		enemyId = enemyId,
		uniqueId = uniqueId,
		pos = PathUtils.getPosFromDist(path, 0),
		health = 100,
		speed = 5,
		dead = false,
		maxHealth = 100,
		reachedEnd = false,
		destroyed = Signal.new(),
	}, EnemyClient)

	local model = ReplicatedStorage.Assets.Misc.Enemy:Clone()
	model.Name = "Enemy_" .. uniqueId
	model:PivotTo(CFrame.new(self.pos))
	model.Parent = workspace
	model.AnimationController.Animator:LoadAnimation(ANIMATION):Play()
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

function EnemyClient.getPosition(self: EnemyClient): Vector3
	return self.pos
end

function EnemyClient.destroy(self: EnemyClient): ()
	self.destroyed:Fire()
	if self.model then
		self.model:Destroy()
	end
	self.destroyed:Destroy()
end

return EnemyClient
