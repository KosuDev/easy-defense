local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)

local function instaCallback(player: Player, n: number): ()
	PlotServiceServer:instaOpenCrate(player, n)
end

for i = 1, 10 do
	Products["insta" .. i].callback = function(player: Player)
		instaCallback(player, i)
	end
end

return nil
