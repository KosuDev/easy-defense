local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local DefenseSlice = require(ReplicatedStorage.Source.Features.Defense.DefenseSlice)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)
local e = React.createElement

type TowerBillboardProps = {
	root: BasePart,
	forcedParent: Instance?,
	towerData: DataTemplate.TowerData,
}

local function TowerBillboard(props: TowerBillboardProps)
	local towerInfo = Towers.getTowerInfo(props.towerData.itemId)
	local tier = Tiers.getTierForOdds(towerInfo.odds)
	local dps = Abbreviate(towerInfo.damage * towerInfo.firerate)

	local localBillboardGui = e("BillboardGui", {
		LightInfluence = 0,
		Adornee = props.root,
		StudsOffsetWorldSpace = Vector3.new(0, 6, 0),
		Size = UDim2.fromScale(7, 3.5),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
		}),

		TowerName = e(TextLabel, {
			Text = towerInfo.name,
			Size = UDim2.fromScale(1, 0.35),
			LayoutOrder = 1,
			Stroke = { Thickness = 0.1, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
		}),

		Rarity = e(TextLabel, {
			Text = tier.name,
			Gradient = { Color = tier.gradient, Rotation = 90 },
			Size = UDim2.fromScale(1, 0.3),
			LayoutOrder = 2,
			Stroke = { Thickness = 0.1, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
		}),

		Dps = e(TextLabel, {
			Text = "💪 " .. dps,
			Gradient = {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 223, 93)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 121, 121)),
				}),
				Rotation = 90,
			},
			Size = UDim2.fromScale(1, 0.3),
			LayoutOrder = 3,
			Stroke = { Thickness = 0.1, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
		}),
	})

	if props.forcedParent then
		return e(React.Fragment, nil, ReactRoblox.createPortal(localBillboardGui, props.forcedParent))
	end

	return localBillboardGui
end

return function()
	local towersData = ReactCharm.useAtom(DefenseSlice.states.towers)
	local towers = {}
	for root, towerUiData in towersData do
		towers[root] = e(TowerBillboard, {
			root = root,
			forcedParent = towerUiData.forcedParent,
			towerData = towerUiData.towerData,
		})
	end

	return towers
end
