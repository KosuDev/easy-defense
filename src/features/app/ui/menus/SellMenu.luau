-- SellMenu.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local DataService = require(ReplicatedStorage.Packages.DataService).client
local Menu = require(script.Parent.Menu)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventoryServiceUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceUtils)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local useItemDataLayout = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDataLayout)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local create = Vide.create

local getSelectedUniqueIds, setSelectedUniqueIds = Charm.signal({} :: { [string]: boolean })
local getTab, setTab = Charm.signal("all")
local selectAllActivated = Signal.new()

local function ConfirmButton()
	local selected = VideCharm.useSignalState(getSelectedUniqueIds)

	return function()
		local s = selected()
		local numSelected = Sift.Dictionary.count(s)
		local Btn = if numSelected > 0 then StudButton.Green else StudButton.White
		return Btn({
			Size = UDim2.fromOffset(200, 60),
			Position = UDim2.fromScale(0.5, 0.9),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = `Sell ({numSelected})`,
			Activated = function()
				if numSelected == 0 then
					return
				end
				InventoryServiceClient:sell(getSelectedUniqueIds())
				Menu.setOpenedMenu(nil)
			end,
		})
	end
end

type ItemButtonProps = {
	uniqueId: string,
	itemData: DataTemplate.ItemData,
}

local function ItemButton(props: ItemButtonProps)
	local visible = Vide.source(true)
	local layoutOrder = useItemDataLayout(props.itemData)
	local isSelected = VideCharm.useSignalState(function()
		return getSelectedUniqueIds()[props.uniqueId]
	end)

	local isTower = not props.itemData.crateId

	-- select all signal
	local conn = selectAllActivated:Connect(function()
		if visible() then
			setSelectedUniqueIds(function(prev)
				return Sift.Dictionary.set(prev, props.uniqueId, true)
			end)
		end
	end)

	-- visibility based on tab and plot nodes
	local function calcVisible(): boolean
		local info = if props.itemData.itemId
			then Towers.getTowerInfo(props.itemData.itemId)
			else Towers.getTowerInfo(props.itemData.crateId)
		if props.itemData.fav or info.isLuckyBlock then
			return false
		end

		for _, equippedUniqueId in DataService:get("plotNodes") do
			if equippedUniqueId == props.uniqueId then
				return false
			end
		end

		local tab = getTab()
		if (tab == "towers" and not isTower) or (tab == "crates" and isTower) then
			return false
		end

		return true
	end

	visible(calcVisible())

	local tabUnsub = Charm.subscribe(getTab, function()
		visible(calcVisible())
	end)

	local nodesConn = DataService:getChangedSignal("plotNodes"):Connect(function()
		visible(calcVisible())
	end)

	Vide.cleanup(function()
		conn:Disconnect()
		tabUnsub()
		nodesConn:Disconnect()
	end)

	return function()
		if not visible() then
			return nil
		end

		return Button({
			hoverScale = 1,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			LayoutOrder = layoutOrder,
			Activated = function()
				setSelectedUniqueIds(function(prev)
					if isSelected() then
						return Sift.Dictionary.removeKey(prev, props.uniqueId)
					else
						return Sift.Dictionary.set(prev, props.uniqueId, true)
					end
				end)
			end,

			children = {
				create("UIStroke")({
					Thickness = 2.5,
					Color = function()
						return if isSelected() then Color3.new(1, 0, 0) else Color3.new(0, 0, 0)
					end,
				}),

				ItemIcon({
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					itemData = props.itemData,
					hideStroke = true,
				}),
			},
		})
	end
end

local function Items()
	local inventory = useDataState("inventory")

	return function()
		local result = {}
		for uniqueId, itemData in inventory() do
			result[uniqueId] = ItemButton({
				uniqueId = uniqueId,
				itemData = itemData,
			})
		end
		return result
	end
end

local function Inventory()
	return InsetFrame({
		Size = UDim2.fromScale(0.97, 0.8),
		Position = UDim2.fromScale(0.5, 0.425),
		AnchorPoint = Vector2.new(0.5, 0.5),

		children = {
			create("ScrollingFrame")({
				Size = UDim2.fromScale(0.97, 0.94),
				Position = UDim2.fromScale(0.5, 0.495),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				BorderSizePixel = 0,
				ScrollBarThickness = 0,

				create("UIGridLayout")({
					CellSize = UDim2.fromOffset(100, 100),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					CellPadding = UDim2.fromOffset(10, 10),
				}),

				create("UIPadding")({
					PaddingTop = UDim.new(0, 5),
				}),

				Items(),
			}),
		},
	})
end

local function SelectAll()
	return StudButton.Purple({
		Size = UDim2.fromOffset(120, 40),
		Position = UDim2.fromScale(0.15, 0.9),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "Select All",
		Activated = function()
			selectAllActivated:Fire()
		end,
	})
end

local function CurrencyCount()
	local selected = VideCharm.useSignalState(getSelectedUniqueIds)

	return function()
		local amt = 0
		for uniqueId in selected() do
			local itemData: DataTemplate.ItemData? = DataService:get("inventory")[uniqueId]
			if itemData then
				amt += InventoryServiceUtils.getSellValue(itemData)
			end
		end

		return TextLabel({
			Size = UDim2.fromOffset(200, 50),
			Position = UDim2.fromScale(0.825, 0.9),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = `${Abbreviate(amt)}`,
			Stroke = { Thickness = 3, Color = Color3.fromRGB(24, 55, 7) },
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
				}),
			},
		})
	end
end

return function()
	return Menu.Component({
		menuName = "SellMenu",
		Title = "Sell",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(700, 530),
		Prefix = {
			Image = ImageIds.currency,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
		OnClose = function()
			setSelectedUniqueIds({})
			setTab("all")
		end,

		children = {
			Inventory(),
			ConfirmButton(),
			SelectAll(),
			CurrencyCount(),
		},
	})
end
