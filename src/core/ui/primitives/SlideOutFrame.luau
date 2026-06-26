-- SlideOutFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring
local AutoScaledFrame = require(script.Parent.AutoScaledFrame)

type SlideOutFrameProps = {
	-- inherited from AutoScaledFrame
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
	-- slide behavior
	Shown: boolean | () -> boolean,
	From: UDim2,
	To: UDim2,
	Frequency: number?,
	Damping: number?,
	children: { any }?,
}

return function(props: SlideOutFrameProps)
	local function getShown(): boolean
		if type(props.Shown) == "function" then
			return (props.Shown :: () -> boolean)()
		end
		return props.Shown
	end

	local shown = Vide.source(getShown())

	Vide.effect(function()
		shown(getShown())
	end)
	local mounted = Vide.source(props.Shown)
	local pos, spring = useSpring(
		if props.Shown then props.From else props.To,
		{ frequency = props.Frequency or 5, dampingRatio = props.Damping or 0.8 }
	)

	Vide.effect(function()
		if shown() then
			-- slide in
			if not mounted() then
				mounted(true)
				return
			end
			spring:setPosition(props.To)
			spring:setGoal(props.From)
		else
			-- slide out then unmount
			spring:setGoal(props.To)
			spring:onComplete(function()
				if not shown() then
					mounted(false)
				end
			end)
		end
	end)

	-- update shown when prop changes
	Vide.effect(function()
		shown(props.Shown)
	end)

	return function()
		if not mounted() then
			return nil
		end

		return AutoScaledFrame({
			ScaleFactor = props.ScaleFactor,
			MinSize = props.MinSize,
			Size = props.Size,
			Position = pos,
			Rotation = props.Rotation,
			AnchorPoint = props.AnchorPoint,
			BackgroundTransparency = props.BackgroundTransparency,
			BackgroundColor3 = props.BackgroundColor3,
			LayoutOrder = props.LayoutOrder,
			ZIndex = props.ZIndex,
			Visible = props.Visible,
			children = props.children,
		})
	end
end
