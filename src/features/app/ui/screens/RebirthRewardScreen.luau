-- RebirthRewardScreen.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Screen = require(script.Parent.Screen)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local TransparentFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.TransparentFrame)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring

local create = Vide.create

local function RewardsFrame(rewards)
	local springValue, spring = useSpring(0, { frequency = 1.5, dampingRatio = 0.5 })
	spring:setGoal(1)

	local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			Screen.setOpenedScreen(nil)
			PlotSlice.states.rebirthReward(nil)
		end
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = function()
			return UDim2.fromScale(1.25, springValue() * 0.25)
		end,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Rotation = function()
			return -5 * springValue()
		end,

		TextLabel({
			Text = "Tap to continue!",
			Size = UDim2.fromScale(0.3, 0.33),
			Position = UDim2.fromScale(0.5, 1.05),
			AnchorPoint = Vector2.new(0.5, 0),
			Stroke = { Thickness = 4 },
			ZIndex = 2,
		}),

		create("Frame")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),

			create("UIListLayout")({
				Padding = UDim.new(0, 20),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			TransparentFrame({
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 2,

				children = {
					TextLabel({
						Text = "Tower Slot",
						Size = UDim2.fromScale(1.1, 0.3),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0),
						ZIndex = 2,
						Stroke = {},
						Gradient = {
							Rotation = 90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 255)),
							}),
						},
					}),

					TextLabel({
						Text = "+" .. rewards.towerSlots,
						Size = UDim2.fromScale(1, 0.3),
						Position = UDim2.fromScale(0.5, 0.95),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Stroke = { Thickness = 3 },
						ZIndex = 2,
					}),

					create("ImageLabel")({
						Size = UDim2.fromScale(0.9, 0.9),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = ImageIds.extraSlot,
					}),
				},
			}),

			TransparentFrame({
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 1,

				children = {
					TextLabel({
						Text = "+10%",
						Size = UDim2.fromScale(1, 0.3),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0),
						ZIndex = 2,
						Stroke = {},
						Gradient = {
							Rotation = 90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
							}),
						},
					}),

					TextLabel({
						Text = "Money Bonus",
						Size = UDim2.fromScale(1, 0.25),
						Position = UDim2.fromScale(0.5, 1),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Stroke = { Thickness = 2 },
						ZIndex = 2,
					}),

					create("ImageLabel")({
						Size = UDim2.fromScale(0.9, 0.9),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = ImageIds.currency,
					}),
				},
			}),
		}),
	})
end

return function()
	local rewards = VideCharm.useSignalState(PlotSlice.states.rebirthReward)

	return function()
		if not rewards() then
			return nil
		end
		return RewardsFrame(rewards())
	end
end
