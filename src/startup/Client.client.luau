local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local LeaderboardServiceClient = require(ReplicatedStorage.Source.Features.Leaderboards.LeaderboardServiceClient)
local MutationsServiceClient = require(ReplicatedStorage.Source.Features.Mutations.MutationsServiceClient)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local MountUI = require(script.Parent.MountUI)

local DataService = require(ReplicatedStorage.Packages.DataService).client
DataService:init()
MountUI()

PlotServiceClient:init()
InventoryServiceClient:init()
MutationsServiceClient:init()
LeaderboardServiceClient:init()

-- Preload sounds

for _, sound in Sounds.misc do
	SoundController:Load(sound)
end
