local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

type SideBarButtonProps = {
	Position: UDim2,
	Text: string,
	Image: string,
	IconScale: number?,
	Activated: () -> (),
}

local function SideBarButton(props: SideBarButtonProps)
	local iconScale = props.IconScale or 1
	return e(Button, {
		hoverScale = 1.1,
		Size = UDim2.fromOffset(80, 80),
		Position = props.Position,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Activated = props.Activated,
	}, {
		Stroke = e("UIStroke", {
			Thickness = 2.5,
			Color = Color3.new(0, 0, 0),
		}),

		Title = e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(1, 0.275),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.975),
			Stroke = {},
			ZIndex = 2,
		}),

		Icon = e("ImageLabel", {
			Size = UDim2.fromScale(iconScale, iconScale),
			Position = UDim2.fromScale(0.5, 0.475),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.Image,
		}),
	})
end

return function()
	return e(AutoScaledFrame, {
		Size = UDim2.fromOffset(180, 800),
		Position = UDim2.fromScale(0.005, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	}, {
		Rebirth = e(SideBarButton, {
			Position = UDim2.fromScale(0.75, 0.5),
			Text = "Rebirth",
			IconScale = 0.925,
			Image = ImageIds.rebirth,
			Activated = function()
				Menu.setOpenedMenu("RebirthMenu")
			end,
		}),

		Index = e(SideBarButton, {
			Position = UDim2.fromScale(0.25, 0.5),
			Text = "Index",
			IconScale = 0.925,
			Image = ImageIds.index,
			Activated = function() end,
		}),
	})
end
