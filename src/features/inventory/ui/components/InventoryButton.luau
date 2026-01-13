local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local e = React.createElement

type InventoryButtonProps = {
	Size: UDim2,
}

return function(props: InventoryButtonProps)
	local active = false

	return e(Button, {
		Size = props.Size,
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		BackgroundTransparency = 0.5,
	}, {
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 1,
		}),
	})
end
