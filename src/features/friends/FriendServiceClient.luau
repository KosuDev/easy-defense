-- FriendServiceClient.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Networker = require(ReplicatedStorage.Packages.Networker)

local getFriendCount, setFriendCount = Charm.signal(0)

local FriendServiceClient = {
	friendCount = getFriendCount, -- expose getter for other modules to subscribe to
}

function FriendServiceClient.init(self: FriendServiceClient)
	self.networker = Networker.client.new("FriendService", self)
	task.spawn(function()
		setFriendCount(self.networker:fetch("getFriendCount"))
	end)
end

function FriendServiceClient.setFriendCount(self: FriendServiceClient, count: number)
	setFriendCount(count)
end

type FriendServiceClient = typeof(FriendServiceClient) & {
	networker: Networker.Client,
}

return FriendServiceClient :: FriendServiceClient
