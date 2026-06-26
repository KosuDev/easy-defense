local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

return function(instance: GuiObject): () -> Vector2
	local absSize = Vide.source(instance.AbsoluteSize)

	local conn = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		absSize(instance.AbsoluteSize)
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return absSize
end
