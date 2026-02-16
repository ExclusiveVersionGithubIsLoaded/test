--[[
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                    PEPSI UI LIBRARY v3.0                          ║
    ║                   DragWare Professional Style                     ║
    ║                     Full Production Build                         ║
    ╚═══════════════════════════════════════════════════════════════════╝
    
    FEATURES:
    ✓ Watermark with live stats (top)
    ✓ KeyBinds panel (right side)
    ✓ Horizontal tabs (Combat, Visuals, Misc)
    ✓ Background image support
    ✓ Dropdown/ColorPicker with Z-Index 1500+ (always on top)
    ✓ Column-based sections (left/right)
    ✓ All components: Toggle, Slider, Dropdown, Keybind, ColorPicker, TextBox
    ✓ Professional strict design
    ✓ 3000+ lines of production code
]]

local PepsiUI = {}
PepsiUI.__index = PepsiUI
PepsiUI.Version = "3.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

-- ============================================
-- CONFIGURATION SYSTEM
-- ============================================
local CONFIG = {
    -- Color Palette (Strict Dark Theme)
    Colors = {
        -- Backgrounds
        Background = Color3.fromRGB(18, 18, 18),
        BackgroundLight = Color3.fromRGB(22, 22, 22),
        Sidebar = Color3.fromRGB(14, 14, 14),
        Header = Color3.fromRGB(20, 20, 20),
        
        -- Accents
        Accent = Color3.fromRGB(138, 43, 226), -- Purple
        AccentDark = Color3.fromRGB(110, 30, 200),
        AccentLight = Color3.fromRGB(150, 60, 230),
        
        -- Text
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(170, 170, 170),
        TextDimmed = Color3.fromRGB(120, 120, 120),
        
        -- States
        Border = Color3.fromRGB(35, 35, 35),
        BorderLight = Color3.fromRGB(45, 45, 45),
        Hover = Color3.fromRGB(28, 28, 28),
        Active = Color3.fromRGB(32, 32, 32),
        
        -- Status
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(220, 80, 80),
        Info = Color3.fromRGB(80, 160, 220),
    },
    
    -- Typography
    Fonts = {
        Main = Enum.Font.Code,
        Bold = Enum.Font.CodeBold,
        Mono = Enum.Font.RobotoMono,
    },
    
    FontSizes = {
        Tiny = 9,
        Small = 11,
        Medium = 13,
        Large = 15,
        XLarge = 17,
    },
    
    -- Spacing & Layout
    Spacing = {
        Tiny = 2,
        Small = 4,
        Medium = 6,
        Large = 8,
        XLarge = 12,
    },
    
    -- Border Radius
    CornerRadius = {
        None = 0,
        Small = 2,
        Medium = 4,
        Large = 6,
    },
    
    -- Animation
    Animation = {
        Fast = 0.1,
        Normal = 0.2,
        Slow = 0.3,
        VerySlow = 0.5,
    },
    
    -- Z-Index Layers
    ZIndex = {
        Background = 0,
        Base = 1,
        Content = 50,
        Header = 100,
        Overlay = 500,
        Dropdown = 1500,
        Modal = 2000,
        Tooltip = 2500,
    },
    
    -- Component Sizes
    Sizes = {
        WatermarkHeight = 20,
        HeaderHeight = 30,
        TabHeight = 30,
        SectionPadding = 6,
        ComponentHeight = 18,
        SliderHeight = 32,
        DropdownHeight = 36,
        ColorPickerSize = 250,
    },
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local Utility = {}

function Utility.Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            pcall(function()
                instance[property] = value
            end)
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.Tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or CONFIG.Animation.Normal
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility.AddCorner(parent, radius)
    radius = radius or CONFIG.CornerRadius.Medium
    return Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent,
    })
end

function Utility.AddStroke(parent, color, thickness)
    color = color or CONFIG.Colors.Border
    thickness = thickness or 1
    return Utility.Create("UIStroke", {
        Color = color,
        Thickness = thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function Utility.AddPadding(parent, padding)
    local p = padding or CONFIG.Spacing.Medium
    return Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, p),
        PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p),
        PaddingRight = UDim.new(0, p),
        Parent = parent,
    })
end

function Utility.AddListLayout(parent, padding, direction, horizontalAlign, verticalAlign)
    padding = padding or CONFIG.Spacing.Small
    direction = direction or Enum.FillDirection.Vertical
    
    return Utility.Create("UIListLayout", {
        Padding = UDim.new(0, padding),
        FillDirection = direction,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = horizontalAlign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = verticalAlign or Enum.VerticalAlignment.Top,
        Parent = parent,
    })
end

function Utility.AddGridLayout(parent, cellSize, padding)
    cellSize = cellSize or UDim2.new(0, 100, 0, 100)
    padding = padding or UDim2.new(0, CONFIG.Spacing.Small, 0, CONFIG.Spacing.Small)
    
    return Utility.Create("UIGridLayout", {
        CellSize = cellSize,
        CellPadding = padding,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Utility.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility.RGBToHex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

function Utility.HexToRGB(hex)
    hex = hex:gsub("#", "")
    local r = tonumber("0x" .. hex:sub(1, 2)) / 255
    local g = tonumber("0x" .. hex:sub(3, 4)) / 255
    local b = tonumber("0x" .. hex:sub(5, 6)) / 255
    return Color3.new(r, g, b)
end

-- ============================================
-- MAIN UI CLASS
-- ============================================
function PepsiUI.new(title, config)
    local self = setmetatable({}, PepsiUI)
    
    -- Properties
    self.Title = title or "dragware"
    self.Config = config or {}
    self.Tabs = {}
    self.ActiveTab = nil
    self.ActiveDropdowns = {}
    self.Keybinds = {}
    self.Notifications = {}
    
    -- Create ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "PepsiUI_" .. self.Title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui"),
    })
    
    -- Initialize Components
    self:CreateBackground()
    self:CreateWatermark()
    self:CreateKeybindsPanel()
    self:CreateMainWindow()
    self:SetupInputHandlers()
    self:StartUpdateLoop()
    
    return self
end

-- ============================================
-- BACKGROUND SYSTEM
-- ============================================
function PepsiUI:CreateBackground()
    self.BackgroundContainer = Utility.Create("Frame", {
        Name = "BackgroundContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Background,
        Parent = self.ScreenGui,
    })
    
    self.BackgroundImage = Utility.Create("ImageLabel", {
        Name = "BackgroundImage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "",
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = CONFIG.ZIndex.Background,
        Parent = self.BackgroundContainer,
    })
    
    -- Vignette Effect
    self.Vignette = Utility.Create("ImageLabel", {
        Name = "Vignette",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4576475446",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.3,
        ZIndex = CONFIG.ZIndex.Background + 1,
        Parent = self.BackgroundContainer,
    })
end

function PepsiUI:SetBackgroundImage(imageId)
    if type(imageId) == "number" then
        self.BackgroundImage.Image = "rbxassetid://" .. imageId
    else
        self.BackgroundImage.Image = imageId
    end
end

function PepsiUI:SetBackgroundTransparency(transparency)
    self.BackgroundImage.ImageTransparency = math.clamp(transparency, 0, 1)
end

-- ============================================
-- WATERMARK COMPONENT
-- ============================================
function PepsiUI:CreateWatermark()
    local watermark = Utility.Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 450, 0, CONFIG.Sizes.WatermarkHeight),
        Position = UDim2.new(0.5, -225, 0, 5),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay,
        Parent = self.ScreenGui,
    })
    
    Utility.AddCorner(watermark, CONFIG.CornerRadius.Small)
    Utility.AddStroke(watermark, CONFIG.Colors.Border, 1)
    
    -- Accent Line
    local accentLine = Utility.Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = CONFIG.Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay + 1,
        Parent = watermark,
    })
    
    -- Text Label
    self.WatermarkLabel = Utility.Create("TextLabel", {
        Name = "WatermarkLabel",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = self.Title .. " | 0ms | 0fps | 0plr | 0mb",
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = CONFIG.ZIndex.Overlay + 2,
        Parent = watermark,
    })
    
    self.Watermark = watermark
end

function PepsiUI:UpdateWatermark()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    local players = #Players:GetPlayers()
    local memory = math.floor(Stats:GetTotalMemoryUsageMb())
    
    self.WatermarkLabel.Text = string.format(
        "%s | %dms | %dfps | %dplr | %dmb",
        self.Title, ping, fps, players, memory
    )
end

-- ============================================
-- KEYBINDS PANEL
-- ============================================
function PepsiUI:CreateKeybindsPanel()
    local panel = Utility.Create("Frame", {
        Name = "KeybindsPanel",
        Size = UDim2.new(0, 180, 0, 25),
        Position = UDim2.new(1, -190, 0.5, -100),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay,
        Parent = self.ScreenGui,
    })
    
    Utility.AddCorner(panel, CONFIG.CornerRadius.Medium)
    Utility.AddStroke(panel, CONFIG.Colors.Border, 1)
    
    -- Header
    local header = Utility.Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = CONFIG.Colors.Header,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay + 1,
        Parent = panel,
    })
    
    Utility.AddCorner(header, CONFIG.CornerRadius.Medium)
    
    -- Accent bar
    local accentBar = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = CONFIG.Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay + 2,
        Parent = header,
    })
    
    local title = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Bold,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = "keybinds",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Overlay + 3,
        Parent = header,
    })
    
    -- Content
    local content = Utility.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Overlay + 1,
        Parent = panel,
    })
    
    Utility.AddPadding(content, CONFIG.Spacing.Small)
    
    local listLayout = Utility.AddListLayout(content, 2)
    
    self.KeybindsPanel = panel
    self.KeybindsContent = content
    self.KeybindsListLayout = listLayout
    
    -- Auto-resize
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local height = listLayout.AbsoluteContentSize.Y + 25
        Utility.Tween(panel, {Size = UDim2.new(0, 180, 0, height)}, CONFIG.Animation.Fast)
    end)
    
    Utility.MakeDraggable(panel, header)
end

function PepsiUI:AddKeybindDisplay(name, key, enabled)
    local id = "KB_" .. name:gsub("%s+", "_")
    local existing = self.KeybindsContent:FindFirstChild(id)
    
    if enabled then
        if not existing then
            local container = Utility.Create("Frame", {
                Name = id,
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                ZIndex = CONFIG.ZIndex.Overlay + 2,
                Parent = self.KeybindsContent,
            })
            
            local nameLabel = Utility.Create("TextLabel", {
                Size = UDim2.new(0.65, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = CONFIG.Fonts.Main,
                TextSize = CONFIG.FontSizes.Small,
                TextColor3 = CONFIG.Colors.Text,
                Text = name,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = CONFIG.ZIndex.Overlay + 3,
                Parent = container,
            })
            
            local keyLabel = Utility.Create("TextLabel", {
                Size = UDim2.new(0.35, 0, 1, 0),
                Position = UDim2.new(0.65, 0, 0, 0),
                BackgroundTransparency = 1,
                Font = CONFIG.Fonts.Main,
                TextSize = CONFIG.FontSizes.Small,
                TextColor3 = CONFIG.Colors.TextDark,
                Text = "[" .. key .. "]",
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = CONFIG.ZIndex.Overlay + 3,
                Parent = container,
            })
            
            -- Fade in animation
            container.BackgroundTransparency = 1
            nameLabel.TextTransparency = 1
            keyLabel.TextTransparency = 1
            
            Utility.Tween(nameLabel, {TextTransparency = 0}, CONFIG.Animation.Normal)
            Utility.Tween(keyLabel, {TextTransparency = 0}, CONFIG.Animation.Normal)
        end
    else
        if existing then
            -- Fade out animation
            for _, child in ipairs(existing:GetChildren()) do
                if child:IsA("TextLabel") then
                    Utility.Tween(child, {TextTransparency = 1}, CONFIG.Animation.Normal)
                end
            end
            task.wait(CONFIG.Animation.Normal)
            existing:Destroy()
        end
    end
end

-- ============================================
-- MAIN WINDOW
-- ============================================
function PepsiUI:CreateMainWindow()
    local window = Utility.Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 650, 0, 450),
        Position = UDim2.new(0.5, -325, 0.5, -225),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base,
        Parent = self.ScreenGui,
    })
    
    Utility.AddCorner(window, CONFIG.CornerRadius.Medium)
    Utility.AddStroke(window, CONFIG.Colors.Border, 1)
    
    -- Header
    local header = Utility.Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.HeaderHeight),
        BackgroundColor3 = CONFIG.Colors.Header,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Header,
        Parent = window,
    })
    
    Utility.AddCorner(header, CONFIG.CornerRadius.Medium)
    
    -- Accent line under header
    local headerAccent = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = CONFIG.Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Header + 1,
        Parent = header,
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Bold,
        TextSize = CONFIG.FontSizes.Medium,
        TextColor3 = CONFIG.Colors.Text,
        Text = self.Title,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = CONFIG.ZIndex.Header + 2,
        Parent = header,
    })
    
    -- Tabs Container
    local tabsContainer = Utility.Create("Frame", {
        Name = "TabsContainer",
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.TabHeight),
        Position = UDim2.new(0, 0, 0, CONFIG.Sizes.HeaderHeight),
        BackgroundColor3 = CONFIG.Colors.Sidebar,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 10,
        Parent = window,
    })
    
    Utility.AddListLayout(tabsContainer, 0, Enum.FillDirection.Horizontal)
    
    -- Tab underline (indicator)
    self.TabIndicator = Utility.Create("Frame", {
        Name = "TabIndicator",
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = CONFIG.Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Base + 12,
        Parent = tabsContainer,
    })
    
    -- Content Container
    local contentContainer = Utility.Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipDescendants = true,
        ZIndex = CONFIG.ZIndex.Content,
        Parent = window,
    })
    
    self.Window = window
    self.Header = header
    self.TabsContainer = tabsContainer
    self.ContentContainer = contentContainer
    
    -- Make draggable
    Utility.MakeDraggable(window, header)
end

-- ============================================
-- TAB SYSTEM
-- ============================================
function PepsiUI:AddTab(name, icon)
    local tab = {
        Name = name,
        Icon = icon or "",
        Sections = {},
        Active = false,
        Elements = {},
    }
    
    -- Calculate tab width
    local tabCount = #self.Tabs + 1
    local tabWidth = 650 / math.max(tabCount, 3)
    
    -- Tab Button
    local button = Utility.Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(0, tabWidth, 1, 0),
        BackgroundColor3 = CONFIG.Colors.Sidebar,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Medium,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = "",
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Base + 11,
        Parent = self.TabsContainer,
    })
    
    -- Icon + Text Container
    local textContainer = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Base + 12,
        Parent = button,
    })
    
    if icon and icon ~= "" then
        local iconLabel = Utility.Create("TextLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0.5, -50, 0.5, -9),
            BackgroundTransparency = 1,
            Font = CONFIG.Fonts.Bold,
            TextSize = CONFIG.FontSizes.Medium,
            TextColor3 = CONFIG.Colors.TextDark,
            Text = icon,
            ZIndex = CONFIG.ZIndex.Base + 13,
            Parent = textContainer,
        })
        tab.IconLabel = iconLabel
        
        local textLabel = Utility.Create("TextLabel", {
            Size = UDim2.new(0, 100, 1, 0),
            Position = UDim2.new(0.5, -32, 0, 0),
            BackgroundTransparency = 1,
            Font = CONFIG.Fonts.Main,
            TextSize = CONFIG.FontSizes.Medium,
            TextColor3 = CONFIG.Colors.TextDark,
            Text = string.upper(name),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = CONFIG.ZIndex.Base + 13,
            Parent = textContainer,
        })
        tab.TextLabel = textLabel
    else
        local textLabel = Utility.Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = CONFIG.Fonts.Main,
            TextSize = CONFIG.FontSizes.Medium,
            TextColor3 = CONFIG.Colors.TextDark,
            Text = string.upper(name),
            ZIndex = CONFIG.ZIndex.Base + 13,
            Parent = textContainer,
        })
        tab.TextLabel = textLabel
    end
    
    -- Content ScrollFrame
    local scrollFrame = Utility.Create("ScrollingFrame", {
        Name = "TabContent_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.Colors.Border,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = CONFIG.ZIndex.Content + 1,
        Parent = self.ContentContainer,
    })
    
    -- Two column layout
    local leftColumn = Utility.Create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.49, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 2,
        Parent = scrollFrame,
    })
    
    local rightColumn = Utility.Create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.49, 0, 1, 0),
        Position = UDim2.new(0.51, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 2,
        Parent = scrollFrame,
    })
    
    Utility.AddListLayout(leftColumn, CONFIG.Spacing.Large)
    Utility.AddListLayout(rightColumn, CONFIG.Spacing.Large)
    
    tab.Button = button
    tab.Content = scrollFrame
    tab.LeftColumn = leftColumn
    tab.RightColumn = rightColumn
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        if not tab.Active then
            Utility.Tween(button, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not tab.Active then
            Utility.Tween(button, {BackgroundColor3 = CONFIG.Colors.Sidebar}, CONFIG.Animation.Fast)
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Update all tab widths
    for i, t in ipairs(self.Tabs) do
        local newWidth = 650 / #self.Tabs
        Utility.Tween(t.Button, {Size = UDim2.new(0, newWidth, 1, 0)}, CONFIG.Animation.Normal)
    end
    
    return tab
end

function PepsiUI:SelectTab(tab)
    -- Deselect all tabs
    for _, t in ipairs(self.Tabs) do
        t.Active = false
        t.Content.Visible = false
        
        Utility.Tween(t.Button, {
            BackgroundColor3 = CONFIG.Colors.Sidebar
        }, CONFIG.Animation.Fast)
        
        if t.TextLabel then
            Utility.Tween(t.TextLabel, {TextColor3 = CONFIG.Colors.TextDark}, CONFIG.Animation.Fast)
        end
        if t.IconLabel then
            Utility.Tween(t.IconLabel, {TextColor3 = CONFIG.Colors.TextDark}, CONFIG.Animation.Fast)
        end
    end
    
    -- Select new tab
    tab.Active = true
    tab.Content.Visible = true
    self.ActiveTab = tab
    
    Utility.Tween(tab.Button, {
        BackgroundColor3 = CONFIG.Colors.Active
    }, CONFIG.Animation.Normal)
    
    if tab.TextLabel then
        Utility.Tween(tab.TextLabel, {TextColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Normal)
    end
    if tab.IconLabel then
        Utility.Tween(tab.IconLabel, {TextColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Normal)
    end
    
    -- Animate indicator
    local buttonPos = tab.Button.AbsolutePosition.X - self.TabsContainer.AbsolutePosition.X
    local buttonWidth = tab.Button.AbsoluteSize.X
    
    Utility.Tween(self.TabIndicator, {
        Position = UDim2.new(0, buttonPos, 1, -2),
        Size = UDim2.new(0, buttonWidth, 0, 2)
    }, CONFIG.Animation.Normal, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

-- ============================================
-- SECTION SYSTEM
-- ============================================
function PepsiUI:AddSection(tab, name, side)
    side = side or "left"
    
    local section = {
        Name = name,
        Side = side,
        Elements = {},
    }
    
    local parentColumn = side == "left" and tab.LeftColumn or tab.RightColumn
    
    local container = Utility.Create("Frame", {
        Name = "Section_" .. name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = CONFIG.Colors.Sidebar,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 3,
        Parent = parentColumn,
    })
    
    Utility.AddCorner(container, CONFIG.CornerRadius.Medium)
    Utility.AddStroke(container, CONFIG.Colors.Border, 1)
    Utility.AddPadding(container, CONFIG.Spacing.Medium)
    Utility.AddListLayout(container, CONFIG.Spacing.Small)
    
    -- Section Title
    local title = Utility.Create("TextLabel", {
        Name = "SectionTitle",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Bold,
        TextSize = CONFIG.FontSizes.Medium,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 4,
        Parent = container,
    })
    
    -- Separator line
    local separator = Utility.Create("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = CONFIG.Colors.Border,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 4,
        Parent = container,
    })
    
    section.Container = container
    section.Title = title
    
    table.insert(tab.Sections, section)
    
    -- Update canvas size
    task.spawn(function()
        while container and container.Parent do
            task.wait(0.1)
            local leftHeight = tab.LeftColumn.UIListLayout.AbsoluteContentSize.Y
            local rightHeight = tab.RightColumn.UIListLayout.AbsoluteContentSize.Y
            local maxHeight = math.max(leftHeight, rightHeight)
            tab.Content.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 16)
        end
    end)
    
    return section
end

-- ============================================
-- TOGGLE COMPONENT
-- ============================================
function PepsiUI:AddToggle(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local toggle = {
        Name = name,
        Value = default,
        Callback = callback,
        Type = "Toggle",
    }
    
    local container = Utility.Create("Frame", {
        Name = "Toggle_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ComponentHeight),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    -- Checkbox background
    local checkboxBg = Utility.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(checkboxBg, CONFIG.CornerRadius.Small)
    Utility.AddStroke(checkboxBg, CONFIG.Colors.Border, 1)
    
    -- Checkmark
    local checkmark = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Bold,
        TextSize = 11,
        TextColor3 = CONFIG.Colors.Accent,
        Text = "✓",
        Visible = default,
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = checkboxBg,
    })
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Click detector
    local button = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = CONFIG.ZIndex.Content + 8,
        Parent = container,
    })
    
    function toggle:Set(value)
        self.Value = value
        checkmark.Visible = value
        
        if value then
            Utility.Tween(checkboxBg, {BackgroundColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
            Utility.Tween(checkmark, {TextColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Fast)
        else
            Utility.Tween(checkboxBg, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        end
        
        self.Callback(value)
    end
    
    button.MouseButton1Click:Connect(function()
        toggle:Set(not toggle.Value)
    end)
    
    button.MouseEnter:Connect(function()
        Utility.Tween(label, {TextColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
    end)
    
    button.MouseLeave:Connect(function()
        Utility.Tween(label, {TextColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Fast)
    end)
    
    toggle.Container = container
    toggle.Label = label
    toggle.Checkmark = checkmark
    
    table.insert(section.Elements, toggle)
    return toggle
end

-- ============================================
-- SLIDER COMPONENT
-- ============================================
function PepsiUI:AddSlider(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local suffix = config.Suffix or ""
    local callback = config.Callback or function() end
    
    local slider = {
        Name = name,
        Min = min,
        Max = max,
        Value = default,
        Increment = increment,
        Suffix = suffix,
        Callback = callback,
        Type = "Slider",
        Dragging = false,
    }
    
    local container = Utility.Create("Frame", {
        Name = "Slider_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.SliderHeight),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Value display
    local valueLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 14),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = tostring(default) .. suffix,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Slider bar background
    local barBg = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(barBg, CONFIG.CornerRadius.Small)
    Utility.AddStroke(barBg, CONFIG.Colors.Border, 1)
    
    -- Fill
    local fill = Utility.Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = CONFIG.Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = barBg,
    })
    
    Utility.AddCorner(fill, CONFIG.CornerRadius.Small)
    
    -- Handle
    local handle = Utility.Create("Frame", {
        Size = UDim2.new(0, 10, 0, 13),
        Position = UDim2.new((default - min) / (max - min), -5, 0.5, -6.5),
        BackgroundColor3 = CONFIG.Colors.Text,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 8,
        Parent = barBg,
    })
    
    Utility.AddCorner(handle, CONFIG.CornerRadius.Small)
    Utility.AddStroke(handle, CONFIG.Colors.Border, 1)
    
    function slider:Set(value)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor((value / self.Increment) + 0.5) * self.Increment
        self.Value = value
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        
        local tweenDuration = self.Dragging and 0 or CONFIG.Animation.Fast
        Utility.Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, tweenDuration)
        Utility.Tween(handle, {Position = UDim2.new(percent, -5, 0.5, -6.5)}, tweenDuration)
        
        valueLabel.Text = tostring(value) .. self.Suffix
        self.Callback(value)
    end
    
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slider.Dragging = true
            Utility.Tween(handle, {Size = UDim2.new(0, 12, 0, 15)}, CONFIG.Animation.Fast)
        end
    end)
    
    barBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slider.Dragging = false
            Utility.Tween(handle, {Size = UDim2.new(0, 10, 0, 13)}, CONFIG.Animation.Fast)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = barBg.AbsolutePosition
            local size = barBg.AbsoluteSize
            local mouse = UserInputService:GetMouseLocation()
            
            local relX = math.clamp(mouse.X - pos.X, 0, size.X)
            local percent = relX / size.X
            local value = slider.Min + (slider.Max - slider.Min) * percent
            
            slider:Set(value)
        end
    end)
    
    handle.MouseEnter:Connect(function()
        if not slider.Dragging then
            Utility.Tween(handle, {BackgroundColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
        end
    end)
    
    handle.MouseLeave:Connect(function()
        if not slider.Dragging then
            Utility.Tween(handle, {BackgroundColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Fast)
        end
    end)
    
    slider.Container = container
    slider.Label = label
    slider.ValueLabel = valueLabel
    
    table.insert(section.Elements, slider)
    return slider
end

-- ============================================
-- DROPDOWN COMPONENT (HIGH Z-INDEX)
-- ============================================
function PepsiUI:AddDropdown(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local default = config.Default or options[1]
    local callback = config.Callback or function() end
    
    local dropdown = {
        Name = name,
        Options = options,
        Value = default,
        Callback = callback,
        Type = "Dropdown",
        Open = false,
    }
    
    local container = Utility.Create("Frame", {
        Name = "Dropdown_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.DropdownHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Button
    local button = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(button, CONFIG.CornerRadius.Small)
    Utility.AddStroke(button, CONFIG.Colors.Border, 1)
    Utility.AddPadding(button, CONFIG.Spacing.Small)
    
    local buttonText = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = default,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = button,
    })
    
    -- Arrow
    local arrow = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = "▼",
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = button,
    })
    
    -- Options frame (CRITICAL: HIGH Z-INDEX!)
    local optionsFrame = Utility.Create("Frame", {
        Name = "OptionsFrame",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 34),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = CONFIG.ZIndex.Dropdown, -- 1500! ALWAYS ON TOP
        Parent = container,
    })
    
    Utility.AddCorner(optionsFrame, CONFIG.CornerRadius.Small)
    Utility.AddStroke(optionsFrame, CONFIG.Colors.Accent, 1)
    
    local optionsList = Utility.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.Colors.Border,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = optionsFrame,
    })
    
    Utility.AddListLayout(optionsList, 1)
    
    function dropdown:Refresh(newOptions)
        self.Options = newOptions or self.Options
        
        -- Clear existing
        for _, child in ipairs(optionsList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Create new options
        for i, opt in ipairs(self.Options) do
            local optButton = Utility.Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = CONFIG.Colors.Sidebar,
                BorderSizePixel = 0,
                Font = CONFIG.Fonts.Main,
                TextSize = CONFIG.FontSizes.Small,
                TextColor3 = CONFIG.Colors.Text,
                Text = "",
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = CONFIG.ZIndex.Dropdown + 2,
                Parent = optionsList,
            })
            
            Utility.AddPadding(optButton, CONFIG.Spacing.Small)
            
            local optText = Utility.Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = CONFIG.Fonts.Main,
                TextSize = CONFIG.FontSizes.Small,
                TextColor3 = CONFIG.Colors.Text,
                Text = opt,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = CONFIG.ZIndex.Dropdown + 3,
                Parent = optButton,
            })
            
            optButton.MouseEnter:Connect(function()
                Utility.Tween(optButton, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
                Utility.Tween(optText, {TextColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
            end)
            
            optButton.MouseLeave:Connect(function()
                Utility.Tween(optButton, {BackgroundColor3 = CONFIG.Colors.Sidebar}, CONFIG.Animation.Fast)
                Utility.Tween(optText, {TextColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Fast)
            end)
            
            optButton.MouseButton1Click:Connect(function()
                dropdown:Set(opt)
                dropdown:Close()
            end)
        end
        
        optionsList.CanvasSize = UDim2.new(0, 0, 0, #self.Options * 23)
    end
    
    function dropdown:Set(value)
        self.Value = value
        buttonText.Text = value
        self.Callback(value)
    end
    
    function dropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            table.insert(PepsiUI.ActiveDropdowns, self)
            
            local height = math.min(#self.Options * 23, 110)
            optionsFrame.Visible = true
            
            Utility.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, height)}, CONFIG.Animation.Normal)
            Utility.Tween(arrow, {Rotation = 180}, CONFIG.Animation.Normal)
            Utility.Tween(button, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        else
            self:Close()
        end
    end
    
    function dropdown:Close()
        if not self.Open then return end
        self.Open = false
        
        Utility.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, CONFIG.Animation.Normal)
        Utility.Tween(arrow, {Rotation = 0}, CONFIG.Animation.Normal)
        Utility.Tween(button, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        
        task.wait(CONFIG.Animation.Normal)
        optionsFrame.Visible = false
        
        -- Remove from active list
        for i, dd in ipairs(PepsiUI.ActiveDropdowns) do
            if dd == self then
                table.remove(PepsiUI.ActiveDropdowns, i)
                break
            end
        end
    end
    
    button.MouseButton1Click:Connect(function()
        dropdown:Toggle()
    end)
    
    button.MouseEnter:Connect(function()
        if not dropdown.Open then
            Utility.Tween(button, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not dropdown.Open then
            Utility.Tween(button, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        end
    end)
    
    dropdown:Refresh()
    dropdown.Container = container
    dropdown.Button = button
    dropdown.ButtonText = buttonText
    
    table.insert(section.Elements, dropdown)
    return dropdown
end

-- ============================================
-- KEYBIND COMPONENT
-- ============================================
function PepsiUI:AddKeybind(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.E
    local callback = config.Callback or function() end
    
    local keybind = {
        Name = name,
        Key = default,
        Callback = callback,
        Type = "Keybind",
        Listening = false,
        Enabled = false,
    }
    
    local container = Utility.Create("Frame", {
        Name = "Keybind_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ComponentHeight),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Key button
    local keyButton = Utility.Create("TextButton", {
        Size = UDim2.new(0.38, 0, 0, 16),
        Position = UDim2.new(0.62, 0, 0, 1),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = "[" .. default.Name .. "]",
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(keyButton, CONFIG.CornerRadius.Small)
    Utility.AddStroke(keyButton, CONFIG.Colors.Border, 1)
    
    function keybind:Set(key)
        self.Key = key
        keyButton.Text = "[" .. key.Name .. "]"
        self.Listening = false
        
        Utility.Tween(keyButton, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        Utility.Tween(keyButton, {TextColor3 = CONFIG.Colors.TextDark}, CONFIG.Animation.Fast)
        
        -- Update keybinds panel
        PepsiUI:AddKeybindDisplay(self.Name, key.Name, self.Enabled)
    end
    
    keyButton.MouseButton1Click:Connect(function()
        keybind.Listening = true
        keyButton.Text = "..."
        Utility.Tween(keyButton, {BackgroundColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
        Utility.Tween(keyButton, {TextColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Fast)
    end)
    
    keyButton.MouseEnter:Connect(function()
        if not keybind.Listening then
            Utility.Tween(keyButton, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        end
    end)
    
    keyButton.MouseLeave:Connect(function()
        if not keybind.Listening then
            Utility.Tween(keyButton, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybind:Set(input.KeyCode)
        end
        
        if not processed and input.KeyCode == keybind.Key then
            keybind.Enabled = not keybind.Enabled
            keybind.Callback(keybind.Key, keybind.Enabled)
            PepsiUI:AddKeybindDisplay(keybind.Name, keybind.Key.Name, keybind.Enabled)
        end
    end)
    
    keybind.Container = container
    keybind.Label = label
    keybind.Button = keyButton
    
    table.insert(section.Elements, keybind)
    return keybind
end

-- ============================================
-- TEXTBOX COMPONENT
-- ============================================
function PepsiUI:AddTextbox(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Textbox"
    local default = config.Default or ""
    local placeholder = config.Placeholder or "Enter text..."
    local callback = config.Callback or function() end
    
    local textbox = {
        Name = name,
        Value = default,
        Placeholder = placeholder,
        Callback = callback,
        Type = "Textbox",
    }
    
    local container = Utility.Create("Frame", {
        Name = "Textbox_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.DropdownHeight),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Input box
    local inputBox = Utility.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        PlaceholderText = placeholder,
        PlaceholderColor3 = CONFIG.Colors.TextDimmed,
        Text = default,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(inputBox, CONFIG.CornerRadius.Small)
    Utility.AddStroke(inputBox, CONFIG.Colors.Border, 1)
    Utility.AddPadding(inputBox, CONFIG.Spacing.Small)
    
    function textbox:Set(value)
        self.Value = value
        inputBox.Text = value
        self.Callback(value)
    end
    
    inputBox.Focused:Connect(function()
        Utility.Tween(inputBox, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        local stroke = inputBox:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utility.Tween(stroke, {Color = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
        end
    end)
    
    inputBox.FocusLost:Connect(function()
        Utility.Tween(inputBox, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        local stroke = inputBox:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utility.Tween(stroke, {Color = CONFIG.Colors.Border}, CONFIG.Animation.Fast)
        end
        
        textbox.Value = inputBox.Text
        textbox.Callback(inputBox.Text)
    end)
    
    textbox.Container = container
    textbox.InputBox = inputBox
    
    table.insert(section.Elements, textbox)
    return textbox
end

-- ============================================
-- LABEL COMPONENT
-- ============================================
function PepsiUI:AddLabel(section, config)
    config = config or {}
    local text = config.Text or "Label"
    
    local label = {
        Text = text,
        Type = "Label",
    }
    
    local textLabel = Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    function label:Set(newText)
        self.Text = newText
        textLabel.Text = newText
    end
    
    label.Label = textLabel
    table.insert(section.Elements, label)
    return label
end

-- ============================================
-- DIVIDER COMPONENT
-- ============================================
function PepsiUI:AddDivider(section)
    local divider = Utility.Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = CONFIG.Colors.Border,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    return divider
end

-- ============================================
-- COLOR PICKER COMPONENT (HIGH Z-INDEX)
-- ============================================
function PepsiUI:AddColorPicker(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Color Picker"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local callback = config.Callback or function() end
    
    local colorPicker = {
        Name = name,
        Value = default,
        Callback = callback,
        Type = "ColorPicker",
        Open = false,
        H = 0,
        S = 1,
        V = 1,
    }
    
    -- Convert default color to HSV
    colorPicker.H, colorPicker.S, colorPicker.V = default:ToHSV()
    
    local container = Utility.Create("Frame", {
        Name = "ColorPicker_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.ComponentHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    -- Label
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    -- Color preview button
    local previewButton = Utility.Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 16),
        Position = UDim2.new(1, -30, 0, 1),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(previewButton, CONFIG.CornerRadius.Small)
    Utility.AddStroke(previewButton, CONFIG.Colors.Border, 1)
    
    -- Picker frame (CRITICAL: HIGH Z-INDEX!)
    local pickerFrame = Utility.Create("Frame", {
        Name = "PickerFrame",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = CONFIG.ZIndex.Dropdown, -- 1500! ALWAYS ON TOP
        Parent = container,
    })
    
    Utility.AddCorner(pickerFrame, CONFIG.CornerRadius.Medium)
    Utility.AddStroke(pickerFrame, CONFIG.Colors.Accent, 2)
    
    -- SV Picker Canvas
    local svCanvas = Utility.Create("ImageButton", {
        Name = "SVCanvas",
        Size = UDim2.new(1, -14, 0, 150),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = Color3.fromHSV(colorPicker.H, 1, 1),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = pickerFrame,
    })
    
    Utility.AddCorner(svCanvas, CONFIG.CornerRadius.Small)
    
    -- Saturation gradient
    local satGradient = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 2,
        Parent = svCanvas,
    })
    
    Utility.AddCorner(satGradient, CONFIG.CornerRadius.Small)
    
    local satGrad = Utility.Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Rotation = 0,
        Parent = satGradient,
    })
    
    -- Value gradient
    local valGradient = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 3,
        Parent = svCanvas,
    })
    
    Utility.AddCorner(valGradient, CONFIG.CornerRadius.Small)
    
    local valGrad = Utility.Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90,
        Parent = valGradient,
    })
    
    -- Cursor
    local cursor = Utility.Create("Frame", {
        Name = "Cursor",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(colorPicker.S, -7, 1 - colorPicker.V, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 4,
        Parent = svCanvas,
    })
    
    Utility.AddCorner(cursor, CONFIG.CornerRadius.Full)
    Utility.AddStroke(cursor, Color3.fromRGB(0, 0, 0), 2)
    
    -- Hue slider
    local hueSlider = Utility.Create("Frame", {
        Name = "HueSlider",
        Size = UDim2.new(1, -14, 0, 18),
        Position = UDim2.new(0, 7, 0, 164),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = pickerFrame,
    })
    
    Utility.AddCorner(hueSlider, CONFIG.CornerRadius.Small)
    
    local hueGrad = Utility.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueSlider,
    })
    
    -- RGB Display
    local rgbDisplay = Utility.Create("TextLabel", {
        Name = "RGBDisplay",
        Size = UDim2.new(1, -14, 0, 16),
        Position = UDim2.new(0, 7, 0, 189),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Tiny,
        TextColor3 = CONFIG.Colors.Text,
        Text = "RGB: 255, 255, 255",
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = pickerFrame,
    })
    
    Utility.AddCorner(rgbDisplay, CONFIG.CornerRadius.Small)
    
    -- HEX Display
    local hexDisplay = Utility.Create("TextLabel", {
        Name = "HEXDisplay",
        Size = UDim2.new(1, -14, 0, 16),
        Position = UDim2.new(0, 7, 0, 212),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Mono,
        TextSize = CONFIG.FontSizes.Tiny,
        TextColor3 = CONFIG.Colors.Text,
        Text = "HEX: #FFFFFF",
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = pickerFrame,
    })
    
    Utility.AddCorner(hexDisplay, CONFIG.CornerRadius.Small)
    
    local draggingSV = false
    local draggingHue = false
    
    local function updateColor()
        local color = Color3.fromHSV(colorPicker.H, colorPicker.S, colorPicker.V)
        colorPicker.Value = color
        previewButton.BackgroundColor3 = color
        
        svCanvas.BackgroundColor3 = Color3.fromHSV(colorPicker.H, 1, 1)
        
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        
        rgbDisplay.Text = string.format("RGB: %d, %d, %d", r, g, b)
        hexDisplay.Text = "HEX: " .. Utility.RGBToHex(color)
        
        colorPicker.Callback(color)
    end
    
    svCanvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = true
        end
    end)
    
    svCanvas.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = false
        end
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
        end
    end)
    
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingSV then
                local pos = svCanvas.AbsolutePosition
                local size = svCanvas.AbsoluteSize
                local mouse = UserInputService:GetMouseLocation()
                
                local relX = math.clamp(mouse.X - pos.X, 0, size.X)
                local relY = math.clamp(mouse.Y - pos.Y, 0, size.Y)
                
                colorPicker.S = relX / size.X
                colorPicker.V = 1 - (relY / size.Y)
                
                cursor.Position = UDim2.new(colorPicker.S, -7, 1 - colorPicker.V, -7)
                updateColor()
            end
            
            if draggingHue then
                local pos = hueSlider.AbsolutePosition
                local size = hueSlider.AbsoluteSize
                local mouse = UserInputService:GetMouseLocation()
                
                local relX = math.clamp(mouse.X - pos.X, 0, size.X)
                colorPicker.H = relX / size.X
                
                updateColor()
            end
        end
    end)
    
    function colorPicker:Set(color)
        self.Value = color
        self.H, self.S, self.V = color:ToHSV()
        
        previewButton.BackgroundColor3 = color
        cursor.Position = UDim2.new(self.S, -7, 1 - self.V, -7)
        
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        
        rgbDisplay.Text = string.format("RGB: %d, %d, %d", r, g, b)
        hexDisplay.Text = "HEX: " .. Utility.RGBToHex(color)
    end
    
    function colorPicker:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            table.insert(PepsiUI.ActiveDropdowns, self)
            
            pickerFrame.Visible = true
            Utility.Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 235)}, CONFIG.Animation.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self:Close()
        end
    end
    
    function colorPicker:Close()
        if not self.Open then return end
        self.Open = false
        
        Utility.Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 0)}, CONFIG.Animation.Normal)
        task.wait(CONFIG.Animation.Normal)
        pickerFrame.Visible = false
        
        for i, cp in ipairs(PepsiUI.ActiveDropdowns) do
            if cp == self then
                table.remove(PepsiUI.ActiveDropdowns, i)
                break
            end
        end
    end
    
    previewButton.MouseButton1Click:Connect(function()
        colorPicker:Toggle()
    end)
    
    previewButton.MouseEnter:Connect(function()
        local stroke = previewButton:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utility.Tween(stroke, {Color = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
        end
    end)
    
    previewButton.MouseLeave:Connect(function()
        local stroke = previewButton:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utility.Tween(stroke, {Color = CONFIG.Colors.Border}, CONFIG.Animation.Fast)
        end
    end)
    
    updateColor()
    
    colorPicker.Container = container
    colorPicker.PreviewButton = previewButton
    
    table.insert(section.Elements, colorPicker)
    return colorPicker
end

-- ============================================
-- INPUT HANDLERS
-- ============================================
function PepsiUI:SetupInputHandlers()
    -- Close dropdowns on click outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, dropdown in ipairs(self.ActiveDropdowns) do
                if dropdown and dropdown.Close then
                    dropdown:Close()
                end
            end
            self.ActiveDropdowns = {}
        end
    end)
end

-- ============================================
-- BUTTON COMPONENT
-- ============================================
function PepsiUI:AddButton(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Button"
    local callback = config.Callback or function() end
    
    local button = {
        Name = name,
        Callback = callback,
        Type = "Button",
    }
    
    local container = Utility.Create("TextButton", {
        Name = "Button_" .. name,
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    Utility.AddCorner(container, CONFIG.CornerRadius.Small)
    Utility.AddStroke(container, CONFIG.Colors.Border, 1)
    
    container.MouseEnter:Connect(function()
        Utility.Tween(container, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        Utility.Tween(container, {TextColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
    end)
    
    container.MouseLeave:Connect(function()
        Utility.Tween(container, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        Utility.Tween(container, {TextColor3 = CONFIG.Colors.Text}, CONFIG.Animation.Fast)
    end)
    
    container.MouseButton1Click:Connect(function()
        Utility.Tween(container, {Size = UDim2.new(1, 0, 0, 20)}, 0.05)
        task.wait(0.05)
        Utility.Tween(container, {Size = UDim2.new(1, 0, 0, 22)}, 0.05)
        button.Callback()
    end)
    
    button.Container = container
    table.insert(section.Elements, button)
    return button
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
function PepsiUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local text = config.Text or config.Message or ""
    local duration = config.Duration or 3
    local type_ = config.Type or "info" -- info, success, warning, error
    
    -- Create notification container if it doesn't exist
    if not self.NotificationContainer then
        self.NotificationContainer = Utility.Create("Frame", {
            Name = "NotificationContainer",
            Size = UDim2.new(0, 280, 1, 0),
            Position = UDim2.new(1, -290, 0, 10),
            BackgroundTransparency = 1,
            ZIndex = CONFIG.ZIndex.Overlay + 100,
            Parent = self.ScreenGui,
        })
        
        Utility.AddListLayout(self.NotificationContainer, CONFIG.Spacing.Medium)
    end
    
    local typeColors = {
        info = CONFIG.Colors.Info,
        success = CONFIG.Colors.Success,
        warning = CONFIG.Colors.Warning,
        error = CONFIG.Colors.Error,
    }
    
    local accentColor = typeColors[type_] or CONFIG.Colors.Accent
    
    local notification = Utility.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay + 101,
        Parent = self.NotificationContainer,
    })
    
    Utility.AddCorner(notification, CONFIG.CornerRadius.Medium)
    Utility.AddStroke(notification, CONFIG.Colors.Border, 1)
    
    -- Accent line
    local accentLine = Utility.Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay + 102,
        Parent = notification,
    })
    
    Utility.AddCorner(accentLine, CONFIG.CornerRadius.Small)
    
    -- Content
    local content = Utility.Create("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Overlay + 102,
        Parent = notification,
    })
    
    Utility.AddPadding(content, CONFIG.Spacing.Small)
    
    local titleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Bold,
        TextSize = CONFIG.FontSizes.Medium,
        TextColor3 = CONFIG.Colors.Text,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Overlay + 103,
        Parent = content,
    })
    
    local textLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = CONFIG.ZIndex.Overlay + 103,
        Parent = content,
    })
    
    -- Progress bar
    local progressBar = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Overlay + 103,
        Parent = notification,
    })
    
    -- Animate in
    notification.Position = UDim2.new(1, 50, 0, 0)
    notification.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    textLabel.TextTransparency = 1
    
    Utility.Tween(notification, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, CONFIG.Animation.Normal)
    Utility.Tween(titleLabel, {TextTransparency = 0}, CONFIG.Animation.Normal)
    Utility.Tween(textLabel, {TextTransparency = 0}, CONFIG.Animation.Normal)
    
    -- Progress animation
    Utility.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    
    -- Auto remove
    task.delay(duration, function()
        Utility.Tween(notification, {
            Position = UDim2.new(1, 50, 0, 0),
            BackgroundTransparency = 1
        }, CONFIG.Animation.Normal)
        Utility.Tween(titleLabel, {TextTransparency = 1}, CONFIG.Animation.Normal)
        Utility.Tween(textLabel, {TextTransparency = 1}, CONFIG.Animation.Normal)
        
        task.wait(CONFIG.Animation.Normal)
        notification:Destroy()
    end)
    
    table.insert(self.Notifications, notification)
    return notification
end

-- ============================================
-- UPDATE LOOP
-- ============================================
function PepsiUI:StartUpdateLoop()
    task.spawn(function()
        while self.ScreenGui and self.ScreenGui.Parent do
            task.wait(1)
            pcall(function()
                self:UpdateWatermark()
            end)
        end
    end)
end

-- ============================================
-- MULTI-DROPDOWN COMPONENT
-- ============================================
function PepsiUI:AddMultiDropdown(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Multi Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local default = config.Default or {}
    local callback = config.Callback or function() end
    
    local multiDropdown = {
        Name = name,
        Options = options,
        Selected = {},
        Callback = callback,
        Type = "MultiDropdown",
        Open = false,
    }
    
    -- Set defaults
    for _, opt in ipairs(default) do
        multiDropdown.Selected[opt] = true
    end
    
    local container = Utility.Create("Frame", {
        Name = "MultiDropdown_" .. name,
        Size = UDim2.new(1, 0, 0, CONFIG.Sizes.DropdownHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    local button = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(button, CONFIG.CornerRadius.Small)
    Utility.AddStroke(button, CONFIG.Colors.Border, 1)
    Utility.AddPadding(button, CONFIG.Spacing.Small)
    
    local function updateButtonText()
        local selectedList = {}
        for opt, _ in pairs(multiDropdown.Selected) do
            table.insert(selectedList, opt)
        end
        
        if #selectedList == 0 then
            button.Text = "None selected"
        elseif #selectedList == 1 then
            button.Text = selectedList[1]
        else
            button.Text = #selectedList .. " selected"
        end
    end
    
    updateButtonText()
    
    local arrow = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDark,
        Text = "▼",
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = button,
    })
    
    local optionsFrame = Utility.Create("Frame", {
        Name = "OptionsFrame",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 34),
        BackgroundColor3 = CONFIG.Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = CONFIG.ZIndex.Dropdown,
        Parent = container,
    })
    
    Utility.AddCorner(optionsFrame, CONFIG.CornerRadius.Small)
    Utility.AddStroke(optionsFrame, CONFIG.Colors.Accent, 1)
    
    local optionsList = Utility.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.Colors.Border,
        ZIndex = CONFIG.ZIndex.Dropdown + 1,
        Parent = optionsFrame,
    })
    
    Utility.AddListLayout(optionsList, 1)
    
    function multiDropdown:Refresh(newOptions)
        self.Options = newOptions or self.Options
        
        for _, child in ipairs(optionsList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for i, opt in ipairs(self.Options) do
            local optContainer = Utility.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = CONFIG.Colors.Sidebar,
                BorderSizePixel = 0,
                ZIndex = CONFIG.ZIndex.Dropdown + 2,
                Parent = optionsList,
            })
            
            local checkbox = Utility.Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 5, 0.5, -6),
                BackgroundColor3 = CONFIG.Colors.BackgroundLight,
                BorderSizePixel = 0,
                ZIndex = CONFIG.ZIndex.Dropdown + 3,
                Parent = optContainer,
            })
            
            Utility.AddCorner(checkbox, CONFIG.CornerRadius.Small)
            Utility.AddStroke(checkbox, CONFIG.Colors.Border, 1)
            
            local checkmark = Utility.Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = CONFIG.Fonts.Bold,
                TextSize = 10,
                TextColor3 = CONFIG.Colors.Accent,
                Text = "✓",
                Visible = multiDropdown.Selected[opt] or false,
                ZIndex = CONFIG.ZIndex.Dropdown + 4,
                Parent = checkbox,
            })
            
            local optText = Utility.Create("TextLabel", {
                Size = UDim2.new(1, -25, 1, 0),
                Position = UDim2.new(0, 22, 0, 0),
                BackgroundTransparency = 1,
                Font = CONFIG.Fonts.Main,
                TextSize = CONFIG.FontSizes.Small,
                TextColor3 = CONFIG.Colors.Text,
                Text = opt,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = CONFIG.ZIndex.Dropdown + 3,
                Parent = optContainer,
            })
            
            local optButton = Utility.Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = CONFIG.ZIndex.Dropdown + 5,
                Parent = optContainer,
            })
            
            optButton.MouseEnter:Connect(function()
                Utility.Tween(optContainer, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
            end)
            
            optButton.MouseLeave:Connect(function()
                Utility.Tween(optContainer, {BackgroundColor3 = CONFIG.Colors.Sidebar}, CONFIG.Animation.Fast)
            end)
            
            optButton.MouseButton1Click:Connect(function()
                multiDropdown.Selected[opt] = not multiDropdown.Selected[opt]
                checkmark.Visible = multiDropdown.Selected[opt]
                
                if multiDropdown.Selected[opt] then
                    Utility.Tween(checkbox, {BackgroundColor3 = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
                else
                    Utility.Tween(checkbox, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
                end
                
                updateButtonText()
                multiDropdown.Callback(multiDropdown:GetSelected())
            end)
        end
        
        optionsList.CanvasSize = UDim2.new(0, 0, 0, #self.Options * 23)
    end
    
    function multiDropdown:GetSelected()
        local selected = {}
        for opt, _ in pairs(self.Selected) do
            table.insert(selected, opt)
        end
        return selected
    end
    
    function multiDropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            table.insert(PepsiUI.ActiveDropdowns, self)
            
            local height = math.min(#self.Options * 23, 110)
            optionsFrame.Visible = true
            
            Utility.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, height)}, CONFIG.Animation.Normal)
            Utility.Tween(arrow, {Rotation = 180}, CONFIG.Animation.Normal)
        else
            self:Close()
        end
    end
    
    function multiDropdown:Close()
        if not self.Open then return end
        self.Open = false
        
        Utility.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, CONFIG.Animation.Normal)
        Utility.Tween(arrow, {Rotation = 0}, CONFIG.Animation.Normal)
        task.wait(CONFIG.Animation.Normal)
        optionsFrame.Visible = false
        
        for i, dd in ipairs(PepsiUI.ActiveDropdowns) do
            if dd == self then
                table.remove(PepsiUI.ActiveDropdowns, i)
                break
            end
        end
    end
    
    button.MouseButton1Click:Connect(function()
        multiDropdown:Toggle()
    end)
    
    multiDropdown:Refresh()
    multiDropdown.Container = container
    
    table.insert(section.Elements, multiDropdown)
    return multiDropdown
end

-- ============================================
-- BOX COMPONENT
-- ============================================
function PepsiUI:AddBox(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Box"
    
    local box = {
        Name = name,
        Type = "Box",
    }
    
    local container = Utility.Create("Frame", {
        Name = "Box_" .. name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    Utility.AddCorner(container, CONFIG.CornerRadius.Medium)
    Utility.AddStroke(container, CONFIG.Colors.Border, 1)
    Utility.AddPadding(container, CONFIG.Spacing.Medium)
    Utility.AddListLayout(container, CONFIG.Spacing.Small)
    
    local title = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Bold,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    box.Container = container
    box.Title = title
    
    function box:AddElement(elementFunc, ...)
        return elementFunc(self, ...)
    end
    
    table.insert(section.Elements, box)
    return box
end

-- ============================================
-- SEARCH BOX COMPONENT
-- ============================================
function PepsiUI:AddSearchBox(section, config)
    config = config or {}
    local name = config.Name or config.Text or "Search"
    local placeholder = config.Placeholder or "Search..."
    local callback = config.Callback or function() end
    
    local searchBox = {
        Name = name,
        Value = "",
        Placeholder = placeholder,
        Callback = callback,
        Type = "SearchBox",
    }
    
    local container = Utility.Create("Frame", {
        Name = "SearchBox_" .. name,
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    local searchFrame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(searchFrame, CONFIG.CornerRadius.Small)
    Utility.AddStroke(searchFrame, CONFIG.Colors.Border, 1)
    
    local searchIcon = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.TextDimmed,
        Text = "🔍",
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = searchFrame,
    })
    
    local inputBox = Utility.Create("TextBox", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 25, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        PlaceholderText = placeholder,
        PlaceholderColor3 = CONFIG.Colors.TextDimmed,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = CONFIG.ZIndex.Content + 7,
        Parent = searchFrame,
    })
    
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchBox.Value = inputBox.Text
        searchBox.Callback(inputBox.Text)
    end)
    
    inputBox.Focused:Connect(function()
        Utility.Tween(searchFrame, {BackgroundColor3 = CONFIG.Colors.Hover}, CONFIG.Animation.Fast)
        local stroke = searchFrame:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utility.Tween(stroke, {Color = CONFIG.Colors.Accent}, CONFIG.Animation.Fast)
        end
    end)
    
    inputBox.FocusLost:Connect(function()
        Utility.Tween(searchFrame, {BackgroundColor3 = CONFIG.Colors.BackgroundLight}, CONFIG.Animation.Fast)
        local stroke = searchFrame:FindFirstChildOfClass("UIStroke")
        if stroke then
            Utility.Tween(stroke, {Color = CONFIG.Colors.Border}, CONFIG.Animation.Fast)
        end
    end)
    
    searchBox.Container = container
    searchBox.InputBox = inputBox
    
    table.insert(section.Elements, searchBox)
    return searchBox
end

-- ============================================
-- INFO BOX COMPONENT
-- ============================================
function PepsiUI:AddInfoBox(section, config)
    config = config or {}
    local text = config.Text or "Information"
    local type_ = config.Type or "info" -- info, success, warning, error
    
    local typeColors = {
        info = CONFIG.Colors.Info,
        success = CONFIG.Colors.Success,
        warning = CONFIG.Colors.Warning,
        error = CONFIG.Colors.Error,
    }
    
    local accentColor = typeColors[type_] or CONFIG.Colors.Accent
    
    local infoBox = {
        Text = text,
        Type = type_,
        AccentColor = accentColor,
    }
    
    local container = Utility.Create("Frame", {
        Name = "InfoBox",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = CONFIG.Colors.BackgroundLight,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    Utility.AddCorner(container, CONFIG.CornerRadius.Small)
    Utility.AddStroke(container, accentColor, 1)
    
    local accentBar = Utility.Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddCorner(accentBar, CONFIG.CornerRadius.Small)
    
    local textLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -15, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = CONFIG.Fonts.Main,
        TextSize = CONFIG.FontSizes.Small,
        TextColor3 = CONFIG.Colors.Text,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        ZIndex = CONFIG.ZIndex.Content + 6,
        Parent = container,
    })
    
    Utility.AddPadding(textLabel, CONFIG.Spacing.Small)
    
    function infoBox:Set(newText)
        self.Text = newText
        textLabel.Text = newText
    end
    
    infoBox.Container = container
    infoBox.Label = textLabel
    
    table.insert(section.Elements, infoBox)
    return infoBox
end

-- ============================================
-- SPACING COMPONENT
-- ============================================
function PepsiUI:AddSpacing(section, height)
    height = height or CONFIG.Spacing.Large
    
    local spacing = Utility.Create("Frame", {
        Name = "Spacing",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = CONFIG.ZIndex.Content + 5,
        Parent = section.Container,
    })
    
    return spacing
end

-- ============================================
-- UTILITY METHODS
-- ============================================
function PepsiUI:Toggle()
    self.ScreenGui.Enabled = not self.ScreenGui.Enabled
end

function PepsiUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function PepsiUI:GetConfig()
    local config = {}
    
    for _, tab in ipairs(self.Tabs) do
        config[tab.Name] = {}
        
        for _, section in ipairs(tab.Sections) do
            config[tab.Name][section.Name] = {}
            
            for _, element in ipairs(section.Elements) do
                if element.Type == "Toggle" then
                    config[tab.Name][section.Name][element.Name] = element.Value
                elseif element.Type == "Slider" then
                    config[tab.Name][section.Name][element.Name] = element.Value
                elseif element.Type == "Dropdown" then
                    config[tab.Name][section.Name][element.Name] = element.Value
                elseif element.Type == "Keybind" then
                    config[tab.Name][section.Name][element.Name] = element.Key.Name
                elseif element.Type == "Textbox" then
                    config[tab.Name][section.Name][element.Name] = element.Value
                end
            end
        end
    end
    
    return config
end

-- ============================================
-- RETURN MODULE
-- ============================================
return PepsiUI
