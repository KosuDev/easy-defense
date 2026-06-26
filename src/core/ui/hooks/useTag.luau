local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

return function(tag: string): () -> Instance?
	local instance = Vide.source(CollectionService:GetTagged(tag)[1] :: Instance?)

	local addedConn = CollectionService:GetInstanceAddedSignal(tag):Connect(function(newInstance)
		if instance() ~= nil then
			warn(
				`useTag: Multiple instances with tag "{tag}" detected. useTag should only be used with tags that have a single instance.`
			)
			return
		end
		instance(newInstance)
	end)

	local removedConn = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(removedInstance)
		if removedInstance == instance() then
			instance(nil)
		end
	end)

	Vide.cleanup(function()
		addedConn:Disconnect()
		removedConn:Disconnect()
	end)

	return instance
end
