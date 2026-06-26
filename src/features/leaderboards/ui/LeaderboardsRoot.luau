-- LeaderboardsRoot.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local LeaderboardSlice = require(ReplicatedStorage.Source.Features.Leaderboards.LeaderboardSlice)
local LeaderboardSurfaceGui =
	require(ReplicatedStorage.Source.Features.Leaderboards.UI.Components.LeaderboardSurfaceGui)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

return function()
	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		-- swap out prefix images and gradients for your own game
		LeaderboardSurfaceGui({
			tag = "CrateLeaderboard",
			leaderboardData = LeaderboardSlice.states.crateRollsLeaderboard,
			prefix = {
				Image = "", -- replace with your own image
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			},
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 202, 87)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 26, 0)),
			}),
		}),

		LeaderboardSurfaceGui({
			tag = "KillsLeaderboard",
			leaderboardData = LeaderboardSlice.states.killsLeaderboard,
			prefix = {
				Image = "rbxassetid://135416232303660",
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			},
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 154, 154)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 30)),
			}),
		}),

		LeaderboardSurfaceGui({
			tag = "CurrencyLeaderboard",
			leaderboardData = LeaderboardSlice.states.currencyLeaderboard,
			prefix = {
				Image = ImageIds.currency,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			},
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(211, 255, 154)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 100, 0)),
			}),
		}),
	})
end
