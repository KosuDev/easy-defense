-- ShopContentFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)

local create = Vide.create

type ShopContentFrameProps = {
	Padding: number?,
	Text: string,
	children: { any }?,
	LayoutOrder: number,
}

return function(props: ShopContentFrameProps)
	return create("Frame")({
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,

		create("UIListLayout")({
			Padding = UDim.new(0, 16),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Wraps = true,
		}),

		create("UIPadding")({
			PaddingTop = UDim.new(0, props.Padding or 0),
		}),

		TextLabel({
			Text = props.Text,
			Size = UDim2.new(1, 0, 0, 40),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			LayoutOrder = -2,
		}),

		props.children,
	})
end
