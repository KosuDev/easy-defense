-- ErrorMessage.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Vide = require(ReplicatedStorage.Packages.Vide)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring
local create = Vide.create

local getErrors, setErrors = Charm.signal({} :: { [number]: string })
local id = 0

type ErrorMessageProps = {
	i: number,
	message: string,
}

local function ErrorMessage(props: ErrorMessageProps)
	local size, spring = useSpring(UDim2.fromScale(0, 0), { frequency = 2.5, dampingRatio = 1 })
	spring:setGoal(UDim2.fromScale(1, 1))

	local thread = task.delay(3, function()
		spring:setGoal(UDim2.fromScale(0, 0))
		spring:onComplete(function()
			setErrors(function(current)
				return Sift.Dictionary.removeKey(current, props.i)
			end)
		end)
	end)

	Vide.cleanup(function()
		task.cancel(thread)
	end)

	return create("Frame")({
		LayoutOrder = props.i,
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
			Text = props.message,
			Size = UDim2.fromScale(1, 1),
			TextColor3 = Color3.fromRGB(255, 0, 0),
			BackgroundTransparency = 1,
			TextScaled = true,

			create("UIStroke")({
				Color = Color3.fromRGB(87, 0, 0),
				Thickness = 2,
			}),
		}),
	})
end

local function Component()
	return create("Frame")({
		Size = UDim2.new(0.55, 0, 0, 30),
		Position = UDim2.fromScale(0.5, 0.7),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		ZIndex = 2 ^ 31 - 1,

		Charm.observe(getErrors, function(message, i)
			return ErrorMessage({ i = i, message = message })
		end),

		create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 0),
		}),
	})
end

local function add(message: string)
	id += 1
	local currentId = id
	setErrors(function(current)
		return Sift.Dictionary.set(current, currentId, message)
	end)
end

return {
	Component = Component,
	add = add,
}
