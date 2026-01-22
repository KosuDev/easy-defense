local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local DefenseSlice = require(ReplicatedStorage.Source.Features.Defense.DefenseSlice)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

local function xToScale(x: number, i: number): number
	return math.clamp(1.2 * (-(2 * i * x - 1) ^ 2 + 1), 0.001, 1.2)
end

return function(cf: CFrame, towerData: DataTemplate.TowerData): ()
	cf *= CFrame.new(0, 0.5, 0)
	VfxUtils.emitAllAtPosition("CrateOpen", cf.Position)
	SoundController:Play(Sounds.misc.woosh)
	local prevId = nil
	local finishedSignal = Signal.new()

	local newTower

	newTower = function(i: number)
		local isFinal = i == 1
		local isBeforeFinal = i == 2
		local towerId = if isFinal then towerData.itemId else Towers.rollTowerId(1)
		while (towerId == prevId and not isFinal) or (isBeforeFinal and towerId == towerData.itemId) do
			towerId = Towers.rollTowerId(1)
		end

		prevId = towerId
		local model = Towers.getTowerModel(towerId)
		local gui = ReplicatedStorage.Assets.VFX.TowerBillboard:Clone()
		local towerInfo = Towers.getTowerInfo(towerId)
		local tier = Tiers.getTierForOdds(towerInfo.odds)
		gui.StudsOffsetWorldSpace = Vector3.new(0, towerInfo.height, 0)
		gui.TowerName.TextLabel.Text = towerInfo.name
		gui.Rarity.TextLabel.Text = tier.name
		gui.Rarity.TextLabel.Gradient.Color = tier.gradient
		gui.Dps.Visible = false
		gui.Parent = model.PrimaryPart
		model:PivotTo(cf)
		model.Parent = workspace
		model:ScaleTo(0.001)
		local x = 0
		local hasBeenOne = false
		local hasSpawnedNext = false

		local hasBeenMax = false
		local conn
		if isFinal then
			SoundController:Play(Sounds.misc.rollEnd)
			VfxUtils.emitAllAtPosition("CrateEnd", cf.Position)
		end
		SoundController:Play(Sounds.misc.roll)

		conn = RunService.Heartbeat:Connect(function(dt: number)
			if isFinal and hasBeenMax then
				local currentScale = model:GetScale()
				if math.abs(1 - currentScale) < 0.01 then
					finishedSignal:Fire()
					conn:Disconnect()
					model:Destroy()
					return
				end

				model:ScaleTo(math.lerp(currentScale, 1, 3 * dt))
				return
			end

			x += dt
			local scale = xToScale(x, i)
			model:ScaleTo(scale)
			if scale > 1 and not hasBeenOne then
				hasBeenOne = true
			elseif scale < 0.7 and hasBeenOne and not hasSpawnedNext and not isFinal then
				hasSpawnedNext = true
				newTower(i - 1)
			elseif scale <= 0.001 and hasSpawnedNext then
				conn:Disconnect()
				DefenseSlice.actions.removeTower(model.PrimaryPart)
				model:Destroy()
			end

			if scale > 1.1 then
				hasBeenMax = true
			end
		end)
	end

	newTower(math.random(13, 16))

	finishedSignal:Wait()
end
