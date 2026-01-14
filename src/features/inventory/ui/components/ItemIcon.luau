local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type ItemIconProps = {
	Size: UDim2?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	itemData: DataTemplate.ItemData,
	children: React.ReactNode?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
}

return function(props: ItemIconProps)
	local info = if props.itemData.crateId then Crates.getCrateInfo(props.itemData.crateId) else {} :: any

	return e("Frame", {
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		BackgroundTransparency = props.BackgroundTransparency or 0.2,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(37, 38, 41),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		Icon = e("ImageLabel", {
			Image = info.image,
			Size = UDim2.fromScale(0.9, 0.9),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
		}),

		Quantity = if props.itemData.amt
			then e(TextLabel, {
				Text = "x" .. props.itemData.amt,
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.95, 0.95),
				Size = UDim2.fromScale(0.66, 0.25),
				Stroke = {},
			})
			else nil,
	}, props.children)
end
