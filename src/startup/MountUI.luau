local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Vide = require(ReplicatedStorage.Packages.Vide)
local TopBarButtons = require(ReplicatedStorage.Source.Features.App.UI.Hud.TopBarButtons)
local RootUI = require(ReplicatedStorage.Source.Features.App.UI.RootUI)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

return function()
	local container = Instance.new("ScreenGui")
	container.Name = "UI"
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.ClipToDeviceSafeArea = false
	container.Parent = playerGui

	Vide.mount(function()
		return RootUI()
	end, container)

	TopBarButtons()

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end
