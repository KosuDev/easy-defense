local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local InventorySlice = require(script.Parent.InventorySlice)
local Networker = require(ReplicatedStorage.Packages.Networker)
local InventoryServiceClient = {}

function InventoryServiceClient.init(self: InventoryServiceClient)
	self.networker = Networker.client.new("InventoryService", self)
end

function InventoryServiceClient.dragItem(self: InventoryServiceClient, uniqueId: string)
	local hotbarIndex = table.find(DataService:get("hotbar"), uniqueId)
	if hotbarIndex then
		--self.networker:fire("setHotBarUniqueId", hotbarIndex, nil)
		DataService:set({ "hotbar", hotbarIndex }, "NULL")
		InventorySlice.state.originalSlot(hotbarIndex)
	end
	InventorySlice.state.backpackOpen(true)
	InventorySlice.state.draggingItemUniqueId(uniqueId)
end

function InventoryServiceClient.moveItem(self: InventoryServiceClient, uniqueId: string, targetSlot: number?)
	if not targetSlot then
		return
	end

	local currentUniqueId = DataService:get({ "hotbar", targetSlot })
	local originalSlot = InventorySlice.state.originalSlot()
	if originalSlot and currentUniqueId then -- swap items
		DataService:set({ "hotbar", originalSlot }, currentUniqueId)
		--self.networker:fire("moveItem", currentUniqueId, originalSlot)
		InventorySlice.state.originalSlot(nil)
	end
	DataService:set({ "hotbar", targetSlot }, uniqueId)
	--self.networker:fire("moveItem", uniqueId, targetSlot)
end

type InventoryServiceClient = typeof(InventoryServiceClient) & {
	networker: Networker.Client,
}

return InventoryServiceClient :: InventoryServiceClient
