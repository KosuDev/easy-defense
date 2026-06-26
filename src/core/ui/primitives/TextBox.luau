-- TextBox.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

export type TextBoxProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	Text: string?,
	ClearTextOnFocus: boolean?,
	TextEditable: boolean?,
	PlaceholderText: string?,
	PlaceholderColor3: Color3?,
	TextSize: number?,
	TextColor3: Color3?,
	TextScaled: boolean?,
	TextWrapped: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	-- input filters
	NumbersOnly: boolean?,
	LettersOnly: boolean?,
	LettersAndNumbersOnly: boolean?,
	MaxCharacters: number?,
	CapsLock: boolean?,
	-- callbacks
	FocusLost: ((textbox: TextBox, enterPressed: boolean) -> ())?,
	-- children
	children: { any }?,
}

return function(props: TextBoxProps)
	local function onTextChanged(textbox: TextBox)
		local newText = textbox.Text

		if props.MaxCharacters and #newText > props.MaxCharacters then
			newText = newText:sub(1, props.MaxCharacters)
		end

		if props.CapsLock then
			newText = newText:upper()
		end

		if props.NumbersOnly then
			newText = newText:gsub("[^%d]", "")
		elseif props.LettersOnly then
			newText = newText:gsub("[^%a]", "")
		elseif props.LettersAndNumbersOnly then
			newText = newText:gsub("[^%w]", "")
		end

		if newText ~= textbox.Text then
			textbox.Text = newText
		end
	end

	return create("TextBox")({
		Size = props.Size,
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		Text = props.Text or "",
		ClearTextOnFocus = props.ClearTextOnFocus or false,
		TextEditable = props.TextEditable ~= false,
		PlaceholderText = props.PlaceholderText or "",
		PlaceholderColor3 = props.PlaceholderColor3 or Color3.fromRGB(194, 194, 194),
		TextSize = props.TextSize,
		TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
		TextScaled = props.TextScaled ~= false,
		TextWrapped = props.TextWrapped,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		Font = Enum.Font.BuilderSansExtraBold,

		Changed = onTextChanged,
		FocusLost = props.FocusLost,

		props.children,
	})
end
