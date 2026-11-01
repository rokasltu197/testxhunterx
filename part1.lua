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
