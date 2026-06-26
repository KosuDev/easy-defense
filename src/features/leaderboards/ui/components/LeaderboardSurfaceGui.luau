-- LeaderboardSurfaceGui.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local useTag = require(ReplicatedStorage.Source.Core.UI.Hooks.useTag)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local LeaderboardServiceUtils = require(ReplicatedStorage.Source.Features.Leaderboards.LeaderboardServiceUtils)

local create = Vide.create

type EntryProps = {
	i: number,
	entry: LeaderboardServiceUtils.LeaderboardEntry,
	prefix: any,
	gradient: ColorSequence,
}

local function LeaderboardEntry(props: EntryProps)
	return create("Frame")({
		Size = UDim2.new(1, 0, 0, 90),
		BackgroundTransparency = 1,
		LayoutOrder = props.i,

		create("ImageLabel")({
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = props.entry.profileImageId,
			BackgroundTransparency = 1,

			TextLabel({
				Size = UDim2.fromScale(1, 0.33),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				Text = "#" .. props.i,
				TextXAlignment = Enum.TextXAlignment.Right,
				Stroke = {},
			}),
		}),

		TextLabel({
			Size = UDim2.fromScale(0.7, 0.5),
			Position = UDim2.fromOffset(100, 0),
			AnchorPoint = Vector2.new(0, 0),
			Text = props.entry.username,
			TextXAlignment = Enum.TextXAlignment.Left,
			Stroke = {},
		}),

		TextLabel({
			Size = UDim2.fromScale(0.7, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(1, 0),
			Text = Abbreviate(props.entry.value, 5),
			TextXAlignment = Enum.TextXAlignment.Left,
			Stroke = {},
			Prefix = props.prefix,
			Gradient = {
				Rotation = 90,
				Color = props.gradient,
			},
		}),
	})
end

type LeaderboardSurfaceGuiProps = {
	tag: string,
	leaderboardData: () -> LeaderboardServiceUtils.LeaderboardData,
	prefix: any,
	gradient: ColorSequence,
}

return function(props: LeaderboardSurfaceGuiProps)
	local leaderboardData = VideCharm.useSignalState(props.leaderboardData)
	local adornee = useTag(props.tag)

	return create("SurfaceGui")({
		Adornee = adornee,
		Face = Enum.NormalId.Left,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		MaxDistance = 400,
		LightInfluence = 0,

		create("ScrollingFrame")({
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.fromScale(0, 0),
			ScrollBarThickness = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),

			function()
				local children = {}
				for i, entry in leaderboardData() do
					children[i] = LeaderboardEntry({
						i = i,
						entry = entry,
						prefix = props.prefix,
						gradient = props.gradient,
					})
				end
				return children
			end,
		}),
	})
end
