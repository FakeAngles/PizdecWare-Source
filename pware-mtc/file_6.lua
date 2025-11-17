-- UI Library – точная копия ва-- UI Library – точная копия ва
local UILibrary = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
-- Глобальные переменные для элементов
_G.UIElements = _G.UIElements or {}
_G.UICallbacks = _G.UICallbacks or {}
-- Глобальные функции создания элементов
function CreateToggle(config)
    local element = {
        section = config.section,
        save = config.save or false,
        name = config.name or "Toggle",
        default = config.default or false,
        callback = config.callback,
        id = config.id or config.name or "Toggle"
    }
   
    if config.save then
        _G.UIElements[element.id] = element
    end
   
    return element.section:CreateToggle(element.name, element.default, element.callback, element.save and element.id or nil)
end
function CreateButton(config)
    local element = {
        section = config.section,
        save = config.save or false,
        name = config.name or "Button",
        position = config.position or "left",
        callback = config.callback,
        id = config.id or config.name or "Button"
    }
   
    if config.save then
        _G.UIElements[element.id] = element
    end
   
    return element.section:CreateButton(element.name, element.position, element.callback)
end
function CreateBind(config)
    local element = {
        section = config.section,
        save = config.save or false,
        name = config.name or "Bind",
        default = config.default or Enum.KeyCode.F,
        callback = config.callback,
        id = config.id or config.name or "Bind"
    }
   
    if config.save then
        _G.UIElements[element.id] = element
    end
   
    return element.section:CreateBind(element.name, element.default, element.callback, element.save and element.id or nil)
end
function CreateDropdown(config)
    local element = {
        section = config.section,
        save = config.save or false,
        name = config.name or "Dropdown",
        options = config.options or {"Option1", "Option2"},
        default = config.default or config.options[1],
        multi = config.multi or false,
        search = config.search or false,
        callback = config.callback,
        id = config.id or config.name or "Dropdown"
    }
   
    if config.save then
        _G.UIElements[element.id] = element
    end
   
    return element.section:CreateDropdown(element.name, element.options, element.default, element.callback, element.multi, element.search, element.save and element.id or nil)
end
function CreateSlider(config)
    local element = {
        section = config.section,
        save = config.save or false,
        name = config.name or "Slider",
        min = config.min or 0,
        max = config.max or 100,
        default = config.default or 50,
        callback = config.callback,
        id = config.id or config.name or "Slider"
    }
   
    if config.save then
        _G.UIElements[element.id] = element
    end
   
    return element.section:CreateSlider(element.name, element.min, element.max, element.default, element.callback, element.save and element.id or nil)
end
function CreateInput(config)
    local element = {
        section = config.section,
        save = config.save or false,
        name = config.name or "Input",
        placeholder = config.placeholder or "Input...",
        default = config.default or "",
        callback = config.callback,
        id = config.id or config.name or "Input"
    }
   
    if config.save then
        _G.UIElements[element.id] = element
    end
   
    return element.section:CreateInput(element.name, element.placeholder, element.default, element.callback, element.save and element.id or nil)
end
-- === Сохранение/загрузка настроек ===
local function saveSettings(fileName, settings)
    if writefile then
        writefile(fileName, HttpService:JSONEncode(settings))
    end
end
-- === Функция сокращения названий клавиш ===
local function formatKeyName(keyName)
    local shortcuts = {
        ["RightShift"] = "RShift",
        ["LeftShift"] = "LShift",
        ["RightControl"] = "RCtrl",
        ["LeftControl"] = "LCtrl",
        ["RightAlt"] = "RAlt",
        ["LeftAlt"] = "LAlt"
    }
   
    if shortcuts[keyName] then
        return shortcuts[keyName]
    elseif string.len(keyName) > 5 then
        return string.sub(keyName, 1, 5)
    else
        return keyName
    end
end
local function loadSettings(fileName)
    if readfile and isfile and isfile(fileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success then return result end
    end
    return {}
end
-- === Основная функция ===
function UILibrary.new(config)
    local ui = {}
    local settings = loadSettings(config.FileName or "ui_settings.json")
    local tabSections = {}
    local tabs = {}
    local currentTab = nil
    local uiVisible = true
    local keyBind = settings.keyBind or Enum.KeyCode.RightShift
    -- === ScreenGui ===
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PizdecWareUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    -- === MainFrame ===
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.108214848, 0, 0.333333343, 0)
    MainFrame.Size = UDim2.new(0, 570, 0, 380)
    Instance.new("UICorner", MainFrame)
   
    -- === Функция перетаскивания ===
    local dragging = false
    local dragStart = nil
    local startPos = nil
   
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
   
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
   
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    -- === Menu ===
    local Menu = Instance.new("Frame")
    Menu.Name = "Menu"
    Menu.Parent = MainFrame
    Menu.BackgroundColor3 = Color3.fromRGB(28, 28, 31)
    Menu.BorderColor3 = Color3.fromRGB(39, 39, 42)
    Menu.BorderSizePixel = 1
    Menu.Position = UDim2.new(0, 0, 0.00263157906, 0)
    Menu.Size = UDim2.new(0, 130, 0, 378)
    Menu.ZIndex = 5
    -- === ElementContainer ===
    local ElementContainer = Instance.new("ScrollingFrame")
    ElementContainer.Name = "ElementContainer"
    ElementContainer.Parent = MainFrame
    ElementContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    ElementContainer.BorderColor3 = Color3.fromRGB(39, 39, 42)
    ElementContainer.BorderSizePixel = 1
    ElementContainer.Position = UDim2.new(0.22807017, 0, 0.104999982, 0)
    ElementContainer.Size = UDim2.new(0, 439, 0, 329)
    ElementContainer.ScrollBarThickness = 3
    ElementContainer.ScrollBarImageColor3 = Color3.fromRGB(150, 17, 255)
    ElementContainer.ScrollBarImageTransparency = 0
    ElementContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
   
    _G.OpenDropdowns = _G.OpenDropdowns or {}
    _G.DropdownButtons = _G.DropdownButtons or {}
    -- === Tabzone ===
    local Tabzone = Instance.new("ScrollingFrame")
    Tabzone.Name = "Tabzone"
    Tabzone.Parent = Menu
    Tabzone.BackgroundColor3 = Color3.fromRGB(28, 28, 31)
    Tabzone.BorderColor3 = Color3.fromRGB(39, 39, 42)
    Tabzone.BorderSizePixel = 1
    Tabzone.Position = UDim2.new(0, 0, 0.102910116, 0)
    Tabzone.Size = UDim2.new(0, 130, 0, 226)
    Tabzone.ZIndex = 5
    Tabzone.ScrollBarThickness = 3
    Tabzone.ScrollBarImageColor3 = Color3.fromRGB(150, 17, 255)
    Tabzone.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tabzone.ScrollingDirection = Enum.ScrollingDirection.Y
    -- === SelectedTabName ===
    local SelectedTabName = Instance.new("TextLabel")
    SelectedTabName.Name = "SelectedTabName"
    SelectedTabName.Parent = MainFrame
    SelectedTabName.BackgroundTransparency = 1
    SelectedTabName.Position = UDim2.new(0, 140, 0, 8)
    SelectedTabName.Size = UDim2.new(0, 200, 0, 24)
    SelectedTabName.Font = Enum.Font.SourceSansBold
    SelectedTabName.Text = ""
    SelectedTabName.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectedTabName.TextSize = 18
    SelectedTabName.TextXAlignment = Enum.TextXAlignment.Left
    SelectedTabName.ZIndex = 10
    -- === BaseUIconfigsZone ===
    local BaseUIconfigsZone = Instance.new("Frame")
    BaseUIconfigsZone.Name = "BaseUIconfigsZone"
    BaseUIconfigsZone.Parent = Menu
    BaseUIconfigsZone.BackgroundColor3 = Color3.fromRGB(28, 28, 31)
    BaseUIconfigsZone.BorderColor3 = Color3.fromRGB(39, 39, 42)
    BaseUIconfigsZone.BorderSizePixel = 1
    BaseUIconfigsZone.Position = UDim2.new(0, 0, 0.700793743, 0)
    BaseUIconfigsZone.Size = UDim2.new(0, 130, 0, 73)
    BaseUIconfigsZone.ZIndex = 5
    -- === Discord Button ===
    if config.discordURL then
        local Discordbutton = Instance.new("Frame")
        Discordbutton.Name = "Discordbutton"
        Discordbutton.Parent = BaseUIconfigsZone
        Discordbutton.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
        Discordbutton.BackgroundTransparency = 1
        Discordbutton.BorderSizePixel = 0
        Discordbutton.Position = UDim2.new(0, 0, 0.339335412, 0)
        Discordbutton.Size = UDim2.new(0, 117, 0, 25)
        Instance.new("UICorner", Discordbutton)
        local TabImage_5 = Instance.new("ImageLabel")
        TabImage_5.Name = "TabImage"
        TabImage_5.Parent = Discordbutton
        TabImage_5.BackgroundTransparency = 1
        TabImage_5.Position = UDim2.new(0.0299999993, 0, 0.0799999982, 0)
        TabImage_5.Size = UDim2.new(0, 20, 0, 20)
        TabImage_5.Image = "rbxassetid://113749813889630"
        local TabName_5 = Instance.new("TextLabel")
        TabName_5.Name = "TabName"
        TabName_5.Parent = Discordbutton
        TabName_5.BackgroundTransparency = 1
        TabName_5.Position = UDim2.new(0.250999987, 0, 0.0799999982, 0)
        TabName_5.Size = UDim2.new(0, 84, 0, 20)
        TabName_5.Font = Enum.Font.SourceSansBold
        TabName_5.Text = "Discord"
        TabName_5.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName_5.TextSize = 16
        TabName_5.TextXAlignment = Enum.TextXAlignment.Left
        Discordbutton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if setclipboard then
                    setclipboard(config.discordURL)
                   
                    -- Создаем уведомление "Copied!" под курсором
                    local mousePos = UserInputService:GetMouseLocation()
                    local notification = Instance.new("TextLabel")
                    notification.Name = "CopiedNotification"
                    notification.Parent = ScreenGui
                    notification.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
                    notification.BorderSizePixel = 0
                    notification.Position = UDim2.new(0, mousePos.X - 25, 0, mousePos.Y - 30)
                    notification.Size = UDim2.new(0, 50, 0, 20)
                    notification.Font = Enum.Font.SourceSansBold
                    notification.Text = "Copied!"
                    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
                    notification.TextSize = 14
                    notification.ZIndex = 1000
                    Instance.new("UICorner", notification)
                   
                    -- Удаляем уведомление через 1 секунду
                    spawn(function()
                        wait(1)
                        if notification then
                            notification:Destroy()
                        end
                    end)
                end
            end
        end)
    end
    -- === ShowUI Bind ===
    local ShowUIbind = Instance.new("Frame")
    ShowUIbind.Name = "ShowUIbind"
    ShowUIbind.Parent = BaseUIconfigsZone
    ShowUIbind.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    ShowUIbind.BackgroundTransparency = 1
    ShowUIbind.BorderSizePixel = 0
    ShowUIbind.Size = UDim2.new(0, 117, 0, 26)
    Instance.new("UICorner", ShowUIbind)
    local TabImage_6 = Instance.new("ImageLabel")
    TabImage_6.Name = "TabImage"
    TabImage_6.Parent = ShowUIbind
    TabImage_6.BackgroundTransparency = 1
    TabImage_6.Position = UDim2.new(0.0385469608, 0, 0.233846813, 0)
    TabImage_6.Size = UDim2.new(0, 20, 0, 12)
    TabImage_6.Image = "rbxassetid://6975240170"
    local TabName_6 = Instance.new("TextLabel")
    TabName_6.Name = "TabName"
    TabName_6.Parent = ShowUIbind
    TabName_6.BackgroundTransparency = 1
    TabName_6.Position = UDim2.new(0.251000047, 0, 0.0799999982, 0)
    TabName_6.Size = UDim2.new(0, 41, 0, 20)
    TabName_6.Font = Enum.Font.SourceSansBold
    TabName_6.Text = "Visible"
    TabName_6.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabName_6.TextSize = 16
    TabName_6.TextXAlignment = Enum.TextXAlignment.Left
    local Key = Instance.new("TextLabel")
    Key.Name = "Key"
    Key.Parent = ShowUIbind
    Key.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    Key.BorderSizePixel = 0
    Key.Position = UDim2.new(0.661000013, 0, 0.100000001, 0)
    Key.Size = UDim2.new(0, 40, 0, 20)
    Key.Font = Enum.Font.SourceSansBold
    Key.Text = formatKeyName(keyBind.Name)
    Key.TextColor3 = Color3.fromRGB(255, 255, 255)
    Key.TextSize = 14
    Instance.new("UICorner", Key)
    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = Color3.fromRGB(39, 39, 42)
    keyStroke.Thickness = 1
    keyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    keyStroke.Parent = Key
    -- === Logo ===
    local logo = Instance.new("Frame")
    logo.Name = "logo"
    logo.Parent = MainFrame
    logo.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
    logo.BorderSizePixel = 0
    logo.Position = UDim2.new(0, 6, 0, 8)
    logo.Size = UDim2.new(0, 25, 0, 25)
    logo.ZIndex = 6
    Instance.new("UICorner", logo)
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = logo
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(1.27999997, 0, 0, -1)
    TextLabel.Size = UDim2.new(0, 77, 0, 25)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "PizdecWare"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 17
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    local P = Instance.new("TextLabel")
    P.Name = "P"
    P.Parent = logo
    P.BackgroundTransparency = 1
    P.Position = UDim2.new(0, -1, 0, -1)
    P.Size = UDim2.new(0, 13, 0, 25)
    P.Font = Enum.Font.SourceSansBold
    P.Text = "P"
    P.TextColor3 = Color3.fromRGB(255, 255, 255)
    P.TextSize = 16
    local W = Instance.new("TextLabel")
    W.Name = "W"
    W.Parent = logo
    W.BackgroundTransparency = 1
    W.Position = UDim2.new(0.400000006, 0, 0, -1)
    W.Size = UDim2.new(0, 13, 0, 25)
    W.Font = Enum.Font.SourceSansBold
    W.Text = "W"
    W.TextColor3 = Color3.fromRGB(0, 0, 0)
    W.TextSize = 16
    -- === Version ===
    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Parent = MainFrame
    Version.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
    Version.BorderSizePixel = 0
    Version.Position = UDim2.new(0.022807017, 0, 0.923684239, 0)
    Version.Size = UDim2.new(0, 103, 0, 18)
    Version.ZIndex = 7
    Version.Font = Enum.Font.SourceSansBold
    Version.Text = config.Info or "MTC V2.0"
    Version.TextColor3 = Color3.fromRGB(255, 255, 255)
    Version.TextSize = 16
    Instance.new("UICorner", Version)
    -- === UI Visibility ===
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == keyBind then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
            saveSettings(config.FileName or "ui_settings.json", settings)
        end
    end)
    local binding = false
    Key.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            binding = true
            Key.Text = "..."
        end
    end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if binding and not processed and input.KeyCode ~= Enum.KeyCode.Unknown then
            keyBind = input.KeyCode
            Key.Text = formatKeyName(keyBind.Name)
            settings.keyBind = keyBind
            saveSettings(config.FileName or "ui_settings.json", settings)
            binding = false
        end
    end)
    -- === Создание TabSection ===
    function ui:CreateTabSection(name)
        local tabSection = {}
        local yOffset = 0
        for _, section in pairs(tabSections) do
            yOffset = yOffset + section.Size.Y.Offset
        end
        local TabSection = Instance.new("Frame")
        TabSection.Name = name
        TabSection.Parent = Tabzone
        TabSection.BackgroundTransparency = 1
        TabSection.BorderSizePixel = 0
        TabSection.Position = UDim2.new(0.0474440344, 0, 0, yOffset)
        TabSection.Size = UDim2.new(0, 117, 0, 70)
        local TabSectionName = Instance.new("TextLabel")
        TabSectionName.Name = "TabSectionName"
        TabSectionName.Parent = TabSection
        TabSectionName.BackgroundTransparency = 1
        TabSectionName.Position = UDim2.new(0.029059777, 0, 0, 0)
        TabSectionName.Size = UDim2.new(0, 42, 0, 18)
        TabSectionName.Font = Enum.Font.SourceSansBold
        TabSectionName.Text = name
        TabSectionName.TextColor3 = Color3.fromRGB(113, 113, 123)
        TabSectionName.TextSize = 15
        TabSectionName.TextXAlignment = Enum.TextXAlignment.Left
        tabSections[#tabSections + 1] = TabSection
       
        -- Функция обновления размера секции
        local function updateTabSectionSize()
            local maxTabY = 18
            for _, tab in pairs(tabs) do
                if tab.section == TabSection then
                    maxTabY = maxTabY + 25
                end
            end
            TabSection.Size = UDim2.new(0, 117, 0, maxTabY + 5)
           
            -- Обновляем позиции всех секций
            local currentY = 0
            for i, section in pairs(tabSections) do
                section.Position = UDim2.new(0.0474440344, 0, 0, currentY)
                currentY = currentY + section.Size.Y.Offset
            end
           
            -- Обновляем CanvasSize для Tabzone
            Tabzone.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)
        end
        -- === Создание Tab в TabSection ===
        function tabSection:CreateTab(name, imageId)
            local tab = {}
            local sectionTabs = 0
            for _, existingTab in pairs(tabs) do
                if existingTab.section == TabSection then
                    sectionTabs = sectionTabs + 1
                end
            end
            local tabY = 18 + (sectionTabs * 25)
            local TabFrame = Instance.new("Frame")
            TabFrame.Name = name
            TabFrame.Parent = TabSection
            TabFrame.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
            TabFrame.BackgroundTransparency = 1
            TabFrame.BorderSizePixel = 0
            TabFrame.Position = UDim2.new(0, 0, 0, tabY)
            TabFrame.Size = UDim2.new(0, 117, 0, 25)
            Instance.new("UICorner", TabFrame)
            local TabImage = Instance.new("ImageLabel")
            TabImage.Name = "TabImage"
            TabImage.Parent = TabFrame
            TabImage.BackgroundTransparency = 1
            TabImage.Position = UDim2.new(0.0299999993, 0, 0.0799999982, 0)
            TabImage.Size = UDim2.new(0, 20, 0, 20)
            TabImage.Image = imageId or "rbxassetid://13587579249"
            TabImage.ImageColor3 = Color3.fromRGB(113, 113, 123)
            local TabNameLabel = Instance.new("TextLabel")
            TabNameLabel.Name = "TabName"
            TabNameLabel.Parent = TabFrame
            TabNameLabel.BackgroundTransparency = 1
            TabNameLabel.Position = UDim2.new(0.250999987, 0, 0.0799999982, 0)
            TabNameLabel.Size = UDim2.new(0, 84, 0, 20)
            TabNameLabel.Font = Enum.Font.SourceSansBold
            TabNameLabel.Text = name
            TabNameLabel.TextColor3 = Color3.fromRGB(113, 113, 123)
            TabNameLabel.TextSize = 16
            TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            local container = Instance.new("Frame")
            container.Name = name .. "Container"
            container.Parent = ElementContainer
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, 0, 1, 0)
            container.Visible = false
            tabs[#tabs + 1] = {frame = TabFrame, container = container, image = TabImage, label = TabNameLabel, section = TabSection}
            updateTabSectionSize()
            TabFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Закрываем все dropdown при переключении табов
                    for i = #_G.OpenDropdowns, 1, -1 do
                        local dropdown = _G.OpenDropdowns[i]
                        if dropdown and dropdown.Parent then
                            local button = _G.DropdownButtons[dropdown]
                            if button and _G.DropdownStates[button] then
                                _G.DropdownStates[button].imageLabel.Rotation = 270
                                _G.DropdownStates[button].open = false
                            end
                            dropdown:Destroy()
                        end
                        table.remove(_G.OpenDropdowns, i)
                    end
                   
                    for _, t in pairs(tabs) do
                        t.container.Visible = false
                        t.frame.BackgroundTransparency = 1
                        t.image.ImageColor3 = Color3.fromRGB(113, 113, 123)
                        t.label.TextColor3 = Color3.fromRGB(113, 113, 123)
                    end
                    TabFrame.BackgroundTransparency = 0
                    TabImage.ImageColor3 = Color3.fromRGB(150, 17, 255)
                    TabNameLabel.TextColor3 = Color3.fromRGB(150, 17, 255)
                    container.Visible = true
                    container.ZIndex = 10
                    currentTab = name
                    SelectedTabName.Text = name
                   
                    -- Обновляем CanvasSize при переключении табов
                    local maxY = 0
                    for _, child in pairs(container:GetChildren()) do
                        if child:IsA("Frame") and child.Name ~= "UICorner" then
                            local childBottom = child.Position.Y.Offset + child.Size.Y.Offset
                            maxY = math.max(maxY, childBottom)
                        end
                    end
                    ElementContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(maxY + 50, ElementContainer.AbsoluteSize.Y + 100))
                end
            end)
           
            TabFrame.MouseEnter:Connect(function()
                if currentTab ~= name then
                    TabFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 36)
                    TabFrame.BackgroundTransparency = 0
                    TabImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    TabNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end)
           
            TabFrame.MouseLeave:Connect(function()
                if currentTab ~= name then
                    TabFrame.BackgroundTransparency = 1
                    TabImage.ImageColor3 = Color3.fromRGB(113, 113, 123)
                    TabNameLabel.TextColor3 = Color3.fromRGB(113, 113, 123)
                end
            end)
            -- === Создание Section в Tab ===
            local leftSections = {}
            local rightSections = {}
           
            function tab:CreateSection(name, orientation)
                local section = {}
                local sectionFrame = Instance.new("Frame")
                sectionFrame.Name = name
                sectionFrame.Parent = container
                sectionFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
                sectionFrame.BorderSizePixel = 0
                sectionFrame.Size = orientation == "left" and UDim2.new(0, 198, 0, 35) or UDim2.new(0, 200, 0, 35)
                sectionFrame.ClipsDescendants = true
               
                if orientation == "left" then
                    local yPos = 18
                    for _, leftSection in ipairs(leftSections) do
                        yPos = yPos + leftSection.Size.Y.Offset + 10
                    end
                    sectionFrame.Position = UDim2.new(0, 15, 0, yPos)
                    table.insert(leftSections, sectionFrame)
                else
                    local yPos = 18
                    for _, rightSection in ipairs(rightSections) do
                        yPos = yPos + rightSection.Size.Y.Offset + 10
                    end
                    sectionFrame.Position = UDim2.new(0, 223, 0, yPos)
                    table.insert(rightSections, sectionFrame)
                end
               
                -- Обновляем размер canvas с запасом
                local maxY = math.max(leftSectionY or 18, rightSectionY or 18)
                ElementContainer.CanvasSize = UDim2.new(0, 0, 0, maxY + 200)
                ElementContainer.ScrollingEnabled = true
               
                Instance.new("UICorner", sectionFrame)
               
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(39, 39, 42)
                stroke.Thickness = 1
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = sectionFrame
                local Line = Instance.new("Frame")
                Line.Name = "Line"
                Line.Parent = sectionFrame
                Line.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
                Line.BorderSizePixel = 0
                Line.Position = UDim2.new(0, 0, 0, 30)
                Line.Size = UDim2.new(1, 0, 0, 1)
                local SectionName = Instance.new("TextLabel")
                SectionName.Name = "SectionName"
                SectionName.Parent = sectionFrame
                SectionName.BackgroundTransparency = 1
                SectionName.Position = UDim2.new(0, 8, 0, 6)
                SectionName.Size = UDim2.new(0, 100, 0, 18)
                SectionName.Font = Enum.Font.SourceSansBold
                SectionName.Text = name
                SectionName.TextColor3 = Color3.fromRGB(255, 255, 255)
                SectionName.TextSize = 18
                SectionName.TextXAlignment = Enum.TextXAlignment.Left
                local elementY = 35
                local elementHeight = 30
               
                local function updateSectionSize()
                    sectionFrame.Size = UDim2.new(sectionFrame.Size.X.Scale, sectionFrame.Size.X.Offset, 0, elementY + 5)
                   
                    -- Обновляем позиции всех секций после изменения размера
                    local leftY = 18
                    for _, leftSection in ipairs(leftSections) do
                        if leftSection and leftSection.Size then
                            leftSection.Position = UDim2.new(0, 15, 0, leftY)
                            leftY = leftY + leftSection.Size.Y.Offset + 10
                        end
                    end
                   
                    local rightY = 18
                    for _, rightSection in ipairs(rightSections) do
                        if rightSection and rightSection.Size then
                            rightSection.Position = UDim2.new(0, 223, 0, rightY)
                            rightY = rightY + rightSection.Size.Y.Offset + 10
                        end
                    end
                   
                    local maxY = math.max(leftY or 18, rightY or 18)
                    local canvasY = math.max(maxY + 50, (ElementContainer.AbsoluteSize and ElementContainer.AbsoluteSize.Y or 0) + 100)
                    ElementContainer.CanvasSize = UDim2.new(0, 0, 0, canvasY)
                end
                -- === TOGGLE ===
                function section:CreateToggle(name, default, callback, saveId)
                    local saveKey = saveId or name
                    local shouldSave = saveId ~= nil
                    local currentValue = shouldSave and (settings[saveKey] ~= nil and settings[saveKey] or default) or default
                   
                    local toggleZone = Instance.new("Frame")
                    toggleZone.Name = "ToggleZone"
                    toggleZone.Parent = sectionFrame
                    toggleZone.BackgroundTransparency = 1
                    toggleZone.Position = UDim2.new(0, 0, 0, elementY)
                    toggleZone.Size = UDim2.new(1, 0, 0, elementHeight)
                    local Toggle = Instance.new("TextButton")
                    Toggle.Name = "Toggle"
                    Toggle.Parent = toggleZone
                    Toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 31)
                    Toggle.BorderSizePixel = 0
                    local toggleStroke = Instance.new("UIStroke")
                    toggleStroke.Color = Color3.fromRGB(39, 39, 42)
                    toggleStroke.Thickness = 1
                    toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    toggleStroke.Parent = Toggle
                    Toggle.Position = UDim2.new(0.726999998, 0, 0.170000002, 0)
                    Toggle.Size = UDim2.new(0, 40, 0, 19)
                    Toggle.ZIndex = 7
                    Toggle.Text = ""
                    local UICorner_11 = Instance.new("UICorner")
                    UICorner_11.CornerRadius = UDim.new(1, 0)
                    UICorner_11.Parent = Toggle
                    local ToggleMove = Instance.new("TextButton")
                    ToggleMove.Name = "ToggleMove"
                    ToggleMove.Parent = Toggle
                    ToggleMove.BackgroundColor3 = currentValue and Color3.fromRGB(150, 17, 255) or Color3.fromRGB(80, 80, 86)
                    ToggleMove.BorderSizePixel = 0
                    ToggleMove.Position = currentValue and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
                    ToggleMove.Size = UDim2.new(0, 16, 0, 16)
                    ToggleMove.Text = ""
                    local UICorner_12 = Instance.new("UICorner")
                    UICorner_12.CornerRadius = UDim.new(1, 0)
                    UICorner_12.Parent = ToggleMove
                    local ToggleName = Instance.new("TextLabel")
                    ToggleName.Name = "ToggleName"
                    ToggleName.Parent = Toggle
                    ToggleName.BackgroundTransparency = 1
                    ToggleName.Position = UDim2.new(-3.25, 0, -0.100000083, 0)
                    ToggleName.Size = UDim2.new(0, 121, 0, 22)
                    ToggleName.Font = Enum.Font.SourceSansBold
                    ToggleName.Text = name
                    ToggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ToggleName.TextSize = 18
                    ToggleName.TextXAlignment = Enum.TextXAlignment.Left
                    local function toggleFunction()
                        currentValue = not currentValue
                        if shouldSave then
                            settings[saveKey] = currentValue
                            saveSettings(config.FileName or "ui_settings.json", settings)
                        end
                        ToggleMove.BackgroundColor3 = currentValue and Color3.fromRGB(150, 17, 255) or Color3.fromRGB(80, 80, 86)
                        ToggleMove.Position = currentValue and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
                        if callback then callback(currentValue) end
                    end
                   
                    Toggle.MouseButton1Click:Connect(toggleFunction)
                    ToggleMove.MouseButton1Click:Connect(toggleFunction)
                    -- Автовключение при загрузке
                    if currentValue and callback then
                        spawn(function() callback(currentValue) end)
                    end
                    elementY = elementY + elementHeight + 5
                    updateSectionSize()
                end
                -- === BUTTON ===
                local lastButtonPosition = nil
                local lastButtonY = nil
               
                function section:CreateButton(name, position, callback)
                    position = position or "left"
                    local currentY = elementY
                   
                    -- Если предыдущая кнопка была left, а текущая right - выравниваем на одном уровне
                    if lastButtonPosition == "left" and position == "right" then
                        currentY = lastButtonY
                    end
                   
                    local buttonZone = Instance.new("Frame")
                    buttonZone.Name = "ButtonZone"
                    buttonZone.Parent = sectionFrame
                    buttonZone.BackgroundTransparency = 1
                    buttonZone.Position = UDim2.new(0, 0, 0, currentY)
                    buttonZone.Size = UDim2.new(1, 0, 0, elementHeight)
                    local button = Instance.new("TextButton")
                    button.Name = name
                    button.Parent = buttonZone
                    button.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
                    button.BorderSizePixel = 0
                    local buttonStroke = Instance.new("UIStroke")
                    buttonStroke.Color = Color3.fromRGB(39, 39, 42)
                    buttonStroke.Thickness = 1
                    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    buttonStroke.Parent = button
                    button.Position = position == "left" and UDim2.new(0.0505050495, 0, 0.0666666701, 0) or UDim2.new(0.545454562, 0, 0.0666666701, 0)
                    button.Size = UDim2.new(0, 80, 0, 25)
                    button.ZIndex = 6
                    button.Font = Enum.Font.SourceSansBold
                    button.Text = name
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.TextSize = 15
                    Instance.new("UICorner", button)
                    button.MouseButton1Click:Connect(function()
                        if callback then callback() end
                    end)
                    -- Обновляем отслеживание позиций
                    lastButtonPosition = position
                    lastButtonY = currentY
                   
                    -- Увеличиваем elementY только если это не right кнопка после left
                    if not (lastButtonPosition == "left" and position == "right") then
                        elementY = currentY + elementHeight + 5
                    end
                   
                    updateSectionSize()
                end
                -- === BIND ===
                function section:CreateBind(name, defaultKey, callback, saveId)
                    local saveKey = saveId or name
                    local shouldSave = saveId ~= nil
                    local currentKey = shouldSave and (settings[saveKey] or defaultKey) or defaultKey
                    if shouldSave then
                        settings[saveKey] = currentKey
                    end
                    local bindZone = Instance.new("Frame")
                    bindZone.Name = "BindZone"
                    bindZone.Parent = sectionFrame
                    bindZone.BackgroundTransparency = 1
                    bindZone.Position = UDim2.new(0, 0, 0, elementY)
                    bindZone.Size = UDim2.new(1, 0, 0, elementHeight)
                    local BindName = Instance.new("TextLabel")
                    BindName.Name = "BindName"
                    BindName.Parent = bindZone
                    BindName.BackgroundTransparency = 1
                    BindName.Position = UDim2.new(0.0900000036, 0, 0.233333334, 0)
                    BindName.Size = UDim2.new(0, 93, 0, 16)
                    BindName.Font = Enum.Font.SourceSansBold
                    BindName.Text = name
                    BindName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    BindName.TextSize = 18
                    BindName.TextXAlignment = Enum.TextXAlignment.Left
                    local TextButton = Instance.new("TextButton")
                    TextButton.Name = "TextButton"
                    TextButton.Parent = bindZone
                    TextButton.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
                    TextButton.BorderSizePixel = 0
                    TextButton.Position = UDim2.new(0.639999986, 0, 0.166999996, 0)
                    TextButton.Size = UDim2.new(0, 60, 0, 20)
                    TextButton.Font = Enum.Font.SourceSansBold
                    TextButton.Text = formatKeyName(currentKey.Name)
                    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextButton.TextSize = 14
                    local bindCorner = Instance.new("UICorner")
                    bindCorner.Parent = TextButton
                    local bindStroke = Instance.new("UIStroke")
                    bindStroke.Color = Color3.fromRGB(39, 39, 42)
                    bindStroke.Thickness = 1
                    bindStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    bindStroke.Parent = TextButton
                    local binding = false
                    TextButton.MouseButton1Click:Connect(function()
                        binding = true
                        TextButton.Text = "..."
                    end)
                    UserInputService.InputBegan:Connect(function(input, processed)
                        if binding and not processed and input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode
                            if shouldSave then
                                settings[saveKey] = currentKey
                                saveSettings(config.FileName or "ui_settings.json", settings)
                            end
                            TextButton.Text = formatKeyName(currentKey.Name)
                            binding = false
                            if callback then callback(currentKey) end
                        end
                    end)
                    elementY = elementY + elementHeight + 5
                    updateSectionSize()
                end
                -- === DROPDOWN ===
                function section:CreateDropdown(name, options, default, callback, multi, search, saveId)
                    local dropdownData = {
                        options = options,
                        updateOptions = nil
                    }
                    local saveKey = saveId or name
                    if multi then
                        settings[saveKey] = settings[saveKey] or {}
                        if type(settings[saveKey]) ~= "table" then
                            settings[saveKey] = {}
                        end
                    else
                        settings[saveKey] = settings[saveKey] or default
                    end
                    local dropdownZone = Instance.new("Frame")
                    dropdownZone.Name = "DropdownZone"
                    dropdownZone.Parent = sectionFrame
                    dropdownZone.BackgroundTransparency = 1
                    dropdownZone.Position = UDim2.new(0, 0, 0, elementY)
                    dropdownZone.Size = UDim2.new(1, 0, 0, 50)
                    local CallDropdownListButton = Instance.new("TextButton")
                    CallDropdownListButton.Name = "CallDropdownListButton"
                    CallDropdownListButton.Parent = dropdownZone
                    CallDropdownListButton.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
                    CallDropdownListButton.BorderSizePixel = 0
                    CallDropdownListButton.Position = UDim2.new(0.100000001, 0, 0.5, 0)
                    CallDropdownListButton.Size = UDim2.new(0, 160, 0, 20)
                    CallDropdownListButton.Font = Enum.Font.SourceSansBold
                    CallDropdownListButton.Text = ""
                    CallDropdownListButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    CallDropdownListButton.TextSize = 18
                    local dropdownCorner = Instance.new("UICorner")
                    dropdownCorner.CornerRadius = UDim.new(0, 6)
                    dropdownCorner.Parent = CallDropdownListButton
                    local dropdownStroke = Instance.new("UIStroke")
                    dropdownStroke.Color = Color3.fromRGB(39, 39, 42)
                    dropdownStroke.Thickness = 1
                    dropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    dropdownStroke.Parent = CallDropdownListButton
                    local Selected = Instance.new("TextLabel")
                    Selected.Name = "Selected"
                    Selected.Parent = CallDropdownListButton
                    Selected.BackgroundTransparency = 1
                    Selected.Position = UDim2.new(0.03125, 0, 0.100000001, 0)
                    Selected.Size = UDim2.new(0, 15, 0, 15)
                    Selected.Font = Enum.Font.SourceSansBold
                    if multi then
                        Selected.Text = #settings[saveKey] > 0 and "Selected: " .. #settings[saveKey] or "None"
                    else
                        Selected.Text = settings[saveKey]
                    end
                    Selected.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Selected.TextSize = 14
                    Selected.TextXAlignment = Enum.TextXAlignment.Left
                   
                    local searchBox
                    if search then
                        searchBox = Instance.new("TextBox")
                        searchBox.Name = "SearchBox"
                        searchBox.Parent = CallDropdownListButton
                        searchBox.BackgroundTransparency = 1
                        searchBox.Position = UDim2.new(0.03125, 0, 0.100000001, 0)
                        searchBox.Size = UDim2.new(0, 120, 0, 15)
                        searchBox.Font = Enum.Font.SourceSansBold
                        searchBox.Text = ""
                        searchBox.PlaceholderText = "Search..."
                        searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                        searchBox.PlaceholderColor3 = Color3.fromRGB(113, 113, 123)
                        searchBox.TextSize = 14
                        searchBox.TextXAlignment = Enum.TextXAlignment.Left
                        searchBox.ClearTextOnFocus = false
                        searchBox.Visible = false
                    end
                    local ImageLabel = Instance.new("ImageLabel")
                    ImageLabel.Parent = CallDropdownListButton
                    ImageLabel.BackgroundTransparency = 1
                    ImageLabel.Position = search and UDim2.new(0.737500012, 0, 0.100000001, 0) or UDim2.new(0.862500012, 0, 0.100000001, 0)
                    ImageLabel.Rotation = 270
                    ImageLabel.Size = UDim2.new(0, 15, 0, 15)
                    ImageLabel.Image = "rbxassetid://4726772330"
                   
                    local searchButton
                    local searchMode = false
                    local originalOptions = dropdownData.options
                   
                    if search then
                        searchButton = Instance.new("ImageButton")
                        searchButton.Parent = CallDropdownListButton
                        searchButton.BackgroundTransparency = 1
                        searchButton.Position = UDim2.new(0.862500012, 0, 0.100000001, 0)
                        searchButton.Size = UDim2.new(0, 15, 0, 15)
                        searchButton.Image = "rbxassetid://118685771787843"
                       
                        searchButton.MouseButton1Click:Connect(function()
                            searchMode = true
                            Selected.Visible = false
                            searchBox.Visible = true
                            searchBox:CaptureFocus()
                        end)
                    end
                    local DropdownName = Instance.new("TextLabel")
                    DropdownName.Name = "DropdownName"
                    DropdownName.Parent = dropdownZone
                    DropdownName.BackgroundTransparency = 1
                    DropdownName.Position = UDim2.new(0.100000001, 0, 0, 5)
                    DropdownName.Size = UDim2.new(0, 20, 0, 10)
                    DropdownName.Font = Enum.Font.SourceSansBold
                    DropdownName.Text = name
                    DropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    DropdownName.TextSize = 14
                    DropdownName.TextXAlignment = Enum.TextXAlignment.Left
                    local dropdownOpen = false
                    local dropdownList = nil
                    _G.DropdownStates = _G.DropdownStates or {}
                    _G.DropdownStates[CallDropdownListButton] = {open = false, imageLabel = ImageLabel}
                   
                    CallDropdownListButton.MouseButton1Click:Connect(function()
                        -- Если в режиме поиска, выходим из него
                        if search and searchMode and not _G.DropdownStates[CallDropdownListButton].open then
                            searchMode = false
                            Selected.Visible = true
                            searchBox.Visible = false
                            searchBox.Text = ""
                        end
                       
                        if _G.DropdownStates[CallDropdownListButton].open then
                            if dropdownList then
                                dropdownList:Destroy()
                                dropdownList = nil
                            end
                            ElementContainer.ScrollingEnabled = true
                            ImageLabel.Rotation = 270
                            _G.DropdownStates[CallDropdownListButton].open = false
                           
                            -- Выходим из режима поиска
                            if search and searchMode then
                                searchMode = false
                                Selected.Visible = true
                                searchBox.Visible = false
                                searchBox.Text = ""
                            end
                        else
                            -- Сбрасываем поиск при открытии
                            if search then
                                searchMode = false
                                Selected.Visible = true
                                searchBox.Visible = false
                                searchBox.Text = ""
                            end
                            ImageLabel.Rotation = 90
                            dropdownList = Instance.new("ScrollingFrame")
                            dropdownList.Name = "DropdownList"
                            dropdownList.Parent = ScreenGui
                            dropdownList.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
                            dropdownList.Position = UDim2.new(0, CallDropdownListButton.AbsolutePosition.X, 0, CallDropdownListButton.AbsolutePosition.Y + 25)
                            dropdownList.Size = UDim2.new(0, 160, 0, 100)
                            dropdownList.CanvasSize = UDim2.new(0, 0, 0, #dropdownData.options * 25)
                            dropdownList.ScrollBarThickness = 3
                            dropdownList.ScrollBarImageColor3 = Color3.fromRGB(150, 17, 255)
                            dropdownList.ScrollingEnabled = false
                            dropdownList.ZIndex = 100
                           
                            local scrollOffset = 0
                            local maxScroll = math.max(0, (#dropdownData.options - 4) * 25)
                            local connections = {}
                           
                            -- Обновляем позицию dropdown при скроллинге
                            local updatePosition
                            updatePosition = RunService.Heartbeat:Connect(function()
                                if dropdownList and dropdownList.Parent and CallDropdownListButton and CallDropdownListButton.Parent then
                                    dropdownList.Position = UDim2.new(0, CallDropdownListButton.AbsolutePosition.X, 0, CallDropdownListButton.AbsolutePosition.Y + 25)
                                else
                                    updatePosition:Disconnect()
                                end
                            end)
                           
                            -- Блокируем скроллинг основного контейнера
                            local mouseEnterConn = dropdownList.MouseEnter:Connect(function()
                                ElementContainer.ScrollingEnabled = false
                            end)
                           
                            local mouseLeaveConn = dropdownList.MouseLeave:Connect(function()
                                ElementContainer.ScrollingEnabled = true
                            end)
                            
                            -- Добавляем соединения в список для очистки
                            table.insert(connections, mouseEnterConn)
                            table.insert(connections, mouseLeaveConn)
                           
                           
                            -- Скроллинг по 1 опции с двойной обработкой
                            local function handleScroll(input)
                                if input.UserInputType == Enum.UserInputType.MouseWheel and dropdownList and dropdownList.Parent then
                                    local mousePos = UserInputService:GetMouseLocation()
                                    local dropPos = dropdownList.AbsolutePosition
                                    local dropSize = dropdownList.AbsoluteSize
                                   
                                    if mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and
                                       mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y then
                                        local scrollAmount = input.Position.Z > 0 and -25 or 25
                                        scrollOffset = math.clamp(scrollOffset + scrollAmount, 0, maxScroll)
                                        dropdownList.CanvasPosition = Vector2.new(0, scrollOffset)
                                    end
                                end
                            end
                           
                            local scrollConnection1 = UserInputService.InputChanged:Connect(handleScroll)
                            local scrollConnection2 = UserInputService.InputBegan:Connect(handleScroll)
                            local scrollConnection3 = UserInputService.InputEnded:Connect(handleScroll)
                           
                            -- Дополнительная обработка прямо на дропдауне
                            local dropdownScrollConnection = dropdownList.InputChanged:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseWheel then
                                    local scrollAmount = input.Position.Z > 0 and -25 or 25
                                    scrollOffset = math.clamp(scrollOffset + scrollAmount, 0, maxScroll)
                                    dropdownList.CanvasPosition = Vector2.new(0, scrollOffset)
                                end
                            end)
                           
                            -- Очистка соединений при закрытии
                            spawn(function()
                                while dropdownList and dropdownList.Parent do
                                    wait()
                                end
                                ElementContainer.ScrollingEnabled = true
                                for _, conn in pairs(connections) do
                                    if conn then conn:Disconnect() end
                                end
                                if scrollConnection1 then scrollConnection1:Disconnect() end
                                if scrollConnection2 then scrollConnection2:Disconnect() end
                                if scrollConnection3 then scrollConnection3:Disconnect() end
                                if dropdownScrollConnection then dropdownScrollConnection:Disconnect() end
                            end)
                            table.insert(_G.OpenDropdowns, dropdownList)
                            _G.DropdownButtons[dropdownList] = CallDropdownListButton
                            
                            -- Обработчик поиска для нового дропдауна
                            if search then
                                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                                    local searchText = searchBox.Text or ""
                                    searchText = string.lower(searchText)
                                    local visibleOptions = {}
                                    
                                    for _, child in pairs(dropdownList:GetChildren()) do
                                        if child:IsA("TextButton") and string.find(child.Name, "Option") then
                                            local optionText = child.Text or ""
                                            optionText = string.lower(optionText)
                                            
                                            local shouldShow = false
                                            if searchText == "" then
                                                shouldShow = true
                                            else
                                                shouldShow = string.find(optionText, searchText, 1, true) ~= nil
                                            end
                                            
                                            child.Visible = shouldShow
                                            if shouldShow then
                                                table.insert(visibleOptions, child)
                                            end
                                        end
                                    end
                                    
                                    for i, option in ipairs(visibleOptions) do
                                        option.Position = UDim2.new(0, 0, 0, (i-1) * 25)
                                    end
                                end)
                            end
                            
                            Instance.new("UICorner", dropdownList)
                            local listStroke = Instance.new("UIStroke")
                            listStroke.Color = Color3.fromRGB(39, 39, 42)
                            listStroke.Thickness = 1
                            listStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                            listStroke.Parent = dropdownList
                           
                            for i, option in ipairs(dropdownData.options) do
                                local optionButton = Instance.new("TextButton")
                                optionButton.Name = "Option" .. i
                                optionButton.Parent = dropdownList
                                optionButton.BackgroundTransparency = 1
                                optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
                                optionButton.Size = UDim2.new(1, 0, 0, 25)
                                optionButton.Font = Enum.Font.SourceSansBold
                                optionButton.Text = option
                                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                optionButton.TextSize = 14
                                local isSelected = multi and table.find(settings[saveKey], option) or settings[saveKey] == option
                                if isSelected then
                                    optionButton.TextColor3 = Color3.fromRGB(150, 17, 255)
                                end
                               
                                optionButton.MouseEnter:Connect(function()
                                    if not isSelected then
                                        optionButton.BackgroundColor3 = Color3.fromRGB(33, 33, 36)
                                        optionButton.BackgroundTransparency = 0
                                    end
                                end)
                               
                                optionButton.MouseLeave:Connect(function()
                                    optionButton.BackgroundTransparency = 1
                                end)
                               
                                optionButton.MouseButton1Click:Connect(function()
                                    if multi then
                                        local index = table.find(settings[saveKey], option)
                                        if index then
                                            table.remove(settings[saveKey], index)
                                        else
                                            table.insert(settings[saveKey], option)
                                        end
                                        local newSelected = table.find(settings[saveKey], option)
                                        optionButton.TextColor3 = newSelected and Color3.fromRGB(150, 17, 255) or Color3.fromRGB(255, 255, 255)
                                        Selected.Text = #settings[saveKey] > 0 and "Selected: " .. #settings[saveKey] or "None"
                                        if callback then callback(settings[saveKey]) end
                                    else
                                        settings[saveKey] = option
                                        Selected.Text = option
                                        if searchMode then
                                            searchMode = false
                                            Selected.Visible = true
                                            searchBox.Visible = false
                                            searchBox.Text = ""
                                        end
                                        dropdownList:Destroy()
                                        dropdownList = nil
                                        ImageLabel.Rotation = 270
                                        _G.DropdownStates[CallDropdownListButton].open = false
                                        if callback then callback(option) end
                                    end
                                    saveSettings(config.FileName or "ui_settings.json", settings)
                                end)
                            end
                           
                            -- Применяем фильтр при открытии
                            if searchMode and searchBox.Text ~= "" then
                                local searchText = string.lower(searchBox.Text)
                                for _, child in pairs(dropdownList:GetChildren()) do
                                    if child:IsA("TextButton") and string.find(child.Name, "Option") then
                                        local optionText = string.lower(child.Text)
                                        child.Visible = string.find(optionText, searchText, 1, true) ~= nil
                                    end
                                end
                            end
                            _G.DropdownStates[CallDropdownListButton].open = true
                        end
                    end)
                    -- Функция обновления опций
                    dropdownData.updateOptions = function(newOptions)
                        dropdownData.options = newOptions
                       
                        -- Очищаем выбранные опции которых больше нет в списке
                        if multi then
                            local validSelected = {}
                            for _, selected in ipairs(settings[saveKey]) do
                                if table.find(newOptions, selected) then
                                    table.insert(validSelected, selected)
                                end
                            end
                            settings[saveKey] = validSelected
                           
                            -- Обновляем отображение
                            Selected.Text = #settings[saveKey] > 0 and "Selected: " .. #settings[saveKey] or "None"
                           
                            saveSettings(config.FileName or "ui_settings.json", settings)
                        end
                    end
                   
                    elementY = elementY + 55
                    updateSectionSize()
                   
                    return dropdownData
                end
                -- === SLIDER ===
                function section:CreateSlider(name, min, max, default, callback, saveId)
                    local saveKey = saveId or name
                    local shouldSave = saveId ~= nil
                    local currentValue = shouldSave and (settings[saveKey] or default) or default
                    local sliderZone = Instance.new("Frame")
                    sliderZone.Name = "SliderZone"
                    sliderZone.Parent = sectionFrame
                    sliderZone.BackgroundTransparency = 1
                    sliderZone.Position = UDim2.new(0, 0, 0, elementY)
                    sliderZone.Size = UDim2.new(1, 0, 0, 35)
                    local SliderLine = Instance.new("Frame")
                    SliderLine.Name = "SliderLine"
                    SliderLine.Parent = sliderZone
                    SliderLine.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
                    SliderLine.BorderSizePixel = 0
                    SliderLine.Position = UDim2.new(0.100000001, 0, 0.649999976, 0)
                    SliderLine.Size = UDim2.new(0, 160, 0, 5)
                    local UICorner_20 = Instance.new("UICorner")
                    UICorner_20.CornerRadius = UDim.new(1, 0)
                    UICorner_20.Parent = SliderLine
                   
                    local sliderStroke = Instance.new("UIStroke")
                    sliderStroke.Color = Color3.fromRGB(39, 39, 42)
                    sliderStroke.Thickness = 1
                    sliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    sliderStroke.Parent = SliderLine
                   
                    local SliderFill = Instance.new("Frame")
                    SliderFill.Name = "SliderFill"
                    SliderFill.Parent = SliderLine
                    SliderFill.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
                    SliderFill.BorderSizePixel = 0
                    SliderFill.Position = UDim2.new(0, 0, 0, 0)
                    SliderFill.Size = UDim2.new((currentValue - min)/(max - min), 0, 1, 0)
                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(1, 0)
                    fillCorner.Parent = SliderFill
                    local SliderVover = Instance.new("TextButton")
                    SliderVover.Name = "SliderVover"
                    SliderVover.Parent = SliderLine
                    SliderVover.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
                    SliderVover.BorderSizePixel = 0
                    SliderVover.Position = UDim2.new((currentValue - min)/(max - min), 0, -0.8, 0)
                    SliderVover.Size = UDim2.new(0, 12, 0, 12)
                    SliderVover.Text = ""
                    local UICorner_21 = Instance.new("UICorner")
                    UICorner_21.CornerRadius = UDim.new(1, 0)
                    UICorner_21.Parent = SliderVover
                    local SliderName = Instance.new("TextLabel")
                    SliderName.Name = "SliderName"
                    SliderName.Parent = SliderLine
                    SliderName.BackgroundTransparency = 1
                    SliderName.Position = UDim2.new(0, 0, -4.4000001, 0)
                    SliderName.Size = UDim2.new(0, 15, 0, 18)
                    SliderName.Font = Enum.Font.SourceSansBold
                    SliderName.Text = name
                    SliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderName.TextSize = 16
                    SliderName.TextXAlignment = Enum.TextXAlignment.Left
                    local SliderValue = Instance.new("TextLabel")
                    SliderValue.Name = "SliderValue"
                    SliderValue.Parent = SliderLine
                    SliderValue.BackgroundTransparency = 1
                    SliderValue.Position = UDim2.new(0.9375, 0, -4.4000001, 0)
                    SliderValue.Size = UDim2.new(0, 10, 0, 18)
                    SliderValue.Font = Enum.Font.SourceSansBold
                    SliderValue.Text = tostring(currentValue)
                    SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderValue.TextSize = 16
                    SliderValue.TextXAlignment = Enum.TextXAlignment.Left
                    local dragging = false
                    SliderVover.MouseButton1Down:Connect(function()
                        dragging = true
                    end)
                    RunService.RenderStepped:Connect(function()
                        if dragging then
                            local mousePos = UserInputService:GetMouseLocation()
                            local relativePos = (mousePos.X - SliderLine.AbsolutePosition.X) / SliderLine.AbsoluteSize.X
                            relativePos = math.clamp(relativePos, 0, 1)
                            local value = min + (max - min) * relativePos
                            value = math.floor(value)
                            SliderVover.Position = UDim2.new(relativePos, 0, -0.8, 0)
                            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                            SliderValue.Text = tostring(value)
                            if shouldSave then
                                settings[saveKey] = value
                                saveSettings(config.FileName or "ui_settings.json", settings)
                            end
                            if callback then callback(value) end
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    elementY = elementY + 40
                    updateSectionSize()
                end
                -- === INPUT ===
                function section:CreateInput(name, placeholder, default, callback, saveId)
                    local saveKey = saveId or name
                    local shouldSave = saveId ~= nil
                    local currentValue = shouldSave and (settings[saveKey] or default) or default
                    
                    -- Проверка на nil
                    if currentValue == nil then
                        currentValue = default or ""
                    end
                    local inputZone = Instance.new("Frame")
                    inputZone.Name = "InputZone"
                    inputZone.Parent = sectionFrame
                    inputZone.BackgroundTransparency = 1
                    inputZone.Position = UDim2.new(0, 0, 0, elementY)
                    inputZone.Size = UDim2.new(1, 0, 0, 35)
                    local InputBox = Instance.new("TextBox")
                    InputBox.Name = "InputBox"
                    InputBox.Parent = inputZone
                    InputBox.BackgroundColor3 = Color3.fromRGB(28, 28, 31)
                    InputBox.BorderSizePixel = 0
                    InputBox.Position = UDim2.new(0.0505050495, 0, 0.114286147, 0)
                    InputBox.Size = UDim2.new(0, 178, 0, 25)
                    InputBox.Font = Enum.Font.SourceSans
                    InputBox.PlaceholderText = placeholder
                    InputBox.PlaceholderColor3 = Color3.fromRGB(113, 113, 123)
                    InputBox.Text = tostring(currentValue or "")
                    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    InputBox.TextSize = 14
                    InputBox.TextXAlignment = Enum.TextXAlignment.Left
                    local inputCorner = Instance.new("UICorner")
                    inputCorner.CornerRadius = UDim.new(0, 6)
                    inputCorner.Parent = InputBox
                    local inputStroke = Instance.new("UIStroke")
                    inputStroke.Color = Color3.fromRGB(39, 39, 42)
                    inputStroke.Thickness = 1
                    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    inputStroke.Parent = InputBox
                   
                    -- Добавляем отступ текста на 10 пикселей
                    local inputPadding = Instance.new("UIPadding")
                    inputPadding.PaddingLeft = UDim.new(0, 10)
                    inputPadding.Parent = InputBox
                    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        if shouldSave then
                            settings[saveKey] = InputBox.Text
                            saveSettings(config.FileName or "ui_settings.json", settings)
                        end
                        if callback then callback(InputBox.Text) end
                    end)
                    elementY = elementY + 40
                    updateSectionSize()
                end
                return section
            end
            -- Автооткрытие первого таба
            if #tabs == 1 then
                TabFrame.BackgroundTransparency = 0
                TabImage.ImageColor3 = Color3.fromRGB(150, 17, 255)
                TabNameLabel.TextColor3 = Color3.fromRGB(150, 17, 255)
                container.Visible = true
                container.ZIndex = 10
                currentTab = name
                SelectedTabName.Text = name
               
                -- Обновляем CanvasSize для первого таба
                spawn(function()
                    wait(0.1)
                    local maxY = 0
                    for _, child in pairs(container:GetChildren()) do
                        if child:IsA("Frame") and child.Name ~= "UICorner" then
                            local childBottom = child.Position.Y.Offset + child.Size.Y.Offset
                            maxY = math.max(maxY, childBottom)
                        end
                    end
                    ElementContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(maxY + 50, ElementContainer.AbsoluteSize.Y + 100))
                end)
            end
            return tab
        end
        return tabSection
    end
    return ui
end
-- Экспорт глобальных функций
_G.CreateToggle = CreateToggle
_G.CreateButton = CreateButton
_G.CreateBind = CreateBind
_G.CreateDropdown = CreateDropdown
_G.CreateSlider = CreateSlider
_G.CreateInput = CreateInput
return UILibrary
