export type TierData = {
	name: string,
	odds: number,
	gradient: ColorSequence,
	tierId: string,
}

local tiers = {
	common = {
		name = "Common",
		odds = 1,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
		}),
	},

	uncommon = {
		name = "Uncommon",
		odds = 1 / 10,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(172, 255, 134)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 0)),
		}),
	},
}

local sortedTiers = {}
for tierId, tierData in tiers do
	tierData.tierId = tierId
	table.insert(sortedTiers, { tierId = tierId, data = tierData })
end
table.sort(sortedTiers, function(a, b)
	return a.data.odds > b.data.odds
end)

local Tiers = {}

function Tiers.getTierForOdds(odds: number): TierData
	for i = #sortedTiers, 1, -1 do
		local tier = sortedTiers[i]
		if odds <= tier.data.odds then
			return tier.data
		end
	end

	return sortedTiers[1].data
end

function Tiers.getTierData(tierId: string): TierData
	return tiers[tierId]
end

return Tiers
