-- root.story.luau
-- Used for UI previewing in Hoarcekat or similar story tools.
-- Mounts the full UI tree into a given parent for development previewing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local DataService = require(ReplicatedStorage.Packages.DataService).client
local RootUI = require(script.Parent.RootUI)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

return function(parent: Instance)
	DataService:init(DataTemplate)
	MonetizationServiceClient:init(Products)

	local unmount = Vide.mount(function()
		return RootUI()
	end, parent)

	local menuCleanup = Menu.init()
	Menu.setOpenedMenu("LikeMenu")

	return function()
		menuCleanup()
		unmount()
	end
end
