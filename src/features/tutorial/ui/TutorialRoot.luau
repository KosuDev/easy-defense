-- TutorialRoot.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local TutorialInstructions = require(ReplicatedStorage.Source.Features.Tutorial.Modules.TutorialInstructions)

local create = Vide.create

return function()
	local completed = useDataState({ "tutorial", "completed" })
	local step = useDataState({ "tutorial", "step" })
	local size, spring = useSpring(0.5, { dampingRatio = 0.8, frequency = 1 })
	spring:setGoal(1)

	-- impulse spring whenever step changes
	Vide.effect(function()
		step() -- track step as dependency
		spring:impulse(5)
	end)

	return function()
		if completed() or not step() then
			return nil
		end

		local instruction = TutorialInstructions[step()]
		if not instruction or not instruction.text then
			return nil
		end

		return AutoScaledFrame({
			Size = UDim2.fromOffset(1000, 50),
			Position = UDim2.fromScale(0.5, 0.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 999,

			children = {
				create("Frame")({
					Size = function()
						local v = size()
						return UDim2.fromScale(v, v)
					end,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),

					create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.5, 0),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),

					TextLabel({
						Size = UDim2.fromScale(1, 0.8),
						Position = UDim2.fromScale(0, 0.5),
						AnchorPoint = Vector2.new(0, 0.5),
						Text = instruction.text:upper(),
						Stroke = {},
					}),
				}),
			},
		})
	end
end
