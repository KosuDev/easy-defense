local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
export type TowerInfo = {
	name: string,
	image: string,
	weight: number,
	damage: number,
	range: number,
	firerate: number,
	odds: number,
	id: string,
	height: number,
	layoutOrder: number,
}

local towers = {
	crossbow = {
		name = "Crossbow",
		image = "rbxassetid://137282012852812",
		weight = 10e9,
		damage = 4,
		range = 25,
		firerate = 2,
		height = 6,
	},

	catapult = {
		name = "Catapult",
		image = "rbxassetid://83891927108386",
		weight = 4e9,
		damage = 15,
		range = 25,
		firerate = 1,
		height = 6,
	},

	cannon = {
		name = "Cannon",
		image = "rbxassetid://71141124599337",
		weight = 1.5e9,
		damage = 40,
		range = 25,
		firerate = 0.66,
		height = 6.5,
	},

	turret = {
		name = "Turret",
		image = "rbxassetid://120894736547855",
		weight = 600e6,
		damage = 60,
		range = 25,
		firerate = 1,
		height = 7,
	},

	minigun = {
		name = "Minigun",
		image = "rbxassetid://109830357002566",
		weight = 187e6,
		damage = 33,
		range = 25,
		firerate = 4,
		height = 7,
	},

	tesla = {
		name = "Tesla",
		image = "rbxassetid://103187875630362",
		weight = 64e6,
		damage = 250,
		range = 25,
		firerate = 1,
		height = 10,
	},

	orbOfLight = {
		name = "Orb of Light",
		image = "rbxassetid://135703405395373",
		weight = 28e6,
		damage = 600,
		range = 25,
		firerate = 0.75,
		height = 9.5,
	},

	laserBlaster = {
		name = "Laser Blaster",
		image = "rbxassetid://88729081935706",
		weight = 16e6,
		damage = 800,
		range = 25,
		firerate = 1.25,
		height = 8.5,
	},

	flamethrower = {
		name = "Flamethrower",
		image = "rbxassetid://137282012852812",
		weight = 7.5e6,
		damage = 456,
		range = 25,
		firerate = 4.2,
		height = 8,
	},

	plasmaCannon = {
		name = "Plasma Cannon",
		image = "rbxassetid://137282012852812",
		weight = 4e6,
		damage = 4000,
		range = 25,
		firerate = 1,
		height = 8.5,
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

for i, tower in sortedTowers do
	tower.layoutOrder = i
end

local Towers = {
	towers = towers,
	sortedTowers = sortedTowers,
}

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

local function _listOdds()
	print("--------------------------------")
	for _, tower in sortedTowers do
		print(
			"1/"
				.. Abbreviate(math.ceil(1 / tower.odds))
				.. " "
				.. math.round(tower.odds * 10000) / 100
				.. "% "
				.. tower.name
		)
	end
end

return Towers
