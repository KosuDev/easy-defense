local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Mutations = DataTemplate.Mutations

local MUTATION_EVENT_CHANCE = 0.04
local GOLD_MUTATION_CHANCE = 1 / 25
local DIAMOND_MUTATION_CHANCE = 1 / 250

local MutationServiceUtils = {}

function MutationServiceUtils.rollMutations(activeEvents: { string }, luck: number): Mutations?
	local mutations = {}

	for _, eventName in activeEvents do
		local roll = math.random()
		local chance = 1 - (1 - MUTATION_EVENT_CHANCE) ^ luck
		if roll < chance then
			mutations[eventName] = true
		end
	end

	local diamondChance = 1 - (1 - DIAMOND_MUTATION_CHANCE) ^ luck
	local goldChance = 1 - (1 - GOLD_MUTATION_CHANCE) ^ luck
	if math.random() < diamondChance then
		mutations.diamond = true
	elseif math.random() < goldChance then
		mutations.gold = true
	end

	if next(mutations) == nil then
		return nil
	end

	return mutations
end

return MutationServiceUtils
