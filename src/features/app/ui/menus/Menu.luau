-- Menu.luau
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local SlideOutFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.SlideOutFrame)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudBackground = require(ReplicatedStorage.Source.Features.App.UI.Components.StudBackground)
local Screen = require(ReplicatedStorage.Source.Features.App.UI.Screens.Screen)

local create = Vide.create

local getOpenedMenu, setOpenedMenuSignal = Charm.signal(nil :: string?)
local hasInitialized = false

local function init()
	if not RunService:IsRunning() then
		return function() end
	end

	if hasInitialized then
		warn("Menu module has already been initialized!")
		return
	end

	hasInitialized = true

	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Name = "MenuBlur"
	blur.Parent = Lighting

	local camera = workspace.CurrentCamera
	local spring = Ripple.createSpring(0, { frequency = 3, dampingRatio = 0.8, start = true })

	spring:onChange(function(value)
		blur.Size = value * 16
		camera.FieldOfView = 70 - value * 10
	end)

	local unsub = Charm.subscribe(function()
		return getOpenedMenu() or Screen.openedScreen()
	end, function(menuName)
		if menuName then
			spring:setGoal(1)
		else
			spring:setGoal(0)
		end
	end)

	return function()
		unsub()
		blur:Destroy()
		spring:destroy()
	end
end

local function setOpenedMenu(menuName: string?)
	if getOpenedMenu() == menuName then
		setOpenedMenuSignal(nil)
	else
		setOpenedMenuSignal(menuName)
	end
end

type MenuProps = {
	menuName: string,
	children: { any }?,
	Title: string?,
	Prefix: any?,
	Size: UDim2?,
	From: UDim2?,
	To: UDim2?,
	OnOpen: (() -> ())?,
	OnClose: (() -> ())?,
}

local function Menu(props: MenuProps)
	local isOpen = VideCharm.useSignalState(function()
		return getOpenedMenu() == props.menuName
	end)

	local openedScreen = VideCharm.useSignalState(Screen.openedScreen)

	-- fire OnOpen/OnClose callbacks when isOpen changes
	-- skip on first run
	local firstRun = true
	Vide.effect(function()
		local open = isOpen()
		if firstRun then
			firstRun = false
			return
		end
		if open and props.OnOpen then
			props.OnOpen()
		elseif not open and props.OnClose then
			props.OnClose()
		end
	end)

	return SlideOutFrame({
		Shown = function()
			return isOpen() and openedScreen() == nil
		end,
		From = props.From or UDim2.fromScale(0.5, 0.5),
		To = props.To or UDim2.fromScale(0.5, -0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.fromOffset(600, 400),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.5,

		create("UIStroke")({
			Thickness = 3,
			Color = Color3.fromRGB(20, 20, 20),
		}),

		-- content area
		create("Frame")({
			Size = UDim2.new(1, 0, 1, -50),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			props.children,
		}),

		-- title bar
		StudBackground({
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.fromScale(0, 0),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),

			children = {
				TextLabel({
					Text = props.Title,
					Size = UDim2.fromScale(0.8, 0.8),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0.01, 0.5),
					Stroke = { Thickness = 3, Color = Color3.fromRGB(20, 20, 20) },
					TextXAlignment = Enum.TextXAlignment.Left,
					Prefix = props.Prefix,
				}),

				create("UIStroke")({
					Thickness = 3,
					Color = Color3.fromRGB(20, 20, 20),
				}),

				create("UIGradient")({
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(0.21, Color3.fromRGB(71, 230, 255)),
						ColorSequenceKeypoint.new(0.87, Color3.fromRGB(10, 143, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 68, 117)),
					}),
				}),
			},
		}),

		-- close button
		Button({
			hoverScale = 1,
			Size = UDim2.fromOffset(50, 50),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Activated = function()
				if getOpenedMenu() == props.menuName then
					setOpenedMenuSignal(nil)
				end
			end,

			children = {
				TextLabel({
					Text = "X",
					Size = UDim2.fromScale(0.85, 0.85),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Stroke = { Thickness = 3, Color = Color3.fromRGB(117, 4, 4) },
				}),

				StudBackground({
					Size = UDim2.new(1, 0, 0, 50),
					Position = UDim2.fromScale(0, 0),
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),

					children = {
						create("UIStroke")({
							Thickness = 3,
							Color = Color3.fromRGB(20, 20, 20),
						}),

						create("UIGradient")({
							Rotation = 90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
								ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255, 71, 71)),
								ColorSequenceKeypoint.new(0.87, Color3.fromRGB(255, 10, 10)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(117, 4, 4)),
							}),
						}),
					},
				}),
			},
		}),
	})
end

if RunService:IsRunning() then
	init()
end

return {
	init = init,
	openedMenu = getOpenedMenu,
	setOpenedMenu = setOpenedMenu,
	Component = Menu,
}
