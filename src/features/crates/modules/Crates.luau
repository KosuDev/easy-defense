local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type CrateInfo = {
	id: string,
	weight: number,
	cost: number,
	odds: number,
	image: string,
	name: string,
	openTime: number,
	layoutOrder: number,
}

local crates = {
	wooden = {
		name = "Wooden Crate",
		image = "rbxassetid://92040501256272",
		weight = 1e9,
		cost = 100,
		openTime = 5,
	},
	silver = {
		name = "Silver Crate",
		image = "rbxassetid://72492711846524",
		weight = 5e8,
		cost = 1e3,
		openTime = 15,
	},
	gold = {
		name = "Gold Crate",
		image = "rbxassetid://115551403938538",
		weight = 1e8,
		cost = 10e3,
		openTime = 25,
	},
	diamond = {
		name = "Diamond Crate",
		image = "rbxassetid://96169247372637",
		weight = 1e7,
		cost = 100e3,
		openTime = 35,
	},
}

local totalWeight = 0
for _, crate in crates do
	totalWeight += crate.weight
end

local sortedCrates = {}
for crateId, crate in crates do
	crate.id = crateId
	crate.odds = crate.weight / totalWeight
	table.insert(sortedCrates, { id = crateId, weight = crate.weight })
end
table.sort(sortedCrates, function(a, b)
	return a.weight > b.weight
end)

for i, crate in sortedCrates do
	crates[crate.id].layoutOrder = i
end

local Crates = {}

function Crates.rollCrateId(luck: number): string
	local roll = math.random()
	local sum = 0
	for i = #sortedCrates, 1, -1 do
		local crate = sortedCrates[i]
		local chance = 1 - (1 - crates[crate.id].odds) ^ luck
		sum += chance
		if roll <= sum then
			return crate.id
		end
	end

	return sortedCrates[1].id
end

function Crates.getCrateInfo(crateId: string): CrateInfo
	assert(crates[crateId], "Invalid crate ID" .. crateId)
	return crates[crateId]
end

function Crates.getCrateModel(crateId: string): Model
	assert(crates[crateId], "Invalid crate ID" .. crateId)
	local model = ReplicatedStorage.Assets.Crates[crateId]:Clone()
	return model
end

return Crates
