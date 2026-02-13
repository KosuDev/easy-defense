local CollectionService = game:GetService("CollectionService")
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

	local sellProx = CollectionService:GetTagged("SellMenuProx")[1] :: ProximityPrompt
	sellProx.Triggered:Connect(function()
		Menu.setOpenedMenu("SellMenu")
	end)

	task.spawn(function()
		while true do
			self:updatePlotReplication()
			task.wait(1)
		end
	end)
end

function PlotServiceClient.initPlot(self: PlotServiceClient, plotData: PlotTypes.PlotData)
	local existingPlot = self.plots[plotData.index]
	if existingPlot and existingPlot.player ~= plotData.player then
		print("Plot already exists, destroying old plot")
		existingPlot:destroy()
	end

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

function PlotServiceClient.tpToSell(self: PlotServiceClient)
	self.networker:fire("tpToSell")
end

function PlotServiceClient.tpToBase(self: PlotServiceClient)
	self.networker:fire("tpToBase")
end

local PLOT_SIZE = Vector3.new(120, 0, 175)
local BOUNDS_OFFSET = CFrame.new(0, 0, 65)

local function isWithinPlotBounds(plotCf: CFrame, position: Vector3): boolean
	local boundsCf = plotCf * BOUNDS_OFFSET
	local relativePos = boundsCf:PointToObjectSpace(position)
	return math.abs(relativePos.X) <= PLOT_SIZE.X / 2 and math.abs(relativePos.Z) <= PLOT_SIZE.Z / 2
end

function PlotServiceClient.updatePlotReplication(self: PlotServiceClient)
	local char = Players.LocalPlayer.Character
	if not char then
		return
	end

	local pos = char:GetPivot().Position
	for _, plot in self.plots do
		if plot.player == Players.LocalPlayer then
			continue
		end

		local withinBounds = isWithinPlotBounds(plot.cf, pos)
		plot:setReplication(withinBounds)
	end
end

type PlotServiceClient = typeof(PlotServiceClient) & {
	networker: Networker.Client,
	plots: { [number]: PlotClient.PlotClient },
}

return PlotServiceClient :: PlotServiceClient
