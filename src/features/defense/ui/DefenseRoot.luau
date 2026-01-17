local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TowerBillboards = require(ReplicatedStorage.Source.Features.Defense.UI.Screens.TowerBillboards)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		TowerBillboard = e(TowerBillboards),
	})
end
