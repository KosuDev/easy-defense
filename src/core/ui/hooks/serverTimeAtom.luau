local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charm = require(ReplicatedStorage.Packages.Charm)

local function getCurrentTime(): number
	if RunService:IsRunning() then
		return math.round(workspace:GetServerTimeNow())
	end
	return os.time()
end

local getServerTime, setServerTime = Charm.signal(getCurrentTime())

local TIME_GET_CD = 60
local lastTimeGet = getServerTime()

task.spawn(function()
	while true do
		task.wait(1)
		setServerTime(function(current)
			return current + 1
		end)
		if getServerTime() - lastTimeGet >= TIME_GET_CD then
			setServerTime(getCurrentTime())
			lastTimeGet = getServerTime()
		end
	end
end)

return getServerTime
