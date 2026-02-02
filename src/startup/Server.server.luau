local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local MutationServiceServer = require(ServerScriptService.Features.Mutations.MutationServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

function DataService:onPlayerInit(_player, data)
	print(data)
end

DataService:addPlayerRemovingCallback(function(_player, _data)
	print(_data)
end)

DataService:init({
	template = DataTemplate,
	profileStoreIndex = "PRE",
	useMock = false,
	resetData = true,
	dontSave = false,
})

PlotServiceServer:init()
InventoryServiceServer:init()
MutationServiceServer:init()
