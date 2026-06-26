-- PlayerPortrait.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

type PlayerPortraitProps = {
	userId: number?,
	Size: UDim2,
	Position: UDim2,
	StrokeColor: Color3?,
	SizeConstraint: Enum.SizeConstraint?,
	AnchorPoint: Vector2?,
}

return function(props: PlayerPortraitProps)
	local imageId = if props.userId
		then `https://www.roblox.com/headshot-thumbnail/image?userId={props.userId}&width=128&height=128&format=png`
		else ""

	return create("Frame")({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		SizeConstraint = props.SizeConstraint,
		BackgroundTransparency = 1,

		create("ImageLabel")({
			Size = UDim2.fromScale(0.8, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = imageId,
			ScaleType = Enum.ScaleType.Fit,

			create("UICorner")({
				CornerRadius = UDim.new(1, 0),
			}),
		}),

		create("UICorner")({
			CornerRadius = UDim.new(1, 0),
		}),

		create("UIStroke")({
			Color = props.StrokeColor or Color3.fromRGB(79, 79, 79),
			Thickness = 2,
		}),
	})
end
