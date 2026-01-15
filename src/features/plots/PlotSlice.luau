local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local atom = Charm.atom

type CrateNode = DataTemplate.CrateNode
type Atom<T> = Charm.Atom<T>

local crates: Atom<{ [BasePart]: CrateNode }> = atom({})

local actions = {
	addCrate = function(root: BasePart, crateData: CrateNode)
		crates(function(prev)
			return Sift.Dictionary.set(prev, root, crateData)
		end)
	end,

	removeCrate = function(root: BasePart)
		crates(function(prev)
			return Sift.Dictionary.removeKey(prev, root)
		end)
	end,
}

return {
	actions = actions,
	states = {
		crates = crates,
	},
}
