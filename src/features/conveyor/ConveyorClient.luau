local ConveyorClient = {}
ConveyorClient.__index = ConveyorClient

function ConveyorClient.new()
	local self = setmetatable({}, ConveyorClient)

	return self
end

return ConveyorClient
