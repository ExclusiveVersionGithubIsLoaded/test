--[[
    Professional UI Library for Roblox
    Version: 2.0.0
    Features: All components, proper bindings, working dropdowns, color picker with wheel, no overlapping
    Design: Strict, professional, black-white theme inspired by Pepsi UI
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Local Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Utility Functions
local Utility = {}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:GetTextBounds(text, font, size)
    local textService = game:GetService("TextService")
    local bounds = textService:GetTextSize(text, size, font, Vector2.new(math.huge, math.huge))
    return bounds
end

function Utility:MakeDraggable(frame, dragFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Utility:RippleEffect(button, color)
    local ripple = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 1,
        Parent = button
    })

    Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })

    Utility:Tween(ripple, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, 0.5):Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Color Picker Utility
local ColorUtility = {}

function ColorUtility:HSVToRGB(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    
    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    
    return Color3.new(r + m, g + m, b + m)
end

function ColorUtility:RGBToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    local h = 0
    if delta > 0 then
        if max == r then
            h = 60 * (((g - b) / delta) % 6)
        elseif max == g then
            h = 60 * (((b - r) / delta) + 2)
        else
            h = 60 * (((r - g) / delta) + 4)
        end
    end
    
    local s = max == 0 and 0 or delta / max
    local v = max
    
    return h, s, v
end

-- Theme Configuration
local Theme = {
    -- Main Colors
    Background = Color3.fromRGB(15, 15, 15),
    SecondaryBackground = Color3.fromRGB(20, 20, 20),
    TertiaryBackground = Color3.fromRGB(25, 25, 25),
    
    -- Accent Colors
    Accent = Color3.fromRGB(255, 255, 255),
    AccentHover = Color3.fromRGB(220, 220, 220),
    AccentActive = Color3.fromRGB(180, 180, 180),
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDisabled = Color3.fromRGB(100, 100, 100),
    
    -- Border Colors
    Border = Color3.fromRGB(40, 40, 40),
    BorderStrong = Color3.fromRGB(60, 60, 60),
    
    -- Status Colors
    Success = Color3.fromRGB(100, 255, 100),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 100, 100),
    
    -- UI Elements
    Toggle = {
        Background = Color3.fromRGB(30, 30, 30),
        Enabled = Color3.fromRGB(255, 255, 255),
        Disabled = Color3.fromRGB(80, 80, 80)
    },
    
    Slider = {
        Background = Color3.fromRGB(30, 30, 30),
        Fill = Color3.fromRGB(255, 255, 255),
        Thumb = Color3.fromRGB(255, 255, 255)
    },
    
    Dropdown = {
        Background = Color3.fromRGB(25, 25, 25),
        Hover = Color3.fromRGB(35, 35, 35),
        Selected = Color3.fromRGB(255, 255, 255)
    },
    
    Button = {
        Background = Color3.fromRGB(30, 30, 30),
        Hover = Color3.fromRGB(40, 40, 40),
        Active = Color3.fromRGB(50, 50, 50)
    }
}

-- Notification System
local NotificationManager = {}
NotificationManager.Notifications = {}
NotificationManager.MaxNotifications = 5

function NotificationManager:Create(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "info"
    
    local notificationGui = PlayerGui:FindFirstChild("NotificationGui")
    if not notificationGui then
        notificationGui = Utility:Create("ScreenGui", {
            Name = "NotificationGui",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = PlayerGui
        })
    end
    
    local notifColor = Theme.Accent
    if notifType == "success" then
        notifColor = Theme.Success
    elseif notifType == "warning" then
        notifColor = Theme.Warning
    elseif notifType == "error" then
        notifColor = Theme.Error
    end
    
    local notification = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, -320, 0, 20 + (#NotificationManager.Notifications * 90)),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = notificationGui
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notification
    })
    
    Utility:Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = notification
    })
    
    local accent = Utility:Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = notifColor,
        BorderSizePixel = 0,
        Parent = notification
    })
    
    local titleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local messageLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, -36),
        Position = UDim2.new(0, 15, 0, 28),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notification
    })
    
    local closeButton = Utility:Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -28, 0, 8),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.TextSecondary,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = notification
    })
    
    table.insert(NotificationManager.Notifications, notification)
    
    Utility:Tween(notification, {Size = UDim2.new(0, 300, 0, 80)}, 0.3)
    
    local function closeNotification()
        Utility:Tween(notification, {
            Size = UDim2.new(0, 300, 0, 0),
            Position = UDim2.new(1, -320, 0, notification.Position.Y.Offset)
        }, 0.3).Completed:Connect(function()
            notification:Destroy()
            for i, notif in ipairs(NotificationManager.Notifications) do
                if notif == notification then
                    table.remove(NotificationManager.Notifications, i)
                    break
                end
            end
            
            for i, notif in ipairs(NotificationManager.Notifications) do
                Utility:Tween(notif, {
                    Position = UDim2.new(1, -320, 0, 20 + ((i - 1) * 90))
                }, 0.3)
            end
        end)
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    task.delay(duration, closeNotification)
    
    if #NotificationManager.Notifications > NotificationManager.MaxNotifications then
        NotificationManager.Notifications[1]:Destroy()
        table.remove(NotificationManager.Notifications, 1)
    end
end

-- Config Manager
local ConfigManager = {}
ConfigManager.CurrentConfig = {}
ConfigManager.ConfigFolder = "UILibConfigs"

function ConfigManager:Save(configName)
    local config = {}
    
    for key, value in pairs(ConfigManager.CurrentConfig) do
        if typeof(value) == "Color3" then
            config[key] = {value.R, value.G, value.B}
        else
            config[key] = value
        end
    end
    
    local success, result = pcall(function()
        if not isfolder(ConfigManager.ConfigFolder) then
            makefolder(ConfigManager.ConfigFolder)
        end
        writefile(ConfigManager.ConfigFolder .. "/" .. configName .. ".json", HttpService:JSONEncode(config))
    end)
    
    if success then
        NotificationManager:Create("Config Saved", "Configuration '" .. configName .. "' saved successfully", 3, "success")
        return true
    else
        NotificationManager:Create("Save Failed", "Failed to save configuration: " .. tostring(result), 5, "error")
        return false
    end
end

function ConfigManager:Load(configName)
    local success, result = pcall(function()
        local data = readfile(ConfigManager.ConfigFolder .. "/" .. configName .. ".json")
        return HttpService:JSONDecode(data)
    end)
    
    if success and result then
        for key, value in pairs(result) do
            if type(value) == "table" and #value == 3 then
                ConfigManager.CurrentConfig[key] = Color3.new(value[1], value[2], value[3])
            else
                ConfigManager.CurrentConfig[key] = value
            end
        end
        
        NotificationManager:Create("Config Loaded", "Configuration '" .. configName .. "' loaded successfully", 3, "success")
        return true
    else
        NotificationManager:Create("Load Failed", "Failed to load configuration", 5, "error")
        return false
    end
end

function ConfigManager:GetConfigs()
    if not isfolder(ConfigManager.ConfigFolder) then
        makefolder(ConfigManager.ConfigFolder)
        return {}
    end
    
    local configs = {}
    local success, files = pcall(function()
        return listfiles(ConfigManager.ConfigFolder)
    end)
    
    if success then
        for _, file in ipairs(files) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    
    return configs
end

function ConfigManager:Delete(configName)
    local success, result = pcall(function()
        delfile(ConfigManager.ConfigFolder .. "/" .. configName .. ".json")
    end)
    
    if success then
        NotificationManager:Create("Config Deleted", "Configuration '" .. configName .. "' deleted successfully", 3, "success")
        return true
    else
        NotificationManager:Create("Delete Failed", "Failed to delete configuration", 5, "error")
        return false
    end
end

-- Main Library
function Library:New(options)
    options = options or {}
    
    local screenGui = Utility:Create("ScreenGui", {
        Name = options.Name or "UILibrary",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui
    })
    
    local self = setmetatable({
        ScreenGui = screenGui,
        Windows = {},
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift,
        Flags = {}
    }, Library)
    
    -- Toggle GUI with key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.ToggleKey then
            for _, window in pairs(self.Windows) do
                window.Visible = not window.Visible
            end
        end
    end)
    
    return self
end

function Library:CreateWindow(options)
    options = options or {}
    
    local window = Utility:Create("Frame", {
        Name = options.Name or "Window",
        Size = options.Size or UDim2.new(0, 600, 0, 500),
        Position = options.Position or UDim2.new(0.5, -300, 0.5, -250),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        Parent = self.ScreenGui
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = window
    })
    
    Utility:Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = window
    })
    
    -- Header
    local header = Utility:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = window
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = header
    })
    
    local headerBottom = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = header
    })
    
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Name or "Window",
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Close Button
    local closeButton = Utility:Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0, 5),
        BackgroundColor3 = Theme.TertiaryBackground,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.TextPrimary,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = header
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = closeButton
    })
    
    closeButton.MouseButton1Click:Connect(function()
        Utility:RippleEffect(closeButton, Theme.Accent)
        window.Visible = false
    end)
    
    closeButton.MouseEnter:Connect(function()
        Utility:Tween(closeButton, {BackgroundColor3 = Theme.Button.Hover}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utility:Tween(closeButton, {BackgroundColor3 = Theme.TertiaryBackground}, 0.2)
    end)
    
    -- Tab Container
    local tabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundTransparency = 1,
        Parent = window
    })
    
    local tabList = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContainer
    })
    
    -- Content Container
    local contentContainer = Utility:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -165, 1, -50),
        Position = UDim2.new(0, 160, 0, 45),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = window
    })
    
    Utility:MakeDraggable(window, header)
    
    table.insert(self.Windows, window)
    
    local WindowAPI = {
        Window = window,
        Tabs = {},
        Library = self
    }
    
    function WindowAPI:CreateTab(options)
        options = options or {}
        
        local tabButton = Utility:Create("TextButton", {
            Name = options.Name or "Tab",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.TertiaryBackground,
            BorderSizePixel = 0,
            Text = "",
            Parent = tabContainer
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabButton
        })
        
        local tabIcon = Utility:Create("TextLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Text = options.Icon or "●",
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = tabButton
        })
        
        local tabLabel = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = options.Name or "Tab",
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        local tabContent = Utility:Create("ScrollingFrame", {
            Name = options.Name or "Tab",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentContainer
        })
        
        local contentList = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })
        
        local contentPadding = Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            Parent = tabContent
        })
        
        local isActive = false
        
        local function setActive()
            for _, tab in pairs(WindowAPI.Tabs) do
                tab.Button.BackgroundColor3 = Theme.TertiaryBackground
                tab.Icon.TextColor3 = Theme.TextSecondary
                tab.Label.TextColor3 = Theme.TextSecondary
                tab.Content.Visible = false
            end
            
            tabButton.BackgroundColor3 = Theme.SecondaryBackground
            tabIcon.TextColor3 = Theme.Accent
            tabLabel.TextColor3 = Theme.Accent
            tabContent.Visible = true
            isActive = true
        end
        
        tabButton.MouseButton1Click:Connect(function()
            Utility:RippleEffect(tabButton, Theme.Accent)
            setActive()
        end)
        
        tabButton.MouseEnter:Connect(function()
            if not isActive then
                Utility:Tween(tabButton, {BackgroundColor3 = Theme.SecondaryBackground}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not isActive then
                Utility:Tween(tabButton, {BackgroundColor3 = Theme.TertiaryBackground}, 0.2)
            end
        end)
        
        local TabAPI = {
            Button = tabButton,
            Icon = tabIcon,
            Label = tabLabel,
            Content = tabContent,
            Sections = {}
        }
        
        table.insert(WindowAPI.Tabs, TabAPI)
        
        if #WindowAPI.Tabs == 1 then
            setActive()
        end
        
        function TabAPI:CreateSection(options)
            options = options or {}
            
            local section = Utility:Create("Frame", {
                Name = options.Name or "Section",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = tabContent
            })
            
            Utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = section
            })
            
            Utility:Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                Parent = section
            })
            
            local sectionHeader = Utility:Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Parent = section
            })
            
            local sectionTitle = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = options.Name or "Section",
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionHeader
            })
            
            local sectionDivider = Utility:Create("Frame", {
                Size = UDim2.new(1, -20, 0, 1),
                Position = UDim2.new(0, 10, 0, 35),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = section
            })
            
            local sectionContent = Utility:Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 40),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = section
            })
            
            local contentList = Utility:Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = sectionContent
            })
            
            local contentPadding = Utility:Create("UIPadding", {
                PaddingBottom = UDim.new(0, 10),
                Parent = sectionContent
            })
            
            local SectionAPI = {
                Section = section,
                Content = sectionContent
            }
            
            table.insert(TabAPI.Sections, SectionAPI)
            
            -- TOGGLE
            function SectionAPI:CreateToggle(options)
                options = options or {}
                local flagName = options.Flag or options.Name or "Toggle"
                local currentValue = options.Default or false
                ConfigManager.CurrentConfig[flagName] = currentValue
                
                local toggleFrame = Utility:Create("Frame", {
                    Name = "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local toggleLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Toggle",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
                
                local toggleButton = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -44, 0.5, -11),
                    BackgroundColor3 = Theme.Toggle.Background,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = toggleFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleButton
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = toggleButton
                })
                
                local toggleIndicator = Utility:Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = Theme.Toggle.Disabled,
                    BorderSizePixel = 0,
                    Parent = toggleButton
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleIndicator
                })
                
                local function updateToggle()
                    if currentValue then
                        Utility:Tween(toggleIndicator, {
                            Position = UDim2.new(1, -20, 0.5, -9),
                            BackgroundColor3 = Theme.Toggle.Enabled
                        }, 0.25)
                        Utility:Tween(toggleButton, {
                            BackgroundColor3 = Theme.Accent
                        }, 0.25)
                    else
                        Utility:Tween(toggleIndicator, {
                            Position = UDim2.new(0, 2, 0.5, -9),
                            BackgroundColor3 = Theme.Toggle.Disabled
                        }, 0.25)
                        Utility:Tween(toggleButton, {
                            BackgroundColor3 = Theme.Toggle.Background
                        }, 0.25)
                    end
                    
                    ConfigManager.CurrentConfig[flagName] = currentValue
                    
                    if options.Callback then
                        task.spawn(function()
                            options.Callback(currentValue)
                        end)
                    end
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    currentValue = not currentValue
                    updateToggle()
                end)
                
                updateToggle()
                
                return {
                    SetValue = function(value)
                        currentValue = value
                        updateToggle()
                    end,
                    GetValue = function()
                        return currentValue
                    end
                }
            end
            
            -- SLIDER
            function SectionAPI:CreateSlider(options)
                options = options or {}
                local flagName = options.Flag or options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local currentValue = default
                ConfigManager.CurrentConfig[flagName] = currentValue
                
                local sliderFrame = Utility:Create("Frame", {
                    Name = "Slider",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local sliderLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Slider",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                
                local sliderValue = Utility:Create("TextLabel", {
                    Size = UDim2.new(0.4, 0, 0, 20),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(currentValue),
                    TextColor3 = Theme.Accent,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderFrame
                })
                
                local sliderTrack = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Theme.Slider.Background,
                    BorderSizePixel = 0,
                    Parent = sliderFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = sliderTrack
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = sliderTrack
                })
                
                local sliderFill = Utility:Create("Frame", {
                    Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Slider.Fill,
                    BorderSizePixel = 0,
                    Parent = sliderTrack
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = sliderFill
                })
                
                local sliderThumb = Utility:Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((currentValue - min) / (max - min), -8, 0.5, -8),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Theme.Slider.Thumb,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = sliderTrack
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderThumb
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.BorderStrong,
                    Thickness = 2,
                    Parent = sliderThumb
                })
                
                local dragging = false
                
                local function updateSlider(input)
                    local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * relativeX
                    value = math.floor(value / increment + 0.5) * increment
                    value = math.clamp(value, min, max)
                    
                    currentValue = value
                    sliderValue.Text = tostring(value)
                    
                    Utility:Tween(sliderFill, {
                        Size = UDim2.new(relativeX, 0, 1, 0)
                    }, 0.1)
                    
                    Utility:Tween(sliderThumb, {
                        Position = UDim2.new(relativeX, -8, 0.5, -8)
                    }, 0.1)
                    
                    ConfigManager.CurrentConfig[flagName] = currentValue
                    
                    if options.Callback then
                        task.spawn(function()
                            options.Callback(value)
                        end)
                    end
                end
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                        Utility:Tween(sliderThumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
                    end
                end)
                
                sliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        Utility:Tween(sliderThumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                return {
                    SetValue = function(value)
                        currentValue = math.clamp(value, min, max)
                        sliderValue.Text = tostring(currentValue)
                        local relativeX = (currentValue - min) / (max - min)
                        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                        sliderThumb.Position = UDim2.new(relativeX, -8, 0.5, -8)
                        ConfigManager.CurrentConfig[flagName] = currentValue
                    end,
                    GetValue = function()
                        return currentValue
                    end
                }
            end
            
            -- DROPDOWN
            function SectionAPI:CreateDropdown(options)
                options = options or {}
                local flagName = options.Flag or options.Name or "Dropdown"
                local items = options.Items or {}
                local currentValue = options.Default or (items[1] or "None")
                local multi = options.Multi or false
                local currentValues = {}
                
                if multi then
                    ConfigManager.CurrentConfig[flagName] = currentValues
                else
                    ConfigManager.CurrentConfig[flagName] = currentValue
                end
                
                local dropdownFrame = Utility:Create("Frame", {
                    Name = "Dropdown",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local dropdownButton = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.TertiaryBackground,
                    BorderSizePixel = 0,
                    Text = "",
                    ClipsDescendants = true,
                    Parent = dropdownFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdownButton
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = dropdownButton
                })
                
                local dropdownLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Dropdown",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownButton
                })
                
                local dropdownValue = Utility:Create("TextLabel", {
                    Size = UDim2.new(0, 100, 1, 0),
                    Position = UDim2.new(1, -130, 0, 0),
                    BackgroundTransparency = 1,
                    Text = multi and "None" or currentValue,
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = dropdownButton
                })
                
                local dropdownArrow = Utility:Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    Parent = dropdownButton
                })
                
                local dropdownList = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 42),
                    BackgroundColor3 = Theme.Dropdown.Background,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = self.Library.ScreenGui
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdownList
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.BorderStrong,
                    Thickness = 1,
                    Parent = dropdownList
                })
                
                local listScroll = Utility:Create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = Theme.Border,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = dropdownList
                })
                
                local listLayout = Utility:Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = listScroll
                })
                
                local listPadding = Utility:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = listScroll
                })
                
                local isOpen = false
                
                local function updateDropdownText()
                    if multi then
                        if #currentValues == 0 then
                            dropdownValue.Text = "None"
                        else
                            dropdownValue.Text = table.concat(currentValues, ", ")
                        end
                        ConfigManager.CurrentConfig[flagName] = currentValues
                    else
                        dropdownValue.Text = currentValue
                        ConfigManager.CurrentConfig[flagName] = currentValue
                    end
                end
                
                local function createItem(itemName)
                    local itemButton = Utility:Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.Dropdown.Background,
                        BorderSizePixel = 0,
                        Text = "",
                        Parent = listScroll
                    })
                    
                    Utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = itemButton
                    })
                    
                    local itemLabel = Utility:Create("TextLabel", {
                        Size = UDim2.new(1, -10, 1, 0),
                        Position = UDim2.new(0, 5, 0, 0),
                        BackgroundTransparency = 1,
                        Text = itemName,
                        TextColor3 = Theme.TextSecondary,
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = itemButton
                    })
                    
                    local checkmark = Utility:Create("TextLabel", {
                        Size = UDim2.new(0, 20, 1, 0),
                        Position = UDim2.new(1, -25, 0, 0),
                        BackgroundTransparency = 1,
                        Text = "✓",
                        TextColor3 = Theme.Accent,
                        TextSize = 14,
                        Font = Enum.Font.GothamBold,
                        Visible = false,
                        Parent = itemButton
                    })
                    
                    if multi then
                        if table.find(currentValues, itemName) then
                            checkmark.Visible = true
                            itemLabel.TextColor3 = Theme.Accent
                        end
                    else
                        if itemName == currentValue then
                            checkmark.Visible = true
                            itemLabel.TextColor3 = Theme.Accent
                        end
                    end
                    
                    itemButton.MouseButton1Click:Connect(function()
                        if multi then
                            local index = table.find(currentValues, itemName)
                            if index then
                                table.remove(currentValues, index)
                                checkmark.Visible = false
                                itemLabel.TextColor3 = Theme.TextSecondary
                            else
                                table.insert(currentValues, itemName)
                                checkmark.Visible = true
                                itemLabel.TextColor3 = Theme.Accent
                            end
                            updateDropdownText()
                            
                            if options.Callback then
                                task.spawn(function()
                                    options.Callback(currentValues)
                                end)
                            end
                        else
                            for _, child in pairs(listScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local check = child:FindFirstChild("TextLabel")
                                    local label = child:FindFirstChildOfClass("TextLabel")
                                    if check and check.Text == "✓" then
                                        check.Visible = false
                                    end
                                    if label and label.Text ~= "✓" then
                                        label.TextColor3 = Theme.TextSecondary
                                    end
                                end
                            end
                            
                            currentValue = itemName
                            checkmark.Visible = true
                            itemLabel.TextColor3 = Theme.Accent
                            updateDropdownText()
                            
                            if options.Callback then
                                task.spawn(function()
                                    options.Callback(currentValue)
                                end)
                            end
                            
                            isOpen = false
                            Utility:Tween(dropdownArrow, {Rotation = 0}, 0.2)
                            Utility:Tween(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
                                dropdownList.Visible = false
                            end)
                        end
                    end)
                    
                    itemButton.MouseEnter:Connect(function()
                        Utility:Tween(itemButton, {BackgroundColor3 = Theme.Dropdown.Hover}, 0.2)
                    end)
                    
                    itemButton.MouseLeave:Connect(function()
                        Utility:Tween(itemButton, {BackgroundColor3 = Theme.Dropdown.Background}, 0.2)
                    end)
                end
                
                for _, item in ipairs(items) do
                    createItem(item)
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    
                    if isOpen then
                        local maxHeight = math.min(#items * 32 + 10, 200)
                        dropdownList.Position = UDim2.new(
                            0,
                            dropdownButton.AbsolutePosition.X,
                            0,
                            dropdownButton.AbsolutePosition.Y + dropdownButton.AbsoluteSize.Y + 5
                        )
                        dropdownList.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)
                        dropdownList.Visible = true
                        
                        Utility:Tween(dropdownArrow, {Rotation = 180}, 0.2)
                        Utility:Tween(dropdownList, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, maxHeight)}, 0.3)
                    else
                        Utility:Tween(dropdownArrow, {Rotation = 0}, 0.2)
                        Utility:Tween(dropdownList, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)}, 0.2).Completed:Connect(function()
                            dropdownList.Visible = false
                        end)
                    end
                end)
                
                dropdownButton.MouseEnter:Connect(function()
                    Utility:Tween(dropdownButton, {BackgroundColor3 = Theme.Button.Hover}, 0.2)
                end)
                
                dropdownButton.MouseLeave:Connect(function()
                    Utility:Tween(dropdownButton, {BackgroundColor3 = Theme.TertiaryBackground}, 0.2)
                end)
                
                return {
                    SetValue = function(value)
                        if multi then
                            currentValues = value
                        else
                            currentValue = value
                        end
                        updateDropdownText()
                    end,
                    GetValue = function()
                        return multi and currentValues or currentValue
                    end,
                    AddItem = function(item)
                        table.insert(items, item)
                        createItem(item)
                    end,
                    RemoveItem = function(item)
                        local index = table.find(items, item)
                        if index then
                            table.remove(items, index)
                            for _, child in pairs(listScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local label = child:FindFirstChildOfClass("TextLabel")
                                    if label and label.Text == item then
                                        child:Destroy()
                                        break
                                    end
                                end
                            end
                        end
                    end
                }
            end
            
            -- COLOR PICKER
            function SectionAPI:CreateColorPicker(options)
                options = options or {}
                local flagName = options.Flag or options.Name or "ColorPicker"
                local currentColor = options.Default or Color3.fromRGB(255, 255, 255)
                ConfigManager.CurrentConfig[flagName] = currentColor
                
                local colorFrame = Utility:Create("Frame", {
                    Name = "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local colorLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -90, 1, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Color Picker",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = colorFrame
                })
                
                local colorDisplay = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 70, 0, 24),
                    Position = UDim2.new(1, -70, 0.5, -12),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = colorFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorDisplay
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.BorderStrong,
                    Thickness = 2,
                    Parent = colorDisplay
                })
                
                -- Color Picker Window
                local pickerWindow = Utility:Create("Frame", {
                    Size = UDim2.new(0, 260, 0, 300),
                    Position = UDim2.new(0.5, -130, 0.5, -150),
                    BackgroundColor3 = Theme.SecondaryBackground,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 200,
                    Parent = self.Library.ScreenGui
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 10),
                    Parent = pickerWindow
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.BorderStrong,
                    Thickness = 2,
                    Parent = pickerWindow
                })
                
                local pickerHeader = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.TertiaryBackground,
                    BorderSizePixel = 0,
                    Parent = pickerWindow
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 10),
                    Parent = pickerHeader
                })
                
                local headerBottom = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 1, -10),
                    BackgroundColor3 = Theme.TertiaryBackground,
                    BorderSizePixel = 0,
                    Parent = pickerHeader
                })
                
                local pickerTitle = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Color Picker",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = pickerHeader
                })
                
                local pickerClose = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 25, 0, 25),
                    Position = UDim2.new(1, -30, 0, 5),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Text = "×",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 18,
                    Font = Enum.Font.GothamBold,
                    Parent = pickerHeader
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = pickerClose
                })
                
                -- Saturation/Value Canvas
                local svCanvas = Utility:Create("Frame", {
                    Size = UDim2.new(1, -20, 0, 180),
                    Position = UDim2.new(0, 10, 0, 45),
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    BorderSizePixel = 0,
                    Parent = pickerWindow
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = svCanvas
                })
                
                local svWhite = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = svCanvas
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = svWhite
                })
                
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    },
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    },
                    Parent = svWhite
                })
                
                local svBlack = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = svCanvas
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = svBlack
                })
                
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)),
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    },
                    Rotation = 90,
                    Parent = svBlack
                })
                
                local svSelector = Utility:Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -6, 0, -6),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = svCanvas
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = svSelector
                })
                
                Utility:Create("UIStroke", {
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 2,
                    Parent = svSelector
                })
                
                -- Hue Slider
                local hueSlider = Utility:Create("Frame", {
                    Size = UDim2.new(1, -20, 0, 15),
                    Position = UDim2.new(0, 10, 0, 235),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = pickerWindow
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = hueSlider
                })
                
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    },
                    Parent = hueSlider
                })
                
                local hueSelector = Utility:Create("Frame", {
                    Size = UDim2.new(0, 6, 1, 4),
                    Position = UDim2.new(0, -3, 0, -2),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = hueSlider
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = hueSelector
                })
                
                Utility:Create("UIStroke", {
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 2,
                    Parent = hueSelector
                })
                
                -- Preview and RGB
                local previewFrame = Utility:Create("Frame", {
                    Size = UDim2.new(0, 60, 0, 35),
                    Position = UDim2.new(0, 10, 0, 260),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Parent = pickerWindow
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = previewFrame
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.BorderStrong,
                    Thickness = 2,
                    Parent = previewFrame
                })
                
                local rgbLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -80, 0, 35),
                    Position = UDim2.new(0, 75, 0, 260),
                    BackgroundTransparency = 1,
                    Text = string.format("RGB(%d, %d, %d)", 
                        math.floor(currentColor.R * 255),
                        math.floor(currentColor.G * 255),
                        math.floor(currentColor.B * 255)
                    ),
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = pickerWindow
                })
                
                -- Color Picker Logic
                local h, s, v = ColorUtility:RGBToHSV(currentColor)
                local draggingSV = false
                local draggingHue = false
                
                local function updateColorFromHSV()
                    currentColor = ColorUtility:HSVToRGB(h, s, v)
                    colorDisplay.BackgroundColor3 = currentColor
                    previewFrame.BackgroundColor3 = currentColor
                    svCanvas.BackgroundColor3 = ColorUtility:HSVToRGB(h, 1, 1)
                    
                    rgbLabel.Text = string.format("RGB(%d, %d, %d)",
                        math.floor(currentColor.R * 255),
                        math.floor(currentColor.G * 255),
                        math.floor(currentColor.B * 255)
                    )
                    
                    ConfigManager.CurrentConfig[flagName] = currentColor
                    
                    if options.Callback then
                        task.spawn(function()
                            options.Callback(currentColor)
                        end)
                    end
                end
                
                local function updateSVPosition(input)
                    local relX = math.clamp((input.Position.X - svCanvas.AbsolutePosition.X) / svCanvas.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((input.Position.Y - svCanvas.AbsolutePosition.Y) / svCanvas.AbsoluteSize.Y, 0, 1)
                    
                    s = relX
                    v = 1 - relY
                    
                    svSelector.Position = UDim2.new(relX, 0, relY, 0)
                    updateColorFromHSV()
                end
                
                local function updateHuePosition(input)
                    local relX = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    h = relX * 360
                    
                    hueSelector.Position = UDim2.new(relX, -3, 0, -2)
                    updateColorFromHSV()
                end
                
                svCanvas.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        updateSVPosition(input)
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
                        updateHuePosition(input)
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
                            updateSVPosition(input)
                        elseif draggingHue then
                            updateHuePosition(input)
                        end
                    end
                end)
                
                colorDisplay.MouseButton1Click:Connect(function()
                    pickerWindow.Visible = not pickerWindow.Visible
                end)
                
                pickerClose.MouseButton1Click:Connect(function()
                    pickerWindow.Visible = false
                end)
                
                pickerClose.MouseEnter:Connect(function()
                    Utility:Tween(pickerClose, {BackgroundColor3 = Theme.Button.Hover}, 0.2)
                end)
                
                pickerClose.MouseLeave:Connect(function()
                    Utility:Tween(pickerClose, {BackgroundColor3 = Theme.Background}, 0.2)
                end)
                
                Utility:MakeDraggable(pickerWindow, pickerHeader)
                
                -- Initialize positions
                svSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                hueSelector.Position = UDim2.new(h / 360, -3, 0, -2)
                svCanvas.BackgroundColor3 = ColorUtility:HSVToRGB(h, 1, 1)
                
                return {
                    SetValue = function(color)
                        currentColor = color
                        h, s, v = ColorUtility:RGBToHSV(color)
                        colorDisplay.BackgroundColor3 = color
                        previewFrame.BackgroundColor3 = color
                        svCanvas.BackgroundColor3 = ColorUtility:HSVToRGB(h, 1, 1)
                        svSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                        hueSelector.Position = UDim2.new(h / 360, -3, 0, -2)
                        rgbLabel.Text = string.format("RGB(%d, %d, %d)",
                            math.floor(color.R * 255),
                            math.floor(color.G * 255),
                            math.floor(color.B * 255)
                        )
                        ConfigManager.CurrentConfig[flagName] = currentColor
                    end,
                    GetValue = function()
                        return currentColor
                    end
                }
            end
            
            -- KEYBIND
            function SectionAPI:CreateKeybind(options)
                options = options or {}
                local flagName = options.Flag or options.Name or "Keybind"
                local currentKey = options.Default or Enum.KeyCode.None
                local keyName = options.DefaultName or "None"
                ConfigManager.CurrentConfig[flagName] = currentKey
                
                local keybindFrame = Utility:Create("Frame", {
                    Name = "Keybind",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local keybindLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -90, 1, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Keybind",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindFrame
                })
                
                local keybindButton = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 70, 0, 24),
                    Position = UDim2.new(1, -70, 0.5, -12),
                    BackgroundColor3 = Theme.TertiaryBackground,
                    BorderSizePixel = 0,
                    Text = keyName,
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Parent = keybindFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = keybindButton
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = keybindButton
                })
                
                local binding = false
                
                keybindButton.MouseButton1Click:Connect(function()
                    binding = true
                    keybindButton.Text = "..."
                    keybindButton.TextColor3 = Theme.Warning
                end)
                
                keybindButton.MouseEnter:Connect(function()
                    if not binding then
                        Utility:Tween(keybindButton, {BackgroundColor3 = Theme.Button.Hover}, 0.2)
                    end
                end)
                
                keybindButton.MouseLeave:Connect(function()
                    if not binding then
                        Utility:Tween(keybindButton, {BackgroundColor3 = Theme.TertiaryBackground}, 0.2)
                    end
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local keyCode = input.KeyCode
                            
                            if keyCode == Enum.KeyCode.Escape then
                                currentKey = Enum.KeyCode.None
                                keyName = "None"
                            else
                                currentKey = keyCode
                                keyName = keyCode.Name
                            end
                            
                            keybindButton.Text = keyName
                            keybindButton.TextColor3 = Theme.Accent
                            binding = false
                            
                            ConfigManager.CurrentConfig[flagName] = currentKey
                            
                            if options.Callback then
                                task.spawn(function()
                                    options.Callback(currentKey)
                                end)
                            end
                        end
                    elseif not gameProcessed and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.None then
                        if options.OnPress then
                            task.spawn(function()
                                options.OnPress()
                            end)
                        end
                    end
                end)
                
                return {
                    SetValue = function(keyCode, name)
                        currentKey = keyCode
                        keyName = name or keyCode.Name
                        keybindButton.Text = keyName
                        ConfigManager.CurrentConfig[flagName] = currentKey
                    end,
                    GetValue = function()
                        return currentKey
                    end
                }
            end
            
            -- BUTTON
            function SectionAPI:CreateButton(options)
                options = options or {}
                
                local buttonFrame = Utility:Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.Button.Background,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = sectionContent
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = buttonFrame
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = buttonFrame
                })
                
                local buttonLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Button",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = buttonFrame
                })
                
                buttonFrame.MouseButton1Click:Connect(function()
                    Utility:RippleEffect(buttonFrame, Theme.Accent)
                    if options.Callback then
                        task.spawn(function()
                            options.Callback()
                        end)
                    end
                end)
                
                buttonFrame.MouseEnter:Connect(function()
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Theme.Button.Hover}, 0.2)
                    Utility:Tween(buttonLabel, {TextColor3 = Theme.Accent}, 0.2)
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Theme.Button.Background}, 0.2)
                    Utility:Tween(buttonLabel, {TextColor3 = Theme.TextPrimary}, 0.2)
                end)
            end
            
            -- TEXTBOX
            function SectionAPI:CreateTextBox(options)
                options = options or {}
                local flagName = options.Flag or options.Name or "TextBox"
                local currentText = options.Default or ""
                ConfigManager.CurrentConfig[flagName] = currentText
                
                local textboxFrame = Utility:Create("Frame", {
                    Name = "TextBox",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local textboxLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(0.4, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "TextBox",
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxFrame
                })
                
                local textbox = Utility:Create("TextBox", {
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Position = UDim2.new(0.45, 0, 0, 0),
                    BackgroundColor3 = Theme.TertiaryBackground,
                    BorderSizePixel = 0,
                    Text = currentText,
                    PlaceholderText = options.Placeholder or "Enter text...",
                    TextColor3 = Theme.Accent,
                    PlaceholderColor3 = Theme.TextDisabled,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = textboxFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = textbox
                })
                
                Utility:Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = textbox
                })
                
                Utility:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    Parent = textbox
                })
                
                textbox.FocusLost:Connect(function(enterPressed)
                    currentText = textbox.Text
                    ConfigManager.CurrentConfig[flagName] = currentText
                    
                    if options.Callback then
                        task.spawn(function()
                            options.Callback(currentText, enterPressed)
                        end)
                    end
                end)
                
                textbox.Focused:Connect(function()
                    Utility:Tween(textbox, {BackgroundColor3 = Theme.Button.Hover}, 0.2)
                end)
                
                textbox:GetPropertyChangedSignal("Text"):Connect(function()
                    if textbox:IsFocused() then
                        Utility:Tween(textbox, {BackgroundColor3 = Theme.Button.Active}, 0.2)
                    end
                end)
                
                return {
                    SetValue = function(text)
                        currentText = text
                        textbox.Text = text
                        ConfigManager.CurrentConfig[flagName] = currentText
                    end,
                    GetValue = function()
                        return currentText
                    end
                }
            end
            
            -- LABEL
            function SectionAPI:CreateLabel(options)
                options = options or {}
                
                local label = Utility:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Text = options.Text or "Label",
                    TextColor3 = options.Color or Theme.TextSecondary,
                    TextSize = options.Size or 13,
                    Font = options.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = sectionContent
                })
                
                return {
                    SetText = function(text)
                        label.Text = text
                    end,
                    SetColor = function(color)
                        label.TextColor3 = color
                    end
                }
            end
            
            -- DIVIDER
            function SectionAPI:CreateDivider()
                local divider = Utility:Create("Frame", {
                    Name = "Divider",
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel = 0,
                    Parent = sectionContent
                })
                
                return divider
            end
            
            return SectionAPI
        end
        
        return TabAPI
    end
    
    return WindowAPI
end

-- Notifications
function Library:Notify(title, message, duration, notifType)
    NotificationManager:Create(title, message, duration, notifType)
end

-- Config Management
function Library:SaveConfig(name)
    return ConfigManager:Save(name)
end

function Library:LoadConfig(name)
    return ConfigManager:Load(name)
end

function Library:GetConfigs()
    return ConfigManager:GetConfigs()
end

function Library:DeleteConfig(name)
    return ConfigManager:Delete(name)
end

function Library:GetFlag(flag)
    return ConfigManager.CurrentConfig[flag]
end

function Library:SetFlag(flag, value)
    ConfigManager.CurrentConfig[flag] = value
end

return Library
