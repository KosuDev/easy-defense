local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)

local ANIMATION = ReplicatedStorage.Assets.Animations.EnemyMovement
local MODEL_OFFSET = CFrame.new(0, 0.125, 0)

local EnemyClient = {}
EnemyClient.__index = EnemyClient

export type EnemyClient = typeof(setmetatable(
	{} :: {
		dist: number,
		enemyId: number,
		uniqueId: number,
		cf: CFrame,
		health: number,
		maxHealth: number,
		speed: number,
		model: Model & any,
		dead: boolean,
		reachedEnd: boolean,
		path: PathUtils.Path,
		hpBar: BillboardGui & any,
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
		cf = PathUtils.getCFrameFromDist(path, 0),
		health = 100,
		speed = 5,
		dead = false,
		maxHealth = 100,
		reachedEnd = false,
		destroyed = Signal.new(),
	}, EnemyClient)

	local model = ReplicatedStorage.Assets.Misc.Enemy:Clone()
	model.Name = "Enemy_" .. uniqueId
	model:PivotTo(self.cf * MODEL_OFFSET)
	model.Parent = workspace
	local track: AnimationTrack = model.AnimationController.Animator:LoadAnimation(ANIMATION)
	track.Looped = true
	track:Play()
	self.model = model
	self.hpBar = model.Root.EnemyHealthBillboard
	self:updateHpBar()

	return self
end

local GREEN = Color3.fromRGB(98, 255, 0)
local RED = Color3.fromRGB(255, 47, 10)

local function percentToGradient(percent: number): ColorSequence
	if percent >= 0.995 then
		return ColorSequence.new(GREEN)
	elseif percent <= 0.005 then
		return ColorSequence.new(RED)
	end

	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, GREEN),
		ColorSequenceKeypoint.new(percent - 0.001, GREEN),
		ColorSequenceKeypoint.new(percent + 0.001, RED),
		ColorSequenceKeypoint.new(1, RED),
	})
end

function EnemyClient.updateHpBar(self: EnemyClient): ()
	local healthPercent = math.clamp(self.health / self.maxHealth, 0, 1)
	local hpText = Abbreviate(self.health) .. " / " .. Abbreviate(self.maxHealth)
	self.hpBar.Frame.Health.Text = hpText
	self.hpBar.Frame.Bar.UIGradient.Color = percentToGradient(healthPercent)
end

function EnemyClient.damage(self: EnemyClient, amt: number): ()
	self.health -= amt
	if self.health <= 0 then
		self.dead = true
	else
		self:updateHpBar()
	end
end

function EnemyClient.update(self: EnemyClient, dt: number): ()
	self.dist += dt * self.speed
	self.cf = PathUtils.getCFrameFromDist(self.path, self.dist)

	if self.model then
		self.model:PivotTo(self.cf * MODEL_OFFSET)
	end

	if self.dist >= self.path.length then
		self.reachedEnd = true
	end
end

function EnemyClient.getPosition(self: EnemyClient): Vector3
	return self.cf.Position
end

function EnemyClient.destroy(self: EnemyClient): ()
	self.destroyed:Fire()
	if self.model then
		self.model:Destroy()
	end
	self.destroyed:Destroy()
end

return EnemyClient
