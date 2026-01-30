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
	luck: number,
}

local crates = {
	wooden = {
		name = "Wooden Crate",
		image = "rbxassetid://92040501256272",
		weight = 1e9,
		cost = 100,
		openTime = 5,
		luck = 1,
	},
	wooden1 = {
		name = "Sturdy Crate",
		image = "rbxassetid://106355486794326",
		weight = 500e6,
		cost = 250,
		openTime = 5,
		luck = 2,
	},
	wooden2 = {
		name = "Carbon Crate",
		image = "rbxassetid://135070263716258",
		weight = 250e6,
		cost = 1e3,
		openTime = 5,
		luck = 4,
	},
	silver = {
		name = "Silver Crate",
		image = "rbxassetid://72492711846524",
		weight = 125e6,
		cost = 2.5e3,
		openTime = 10,
		luck = 8,
	},
	silver1 = {
		name = "Alloy Crate",
		image = "rbxassetid://70665389038956",
		weight = 62.5e6,
		cost = 5e3,
		openTime = 10,
		luck = 16,
	},
	silver2 = {
		name = "Cryo Crate",
		image = "rbxassetid://136054785134449",
		weight = 31.25e6,
		cost = 15e3,
		openTime = 10,
		luck = 32,
	},
	gold = {
		name = "Gold Crate",
		image = "rbxassetid://115551403938538",
		weight = 16e6,
		cost = 40e3,
		openTime = 20,
		luck = 64,
	},
	gold1 = {
		name = "Radiant Crate",
		image = "rbxassetid://88495801126575",
		weight = 8e6,
		cost = 95e3,
		openTime = 20,
		luck = 128,
	},
	gold2 = {
		name = "Ember Crate",
		image = "rbxassetid://90654635690164",
		weight = 4e6,
		cost = 205e3,
		openTime = 20,
		luck = 256,
	},
	diamond = {
		name = "Diamond Crate",
		image = "rbxassetid://96169247372637",
		weight = 2e6,
		cost = 500e3,
		openTime = 40,
		luck = 512,
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

local Crates = {
	crates = crates,
	sortedCrates = sortedCrates,
}

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
