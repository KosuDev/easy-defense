local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

DataService:init({
	template = DataTemplate,
	profileStoreIndex = "PRE",
	useMock = false,
	resetData = false,
	dontSave = false,
})

PlotServiceServer:init()
