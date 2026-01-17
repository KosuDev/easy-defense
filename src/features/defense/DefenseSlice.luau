local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local atom = Charm.atom

type TowerData = DataTemplate.TowerData
type Atom<T> = Charm.Atom<T>

local towers: Atom<{ [BasePart]: { towerData: TowerData, forcedParent: Instance? } }> = atom({})

local actions = {
	addTower = function(root: BasePart, towerData: TowerData, forcedParent: Instance?)
		towers(function(prev)
			return Sift.Dictionary.set(prev, root, { towerData = towerData, forcedParent = forcedParent })
		end)
	end,

	removeTower = function(root: BasePart)
		towers(function(prev)
			return Sift.Dictionary.removeKey(prev, root)
		end)
	end,
}

return {
	actions = actions,
	states = {
		towers = towers,
	},
}
