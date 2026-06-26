-- MenuRoot.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

local capturedMenus = {}
for _, module in script.Parent:GetChildren() do
	if module:IsA("ModuleScript") and module.Name ~= "Menu" and module ~= script then
		capturedMenus[module.Name] = require(module)
	end
end

return function()
	local children = {}
	for name, menuModule in capturedMenus do
		children[name] = menuModule()
	end
	return Vide.create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		children,
	})
end
