-- RootUI.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local ErrorMessage = require(ReplicatedStorage.Source.Core.UI.Components.ErrorMessage)
local NotificationMessage = require(ReplicatedStorage.Source.Core.UI.Components.NotificationMessage)
local Notifications = require(ReplicatedStorage.Source.Features.Notifications.UI.Notifications)

local create = Vide.create

local capturedRoots = {}
for _, module in ReplicatedStorage.Source.Features:GetDescendants() do
	if module:IsA("ModuleScript") and module.Name:match("Root") and module ~= script then
		capturedRoots[module.Name] = require(module)
	end
end

local function RootUI()
	local children = {}

	for name, rootModule in capturedRoots do
		children[name] = rootModule()
	end

	children.ErrorMessage = ErrorMessage.Component()
	children.NotificationMessage = NotificationMessage.Component()
	children.Notifications = Notifications.Screen()

	return create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		children,
	})
end

return RootUI
