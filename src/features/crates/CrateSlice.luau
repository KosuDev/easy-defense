local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>

local crates: Atom<{ [Instance]: any }> = atom({})

local actions = {
	addCrate = function(instance: Instance, crateData: any)
		crates(function(prev)
			return Sift.Dictionary.set(prev, instance, crateData)
		end)
	end,

	removeCrate = function(instance: Instance)
		crates(function(prev)
			return Sift.Dictionary.removeKey(prev, instance)
		end)
	end,
}

return {
	state = {
		crates = crates,
	},
	actions = actions,
}
