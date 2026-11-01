local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(255, 0, 0),
			Second = Color3.fromRGB(200, 0, 0),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

local Icons = {}
local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)
if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then return Icons[IconName] else return nil end
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then Interface:Destroy() end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then Interface:Destroy() end
	end
end

function OrionLib:IsRunning()
	if gethui then return Orion.Parent == gethui()
	else return Orion.Parent == game:GetService("CoreGui") end
end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do wait() end
	for _, Connection in next, OrionLib.Connections do Connection:Disconnect() end
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
				}):Play()
			end
		end)
	end)
end

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do Object[i] = v end
	for i, v in next, Children or {} do v.Parent = Object end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...) return ElementFunction(...) end
end

local function MakeElement(ElementName, ...)
	return OrionLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value) Element[Property] = Value end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child) Child.Parent = Element end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3" end
	if Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
	if Object:IsA("UIStroke") then return "Color" end
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3" end
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then OrionLib.ThemeObjects[Type] = {} end
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
		end
	end
end

local function PackColor(Color) return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255} end
local function UnpackColor(Color) return Color3.fromRGB(Color.R, Color.G, Color.B) end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function()
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then Data[i] = PackColor(v.Value)
			else Data[i] = v.Value end
		end
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3, Enum.UserInputType.Touch}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do if v == Key then return true end end
end

CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})
end)
CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {Color = Color or Color3.fromRGB(255, 255, 255), Thickness = Thickness or 1})
end)
CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(Scale or 0, Offset or 0)})
end)
CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {PaddingBottom = UDim.new(0, Bottom or 4), PaddingLeft = UDim.new(0, Left or 4), PaddingRight = UDim.new(0, Right or 4), PaddingTop = UDim.new(0, Top or 4)})
end)
CreateElement("TFrame", function() return Create("Frame", {BackgroundTransparency = 1}) end)
CreateElement("Frame", function(Color)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
end)
CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0}, {
		Create("UICorner", {CornerRadius = UDim.new(Scale, Offset)})
	})
end)
CreateElement("Button", function()
	return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0})
end)
CreateElement("ScrollFrame", function(Color, Width)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
end)
CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {Image = ImageID, BackgroundTransparency = 1})
	if GetIcon(ImageID) ~= nil then ImageNew.Image = GetIcon(ImageID) end
	return ImageNew
end)
CreateElement("ImageButton", function(ImageID)
	return Create("ImageButton", {Image = ImageID, BackgroundTransparency = 1})
end)
CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "", TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0, TextSize = TextSize or 15,
		Font = Enum.Font.Gotham, RichText = true, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = NotificationConfig.Time or 15
		local NotificationParent = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})
		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent, Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0), BackgroundTransparency = 0.9,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {Size = UDim2.new(0, 20, 0, 20), ImageColor3 = Color3.fromRGB(240, 240, 240), Name = "Icon"}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 30, 0, 0), Font = Enum.Font.GothamBold, Name = "Title"}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold, Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = Color3.fromRGB(200, 200, 200), TextWrapped = true
			})
		})
		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		wait(0.3)
		TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		wait(0.05)
		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
		wait(1.35)
		NotificationFrame:Destroy()
	end)
end

function OrionLib:Init()
	if OrionLib.SaveCfg then
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)
	end
end
function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then makefolder(WindowConfig.ConfigFolder) end
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {Position = UDim2.new(0, 9, 0, 6), Size = UDim2.new(0, 18, 0, 18)}), "Text")
	})
	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {Position = UDim2.new(0, 9, 0, 6), Size = UDim2.new(0, 18, 0, 18), Name = "Ico"}), "Text")
	})
	local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 50)})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50), Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0)}), "Stroke"),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 1, -50)}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 1)}), "Stroke"),
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 10, 0.5, 0)}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {Size = UDim2.new(1, 0, 1, 0)}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {Size = UDim2.new(1, 0, 1, 0)}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 10, 0.5, 0)}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold, ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 12), {Size = UDim2.new(1, -60, 0, 12), Position = UDim2.new(0, 50, 1, -25), Visible = not WindowConfig.HidePremium}), "TextDark")
		})
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0), Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack, TextSize = 20
	}), "Text")
	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1)}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = Orion, Position = UDim2.new(0.5, -280, 0.5, -155),
		Size = UDim2.new(0, 560, 0, 310), ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 50), Name = "TopBar"}), {
			WindowName, WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0)}), "Stroke"),
				CloseBtn, MinimizeBtn
			}), "Second"),
		}),
		DragPoint, WindowStuff
	}), "Main")

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 25, 0, 15)})
		WindowIcon.Parent = MainWindow.TopBar
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({Name = "Interface Hidden", Content = "Tap RightShift to reopen the interface", Time = 5})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then MainWindow.Visible = true end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, 310)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1)
			WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0), Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 1
		})
		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion, Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end

	if WindowConfig.IntroEnabled then LoadSequence() end

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 0, 30), Parent = TabHolder}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0), ImageTransparency = 0.4, Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold, TextTransparency = 0.4, Name = "Title"
			}), "Text")
		})
		if GetIcon(TabConfig.Icon) ~= nil then TabFrame.Ico.Image = GetIcon(TabConfig.Icon) end

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50), Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow, Visible = false, Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				end
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then ItemContainer.Visible = false end
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end)

		local function GetElements(ItemParent)
			local ElementFunction = {}
			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.9, Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold, Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				local LabelFunction = {}
				function LabelFunction:Set(ToChange) LabelFrame.Content.Text = ToChange end
				return LabelFunction
			end
function ElementFunction:AddParagraph(Text, Content)
	Text = Text or "Text"
	Content = Content or "Content"
	local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
		Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.9, Parent = ItemParent
	}), {
		AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
			Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 12, 0, 10),
			Font = Enum.Font.GothamBold, Name = "Title"
		}), "Text"),
		AddThemeObject(SetProps(MakeElement("Label", "", 13), {
			Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 26),
			Font = Enum.Font.GothamSemibold, Name = "Content", TextWrapped = true
		}), "TextDark"),
		AddThemeObject(MakeElement("Stroke"), "Stroke")
	}), "Second")

	AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
		ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
		ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
	end)

	ParagraphFrame.Content.Text = Content

	local ParagraphFunction = {}
	function ParagraphFunction:Set(ToChange)
		ParagraphFrame.Content.Text = ToChange
	end
	return ParagraphFunction
end

function ElementFunction:AddButton(ButtonConfig)
	ButtonConfig = ButtonConfig or {}
	ButtonConfig.Name = ButtonConfig.Name or "Button"
	ButtonConfig.Callback = ButtonConfig.Callback or function() end
	ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

	local Button = {}
	local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

	local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
		Size = UDim2.new(1, 0, 0, 33), Parent = ItemParent
	}), {
		AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
			Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
			Font = Enum.Font.GothamBold, Name = "Content"
		}), "Text"),
		AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0, 7),
		}), "TextDark"),
		AddThemeObject(MakeElement("Stroke"), "Stroke"), Click
	}), "Second")

	AddConnection(Click.MouseEnter, function()
		TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
	end)
	AddConnection(Click.MouseLeave, function()
		TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
	end)
	AddConnection(Click.MouseButton1Up, function()
		TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
		spawn(function() ButtonConfig.Callback() end)
	end)
	AddConnection(Click.MouseButton1Down, function()
		TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
	end)

	function Button:Set(ButtonText) ButtonFrame.Content.Text = ButtonText end
	return Button
end

function ElementFunction:AddToggle(ToggleConfig)
	ToggleConfig = ToggleConfig or {}
	ToggleConfig.Name = ToggleConfig.Name or "Toggle"
	ToggleConfig.Default = ToggleConfig.Default or false
	ToggleConfig.Callback = ToggleConfig.Callback or function() end
	ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
	ToggleConfig.Flag = ToggleConfig.Flag or nil
	ToggleConfig.Save = ToggleConfig.Save or false

	local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
	local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

	local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
		Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -24, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)
	}), {
		SetProps(MakeElement("Stroke"), {Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5}),
		SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
			Size = UDim2.new(0, 20, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0), ImageColor3 = Color3.fromRGB(255, 255, 255), Name = "Ico"
		}),
	})

	local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
		Size = UDim2.new(1, 0, 0, 38), Parent = ItemParent
	}), {
		AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
			Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
			Font = Enum.Font.GothamBold, Name = "Content"
		}), "Text"),
		AddThemeObject(MakeElement("Stroke"), "Stroke"), ToggleBox, Click
	}), "Second")

	function Toggle:Set(Value)
		Toggle.Value = Value
		TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
		TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
		TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
		ToggleConfig.Callback(Toggle.Value)
	end

	Toggle:Set(Toggle.Value)

	AddConnection(Click.MouseEnter, function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
	end)
	AddConnection(Click.MouseLeave, function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
	end)
	AddConnection(Click.MouseButton1Up, function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
		SaveCfg(game.GameId)
		Toggle:Set(not Toggle.Value)
	end)
	AddConnection(Click.MouseButton1Down, function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
	end)

	if ToggleConfig.Flag then OrionLib.Flags[ToggleConfig.Flag] = Toggle end
	return Toggle
end

function ElementFunction:AddSlider(SliderConfig)
	SliderConfig = SliderConfig or {}
	SliderConfig.Name = SliderConfig.Name or "Slider"
	SliderConfig.Min = SliderConfig.Min or 0
	SliderConfig.Max = SliderConfig.Max or 100
	SliderConfig.Increment = SliderConfig.Increment or 1
	SliderConfig.Default = SliderConfig.Default or 50
	SliderConfig.Callback = SliderConfig.Callback or function() end
	SliderConfig.ValueName = SliderConfig.ValueName or ""
	SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
	SliderConfig.Flag = SliderConfig.Flag or nil
	SliderConfig.Save = SliderConfig.Save or false

	local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
	local Dragging = false

	local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
		Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.3, ClipsDescendants = true
	}), {
		AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
			Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 12, 0, 6),
			Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0
		}), "Text")
	})

	local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
		Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 0, 30), BackgroundTransparency = 0.9
	}), {
		SetProps(MakeElement("Stroke"), {Color = SliderConfig.Color}),
		AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
			Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 12, 0, 6),
			Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0.8
		}), "Text"),
		SliderDrag
	})

	local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
		Size = UDim2.new(1, 0, 0, 65), Parent = ItemParent
	}), {
		AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
			Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 12, 0, 10),
			Font = Enum.Font.GothamBold, Name = "Content"
		}), "Text"),
		AddThemeObject(MakeElement("Stroke"), "Stroke"), SliderBar
	}), "Second")

	SliderBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then Dragging = true end
	end)
	SliderBar.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Dragging then
			local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
			Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
			SaveCfg(game.GameId)
		end
	end)

	function Slider:Set(Value)
		self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
		TweenService:Create(SliderDrag, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
		SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
		SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
		SliderConfig.Callback(self.Value)
	end

	Slider:Set(Slider.Value)
	if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = Slider end
	return Slider
end

function ElementFunction:AddDropdown(DropdownConfig)
	DropdownConfig = DropdownConfig or {}
	DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
	DropdownConfig.Options = DropdownConfig.Options or {}
	DropdownConfig.Default = DropdownConfig.Default or ""
	DropdownConfig.Callback = DropdownConfig.Callback or function() end
	DropdownConfig.Flag = DropdownConfig.Flag or nil
	DropdownConfig.Save = DropdownConfig.Save or false

	local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
	local MaxElements = 5

	if not table.find(Dropdown.Options, Dropdown.Value) then Dropdown.Value = "..." end
	local DropdownList = MakeElement("List")

	local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
		DropdownList
	}), {
		Parent = ItemParent, Position = UDim2.new(0, 0, 0, 38),
		Size = UDim2.new(1, 0, 1, -38), ClipsDescendants = true
	}), "Divider")

	local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

	local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
		Size = UDim2.new(1, 0, 0, 38), Parent = ItemParent, ClipsDescendants = true
	}), {
		DropdownContainer,
		SetProps(SetChildren(MakeElement("TFrame"), {
			AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
				Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
				Font = Enum.Font.GothamBold, Name = "Content"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
				Size = UDim2.new(0, 20, 0, 20), AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(1, -30, 0.5, 0), ImageColor3 = Color3.fromRGB(240, 240, 240), Name = "Ico"
			}), "TextDark"),
			AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
				Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.Gotham,
				Name = "Selected", TextXAlignment = Enum.TextXAlignment.Right
			}), "TextDark"),
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
				Name = "Line", Visible = false
			}), "Stroke"),
			Click
		}), {Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true, Name = "F"}),
		AddThemeObject(MakeElement("Stroke"), "Stroke"),
		MakeElement("Corner")
	}), "Second")

	AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
	end)

	local function AddOptions(Options)
		for _, Option in pairs(Options) do
			local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
				MakeElement("Corner", 0, 6),
				AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
					Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -8, 1, 0), Name = "Title"
				}), "Text")
			}), {
				Parent = DropdownContainer, Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1, ClipsDescendants = true
			}), "Divider")

			AddConnection(OptionBtn.MouseButton1Click, function()
				Dropdown:Set(Option)
				SaveCfg(game.GameId)
			end)

			Dropdown.Buttons[Option] = OptionBtn
		end
	end

	function Dropdown:Refresh(Options, Delete)
		if Delete then
			for _, v in pairs(Dropdown.Buttons) do v:Destroy() end
			table.clear(Dropdown.Options)
			table.clear(Dropdown.Buttons)
		end
		Dropdown.Options = Options
		AddOptions(Dropdown.Options)
	end

	function Dropdown:Set(Value)
		if not table.find(Dropdown.Options, Value) then
			Dropdown.Value = "..."
			DropdownFrame.F.Selected.Text = Dropdown.Value
			for _, v in pairs(Dropdown.Buttons) do
				TweenService:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
				TweenService:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
			end
			return
		end
		Dropdown.Value = Value
		DropdownFrame.F.Selected.Text = Dropdown.Value
		for _, v in pairs(Dropdown.Buttons) do
			TweenService:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			TweenService:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
		end
		TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
		TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		return DropdownConfig.Callback(Dropdown.Value)
	end

	AddConnection(Click.MouseButton1Click, function()
		Dropdown.Toggled = not Dropdown.Toggled
		DropdownFrame.F.Line.Visible = Dropdown.Toggled
		TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
		if #Dropdown.Options > MaxElements then
			TweenService:Create(DropdownFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
		else
			TweenService:Create(DropdownFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
		end
	end)

	Dropdown:Refresh(Dropdown.Options, false)
	Dropdown:Set(Dropdown.Value)
	if DropdownConfig.Flag then OrionLib.Flags[DropdownConfig.Flag] = Dropdown end
	return Dropdown
end

function ElementFunction:AddBind(BindConfig)
	BindConfig.Name = BindConfig.Name or "Bind"
	BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
	BindConfig.Hold = BindConfig.Hold or false
	BindConfig.Callback = BindConfig.Callback or function() end
	BindConfig.Flag = BindConfig.Flag or nil
	BindConfig.Save = BindConfig.Save or false

	local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
	local Holding = false
	local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

	local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
		Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)
	}), {
		AddThemeObject(MakeElement("Stroke"), "Stroke"),
		AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
			Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center, Name = "Value"
		}), "Text")
	}), "Main")

	local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
		Size = UDim2.new(1, 0, 0, 38), Parent = ItemParent
	}), {
		AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
			Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
			Font = Enum.Font.GothamBold, Name = "Content"
		}), "Text"),
		AddThemeObject(MakeElement("Stroke"), "Stroke"), BindBox, Click
	}), "Second")

	AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
		TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
	end)

	AddConnection(Click.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			if Bind.Binding then return end
			Bind.Binding = true
			BindBox.Value.Text = ""
		end
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if UserInputService:GetFocusedTextBox() then return end
		if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
			if BindConfig.Hold then
				Holding = true
				BindConfig.Callback(Holding)
			else
				BindConfig.Callback()
			end
		elseif Bind.Binding then
			local Key
			pcall(function() if not CheckKey(BlacklistedKeys, Input.KeyCode) then Key = Input.KeyCode end end)
			pcall(function() if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then Key = Input.UserInputType end end)
			Key = Key or Bind.Value
			Bind:Set(Key)
			SaveCfg(game.GameId)
		end
	end)

	AddConnection(UserInputService.InputEnded, function(Input)
		if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
			if BindConfig.Hold and Holding then
				Holding = false
				BindConfig.Callback(Holding)
			end
		end
	end)

	AddConnection(Click.MouseEnter, function()
		TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
	end)
	AddConnection(Click.MouseLeave, function()
		TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
	end)
	AddConnection(Click.MouseButton1Up, function()
		TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
	end)
	AddConnection(Click.MouseButton1Down, function()
		TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
	end)

	function Bind:Set(Key)
		Bind.Binding = false
		Bind.Value = Key or Bind.Value
		Bind.Value = Bind.Value.Name or Bind.Value
		BindBox.Value.Text = Bind.Value
	end

	Bind:Set(BindConfig.Default)
	if BindConfig.Flag then OrionLib.Flags[BindConfig.Flag] = Bind end
	return Bind
end

function ElementFunction:AddTextbox(TextboxConfig)
	TextboxConfig = TextboxConfig or {}
	TextboxConfig.Name = TextboxConfig.Name or "Textbox"
	TextboxConfig.Default = TextboxConfig.Default or ""
	TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
	TextboxConfig.Callback = TextboxConfig.Callback or function() end

	local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

	local TextboxActual = AddThemeObject(Create("TextBox", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255), PlaceholderColor3 = Color3.fromRGB(210, 210, 210),
		PlaceholderText = "Input", Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Center, TextSize = 14, ClearTextOnFocus = false
	}), "Text")

	local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
		Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)
	}), {
		AddThemeObject(MakeElement("Stroke"), "Stroke"), TextboxActual
	}), "Main")
				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38), Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold, Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer, Click
				}), "Second")

				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then TextboxActual.Text = "" end
				end)

				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
			end

			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false

				local ColorH, ColorS, ColorV = 1, 1, 1
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0), Visible = false, Image = "rbxassetid://4155801252"
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}), ColorSelection
				})
				local Hue = Create("Frame", {
					Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), Visible = false
				}, {
					Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
						ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
						ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
						ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
						ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
					}}),
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}), HueSelection
				})

				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1, ClipsDescendants = true
				}, {
					Hue, Color,
					Create("UIPadding", {
						PaddingLeft = UDim.new(0, 35), PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 17)
					})
				})

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")

				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38), Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold, Name = "Content"
						}), "Text"),
						ColorpickerBox, Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
							Name = "Line", Visible = false
						}), "Stroke"),
					}), {Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true, Name = "F"}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)

				local ColorInput, HueInput
				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
				ColorS = (math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
				ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if ColorInput then ColorInput:Disconnect() end
						ColorInput = AddConnection(RunService.RenderStepped, function()
							local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
							local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
							ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX; ColorV = 1 - ColorY
							UpdateColorPicker()
						end)
					end
				end)
				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if ColorInput then ColorInput:Disconnect() end
					end
				end)
				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if HueInput then HueInput:Disconnect() end
						HueInput = AddConnection(RunService.RenderStepped, function()
							local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
							HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
							ColorH = 1 - HueY
							UpdateColorPicker()
						end)
					end
				end)
				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if HueInput then HueInput:Disconnect() end
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end

				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
				return Colorpicker
			end

			return ElementFunction
		end

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 26), Parent = Container}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16), Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0), Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23), Name = "Holder"
				}), {MakeElement("List", 0, 6)}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do SectionFunction[i] = v end
			return SectionFunction
		end

		for i, v in next, GetElements(Container) do ElementFunction[i] = v end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do ElementFunction[i] = function() end end
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 1, 0), Parent = ItemParent}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 15, 0, 15), ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14), Position = UDim2.new(0, 38, 0, 18), TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14), Position = UDim2.new(0, 150, 0, 112), Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 12), {
					Size = UDim2.new(1, -200, 0, 14), Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true, TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction
	end

	return TabFunction
end

function OrionLib:Destroy() Orion:Destroy() end
function OrionLib:ToggleUi() Orion.Enabled = not Orion.Enabled end
-- ============================ YOUR APP CODE ============================
local Window = OrionLib:MakeWindow({
    Name = "Dragon Blox Full 2 V1.11",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TeleportConfig"
})

local Tab  = Window:MakeTab({Name = "Smart+Anti Band", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab1 = Window:MakeTab({Name = "Auto Farm👑", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab2 = Window:MakeTab({Name = "Dungeon", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab3 = Window:MakeTab({Name = "Auto Skill", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab4 = Window:MakeTab({Name = "Anti lag", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local BossFolder = workspace["World Mobs"]["Boss Mobs"]

local AutoMeta = false
local AutoPainsHurts = false
local AutoZero = false

local MetaTween = nil
local PainsHurtsTween = nil
local ZeroTween = nil

local TweenSpeed = 200

-- =========================================================
-- NÚT ORION LIB
-- =========================================================

Tab1:AddToggle({
    Name = "Auto set Meta",
    Default = false,
    Save = true,
    Flag = "AutoMeta",
    Callback = function(Value)
        AutoMeta = Value
        if not Value and MetaTween then
            pcall(function() MetaTween:Cancel() end)
            MetaTween = nil
        end
    end
})

Tab1:AddToggle({
    Name = "Auto Pains + Hurts",
    Default = false,
    Save = true,
    Flag = "AutoPainsHurts",
    Callback = function(Value)
        AutoPainsHurts = Value
        if not Value and PainsHurtsTween then
            pcall(function() PainsHurtsTween:Cancel() end)
            PainsHurtsTween = nil
        end
    end
})

Tab1:AddToggle({
    Name = "Auto set Zero",
    Default = false,
    Save = true,
    Flag = "AutoZero",
    Callback = function(Value)
        AutoZero = Value
        if not Value and ZeroTween then
            pcall(function() ZeroTween:Cancel() end)
            ZeroTween = nil
        end
    end
})

-- =========================================================
-- HÀM TWEEN CHUNG
-- =========================================================

local function GetRoot()
    local Character = Player.Character
    if not Character then Character = Player.CharacterAdded:Wait() end
    return Character:WaitForChild("HumanoidRootPart")
end

local function TweenTo(TargetCFrame, CurrentTweenName, IsEnabled)
    local Root = GetRoot()
    local Distance = (Root.Position - TargetCFrame.Position).Magnitude
    local Duration = Distance / TweenSpeed

    if Duration < 0.1 then
        if IsEnabled() then Root.CFrame = TargetCFrame end
        return true, nil
    end

    local Tween = TweenService:Create(
        Root,
        TweenInfo.new(Duration, Enum.EasingStyle.Linear),
        {CFrame = TargetCFrame}
    )

    if CurrentTweenName == "Meta" then MetaTween = Tween
    elseif CurrentTweenName == "PainsHurts" then PainsHurtsTween = Tween
    elseif CurrentTweenName == "Zero" then ZeroTween = Tween end

    Tween:Play()

    while IsEnabled() and Tween.PlaybackState == Enum.PlaybackState.Playing do
        if not Root.Parent or Player.Character ~= Root.Parent then
            pcall(function() Tween:Cancel() end)
            return false, nil
        end
        task.wait()
    end

    if not IsEnabled() then
        pcall(function() Tween:Cancel() end)
        return false, nil
    end

    if Root.Parent and Player.Character == Root.Parent then
        Root.CFrame = TargetCFrame
    end

    return true, nil
end

-- =========================================================
-- AUTO META
-- Meta Chromest -> Meta Coolest -> Meta Amythest
-- =========================================================

task.spawn(function()
    local CurrentIndex = 1
    local BossData = {
        {Name = "Meta Chromest", Position = CFrame.new(-2949.98657, 44.359993, 113.719284, 1,0,0, 0,1,0, 0,0,1)},
        {Name = "Meta Coolest",  Position = CFrame.new(-1997.33386, 80.0019531, -2640.44287, 1,0,0, 0,1,0, 0,0,1)},
        {Name = "Meta Amythest", Position = CFrame.new(1344.54321, 75.0019531, -2866.45361, 1,0,0, 0,1,0, 0,0,1)}
    }

    while true do
        if not AutoMeta then task.wait(0.2) continue end

        local Data = BossData[CurrentIndex]
        local Root = GetRoot()
        local Distance = (Root.Position - Data.Position.Position).Magnitude

        if Distance > 3 then
            local Success = TweenTo(Data.Position, "Meta", function() return AutoMeta end)
            if not Success then task.wait(0.2) continue end
        end

        local Boss = BossFolder:FindFirstChild(Data.Name)
        if Boss then
            local Humanoid = Boss:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health <= 0 then
                task.wait(2)
                if AutoMeta then
                    CurrentIndex += 1
                    if CurrentIndex > #BossData then CurrentIndex = 1 end
                end
            else
                task.wait(0.2)
            end
        else
            task.wait(0.2)
        end
    end
end)

-- =========================================================
-- AUTO PAINS + HURTS
-- =========================================================

task.spawn(function()
    local CurrentIndex = 1
    local BossData = {
        {Name = "Pains", Position = CFrame.new(5435.41064, 502.409637, 741.838013, 1,0,0, 0,1,0, 0,0,1)},
        {Name = "Hurts", Position = CFrame.new(2733.07642, 101.598831, 426.639465, 1,0,0, 0,1,0, 0,0,1)}
    }

    while true do
        if not AutoPainsHurts then task.wait(0.2) continue end

        local Data = BossData[CurrentIndex]
        local Root = GetRoot()
        local Distance = (Root.Position - Data.Position.Position).Magnitude

        if Distance > 3 then
            local Success = TweenTo(Data.Position, "PainsHurts", function() return AutoPainsHurts end)
            if not Success then task.wait(0.2) continue end
        end

        local Boss = BossFolder:FindFirstChild(Data.Name)
        if Boss then
            local Humanoid = Boss:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health <= 0 then
                task.wait(2)
                if AutoPainsHurts then
                    CurrentIndex += 1
                    if CurrentIndex > #BossData then CurrentIndex = 1 end
                end
            else
                task.wait(0.2)
            end
        else
            task.wait(0.2)
        end
    end
end)

-- =========================================================
-- AUTO ZERO
-- =========================================================

task.spawn(function()
    local TargetPosition = CFrame.new(2204.00586, 45.5981483, -4348.96826, 1,0,0, 0,1,0, 0,0,1)

    while true do
        if not AutoZero then task.wait(0.2) continue end
        local Root = GetRoot()
        local Distance = (Root.Position - TargetPosition.Position).Magnitude
        if Distance > 3 then
            TweenTo(TargetPosition, "Zero", function() return AutoZero end)
        end
        task.wait(0.5)
    end
end)

-- =========================================================
-- AUTO PICKUP
-- =========================================================
local AutoPickup = false

Tab1:AddToggle({
    Name = "Auto pickup Support Farm full set",
    Default = false,
    Save = true,
    Callback = function(Value)
        AutoPickup = Value
        if Value then
            task.spawn(function()
                while AutoPickup do
                    local Player = game.Players.LocalPlayer
                    local Character = Player.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not AutoPickup then break end
                            if v:IsA("ProximityPrompt") then
                                local Part = v.Parent
                                if Part and Part:IsA("BasePart") then
                                    if (Root.Position - Part.Position).Magnitude <= 100 then
                                        fireproximityprompt(v)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

OrionLib:Init()

-- =========================================================
-- ANTI FALL
-- =========================================================
local RunService = game:GetService("RunService")
local FloatEnabled = false
local FloatConnection
local BV

local function removeFloat()
    if FloatConnection then FloatConnection:Disconnect() FloatConnection = nil end
    if BV then BV:Destroy() BV = nil end
end

local function setupFloat(Character)
    removeFloat()
    local Root = Character:WaitForChild("HumanoidRootPart", 5)
    if not Root then return end
    BV = Instance.new("BodyVelocity")
    BV.Name = "ContinuousFloat"
    BV.MaxForce = Vector3.new(0, math.huge, 0)
    BV.Velocity = Vector3.zero
    BV.Parent = Root
    FloatConnection = RunService.Heartbeat:Connect(function()
        if FloatEnabled and BV and BV.Parent and Root.Parent then
            BV.Velocity = Vector3.zero
        end
    end)
end

Tab1:AddToggle({
    Name = "Anti Fall Support Tween",
    Default = false,
    Save = true,
    Callback = function(Value)
        FloatEnabled = Value
        if Value then
            local Character = Player.Character
            if Character then setupFloat(Character) end
        else
            removeFloat()
        end
    end
})

Player.CharacterAdded:Connect(function(Character)
    task.wait(0.5)
    if FloatEnabled then setupFloat(Character) end
end)

OrionLib:Init()

-- =========================================================
-- TIME STOP BUTTON
-- =========================================================
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Gui = Instance.new("ScreenGui")
Gui.Name = "Skill126Gui"
Gui.ResetOnSpawn = false
Gui.Enabled = false
Gui.Parent = LP:WaitForChild("PlayerGui")

local SkillButton = Instance.new("TextButton")
SkillButton.Name = "Skill126Button"
SkillButton.Size = UDim2.new(0, 150, 0, 50)
SkillButton.Position = UDim2.new(0.5, -75, 0.8, 0)
SkillButton.BackgroundTransparency = 0.1
SkillButton.Text = "Time stop"
SkillButton.TextSize = 18
SkillButton.TextColor3 = Color3.new(1, 1, 1)
SkillButton.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = SkillButton

SkillButton.MouseButton1Click:Connect(function()
    local args = {
        {
            Camera = CFrame.new(
                74.2727279663086, 251.0009002685547, -28.747745513916016,
                -0.9511321783065796, -0.044049736112356186, 0.3056260347366333,
                0, 0.9897724390029907, 0.14265543222427368,
                -0.308784157037735, 0.13568417727947235, -0.9414043426513672
            ),
            SkillId = "126",
            Began = true,
            CFrame = CFrame.new(70.45240020751953, 247.81771850585938, -16.98019027709961, 1,0,0, 0,1,0, 0,0,1),
            ["Typ\208\181"] = 1,
            Aim = vector.create(70.45240020751953, 247.81771850585938, -66.98019409179688)
        }
    }
    RS:WaitForChild("Remotes"):WaitForChild("SkillRemote"):FireServer(unpack(args))
end)

Tab1:AddToggle({
    Name = "Time stop wis",
    Default = false,
    Callback = function(Value) Gui.Enabled = Value end
})

OrionLib:Init()

-- =========================================================
-- AUTO M1
-- =========================================================
local AutoSkill = false

Tab:AddToggle({
    Name = "Auto M1",
    Default = false,
    Save = true,
    Callback = function(Value)
        AutoSkill = Value
        if Value then
            task.spawn(function()
                while AutoSkill do
                    local args = {
                        [1] = {
                            ["Camera"] = CFrame.new(
                                1436.56982421875, 610.5719604492188, -2926.40576171875,
                                0.4276675879955292, 0.8082790374755859, -0.404704213142395,
                                0, 0.44771331548690796, 0.8941771984100342,
                                0.9039360880851746, -0.38241061568260193, 0.19147247076034546
                            ),
                            ["SkillId"] = "1",
                            ["Began"] = true,
                            ["CFrame"] = CFrame.new(
                                1441.628662109375, 597.61474609375, -2928.799072265625,
                                0.4534393846988678, -9.274389611846345e-08, -0.891287088394165,
                                2.6512436690495633e-08, 1, -9.056802241502737e-08,
                                0.891287088394165, 1.7436915911162032e-08, 0.4534393846988678
                            ),
                            ["Typ\208\181"] = 1,
                            ["Aim"] = Vector3.new(1486.1929931640625, 597.61474609375, -2951.470947265625)
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote"):FireServer(unpack(args))
                    task.wait(0.151)
                end
            end)
        end
    end
})

OrionLib:Init()

-- =========================================================
-- AURA KILL ENERGY BLAST V2
-- =========================================================
local WorldMobs = workspace:WaitForChild("World Mobs")
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")

local AuraEnabled = false

local function GetRandomMob()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Mobs = {}
    for _, Mob in ipairs(WorldMobs:GetDescendants()) do
        if Mob:IsA("Model") then
            local Humanoid = Mob:FindFirstChildOfClass("Humanoid")
            local MobRoot = Mob:FindFirstChild("HumanoidRootPart")
                or Mob.PrimaryPart
                or Mob:FindFirstChildWhichIsA("BasePart")
            if Humanoid and MobRoot and Humanoid.Health > 0 then
                local Distance = (Root.Position - MobRoot.Position).Magnitude
                if Distance <= 400 then
                    table.insert(Mobs, Mob)
                end
            end
        end
    end
    if #Mobs > 0 then return Mobs[math.random(1, #Mobs)] end
    return nil
end

Tab:AddToggle({
    Name = "Aura Kill Energy Blast V2",
    Default = false,
    Callback = function(Value)
        AuraEnabled = Value
        if AuraEnabled then
            task.spawn(function()
                while AuraEnabled do
                    task.wait(0.16)
                    local Character = Player.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        local RandomMob = GetRandomMob()
                        if RandomMob then
                            local MobRoot = RandomMob:FindFirstChild("HumanoidRootPart")
                                or RandomMob.PrimaryPart
                                or RandomMob:FindFirstChildWhichIsA("BasePart")
                            if MobRoot then
                                local TargetPosition = MobRoot.Position
                                local SkillCFrame = CFrame.lookAt(
                                    Root.Position,
                                    Vector3.new(TargetPosition.X, Root.Position.Y, TargetPosition.Z)
                                )
                                local args = {
                                    [1] = {
                                        ["Camera"] = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, TargetPosition),
                                        ["SkillId"] = "101",
                                        ["Began"] = true,
                                        ["CFrame"] = SkillCFrame,
                                        ["Typ\208\181"] = 1,
                                        ["Aim"] = TargetPosition
                                    }
                                }
                                SkillRemote:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- =========================================================
-- AUTO LOCK RANDOM MOB
-- =========================================================
local LockedOnChanged = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("SkillManager")
    :WaitForChild("RE")
    :WaitForChild("LockedOnChanged")

local AutoLockRandomMob = false

local function GetRandomMobLock()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local ValidMobs = {}
    for _, Mob in ipairs(WorldMobs:GetDescendants()) do
        if Mob:IsA("Model") then
            local Humanoid = Mob:FindFirstChildOfClass("Humanoid")
            local MobRoot = Mob:FindFirstChild("HumanoidRootPart")
                or Mob.PrimaryPart
                or Mob:FindFirstChildWhichIsA("BasePart")
            if Humanoid and MobRoot and Humanoid.Health > 0 then
                local Distance = (Root.Position - MobRoot.Position).Magnitude
                if Distance <= 400 then
                    table.insert(ValidMobs, Mob)
                end
            end
        end
    end
    if #ValidMobs > 0 then return ValidMobs[math.random(1, #ValidMobs)] end
    return nil
end

Tab:AddToggle({
    Name = "Auto Lock Random Mob",
    Default = false,
    Callback = function(Value)
        AutoLockRandomMob = Value
        if Value then
            task.spawn(function()
                while AutoLockRandomMob do
                    local RandomMob = GetRandomMobLock()
                    if RandomMob then
                        LockedOnChanged:FireServer(RandomMob)
                    end
                    task.wait(0.4)
                end
            end)
        end
    end
})

-- =========================================================
-- AUTO KILL ZAJA
-- =========================================================
local EventMobs = WorldMobs:WaitForChild("Event Mobs")

local AutoZaja = false
local CurrentTween = nil

local function GetZaja()
    local Zaja = EventMobs:FindFirstChild("Zaja")
    if not Zaja then return nil end
    local Humanoid = Zaja:FindFirstChildOfClass("Humanoid")
    local Root = Zaja:FindFirstChild("HumanoidRootPart")
        or Zaja.PrimaryPart
        or Zaja:FindFirstChildWhichIsA("BasePart")
    if not Humanoid or not Root or Humanoid.Health <= 0 then return nil end
    return Zaja, Humanoid, Root
end

local function GetDistancePosition(PlayerRoot, ZajaRoot)
    local Direction = PlayerRoot.Position - ZajaRoot.Position
    if Direction.Magnitude <= 0.1 then
        Direction = Vector3.new(0, 0, 1)
    else
        Direction = Direction.Unit
    end
    local Position = ZajaRoot.Position + (Direction * 500)
    return CFrame.lookAt(
        Position,
        Vector3.new(ZajaRoot.Position.X, Position.Y, ZajaRoot.Position.Z)
    )
end

local function TweenToZaja(PlayerRoot, ZajaRoot)
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    local TargetCFrame = GetDistancePosition(PlayerRoot, ZajaRoot)
    local Distance = (PlayerRoot.Position - TargetCFrame.Position).Magnitude
    local Time = Distance / 220
    CurrentTween = TweenService:Create(
        PlayerRoot,
        TweenInfo.new(math.max(Time, 0.05), Enum.EasingStyle.Linear),
        {CFrame = TargetCFrame}
    )
    CurrentTween:Play()
end

Tab1:AddToggle({
    Name = "Auto kill Zaja",
    Default = false,
    Callback = function(Value)
        AutoZaja = Value
        if not Value then
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
            return
        end

        -- Luồng di chuyển
        task.spawn(function()
            while AutoZaja do
                local Character = Player.Character
                local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")
                local Zaja, Humanoid, ZajaRoot = GetZaja()
                if PlayerRoot and Zaja and Humanoid.Health > 0 then
                    local Distance = (PlayerRoot.Position - ZajaRoot.Position).Magnitude
                    if math.abs(Distance - 500) > 25 then
                        TweenToZaja(PlayerRoot, ZajaRoot)
                    end
                else
                    if CurrentTween then
                        CurrentTween:Cancel()
                        CurrentTween = nil
                    end
                end
                task.wait(0.3)
            end
        end)

        -- Luồng LockOn
        task.spawn(function()
            while AutoZaja do
                local Zaja = GetZaja()
                if Zaja then
                    LockedOnChanged:FireServer(Zaja)
                end
                task.wait(0.2)
            end
        end)

        -- Luồng bắn Skill 101
        task.spawn(function()
            while AutoZaja do
                local Character = Player.Character
                local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")
                local Zaja, Humanoid, ZajaRoot = GetZaja()
                if PlayerRoot and Zaja and ZajaRoot then
                    local TargetPosition = ZajaRoot.Position
                    local args = {
                        [1] = {
                            ["Camera"] = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, TargetPosition),
                            ["SkillId"] = "101",
                            ["Began"] = true,
                            ["CFrame"] = CFrame.lookAt(
                                PlayerRoot.Position,
                                Vector3.new(TargetPosition.X, PlayerRoot.Position.Y, TargetPosition.Z)
                            ),
                            ["Typ\208\181"] = 1,
                            ["Aim"] = TargetPosition
                        }
                        }
                    }
                    SkillRemote:FireServer(unpack(args))
                end
                task.wait(0.18)
            end
        end)
    end
})

    end
end
