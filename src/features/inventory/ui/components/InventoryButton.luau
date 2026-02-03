local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ItemIcon = require(script.Parent.ItemIcon)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local useInventoryItemVisibility =
	require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useInventoryItemVisibility)
local useItemDataLayout = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDataLayout)
local useItemDragger = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDragger)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type InventoryButtonProps = {
	itemData: DataTemplate.ItemData,
	uniqueId: string,
}

return function(props: InventoryButtonProps)
	local uniqueId = props.uniqueId
	local setDragStart = useItemDragger(uniqueId)
	local equippedUniqueId = ReactCharm.useAtom(InventorySlice.state.equippedItemUniqueId)
	local visible = useInventoryItemVisibility(uniqueId, false)
	local layoutOrder = useItemDataLayout(props.itemData)
	if not visible then
		return nil
	end

	return e(Button, {
		hoverScale = 1,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Activated = function()
			local isEquipped = equippedUniqueId == uniqueId
			if isEquipped then
				InventoryServiceClient:unequipItem()
			else
				InventoryServiceClient:equipItem(uniqueId)
			end
		end,
		OnDown = function()
			setDragStart(UserInputService:GetMouseLocation())
		end,
	}, {
		Icon = e(ItemIcon, {
			Size = UDim2.fromScale(1, 1),
			itemData = props.itemData,
			equipped = equippedUniqueId == uniqueId,
		}),
	})
end
