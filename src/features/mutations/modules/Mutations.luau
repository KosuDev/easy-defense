local mutations = {
	gold = {
		name = "Gold",
		description = "Increases damage",
		value = 1,
	},

	diamond = {
		name = "Diamond",
		description = "Greatly increases damage",
		value = 2,
	},
}

local mutationValues = {}
for key, mutation in mutations do
	assert(mutation.value ~= nil, "Mutation must have a value")
	assert(
		mutationValues[mutation.value] == nil,
		"Duplicate mutation value: " .. mutation.value .. " for mutation " .. key
	)
	mutationValues[mutation.value] = key
end

local Mutations = {
	mutations = mutations,
	sortedMutations = mutationValues :: { string },
}

function Mutations.getByValue(value: number)
	return mutations[mutationValues[value]]
end

return Mutations
