-- TopBar++ | Modern Hub Library
-- Efficient, Icon-Smart, and Easy-to-use

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local TopBarPlus = {}
TopBarPlus.__index = TopBarPlus

-- Theme Configuration
local THEME = {
	Background = Color3.fromRGB(25, 25, 30),
	Hover = Color3.fromRGB(40, 40, 45),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(180, 180, 180),
	CornerRadius = UDim.new(0, 8),
	IconSize = UDim2.fromOffset(20, 20),
	WidgetSize = UDim2.fromOffset(40, 40)
}

--// Helper: Apply Icon (Text or Image)
local function ApplyIcon(parent, content)
	local display
	
	-- Determine type (ID, URL, or Text)
	local isImage = false
	if type(content) == "number" then
		content = "rbxassetid://" .. content
		isImage = true
	elseif type(content) == "string" then
		if content:match("^rbxasset") or content:match("^http") then
			isImage = true
		elseif content:match("^%d+$") then -- String containing only numbers
			content = "rbxassetid://" .. content
			isImage = true
		end
	end

	if isImage then
		display = Instance.new("ImageLabel")
		display.Image = content
		display.BackgroundTransparency = 1
		display.Size = THEME.IconSize
		display.AnchorPoint = Vector2.new(0.5, 0.5)
		display.Position = UDim2.fromScale(0.5, 0.5)
		display.ScaleType = Enum.ScaleType.Fit
	else
		display = Instance.new("TextLabel")
		display.Text = content
		display.BackgroundTransparency = 1
		display.Size = UDim2.fromScale(1, 1)
		display.Font = Enum.Font.GothamBold
		display.TextSize = 18
		display.TextColor3 = THEME.Text
	end
	
	display.Name = "Icon"
	display.Parent = parent
	return display
end

--// Constructor
function TopBarPlus.new()
	local self = setmetatable({}, TopBarPlus)
	
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Cleanup old instances
	if playerGui:FindFirstChild("TopBarPlus") then playerGui.TopBarPlus:Destroy() end
	
	-- Main GUI
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "TopBarPlus"
	self.Gui.ResetOnSpawn = false
	self.Gui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	self.Gui.Parent = playerGui
	
	-- Dropdown Overlay (High ZIndex)
	self.Overlay = Instance.new("Frame")
	self.Overlay.Name = "DropdownOverlay"
	self.Overlay.Size = UDim2.fromScale(1, 1)
	self.Overlay.BackgroundTransparency = 1
	self.Overlay.Visible = false
	self.Overlay.ZIndex = 100
	self.Overlay.Parent = self.Gui

	-- Close shield
	local shield = Instance.new("TextButton")
	shield.Size = UDim2.fromScale(1, 1)
	shield.BackgroundTransparency = 1
	shield.Text = ""
	shield.Parent = self.Overlay
	shield.MouseButton1Click:Connect(function() self:CloseDropdown() end)

	-- Container
	self.Container = Instance.new("Frame")
	self.Container.Name = "Container"
	self.Container.Size = UDim2.fromOffset(0, 44)
	self.Container.Position = UDim2.new(1, -12, 0, 4)
	self.Container.AnchorPoint = Vector2.new(1, 0)
	self.Container.BackgroundTransparency = 1
	self.Container.Parent = self.Gui
	
	-- Layout
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0, 8)
	layout.Parent = self.Container
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Container.Size = UDim2.new(0, layout.AbsoluteContentSize.X, 0, 44)
	end)

	self.ActiveDropdown = nil
	self:SetupDragging()
	
	return self
end

--// Internal: Create Widget Frame
function TopBarPlus:_CreateBase(width)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(width, 40)
	frame.BackgroundColor3 = THEME.Background
	frame.BackgroundTransparency = 0.2
	frame.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = THEME.CornerRadius
	corner.Parent = frame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1,1,1)
	stroke.Transparency = 0.9
	stroke.Thickness = 1
	stroke.Parent = frame
	
	return frame
end

--// Internal: Hover Animation
function TopBarPlus:_BindHover(button)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Hover}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1}):Play()
	end)
end

--// Feature: Add Widget (Single Button)
-- options: { Text = "Desc", Callback = func, Dropdown = {} }
function TopBarPlus:AddWidget(icon, options)
	options = options or {}
	local frame = self:_CreateBase(40)
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = frame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = THEME.CornerRadius
	corner.Parent = btn

	ApplyIcon(btn, icon)
	self:_BindHover(btn)
	
	if options.Dropdown then
		btn.MouseButton1Click:Connect(function()
			self:ToggleDropdown(frame, options.Dropdown)
		end)
	elseif options.Callback then
		btn.MouseButton1Click:Connect(options.Callback)
	end
	
	return btn
end

--// Feature: Add Group (Multiple Buttons)
function TopBarPlus:AddGroup(widgets)
	local count = #widgets
	local frame = self:_CreateBase(count * 40)
	
	-- Divider lines
	for i = 1, count - 1 do
		local line = Instance.new("Frame")
		line.Size = UDim2.new(0, 1, 0.6, 0)
		line.Position = UDim2.new(i/count, 0, 0.2, 0)
		line.BackgroundColor3 = Color3.new(1,1,1)
		line.BackgroundTransparency = 0.8
		line.BorderSizePixel = 0
		line.ZIndex = 2
		line.Parent = frame
	end
	
	for i, widget in ipairs(widgets) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1/count, 0, 1, 0)
		btn.Position = UDim2.new((i-1)/count, 0, 0, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = frame
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = THEME.CornerRadius
		corner.Parent = btn
		
		ApplyIcon(btn, widget.Icon)
		self:_BindHover(btn)
		
		if widget.Dropdown then
			btn.MouseButton1Click:Connect(function()
				self:ToggleDropdown(btn, widget.Dropdown) -- Attach to btn, not frame
			end)
		elseif widget.Callback then
			btn.MouseButton1Click:Connect(widget.Callback)
		end
	end
end

--// System: Dropdowns
function TopBarPlus:ToggleDropdown(attachTo, items)
	if self.ActiveDropdown and self.ActiveDropdown.Adornee == attachTo then
		self:CloseDropdown()
		return
	end
	self:CloseDropdown()
	
	local width = 160
	local listHeight = (#items * 32) + 8
	
	local dropFrame = Instance.new("Frame")
	dropFrame.Size = UDim2.fromOffset(width, 0) -- Start height 0
	dropFrame.BackgroundColor3 = THEME.Background
	dropFrame.ClipsDescendants = true
	dropFrame.Parent = self.Overlay
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = THEME.CornerRadius
	corner.Parent = dropFrame
	
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 2)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Parent = dropFrame
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = dropFrame
	
	-- Calculate Position
	local absPos = attachTo.AbsolutePosition
	local absSize = attachTo.AbsoluteSize
	local finalX = absPos.X + absSize.X - width
	local finalY = absPos.Y + absSize.Y + 6
	
	dropFrame.Position = UDim2.fromOffset(finalX, finalY)
	
	-- Create Items
	for _, item in ipairs(items) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		btn.Text = "  " .. (item.Text or item.Name or "Option")
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 14
		btn.TextColor3 = THEME.Text
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.Parent = dropFrame
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn
		
		-- Hover
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Hover}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
		end)
		
		btn.MouseButton1Click:Connect(function()
			self:CloseDropdown()
			if item.Callback then task.spawn(item.Callback) end
		end)
	end
	
	self.Overlay.Visible = true
	self.ActiveDropdown = { Frame = dropFrame, Adornee = attachTo }
	
	TweenService:Create(dropFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(width, listHeight)
	}):Play()
end

function TopBarPlus:CloseDropdown()
	if not self.ActiveDropdown then return end
	
	local frame = self.ActiveDropdown.Frame
	self.ActiveDropdown = nil
	
	local tween = TweenService:Create(frame, TweenInfo.new(0.15), {Size = UDim2.fromOffset(frame.Size.X.Offset, 0)})
	tween:Play()
	tween.Completed:Connect(function()
		frame:Destroy()
		if not self.ActiveDropdown then self.Overlay.Visible = false end
	end)
end

--// System: Draggable
function TopBarPlus:SetupDragging()
	local dragging, dragStart, startPos
	
	self.Container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Container.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			self.Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

return TopBarPlus
