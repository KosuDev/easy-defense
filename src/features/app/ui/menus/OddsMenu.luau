-- OddsMenu.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Menu = require(script.Parent.Menu)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local ConveyorUpgrades = require(ReplicatedStorage.Source.Game.Items.ConveyorUpgrades)

local create = Vide.create

local getSelectedConveyor, setSelectedConveyor = Charm.signal(1)
local getSelectedCrate, setSelectedCrate = Charm.signal("wooden")

local function ConveyorButton(props)
	local selectedIndex = VideCharm.useSignalState(getSelectedConveyor)
	return function()
		local isSelected = selectedIndex() == props.index
		local Btn = if isSelected then StudButton.Green else StudButton.White
		return Btn({
			Size = UDim2.new(1, 0, 0, 60),
			LayoutOrder = props.index,
			Text = `Level {props.index}\nLuck: {ConveyorUpgrades[props.index].luck}`,
			Activated = function()
				setSelectedConveyor(props.index)
			end,
		})
	end
end

local function ConveyorCrate(props)
	local selectedIndex = VideCharm.useSignalState(getSelectedConveyor)

	return function()
		local conveyorLuck = ConveyorUpgrades[selectedIndex()].luck
		local info = Crates.getCrateInfo(props.index)

		local chance = 0
		local usedUpChance = 0
		for i = #Crates.sortedCrates, 1, -1 do
			local crate = Crates.sortedCrates[i]
			local crateChance =
				math.clamp(1 - (1 - Crates.getCrateInfo(crate.id).odds) ^ conveyorLuck, 0, 1 - usedUpChance)
			if i == info.layoutOrder then
				chance = crateChance
			end
			usedUpChance += crateChance
		end

		return InsetFrame({
			Size = UDim2.new(1, 0, 0, 80),
			LayoutOrder = math.round(10000 - chance * 10000),

			create("ImageLabel")({
				Size = UDim2.fromOffset(64, 64),
				Position = UDim2.fromScale(0.05, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = info.image,
			}),

			TextLabel({
				Text = `{math.round(chance * 10000) / 100}%`,
				Size = UDim2.fromScale(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.4, 0.25),
				AnchorPoint = Vector2.new(0, 0),
				Stroke = { Thickness = 2 },
			}),
		})
	end
end

local function CrateButton(props)
	local selectedIndex = VideCharm.useSignalState(getSelectedCrate)
	return function()
		local isSelected = selectedIndex() == props.index
		local Btn = if isSelected then StudButton.Green else StudButton.White
		return Btn({
			Size = UDim2.new(1, 0, 0, 60),
			LayoutOrder = props.data.layoutOrder,
			Activated = function()
				setSelectedCrate(props.index)
			end,

			children = {
				create("ImageLabel")({
					Size = UDim2.fromOffset(48, 48),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = Crates.getCrateInfo(props.index).image,
				}),
			},
		})
	end
end

local function CrateTower(props)
	local selectedIndex = VideCharm.useSignalState(getSelectedCrate)

	return function()
		local crateInfo = Crates.getCrateInfo(selectedIndex())
		local crateLuck = crateInfo.luck
		local towerInfo = Towers.getTowerInfo(props.index)

		local chance = 0
		local usedUpChance = 0
		for i = #Towers.sortedTowers, 1, -1 do
			local tower = Towers.sortedTowers[i]
			local towerChance = math.clamp(1 - (1 - tower.odds) ^ crateLuck, 0, 1 - usedUpChance)
			if i == towerInfo.layoutOrder then
				chance = towerChance
			end
			usedUpChance += towerChance
		end

		return InsetFrame({
			Size = UDim2.new(1, 0, 0, 80),
			LayoutOrder = math.round(10000 - chance * 10000),

			create("ImageLabel")({
				Size = UDim2.fromOffset(64, 64),
				Position = UDim2.fromScale(0.05, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = towerInfo.image,
			}),

			TextLabel({
				Text = towerInfo.name,
				Size = UDim2.fromScale(1, 0.2),
				Position = UDim2.fromScale(0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Stroke = { Thickness = 2 },
			}),

			TextLabel({
				Text = `{math.round(chance * 10000) / 100}%`,
				Size = UDim2.fromScale(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.4, 0.75),
				AnchorPoint = Vector2.new(0, 1),
				Stroke = { Thickness = 2 },
			}),
		})
	end
end

local function ConveyorsFrame()
	local conveyorButtons = {}
	for index in ConveyorUpgrades do
		conveyorButtons[index] = ConveyorButton({ index = index })
	end

	local conveyorCrates = {}
	for index in Crates.crates do
		conveyorCrates[index] = ConveyorCrate({ index = index })
	end

	return InsetFrame({
		Size = UDim2.fromScale(0.45, 0.9),
		Position = UDim2.fromScale(0.02, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),

		TextLabel({
			Text = "Conveyors",
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.fromScale(0.5, 0.01),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 2 },
		}),

		create("ScrollingFrame")({
			Size = UDim2.fromScale(0.4, 0.95),
			Position = UDim2.fromScale(0.04, 0.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,

			create("UIListLayout")({
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),

			conveyorButtons,
		}),

		create("ScrollingFrame")({
			Size = UDim2.fromScale(0.5, 0.95),
			Position = UDim2.fromScale(0.96, 0.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,

			create("UIListLayout")({
				Padding = UDim.new(0, 0),
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
			}),

			conveyorCrates,
		}),
	})
end

local function CratesFrame()
	local crateButtons = {}
	for index, data in Crates.crates do
		crateButtons[index] = CrateButton({ data = data, index = index })
	end

	local crateTowers = {}
	for index, data in Towers.towers do
		crateTowers[index] = CrateTower({ data = data, index = index })
	end

	return InsetFrame({
		Size = UDim2.fromScale(0.45, 0.9),
		Position = UDim2.fromScale(0.52, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),

		TextLabel({
			Text = "Crates",
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.fromScale(0.5, 0.01),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 2 },
		}),

		create("ScrollingFrame")({
			Size = UDim2.fromScale(0.3, 0.95),
			Position = UDim2.fromScale(0.05, 0.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,

			create("UIListLayout")({
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),

			crateButtons,
		}),

		create("ScrollingFrame")({
			Size = UDim2.fromScale(0.6, 0.95),
			Position = UDim2.fromScale(0.95, 0.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			BorderSizePixel = 0,

			create("UIListLayout")({
				Padding = UDim.new(0, 0),
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
			}),

			crateTowers,
		}),
	})
end

return function()
	return Menu.Component({
		menuName = "OddsMenu",
		Title = "Odds",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(700, 530),
		Prefix = {
			Image = Crates.getCrateInfo("wooden").image,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},

		children = {
			ConveyorsFrame(),
			CratesFrame(),
		},
	})
end
