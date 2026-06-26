-- Screen.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local useSpring = require(ReplicatedStorage.Packages.VideRipple).useSpring

local getOpenedScreen, setOpenedScreenSignal = Charm.signal(nil :: string?)

local function setOpenedScreen(screenName: string?)
	setOpenedScreenSignal(screenName)
end

type ScreenProps = {
	screenName: string,
	children: { any }?,
}

local function Screen(props: ScreenProps)
	local isOpen = VideCharm.useSignalState(function()
		return getOpenedScreen() == props.screenName
	end)

	return function()
		if not isOpen() then
			return nil
		end
		return props.children
	end
end

local function useScreenSpring(screenName: string)
	local value, spring =
		useSpring(if getOpenedScreen() == screenName then 1 else 0, { frequency = 3, dampingRatio = 0.7 })

	local unsub = Charm.subscribe(getOpenedScreen, function(newScreen)
		if newScreen == screenName then
			spring:setGoal(1)
		else
			spring:setGoal(0)
		end
	end)

	Vide.cleanup(unsub)

	return value
end

return {
	openedScreen = getOpenedScreen,
	setOpenedScreen = setOpenedScreen,
	Component = Screen,
	useScreenSpring = useScreenSpring,
}
