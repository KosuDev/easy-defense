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

type InventoryServiceServer = typeof(InventoryServiceServer) & {
	networker: Networker.Server,
}

return InventoryServiceServer :: InventoryServiceServer
