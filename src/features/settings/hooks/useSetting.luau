-- useSetting.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local SettingsServiceClient = require(ReplicatedStorage.Source.Features.Settings.SettingsServiceClient)
local SettingsServiceUtils = require(ReplicatedStorage.Source.Features.Settings.SettingsServiceUtils)

return function(path: string | { string })
	local settingsPath = SettingsServiceUtils.convertPathToSettingPath(path)
	local value = useDataState(settingsPath)

	local function setValue(newValue: any)
		SettingsServiceClient:set(path, newValue)
	end

	return value, setValue
end
