local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>

local actions = {}

return {
	actions = actions,
	state = {},
}
