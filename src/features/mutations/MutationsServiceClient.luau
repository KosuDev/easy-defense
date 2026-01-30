local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MutationServiceUtils = require(script.Parent.MutationServiceUtils)
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Mutations = DataTemplate.Mutations

local MutationServiceClient = {}

function MutationServiceClient.init(self: MutationServiceClient)
	self.networker = Networker.client.new("MutationService", self)
end

function MutationServiceClient.rollMutations(_self: MutationServiceClient): Mutations?
	return MutationServiceUtils.rollMutations({}, 1)
end
type MutationServiceClient = typeof(MutationServiceClient) & {
	networker: Networker.Client,
}

return MutationServiceClient :: MutationServiceClient
