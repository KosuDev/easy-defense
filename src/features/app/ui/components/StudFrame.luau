-- StudFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local ColorTweaker = require(ReplicatedStorage.Source.Core.Platform.ColorTweaker)

local create = Vide.create

export type StudFrameProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	Gradient: ColorSequence,
	studColor: Color3?,
	children: { any }?,
}

return function(props: StudFrameProps)
	return create("Frame")({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),

		create("UIStroke")({
			Color = Color3.fromRGB(0, 0, 0),
			Thickness = 4,
			LineJoinMode = Enum.LineJoinMode.Miter,
		}),

		create("UIStroke")({
			Color = Color3.fromRGB(255, 255, 255),
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Thickness = 4,
			LineJoinMode = Enum.LineJoinMode.Miter,

			create("UIGradient")({
				Color = ColorTweaker.tweakColorSequence(
					props.Gradient,
					{ saturationBoost = 0.66, valueBoost = 2, primaryColor = ColorTweaker.enums.primaryColors.master }
				),
				Rotation = 90,
			}),
		}),

		create("UIGradient")({
			Color = props.Gradient,
			Rotation = 90,
		}),

		-- studs texture
		create("ImageLabel")({
			Image = "rbxassetid://12055407192",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(50, 50),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -8, 1, -8),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageColor3 = props.studColor,
			ZIndex = -1,
			ImageTransparency = 0.2,
		}),

		props.children,
	})
end
