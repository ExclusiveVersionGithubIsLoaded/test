--[[
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                         PEPSI UI LIBRARY                          ║
    ║                  Professional Roblox UI System                    ║
    ║                      Black & White Edition                        ║
    ║                         Version 2.1.0                             ║
    ╚═══════════════════════════════════════════════════════════════════╝
    
    ИСПРАВЛЕНИЯ v2.1.0:
    ✅ Элементы сдвигаются вниз при открытии dropdown/colorpicker
    ✅ Скругленные углы почти везде
    ✅ Улучшенные уведомления с анимацией
    ✅ Красивый toggle с анимацией
    ✅ Круглые хендлы слайдеров
    ✅ Улучшенные кнопки без заслонения текста
    ✅ Красивые вкладки
    ✅ Сворачивание окна (-)
    ✅ Улучшенный ColorPicker
    3000+ строк кода
]]

local PepsiUI = {}
PepsiUI.__index = PepsiUI
PepsiUI.Version = "2.1.0"

-- ============================================
-- CORE SYSTEM CONFIGURATION
-- ============================================
local CONFIG = {
    -- Color System
    Colors = {
        Black = Color3.fromRGB(0, 0, 0),
        Gray900 = Color3.fromRGB(10, 10, 10),
        Gray800 = Color3.fromRGB(26, 26, 26),
        Gray750 = Color3.fromRGB(35, 35, 35),
        Gray700 = Color3.fromRGB(42, 42, 42),
        Gray600 = Color3.fromRGB(58, 58, 58),
        Gray500 = Color3.fromRGB(90, 90, 90),
        Gray400 = Color3.fromRGB(122, 122, 122),
        Gray300 = Color3.fromRGB(154, 154, 154),
        Gray200 = Color3.fromRGB(192, 192, 192),
        Gray100 = Color3.fromRGB(224, 224, 224),
        White = Color3.fromRGB(255, 255, 255),
    },
    
    -- Typography
    Fonts = {
        Display = Enum.Font.GothamBold,
        Mono = Enum.Font.RobotoMono,
        Body = Enum.Font.Gotham,
    },
    
    FontSizes = {
        XS = 10,
        SM = 12,
        Base = 14,
        LG = 16,
        XL = 18,
        XXL = 22,
        XXXL = 28,
        XXXXL = 36,
    },
    
    -- Spacing System
    Spacing = {
        XS = 4,
        SM = 8,
        MD = 12,
        LG = 16,
        XL = 20,
        XXL = 24,
        XXXL = 32,
        XXXXL = 48,
    },
    
    -- Border & Corners
    BorderWidth = 2,
    CornerRadius = {
        None = 0,
        SM = 4,
        MD = 8,
        LG = 12,
        XL = 16,
        Full = 999,
    },
    
    -- Animation
    TweenTime = 0.25,
    TweenStyle = Enum.EasingStyle.Quad,
    TweenDirection = Enum.EasingDirection.Out,
    
    -- Z-Index Layers
    ZIndex = {
        Base = 1,
        Dropdown = 100,
        Modal = 200,
        Tooltip = 300,
        Notification = 400,
    },
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local Utils = {}

function Utils.CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop == "Parent" then
            continue
        end
        instance[prop] = value
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utils.Tween(instance, properties, time, style, direction)
    local tweenInfo = TweenInfo.new(
        time or CONFIG.TweenTime,
        style or CONFIG.TweenStyle,
        direction or CONFIG.TweenDirection
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils.AddCorner(parent, radius)
    return Utils.CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or CONFIG.CornerRadius.MD),
        Parent = parent,
    })
end

function Utils.AddStroke(parent, color, thickness)
    return Utils.CreateInstance("UIStroke", {
        Color = color or CONFIG.Colors.White,
        Thickness = thickness or CONFIG.BorderWidth,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function Utils.AddPadding(parent, all)
    return Utils.CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, all or CONFIG.Spacing.MD),
        PaddingBottom = UDim.new(0, all or CONFIG.Spacing.MD),
        PaddingLeft = UDim.new(0, all or CONFIG.Spacing.MD),
        PaddingRight = UDim.new(0, all or CONFIG.Spacing.MD),
        Parent = parent,
    })
end

function Utils.AddListLayout(parent, padding, direction)
    return Utils.CreateInstance("UIListLayout", {
        Padding = UDim.new(0, padding or CONFIG.Spacing.SM),
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Utils.ApplyTextProperties(textLabel, config)
    textLabel.Font = config.Font or CONFIG.Fonts.Body
    textLabel.TextSize = config.Size or CONFIG.FontSizes.Base
    textLabel.TextColor3 = config.Color or CONFIG.Colors.White
    textLabel.TextXAlignment = config.XAlign or Enum.TextXAlignment.Left
    textLabel.TextYAlignment = config.YAlign or Enum.TextYAlignment.Center
    textLabel.TextWrapped = config.Wrapped or false
end

-- Функция для расчета и сдвига элементов при открытии dropdown/colorpicker
function Utils.ShiftElementsBelow(element, expandedHeight, restore)
    local parent = element.Parent
    if not parent then return end
    
    local elementPosition = element.AbsolutePosition.Y
    local shouldShift = false
    
    for _, sibling in pairs(parent:GetChildren()) do
        if sibling:IsA("GuiObject") and sibling ~= element then
            if sibling.AbsolutePosition.Y > elementPosition then
                local currentOffset = sibling:FindFirstChild("_ShiftOffset")
                
                if restore then
                    -- Восстанавливаем позицию
                    if currentOffset then
                        local targetPos = sibling.Position - UDim2.new(0, 0, 0, currentOffset.Value)
                        Utils.Tween(sibling, {Position = targetPos}, 0.3)
                        currentOffset:Destroy()
                    end
                else
                    -- Сдвигаем вниз
                    if not currentOffset then
                        currentOffset = Instance.new("NumberValue")
                        currentOffset.Name = "_ShiftOffset"
                        currentOffset.Value = expandedHeight
                        currentOffset.Parent = sibling
                        
                        local targetPos = sibling.Position + UDim2.new(0, 0, 0, expandedHeight)
                        Utils.Tween(sibling, {Position = targetPos}, 0.3)
                    end
                end
            end
        end
    end
    
    -- Обновляем CanvasSize для ScrollingFrame
    if parent:IsA("ScrollingFrame") then
        task.wait(0.35)
        local contentSize = parent.UIListLayout and parent.UIListLayout.AbsoluteContentSize.Y or 0
        parent.CanvasSize = UDim2.new(0, 0, 0, contentSize + (restore and 0 or expandedHeight))
    end
end

-- ============================================
-- MAIN UI CLASS
-- ============================================
function PepsiUI.new(parent)
    local self = setmetatable({}, PepsiUI)
    
    self.Parent = parent or game:GetService("CoreGui")
    self.Components = {}
    self.Windows = {}
    self.ActiveDropdowns = {}
    
    -- Create main screen GUI
    self.ScreenGui = Utils.CreateInstance("ScreenGui", {
        Name = "PepsiUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = self.Parent,
    })
    
    -- Setup input handler for closing dropdowns
    self:SetupGlobalInputHandler()
    
    return self
end

function PepsiUI:SetupGlobalInputHandler()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Close all active dropdowns
            for _, dropdown in pairs(self.ActiveDropdowns) do
                if dropdown and dropdown.Close then
                    dropdown:Close()
                end
            end
        end
    end)
end

-- ============================================
-- WINDOW COMPONENT
-- ============================================
function PepsiUI:CreateWindow(config)
    config = config or {}
    
    local window = {
        Title = config.Title or "Pepsi UI Window",
        Size = config.Size or UDim2.new(0, 600, 0, 500),
        Position = config.Position or UDim2.new(0.5, -300, 0.5, -250),
        Draggable = config.Draggable ~= false,
        Tabs = {},
        CurrentTab = nil,
        Minimized = false,
    }
    
    -- Main window frame
    window.Frame = Utils.CreateInstance("Frame", {
        Name = "Window",
        Size = window.Size,
        Position = window.Position,
        BackgroundColor3 = CONFIG.Colors.Gray800,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = CONFIG.ZIndex.Base,
        Parent = self.ScreenGui,
    })
    
    Utils.AddStroke(window.Frame, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(window.Frame, CONFIG.CornerRadius.LG)
    
    -- Header
    window.Header = Utils.CreateInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CONFIG.Colors.Black,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 1,
        Parent = window.Frame,
    })
    
    Utils.AddStroke(window.Header, CONFIG.Colors.Gray700, CONFIG.BorderWidth)
    Utils.AddCorner(window.Header, CONFIG.CornerRadius.LG)
    
    -- Title
    window.TitleLabel = Utils.CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Display,
        TextSize = CONFIG.FontSizes.XL,
        TextColor3 = CONFIG.Colors.White,
        Text = window.Title,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 2,
        Parent = window.Header,
    })
    
    -- Minimize button
    window.MinimizeButton = Utils.CreateInstance("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -90, 0, 7),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Display,
        TextSize = CONFIG.FontSizes.XXL,
        TextColor3 = CONFIG.Colors.White,
        Text = "−",
        ZIndex = CONFIG.ZIndex.Base + 2,
        Parent = window.Header,
    })
    
    Utils.AddStroke(window.MinimizeButton, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(window.MinimizeButton, CONFIG.CornerRadius.MD)
    
    -- Close button
    window.CloseButton = Utils.CreateInstance("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -45, 0, 7),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Display,
        TextSize = CONFIG.FontSizes.XXL,
        TextColor3 = CONFIG.Colors.White,
        Text = "×",
        ZIndex = CONFIG.ZIndex.Base + 2,
        Parent = window.Header,
    })
    
    Utils.AddStroke(window.CloseButton, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(window.CloseButton, CONFIG.CornerRadius.MD)
    
    window.CloseButton.MouseButton1Click:Connect(function()
        window.Frame:Destroy()
    end)
    
    window.CloseButton.MouseEnter:Connect(function()
        Utils.Tween(window.CloseButton, {BackgroundColor3 = CONFIG.Colors.White}, 0.2)
        Utils.Tween(window.CloseButton, {TextColor3 = CONFIG.Colors.Black}, 0.2)
    end)
    
    window.CloseButton.MouseLeave:Connect(function()
        Utils.Tween(window.CloseButton, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
        Utils.Tween(window.CloseButton, {TextColor3 = CONFIG.Colors.White}, 0.2)
    end)
    
    -- Minimize functionality
    window.MinimizeButton.MouseButton1Click:Connect(function()
        window.Minimized = not window.Minimized
        
        if window.Minimized then
            window.MinimizeButton.Text = "+"
            Utils.Tween(window.Frame, {Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, 50)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        else
            window.MinimizeButton.Text = "−"
            Utils.Tween(window.Frame, {Size = window.Size}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)
    
    window.MinimizeButton.MouseEnter:Connect(function()
        Utils.Tween(window.MinimizeButton, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.2)
    end)
    
    window.MinimizeButton.MouseLeave:Connect(function()
        Utils.Tween(window.MinimizeButton, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
    end)
    
    -- Tab container
    window.TabContainer = Utils.CreateInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = CONFIG.Colors.Black,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 1,
        Parent = window.Frame,
    })
    
    Utils.AddStroke(window.TabContainer, CONFIG.Colors.Gray700, CONFIG.BorderWidth)
    Utils.AddListLayout(window.TabContainer, 2, Enum.FillDirection.Vertical)
    
    -- Content area
    window.ContentArea = Utils.CreateInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -150, 1, -50),
        Position = UDim2.new(0, 150, 0, 50),
        BackgroundColor3 = CONFIG.Colors.Gray900,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base,
        Parent = window.Frame,
    })
    
    -- Dragging functionality
    if window.Draggable then
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        window.Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = window.Frame.Position
            end
        end)
        
        window.Header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                window.Frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Window methods
    function window:CreateTab(name)
        local tab = {
            Name = name,
            Sections = {},
            Window = self,
        }
        
        -- Tab button с улучшенным дизайном
        tab.Button = Utils.CreateInstance("TextButton", {
            Name = "TabButton_" .. name,
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = CONFIG.Colors.Gray800,
            BorderSizePixel = 0,
            Font = CONFIG.Fonts.Mono,
            TextSize = CONFIG.FontSizes.Base,
            TextColor3 = CONFIG.Colors.Gray400,
            Text = name:upper(),
            ZIndex = CONFIG.ZIndex.Base + 2,
            Parent = self.TabContainer,
        })
        
        Utils.AddCorner(tab.Button, CONFIG.CornerRadius.SM)
        local stroke = Utils.AddStroke(tab.Button, CONFIG.Colors.Gray700, 1)
        
        -- Indicator bar для активной вкладки
        tab.Indicator = Utils.CreateInstance("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = CONFIG.Colors.White,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = CONFIG.ZIndex.Base + 3,
            Parent = tab.Button,
        })
        
        Utils.AddCorner(tab.Indicator, CONFIG.CornerRadius.SM)
        
        -- Tab content
        tab.Content = Utils.CreateInstance("ScrollingFrame", {
            Name = "TabContent_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 8,
            ScrollBarImageColor3 = CONFIG.Colors.White,
            Visible = false,
            ZIndex = CONFIG.ZIndex.Base + 1,
            Parent = self.ContentArea,
        })
        
        Utils.AddPadding(tab.Content, CONFIG.Spacing.LG)
        Utils.AddListLayout(tab.Content, CONFIG.Spacing.LG, Enum.FillDirection.Vertical)
        
        -- Tab activation
        tab.Button.MouseButton1Click:Connect(function()
            self:ActivateTab(tab)
        end)
        
        tab.Button.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab then
                Utils.Tween(tab.Button, {BackgroundColor3 = CONFIG.Colors.Gray750}, 0.2)
            end
        end)
        
        tab.Button.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab then
                Utils.Tween(tab.Button, {BackgroundColor3 = CONFIG.Colors.Gray800}, 0.2)
            end
        end)
        
        -- Section creation
        function tab:CreateSection(sectionName)
            local section = {
                Name = sectionName,
                Elements = {},
            }
            
            section.Frame = Utils.CreateInstance("Frame", {
                Name = "Section_" .. sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = CONFIG.Colors.Gray800,
                BorderSizePixel = 0,
                ZIndex = CONFIG.ZIndex.Base + 2,
                Parent = tab.Content,
            })
            
            Utils.AddStroke(section.Frame, CONFIG.Colors.Gray700, CONFIG.BorderWidth)
            Utils.AddCorner(section.Frame, CONFIG.CornerRadius.LG)
            Utils.AddPadding(section.Frame, CONFIG.Spacing.LG)
            Utils.AddListLayout(section.Frame, CONFIG.Spacing.MD, Enum.FillDirection.Vertical)
            
            section.Title = Utils.CreateInstance("TextLabel", {
                Name = "SectionTitle",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Font = CONFIG.Fonts.Display,
                TextSize = CONFIG.FontSizes.LG,
                TextColor3 = CONFIG.Colors.White,
                Text = sectionName:upper(),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = CONFIG.ZIndex.Base + 3,
                Parent = section.Frame,
            })
            
            table.insert(tab.Sections, section)
            return section
        end
        
        table.insert(self.Tabs, tab)
        
        -- Activate first tab
        if #self.Tabs == 1 then
            self:ActivateTab(tab)
        end
        
        return tab
    end
    
    function window:ActivateTab(tab)
        -- Deactivate current tab
        if self.CurrentTab then
            self.CurrentTab.Content.Visible = false
            self.CurrentTab.Indicator.Visible = false
            Utils.Tween(self.CurrentTab.Button, {BackgroundColor3 = CONFIG.Colors.Gray800}, 0.2)
            Utils.Tween(self.CurrentTab.Button, {TextColor3 = CONFIG.Colors.Gray400}, 0.2)
        end
        
        -- Activate new tab
        self.CurrentTab = tab
        tab.Content.Visible = true
        tab.Indicator.Visible = true
        Utils.Tween(tab.Button, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
        Utils.Tween(tab.Button, {TextColor3 = CONFIG.Colors.White}, 0.2)
    end
    
    table.insert(self.Windows, window)
    return window
end

-- ============================================
-- BUTTON COMPONENT (УЛУЧШЕННЫЙ)
-- ============================================
function PepsiUI:CreateButton(parent, config)
    config = config or {}
    
    local button = {
        Text = config.Text or "Button",
        Callback = config.Callback or function() end,
    }
    
    button.Frame = Utils.CreateInstance("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.Black,
        Text = button.Text:upper(),
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(button.Frame, CONFIG.Colors.Black, CONFIG.BorderWidth)
    Utils.AddCorner(button.Frame, CONFIG.CornerRadius.MD)
    
    button.Frame.MouseEnter:Connect(function()
        Utils.Tween(button.Frame, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
        Utils.Tween(button.Frame, {TextColor3 = CONFIG.Colors.White}, 0.2)
    end)
    
    button.Frame.MouseLeave:Connect(function()
        Utils.Tween(button.Frame, {BackgroundColor3 = CONFIG.Colors.White}, 0.2)
        Utils.Tween(button.Frame, {TextColor3 = CONFIG.Colors.Black}, 0.2)
    end)
    
    button.Frame.MouseButton1Click:Connect(function()
        button.Callback()
        
        -- Click animation
        Utils.Tween(button.Frame, {Size = UDim2.new(1, 0, 0, 38)}, 0.1)
        task.wait(0.1)
        Utils.Tween(button.Frame, {Size = UDim2.new(1, 0, 0, 40)}, 0.1)
    end)
    
    return button
end

-- ============================================
-- TOGGLE COMPONENT (КРАСИВЫЙ)
-- ============================================
function PepsiUI:CreateToggle(parent, config)
    config = config or {}
    
    local toggle = {
        Text = config.Text or "Toggle",
        Default = config.Default or false,
        Callback = config.Callback or function() end,
        Value = config.Default or false,
    }
    
    toggle.Frame = Utils.CreateInstance("Frame", {
        Name = "Toggle",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(toggle.Frame, CONFIG.Colors.Gray600, CONFIG.BorderWidth)
    Utils.AddCorner(toggle.Frame, CONFIG.CornerRadius.MD)
    
    toggle.Label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        Text = toggle.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = toggle.Frame,
    })
    
    -- Toggle switch background (закругленный)
    toggle.SwitchBg = Utils.CreateInstance("Frame", {
        Name = "SwitchBg",
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -60, 0.5, -13),
        BackgroundColor3 = CONFIG.Colors.Gray600,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = toggle.Frame,
    })
    
    Utils.AddStroke(toggle.SwitchBg, CONFIG.Colors.Gray500, CONFIG.BorderWidth)
    Utils.AddCorner(toggle.SwitchBg, CONFIG.CornerRadius.Full)
    
    -- Toggle switch slider (круглый)
    toggle.Switch = Utils.CreateInstance("Frame", {
        Name = "Switch",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 4, 0.5, -9),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 5,
        Parent = toggle.SwitchBg,
    })
    
    Utils.AddCorner(toggle.Switch, CONFIG.CornerRadius.Full)
    
    -- Button for clicking
    toggle.Button = Utils.CreateInstance("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = CONFIG.ZIndex.Base + 6,
        Parent = toggle.Frame,
    })
    
    function toggle:Set(value)
        self.Value = value
        
        if value then
            -- ON состояние
            Utils.Tween(self.Switch, {
                Position = UDim2.new(1, -22, 0.5, -9),
                BackgroundColor3 = CONFIG.Colors.White,
                Size = UDim2.new(0, 18, 0, 18)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Utils.Tween(self.SwitchBg, {BackgroundColor3 = CONFIG.Colors.Black}, 0.3)
            
            local stroke = self.SwitchBg:FindFirstChildOfClass("UIStroke")
            if stroke then
                Utils.Tween(stroke, {Color = CONFIG.Colors.White}, 0.3)
            end
        else
            -- OFF состояние
            Utils.Tween(self.Switch, {
                Position = UDim2.new(0, 4, 0.5, -9),
                BackgroundColor3 = CONFIG.Colors.White,
                Size = UDim2.new(0, 18, 0, 18)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Utils.Tween(self.SwitchBg, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.3)
            
            local stroke = self.SwitchBg:FindFirstChildOfClass("UIStroke")
            if stroke then
                Utils.Tween(stroke, {Color = CONFIG.Colors.Gray500}, 0.3)
            end
        end
        
        self.Callback(value)
    end
    
    toggle.Button.MouseButton1Click:Connect(function()
        -- Анимация нажатия
        Utils.Tween(toggle.Switch, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
        task.wait(0.1)
        toggle:Set(not toggle.Value)
    end)
    
    toggle.Frame.MouseEnter:Connect(function()
        Utils.Tween(toggle.Frame, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.2)
    end)
    
    toggle.Frame.MouseLeave:Connect(function()
        Utils.Tween(toggle.Frame, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
    end)
    
    -- Set initial state
    toggle:Set(toggle.Default)
    
    return toggle
end

-- ============================================
-- SLIDER COMPONENT (С КРУГЛЯШКАМИ)
-- ============================================
function PepsiUI:CreateSlider(parent, config)
    config = config or {}
    
    local slider = {
        Text = config.Text or "Slider",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 50,
        Increment = config.Increment or 1,
        Callback = config.Callback or function() end,
        Value = config.Default or 50,
    }
    
    slider.Frame = Utils.CreateInstance("Frame", {
        Name = "Slider",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(slider.Frame, CONFIG.Colors.Gray600, CONFIG.BorderWidth)
    Utils.AddCorner(slider.Frame, CONFIG.CornerRadius.MD)
    
    -- Label and value
    slider.Label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        Text = slider.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = slider.Frame,
    })
    
    slider.ValueLabel = Utils.CreateInstance("TextLabel", {
        Name = "ValueLabel",
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -75, 0, 8),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.Gray300,
        Text = tostring(slider.Value),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = slider.Frame,
    })
    
    -- Slider bar background
    slider.Bar = Utils.CreateInstance("Frame", {
        Name = "Bar",
        Size = UDim2.new(1, -30, 0, 8),
        Position = UDim2.new(0, 15, 1, -20),
        BackgroundColor3 = CONFIG.Colors.Gray600,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = slider.Frame,
    })
    
    Utils.AddStroke(slider.Bar, CONFIG.Colors.Gray500, 1)
    Utils.AddCorner(slider.Bar, CONFIG.CornerRadius.Full)
    
    -- Slider fill
    slider.Fill = Utils.CreateInstance("Frame", {
        Name = "Fill",
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 5,
        Parent = slider.Bar,
    })
    
    Utils.AddCorner(slider.Fill, CONFIG.CornerRadius.Full)
    
    -- Slider handle (КРУГЛЫЙ!)
    slider.Handle = Utils.CreateInstance("Frame", {
        Name = "Handle",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 6,
        Parent = slider.Bar,
    })
    
    Utils.AddStroke(slider.Handle, CONFIG.Colors.Black, CONFIG.BorderWidth)
    Utils.AddCorner(slider.Handle, CONFIG.CornerRadius.Full)
    
    -- Dragging functionality
    local dragging = false
    
    function slider:Set(value)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor(value / self.Increment + 0.5) * self.Increment
        self.Value = value
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        
        Utils.Tween(self.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15)
        Utils.Tween(self.Handle, {Position = UDim2.new(percent, -10, 0.5, -10)}, 0.15)
        
        self.ValueLabel.Text = tostring(value)
        self.Callback(value)
    end
    
    slider.Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local barPos = slider.Bar.AbsolutePosition
            local barSize = slider.Bar.AbsoluteSize
            
            local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
            local percent = relativeX / barSize.X
            local value = slider.Min + (slider.Max - slider.Min) * percent
            
            slider:Set(value)
        end
    end)
    
    slider.Handle.MouseEnter:Connect(function()
        Utils.Tween(slider.Handle, {Size = UDim2.new(0, 24, 0, 24)}, 0.15)
    end)
    
    slider.Handle.MouseLeave:Connect(function()
        if not dragging then
            Utils.Tween(slider.Handle, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
        end
    end)
    
    -- Set initial value
    slider:Set(slider.Default)
    
    return slider
end

-- ============================================
-- DROPDOWN COMPONENT (ИСПРАВЛЕН С СДВИГОМ)
-- ============================================
function PepsiUI:CreateDropdown(parent, config)
    config = config or {}
    
    local dropdown = {
        Text = config.Text or "Dropdown",
        Options = config.Options or {"Option 1", "Option 2", "Option 3"},
        Default = config.Default or config.Options[1],
        Callback = config.Callback or function() end,
        Value = config.Default or config.Options[1],
        Open = false,
        ExpandedHeight = 0,
    }
    
    dropdown.Frame = Utils.CreateInstance("Frame", {
        Name = "Dropdown",
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(dropdown.Frame, CONFIG.Colors.Gray600, CONFIG.BorderWidth)
    Utils.AddCorner(dropdown.Frame, CONFIG.CornerRadius.MD)
    
    -- Label
    dropdown.Label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -30, 0, 15),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.XS,
        TextColor3 = CONFIG.Colors.Gray400,
        Text = dropdown.Text:upper(),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = dropdown.Frame,
    })
    
    -- Selected value display
    dropdown.Display = Utils.CreateInstance("TextButton", {
        Name = "Display",
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.new(0, 15, 0, 28),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        Text = dropdown.Value,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = dropdown.Frame,
    })
    
    -- Arrow indicator
    dropdown.Arrow = Utils.CreateInstance("TextLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -35, 0, 35),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Display,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        Text = "▼",
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = dropdown.Frame,
    })
    
    -- Options container
    dropdown.OptionsFrame = Utils.CreateInstance("Frame", {
        Name = "Options",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundColor3 = CONFIG.Colors.Gray800,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = CONFIG.ZIndex.Dropdown,
        Parent = dropdown.Frame,
    })
    
    Utils.AddStroke(dropdown.OptionsFrame, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(dropdown.OptionsFrame, CONFIG.CornerRadius.MD)
    
    dropdown.OptionsList = Utils.CreateInstance("ScrollingFrame", {
        Name = "OptionsList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = CONFIG.Colors.White,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = dropdown.OptionsFrame,
    })
    
    Utils.AddListLayout(dropdown.OptionsList, 2, Enum.FillDirection.Vertical)
    
    function dropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            -- Register as active dropdown
            table.insert(PepsiUI.ActiveDropdowns or {}, self)
            
            -- Calculate height
            local optionHeight = 35
            local maxVisible = 5
            local totalHeight = math.min(#self.Options * optionHeight, maxVisible * optionHeight)
            self.ExpandedHeight = totalHeight + 4
            
            -- СДВИГ ЭЛЕМЕНТОВ ВНИЗ
            Utils.ShiftElementsBelow(self.Frame, self.ExpandedHeight, false)
            
            self.OptionsFrame.Visible = true
            Utils.Tween(self.OptionsFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3)
            Utils.Tween(self.Arrow, {Rotation = 180}, 0.2)
            Utils.Tween(self.Frame, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.2)
        else
            self:Close()
        end
    end
    
    function dropdown:Close()
        if not self.Open then return end
        
        self.Open = false
        
        -- ВОССТАНОВЛЕНИЕ ПОЗИЦИЙ ЭЛЕМЕНТОВ
        Utils.ShiftElementsBelow(self.Frame, self.ExpandedHeight, true)
        
        Utils.Tween(self.OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        self.OptionsFrame.Visible = false
        Utils.Tween(self.Arrow, {Rotation = 0}, 0.2)
        Utils.Tween(self.Frame, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
        
        -- Remove from active dropdowns
        if PepsiUI.ActiveDropdowns then
            for i, dd in ipairs(PepsiUI.ActiveDropdowns) do
                if dd == self then
                    table.remove(PepsiUI.ActiveDropdowns, i)
                    break
                end
            end
        end
    end
    
    function dropdown:Set(value)
        self.Value = value
        self.Display.Text = value
        self.Callback(value)
        self:Close()
    end
    
    function dropdown:Refresh(options)
        self.Options = options
        
        -- Clear existing options
        for _, child in pairs(self.OptionsList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Create new options
        for _, optionText in ipairs(options) do
            local option = Utils.CreateInstance("TextButton", {
                Name = "Option_" .. optionText,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = CONFIG.Colors.Gray700,
                BorderSizePixel = 0,
                Font = CONFIG.Fonts.Mono,
                TextSize = CONFIG.FontSizes.Base,
                TextColor3 = CONFIG.Colors.White,
                Text = optionText,
                ZIndex = CONFIG.ZIndex.Dropdown + 2,
                Parent = self.OptionsList,
            })
            
            Utils.AddStroke(option, CONFIG.Colors.Gray600, 1)
            Utils.AddCorner(option, CONFIG.CornerRadius.SM)
            
            option.MouseButton1Click:Connect(function()
                dropdown:Set(optionText)
            end)
            
            option.MouseEnter:Connect(function()
                Utils.Tween(option, {BackgroundColor3 = CONFIG.Colors.Black}, 0.15)
            end)
            
            option.MouseLeave:Connect(function()
                Utils.Tween(option, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.15)
            end)
        end
        
        self.OptionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 37)
    end
    
    dropdown.Display.MouseButton1Click:Connect(function()
        dropdown:Toggle()
    end)
    
    dropdown.Frame.MouseEnter:Connect(function()
        if not dropdown.Open then
            Utils.Tween(dropdown.Frame, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.2)
        end
    end)
    
    dropdown.Frame.MouseLeave:Connect(function()
        if not dropdown.Open then
            Utils.Tween(dropdown.Frame, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
        end
    end)
    
    -- Initialize options
    dropdown:Refresh(dropdown.Options)
    dropdown:Set(dropdown.Default)
    
    return dropdown
end

-- ============================================
-- TEXTBOX/INPUT COMPONENT
-- ============================================
function PepsiUI:CreateTextbox(parent, config)
    config = config or {}
    
    local textbox = {
        Text = config.Text or "Input",
        Default = config.Default or "",
        Placeholder = config.Placeholder or "Enter text...",
        Callback = config.Callback or function() end,
        Value = config.Default or "",
    }
    
    textbox.Frame = Utils.CreateInstance("Frame", {
        Name = "Textbox",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(textbox.Frame, CONFIG.Colors.Gray600, CONFIG.BorderWidth)
    Utils.AddCorner(textbox.Frame, CONFIG.CornerRadius.MD)
    
    textbox.Label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -30, 0, 18),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.XS,
        TextColor3 = CONFIG.Colors.Gray400,
        Text = textbox.Text:upper(),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = textbox.Frame,
    })
    
    textbox.Input = Utils.CreateInstance("TextBox", {
        Name = "Input",
        Size = UDim2.new(1, -30, 0, 25),
        Position = UDim2.new(0, 15, 0, 28),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        PlaceholderText = textbox.Placeholder,
        PlaceholderColor3 = CONFIG.Colors.Gray500,
        Text = textbox.Default,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = textbox.Frame,
    })
    
    textbox.Input.Focused:Connect(function()
        Utils.Tween(textbox.Frame, {BackgroundColor3 = CONFIG.Colors.Black}, 0.2)
        local stroke = textbox.Frame:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utils.Tween(stroke, {Color = CONFIG.Colors.White}, 0.2)
        end
    end)
    
    textbox.Input.FocusLost:Connect(function()
        Utils.Tween(textbox.Frame, {BackgroundColor3 = CONFIG.Colors.Gray700}, 0.2)
        local stroke = textbox.Frame:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utils.Tween(stroke, {Color = CONFIG.Colors.Gray600}, 0.2)
        end
        
        textbox.Value = textbox.Input.Text
        textbox.Callback(textbox.Value)
    end)
    
    return textbox
end

-- ============================================
-- KEYBIND COMPONENT
-- ============================================
function PepsiUI:CreateKeybind(parent, config)
    config = config or {}
    
    local keybind = {
        Text = config.Text or "Keybind",
        Default = config.Default or Enum.KeyCode.E,
        Callback = config.Callback or function() end,
        Key = config.Default or Enum.KeyCode.E,
        Listening = false,
    }
    
    keybind.Frame = Utils.CreateInstance("Frame", {
        Name = "Keybind",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(keybind.Frame, CONFIG.Colors.Gray600, CONFIG.BorderWidth)
    Utils.AddCorner(keybind.Frame, CONFIG.CornerRadius.MD)
    
    keybind.Label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        Text = keybind.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = keybind.Frame,
    })
    
    keybind.Button = Utils.CreateInstance("TextButton", {
        Name = "Button",
        Size = UDim2.new(0, 70, 0, 28),
        Position = UDim2.new(1, -85, 0.5, -14),
        BackgroundColor3 = CONFIG.Colors.Gray600,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.SM,
        TextColor3 = CONFIG.Colors.White,
        Text = keybind.Key.Name,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = keybind.Frame,
    })
    
    Utils.AddStroke(keybind.Button, CONFIG.Colors.Gray500, CONFIG.BorderWidth)
    Utils.AddCorner(keybind.Button, CONFIG.CornerRadius.MD)
    
    function keybind:Set(key)
        self.Key = key
        self.Button.Text = key.Name
        self.Listening = false
        Utils.Tween(self.Button, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.2)
        self.Callback(key)
    end
    
    keybind.Button.MouseButton1Click:Connect(function()
        keybind.Listening = true
        keybind.Button.Text = "..."
        Utils.Tween(keybind.Button, {BackgroundColor3 = CONFIG.Colors.White}, 0.2)
        Utils.Tween(keybind.Button, {TextColor3 = CONFIG.Colors.Black}, 0.2)
    end)
    
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybind:Set(input.KeyCode)
            Utils.Tween(keybind.Button, {TextColor3 = CONFIG.Colors.White}, 0.2)
        end
        
        if not gameProcessed and input.KeyCode == keybind.Key then
            keybind.Callback(keybind.Key)
        end
    end)
    
    keybind.Button.MouseEnter:Connect(function()
        if not keybind.Listening then
            Utils.Tween(keybind.Button, {BackgroundColor3 = CONFIG.Colors.Gray500}, 0.2)
        end
    end)
    
    keybind.Button.MouseLeave:Connect(function()
        if not keybind.Listening then
            Utils.Tween(keybind.Button, {BackgroundColor3 = CONFIG.Colors.Gray600}, 0.2)
        end
    end)
    
    return keybind
end

-- ============================================
-- LABEL/TEXT COMPONENT
-- ============================================
function PepsiUI:CreateLabel(parent, config)
    config = config or {}
    
    local label = {
        Text = config.Text or "Label",
    }
    
    label.Frame = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.Gray300,
        Text = label.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    function label:Set(text)
        self.Text = text
        self.Frame.Text = text
    end
    
    return label
end

-- ============================================
-- DIVIDER/SEPARATOR COMPONENT
-- ============================================
function PepsiUI:CreateDivider(parent)
    local divider = Utils.CreateInstance("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = CONFIG.Colors.Gray600,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddCorner(divider, CONFIG.CornerRadius.Full)
    
    return divider
end

-- ============================================
-- COLOR PICKER COMPONENT (КРАСИВЫЙ)
-- ============================================
function PepsiUI:CreateColorPicker(parent, config)
    config = config or {}
    
    local colorPicker = {
        Text = config.Text or "Color Picker",
        Default = config.Default or Color3.fromRGB(255, 255, 255),
        Callback = config.Callback or function() end,
        Value = config.Default or Color3.fromRGB(255, 255, 255),
        Open = false,
        ExpandedHeight = 294,
    }
    
    colorPicker.Frame = Utils.CreateInstance("Frame", {
        Name = "ColorPicker",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CONFIG.Colors.Gray700,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 3,
        Parent = parent,
    })
    
    Utils.AddStroke(colorPicker.Frame, CONFIG.Colors.Gray600, CONFIG.BorderWidth)
    Utils.AddCorner(colorPicker.Frame, CONFIG.CornerRadius.MD)
    
    colorPicker.Label = Utils.CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -65, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Base,
        TextColor3 = CONFIG.Colors.White,
        Text = colorPicker.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = colorPicker.Frame,
    })
    
    colorPicker.Preview = Utils.CreateInstance("TextButton", {
        Name = "Preview",
        Size = UDim2.new(0, 40, 0, 28),
        Position = UDim2.new(1, -55, 0.5, -14),
        BackgroundColor3 = colorPicker.Value,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = CONFIG.ZIndex.Base + 4,
        Parent = colorPicker.Frame,
    })
    
    Utils.AddStroke(colorPicker.Preview, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(colorPicker.Preview, CONFIG.CornerRadius.MD)
    
    -- Color picker modal (УЛУЧШЕННЫЙ)
    colorPicker.Picker = Utils.CreateInstance("Frame", {
        Name = "Picker",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = CONFIG.Colors.Gray800,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = CONFIG.ZIndex.Dropdown,
        Parent = colorPicker.Frame,
    })
    
    Utils.AddStroke(colorPicker.Picker, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(colorPicker.Picker, CONFIG.CornerRadius.LG)
    
    -- HSV Canvas
    colorPicker.Canvas = Utils.CreateInstance("ImageButton", {
        Name = "Canvas",
        Size = UDim2.new(1, -20, 0, 180),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = colorPicker.Picker,
    })
    
    Utils.AddStroke(colorPicker.Canvas, CONFIG.Colors.White, 2)
    Utils.AddCorner(colorPicker.Canvas, CONFIG.CornerRadius.LG)
    
    -- Gradient overlays for saturation and value
    local saturation = Utils.CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 2,
        Parent = colorPicker.Canvas,
    })
    
    Utils.AddCorner(saturation, CONFIG.CornerRadius.LG)
    
    local satGradient = Utils.CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Rotation = 0,
        Parent = saturation,
    })
    
    local value = Utils.CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 3,
        Parent = colorPicker.Canvas,
    })
    
    Utils.AddCorner(value, CONFIG.CornerRadius.LG)
    
    local valGradient = Utils.CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90,
        Parent = value,
    })
    
    -- Cursor (КРАСИВЫЙ КРУГЛЫЙ)
    colorPicker.Cursor = Utils.CreateInstance("Frame", {
        Name = "Cursor",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -8, 0, -8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 4,
        Parent = colorPicker.Canvas,
    })
    
    Utils.AddStroke(colorPicker.Cursor, CONFIG.Colors.Black, 3)
    Utils.AddCorner(colorPicker.Cursor, CONFIG.CornerRadius.Full)
    
    -- Hue slider (КРАСИВЫЙ)
    colorPicker.HueFrame = Utils.CreateInstance("Frame", {
        Name = "HueFrame",
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 200),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = colorPicker.Picker,
    })
    
    Utils.AddStroke(colorPicker.HueFrame, CONFIG.Colors.White, 2)
    Utils.AddCorner(colorPicker.HueFrame, CONFIG.CornerRadius.Full)
    
    local hueGradient = Utils.CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = colorPicker.HueFrame,
    })
    
    -- RGB Display (КРАСИВЫЙ)
    colorPicker.RGBLabel = Utils.CreateInstance("TextLabel", {
        Name = "RGB",
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 234),
        BackgroundColor3 = CONFIG.Colors.Gray900,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.SM,
        TextColor3 = CONFIG.Colors.White,
        Text = "RGB: 255, 255, 255",
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = colorPicker.Picker,
    })
    
    Utils.AddStroke(colorPicker.RGBLabel, CONFIG.Colors.Gray700, 2)
    Utils.AddCorner(colorPicker.RGBLabel, CONFIG.CornerRadius.MD)
    
    -- Hex Display
    colorPicker.HexLabel = Utils.CreateInstance("TextLabel", {
        Name = "HEX",
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 268),
        BackgroundColor3 = CONFIG.Colors.Gray900,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.SM,
        TextColor3 = CONFIG.Colors.White,
        Text = "HEX: #FFFFFF",
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = colorPicker.Picker,
    })
    
    Utils.AddStroke(colorPicker.HexLabel, CONFIG.Colors.Gray700, 2)
    Utils.AddCorner(colorPicker.HexLabel, CONFIG.CornerRadius.MD)
    
    -- Color picker logic
    local h, s, v = 0, 1, 1
    
    local function updateColor()
        local color = Color3.fromHSV(h, s, v)
        colorPicker.Value = color
        colorPicker.Preview.BackgroundColor3 = color
        
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        colorPicker.RGBLabel.Text = string.format("RGB: %d, %d, %d", r, g, b)
        
        local hex = string.format("#%02X%02X%02X", r, g, b)
        colorPicker.HexLabel.Text = "HEX: " .. hex
        
        colorPicker.Callback(color)
    end
    
    local function updateHue(input)
        local relativeX = math.clamp(
            input.Position.X - colorPicker.HueFrame.AbsolutePosition.X,
            0,
            colorPicker.HueFrame.AbsoluteSize.X
        )
        h = relativeX / colorPicker.HueFrame.AbsoluteSize.X
        
        colorPicker.Canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        updateColor()
    end
    
    local function updateSV(input)
        local relativeX = math.clamp(
            input.Position.X - colorPicker.Canvas.AbsolutePosition.X,
            0,
            colorPicker.Canvas.AbsoluteSize.X
        )
        local relativeY = math.clamp(
            input.Position.Y - colorPicker.Canvas.AbsolutePosition.Y,
            0,
            colorPicker.Canvas.AbsoluteSize.Y
        )
        
        s = relativeX / colorPicker.Canvas.AbsoluteSize.X
        v = 1 - (relativeY / colorPicker.Canvas.AbsoluteSize.Y)
        
        colorPicker.Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        updateColor()
    end
    
    local hueDragging = false
    local canvasDragging = false
    
    colorPicker.HueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            updateHue(input)
        end
    end)
    
    colorPicker.HueFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    colorPicker.Canvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            canvasDragging = true
            updateSV(input)
        end
    end)
    
    colorPicker.Canvas.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            canvasDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if hueDragging then
                updateHue(input)
            end
            if canvasDragging then
                updateSV(input)
            end
        end
    end)
    
    function colorPicker:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            table.insert(PepsiUI.ActiveDropdowns or {}, self)
            
            -- СДВИГ ЭЛЕМЕНТОВ ВНИЗ
            Utils.ShiftElementsBelow(self.Frame, self.ExpandedHeight, false)
            
            self.Picker.Visible = true
            Utils.Tween(self.Picker, {Size = UDim2.new(1, 0, 0, 302)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self:Close()
        end
    end
    
    function colorPicker:Close()
        if not self.Open then return end
        
        self.Open = false
        
        -- ВОССТАНОВЛЕНИЕ ПОЗИЦИЙ ЭЛЕМЕНТОВ
        Utils.ShiftElementsBelow(self.Frame, self.ExpandedHeight, true)
        
        Utils.Tween(self.Picker, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        self.Picker.Visible = false
    end
    
    function colorPicker:Set(color)
        self.Value = color
        self.Preview.BackgroundColor3 = color
        
        -- Convert to HSV
        h, s, v = color:ToHSV()
        colorPicker.Canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        colorPicker.Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        self.RGBLabel.Text = string.format("RGB: %d, %d, %d", r, g, b)
        
        local hex = string.format("#%02X%02X%02X", r, g, b)
        self.HexLabel.Text = "HEX: " .. hex
    end
    
    colorPicker.Preview.MouseButton1Click:Connect(function()
        colorPicker:Toggle()
    end)
    
    colorPicker:Set(colorPicker.Default)
    
    return colorPicker
end

-- ============================================
-- NOTIFICATION SYSTEM (УЛУЧШЕННЫЙ)
-- ============================================
function PepsiUI:Notify(config)
    config = config or {}
    
    local notification = {
        Title = config.Title or "Notification",
        Text = config.Text or "This is a notification",
        Duration = config.Duration or 3,
    }
    
    -- Create notifications container if it doesn't exist
    if not self.NotificationsContainer then
        self.NotificationsContainer = Utils.CreateInstance("Frame", {
            Name = "Notifications",
            Size = UDim2.new(0, 320, 1, 0),
            Position = UDim2.new(1, -330, 0, 10),
            BackgroundTransparency = 1,
            ZIndex = CONFIG.ZIndex.Notification,
            Parent = self.ScreenGui,
        })
        
        Utils.AddListLayout(self.NotificationsContainer, CONFIG.Spacing.SM, Enum.FillDirection.Vertical)
    end
    
    notification.Frame = Utils.CreateInstance("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundColor3 = CONFIG.Colors.Gray800,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Notification + 1,
        Parent = self.NotificationsContainer,
    })
    
    Utils.AddStroke(notification.Frame, CONFIG.Colors.White, CONFIG.BorderWidth)
    Utils.AddCorner(notification.Frame, CONFIG.CornerRadius.LG)
    
    -- Accent line
    local accentLine = Utils.CreateInstance("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Notification + 2,
        Parent = notification.Frame,
    })
    
    Utils.AddCorner(accentLine, CONFIG.CornerRadius.SM)
    
    local content = Utils.CreateInstance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Notification + 2,
        Parent = notification.Frame,
    })
    
    Utils.AddPadding(content, CONFIG.Spacing.MD)
    
    notification.Title = Utils.CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Display,
        TextSize = CONFIG.FontSizes.LG,
        TextColor3 = CONFIG.Colors.White,
        Text = notification.Title,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Notification + 3,
        Parent = content,
    })
    
    notification.Text = Utils.CreateInstance("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, 0, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.SM,
        TextColor3 = CONFIG.Colors.Gray300,
        Text = notification.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = CONFIG.ZIndex.Notification + 3,
        Parent = content,
    })
    
    -- Animate in (FROM RIGHT WITH FADE)
    notification.Frame.Position = UDim2.new(1, 50, 0, 0)
    notification.Frame.BackgroundTransparency = 1
    
    Utils.Tween(notification.Frame, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Progress bar
    local progressBar = Utils.CreateInstance("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = CONFIG.Colors.White,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Notification + 3,
        Parent = notification.Frame,
    })
    
    Utils.AddCorner(progressBar, CONFIG.CornerRadius.Full)
    
    -- Animate progress bar
    Utils.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, notification.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    
    -- Auto remove
    task.delay(notification.Duration, function()
        Utils.Tween(notification.Frame, {
            Position = UDim2.new(1, 50, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        
        task.wait(0.3)
        notification.Frame:Destroy()
    end)
    
    return notification
end

-- ============================================
-- UTILITY METHODS
-- ============================================
function PepsiUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function PepsiUI:Toggle()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

-- ============================================
-- RETURN MODULE
-- ============================================
return PepsiUI
