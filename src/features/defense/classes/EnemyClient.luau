local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ColorTweaker = require(ReplicatedStorage.Source.Core.Platform.ColorTweaker)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local HitSplat = require(ReplicatedStorage.Source.Features.Defense.Modules.HitSplat)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)

local ANIMATION = ReplicatedStorage.Assets.Animations.EnemyMovement
local MODEL_OFFSET = CFrame.new(0, 0.125, 0)
local ANIMATION_SPEED = 6

local EnemyClient = {}
EnemyClient.__index = EnemyClient

export type EnemyClient = typeof(setmetatable(
	{} :: {
		dist: number,
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
		baseStats: Enemies.EnemyStats,
		track: AnimationTrack,
		floor: number,
	},
	EnemyClient
))

function EnemyClient.new(
	floor: number,
	enemyStats: Enemies.EnemyStats,
	uniqueId: number,
	path: PathUtils.Path
): EnemyClient
	local self = setmetatable({
		floor = floor,
		dist = 0,
		path = path,
		baseStats = enemyStats,
		uniqueId = uniqueId,
		cf = PathUtils.getCFrameFromDist(path, 0),
		health = enemyStats.health,
		speed = enemyStats.speed,
		dead = false,
		maxHealth = enemyStats.health,
		reachedEnd = false,
		destroyed = Signal.new(),
	}, EnemyClient)

	local model = ReplicatedStorage.Assets.Misc.Enemy:Clone()
	model:ScaleTo(enemyStats.size)
	model.Name = "Enemy_" .. uniqueId
	model:PivotTo(self.cf * MODEL_OFFSET)
	ColorTweaker.fromContainer(model, {
		primaryColor = ColorTweaker.enums.primaryColors.master,
		hue = enemyStats.x / 16,
	})
	model.Parent = workspace
	local track: AnimationTrack = model.AnimationController.Animator:LoadAnimation(ANIMATION)
	self.track = track
	track.Looped = true
	track:Play(nil, nil, enemyStats.speed / ANIMATION_SPEED)
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

function EnemyClient.updateSpeed(self: EnemyClient, newSpeed: number): ()
	self.speed = newSpeed
	self.track:AdjustSpeed(self.speed / ANIMATION_SPEED)
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
		local color = self.model.Inner.Color
		local reward = Enemies.getEnemyReward(self.maxHealth, DataService.client:get("rebirths"))
		HitSplat(self:getPosition(), color, reward)
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
