local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemButtonStroke = require(script.Parent.ItemButtonStroke)
local React = require(ReplicatedStorage.Packages.React)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type ItemIconProps = {
	Size: UDim2?,
	Rotation: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	itemData: DataTemplate.ItemData,
	children: React.ReactNode?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	equipped: boolean?,
}

return function(props: ItemIconProps)
	local isTower = not props.itemData.crateId
	local info = if not isTower
		then Crates.getCrateInfo(props.itemData.crateId)
		else Towers.getTowerInfo(props.itemData.itemId)

	local iconSize = if isTower then UDim2.fromScale(1, 1) else UDim2.fromScale(0.9, 0.9)

	return e("Frame", {
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		BackgroundTransparency = props.BackgroundTransparency or 0.2,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(37, 38, 41),
		Rotation = props.Rotation,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		Icon = e("ImageLabel", {
			Image = info.image,
			Size = iconSize,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
		}),

		Background = e("ImageLabel", {
			Image = info.image,
			ImageTransparency = 0.7,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			Size = iconSize,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			BackgroundTransparency = 1,
			ZIndex = 0,
		}),

		Quantity = if props.itemData.amt
			then e(TextLabel, {
				Text = "x" .. props.itemData.amt,
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.95, 0.95),
				Size = UDim2.fromScale(0.66, 0.25),
				Stroke = {},
				ZIndex = 2,
			})
			else nil,

		Strength = if isTower
			then e(TextLabel, {
				Text = "💪 " .. Abbreviate(math.round(info.damage * info.firerate)),
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.95, 0.95),
				Size = UDim2.fromScale(0.9, 0.25),
				Stroke = {},
				ZIndex = 2,
				Gradient = {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 223, 93)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 121, 121)),
					}),
					Rotation = 90,
				},
			})
			else nil,

		Stroke = e(ItemButtonStroke, { equipped = props.equipped, partData = props.itemData }),
	}, props.children)
end
