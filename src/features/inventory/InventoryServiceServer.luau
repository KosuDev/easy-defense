local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local InventoryServiceServer = {}

function InventoryServiceServer.init(self: InventoryServiceServer)
	self.networker = Networker.server.new("InventoryService", self, {})
end

function InventoryServiceServer.addCrate(_self: InventoryServiceServer, player: Player, crateId: string, amt: number?)
	DataService:update(player, { "crates", crateId }, function(prev: number?)
		return (prev or 0) + (amt or 1)
	end)
end

function InventoryServiceServer.setHotBarUniqueId(
	_self: InventoryServiceServer,
	player: Player,
	index: number,
	uniqueId: string?
)
	assert(type(uniqueId) == "string" or uniqueId == nil, "uniqueId must be a string or nil")
	assert(index >= 1 and index <= 9, "index must be between 1 and 9")
	DataService:set(player, { "hotbar", index }, uniqueId or "NULL")
end

type InventoryServiceServer = typeof(InventoryServiceServer) & {
	networker: Networker.Server,
}

return InventoryServiceServer :: InventoryServiceServer
