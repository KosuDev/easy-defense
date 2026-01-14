local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local InventoryServiceServer = {}

function InventoryServiceServer.init(self: InventoryServiceServer)
	self.networker = Networker.server.new("InventoryService", self, {
		self.setHotBarUniqueId,
		self.equipItem,
		self.unequipItem,
	})
end

function InventoryServiceServer.unequipItem(self: InventoryServiceServer, player: Player)
	self.networker:fireAll("setPlayerItem", player, nil)
end

function InventoryServiceServer.equipItem(self: InventoryServiceServer, player: Player, uniqueId: string)
	local itemData = DataService:get(player, { "inventory", uniqueId })
	if not itemData then
		return
	end

	self.networker:fireAll("setPlayerItem", player, itemData)
end

function InventoryServiceServer.addCrate(_self: InventoryServiceServer, player: Player, crateId: string, amt: number?)
	local prevCrateData: DataTemplate.ItemData = DataService:get(player, { "inventory", crateId })
	if not prevCrateData then
		DataService:set(player, { "inventory", crateId }, {
			crateId = crateId,
			amt = amt or 1,
		})
	else
		DataService:update(player, { "inventory", crateId, "amt" }, function(prev: number?)
			return (prev or 0) + (amt or 1)
		end)
	end
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
