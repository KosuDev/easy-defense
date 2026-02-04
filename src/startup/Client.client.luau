local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local MutationsServiceClient = require(ReplicatedStorage.Source.Features.Mutations.MutationsServiceClient)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local MountUI = require(script.Parent.MountUI)

local DataService = require(ReplicatedStorage.Packages.DataService).client
DataService:init()
MountUI()

PlotServiceClient:init()
InventoryServiceClient:init()
MutationsServiceClient:init()
