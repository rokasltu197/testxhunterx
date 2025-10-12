-- LocalScript inside StarterGui > ScreenGui

local blackScreen = Instance.new("Frame")
blackScreen.Size = UDim2.new(1, 0, 1, 0)
blackScreen.Position = UDim2.new(0, 0, 0, 0)
blackScreen.BackgroundColor3 = Color3.new(0, 0, 0) -- full black = AMOLED pixel off
blackScreen.BorderSizePixel = 0
blackScreen.Visible = false
blackScreen.ZIndex = 999999
blackScreen.Parent = script.Parent

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40)
button.Position = UDim2.new(1, -110, 0.5, -20)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "Black ON"
button.ZIndex = 1000000
button.Parent = script.Parent

local isBlack = false
button.MouseButton1Click:Connect(function()
	isBlack = not isBlack
	blackScreen.Visible = isBlack
	button.Text = isBlack and "Black OFF" or "Black ON"

	-- optional: lower game brightness a bit while black screen is on
	if isBlack then
		game.Lighting.Brightness = 0
	else
		game.Lighting.Brightness = 2
	end
end)
