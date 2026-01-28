local PlotServiceUtils = {
	enums = {
		crateSpawnCooldown = 0.8,
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

return PlotServiceUtils
