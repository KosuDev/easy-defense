local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Screen = require(script.Parent.Screen)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local TransparentFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.TransparentFrame)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

local function RewardsFrame()
	local rewards = ReactCharm.useAtom(PlotSlice.states.rebirthReward)
	React.useEffect(function()
		local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if
				input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1
			then
				Screen.setOpenedScreen(nil)
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return e(React.Fragment, nil, {
		Layout = e("UIListLayout", {
			Padding = UDim.new(0, 20),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Slots = e(TransparentFrame, {
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 2,
		}, {
			Currency = e(TextLabel, {
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

			Text = e(TextLabel, {
				Text = "+" .. rewards.towerSlots,
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0.5, 0.95),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 3 },
				ZIndex = 2,
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = ImageIds.extraSlot,
			}),
		}),

		CurrencyMult = e(TransparentFrame, {
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 1,
		}, {
			Currency = e(TextLabel, {
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

			Text = e(TextLabel, {
				Text = "Money Bonus",
				Size = UDim2.fromScale(1, 0.25),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 2 },
				ZIndex = 2,
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = ImageIds.currency,
			}),
		}),
	})
end

return function()
	local springBinding = Screen.useScreenSpring("RebirthReward")

	return e(Screen.Component, {
		screenName = "RebirthReward",
	}, {
		e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = springBinding:map(function(v)
				return UDim2.fromScale(1.25, v * 0.33)
			end),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Rotation = springBinding:map(function(v)
				return 15 * v
			end),
		}, e(RewardsFrame)),
	})
end
