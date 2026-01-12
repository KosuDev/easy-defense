local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local CrateModels = ReplicatedStorage.Assets.Crates

local MIDPOINT = 24 / 30
local END_START = 1 + 10 / 30
local END_END = 2 + 5 / 30
local MAX_END = END_END - 0.01
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
		model: Model & any,
		isLocalPlayer: boolean,
		state: string,
		t: number,
		track: AnimationTrack,
		janitor: Janitor.Janitor,
	},
	Crate
))

function Crate.new(crateId: string, startCf: CFrame, isLocalPlayer: boolean)
	local self = setmetatable({
		crateId = crateId,
		startCf = startCf,
		model = CrateModels:FindFirstChild(crateId):Clone() :: Model,
		state = CRATE_STATES.spawning,
		t = 0,
		isLocalPlayer = isLocalPlayer,
		track = nil,
		updateConn = nil,
		janitor = Janitor.new(),
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

	PlotSlice.actions.addCrate(self.model.Main, {})

	if self.isLocalPlayer then
		local highlight = Instance.new("Highlight")
		highlight.Parent = self.model
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.Enabled = false
		local prox = Instance.new("ProximityPrompt")
		prox.RequiresLineOfSight = false
		prox.MaxActivationDistance = 10
		prox.Parent = self.model.Main
		prox.ActionText = "Buy"

		prox.PromptShown:Connect(function()
			highlight.Enabled = true
		end)
		prox.PromptHidden:Connect(function()
			highlight.Enabled = false
		end)

		prox.Triggered:Connect(function()
			print("Buy action triggered")
		end)

		self.janitor:Add(prox)
		self.janitor:Add(highlight)
	end

	return self
end

function Crate.setState(self: Crate, state: string)
	self.state = state
end

function Crate.update(self: Crate, dt: number)
	if self.state == CRATE_STATES.idle then
		return
	end

	self.t += dt / 1.33

	if self.state == CRATE_STATES.spawning or self.t < MIDPOINT then
		self.track.TimePosition = math.clamp(self.t, 0, MIDPOINT)
		if self.t >= MIDPOINT and self.state == CRATE_STATES.spawning then
			self:setState(CRATE_STATES.idle)
			self.t = MIDPOINT
		end
	else
		self.track.TimePosition = math.clamp(END_START + self.t - MIDPOINT, END_START, MAX_END)
		if self.track.TimePosition >= MAX_END then
			self:destroy()
		end
	end
end

function Crate.destroy(self: Crate)
	if self.model then
		PlotSlice.actions.removeCrate(self.model.Main)
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
