local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local React = require(ReplicatedStorage.Packages.React)
local FormatCurrency = require(ReplicatedStorage.Source.Core.UI.FormatCurrency)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local e = React.createElement

local CURRENCY_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
})

local function CurrencyCounter()
	local txt, setTxt = React.useBinding(FormatCurrency(DataService:get("currency")))
	React.useEffect(function()
		local goal: number = math.round(DataService:get("currency"))
		local current: number = goal
		local updateConn
		local changedConn = DataService:getChangedSignal("currency"):Connect(function(newGoal: number)
			goal = math.round(newGoal)
			if updateConn then
				return
			end

			updateConn = RunService.Heartbeat:Connect(function(dt: number)
				local dist = goal - current
				local speed = if dist < 0 then 4 else 2
				current = math.lerp(current, goal, dt * speed)

				if math.abs(dist) < 1 then
					current = goal
					updateConn:Disconnect()
					updateConn = nil
				end

				setTxt(FormatCurrency(current))
			end)
		end)

		return function()
			changedConn:Destroy()
			if updateConn then
				updateConn:Disconnect()
			end
		end
	end, {})

	return e(TextLabel, {
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
	local percent = 0

	return e(TextLabel, {
		Text = `Friend Boost +{math.round(percent * 100)}%`,
		Size = UDim2.fromOffset(400, 40),
		Position = UDim2.new(0, 5, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Stroke = { Thickness = 3 },
	})
end

return function()
	return e("Frame", {
		Size = UDim2.new(0.99, -6, 0, 90),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		BackgroundTransparency = 1,
	}, {
		CurrencyCounter = e(CurrencyCounter),
		FriendBoostCounter = e(FriendBoostCounter),
	})
end
