-- ShopFrame.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StudFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.StudFrame)

local GOLD = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 212, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 137, 27)),
})

local GREEN = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(69, 255, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 255, 27)),
})

local BLUE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 247, 255)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(69, 227, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 153, 255)),
})

local PURPLE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 192, 255)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 69, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 27, 255)),
})

local RED = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 192, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 69, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 27, 27)),
})

local ORANGE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 224, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 144, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 94, 27)),
})

local GREY = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(224, 224, 224)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(144, 144, 144)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 94, 94)),
})

local function withGradient(gradient: ColorSequence)
	return function(props)
		local merged = table.clone(props)
		merged.Gradient = gradient
		return StudFrame(merged)
	end
end

return {
	Gold = withGradient(GOLD),
	Green = withGradient(GREEN),
	Blue = withGradient(BLUE),
	Purple = withGradient(PURPLE),
	Red = withGradient(RED),
	Orange = withGradient(ORANGE),
	Grey = withGradient(GREY),
}
