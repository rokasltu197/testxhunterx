-- LocalScript for Executor

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create black overlay
local blackScreen = Instance.new("Frame")
blackScreen.Size = UDim2.new(1, 0, 1, 0)
blackScreen.Position = UDim2.new(0, 0, 0, 0)
blackScreen.BackgroundColor3 = Color3.new(0, 0, 0)
blackScreen.BorderSizePixel = 0
blackScreen.Visible = false
blackScreen.ZIndex = 10
blackScreen.Parent = screenGui

-- Create toggle button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40)
button.Position = UDim2.new(0.95, -110, 0.5, -20) -- Positioned near the right edge
button.AnchorPoint = Vector2.new(1, 0.5)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "Black ON"
button.ZIndex = 11
button.Parent = screenGui

-- Toggle logic
local isBlack = false
button.Activated:Connect(function()
	isBlack = not isBlack
	blackScreen.Visible = isBlack
	button.Text = isBlack and "Black OFF" or "Black ON"
end)
