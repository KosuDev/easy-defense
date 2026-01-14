local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

local e = React.createElement
local EQUIPPED_TRANSPARENCY = NumberSequence.new(0)
local DEFAULT_TRANSPARENCY = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(1, 0),
})

type ItemButtonStrokeProps = {
	equipped: boolean?,
	partData: any,
}

return function(props: ItemButtonStrokeProps)
	local tier = Tiers.getTierForOdds(0.5) --TODO use actual odds from itemData

	return e("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 2,
	}, {
		Gradient = e("UIGradient", {
			Color = tier.gradient,
			Rotation = 90,
			Transparency = if props.equipped then EQUIPPED_TRANSPARENCY else DEFAULT_TRANSPARENCY,
		}),
	})
end
