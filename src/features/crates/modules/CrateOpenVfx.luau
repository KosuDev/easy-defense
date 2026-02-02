local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local DefenseSlice = require(ReplicatedStorage.Source.Features.Defense.DefenseSlice)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local TowerBillboardGui = require(ReplicatedStorage.Source.Features.Defense.UI.Screens.TowerBillboardGui)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

return function(cf: CFrame, towerData: DataTemplate.TowerData): ()
	cf *= CFrame.new(0, 0.5, 0)
	VfxUtils.emitAllAtPosition("CrateOpen", cf.Position)
	SoundController:Play(Sounds.misc.woosh)

	local finishedSignal = Signal.new()
	local model = Towers.getTowerModel(towerData.itemId, towerData.mutations)
	local gui = TowerBillboardGui.new(towerData)
	gui.Parent = model.PrimaryPart
	model:PivotTo(cf)
	model.Parent = workspace
	model:ScaleTo(0.001)

	SoundController:Play(Sounds.misc.rollEnd)
	VfxUtils.emitAllAtPosition("CrateEnd", cf.Position)

	local scaleProgress = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt: number)
		scaleProgress = math.min(scaleProgress + dt * 2.5, 1)
		local scale = math.lerp(0.001, 1, scaleProgress)
		model:ScaleTo(scale)
		if scaleProgress >= 1 then
			conn:Disconnect()
			DefenseSlice.actions.removeTower(model.PrimaryPart)
			model:Destroy()
			finishedSignal:Fire()
		end
	end)

	finishedSignal:Wait()
end
