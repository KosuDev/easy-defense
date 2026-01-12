local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local CrateBillboards = require(ReplicatedStorage.Source.Features.Plots.UI.Screens.CrateBillboards)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		CrateBillboards = e(CrateBillboards),
	})
end
