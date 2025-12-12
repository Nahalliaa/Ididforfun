-- // LOVELY HUB UI LIBRARY // --
-- // Mobile Optimized & Modular // --
-- // Updated with Dropdowns, Input & Scroll Fixes // --

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- // Default Theme
Library.Colors = {
    Primary = Color3.fromRGB(155, 89, 182), 
    Secondary = Color3.fromRGB(142, 68, 173),
    Background = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(15, 15, 20),
    ElementBG = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150),
    Green = Color3.fromRGB(46, 204, 113),
    Red = Color3.fromRGB(231, 76, 60),
    Stroke = Color3.fromRGB(50, 50, 60)
}

-- // Utility Functions
local function tween(obj, props, duration, style)
    if not obj then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 6)
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Color = color or Library.Colors.Stroke
    stroke.Thickness = thickness or 1
    return stroke
end

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(gui, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

-- // Library Functions
function Library:Notify(text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Lovely Hub";
            Text = text;
            Duration = duration or 3;
        })
    end)
end

function Library:CreateWindow(config)
    local titleText = config.Title or "LOVELY"
    local subText = config.Subtitle or "HUB MOBILE"
    
    -- Cleanup Old
    if CoreGui:FindFirstChild("Lovely_Hub_Lib") then
        CoreGui.Lovely_Hub_Lib:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Lovely_Hub_Lib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protect GUI
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then 
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    -- Toggle Button
    local IconBtn = Instance.new("TextButton")
    IconBtn.Name = "OpenIcon"
    IconBtn.Size = UDim2.new(0, 50, 0, 50)
    IconBtn.Position = UDim2.new(0, 20, 0, 20)
    IconBtn.BackgroundColor3 = Library.Colors.Background
    IconBtn.Text = string.sub(titleText, 1, 1)
    IconBtn.TextColor3 = Library.Colors.Primary
    IconBtn.Font = Enum.Font.GothamBlack
    IconBtn.TextSize = 24
    IconBtn.Parent = ScreenGui
    createCorner(IconBtn, 25)
    createStroke(IconBtn, Library.Colors.Primary, 2)
    makeDraggable(IconBtn)

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts closed
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -130)
    MainFrame.BackgroundColor3 = Library.Colors.Background
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    createCorner(MainFrame, 12)
    createStroke(MainFrame, Library.Colors.Stroke, 2)
    makeDraggable(MainFrame)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 110, 1, 0)
    Sidebar.BackgroundColor3 = Library.Colors.Sidebar
    createCorner(Sidebar, 12)
    
    local SidebarCover = Instance.new("Frame", Sidebar)
    SidebarCover.Size = UDim2.new(0, 10, 1, 0)
    SidebarCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarCover.BackgroundColor3 = Library.Colors.Sidebar
    SidebarCover.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", Sidebar)
    TitleLabel.Text = titleText
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextColor3 = Library.Colors.Primary
    TitleLabel.TextSize = 18
    TitleLabel.Size = UDim2.new(1, -10, 0, 30)
    TitleLabel.Position = UDim2.new(0, 10, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SubLabel = Instance.new("TextLabel", Sidebar)
    SubLabel.Text = subText
    SubLabel.Font = Enum.Font.GothamBold
    SubLabel.TextColor3 = Library.Colors.TextDim
    SubLabel.TextSize = 10
    SubLabel.Size = UDim2.new(1, -10, 0, 15)
    SubLabel.Position = UDim2.new(0, 10, 0, 28)
    SubLabel.BackgroundTransparency = 1
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- // SCROLLABLE TAB CONTAINER FIX
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Library.Colors.Primary
    TabContainer.BorderSizePixel = 0
    TabContainer.CanvasSize = UDim2.new(0,0,0,0)
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
    end)

    local ContentFrame = Instance.new("Frame", MainFrame)
    ContentFrame.Size = UDim2.new(1, -120, 1, -10)
    ContentFrame.Position = UDim2.new(0, 115, 0, 5)
    ContentFrame.BackgroundTransparency = 1

    -- Toggle Logic
    local isOpen = false
    IconBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            MainFrame.Visible = true
            MainFrame:TweenSize(UDim2.new(0, 450, 0, 260), "Out", "Back", 0.4, true)
        else
            MainFrame:TweenSize(UDim2.new(0, 450, 0, 0), "In", "Quad", 0.3, true)
            task.wait(0.3)
            if not isOpen then MainFrame.Visible = false end
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(name)
        local Tab = {}
        
        -- Tab Button
        local Btn = Instance.new("TextButton", TabContainer)
        Btn.Size = UDim2.new(1, -10, 0, 32)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        
        local Label = Instance.new("TextLabel", Btn)
        Label.Text = name
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 12
        Label.TextColor3 = Library.Colors.TextDim
        Label.Size = UDim2.new(1, -15, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Indicator = Instance.new("Frame", Btn)
        Indicator.Size = UDim2.new(0, 3, 0, 14)
        Indicator.Position = UDim2.new(0, 0, 0.5, -7)
        Indicator.BackgroundColor3 = Library.Colors.Primary
        Indicator.BackgroundTransparency = 1
        createCorner(Indicator, 2)

        -- Page
        local Page = Instance.new("ScrollingFrame", ContentFrame)
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarImageColor3 = Library.Colors.Primary
        
        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 6)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)
        
        local Padding = Instance.new("UIPadding", Page)
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 5)

        -- Activation Logic
        local function Activate()
            for _, otherBtn in pairs(TabContainer:GetChildren()) do
                if otherBtn:IsA("TextButton") then
                    tween(otherBtn.TextLabel, {TextColor3 = Library.Colors.TextDim, Position = UDim2.new(0, 10, 0, 0)}, 0.2)
                    tween(otherBtn.Frame, {BackgroundTransparency = 1}, 0.2)
                end
            end
            for _, p in pairs(ContentFrame:GetChildren()) do p.Visible = false end
            
            tween(Label, {TextColor3 = Library.Colors.Text, Position = UDim2.new(0, 15, 0, 0)}, 0.2)
            tween(Indicator, {BackgroundTransparency = 0}, 0.2)
            Page.Visible = true
        end

        Btn.MouseButton1Click:Connect(Activate)

        if FirstTab then
            FirstTab = false
            Activate()
        end

        -- // Elements //
        
        function Tab:CreateSection(text)
            local Sec = Instance.new("TextLabel", Page)
            Sec.Size = UDim2.new(1, 0, 0, 24)
            Sec.BackgroundTransparency = 1
            Sec.Text = text
            Sec.Font = Enum.Font.GothamBold
            Sec.TextColor3 = Library.Colors.Text
            Sec.TextSize = 14
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            return Sec
        end

        function Tab:CreateToggle(text, default, callback)
            local toggled = default or false
            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(1, 0, 0, 36)
            Container.BackgroundColor3 = Library.Colors.ElementBG
            createCorner(Container, 8)

            local Txt = Instance.new("TextLabel", Container)
            Txt.Size = UDim2.new(1, -50, 1, 0)
            Txt.Position = UDim2.new(0, 10, 0, 0)
            Txt.BackgroundTransparency = 1
            Txt.Text = text
            Txt.Font = Enum.Font.GothamMedium
            Txt.TextColor3 = Library.Colors.TextDim
            Txt.TextSize = 12
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            
            local SwitchBg = Instance.new("Frame", Container)
            SwitchBg.Size = UDim2.new(0, 36, 0, 18)
            SwitchBg.Position = UDim2.new(1, -45, 0.5, -9)
            SwitchBg.BackgroundColor3 = Library.Colors.Sidebar
            createCorner(SwitchBg, 9)
            
            local SwitchCircle = Instance.new("Frame", SwitchBg)
            SwitchCircle.Size = UDim2.new(0, 14, 0, 14)
            SwitchCircle.Position = UDim2.new(0, 2, 0.5, -7)
            SwitchCircle.BackgroundColor3 = Library.Colors.TextDim
            createCorner(SwitchCircle, 7)
            
            local Btn = Instance.new("TextButton", Container)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""

            local function Update()
                if toggled then
                    tween(SwitchBg, {BackgroundColor3 = Library.Colors.Primary}, 0.2)
                    tween(SwitchCircle, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Library.Colors.Text}, 0.2)
                    tween(Txt, {TextColor3 = Library.Colors.Text}, 0.2)
                else
                    tween(SwitchBg, {BackgroundColor3 = Library.Colors.Sidebar}, 0.2)
                    tween(SwitchCircle, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Library.Colors.TextDim}, 0.2)
                    tween(Txt, {TextColor3 = Library.Colors.TextDim}, 0.2)
                end
                if callback then callback(toggled) end
            end

            Btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                Update()
            end)
            
            if toggled then Update() end
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local value = default or min
            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(1, 0, 0, 50)
            Container.BackgroundColor3 = Library.Colors.ElementBG
            createCorner(Container, 8)
            
            local Txt = Instance.new("TextLabel", Container)
            Txt.Size = UDim2.new(1, -20, 0, 20)
            Txt.Position = UDim2.new(0, 10, 0, 5)
            Txt.BackgroundTransparency = 1
            Txt.Text = text
            Txt.Font = Enum.Font.GothamMedium
            Txt.TextColor3 = Library.Colors.TextDim
            Txt.TextSize = 12
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValTxt = Instance.new("TextLabel", Container)
            ValTxt.Size = UDim2.new(0, 40, 0, 20)
            ValTxt.Position = UDim2.new(1, -50, 0, 5)
            ValTxt.BackgroundTransparency = 1
            ValTxt.Text = tostring(value)
            ValTxt.Font = Enum.Font.GothamBold
            ValTxt.TextColor3 = Library.Colors.Primary
            ValTxt.TextSize = 12
            ValTxt.TextXAlignment = Enum.TextXAlignment.Right
            
            local SliderBg = Instance.new("Frame", Container)
            SliderBg.Size = UDim2.new(1, -20, 0, 4)
            SliderBg.Position = UDim2.new(0, 10, 0, 35)
            SliderBg.BackgroundColor3 = Library.Colors.Sidebar
            createCorner(SliderBg, 2)
            
            local SliderFill = Instance.new("Frame", SliderBg)
            SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Library.Colors.Primary
            createCorner(SliderFill, 2)
            
            local SliderBtn = Instance.new("TextButton", SliderBg)
            SliderBtn.Size = UDim2.new(1, 10, 3, 0)
            SliderBtn.Position = UDim2.new(0, -5, -1, 0)
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Text = ""
            
            local dragging = false
            
            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + (max - min) * pos)
                value = newVal
                ValTxt.Text = tostring(newVal)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                if callback then callback(newVal) end
            end
            
            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end

        function Tab:CreateButton(text, callback)
            local BtnContainer = Instance.new("TextButton", Page)
            BtnContainer.Size = UDim2.new(1, 0, 0, 36)
            BtnContainer.BackgroundColor3 = Library.Colors.ElementBG
            BtnContainer.Text = text
            BtnContainer.Font = Enum.Font.GothamBold
            BtnContainer.TextColor3 = Library.Colors.Text
            BtnContainer.TextSize = 12
            BtnContainer.AutoButtonColor = true
            createCorner(BtnContainer, 8)

            BtnContainer.MouseButton1Click:Connect(function()
                if callback then callback() end
                tween(BtnContainer, {BackgroundColor3 = Library.Colors.Primary}, 0.1, Enum.EasingStyle.Quad)
                task.wait(0.1)
                tween(BtnContainer, {BackgroundColor3 = Library.Colors.ElementBG}, 0.2)
            end)
        end

        -- // NEW INPUT BOX
        function Tab:CreateInput(text, placeholder, callback)
            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(1, 0, 0, 50)
            Container.BackgroundColor3 = Library.Colors.ElementBG
            createCorner(Container, 8)

            local Title = Instance.new("TextLabel", Container)
            Title.Size = UDim2.new(1, -20, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.BackgroundTransparency = 1
            Title.Text = text
            Title.Font = Enum.Font.GothamMedium
            Title.TextColor3 = Library.Colors.TextDim
            Title.TextSize = 12
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local InputFrame = Instance.new("Frame", Container)
            InputFrame.Size = UDim2.new(1, -20, 0, 20)
            InputFrame.Position = UDim2.new(0, 10, 0, 25)
            InputFrame.BackgroundColor3 = Library.Colors.Sidebar
            createCorner(InputFrame, 4)
            createStroke(InputFrame, Library.Colors.Stroke, 1)

            local TextBox = Instance.new("TextBox", InputFrame)
            TextBox.Size = UDim2.new(1, -10, 1, 0)
            TextBox.Position = UDim2.new(0, 5, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder or "Type here..."
            TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            TextBox.TextColor3 = Library.Colors.Text
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 12
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            TextBox.FocusLost:Connect(function()
                if callback then callback(TextBox.Text) end
                tween(InputFrame, {BackgroundColor3 = Library.Colors.Sidebar}, 0.2)
            end)
            
            TextBox.Focused:Connect(function()
                tween(InputFrame, {BackgroundColor3 = Color3.fromRGB(40,40,45)}, 0.2)
            end)
        end

        -- // NEW DROPDOWN
        function Tab:CreateDropdown(text, options, callback)
            local Dropdown = {}
            local dropped = false
            
            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(1, 0, 0, 36)
            Container.BackgroundColor3 = Library.Colors.ElementBG
            Container.ClipsDescendants = true
            createCorner(Container, 8)
            
            local Title = Instance.new("TextLabel", Container)
            Title.Size = UDim2.new(1, -30, 0, 36)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Text = text .. " : " .. (options[1] or "Select")
            Title.Font = Enum.Font.GothamMedium
            Title.TextColor3 = Library.Colors.TextDim
            Title.TextSize = 12
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local Arrow = Instance.new("ImageLabel", Container)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -25, 0, 8)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://6034818372" -- Down Arrow
            Arrow.ImageColor3 = Library.Colors.TextDim
            
            local Button = Instance.new("TextButton", Container)
            Button.Size = UDim2.new(1, 0, 0, 36)
            Button.BackgroundTransparency = 1
            Button.Text = ""
            
            local List = Instance.new("Frame", Container)
            List.Size = UDim2.new(1, -20, 0, 0)
            List.Position = UDim2.new(0, 10, 0, 36)
            List.BackgroundTransparency = 1
            
            local ListLayout = Instance.new("UIListLayout", List)
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Fill Options
            for _, option in pairs(options) do
                local OptBtn = Instance.new("TextButton", List)
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = Library.Colors.Sidebar
                OptBtn.Text = option
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextColor3 = Library.Colors.TextDim
                OptBtn.TextSize = 12
                createCorner(OptBtn, 4)
                
                OptBtn.MouseButton1Click:Connect(function()
                    Title.Text = text .. " : " .. option
                    if callback then callback(option) end
                    -- Close
                    dropped = false
                    tween(Container, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    tween(Arrow, {Rotation = 0}, 0.2)
                end)
            end
            
            Button.MouseButton1Click:Connect(function()
                dropped = not dropped
                local contentSize = ListLayout.AbsoluteContentSize.Y
                local newSize = dropped and (contentSize + 46) or 36
                
                tween(Container, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
                tween(Arrow, {Rotation = dropped and 180 or 0}, 0.2)
            end)
        end

        return Tab
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Library
