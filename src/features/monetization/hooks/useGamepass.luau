-- useGamepass.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)

type Product = MonetizationServiceUtils.MonetizationProduct

return function(product: Product): () -> boolean
	local owns = Vide.source(MonetizationServiceClient:ownsGamepass(product :: any))

	local conn = MonetizationServiceClient:getProductInfoChangedSignal(product):Connect(function()
		owns(MonetizationServiceClient:ownsGamepass(product :: any))
	end)

	Vide.cleanup(function()
		conn:Disconnect()
	end)

	return owns
end
