local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Vide = require(ReplicatedStorage.Packages.Vide)

return function(path: string | { string }, deferred: boolean?)
	local value = Vide.source(DataService:get(path))

	local mostRecent = nil
	local thread = nil

	local function update(new: any)
		if not deferred then
			value(if type(new) == "table" then table.clone(new) else new)
			return
		end

		mostRecent = new
		if thread then
			return
		end

		thread = task.defer(function()
			value(if type(mostRecent) == "table" then table.clone(mostRecent) else mostRecent)
			mostRecent = nil
			thread = nil
		end)
	end

	local conn = DataService:getChangedSignal(path):Connect(update)

	Vide.cleanup(function()
		conn:Disconnect()
		if thread then
			task.cancel(thread)
		end
	end)

	return value
end
