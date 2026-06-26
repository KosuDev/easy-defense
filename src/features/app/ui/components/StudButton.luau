-- StudButton.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudBackground = require(script.Parent.StudBackground)

local create = Vide.create

export type StudButtonProps = {
	-- layout
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	SizeConstraint: Enum.SizeConstraint?,
	-- button
	hoverScale: number?,
	AutoButtonColor: boolean?,
	Activated: (() -> ())?,
	OnEnter: (() -> ())?,
	OnLeave: (() -> ())?,
	OnDown: (() -> ())?,
	OnUp: (() -> ())?,
	-- stud specific
	StudSize: number?,
	Text: string?,
	StrokeColor: Color3?,
	StrokeThickness: number?,
	StudGradient: ColorSequence?,
	children: { any }?,
}

local function StudButton(props: StudButtonProps)
	return Button({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		SizeConstraint = props.SizeConstraint,
		hoverScale = props.hoverScale or 1.1,
		AutoButtonColor = props.AutoButtonColor,
		Activated = props.Activated,
		OnEnter = props.OnEnter,
		OnLeave = props.OnLeave,
		OnDown = props.OnDown,
		OnUp = props.OnUp,

		children = {
			StudBackground({
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TileSize = if props.StudSize then UDim2.fromOffset(props.StudSize, props.StudSize) else nil,
				Size = UDim2.fromScale(1, 1),

				children = {
					create("UIGradient")({
						Rotation = 90,
						Color = props.StudGradient,
					}),
				},
			}),

			create("UIStroke")({
				Thickness = props.StrokeThickness or 3,
				Color = props.StrokeColor or Color3.new(0, 0, 0),
			}),

			if props.Text
				then TextLabel({
					Text = props.Text,
					Size = UDim2.fromScale(0.95, 0.7),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Stroke = {},
				})
				else nil,

			props.children,
		},
	})
end

local GREEN_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(108, 255, 71)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(51, 255, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 117, 4)),
})

local WHITE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
})

local BLUE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(71, 108, 255)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(10, 51, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 40, 117)),
})

local TEAL_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(71, 255, 216)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(10, 205, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 117, 157)),
})

local GOLD_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(255, 211, 108)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(255, 215, 57)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(201, 107, 0)),
})

local BLACK_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})

local PURPLE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(178, 71, 255)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(105, 10, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 4, 117)),
})

local RED_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(255, 71, 71)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(255, 10, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(117, 4, 4)),
})

local function withGradient(gradient: ColorSequence)
	return function(props: StudButtonProps)
		local merged = table.clone(props)
		merged.StudGradient = gradient
		return StudButton(merged)
	end
end

return {
	Component = StudButton,
	Green = withGradient(GREEN_GRADIENT),
	White = withGradient(WHITE_GRADIENT),
	Blue = withGradient(BLUE_GRADIENT),
	Gold = withGradient(GOLD_GRADIENT),
	Teal = withGradient(TEAL_GRADIENT),
	Purple = withGradient(PURPLE_GRADIENT),
	Black = withGradient(BLACK_GRADIENT),
	Red = withGradient(RED_GRADIENT),
}
