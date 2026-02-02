local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local InventoryServiceServer = {}

local function getMutationKey(mutations: DataTemplate.Mutations?): string
	if mutations and mutations.diamond then
		return "diamond"
	end
	if mutations and mutations.gold then
		return "gold"
	end
	return "normal"
end

local function getCrateKey(crateData: DataTemplate.CrateData): string
	return `crate:{crateData.crateId}:{getMutationKey(crateData.mutations)}`
end

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

function InventoryServiceServer.addCrate(
	_self: InventoryServiceServer,
	player: Player,
	crateData: DataTemplate.CrateData,
	amt: number?
): string
	local crateKey = getCrateKey(crateData)
	local prevCrateData: DataTemplate.ItemData = DataService:get(player, { "inventory", crateKey })
	if not prevCrateData then
		local legacyCrateData: DataTemplate.ItemData = DataService:get(player, { "inventory", crateData.crateId })
		if legacyCrateData then
			DataService:set(player, { "inventory", crateKey }, {
				crateId = legacyCrateData.crateId,
				mutations = legacyCrateData.mutations,
				amt = legacyCrateData.amt or 0,
			})
			DataService:set(player, { "inventory", crateData.crateId }, nil)
			prevCrateData = DataService:get(player, { "inventory", crateKey })
		end
	end
	if not prevCrateData then
		DataService:set(player, { "inventory", crateKey }, {
			crateId = crateData.crateId,
			mutations = crateData.mutations,
			amt = amt or crateData.amt or 1,
		})
	else
		DataService:update(player, { "inventory", crateKey, "amt" }, function(prev: number?)
			return (prev or 0) + (amt or crateData.amt or 1)
		end)
	end

	return crateKey
end

function InventoryServiceServer.addTower(
	_self: InventoryServiceServer,
	player: Player,
	towerData: DataTemplate.TowerData
): string
	local uniqueId = HttpService:GenerateGUID(false)
	DataService:set(player, { "inventory", uniqueId }, towerData)

	local towerTier = if towerData.mutations and towerData.mutations.diamond
		then "diamond"
		elseif towerData.mutations and towerData.mutations.gold then "gold"
		else "normal"

	local hasObtained = DataService:get(player, { "towerIndex", towerTier, towerData.itemId }) == true
	if not hasObtained then
		DataService:set(player, { "towerIndex", towerTier, towerData.itemId }, true)
	end

	return uniqueId
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

function InventoryServiceServer.addToHotBar(self: InventoryServiceServer, player: Player, uniqueId: string): ()
	self.networker:fire(player, "addToHotbar", uniqueId)
end

type InventoryServiceServer = typeof(InventoryServiceServer) & {
	networker: Networker.Server,
}

return InventoryServiceServer :: InventoryServiceServer
