-- ImageLabel.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

export type ImageLabelProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	Image: string?,
	ImageColor3: Color3?,
	ImageTransparency: number?,
	ImageRectOffset: Vector2?,
	ImageRectSize: Vector2?,
	ScaleType: Enum.ScaleType?,
	SliceCenter: Rect?,
	TileSize: UDim2?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	SizeConstraint: Enum.SizeConstraint?,
	children: { any }?,
}

return function(props: ImageLabelProps)
	return create("ImageLabel")({
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		Image = props.Image or "",
		ImageColor3 = props.ImageColor3,
		ImageTransparency = props.ImageTransparency,
		ImageRectOffset = props.ImageRectOffset,
		ImageRectSize = props.ImageRectSize,
		ScaleType = props.ScaleType,
		SliceCenter = props.SliceCenter,
		TileSize = props.TileSize,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		SizeConstraint = props.SizeConstraint,

		props.children,
	})
end
