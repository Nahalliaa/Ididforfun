-- Modern UI Library for Roblox
-- Easy-to-use widget system with Roblox-style transparency, colors, and smart dropdowns

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local ModernUI = {}
ModernUI.__index = ModernUI

-- Creates a new UI instance
function ModernUI.new()
	local self = setmetatable({}, ModernUI)
	
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Check if already exists
	if playerGui:FindFirstChild("ModernUI") then
		StarterGui:SetCore("SendNotification", {
			Title = "ModernUI",
			Text = "GUI already loaded.",
			Duration = 4
		})
		return nil
	end
	
	-- Create ScreenGui
	self.gui = Instance.new("ScreenGui")
	self.gui.Name = "ModernUI"
	self.gui.ResetOnSpawn = false
	self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.gui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	self.gui.Parent = playerGui
	
	-- Create container
	self.container = Instance.new("Frame")
	self.container.Size = UDim2.new(0, 0, 0, 44)
	self.container.Position = UDim2.new(1, -11, 0, 11)
	self.container.AnchorPoint = Vector2.new(1, 0)
	self.container.BackgroundTransparency = 1
	self.container.Parent = self.gui
	
	-- Layout
	self.layout = Instance.new("UIListLayout")
	self.layout.FillDirection = Enum.FillDirection.Horizontal
	self.layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	self.layout.VerticalAlignment = Enum.VerticalAlignment.Center
	self.layout.Padding = UDim.new(0, 12)
	self.layout.Parent = self.container
	
	-- Auto-resize container based on content
	self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.container.Size = UDim2.new(0, self.layout.AbsoluteContentSize.X, 0, 44)
	end)
	
	-- Setup dragging
	self:setupDragging()
	
	-- Setup dropdown system
	self:setupDropdownSystem()
	
	return self
end

-- Setup drag functionality
function ModernUI:setupDragging()
	local dragging, dragStart, startPos, dragInput
	
	self.container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.container.Position
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			self.container.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input == dragInput then
			dragging = false
		end
	end)
end

-- Setup dropdown system
function ModernUI:setupDropdownSystem()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Create dedicated dropdown container
	self.dropdownGui = Instance.new("ScreenGui")
	self.dropdownGui.Name = "ModernUI_Dropdowns"
	self.dropdownGui.DisplayOrder = 100
	self.dropdownGui.ResetOnSpawn = false
	self.dropdownGui.Parent = playerGui
	
	-- Invisible click shield to detect outside clicks
	self.clickShield = Instance.new("TextButton")
	self.clickShield.Name = "ClickShield"
	self.clickShield.Size = UDim2.fromScale(1, 1)
	self.clickShield.BackgroundTransparency = 1
	self.clickShield.Text = ""
	self.clickShield.Visible = false
	self.clickShield.Parent = self.dropdownGui
	
	self.currentDropdown = nil
	self.closeCurrentDropdown = nil
	
	-- Click shield listener
	self.clickShield.MouseButton1Click:Connect(function()
		if self.closeCurrentDropdown then
			self.closeCurrentDropdown()
		end
	end)
end

-- Create dropdown with smart positioning
function ModernUI:createDropdown(attachButton, options, config)
	config = config or {}
	local width = config.Width or 180
	local itemHeight = config.ItemHeight or 32
	
	-- Dropdown Frame
	local dropdown = Instance.new("Frame")
	dropdown.Name = "DropdownFrame"
	dropdown.Size = UDim2.fromOffset(width, 0)
	dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	dropdown.BorderSizePixel = 0
	dropdown.ClipsDescendants = true
	dropdown.Visible = false
	dropdown.Parent = self.dropdownGui
	
	-- Styling
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = dropdown
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 65)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = dropdown
	
	-- Shadow effect
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.fromOffset(-15, -15)
	shadow.Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30)
	shadow.ZIndex = dropdown.ZIndex - 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Parent = dropdown
	
	-- List Layout
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 4)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = dropdown
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.Parent = dropdown
	
	-- Calculate total height
	local totalHeight = 12
	
	-- Create option buttons
	for i, opt in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.Name = "Option_" .. i
		btn.Size = UDim2.new(1, -12, 0, itemHeight)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		btn.Text = opt.Text or opt.text or "Option"
		btn.TextColor3 = Color3.fromRGB(220, 220, 220)
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.Parent = dropdown
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn
		
		totalHeight = totalHeight + itemHeight + 4
		
		-- Hover animations
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(50, 50, 55)
			}):Play()
		end)
		
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			}):Play()
		end)
		
		-- Click handler
		btn.MouseButton1Click:Connect(function()
			if self.closeCurrentDropdown then
				self.closeCurrentDropdown()
			end
			if opt.Callback or opt.callback then
				(opt.Callback or opt.callback)()
			end
		end)
	end
	
	totalHeight = totalHeight - 4
	
	-- Close function
	local function close()
		self.clickShield.Visible = false
		local tween = TweenService:Create(dropdown, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(width, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			dropdown.Visible = false
		end)
		self.currentDropdown = nil
		self.closeCurrentDropdown = nil
	end
	
	-- Open function with smart positioning
	local function open()
		if self.closeCurrentDropdown then
			self.closeCurrentDropdown()
		end
		
		local btnPos = attachButton.AbsolutePosition
		local btnSize = attachButton.AbsoluteSize
		local screenSize = self.dropdownGui.AbsoluteSize
		
		-- Calculate default position (below button, left-aligned)
		local finalX = btnPos.X
		local finalY = btnPos.Y + btnSize.Y + 6
		
		-- Smart positioning: adjust if dropdown goes off screen
		
		-- Right edge collision
		if finalX + width > screenSize.X - 10 then
			finalX = (btnPos.X + btnSize.X) - width
		end
		
		-- Left edge collision
		if finalX < 10 then
			finalX = 10
		end
		
		-- Bottom edge collision (flip to top)
		if finalY + totalHeight > screenSize.Y - 10 then
			finalY = btnPos.Y - totalHeight - 6
		end
		
		-- Top edge collision (if flipped but still doesn't fit)
		if finalY < 10 then
			finalY = 10
		end
		
		-- Apply position
		dropdown.Position = UDim2.fromOffset(finalX, finalY)
		dropdown.Visible = true
		
		self.clickShield.Visible = true
		self.clickShield.ZIndex = dropdown.ZIndex - 1
		
		self.currentDropdown = dropdown
		self.closeCurrentDropdown = close
		
		-- Animate open
		TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(width, totalHeight)
		}):Play()
	end
	
	-- Toggle dropdown on button click
	attachButton.MouseButton1Click:Connect(function()
		if self.currentDropdown == dropdown then
			close()
		else
			open()
		end
	end)
	
	return {
		Open = open,
		Close = close,
		Dropdown = dropdown
	}
end

-- Creates a WidgetGroup (frame with multiple buttons)
function ModernUI:WidgetGroup(icons)
	if type(icons) ~= "table" or #icons == 0 then
		warn("WidgetGroup requires a table with at least 1 icon")
		return nil
	end
	
	local buttonCount = #icons
	local frameWidth = (buttonCount * 44)
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, frameWidth, 0, 44)
	frame.BackgroundTransparency = 0.1
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.Active = true
	frame.Parent = self.container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	
	local buttons = {}
	local buttonWidth = 1 / buttonCount
	
	for i, icon in ipairs(icons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(buttonWidth, 0, 1, 0)
		button.Position = UDim2.new(buttonWidth * (i - 1), 0, 0, 0)
		button.BackgroundTransparency = 1
		button.Text = icon
		button.Font = Enum.Font.GothamBold
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Parent = frame
		
		-- Hover effect
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				TextColor3 = Color3.fromRGB(200, 200, 200)
			}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				TextColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end)
		
		table.insert(buttons, button)
	end
	
	return {
		Frame = frame,
		Buttons = buttons,
		OnClick = function(index, callback)
			if buttons[index] then
				buttons[index].MouseButton1Click:Connect(callback)
			end
		end,
		AddDropdown = function(index, options, config)
			if buttons[index] then
				return self:createDropdown(buttons[index], options, config)
			end
		end
	}
end

-- Creates a WidgetItem (single button in its own frame)
function ModernUI:WidgetItem(icon)
	if type(icon) ~= "string" then
		warn("WidgetItem requires an icon string")
		return nil
	end
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 44, 0, 44)
	frame.BackgroundTransparency = 0.1
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.Active = true
	frame.Parent = self.container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = icon
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = frame
	
	-- Hover effect
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			TextColor3 = Color3.fromRGB(200, 200, 200)
		}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)
	
	return {
		Frame = frame,
		Button = button,
		OnClick = function(callback)
			button.MouseButton1Click:Connect(callback)
		end,
		AddDropdown = function(options, config)
			return self:createDropdown(button, options, config)
		end
	}
end

-- Destroy the UI
function ModernUI:Destroy()
	if self.dropdownGui then
		self.dropdownGui:Destroy()
	end
	if self.gui then
		self.gui:Destroy()
	end
end

--[[
═══════════════════════════════════════════════════════════════
USAGE EXAMPLE
═══════════════════════════════════════════════════════════════

local ModernUI = require(script.ModernUI)

-- Create UI
local ui = ModernUI.new()
if not ui then return end

-- Group with dropdowns
local settingsGroup = ui:WidgetGroup({"⚙️", "⭐"})

-- Add dropdown to first button
settingsGroup.AddDropdown(1, {
	{ Text = "Graphics Low", Callback = function() print("Low GFX") end },
	{ Text = "Graphics High", Callback = function() print("High GFX") end }
})

-- Add dropdown to second button
settingsGroup.AddDropdown(2, {
	{ Text = "Skin: Default", Callback = function() print("Default") end },
	{ Text = "Skin: Gold", Callback = function() print("Gold") end }
})

-- Single widget with dropdown
local addButton = ui:WidgetItem("➕")
addButton.AddDropdown({
	{ Text = "Create New", Callback = function() print("Create") end },
	{ Text = "Load File", Callback = function() print("Load") end }
})

-- Another group
local toolsGroup = ui:WidgetGroup({"🧩", "📌"})
toolsGroup.AddDropdown(1, {
	{ Text = "Hammer", Callback = function() print("Hammer") end },
	{ Text = "Wrench", Callback = function() print("Wrench") end }
})

-- Custom dropdown width
toolsGroup.AddDropdown(2, {
	{ Text = "Pin Tool", Callback = function() print("Pin") end },
	{ Text = "Unpin All", Callback = function() print("Unpin") end }
}, { Width = 200 })

-- Manual click handlers (without dropdowns)
settingsGroup.OnClick(1, function() print("Settings!") end)
addButton.OnClick(function() print("Add!") end)

]]

return ModernUI
