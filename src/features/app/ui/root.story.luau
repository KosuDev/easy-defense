local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local RootUI = require(script.Parent.RootUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

return function(parent)
	DataService:init(DataTemplate)
	local root = ReactRoblox.createRoot(parent)
	local app = e(RootUI)
	root:render(app)

	PlotSlice.actions.addCrate(workspace.TowerPlacement.TowerPlacement, {
		crateId = "gold",
		timeBuilt = workspace:GetServerTimeNow() - 1,
	})

	return function()
		root:unmount()
	end
end
