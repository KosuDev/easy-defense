-- LeftSideBar.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Vide = require(ReplicatedStorage.Packages.Vide)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local create = Vide.create

local RAINBOW_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
	ColorSequenceKeypoint.new(0.34, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.85, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
})

type SideBarButtonProps = {
	Position: UDim2,
	Text: string,
	Image: string,
	IconScale: number?,
	Activated: () -> (),
	children: { any }?,
}

local function SideBarButton(props: SideBarButtonProps)
	local iconScale = props.IconScale or 1

	return Button({
		hoverScale = 1.1,
		Size = UDim2.fromOffset(80, 80),
		Position = props.Position,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Activated = props.Activated,

		children = {
			create("UIStroke")({
				Thickness = 2.5,
				Color = Color3.new(0, 0, 0),
			}),

			TextLabel({
				Text = props.Text,
				Size = UDim2.fromScale(1, 0.275),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.975),
				Stroke = {},
				ZIndex = 2,
			}),

			create("ImageLabel")({
				Size = UDim2.fromScale(iconScale, iconScale),
				Position = UDim2.fromScale(0.5, 0.475),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = props.Image,
			}),

			props.children,
		},
	})
end

local function ShopButton()
	local rotation = Vide.source(0)

	local conn = RunService.Heartbeat:Connect(function(dt)
		rotation((rotation() + dt * 15) % 360)
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return Button({
		hoverScale = 1.1,
		Size = UDim2.fromOffset(200, 70),
		Position = UDim2.fromScale(0.595, 0.438),
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Activated = function()
			Menu.setOpenedMenu("Shop")
		end,

		children = {
			create("UIStroke")({
				Thickness = 4,
				Color = Color3.fromRGB(241, 245, 245),

				create("UIGradient")({
					Color = RAINBOW_GRADIENT,
					Rotation = rotation,
				}),
			}),

			TextLabel({
				Text = "Shop",
				Size = UDim2.fromScale(0.6, 0.6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.65, 0.5),
				Stroke = { Thickness = 3 },
				ZIndex = 2,
			}),

			create("ImageLabel")({
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Position = UDim2.fromScale(0.02, 0.495),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = ImageIds.shoppingCart,
			}),
		},
	})
end

local function RebirthNotiButton()
	local rebirths = useDataState("rebirths")
	local currency = useDataState("currency")
	local towerIndex = useDataState("towerIndex")

	return function()
		local r = rebirths()
		if RebirthUtils.isMaxedRebirths(r) then
			return nil
		end

		local reqs = RebirthUtils.getRequirements(r)
		local index = towerIndex()
		local currencyReqMet = currency() >= reqs.currency
		local towerReqMet = index.normal[reqs.towerId] or index.gold[reqs.towerId] or index.diamond[reqs.towerId]

		if not (currencyReqMet and towerReqMet) then
			return nil
		end

		return ShopFrame.Red({
			Size = UDim2.fromScale(0.35, 0.35),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.new(1, -2, 0, 2),
			AnchorPoint = Vector2.new(1, 0),

			children = {
				TextLabel({
					Text = "!",
					Size = UDim2.fromScale(1, 1),
					Stroke = {},
				}),
			},
		})
	end
end

return function()
	return AutoScaledFrame({
		Size = UDim2.fromOffset(180, 800),
		Position = UDim2.fromScale(0.005, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,

		children = {
			ShopButton(),

			SideBarButton({
				Position = UDim2.fromScale(0.75, 0.55),
				Text = "Rebirth",
				IconScale = 0.925,
				Image = ImageIds.rebirth,
				Activated = function()
					Menu.setOpenedMenu("RebirthMenu")
				end,
				children = { RebirthNotiButton() },
			}),

			SideBarButton({
				Position = UDim2.fromScale(0.25, 0.55),
				Text = "Index",
				IconScale = 0.925,
				Image = ImageIds.index,
				Activated = function()
					Menu.setOpenedMenu("IndexMenu")
				end,
			}),
		},
	})
end
