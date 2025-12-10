-- Modern UI Library for Roblox
-- Easy-to-use widget system with Roblox-style transparency and colors

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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

-- Creates a WidgetGroup (frame with multiple buttons)
function ModernUI:WidgetGroup(icons)
	if type(icons) ~= "table" or #icons == 0 then
		warn("WidgetGroup requires a table with at least 1 icon")
		return nil
	end
	
	local buttonCount = #icons
	local frameWidth = (buttonCount * 44) + ((buttonCount - 1) * 0)
	
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
		
		table.insert(buttons, button)
	end
	
	return {
		Frame = frame,
		Buttons = buttons,
		OnClick = function(index, callback)
			if buttons[index] then
				buttons[index].MouseButton1Click:Connect(callback)
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
	
	return {
		Frame = frame,
		Button = button,
		OnClick = function(callback)
			button.MouseButton1Click:Connect(callback)
		end
	}
end

-- Destroy the UI
function ModernUI:Destroy()
	if self.gui then
		self.gui:Destroy()
	end
end

--[[
USAGE EXAMPLE:

local ModernUI = require(path.to.ModernUI)

-- Create the UI
local ui = ModernUI.new()

-- Create a group with 2 buttons
local settingsGroup = ui:WidgetGroup({"⚙️", "⭐"})
settingsGroup.OnClick(1, function()
	print("Settings clicked!")
end)
settingsGroup.OnClick(2, function()
	print("Star clicked!")
end)

-- Create a single button widget
local addButton = ui:WidgetItem("➕")
addButton.OnClick(function()
	print("Add clicked!")
end)

-- Create another group with 2 buttons
local toolsGroup = ui:WidgetGroup({"🧩", "📌"})
toolsGroup.OnClick(1, function()
	print("Puzzle clicked!")
end)
toolsGroup.OnClick(2, function()
	print("Pin clicked!")
end)

-- To destroy when done
-- ui:Destroy()

]]

return ModernUI
