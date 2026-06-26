-- useDeviceInput.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Vide = require(ReplicatedStorage.Packages.Vide)

return function(): () -> Enum.UserInputType
	local currentInput = Vide.source(UserInputService.PreferredInput)

	local conn = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		currentInput(UserInputService.PreferredInput)
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return currentInput
end
