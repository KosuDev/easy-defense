local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CrateModels = ReplicatedStorage.Assets.Crates

local MIDPOINT = 24 / 30
local END_START = 1 + 10 / 30
local END_END = 2 + 5 / 30
local ANIMATION = ReplicatedStorage.Assets.Animations.CrateSpawn

local CRATE_STATES = {
	spawning = "spawning",
	idle = "idle",
	despawning = "despawning",
}

local Crate = {}
Crate.__index = Crate

export type Crate = typeof(setmetatable(
	{} :: {
		crateId: string,
		startCf: CFrame,
		model: Model,
		state: string,
		t: number,
		track: AnimationTrack,
	},
	Crate
))

function Crate.new(crateId: string, startCf: CFrame)
	local self = setmetatable({
		crateId = crateId,
		startCf = startCf,
		model = CrateModels:FindFirstChild(crateId):Clone() :: Model,
		state = CRATE_STATES.spawning,
		t = 0,
		track = nil,
		updateConn = nil,
	}, Crate)

	self.model:PivotTo(self.startCf)
	self.model.Parent = workspace
	local track: AnimationTrack = self.model.AnimationController.Animator:LoadAnimation(ANIMATION)
	track.Looped = true
	track:Play(nil, nil, 0)
	self.track = track
	self.updateConn = RunService.Heartbeat:Connect(function(dt)
		self:update(dt)
	end)

	return self
end

function Crate.setState(self: Crate, state: string)
	self.state = state
	if state == CRATE_STATES.despawning then
		self.t = 0
	end
end

function Crate.update(self: Crate, dt: number)
	if self.state == CRATE_STATES.idle then
		return
	end

	self.t += dt / 1.66

	if self.state == CRATE_STATES.spawning then
		self.track.TimePosition = math.clamp(self.t, 0, MIDPOINT)
		if self.t >= MIDPOINT then
			self:setState(CRATE_STATES.idle)
		end
	else
		self.track.TimePosition = math.clamp(END_START + self.t, END_START, END_END - 0.01)
		if self.t >= END_END - END_START then
			self:destroy()
		end
	end
end

function Crate.destroy(self: Crate)
	if self.model then
		self.model:Destroy()
	end

	if self.updateConn then
		self.updateConn:Disconnect()
	end

	if self.track then
		self.track:Destroy()
	end
end

return Crate
