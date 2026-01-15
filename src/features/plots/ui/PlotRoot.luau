local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local CrateTimers = require(ReplicatedStorage.Source.Features.Plots.UI.Screens.CrateTimers)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		CrateTimer = e(CrateTimers),
	})
end
