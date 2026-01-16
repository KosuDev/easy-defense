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
		damage = 1,
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

function Towers.getTowerInfo(towerId: string): TowerInfo
	assert(towers[towerId], "Invalid towerId: " .. towerId)
	return towers[towerId]
end

return Towers
