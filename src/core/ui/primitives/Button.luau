-- Button.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring
local create = Vide.create

export type ButtonProps = {
	-- layout
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: (boolean | () -> boolean)?,
	-- image
	Image: string?,
	ImageColor3: Color3?,
	ImageTransparency: number?,
	ScaleType: Enum.ScaleType?,
	-- button behavior
	hoverScale: number?,
	AutoButtonColor: boolean?,
	-- callbacks
	Activated: (() -> ())?,
	OnEnter: (() -> ())?,
	OnLeave: (() -> ())?,
	OnDown: (() -> ())?,
	OnUp: (() -> ())?,
	-- children
	children: { any }?,
}

return function(props: ButtonProps)
	local hoverScale = props.hoverScale or 1.2
	local scale, spring = useSpring(1, { frequency = 5, dampingRatio = 0.7 })

	return create("ImageButton")({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		Image = props.Image or "",
		ImageColor3 = props.ImageColor3,
		ImageTransparency = props.ImageTransparency,
		ScaleType = props.ScaleType,
		BackgroundTransparency = 1,
		AutoButtonColor = props.AutoButtonColor or false,

		MouseEnter = function()
			SoundController:Play(Sounds.ui.hover)
			spring:setGoal(hoverScale)
			if props.OnEnter then
				props.OnEnter()
			end
		end,

		MouseLeave = function()
			spring:setGoal(1)
			if props.OnLeave then
				props.OnLeave()
			end
		end,

		MouseButton1Down = function()
			SoundController:Play(Sounds.ui.mouseDown)
			if props.OnDown then
				props.OnDown()
			end
		end,

		MouseButton1Up = function()
			SoundController:Play(Sounds.ui.mouseUp)
			if props.OnUp then
				props.OnUp()
			end
		end,

		Activated = props.Activated,

		create("UIScale")({
			Scale = scale,
		}),

		props.children,
	})
end
