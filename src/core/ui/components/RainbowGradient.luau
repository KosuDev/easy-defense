-- RainbowGradient.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Vide = require(ReplicatedStorage.Packages.Vide)

local RAINBOW_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
	ColorSequenceKeypoint.new(0.34, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.85, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
})

return function()
	local rotation = Vide.source(0)

	local conn = RunService.Heartbeat:Connect(function(dt)
		rotation((rotation() + dt * 15) % 360)
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return Vide.create("UIGradient")({
		Color = RAINBOW_GRADIENT,
		Rotation = rotation,
	})
end
