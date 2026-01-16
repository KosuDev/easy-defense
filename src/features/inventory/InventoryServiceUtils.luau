local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crates = require(ReplicatedStorage.Source.Features.Crates.Modules.Crates)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
type ItemData = DataTemplate.ItemData

local InventoryServiceUtils = {}

function InventoryServiceUtils.getModel(itemData: ItemData): Model
	if itemData.crateId then
		return Crates.getCrateModel(itemData.crateId)
	elseif itemData.itemId then
		return Towers.getTowerModel(itemData.itemId)
	end
	print(itemData)
	error("No model found for itemData")
end

function InventoryServiceUtils.getToolModel(itemData: ItemData): (Model, WeldConstraint)
	local model = InventoryServiceUtils.getModel(itemData)
	local root = model.PrimaryPart :: BasePart
	assert(root, "Model must have a PrimaryPart")
	model.Parent = workspace
	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end
		part.CanCollide = false
		part.Massless = true
		part.Anchored = false
		local joints = part:GetJoints()
		if part ~= root and (not joints or not joints[1]) then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = part
			weld.Parent = part
		end
	end

	local rootWeld = Instance.new("WeldConstraint")
	rootWeld.Part0 = root
	rootWeld.Parent = root

	return model, rootWeld
end

return InventoryServiceUtils
