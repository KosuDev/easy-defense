local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local AutoRejoinServiceClient = require(ReplicatedStorage.Source.Features.AutoRejoin.AutoRejoinServiceClient)
local CodeServiceClient = require(ReplicatedStorage.Source.Features.Codes.CodeServiceClient)
local FriendServiceClient = require(ReplicatedStorage.Source.Features.Friends.FriendServiceClient)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local LeaderboardServiceClient = require(ReplicatedStorage.Source.Features.Leaderboards.LeaderboardServiceClient)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MutationsServiceClient = require(ReplicatedStorage.Source.Features.Mutations.MutationsServiceClient)
local NotificationServiceClient = require(ReplicatedStorage.Source.Features.Notifications.NotificationServiceClient)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local TutorialServiceClient = require(ReplicatedStorage.Source.Features.Tutorial.TutorialServiceClient)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local MountUI = require(script.Parent.MountUI)

local DataService = require(ReplicatedStorage.Packages.DataService).client
DataService:init()
MountUI()

MonetizationServiceClient:init(Products)
CodeServiceClient:init()
PlotServiceClient:init()
InventoryServiceClient:init()
MutationsServiceClient:init()
LeaderboardServiceClient:init()
AutoRejoinServiceClient:init()
NotificationServiceClient:init()
FriendServiceClient:init()
TutorialServiceClient:init()

SoundService:WaitForChild("Music"):Play()

-- Preload sounds
for _, sound in Sounds.misc do
	SoundController:Load(sound)
end

local mouse = Players.LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
	if not mouse.Target then
		print("NONE")
	end
	print(mouse.Target:GetFullName())
end)
