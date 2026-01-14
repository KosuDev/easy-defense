local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local useAbsSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useAbsSize)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local useDeviceInput = require(ReplicatedStorage.Source.Core.UI.Hooks.useDeviceInput)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local InventoryButton = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.InventoryButton)
local ItemButtonStroke = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemButtonStroke)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local useItemDragger = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDragger)
local e = React.createElement

local SLOT_SIZE = 95
local UNUSED_SLOT_SIZE = 75
local MAX_SLOTS = 9
local NULL = "NULL"

type HotbarSlotProps = {
	index: number,
}

local function useHotBarItemData(index: number)
	local path = useDataState({ "hotbar", index })
	local itemData, setItemData = React.useState(nil)

	React.useEffect(function()
		if path == NULL or not path then
			setItemData(nil)
			return
		end

		local function update()
			local val = DataService:get({ "inventory", path })
			if type(val) == "table" then
				setItemData(table.clone(val))
			else
				setItemData(val)
			end
		end

		update()
		local conn = DataService:getChangedSignal({ "inventory", path }):Connect(update)

		return function()
			conn:Destroy()
		end
	end, { path })

	return itemData
end

local function HotbarSlot(props: HotbarSlotProps)
	local open = ReactCharm.useAtom(InventorySlice.state.backpackOpen)
	local uniqueId: string = useDataState({ "hotbar", props.index })
	local itemData = useHotBarItemData(props.index)
	local inputDevice = useDeviceInput()
	local setDragStart = useItemDragger(uniqueId)
	local isDragging = ReactCharm.useAtom(InventorySlice.state.draggingItemUniqueId) ~= nil
	local hoveredSlot = ReactCharm.useAtom(InventorySlice.state.hoveredSlot)
	local equippedUniqueId = ReactCharm.useAtom(InventorySlice.state.equippedItemUniqueId)
	local equipped = equippedUniqueId == uniqueId

	if not itemData and not open then
		return nil
	end

	return e("Frame", {
		Size = if not itemData
			then UDim2.fromOffset(UNUSED_SLOT_SIZE, UNUSED_SLOT_SIZE)
			else UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
		LayoutOrder = props.index,
		BackgroundTransparency = 0.2,
		BackgroundColor3 = if hoveredSlot == props.index
			then Color3.fromRGB(60, 62, 66)
			else Color3.fromRGB(37, 38, 41),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		ItemIcon = if itemData
			then e(ItemIcon, {
				itemData = itemData,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			})
			else nil,

		SlotNum = if inputDevice == Enum.PreferredInput.KeyboardAndMouse
			then e(TextLabel, {
				Text = props.index,
				Size = UDim2.fromScale(0.25, 0.25),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0, 0),
				Stroke = { Color = Color3.fromRGB(20, 20, 20), Thickness = 2 },
				ZIndex = 5,
			})
			else nil,

		Stroke = if itemData then e(ItemButtonStroke, { equipped = equipped, partData = itemData }) else nil,

		Btn = e(Button, {
			hoverScale = 1,
			Size = UDim2.fromScale(1.1, 1.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Activated = function()
				if itemData then
					local isEquipped = equippedUniqueId == uniqueId
					if isEquipped then
						InventoryServiceClient:unequipItem()
					else
						InventoryServiceClient:equipItem(uniqueId)
					end
				end
			end,
			OnDown = function()
				if itemData then
					setDragStart(UserInputService:GetMouseLocation())
				end
			end,
			OnEnter = function()
				if isDragging then
					InventorySlice.state.hoveredSlot(props.index)
				end
			end,
			OnLeave = function()
				if isDragging and InventorySlice.state.hoveredSlot() == props.index then
					InventorySlice.state.hoveredSlot(nil)
				end
			end,
		}),
	})
end

local function Hotbar()
	local ref = React.useRef(nil :: Frame?)
	local absSize = useAbsSize(ref)
	local numSlots = math.min(MAX_SLOTS, absSize.X // SLOT_SIZE)
	local slots = React.useMemo(function()
		local result = {}
		for i = 1, numSlots do
			result[i] = e(HotbarSlot, { index = i })
		end
		return result
	end, { numSlots })

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 95),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		ref = ref,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
		}),
	}, slots)
end

local function InventoryButtons()
	local inventory = useDataState("inventory")
	local buttons = {}
	for uniqueId, itemData in inventory do
		buttons[uniqueId] = e(InventoryButton, { itemData = itemData, uniqueId = uniqueId })
	end

	return buttons
end

local function InventoryFrame(props)
	return e("Frame", {
		Visible = props.open,
		Size = UDim2.fromOffset(600, 300),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(37, 38, 41),
		BackgroundTransparency = 0.2,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		InvButtons = e("Frame", {
			Size = UDim2.new(0, 66, 1, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(0, -6, 0.5, 0),
			BackgroundTransparency = 1,
		}),

		ScrollingFrame = e("ScrollingFrame", {
			Size = UDim2.fromScale(0.98, 0.8),
			Position = UDim2.fromScale(0.5, 0.98),
			AnchorPoint = Vector2.new(0.5, 1),
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIGridLayout", {
				CellSize = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
				CellPadding = UDim2.fromOffset(5, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),

			Padding = e("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),

			InventoryButtons = e(InventoryButtons),
		}),

		X = e(Button, {
			hoverScale = 1,
			Size = UDim2.fromOffset(60, 60),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Activated = function()
				InventorySlice.state.backpackOpen(false)
			end,
		}, {
			Text = e(TextLabel, {
				Text = "X",
				Size = UDim2.fromScale(0.8, 0.8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Stroke = {},
			}),
		}),
	})
end

return function()
	local open = ReactCharm.useAtom(InventorySlice.state.backpackOpen)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.new(0.6, 0, 0, 200),
		Position = UDim2.new(0.5, 0, 1, -6),
		BackgroundTransparency = 1,
	}, {
		Hotbar = e(Hotbar),

		Inventory = e(InventoryFrame, { open = open }),

		OpenButton = e(Button, {
			hoverScale = 1.1,
			Visible = not open,
			Size = UDim2.fromOffset(150, 40),
			Position = UDim2.fromScale(0.5, 0.375),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			Activated = function()
				InventorySlice.state.backpackOpen(true)
			end,
		}, {
			Stroke = e("UIStroke", {

				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 2,
			}),

			Text = e(TextLabel, {
				Text = "Open Backpack",
				Size = UDim2.fromScale(0.9, 0.6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Stroke = {},
			}),
		}),
	})
end
