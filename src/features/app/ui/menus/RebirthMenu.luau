-- RebirthMenu.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local Menu = require(script.Parent.Menu)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local TransparentFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.TransparentFrame)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

local create = Vide.create

local function ClaimedCheckMark()
	return create("ImageLabel")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = ImageIds.checkmark,
		ZIndex = 9,
	})
end

local function RequirementsFrame()
	local rebirths = useDataState("rebirths")
	local currency = useDataState("currency")
	local towerIndex = useDataState("towerIndex")

	return function()
		local r = rebirths()

		if RebirthUtils.isMaxedRebirths(r) then
			return InsetFrame({
				Size = UDim2.new(0.9, 0, 0, 160),
				Position = UDim2.fromScale(0.5, 0.075),
				AnchorPoint = Vector2.new(0.5, 0),

				children = {
					TextLabel({
						Text = "MAXED",
						Size = UDim2.fromScale(1, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Stroke = { Thickness = 3 },
					}),
				},
			})
		end

		local reqs = RebirthUtils.getRequirements(r)
		local towerInfo = Towers.getTowerInfo(reqs.towerId)
		local tier = Tiers.getTierForOdds(towerInfo.odds)
		local currencyReqMet = currency() >= reqs.currency
		local index = towerIndex()
		local towerReqMet = index.normal[reqs.towerId] or index.gold[reqs.towerId] or index.diamond[reqs.towerId]

		return InsetFrame({
			Size = UDim2.new(0.9, 0, 0, 160),
			Position = UDim2.fromScale(0.5, 0.075),
			AnchorPoint = Vector2.new(0.5, 0),

			children = {
				create("UIListLayout")({
					Padding = UDim.new(0, 20),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				TransparentFrame({
					Size = UDim2.fromScale(0.7, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					LayoutOrder = 2,

					children = {
						TextLabel({
							Text = tier.name,
							Size = UDim2.fromScale(1, 0.3),
							Position = UDim2.fromScale(0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Stroke = { Thickness = 2 },
							ZIndex = 2,
							Gradient = { Rotation = 90, Color = tier.gradient },
						}),

						TextLabel({
							Text = towerInfo.name,
							Size = UDim2.fromScale(1, 0.25),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 1),
							ZIndex = 2,
							Stroke = {},
						}),

						create("ImageLabel")({
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = towerInfo.image,
							ImageColor3 = if towerReqMet
								then Color3.fromRGB(51, 51, 51)
								else Color3.fromRGB(255, 255, 255),
						}),

						create("ImageLabel")({
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.5, 0.55),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							ImageColor3 = Color3.fromRGB(0, 0, 0),
							ImageTransparency = 0.4,
							Image = towerInfo.image,
							ZIndex = 0,
						}),

						if towerReqMet then ClaimedCheckMark() else nil,
					},
				}),

				TransparentFrame({
					Size = UDim2.fromScale(0.7, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					LayoutOrder = 1,

					children = {
						if currencyReqMet then ClaimedCheckMark() else nil,

						TextLabel({
							Text = "$" .. Abbreviate(reqs.currency),
							Size = UDim2.fromScale(1, 0.3),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0),
							ZIndex = 2,
							Stroke = {},
							Gradient = {
								Rotation = 90,
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
								}),
							},
						}),

						TextLabel({
							Text = "Money",
							Size = UDim2.fromScale(1, 0.25),
							Position = UDim2.fromScale(0.5, 1),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Stroke = { Thickness = 2 },
							ZIndex = 2,
						}),

						create("ImageLabel")({
							Size = UDim2.fromScale(0.9, 0.9),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = ImageIds.currency,
							ImageColor3 = if currencyReqMet
								then Color3.fromRGB(51, 51, 51)
								else Color3.fromRGB(255, 255, 255),
						}),
					},
				}),
			},
		})
	end
end

local function RewardsFrame()
	local rebirths = useDataState("rebirths")

	return function()
		local r = rebirths()
		local rewards = RebirthUtils.rebirthRewards[r + 1]

		if not rewards then
			return InsetFrame({
				Size = UDim2.new(0.9, 0, 0, 160),
				Position = UDim2.fromScale(0.5, 0.48),
				AnchorPoint = Vector2.new(0.5, 0),

				children = {
					TextLabel({
						Text = "MAXED",
						Size = UDim2.fromScale(1, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Stroke = { Thickness = 3 },
					}),
				},
			})
		end

		return InsetFrame({
			Size = UDim2.new(0.9, 0, 0, 160),
			Position = UDim2.fromScale(0.5, 0.48),
			AnchorPoint = Vector2.new(0.5, 0),

			children = {
				create("UIListLayout")({
					Padding = UDim.new(0, 20),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				TransparentFrame({
					Size = UDim2.fromScale(0.7, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					LayoutOrder = 2,

					children = {
						TextLabel({
							Text = "Tower Slot",
							Size = UDim2.fromScale(1.1, 0.3),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0),
							ZIndex = 2,
							Stroke = {},
							Gradient = {
								Rotation = 90,
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 255)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 255)),
								}),
							},
						}),

						TextLabel({
							Text = "+" .. rewards.towerSlots,
							Size = UDim2.fromScale(1, 0.3),
							Position = UDim2.fromScale(0.5, 0.95),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Stroke = { Thickness = 3 },
							ZIndex = 2,
						}),

						create("ImageLabel")({
							Size = UDim2.fromScale(0.9, 0.9),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = ImageIds.extraSlot,
						}),
					},
				}),

				if rewards.floors
					then TransparentFrame({
						Size = UDim2.fromScale(0.7, 0.7),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						LayoutOrder = 3,

						children = {
							TextLabel({
								Text = "Extra Floor",
								Size = UDim2.fromScale(1.1, 0.3),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0),
								ZIndex = 2,
								Stroke = {},
								Gradient = {
									Rotation = 90,
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 255)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 255)),
									}),
								},
							}),

							TextLabel({
								Text = "+" .. rewards.floors,
								Size = UDim2.fromScale(1, 0.3),
								Position = UDim2.fromScale(0.5, 0.95),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Stroke = { Thickness = 3 },
								ZIndex = 2,
							}),

							create("ImageLabel")({
								Size = UDim2.fromScale(0.9, 0.9),
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Image = ImageIds.floorSlot,
							}),
						},
					})
					else nil,

				TransparentFrame({
					Size = UDim2.fromScale(0.7, 0.7),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					LayoutOrder = 1,

					children = {
						TextLabel({
							Text = "+10%",
							Size = UDim2.fromScale(1, 0.3),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0),
							ZIndex = 2,
							Stroke = {},
							Gradient = {
								Rotation = 90,
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
								}),
							},
						}),

						TextLabel({
							Text = "Money Bonus",
							Size = UDim2.fromScale(1, 0.25),
							Position = UDim2.fromScale(0.5, 1),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Stroke = { Thickness = 2 },
							ZIndex = 2,
						}),

						create("ImageLabel")({
							Size = UDim2.fromScale(0.9, 0.9),
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = ImageIds.currency,
						}),
					},
				}),
			},
		})
	end
end

local function RebirthButton()
	local rebirths = useDataState("rebirths")

	return function()
		local r = rebirths()
		local isMaxed = RebirthUtils.isMaxedRebirths(r)
		return StudButton.Green({
			Text = if isMaxed then "MAXED" else "Rebirth!",
			Size = UDim2.fromOffset(200, 60),
			Position = UDim2.fromScale(0.5, 0.88),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Activated = function()
				if isMaxed then
					return
				end
				PlotServiceClient:rebirth()
			end,
		})
	end
end

return function()
	return Menu.Component({
		menuName = "RebirthMenu",
		Title = "Rebirth",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(600, 530),
		Prefix = {
			Image = ImageIds.rebirth,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},

		children = {
			TextLabel({
				Text = "- YOU NEED -",
				Size = UDim2.new(1, 0, 0, 38),
				Position = UDim2.fromScale(0.5, 0.007),
				AnchorPoint = Vector2.new(0.5, 0),
				Stroke = { Thickness = 3 },
			}),

			RequirementsFrame(),

			TextLabel({
				Text = "- REWARDS -",
				Size = UDim2.new(1, 0, 0, 38),
				Position = UDim2.fromScale(0.5, 0.41),
				AnchorPoint = Vector2.new(0.5, 0),
				Stroke = { Thickness = 3 },
				Gradient = {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 233, 162)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 187, 0)),
					}),
				},
			}),

			RewardsFrame(),
			RebirthButton(),

			TextLabel({
				Text = "[ ! ]  Money is RESET, everything else is kept! [ ! ]",
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromScale(0.5, 0.97),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 2, Color = Color3.fromRGB(102, 0, 0) },
				TextColor3 = Color3.fromRGB(255, 46, 46),
			}),
		},
	})
end
