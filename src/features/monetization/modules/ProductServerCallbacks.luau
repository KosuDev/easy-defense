local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local ShopUtils = require(ReplicatedStorage.Source.Features.Shop.ShopUtils)

local function instaCallback(player: Player, n: number): ()
	PlotServiceServer:instaOpenCrate(player, n)
end

for i = 1, 10 do
	Products["insta" .. i].callback = function(player: Player)
		instaCallback(player, i)
	end
end

local function crateCallback(player: Player, n: number): ()
	PlotServiceServer:boughtProductCrate(player, n)
end

for i = 1, 9 do
	Products["crate" .. i].callback = function(player: Player)
		crateCallback(player, i)
	end
end

Products.currency1.callback = function(player: Player)
	local rebirths: number = DataService:get(player, "rebirths")
	DataService:update(player, "currency", function(amt: number)
		return amt + ShopUtils.getCurrencyAmtFromRebirth(1, rebirths)
	end)
end

Products.currency2.callback = function(player: Player)
	local rebirths: number = DataService:get(player, "rebirths")
	DataService:update(player, "currency", function(amt: number)
		return amt + ShopUtils.getCurrencyAmtFromRebirth(2, rebirths)
	end)
end

Products.currency3.callback = function(player: Player)
	local rebirths: number = DataService:get(player, "rebirths")
	DataService:update(player, "currency", function(amt: number)
		return amt + ShopUtils.getCurrencyAmtFromRebirth(3, rebirths)
	end)
end

local function luckyBlockCallback(player: Player, id: string, amt: number): ()
	InventoryServiceServer:addCrate(player, {
		crateId = id,
		amt = amt,
	})
end

for i = 1, 3, 1 do
	local id = "luckyBlock" .. i
	Products["luckyBlock" .. i].callback = function(player: Player)
		return luckyBlockCallback(player, id, 1)
	end
	Products["threeLuckyBlock" .. i].callback = function(player: Player)
		return luckyBlockCallback(player, id, 3)
	end
end

return nil
