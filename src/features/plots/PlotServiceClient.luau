local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlotSlice = require(script.Parent.PlotSlice)
local Networker = require(ReplicatedStorage.Packages.Networker)
local ErrorMessage = require(ReplicatedStorage.Source.Core.UI.Components.ErrorMessage)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local Screen = require(ReplicatedStorage.Source.Features.App.UI.Screens.Screen)
local PlotClient = require(ReplicatedStorage.Source.Features.Plots.Classes.PlotClient)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)

local PlotServiceClient = {}

function PlotServiceClient.init(self: PlotServiceClient)
	self.networker = Networker.client.new("PlotService", self)
	self.plots = {}
end

function PlotServiceClient.initPlot(self: PlotServiceClient, plotData: PlotTypes.PlotData)
	local plot = PlotClient.new(plotData)
	self.plots[plot.index] = plot
end

function PlotServiceClient.getPlot(self: PlotServiceClient, index: number): PlotClient.PlotClient?
	return self.plots[index]
end

function PlotServiceClient.getLocalPlot(self: PlotServiceClient): PlotClient.PlotClient?
	local player = Players.LocalPlayer
	for _, plot in self.plots do
		if plot.player == player then
			return plot
		end
	end
	return nil
end

function PlotServiceClient.removePlot(self: PlotServiceClient, index: number)
	local plot = self.plots[index]
	if plot then
		plot:destroy()
	end
	self.plots[index] = nil
end

function PlotServiceClient.rebirth(self: PlotServiceClient)
	local result, msg = self.networker:fetch("rebirth")
	print(result, msg)
	if result then
		Menu.setOpenedMenu(nil)
		Screen.setOpenedScreen("RebirthReward")
		PlotSlice.states.rebirthReward(result)
	else
		ErrorMessage.add(msg)
	end
end

function PlotServiceClient.requestUpgrade(self: PlotServiceClient, floor: number, node: number)
	local plot = self:getLocalPlot()
	if not plot then
		return
	end

	plot.networker:fire("requestUpgrade", floor, node)
end

function PlotServiceClient.tpToBase(self: PlotServiceClient)
	self.networker:fire("tpToBase")
end

type PlotServiceClient = typeof(PlotServiceClient) & {
	networker: Networker.Client,
	plots: { [number]: PlotClient.PlotClient },
}

return PlotServiceClient :: PlotServiceClient
