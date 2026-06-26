-- useViewportSize.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

return function(): () -> Vector2
	local viewportSize = Vide.source(workspace.CurrentCamera.ViewportSize)

	local conn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		viewportSize(workspace.CurrentCamera.ViewportSize)
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return viewportSize
end
