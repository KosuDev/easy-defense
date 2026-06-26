-- InsetFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

export type InsetFrameProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	children: { any }?,
}

return function(props: InsetFrameProps)
	return create("ImageLabel")({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		Image = ImageIds.insetFrame,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(31, 33, 109, 99),
		BackgroundTransparency = 1,
		props.children,
	})
end
