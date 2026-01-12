local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local MountUI = require(script.Parent.MountUI)

local DataService = require(ReplicatedStorage.Packages.DataService).client
DataService:init()
MountUI()

PlotServiceClient:init()
