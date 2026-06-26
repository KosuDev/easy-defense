-- TextLabel.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

type Stroke = {
	Thickness: number?,
	Color: Color3?,
	Transparency: number?,
	StrokeSizingMode: Enum.StrokeSizingMode?,
}

type DropShadow = {
	Offset: UDim2?,
	Color: Color3?,
	Transparency: number?,
}

type Gradient = {
	Color: ColorSequence?,
	Transparency: NumberSequence?,
	Rotation: number?,
}

type TextImage = {
	Image: string?,
	Size: UDim2?,
	HorizontalAlignment: Enum.HorizontalAlignment?,
	VerticalAlignment: Enum.VerticalAlignment?,
	Padding: UDim?,
	SizeConstraint: Enum.SizeConstraint?,
	ImageColor3: Color3?,
	ImageTransparency: number?,
}

export type TextLabelProps = {
	-- frame
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	Rotation: number?,
	SizeConstraint: Enum.SizeConstraint?,
	AutomaticSize: Enum.AutomaticSize?,
	-- text
	Text: (string | () -> string)?,
	TextColor3: Color3?,
	TextSize: number?,
	TextTransparency: number?,
	Font: Enum.Font?,
	TextScaled: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
	TextWrapped: boolean?,
	RichText: boolean?,
	-- extras
	Stroke: Stroke?,
	DropShadow: DropShadow?,
	Gradient: Gradient?,
	Prefix: TextImage?,
	Suffix: TextImage?,
	children: { any }?,
}

local STROKE_DEFAULTS = {
	Thickness = 2,
	Color = Color3.fromRGB(0, 0, 0),
	Transparency = 0,
}

local DROP_SHADOW_DEFAULTS = {
	Offset = UDim2.fromOffset(0, 4),
	Color = Color3.fromRGB(0, 0, 0),
	Transparency = 0,
}

return function(props: TextLabelProps)
	local stroke = props.Stroke
	local dropShadow = props.DropShadow
	local gradient = props.Gradient
	local prefix = props.Prefix
	local suffix = props.Suffix
	local hasPrefixOrSuffix = prefix ~= nil or suffix ~= nil

	return create("Frame")({
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		Rotation = props.Rotation,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,

		-- main text label
		create("TextLabel")({
			Text = props.Text,
			TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
			TextSize = props.TextSize,
			TextScaled = if props.TextSize then false else (props.TextScaled ~= false),
			Font = props.Font or Enum.Font.BuilderSansExtraBold,
			TextTransparency = props.TextTransparency,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextWrapped = props.TextWrapped,
			RichText = props.RichText,
			AutomaticSize = props.AutomaticSize or (if hasPrefixOrSuffix then Enum.AutomaticSize.X else nil),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = if hasPrefixOrSuffix then UDim2.fromScale(0, 1) else UDim2.fromScale(1, 1),
			ZIndex = 1,
			LayoutOrder = 1,

			if stroke
				then create("UIStroke")({
					Thickness = stroke.Thickness or STROKE_DEFAULTS.Thickness,
					Color = stroke.Color or STROKE_DEFAULTS.Color,
					Transparency = stroke.Transparency or STROKE_DEFAULTS.Transparency,
					StrokeSizingMode = stroke.StrokeSizingMode,
				})
				else nil,

			if gradient
				then create("UIGradient")({
					Color = gradient.Color,
					Transparency = gradient.Transparency,
					Rotation = gradient.Rotation,
				})
				else nil,

			props.children,
		}),

		-- drop shadow
		if dropShadow
			then create("TextLabel")({
				Text = props.Text,
				TextColor3 = dropShadow.Color or DROP_SHADOW_DEFAULTS.Color,
				TextSize = props.TextSize,
				TextScaled = if props.TextSize then false else (props.TextScaled ~= false),
				Font = props.Font or Enum.Font.BuilderSansExtraBold,
				TextTransparency = dropShadow.Transparency or DROP_SHADOW_DEFAULTS.Transparency,
				TextXAlignment = props.TextXAlignment,
				TextYAlignment = props.TextYAlignment,
				TextWrapped = props.TextWrapped,
				RichText = props.RichText,
				Position = UDim2.fromScale(0.5, 0.5) + (dropShadow.Offset or DROP_SHADOW_DEFAULTS.Offset),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 0,
			})
			else nil,

		-- prefix icon
		if prefix
			then create("ImageLabel")({
				BackgroundTransparency = 1,
				Size = prefix.Size or UDim2.fromScale(1, 1),
				SizeConstraint = prefix.SizeConstraint or Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 0,
				ScaleType = Enum.ScaleType.Fit,
				Image = prefix.Image or "",
				ImageColor3 = prefix.ImageColor3,
				ImageTransparency = prefix.ImageTransparency,
			})
			else nil,

		-- suffix icon
		if suffix
			then create("ImageLabel")({
				BackgroundTransparency = 1,
				Size = suffix.Size or UDim2.fromScale(1, 1),
				SizeConstraint = suffix.SizeConstraint or Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 2,
				ScaleType = Enum.ScaleType.Fit,
				Image = suffix.Image or "",
				ImageColor3 = suffix.ImageColor3,
				ImageTransparency = suffix.ImageTransparency,
			})
			else nil,

		-- layout for prefix/suffix
		if hasPrefixOrSuffix
			then create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = (prefix and prefix.HorizontalAlignment)
					or (suffix and suffix.HorizontalAlignment)
					or Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = (prefix and prefix.Padding) or (suffix and suffix.Padding) or UDim.new(0, 4),
			})
			else nil,
	})
end
