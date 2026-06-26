-- StudBackground.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

export type StudBackgroundProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	ImageColor3: Color3?,
	BackgroundColor3: Color3?,
	TileSize: UDim2?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	children: { any }?,
}

return function(props: StudBackgroundProps)
	return create("ImageLabel")({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ImageColor3 = props.ImageColor3,
		BackgroundColor3 = props.BackgroundColor3,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		Image = ImageIds.studBackground,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = props.TileSize or UDim2.fromOffset(100, 100),
		BorderSizePixel = 0,
		props.children,
	})
end
