-- ScreenRoot.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

local capturedScreens = {}
for _, module in script.Parent:GetChildren() do
	if module:IsA("ModuleScript") and module.Name ~= "Screen" and module ~= script then
		capturedScreens[module.Name] = require(module)
	end
end

return function()
	local children = {}
	for name, screenModule in capturedScreens do
		children[name] = screenModule()
	end
	return Vide.create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		children,
	})
end
