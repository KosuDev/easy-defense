local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local e = React.createElement

local function CrateBillboard(props: { instance: Instance, crateData: any })
	return e("BillboardGui", {
		Adornee = props.instance,
		AlwaysOnTop = true,
		ExtentsOffsetWorldSpace = Vector3.new(0, 3, 0),
		Size = UDim2.fromScale(15, 5),
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Tier = e(TextLabel, {
			Text = "Legendary",
			Size = UDim2.fromScale(1, 0.36),
			LayoutOrder = 1,
			Stroke = {},
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
				}),
			},
		}),

		CrateName = e(TextLabel, {
			Text = "Crate Name",
			Size = UDim2.fromScale(1, 0.28),
			LayoutOrder = 2,
			Stroke = {},
		}),

		Cost = e(TextLabel, {
			Text = "$12,000,000",
			Size = UDim2.fromScale(1, 0.36),
			LayoutOrder = 3,
			Stroke = {},
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
				}),
			},
		}),
	})
end

return function()
	local crates = ReactCharm.useAtom(PlotSlice.state.crates)
	return e(
		React.Fragment,
		nil,
		Sift.Dictionary.map(crates, function(crateData, instance)
			return e(CrateBillboard, { instance = instance, crateData = crateData })
		end)
	)
end
