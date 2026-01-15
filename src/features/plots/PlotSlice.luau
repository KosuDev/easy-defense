local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local atom = Charm.atom

type CrateData = DataTemplate.CrateData
type Atom<T> = Charm.Atom<T>

local crates: Atom<{ [BasePart]: CrateData }> = atom({})

local actions = {
	addCrate = function(root: BasePart, crateData: CrateData)
		crates(function(prev)
			return Sift.Dictionary.set(prev, root, crateData)
		end)
	end,
}

return {
	actions = actions,
	states = {
		crates = crates,
	},
}
