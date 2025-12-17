local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// 1. Theme Configuration //--
Library.Theme = {
	MainColor = Color3.fromRGB(255, 217, 78),       -- The Yellow/Gold
	BackgroundColor = Color3.fromRGB(12, 12, 12),   -- Dark Grey backgrounds
	SecondaryColor = Color3.fromRGB(25, 25, 25),    -- Slightly lighter grey for elements
	TextColor = Color3.fromRGB(235, 255, 103),      -- Text Color
	TextSelected = Color3.fromRGB(9, 9, 9),         -- Text color when selected/active
	ToggleCheck = Color3.fromRGB(9, 9, 9),          -- Checkbox background
	Gradient1 = Color3.fromRGB(46, 43, 0),
	Gradient2 = Color3.fromRGB(6, 6, 6),
}

--// Utility Functions //--
local function addHoverEffect(guiObject, stroke, baseThickness)
	baseThickness = baseThickness or 0.7
	local scale = guiObject:FindFirstChild("UIScale") or Instance.new("UIScale")
	scale.Parent = guiObject
	scale.Scale = 1

	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	
	-- Restored Hover Logic (Works on PC now)
	guiObject.MouseEnter:Connect(function()
		TweenService:Create(scale, info, {Scale = 1.02}):Play()
		if stroke then TweenService:Create(stroke, info, {Thickness = baseThickness + 0.5}):Play() end
	end)

	guiObject.MouseLeave:Connect(function()
		TweenService:Create(scale, info, {Scale = 1}):Play()
		if stroke then TweenService:Create(stroke, info, {Thickness = baseThickness}):Play() end
	end)
end

local function makeDraggable(frame, dragHandle)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		TweenService:Create(frame, TweenInfo.new(0.05), {Position = newPos}):Play()
	end

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
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
			update(input)
		end
	end)
end

--// Main Window //--
function Library:CreateWindow(titleText)
	local Window = {}
	local Theme = Library.Theme

	-- UI Construction
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LynixUI"
	if gethui then
		ScreenGui.Parent = gethui()
	else
		ScreenGui.Parent = CoreGui
	end
	
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, -230, 0.5, -125)
	MainFrame.Size = UDim2.new(0, 461, 0, 251)
	
	-- Open Animation
	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 461, 0, 251)}):Play()

	local FrameCorner = Instance.new("UICorner")
	FrameCorner.CornerRadius = UDim.new(0, 9)
	FrameCorner.Parent = MainFrame

	local FrameStroke = Instance.new("UIStroke")
	FrameStroke.Parent = MainFrame
	FrameStroke.Thickness = 0.5
	FrameStroke.Color = Theme.MainColor
	FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Theme.Gradient1),
		ColorSequenceKeypoint.new(1.00, Theme.Gradient2)
	}
	UIGradient.Rotation = 40
	UIGradient.Parent = MainFrame

	-- Top Bar
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = MainFrame
	TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.BackgroundTransparency = 1.000
	TitleLabel.Position = UDim2.new(0.045, 0, 0, 0)
	TitleLabel.Size = UDim2.new(0, 100, 0, 40)
	TitleLabel.Font = Enum.Font.FredokaOne
	TitleLabel.Text = titleText or "Lynix"
	TitleLabel.TextColor3 = Theme.MainColor
	TitleLabel.TextSize = 18.000
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Close Button (X)
	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Parent = MainFrame
	CloseBtn.BackgroundTransparency = 1.000
	CloseBtn.Position = UDim2.new(0.915, 0, 0.032, 0)
	CloseBtn.Size = UDim2.new(0, 30, 0, 24)
	CloseBtn.Image = "rbxassetid://103094495394151"
	CloseBtn.ImageColor3 = Theme.MainColor
	
	-- Minimize Button (-)
	local MinBtn = Instance.new("ImageButton")
	MinBtn.Parent = MainFrame
	MinBtn.BackgroundTransparency = 1.000
	MinBtn.Position = UDim2.new(0.85, 0, 0.032, 0)
	MinBtn.Size = UDim2.new(0, 30, 0, 24)
	MinBtn.Image = "rbxassetid://80500837074519"
	MinBtn.ImageColor3 = Theme.MainColor

	local Divider = Instance.new("Frame")
	Divider.Parent = MainFrame
	Divider.BackgroundColor3 = Theme.MainColor
	Divider.BorderSizePixel = 0
	Divider.Position = UDim2.new(0, 0, 0.157, 0)
	Divider.Size = UDim2.new(0, 461, 0, 1)

	-- Containers
	local TabContainer = Instance.new("Frame")
	TabContainer.Parent = MainFrame
	TabContainer.BackgroundColor3 = Theme.BackgroundColor
	TabContainer.BackgroundTransparency = 0.9
	TabContainer.Position = UDim2.new(0.024, 0, 0.2, 0)
	TabContainer.Size = UDim2.new(0, 107, 0, 189)
	
	local TabContainerCorner = Instance.new("UICorner")
	TabContainerCorner.Parent = TabContainer
	
	local TabContainerStroke = Instance.new("UIStroke")
	TabContainerStroke.Parent = TabContainer
	TabContainerStroke.Thickness = 0.7
	TabContainerStroke.Color = Theme.MainColor

	local PageContainer = Instance.new("Frame")
	PageContainer.Parent = MainFrame
	PageContainer.BackgroundColor3 = Theme.BackgroundColor
	PageContainer.BackgroundTransparency = 0.9
	PageContainer.Position = UDim2.new(0.277, 0, 0.2, 0)
	PageContainer.Size = UDim2.new(0, 323, 0, 189)
	PageContainer.ClipsDescendants = true

	local PageContainerCorner = Instance.new("UICorner")
	PageContainerCorner.Parent = PageContainer

	local PageContainerStroke = Instance.new("UIStroke")
	PageContainerStroke.Parent = PageContainer
	PageContainerStroke.Thickness = 0.7
	PageContainerStroke.Color = Theme.MainColor
	
	makeDraggable(MainFrame, MainFrame)
	
	-- Close Logic
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	-- Minimize Logic
	local minimized = false
	local fullSize = UDim2.new(0, 461, 0, 251)
	local miniSize = UDim2.new(0, 461, 0, 40)
	
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			TabContainer.Visible = false
			PageContainer.Visible = false
			Divider.Visible = false
			MainFrame:TweenSize(miniSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
		else
			MainFrame:TweenSize(fullSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
			task.wait(0.2)
			if not minimized then
				TabContainer.Visible = true
				PageContainer.Visible = true
				Divider.Visible = true
			end
		end
	end)
	
	--// Mobile Button //--
	function Window:CreateMobileButton(iconId)
		local MobileBtn = Instance.new("ImageButton")
		MobileBtn.Name = "MobileToggle"
		MobileBtn.Parent = ScreenGui
		MobileBtn.BackgroundColor3 = Theme.BackgroundColor
		MobileBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
		MobileBtn.Size = UDim2.new(0, 50, 0, 50) 
		MobileBtn.Image = iconId or "rbxassetid://18636968846" -- Gear/Menu Icon
		MobileBtn.ImageColor3 = Theme.MainColor
		MobileBtn.Active = true
		
		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0.3, 0)
		BtnCorner.Parent = MobileBtn
		
		local BtnStroke = Instance.new("UIStroke")
		BtnStroke.Parent = MobileBtn
		BtnStroke.Color = Theme.MainColor
		BtnStroke.Thickness = 1.5
		
		makeDraggable(MobileBtn, MobileBtn)
		
		local toggled = true
		MobileBtn.MouseButton1Click:Connect(function()
			toggled = not toggled
			MainFrame.Visible = toggled
		end)
	end
	
	--// Tabs //--
	local tabs = {}
	local firstTab = true
	
	function Window:CreateTab(name)
		local Tab = {}
		
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name .. "_Btn"
		TabBtn.Parent = TabContainer
		TabBtn.BackgroundColor3 = Theme.BackgroundColor
		TabBtn.Size = UDim2.new(0, 88, 0, 32)
		TabBtn.Font = Enum.Font.FredokaOne
		TabBtn.Text = name
		TabBtn.TextColor3 = Theme.TextColor
		TabBtn.TextSize = 14.000
		
		local TabBtnCorner = Instance.new("UICorner")
		TabBtnCorner.CornerRadius = UDim.new(0, 3)
		TabBtnCorner.Parent = TabBtn
		
		local TabBtnStroke = Instance.new("UIStroke")
		TabBtnStroke.Parent = TabBtn
		TabBtnStroke.Thickness = 0.7
		TabBtnStroke.Color = Theme.MainColor
		TabBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		
		addHoverEffect(TabBtn, TabBtnStroke)
		
		local TabList = TabContainer:FindFirstChild("UIListLayout") or Instance.new("UIListLayout")
		TabList.Parent = TabContainer
		TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		TabList.SortOrder = Enum.SortOrder.LayoutOrder
		TabList.Padding = UDim.new(0, 10)
		
		local TabPadding = TabContainer:FindFirstChild("UIPadding") or Instance.new("UIPadding")
		TabPadding.Parent = TabContainer
		TabPadding.PaddingTop = UDim.new(0, 10)
		
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name .. "_Page"
		Page.Parent = PageContainer
		Page.Active = true
		Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Page.BackgroundTransparency = 1.000
		Page.BorderSizePixel = 0
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Theme.MainColor
		Page.Visible = false
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Parent = Page
		PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)
		
		local PagePadding = Instance.new("UIPadding")
		PagePadding.Parent = Page
		PagePadding.PaddingTop = UDim.new(0, 15)
		PagePadding.PaddingBottom = UDim.new(0, 30)
		
		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(tabs) do
				t.Page.Visible = false
				t.Btn.BackgroundColor3 = Theme.BackgroundColor
				t.Btn.TextColor3 = Theme.TextColor
			end
			Page.Visible = true
			TabBtn.BackgroundColor3 = Theme.MainColor
			TabBtn.TextColor3 = Theme.TextSelected
		end)
		
		if firstTab then
			firstTab = false
			Page.Visible = true
			TabBtn.BackgroundColor3 = Theme.MainColor
			TabBtn.TextColor3 = Theme.TextSelected
		end
		
		table.insert(tabs, {Btn = TabBtn, Page = Page})
		
		--// Elements //--
		
		function Tab:CreateToggle(text, callback)
			callback = callback or function() end
			local toggled = false
			
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Parent = Page
			ToggleFrame.BackgroundColor3 = Theme.BackgroundColor
			ToggleFrame.Size = UDim2.new(0, 300, 0, 38)
			
			local TCorner = Instance.new("UICorner")
			TCorner.CornerRadius = UDim.new(0, 3)
			TCorner.Parent = ToggleFrame
			
			local TStroke = Instance.new("UIStroke")
			TStroke.Parent = ToggleFrame
			TStroke.Thickness = 0.7
			TStroke.Color = Theme.MainColor
			TStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			
			local TLabel = Instance.new("TextLabel")
			TLabel.Parent = ToggleFrame
			TLabel.BackgroundTransparency = 1
			TLabel.Position = UDim2.new(0.05, 0, 0, 0)
			TLabel.Size = UDim2.new(0.75, 0, 1, 0)
			TLabel.Font = Enum.Font.FredokaOne
			TLabel.Text = text
			TLabel.TextColor3 = Theme.TextColor
			TLabel.TextSize = 14.000
			TLabel.TextXAlignment = Enum.TextXAlignment.Left
			
			-- Full Size Hitbox for Mobile
			local TButton = Instance.new("TextButton")
			TButton.Parent = ToggleFrame
			TButton.Text = ""
			TButton.BackgroundTransparency = 1
			TButton.Size = UDim2.new(1, 0, 1, 0)
			TButton.ZIndex = 5 
			
			local CheckBg = Instance.new("Frame")
			CheckBg.Parent = ToggleFrame
			CheckBg.BackgroundColor3 = Theme.ToggleCheck
			CheckBg.BackgroundTransparency = 0.93
			CheckBg.Position = UDim2.new(0.893, 0, 0.234, 0)
			CheckBg.Size = UDim2.new(0, 19, 0, 19)
			
			local CheckCorner = Instance.new("UICorner")
			CheckCorner.CornerRadius = UDim.new(1, 0)
			CheckCorner.Parent = CheckBg
			
			local CheckStroke = Instance.new("UIStroke")
			CheckStroke.Parent = CheckBg
			CheckStroke.Thickness = 0.7
			CheckStroke.Color = Theme.MainColor
			
			local CheckIndicator = Instance.new("Frame")
			CheckIndicator.Parent = CheckBg
			CheckIndicator.BackgroundColor3 = Theme.MainColor
			CheckIndicator.Size = UDim2.new(0, 11, 0, 11)
			CheckIndicator.Position = UDim2.new(0.5, 0, 0.5, 0)
			CheckIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
			CheckIndicator.Visible = false
			
			local IndicatorCorner = Instance.new("UICorner")
			IndicatorCorner.CornerRadius = UDim.new(1, 0)
			IndicatorCorner.Parent = CheckIndicator
			
			addHoverEffect(ToggleFrame, TStroke)
			
			TButton.MouseButton1Click:Connect(function()
				toggled = not toggled
				CheckIndicator.Visible = toggled
				CheckBg.BackgroundTransparency = toggled and 0 or 0.93
				callback(toggled)
			end)
		end
		
		function Tab:CreateButton(text, callback)
			callback = callback or function() end
			
			local BtnFrame = Instance.new("Frame")
			BtnFrame.Parent = Page
			BtnFrame.BackgroundColor3 = Theme.BackgroundColor
			BtnFrame.Size = UDim2.new(0, 300, 0, 38)
			
			local BCorner = Instance.new("UICorner")
			BCorner.CornerRadius = UDim.new(0, 3)
			BCorner.Parent = BtnFrame
			
			local BStroke = Instance.new("UIStroke")
			BStroke.Parent = BtnFrame
			BStroke.Thickness = 0.7
			BStroke.Color = Theme.MainColor
			BStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			
			local BLabel = Instance.new("TextLabel")
			BLabel.Parent = BtnFrame
			BLabel.BackgroundTransparency = 1
			BLabel.Position = UDim2.new(0.05, 0, 0, 0)
			BLabel.Size = UDim2.new(0.8, 0, 1, 0)
			BLabel.Font = Enum.Font.FredokaOne
			BLabel.Text = text
			BLabel.TextColor3 = Theme.TextColor
			BLabel.TextSize = 14.000
			BLabel.TextXAlignment = Enum.TextXAlignment.Left
			
			local Icon = Instance.new("ImageButton")
			Icon.Parent = BtnFrame
			Icon.BackgroundTransparency = 1
			Icon.Position = UDim2.new(0.87, 0, 0.13, 0)
			Icon.Size = UDim2.new(0, 28, 0, 28)
			Icon.Image = "rbxassetid://110620726041573"
			Icon.ImageColor3 = Theme.MainColor
			
			local Hitbox = Instance.new("TextButton")
			Hitbox.Parent = BtnFrame
			Hitbox.BackgroundTransparency = 1
			Hitbox.Size = UDim2.new(1,0,1,0)
			Hitbox.Text = ""
			Hitbox.ZIndex = 5
			
			addHoverEffect(BtnFrame, BStroke)
			
			Hitbox.MouseButton1Click:Connect(function()
				TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SecondaryColor}):Play()
				task.wait(0.1)
				TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BackgroundColor}):Play()
				callback()
			end)
		end
		
		function Tab:CreateSlider(text, min, max, default, callback)
			callback = callback or function() end
			local value = default or min
			
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Parent = Page
			SliderFrame.BackgroundColor3 = Theme.BackgroundColor
			SliderFrame.Size = UDim2.new(0, 300, 0, 60)
			
			local SCorner = Instance.new("UICorner")
			SCorner.CornerRadius = UDim.new(0, 3)
			SCorner.Parent = SliderFrame
			
			local SStroke = Instance.new("UIStroke")
			SStroke.Parent = SliderFrame
			SStroke.Thickness = 0.7
			SStroke.Color = Theme.MainColor
			SStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			
			local SLabel = Instance.new("TextLabel")
			SLabel.Parent = SliderFrame
			SLabel.BackgroundTransparency = 1
			SLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
			SLabel.Size = UDim2.new(0.9, 0, 0, 20)
			SLabel.Font = Enum.Font.FredokaOne
			SLabel.Text = text .. ": " .. tostring(value)
			SLabel.TextColor3 = Theme.TextColor
			SLabel.TextSize = 12.000
			SLabel.TextXAlignment = Enum.TextXAlignment.Left
			
			local SlideBg = Instance.new("Frame")
			SlideBg.Parent = SliderFrame
			SlideBg.BackgroundColor3 = Theme.SecondaryColor
			SlideBg.Position = UDim2.new(0.05, 0, 0.6, 0)
			SlideBg.Size = UDim2.new(0.9, 0, 0, 10)
			
			local SlideBgCorner = Instance.new("UICorner")
			SlideBgCorner.CornerRadius = UDim.new(0, 5)
			SlideBgCorner.Parent = SlideBg
			
			local Fill = Instance.new("Frame")
			Fill.Parent = SlideBg
			Fill.BackgroundColor3 = Theme.MainColor
			Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			
			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(0, 5)
			FillCorner.Parent = Fill
			
			-- Mobile/Full Hitbox Trigger
			local Trigger = Instance.new("TextButton")
			Trigger.Parent = SliderFrame
			Trigger.BackgroundTransparency = 1
			Trigger.Size = UDim2.new(1, 0, 1, 0)
			Trigger.Text = ""
			Trigger.ZIndex = 5
			
			addHoverEffect(SliderFrame, SStroke)
			
			local dragging = false
			
			local function update(input)
				local pos = input.Position.X
				local bgAbsPos = SlideBg.AbsolutePosition.X
				local bgAbsSize = SlideBg.AbsoluteSize.X
				
				local relative = math.clamp(pos - bgAbsPos, 0, bgAbsSize)
				local percent = relative / bgAbsSize
				
				value = math.floor(min + (max - min) * percent)
				
				TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
				SLabel.Text = text .. ": " .. tostring(value)
				callback(value)
			end
			
			Trigger.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(input)
				end
			end)
			
			Trigger.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					update(input)
				end
			end)
		end
		
		return Tab
	end
	
	return Window
end

return Library
