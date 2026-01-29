local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

function DataService:onPlayerInit(_player, data)
	data.currency = 10e9
	data.inventory.wooden.amt = 100
	--data.rebirths = 0
	data.conveyorLevel = 1
end

DataService:addPlayerRemovingCallback(function(_player, _data)
	print(_data)
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
