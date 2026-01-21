local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type TowerInfo = {
	name: string,
	image: string,
	weight: number,
	damage: number,
	range: number,
	firerate: number,
	odds: number,
	id: string,
}

local towers = {
	crossbow = {
		name = "Crossbow",
		image = "",
		weight = 10e9,
		damage = 4,
		range = 20,
		firerate = 2,
	},

	catapult = {
		name = "Catapult",
		image = "",
		weight = 10e9,
		damage = 6,
		range = 20,
		firerate = 1,
	},

	cannon = {
		name = "Cannon",
		image = "",
		weight = 10e9,
		damage = 10,
		range = 20,
		firerate = 0.5,
	},

	turret = {
		name = "Turret",
		image = "",
		weight = 10e9,
		damage = 6,
		range = 20,
		firerate = 1,
	},

	minigun = {
		name = "Minigun",
		image = "",
		weight = 10e9,
		damage = 1,
		range = 20,
		firerate = 4,
	},

	tesla = {
		name = "Tesla",
		image = "",
		weight = 10e9,
		damage = 10,
		range = 25,
		firerate = 1,
	},

	orbOfLight = {
		name = "Orb of Light",
		image = "",
		weight = 10e9,
		damage = 10,
		range = 25,
		firerate = 1,
	},

	laserBlaster = {
		name = "Laser Blaster",
		image = "",
		weight = 10e9,
		damage = 4,
		range = 20,
		firerate = 1,
	},
}

local totalWeight = 0
for _, towerInfo in towers do
	totalWeight += towerInfo.weight
end

local sortedTowers = {}
for towerId, towerInfo in towers do
	towerInfo.odds = towerInfo.weight / totalWeight
	towerInfo.id = towerId
	table.insert(sortedTowers, towerInfo)
end

table.sort(sortedTowers, function(a, b)
	return a.weight > b.weight
end)

local Towers = {}

function Towers.rollTowerId(luck: number): string
	local roll = math.random()
	local sum = 0
	for i = #sortedTowers, 1, -1 do
		local tower = sortedTowers[i]
		local chance = 1 - (1 - towers[tower.id].odds) ^ luck
		sum += chance
		if roll <= sum then
			return tower.id
		end
	end

	return sortedTowers[1].id
end

function Towers.getTowerModel(towerId: string): Model
	assert(towers[towerId], "Invalid tower ID" .. towerId)
	local model = ReplicatedStorage.Assets.Towers[towerId]:Clone()
	return model
end

function Towers.getTowerInfo(towerId: string): TowerInfo
	assert(towers[towerId], "Invalid towerId: " .. towerId)
	return towers[towerId]
end

return Towers
