-- AutoScaledFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local useViewportSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useViewportSize)

local create = Vide.create

local STUDIO_SIZE = Vector2.new(1500, 803)

export type AutoScaledFrameProps = {
	ScaleFactor: number?,
	MinSize: Vector2?,
	Size: UDim2,
	Position: UDim2?,
	Rotation: number?,
	AnchorPoint: Vector2?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	children: { any }?,
}

return function(props: AutoScaledFrameProps)
	local viewportSize = useViewportSize()
	local minSize = props.MinSize or Vector2.zero
	local scaleFactor = props.ScaleFactor or 1

	local scale = Vide.source(scaleFactor)

	Vide.effect(function()
		local screenSize = viewportSize()
		local minScale = math.max(minSize.X / props.Size.X.Offset, minSize.Y / props.Size.Y.Offset)
		local newScale = scaleFactor * math.min(screenSize.X / STUDIO_SIZE.X, screenSize.Y / STUDIO_SIZE.Y)
		scale(math.max(newScale, minScale))
	end)

	return create("Frame")({
		Visible = props.Visible,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Rotation = props.Rotation,
		ZIndex = props.ZIndex,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		LayoutOrder = props.LayoutOrder,

		create("UIScale")({
			Scale = scale,
		}),

		props.children,
	})
end
