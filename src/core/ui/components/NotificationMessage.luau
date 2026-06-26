-- NotificationMessage.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Vide = require(ReplicatedStorage.Packages.Vide)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring
local create = Vide.create

type NotificationProps = {
	Text: string,
	TextColor3: Color3?,
	TextSize: number?,
}

local getMessages, setMessages = Charm.signal({} :: { [number]: NotificationProps })
local id = 0

type NotificationMessageProps = {
	i: number,
	props: NotificationProps,
}

local function NotificationMessage(props: NotificationMessageProps)
	local size, spring = useSpring(UDim2.fromScale(0, 0), { frequency = 2.5, dampingRatio = 1 })
	spring:setGoal(UDim2.fromScale(1, 1))

	local thread = task.delay(6, function()
		spring:setGoal(UDim2.fromScale(0, 0))
		spring:onComplete(function()
			setMessages(function(current)
				return Sift.Dictionary.removeKey(current, props.i)
			end)
		end)
	end)

	Vide.cleanup(function()
		task.cancel(thread)
	end)

	return create("Frame")({
		LayoutOrder = -props.i,
		Size = size,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.25,

		create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.33, 0.5),
				NumberSequenceKeypoint.new(0.66, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),

		create("TextLabel")({
			Text = props.props.Text,
			TextColor3 = props.props.TextColor3 or Color3.fromRGB(255, 255, 255),
			TextSize = props.props.TextSize,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextScaled = true,
		}),
	})
end

local function Component()
	return create("Frame")({
		Size = UDim2.new(0.55, 0, 0, 42),
		Position = UDim2.fromScale(0.5, 0.25),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 2 ^ 31 - 1,

		Charm.observe(getMessages, function(props, i)
			return NotificationMessage({ i = i, props = props })
		end),

		create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 0),
		}),
	})
end

local function add(props: NotificationProps)
	id += 1
	local currentId = id
	setMessages(function(current)
		return Sift.Dictionary.set(current, currentId, props)
	end)
end

return {
	Component = Component,
	add = add,
}
