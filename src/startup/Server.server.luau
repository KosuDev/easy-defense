local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local _ProductServerCallbacks = require(ServerScriptService.Features.Monetization.Modules.ProductServerCallbacks)
local AutoRejoinServiceServer = require(ServerScriptService.Features.AutoRejoin.AutoRejoinServiceServer)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local LeaderboardServiceServer = require(ServerScriptService.Features.Leaderboards.LeaderboardServiceServer)
local MonetizationServiceServer = require(ServerScriptService.Features.Monetization.MonetizationServiceServer)
local MutationServiceServer = require(ServerScriptService.Features.Mutations.MutationServiceServer)
local NotificationServiceServer = require(ServerScriptService.Features.Notifications.NotificationServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

function DataService:onPlayerInit(_player, data)
	print(data)
	data.sessionStart = os.time()
	data.rebirths = 6
	data.currency = 0

	task.delay(3, function()
		InventoryServiceServer:addCrate(_player, {
			crateId = "luckyBlock1",
			amt = 1,
		})
	end)
end

DataService:addPlayerRemovingCallback(function(_player, data)
	local playTime = os.time() - data.sessionStart
	data.stats.timePlayed += playTime
	print(data)
end)

DataService:init({
	template = DataTemplate,
	profileStoreIndex = "PRE",
	useMock = false,
	resetData = false,
	dontSave = false,
})

MonetizationServiceServer:init({
	products = Products,
	canAwardGamepasses = true,
	freePassesGroupRank = 45,
	groupId = 15794692,
})

PlotServiceServer:init()
InventoryServiceServer:init()
MutationServiceServer:init()
LeaderboardServiceServer:init()
AutoRejoinServiceServer:init()
NotificationServiceServer:init()
