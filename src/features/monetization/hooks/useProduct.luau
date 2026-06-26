-- useProduct.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)

type Product = MonetizationServiceUtils.MonetizationProduct

return function(product: Product)
	local value = Vide.source(product)

	local conn = MonetizationServiceClient:getProductInfoChangedSignal(product):Connect(function()
		value(table.clone(product))
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return value
end
