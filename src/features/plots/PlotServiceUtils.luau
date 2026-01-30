local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local PlotServiceUtils = {
	enums = {
		crateSpawnCooldown = 0.45,
	},
}

function PlotServiceUtils.floorNodeToString(floor: number, node: number): string
	return tostring(floor) .. "_" .. tostring(node)
end

function PlotServiceUtils.stringToFloorNode(floorNodeStr: string): (number, number)
	local separatorIndex = string.find(floorNodeStr, "_")
	if not separatorIndex then
		error("Invalid floorNodeStr: " .. floorNodeStr)
	end

	local floorStr = string.sub(floorNodeStr, 1, separatorIndex - 1)
	local nodeStr = string.sub(floorNodeStr, separatorIndex + 1)

	local floor = tonumber(floorStr)
	local node = tonumber(nodeStr)

	if not floor or not node then
		error("Invalid floorNodeStr: " .. floorNodeStr)
	end

	return floor, node
end

function PlotServiceUtils.getUpgradeCost(towerData: DataTemplate.TowerData): number
	return 100 * 1.5 ^ (towerData.level - 1)
end

function PlotServiceUtils.getDamageMultiplier(level: number): number
	return 1 + (level - 1) * 0.25
end

function PlotServiceUtils.getScaleFromLevel(level: number): number
	return 2 - (10 / (10 + (level - 3)))
end

function PlotServiceUtils.getDps(towerData: DataTemplate.TowerData): number
	local towerInfo = Towers.getTowerInfo(towerData.itemId)
	return towerInfo.damage * towerInfo.firerate * PlotServiceUtils.getDamageMultiplier(towerData.level)
end

return PlotServiceUtils
