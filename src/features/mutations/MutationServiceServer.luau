local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local MutationServiceUtils = require(ReplicatedStorage.Source.Features.Mutations.MutationServiceUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Mutations = DataTemplate.Mutations

local MutationServiceServer = {}

function MutationServiceServer.init(self: MutationServiceServer)
	self.networker = Networker.server.new("MutationService", self)
end

function MutationServiceServer.getActiveEvents(_self: MutationServiceServer): { string }
	return {}
end

function MutationServiceServer.rollMutations(self: MutationServiceServer): Mutations?
	local activeEvents = self:getActiveEvents()
	local luck = 1 -- Placeholder for player luck calculation, not sure if needed
	return MutationServiceUtils.rollMutations(activeEvents, luck)
end

type MutationServiceServer = typeof(MutationServiceServer) & {
	networker: Networker.Server,
}

return MutationServiceServer :: MutationServiceServer
