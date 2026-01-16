local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ripple = require(ReplicatedStorage.Packages.Ripple)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)
local ROTATION_OFFSET = CFrame.Angles(0, math.rad(-90), 0)

local TowerAnimationUtils = {}

function TowerAnimationUtils.aim(model: any, target: Vector3): ()
	local rotates = model:FindFirstChild("Rotates") :: any
	local pos = rotates:GetPivot().Position
	local groundTarget = Vector3.new(target.X, pos.Y, target.Z)
	rotates:PivotTo(CFrame.lookAt(pos, groundTarget) * ROTATION_OFFSET)

	local top = rotates:FindFirstChild("Top") :: any?
	if not top then
		return
	end

	local topPos = top:GetPivot().Position
	top:PivotTo(CFrame.lookAt(topPos, target) * ROTATION_OFFSET)
end

return TowerAnimationUtils
