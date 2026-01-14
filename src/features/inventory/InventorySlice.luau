local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>
local backpackOpen = atom(false)
local draggingItemUniqueId = atom(nil :: string?)
local hoveredSlot = atom(nil :: number?)
local originalSlot = atom(nil :: number?)

local actions = {}

return {
	actions = actions,
	state = {
		backpackOpen = backpackOpen,
		draggingItemUniqueId = draggingItemUniqueId,
		hoveredSlot = hoveredSlot,
		originalSlot = originalSlot,
	},
}
