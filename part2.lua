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
