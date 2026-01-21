local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BottomBar = require(script.Parent.BottomBar)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		BottomBar = e(BottomBar),
	})
end
