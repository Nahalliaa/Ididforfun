local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// 1. Theme & Registry System //--
Library.Theme = {
	MainColor = Color3.fromRGB(255, 217, 78),
	BackgroundColor = Color3.fromRGB(12, 12, 12),
	SecondaryColor = Color3.fromRGB(25, 25, 25),
	TextColor = Color3.fromRGB(235, 255, 103),
	TextSelected = Color3.fromRGB(10, 10, 10),
	
	--// EDITED: Separated Toggle Settings //--
	ToggleOn = Color3.fromRGB(255, 217, 78),  -- Color when enabled
	ToggleOff = Color3.fromRGB(20, 20, 20),   -- Color of the box background
	
	Gradient1 = Color3.fromRGB(46, 43, 0),
	Gradient2 = Color3.fromRGB(6, 6, 6),
}

-- Registry to update colors dynamically (for RGB/Rainbow)
Library.ThemeObjects = {} 
Library.RainbowMode = false
Library.RainbowSpeed = 10

function Library:AddToRegistry(instance, property, themeKey)
	table.insert(Library.ThemeObjects, {
		Obj = instance,
		Prop = property,
		Key = themeKey
	})
end

-- Rainbow/Gradient Loop
task.spawn(function()
	while true do
		if Library.RainbowMode then
			local hue = tick() % Library.RainbowSpeed / Library.RainbowSpeed
			local color = Color3.fromHSV(hue, 0.8, 1)
			Library.Theme.MainColor = color
			
			-- Optional: If you want Toggles to also be rainbow, uncomment the line below:
			-- Library.Theme.ToggleOn = color 

			for _, reg in pairs(Library.ThemeObjects) do
				-- Updates MainColor and ToggleOn if you set it to rainbow
				if (reg.Key == "MainColor" or (Library.RainbowMode and reg.Key == "ToggleOn")) and reg.Obj then
					TweenService:Create(reg.Obj, TweenInfo.new(0.1), {[reg.Prop] = color}):Play()
				end
			end
		end
		task.wait(0.05)
	end
end)

--// Utility Functions //--
local function addHoverEffect(guiObject, stroke, baseThickness)
	baseThickness = baseThickness or 0.7
	local scale = guiObject:FindFirstChild("UIScale") or Instance.new("UIScale")
	scale.Parent = guiObject
	
	guiObject.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Scale = 1.02}):Play()
		if stroke then TweenService:Create(stroke, TweenInfo.new(0.15), {Thickness = baseThickness + 1}):Play() end
	end)

	guiObject.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Scale = 1}):Play()
		if stroke then TweenService:Create(stroke, TweenInfo.new(0.15), {Thickness = baseThickness}):Play() end
	end)
end

local function makeDraggable(frame, dragHandle)
	local dragging, dragInput, dragStart, startPos
	
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {Position = newPos}):Play()
		end
	end)
end

--// Main Window //--
function Library:CreateWindow(titleText)
	local Window = {}
	local Theme = Library.Theme
	
	-- GUI Setup
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LynixUI_V2"
	ScreenGui.Parent = (game:GetService("RunService"):IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui")) or (gethui and gethui()) or CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MainFrame.Position = UDim2.new(0.5, -230, 0.5, -125)
	MainFrame.Size = UDim2.new(0, 461, 0, 251)
	MainFrame.ClipsDescendants = true
	
	-- Intro Animation
	MainFrame.Size = UDim2.new(0, 461, 0, 0)
	TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 461, 0, 251)}):Play()

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 9)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Parent = MainFrame
	MainStroke.Thickness = 1
	MainStroke.Color = Theme.MainColor
	Library:AddToRegistry(MainStroke, "Color", "MainColor")

	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Theme.Gradient1),
		ColorSequenceKeypoint.new(1.00, Theme.Gradient2)
	}
	UIGradient.Rotation = 40
	UIGradient.Parent = MainFrame

	-- Top Bar
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Parent = MainFrame
	TopBar.BackgroundTransparency = 1
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = TopBar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0.045, 0, 0, 0)
	TitleLabel.Size = UDim2.new(0, 200, 1, 0)
	TitleLabel.Font = Enum.Font.FredokaOne
	TitleLabel.Text = titleText or "Lynix"
	TitleLabel.TextColor3 = Theme.MainColor
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	Library:AddToRegistry(TitleLabel, "TextColor3", "MainColor")

	-- Buttons Container
	local WindowButtons = Instance.new("Frame")
	WindowButtons.Parent = TopBar
	WindowButtons.BackgroundTransparency = 1
	WindowButtons.AnchorPoint = Vector2.new(1, 0.5)
	WindowButtons.Position = UDim2.new(1, -10, 0.5, 0)
	WindowButtons.Size = UDim2.new(0, 70, 0, 24)

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Parent = WindowButtons
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Position = UDim2.new(1, -24, 0, 0)
	CloseBtn.Size = UDim2.new(0, 24, 0, 24)
	CloseBtn.Image = "rbxassetid://103094495394151"
	CloseBtn.ImageColor3 = Theme.MainColor
	Library:AddToRegistry(CloseBtn, "ImageColor3", "MainColor")
	
	local MinBtn = Instance.new("ImageButton")
	MinBtn.Parent = WindowButtons
	MinBtn.BackgroundTransparency = 1
	MinBtn.Position = UDim2.new(1, -54, 0, 0)
	MinBtn.Size = UDim2.new(0, 24, 0, 24)
	MinBtn.Image = "rbxassetid://80500837074519"
	MinBtn.ImageColor3 = Theme.MainColor
	Library:AddToRegistry(MinBtn, "ImageColor3", "MainColor")

	local Divider = Instance.new("Frame")
	Divider.Parent = MainFrame
	Divider.BackgroundColor3 = Theme.MainColor
	Divider.BorderSizePixel = 0
	Divider.Position = UDim2.new(0, 0, 0, 40)
	Divider.Size = UDim2.new(1, 0, 0, 1)
	Library:AddToRegistry(Divider, "BackgroundColor3", "MainColor")

	makeDraggable(MainFrame, TopBar)

	-- Content Containers
	local TabContainer = Instance.new("Frame")
	TabContainer.Parent = MainFrame
	TabContainer.BackgroundColor3 = Theme.BackgroundColor
	TabContainer.BackgroundTransparency = 0.9
	TabContainer.Position = UDim2.new(0.024, 0, 0.2, 0)
	TabContainer.Size = UDim2.new(0, 107, 0, 189)
	Instance.new("UICorner", TabContainer)
	
	local TabStroke = Instance.new("UIStroke")
	TabStroke.Parent = TabContainer
	TabStroke.Thickness = 0.7
	TabStroke.Color = Theme.MainColor
	Library:AddToRegistry(TabStroke, "Color", "MainColor")

	local PageContainer = Instance.new("Frame")
	PageContainer.Parent = MainFrame
	PageContainer.BackgroundColor3 = Theme.BackgroundColor
	PageContainer.BackgroundTransparency = 0.9
	PageContainer.Position = UDim2.new(0.277, 0, 0.2, 0)
	PageContainer.Size = UDim2.new(0, 323, 0, 189)
	PageContainer.ClipsDescendants = true
	Instance.new("UICorner", PageContainer)

	local PageStroke = Instance.new("UIStroke")
	PageStroke.Parent = PageContainer
	PageStroke.Thickness = 0.7
	PageStroke.Color = Theme.MainColor
	Library:AddToRegistry(PageStroke, "Color", "MainColor")
	
	-- Close/Min Logic
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	local minimized = false
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			TabContainer.Visible = false
			PageContainer.Visible = false
			Divider.Visible = false
			MainFrame:TweenSize(UDim2.new(0, 461, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
		else
			MainFrame:TweenSize(UDim2.new(0, 461, 0, 251), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
			task.wait(0.2)
			if not minimized then
				Divider.Visible = true
				TabContainer.Visible = true
				PageContainer.Visible = true
			end
		end
	end)

	--// Mobile / Settings //--
	local MobileBtn = nil
	
	function Window:ToggleRainbow(bool)
		Library.RainbowMode = bool
	end
	
	-- Update Main Color specifically
	function Window:SetMainColor(color)
		Library.RainbowMode = false
		Library.Theme.MainColor = color
		for _, reg in pairs(Library.ThemeObjects) do
			if reg.Key == "MainColor" and reg.Obj then
				TweenService:Create(reg.Obj, TweenInfo.new(0.3), {[reg.Prop] = color}):Play()
			end
		end
	end
	
	--// NEW: Update any theme key (Use this to change Toggle colors) //--
	function Window:UpdateThemeKey(key, color)
		if Library.Theme[key] then
			Library.Theme[key] = color
			for _, reg in pairs(Library.ThemeObjects) do
				if reg.Key == key and reg.Obj then
					TweenService:Create(reg.Obj, TweenInfo.new(0.3), {[reg.Prop] = color}):Play()
				end
			end
		end
	end

	function Window:CreateMobileButton(iconId)
		MobileBtn = Instance.new("ImageButton")
		MobileBtn.Name = "MobileToggle"
		MobileBtn.Parent = ScreenGui
		MobileBtn.BackgroundColor3 = Theme.BackgroundColor
		MobileBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
		MobileBtn.Size = UDim2.new(0, 50, 0, 50) 
		MobileBtn.Image = iconId or "rbxassetid://18636968846"
		MobileBtn.ImageColor3 = Theme.MainColor
		Library:AddToRegistry(MobileBtn, "ImageColor3", "MainColor")
		
		local MBStroke = Instance.new("UIStroke")
		MBStroke.Parent = MobileBtn
		MBStroke.Color = Theme.MainColor
		MBStroke.Thickness = 1.5
		Library:AddToRegistry(MBStroke, "Color", "MainColor")
		
		Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(0.3, 0)
		makeDraggable(MobileBtn, MobileBtn)
		
		local open = true
		MobileBtn.MouseButton1Click:Connect(function()
			open = not open
			TweenService:Create(MobileBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Rotation = open and 0 or 180}):Play()
			
			if open then
				MainFrame.Visible = true
				MainFrame.BackgroundTransparency = 1
				MainFrame.Position = MainFrame.Position + UDim2.new(0,0,0,50)
				
				local fadeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0})
				local slideTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = MainFrame.Position - UDim2.new(0,0,0,50)})
				fadeTween:Play()
				slideTween:Play()
				
				for _, c in pairs(MainFrame:GetChildren()) do
					if c:IsA("GuiObject") and c.Name ~= "UICorner" and c.Name ~= "UIStroke" and c.Name ~= "UIGradient" then
						TweenService:Create(c, TweenInfo.new(0.3), {BackgroundTransparency = (c.Name == "TopBar" and 1 or c.Name == "Divider" and 0 or 0.9)}):Play()
						if c:IsA("TextLabel") or c:IsA("ImageButton") then
							TweenService:Create(c, TweenInfo.new(0.3), {TextTransparency = 0, ImageTransparency = 0}):Play()
						end
					end
				end
			else
				local fadeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
				fadeTween:Play()
				fadeTween.Completed:Connect(function()
					if not open then MainFrame.Visible = false end
				end)
				
				for _, c in pairs(MainFrame:GetChildren()) do
					if c:IsA("GuiObject") then
						TweenService:Create(c, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
						if c:IsA("TextLabel") or c:IsA("ImageButton") then
							TweenService:Create(c, TweenInfo.new(0.2), {TextTransparency = 1, ImageTransparency = 1}):Play()
						end
					end
				end
			end
		end)
	end

	--// Tab System //--
	local tabs = {}
	local firstTab = true
	
	function Window:CreateTab(name)
		local Tab = {}
		
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name.."_Btn"
		TabBtn.Parent = TabContainer
		TabBtn.BackgroundColor3 = Theme.BackgroundColor
		TabBtn.Size = UDim2.new(0, 88, 0, 32)
		TabBtn.Font = Enum.Font.FredokaOne
		TabBtn.Text = name
		TabBtn.TextColor3 = Theme.TextColor
		TabBtn.TextSize = 14
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,3)
		
		local TStroke = Instance.new("UIStroke")
		TStroke.Parent = TabBtn
		TStroke.Thickness = 0.7
		TStroke.Color = Theme.MainColor
		Library:AddToRegistry(TStroke, "Color", "MainColor")
		
		addHoverEffect(TabBtn, TStroke)
		
		if not TabContainer:FindFirstChild("UIListLayout") then
			local list = Instance.new("UIListLayout")
			list.Parent = TabContainer
			list.HorizontalAlignment = Enum.HorizontalAlignment.Center
			list.Padding = UDim.new(0, 10)
			list.SortOrder = Enum.SortOrder.LayoutOrder
			local pad = Instance.new("UIPadding")
			pad.Parent = TabContainer
			pad.PaddingTop = UDim.new(0, 10)
		end
		
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name.."_Page"
		Page.Parent = PageContainer
		Page.BackgroundTransparency = 1
		Page.Size = UDim2.new(1,0,1,0)
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.MainColor
		Page.Visible = false
		Library:AddToRegistry(Page, "ScrollBarImageColor3", "MainColor")
		
		local PLayout = Instance.new("UIListLayout")
		PLayout.Parent = Page
		PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		PLayout.Padding = UDim.new(0, 6)
		PLayout.SortOrder = Enum.SortOrder.LayoutOrder
		
		local PPad = Instance.new("UIPadding")
		PPad.Parent = Page
		PPad.PaddingTop = UDim.new(0, 10)
		PPad.PaddingBottom = UDim.new(0, 10)
		
		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(tabs) do
				t.Page.Visible = false
				TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundColor, TextColor3 = Theme.TextColor}):Play()
			end
			Page.Visible = true
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainColor, TextColor3 = Theme.TextSelected}):Play()
		end)
		
		if firstTab then
			firstTab = false
			Page.Visible = true
			TabBtn.BackgroundColor3 = Theme.MainColor
			TabBtn.TextColor3 = Theme.TextSelected
		end
		
		table.insert(tabs, {Btn = TabBtn, Page = Page})
		
		local function CreateBaseFrame(height)
			local F = Instance.new("Frame")
			F.Parent = Page
			F.BackgroundColor3 = Theme.BackgroundColor
			F.Size = UDim2.new(0, 300, 0, height or 38)
			Instance.new("UICorner", F).CornerRadius = UDim.new(0,3)
			
			local S = Instance.new("UIStroke")
			S.Parent = F
			S.Thickness = 0.7
			S.Color = Theme.MainColor
			Library:AddToRegistry(S, "Color", "MainColor")
			
			addHoverEffect(F, S)
			return F
		end

		--// 1. Toggle (Updated for Separate Colors) //--
		function Tab:CreateToggle(text, callback)
			callback = callback or function() end
			local toggled = false
			local Frame = CreateBaseFrame(38)
			
			local Label = Instance.new("TextLabel")
			Label.Parent = Frame
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0.04, 0, 0, 0)
			Label.Size = UDim2.new(0.7, 0, 1, 0)
			Label.Font = Enum.Font.FredokaOne
			Label.Text = text
			Label.TextColor3 = Theme.TextColor
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			
			local CheckBg = Instance.new("Frame")
			CheckBg.Parent = Frame
			CheckBg.BackgroundColor3 = Theme.ToggleOff -- Using new separated key
			CheckBg.Position = UDim2.new(0.88, 0, 0.5, -9)
			CheckBg.Size = UDim2.new(0, 18, 0, 18)
			Instance.new("UICorner", CheckBg).CornerRadius = UDim.new(0,4)
			Library:AddToRegistry(CheckBg, "BackgroundColor3", "ToggleOff") -- Register it
			
			local CheckInd = Instance.new("Frame")
			CheckInd.Parent = CheckBg
			CheckInd.BackgroundColor3 = Theme.ToggleOn -- Using new separated key
			CheckInd.Size = UDim2.new(1,0,1,0)
			CheckInd.BackgroundTransparency = 1 -- Start hidden (Off)
			Instance.new("UICorner", CheckInd).CornerRadius = UDim.new(0,4)
			Library:AddToRegistry(CheckInd, "BackgroundColor3", "ToggleOn") -- Register it
			
			local Trigger = Instance.new("TextButton")
			Trigger.Parent = Frame
			Trigger.BackgroundTransparency = 1
			Trigger.Size = UDim2.new(1,0,1,0)
			Trigger.Text = ""
			
			Trigger.MouseButton1Click:Connect(function()
				toggled = not toggled
				-- We just change transparency of the 'On' frame
				local targetAlpha = toggled and 0 or 1
				TweenService:Create(CheckInd, TweenInfo.new(0.2), {BackgroundTransparency = targetAlpha}):Play()
				callback(toggled)
			end)
		end
		
		-- 2. Button
		function Tab:CreateButton(text, callback)
			callback = callback or function() end
			local Frame = CreateBaseFrame(38)
			
			local Label = Instance.new("TextLabel")
			Label.Parent = Frame
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0.04, 0, 0, 0)
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.Font = Enum.Font.FredokaOne
			Label.Text = text
			Label.TextColor3 = Theme.TextColor
			Label.TextSize = 14
			
			local Icon = Instance.new("ImageLabel")
			Icon.Parent = Frame
			Icon.BackgroundTransparency = 1
			Icon.Position = UDim2.new(0.9, -5, 0.5, -10)
			Icon.Size = UDim2.new(0, 20, 0, 20)
			Icon.Image = "rbxassetid://110620726041573"
			Icon.ImageColor3 = Theme.MainColor
			Library:AddToRegistry(Icon, "ImageColor3", "MainColor")
			
			local Trigger = Instance.new("TextButton")
			Trigger.Parent = Frame
			Trigger.BackgroundTransparency = 1
			Trigger.Size = UDim2.new(1,0,1,0)
			Trigger.Text = ""
			
			Trigger.MouseButton1Click:Connect(function()
				TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SecondaryColor}):Play()
				task.wait(0.1)
				TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BackgroundColor}):Play()
				callback()
			end)
		end
		
		-- 3. Slider
		function Tab:CreateSlider(text, min, max, default, callback)
			callback = callback or function() end
			local value = default or min
			local Frame = CreateBaseFrame(55)
			
			local Label = Instance.new("TextLabel")
			Label.Parent = Frame
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0.04, 0, 0.1, 0)
			Label.Size = UDim2.new(0.9, 0, 0, 20)
			Label.Font = Enum.Font.FredokaOne
			Label.Text = text .. ": " .. value
			Label.TextColor3 = Theme.TextColor
			Label.TextSize = 12
			Label.TextXAlignment = Enum.TextXAlignment.Left
			
			local Bar = Instance.new("Frame")
			Bar.Parent = Frame
			Bar.BackgroundColor3 = Theme.SecondaryColor
			Bar.Position = UDim2.new(0.04, 0, 0.65, 0)
			Bar.Size = UDim2.new(0.92, 0, 0, 6)
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
			
			local Fill = Instance.new("Frame")
			Fill.Parent = Bar
			Fill.BackgroundColor3 = Theme.MainColor
			Fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)
			Library:AddToRegistry(Fill, "BackgroundColor3", "MainColor")
			
			local Trigger = Instance.new("TextButton")
			Trigger.Parent = Frame
			Trigger.BackgroundTransparency = 1
			Trigger.Size = UDim2.new(1,0,1,0)
			Trigger.Text = ""
			
			local dragging = false
			local function update(input)
				local pos = math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
				local pct = pos / Bar.AbsoluteSize.X
				value = math.floor(min + (max-min)*pct)
				Label.Text = text .. ": " .. value
				TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(pct,0,1,0)}):Play()
				callback(value)
			end
			
			Trigger.InputBegan:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(i)
				end
			end)
			Trigger.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
			end)
		end
		
		-- 4. Text Input
		function Tab:CreateInput(text, placeholder, callback)
			callback = callback or function() end
			local Frame = CreateBaseFrame(38)
			
			local Label = Instance.new("TextLabel")
			Label.Parent = Frame
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0.04, 0, 0, 0)
			Label.Size = UDim2.new(0.4, 0, 1, 0)
			Label.Font = Enum.Font.FredokaOne
			Label.Text = text
			Label.TextColor3 = Theme.TextColor
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			
			local InputBox = Instance.new("TextBox")
			InputBox.Parent = Frame
			InputBox.BackgroundColor3 = Theme.SecondaryColor
			InputBox.Position = UDim2.new(0.5, 0, 0.15, 0)
			InputBox.Size = UDim2.new(0.45, 0, 0.7, 0)
			InputBox.Font = Enum.Font.FredokaOne
			InputBox.PlaceholderText = placeholder or "Type..."
			InputBox.Text = ""
			InputBox.TextColor3 = Color3.fromRGB(255,255,255)
			InputBox.TextSize = 12
			Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0,4)
			
			InputBox.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					callback(InputBox.Text)
				end
			end)
		end

		-- 5. Dropdown
		function Tab:CreateDropdown(text, options, callback)
			callback = callback or function() end
			local isDropped = false
			local dropHeight = 38 + (#options * 30) + 10
			
			local Frame = CreateBaseFrame(38)
			Frame.ClipsDescendants = true
			Frame.ZIndex = 2
			
			local Label = Instance.new("TextLabel")
			Label.Parent = Frame
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0.04, 0, 0, 0)
			Label.Size = UDim2.new(0.6, 0, 0, 38)
			Label.Font = Enum.Font.FredokaOne
			Label.Text = text .. "..."
			Label.TextColor3 = Theme.TextColor
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			
			local Arrow = Instance.new("ImageLabel")
			Arrow.Parent = Frame
			Arrow.BackgroundTransparency = 1
			Arrow.Position = UDim2.new(0.9, -5, 0, 9)
			Arrow.Size = UDim2.new(0, 20, 0, 20)
			Arrow.Image = "rbxassetid://6031091004"
			Arrow.ImageColor3 = Theme.MainColor
			Library:AddToRegistry(Arrow, "ImageColor3", "MainColor")
			
			local OptionContainer = Instance.new("Frame")
			OptionContainer.Parent = Frame
			OptionContainer.BackgroundTransparency = 1
			OptionContainer.Position = UDim2.new(0, 0, 0, 40)
			OptionContainer.Size = UDim2.new(1, 0, 0, 0)
			
			local OLayout = Instance.new("UIListLayout")
			OLayout.Parent = OptionContainer
			OLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			OLayout.Padding = UDim.new(0, 2)
			
			for _, optName in pairs(options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Parent = OptionContainer
				OptBtn.BackgroundColor3 = Theme.SecondaryColor
				OptBtn.Size = UDim2.new(0.9, 0, 0, 28)
				OptBtn.Font = Enum.Font.FredokaOne
				OptBtn.Text = optName
				OptBtn.TextColor3 = Theme.TextColor
				OptBtn.TextSize = 12
				Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0,4)
				
				OptBtn.MouseButton1Click:Connect(function()
					Label.Text = text .. ": " .. optName
					callback(optName)
					isDropped = false
					TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 300, 0, 38)}):Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
				end)
			end
			
			local Trigger = Instance.new("TextButton")
			Trigger.Parent = Frame
			Trigger.BackgroundTransparency = 1
			Trigger.Size = UDim2.new(1, 0, 0, 38)
			Trigger.Text = ""
			
			Trigger.MouseButton1Click:Connect(function()
				isDropped = not isDropped
				local targetHeight = isDropped and dropHeight or 38
				TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 300, 0, targetHeight)}):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = isDropped and 180 or 0}):Play()
			end)
		end
		
		return Tab
	end
	return Window
end

return Library
