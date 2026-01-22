local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

return function()
	return e(Menu.Component, {
		menuName = "RebirthMenu",
		Title = "Rebirth",
	})
end
