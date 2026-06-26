-- IndexMenu.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Menu = require(script.Parent.Menu)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

local create = Vide.create

local getTowerTier, setTowerTier = Charm.signal("normal")

type TowerIndexProps = {
	towerId: string,
	towerInfo: Towers.TowerInfo,
}

local function TowerIndex(props: TowerIndexProps)
	local towerTier = VideCharm.useSignalState(getTowerTier)
	local towerIndex = useDataState("towerIndex")
	local tier = Tiers.getTierForOdds(props.towerInfo.odds)

	return function()
		local currentTier = towerTier()
		local currentIndex = towerIndex()
		local unlocked = currentIndex[currentTier][props.towerId] ~= nil

		return Button({
			hoverScale = 1.1,
			LayoutOrder = props.towerInfo.layoutOrder,
			BackgroundTransparency = 1,

			children = {
				ItemIcon({
					Size = UDim2.fromScale(1, 1),
					ImageColor3 = if unlocked then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(0, 0, 0),
					itemData = {
						itemId = props.towerId,
						level = 1,
						mutations = {
							gold = currentTier == "gold",
							diamond = currentTier == "diamond",
						},
						crateId = "",
						amt = 0,
					},
					equipped = true,
					showStrength = false,

					children = {
						TextLabel({
							Text = if not unlocked then "???" else props.towerInfo.name,
							Size = UDim2.fromScale(0.9, 0.175),
							Position = UDim2.fromScale(0.5, 0.975),
							AnchorPoint = Vector2.new(0.5, 1),
							Stroke = { Thickness = 2 },
							ZIndex = 2,
						}),

						TextLabel({
							Text = tier.name,
							Size = UDim2.fromScale(0.9, 0.2),
							Position = UDim2.fromScale(0.5, 0.7),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Stroke = { Thickness = 2 },
							Gradient = {
								Color = tier.gradient,
								Rotation = 90,
							},
						}),
					},
				}),
			},
		})
	end
end

local function AllTowers()
	local children = {}
	for towerId, towerInfo in Towers.towers do
		if towerInfo.isLuckyBlock then
			continue
		end
		children[towerId] = TowerIndex({
			towerId = towerId,
			towerInfo = towerInfo,
		})
	end
	return children
end

return function()
	return Menu.Component({
		menuName = "IndexMenu",
		Title = "Index",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(600, 530),
		Prefix = {
			Image = ImageIds.index,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},

		children = {
			create("Frame")({
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(1.05, 0),
				Size = UDim2.fromOffset(160, 400),
				BackgroundTransparency = 1,

				create("UIListLayout")({
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				StudButton.White({
					Size = UDim2.fromOffset(160, 50),
					Text = "NORMAL",
					LayoutOrder = 1,
					Activated = function()
						setTowerTier("normal")
					end,
				}),

				StudButton.Gold({
					Size = UDim2.fromOffset(160, 50),
					Text = "GOLD",
					LayoutOrder = 2,
					Activated = function()
						setTowerTier("gold")
					end,
				}),

				StudButton.Teal({
					Size = UDim2.fromOffset(160, 50),
					Text = "DIAMOND",
					LayoutOrder = 3,
					Activated = function()
						setTowerTier("diamond")
					end,
				}),
			}),

			create("ScrollingFrame")({
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				ScrollBarThickness = 0,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromOffset(0, 0),

				create("UIPadding")({
					PaddingTop = UDim.new(0, 20),
					PaddingBottom = UDim.new(0, 20),
					PaddingLeft = UDim.new(0, 20),
					PaddingRight = UDim.new(0, 20),
				}),

				create("UIGridLayout")({
					CellSize = UDim2.fromOffset(120, 120),
					CellPadding = UDim2.fromOffset(10, 10),
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				AllTowers(),
			}),
		},
	})
end
