-- Notifications.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)

local create = Vide.create

type NotificationProps = {
	Image: string,
	Amount: number,
	id: string?,
}

local notificationId = 0
local getActiveNotifications, setActiveNotifications = Charm.signal({} :: { [string]: NotificationProps })

local function addNotification(props: NotificationProps)
	SoundController:Play(Sounds.ui.notification)
	notificationId += 1
	local id = tostring(notificationId)
	props.id = id
	setActiveNotifications(function(notifications)
		return Sift.Dictionary.set(notifications, id, props)
	end)
end

local function NotificationComponent(props: NotificationProps & { id: string })
	local size, spring = useSpring(UDim2.fromScale(0, 0), { frequency = 3, dampingRatio = 0.6 })
	spring:setGoal(UDim2.fromScale(1, 1))

	local thread = task.delay(5, function()
		spring:setGoal(UDim2.fromScale(0, 0))
		spring:onComplete(function()
			setActiveNotifications(function(notifications)
				return Sift.Dictionary.removeKey(notifications, props.id)
			end)
		end)
	end)

	Vide.cleanup(function()
		task.cancel(thread)
	end)

	return ShopFrame.Grey({
		Size = size,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		children = {
			create("ImageLabel")({
				Image = props.Image,
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}),

			TextLabel({
				Text = "x" .. Abbreviate(props.Amount),
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0.5, 0.85),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Color = Color3.new(0, 0, 0), Thickness = 2 },
			}),
		},
	})
end

local function Screen()
	local notifications = VideCharm.useSignalState(getActiveNotifications)

	return AutoScaledFrame({
		Size = UDim2.fromOffset(1000, 90),
		Position = UDim2.fromScale(0.5, 0.75),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 999999,

		children = {
			create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),

			function()
				local children = {}
				for id, props in notifications() do
					children[id] = NotificationComponent(props :: any)
				end
				return children
			end,
		},
	})
end

return {
	addNotification = addNotification,
	Screen = Screen,
}
