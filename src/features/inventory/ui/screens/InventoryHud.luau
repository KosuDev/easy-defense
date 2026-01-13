local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local e = React.createElement

return function()
	local open = false
	local crates = useDataState("crates")

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.fromOffset(1000, 200),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 0.5,
	}, {
		Hotbar = e("Frame", {
			Size = UDim2.fromScale(1, 0.33),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
		}),

		Inventory = e("Frame", {
			Visible = open,
			Size = UDim2.fromScale(1, 0.6),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.67),
		}),

		OpenButton = e(Button, {
			Size = UDim2.fromOffset(150, 40),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 1,
			}),

			Text = e(TextLabel, {
				Text = "Open Backpack",
				Size = UDim2.fromScale(1, 0.7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Stroke = {},
			}),
		}),
	})
end
