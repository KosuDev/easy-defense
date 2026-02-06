local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local AutoRejoinServiceServer = require(ServerScriptService.Features.AutoRejoin.AutoRejoinServiceServer)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local LeaderboardServiceServer = require(ServerScriptService.Features.Leaderboards.LeaderboardServiceServer)
local MutationServiceServer = require(ServerScriptService.Features.Mutations.MutationServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

function DataService:onPlayerInit(_player, data)
	print(data)
	data.sessionStart = os.time()
	data.rebirths = 6
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

PlotServiceServer:init()
InventoryServiceServer:init()
MutationServiceServer:init()
LeaderboardServiceServer:init()
AutoRejoinServiceServer:init()
