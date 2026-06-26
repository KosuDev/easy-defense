-- TopBar.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)

local create = Vide.create

local function Buttons()
	return create("Frame")({
		Size = UDim2.fromOffset(400, 50),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,

		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 20),
		}),

		Button({
			hoverScale = 1.1,
			Size = UDim2.fromScale(0.45, 1),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Activated = function()
				PlotServiceClient:tpToBase()
			end,

			children = {
				create("UIStroke")({
					Thickness = 2.5,
					Color = Color3.new(0, 0, 0),
				}),

				TextLabel({
					Text = "My Plot",
					Size = UDim2.fromScale(0.9, 0.75),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Stroke = { Thickness = 3, Color = Color3.fromRGB(11, 27, 46) },
					Gradient = {
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(151, 248, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 147, 255)),
						}),
					},
				}),
			},
		}),

		Button({
			hoverScale = 1.1,
			Size = UDim2.fromScale(0.45, 1),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			LayoutOrder = 2,
			Activated = function()
				PlotServiceClient:tpToSell()
			end,

			children = {
				create("UIStroke")({
					Thickness = 2.5,
					Color = Color3.new(0, 0, 0),
				}),

				TextLabel({
					Text = "Sell Towers",
					Size = UDim2.fromScale(0.9, 0.75),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Stroke = { Thickness = 3, Color = Color3.fromRGB(25, 46, 11) },
					Gradient = {
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(227, 255, 151)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 255, 14)),
						}),
					},
				}),
			},
		}),
	})
end

return function()
	return AutoScaledFrame({
		Size = UDim2.fromOffset(1400, 90),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		BackgroundTransparency = 1,

		children = { Buttons() },
	})
end
