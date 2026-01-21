export type EnemyStats = {
	health: number,
	speed: number,
	size: number,
	x: number,
}

local HP_SCALAR = 0.1

local enemies = {
	normal = {
		health = 100,
		speed = 6,
		size = 1,
		odds = 0.7,
	},

	fast = {
		health = 35,
		speed = 14,
		size = 0.75,
		odds = 0.2,
	},

	tank = {
		health = 300,
		speed = 3,
		size = 1.5,
		odds = 0.1,
	},
}

local Enemies = {}

local function rollStrengthMultiplier(): number
	local x = math.random()
	local n = math.clamp(1 + 0.33 * x + (x + 0.05) ^ 30, 1, 5)
	return if math.random() < 0.5 then n else 1 / n
end

local function rollEnemyType(): string
	local roll = math.random()
	local cumulative = 0
	for enemyType, data in enemies do
		cumulative += data.odds
		if roll <= cumulative then
			return enemyType
		end
	end
	return "normal"
end

local function getEnemyStats(x: number, enemyType: string): EnemyStats
	local base = enemies[enemyType]
	return {
		health = base.health * HP_SCALAR * 2 ^ x,
		speed = base.speed,
		size = base.size,
		x = x,
	}
end

function Enemies.getEnemyForStrength(strength: number): EnemyStats
	local mult = rollStrengthMultiplier()
	strength *= mult
	local x = math.max(1, math.round(math.log(strength / 4, 2)))
	print("Strength", math.round(strength), "   Mult:", mult, "   X:", x)
	local enemyType = rollEnemyType()
	return getEnemyStats(x, enemyType)
end

return Enemies
