local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

return function(uniqueId: string, isHotbar: boolean?)
	local visible, setVisible = React.useState(false)
	React.useEffect(function()
		local current = false
		local itemData: DataTemplate.ItemData = DataService:get({ "inventory", uniqueId })
		local isCrate = itemData.crateId ~= nil
		local itemInfo = if isCrate then Crates.getCrateInfo(itemData.crateId) else Towers.getTowerInfo(itemData.itemId)
		local function calc()
			if isCrate and itemData.amt <= 0 then
				return false
			end

			if InventorySlice.state.draggingItemUniqueId() == uniqueId then
				return false
			end

			local tab = InventorySlice.state.tab()
			if tab == "crates" and not isCrate then
				return false
			elseif tab == "towers" and isCrate then
				return false
			elseif tab == "favorites" and not itemData.fav then
				return false
			end

			local searchQuery = InventorySlice.state.searchQuery()
			if searchQuery then
				local name = itemInfo.name:lower()
				local query = searchQuery:lower()
				if not string.find(name, query) then
					return false
				end
			end

			for _, equippedUniqueId in DataService:get("plotNodes") do
				if equippedUniqueId == uniqueId then
					return false
				end
			end

			if not isHotbar then
				local hotbarIndex = table.find(DataService:get("hotbar"), uniqueId)
				if hotbarIndex then
					return false
				end
			end

			return true
		end

		local function update()
			local newVisible = calc()
			if current == newVisible then
				return
			end

			InventorySlice.state.numItemsVisible(function(prev)
				return prev + (if current then -1 else 1)
			end)

			current = newVisible
			setVisible(newVisible)
		end

		update()
		local itemDataConn = DataService:getChangedSignal({ "inventory", uniqueId }):Connect(update)
		local equippedConn = DataService:getChangedSignal("plotNodes"):Connect(update)
		local hotbarConn = DataService:getChangedSignal("hotbar"):Connect(update)
		local draggingDiscon = Charm.subscribe(InventorySlice.state.draggingItemUniqueId, update)
		local tabDiscon = Charm.subscribe(InventorySlice.state.tab, update)
		local searchDiscon = Charm.subscribe(InventorySlice.state.searchQuery, update)

		return function()
			itemDataConn:Destroy()
			equippedConn:Destroy()
			hotbarConn:Destroy()
			draggingDiscon()
			tabDiscon()
			searchDiscon()
		end
	end, {})

	return visible
end
