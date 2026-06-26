-- BottomBar.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local FormatCurrency = require(ReplicatedStorage.Source.Core.UI.FormatCurrency)
local FormatTime = require(ReplicatedStorage.Source.Core.UI.FormatTime)
local serverTimeAtom = require(ReplicatedStorage.Source.Core.UI.Hooks.serverTimeAtom)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local FriendServiceClient = require(ReplicatedStorage.Source.Features.Friends.FriendServiceClient)
local MutationEvents = require(ReplicatedStorage.Source.Features.Mutations.Modules.MutationEvents)
local MutationSlice = require(ReplicatedStorage.Source.Features.Mutations.MutationSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

local CURRENCY_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
})

local function CurrencyCounter()
	local txt = Vide.source(FormatCurrency(DataService:get("currency")))
	local goal = Vide.source(math.round(DataService:get("currency")))
	local current = Vide.source(goal())
	local updateConn: RBXScriptConnection? = nil

	local changedConn = DataService:getChangedSignal("currency"):Connect(function(newGoal: number)
		goal(math.round(newGoal))
		if updateConn then
			return
		end

		updateConn = RunService.Heartbeat:Connect(function(dt: number)
			local dist = goal() - current()
			local speed = if dist < 0 then 4 else 2
			current(math.lerp(current(), goal(), dt * speed))

			if math.abs(dist) < 1 then
				current(goal())
				if updateConn then
					updateConn:Disconnect()
					updateConn = nil
				end
			end

			txt(FormatCurrency(current()))
		end)
	end)

	Vide.cleanup(function()
		changedConn:Disconnect()
		if updateConn then
			updateConn:Disconnect()
		end
	end)

	return TextLabel({
		Text = txt,
		Size = UDim2.fromOffset(400, 56),
		Position = UDim2.fromOffset(5, 0),
		AnchorPoint = Vector2.new(0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Stroke = { Thickness = 3, Color = Color3.fromRGB(24, 55, 7) },
		Gradient = {
			Rotation = 90,
			Color = CURRENCY_GRADIENT,
		},
	})
end

local function FriendBoostCounter()
	local numFriends = VideCharm.useSignalState(FriendServiceClient.friendCount)

	return Button({
		hoverScale = 1,
		Size = UDim2.fromOffset(300, 40),
		Position = UDim2.new(0, 5, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Activated = function()
			SocialService:PromptGameInvite(Players.LocalPlayer)
		end,

		children = {
			TextLabel({
				Text = function()
					return `Friend Boost +{math.round(numFriends() * 10)}%`
				end,
				Size = UDim2.fromOffset(400, 40),
				TextXAlignment = Enum.TextXAlignment.Left,
				Stroke = { Thickness = 3 },
			}),
		},
	})
end

type EventTimerProps = {
	eventId: string,
	completionTime: number,
}

local function EventTimer(props: EventTimerProps)
	local serverTime = VideCharm.useSignalState(serverTimeAtom)
	local hovered = Vide.source(false)

	return Button({
		Image = ImageIds.mutations[props.eventId],
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Visible = function()
			return serverTime() < props.completionTime
		end,
		OnEnter = function()
			hovered(true)
		end,
		OnLeave = function()
			hovered(false)
		end,

		children = {
			TextLabel({
				Text = function()
					return FormatTime(math.max(0, props.completionTime - serverTime()))
				end,
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0.5, 0.9),
				AnchorPoint = Vector2.new(0.5, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
				Stroke = { Thickness = 3 },
			}),

			function()
				if not hovered() then
					return nil
				end
				return create("Frame")({
					Size = UDim2.fromOffset(200, 50),
					Position = UDim2.fromScale(0.8, 0),
					AnchorPoint = Vector2.new(1, 1),
					BackgroundColor3 = Color3.fromRGB(235, 242, 245),

					create("UICorner")({
						CornerRadius = UDim.new(0, 8),
					}),

					create("UIStroke")({
						Thickness = 2,
						Color = Color3.fromRGB(0, 0, 0),
					}),

					TextLabel({
						Text = MutationEvents.getEvent(props.eventId).description,
						Size = UDim2.fromScale(0.8, 0.8),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Stroke = { Thickness = 2 },
					}),
				})
			end,
		},
	})
end

local function EventTimers()
	local timers = VideCharm.useSignalState(MutationSlice.states.activeEvents)

	return create("Frame")({
		Size = UDim2.fromOffset(300, 70),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,

		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),

		function()
			local children = {}
			for eventId, completionTime in timers() do
				children[eventId] = EventTimer({
					eventId = eventId,
					completionTime = completionTime,
				})
			end
			return children
		end,
	})
end

return function()
	return AutoScaledFrame({
		Size = UDim2.fromOffset(1494, 90),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		BackgroundTransparency = 1,

		children = {
			CurrencyCounter(),
			FriendBoostCounter(),
			EventTimers(),
		},
	})
end
