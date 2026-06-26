-- TransparentFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

local create = Vide.create

export type TransparentFrameProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	SizeConstraint: Enum.SizeConstraint?,
	Thickness: number?,
	StrokeColor: Color3?,
	children: { any }?,
}

return function(props: TransparentFrameProps)
	return create("Frame")({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		SizeConstraint = props.SizeConstraint,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),

		create("UIStroke")({
			Thickness = props.Thickness or 3,
			Color = props.StrokeColor or Color3.fromRGB(20, 20, 20),
		}),

		props.children,
	})
end
