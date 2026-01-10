local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MountUI = require(script.Parent.MountUI)

local DataService = require(ReplicatedStorage.Packages.DataService).client
DataService:init()
MountUI()
