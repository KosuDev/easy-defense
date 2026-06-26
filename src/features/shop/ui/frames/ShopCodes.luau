-- ShopCodes.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local TextBox = require(ReplicatedStorage.Source.Core.UI.Primitives.TextBox)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local CodeServiceClient = require(ReplicatedStorage.Source.Features.Codes.CodeServiceClient)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)

local create = Vide.create

return function()
	local textbox = Vide.source(nil :: TextBox?)
	local resultText = Vide.source("")
	local resultColor = Vide.source(Color3.fromRGB(255, 255, 255))

	local function redeem()
		local box = textbox()
		if not box or box.Text == "" then
			return
		end

		local code = box.Text
		local success, message = CodeServiceClient:redeem(code)

		if success then
			resultColor(Color3.fromRGB(92, 255, 92))
		else
			resultColor(Color3.fromRGB(255, 64, 64))
		end

		resultText(message)
		task.wait(3)
		if resultText() == message then
			resultText("")
		end
	end

	return ShopContentFrame({
		Text = "Codes",
		LayoutOrder = 50,

		children = {
			ShopFrame.Blue({
				Size = UDim2.fromOffset(768, 160),

				children = {
					TextLabel({
						Text = "Follow socials for codes!",
						Size = UDim2.fromOffset(500, 42),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.05),
						Stroke = { Thickness = 3, Color = Color3.fromRGB(16, 16, 20) },
					}),

					TextLabel({
						Text = resultText,
						TextColor3 = resultColor,
						Size = UDim2.fromOffset(200, 30),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.35),
						Stroke = { Thickness = 2, Color = Color3.fromRGB(16, 16, 20) },
					}),

					StudButton.Green({
						Text = "Redeem",
						Position = UDim2.fromScale(0.86, 0.725),
						Size = UDim2.fromOffset(175, 60),
						AnchorPoint = Vector2.new(0.5, 0.5),
						hoverScale = 1.05,
						Activated = redeem,
					}),

					ShopFrame.Grey({
						Size = UDim2.fromScale(0.7, 0.35),
						Position = UDim2.fromScale(0.03, 0.9),
						AnchorPoint = Vector2.new(0, 1),

						children = {
							TextBox({
								Size = UDim2.fromScale(0.97, 0.875),
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								PlaceholderText = "Enter Code Here",
								ClearTextOnFocus = true,
								TextSize = 20,
								PlaceholderColor3 = Color3.fromRGB(216, 216, 219),
								FocusLost = function(box: TextBox, enterPressed: boolean)
									textbox(box)
									if enterPressed then
										redeem()
									end
								end,
							}),
						},
					}),
				},
			}),
		},
	})
end
