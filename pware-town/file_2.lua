local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Настройки
local UI_LIFETIME = 100 -- Время жизни UI в секундах (можно менять)
local STATUS_CHECK_INTERVAL = 0.1 -- Интервал проверки статуса
local DOT_ANIMATION_SPEED = 2 -- Скорость анимации точек (0.3 секунды на каждую точку)

-- Создаем основной ScreenGui в CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LoadingGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Создаем основной фрейм Loading с фиолетовой обводкой
local Loading = Instance.new("Frame")
Loading.Name = "Loading"
Loading.Parent = ScreenGui
Loading.BackgroundColor3 = Color3.fromRGB(19, 21, 25)
Loading.BorderColor3 = Color3.fromRGB(150, 17, 255) -- Фиолетовая обводка
Loading.BorderSizePixel = 1 -- Толщина 1
Loading.Position = UDim2.new(0.5, -100, 0.5, -60) -- По центру экрана
Loading.Size = UDim2.new(0, 200, 0, 120)
Loading.BackgroundTransparency = 1 -- Начинаем с прозрачности
Loading.ClipsDescendants = true -- Обрезаем элементы выходящие за границы

-- Создаем градиент
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.99, Color3.fromRGB(90, 99, 118)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
}
UIGradient.Offset = Vector2.new(-1, 0) -- Начинаем слева
UIGradient.Parent = Loading

-- Создаем Logo
local Logo = Instance.new("Frame")
Logo.Name = "Logo"
Logo.Parent = Loading
Logo.BackgroundColor3 = Color3.fromRGB(150, 17, 255)
Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0.141592711, 0, 0.288935333, 0)
Logo.Size = UDim2.new(0, 25, 0, 25)
Logo.ZIndex = 3
Logo.BackgroundTransparency = 1
Logo.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.Parent = Logo

local W = Instance.new("TextLabel")
W.Name = "W"
W.Parent = Logo
W.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
W.BackgroundTransparency = 1.000
W.BorderColor3 = Color3.fromRGB(255, 255, 255)
W.BorderSizePixel = 0
W.Position = UDim2.new(0.25, 0, 0.75999999, 0)
W.Size = UDim2.new(0, 23, 0, -14)
W.ZIndex = 4
W.Font = Enum.Font.SourceSansBold
W.Text = "W"
W.TextColor3 = Color3.fromRGB(0, 0, 0)
W.TextSize = 18.000
W.TextTransparency = 1

local PizdecWare = Instance.new("TextLabel")
PizdecWare.Name = "PizdecWare"
PizdecWare.Parent = Logo
PizdecWare.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PizdecWare.BackgroundTransparency = 1.000
PizdecWare.BorderColor3 = Color3.fromRGB(255, 255, 255)
PizdecWare.BorderSizePixel = 0
PizdecWare.Position = UDim2.new(2.21097422, 0, 1.29638064, 0)
PizdecWare.Size = UDim2.new(0, 60, 0, -41)
PizdecWare.ZIndex = 4
PizdecWare.Font = Enum.Font.SourceSansBold
PizdecWare.Text = "PizdecWare"
PizdecWare.TextColor3 = Color3.fromRGB(150, 17, 255)
PizdecWare.TextSize = 25.000
PizdecWare.TextTransparency = 1

local P = Instance.new("TextLabel")
P.Name = "P"
P.Parent = Logo
P.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
P.BackgroundTransparency = 1.000
P.BorderColor3 = Color3.fromRGB(255, 255, 255)
P.BorderSizePixel = 0
P.Position = UDim2.new(-0.304138184, 0, 0.75999999, 0)
P.Size = UDim2.new(0, 27, 0, -14)
P.ZIndex = 4
P.Font = Enum.Font.SourceSansBold
P.Text = "P"
P.TextColor3 = Color3.fromRGB(255, 255, 255)
P.TextSize = 18.000
P.TextTransparency = 1

local PizdecDevelopers = Instance.new("TextLabel")
PizdecDevelopers.Name = "PizdecDevelopers"
PizdecDevelopers.Parent = Logo
PizdecDevelopers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PizdecDevelopers.BackgroundTransparency = 1.000
PizdecDevelopers.BorderColor3 = Color3.fromRGB(255, 255, 255)
PizdecDevelopers.BorderSizePixel = 0
PizdecDevelopers.Position = UDim2.new(1.77600002, 0, 1.20000005, 0)
PizdecDevelopers.Size = UDim2.new(0, 95, 0, -7)
PizdecDevelopers.ZIndex = 4
PizdecDevelopers.Font = Enum.Font.SourceSansBold
PizdecDevelopers.Text = "<Pizdec/Developers>"
PizdecDevelopers.TextColor3 = Color3.fromRGB(150, 17, 255)
PizdecDevelopers.TextSize = 12.000
PizdecDevelopers.TextTransparency = 1

-- Создаем Load frame
local Load = Instance.new("Frame")
Load.Name = "Load"
Load.Parent = Loading
Load.BackgroundColor3 = Color3.fromRGB(52, 57, 68)
Load.BorderColor3 = Color3.fromRGB(0, 0, 0)
Load.BorderSizePixel = 0
Load.Position = UDim2.new(0.25, 0, 0.823333204, 0)
Load.Size = UDim2.new(0, 100, 0, 4)
Load.BackgroundTransparency = 1
Load.Visible = false
Load.ClipsDescendants = true -- Обрезаем ползунок который выходит за границы

-- Создаем AnimationLine (маленькая линия для анимации загрузки)
local AnimationLine = Instance.new("Frame")
AnimationLine.Name = "AnimationLine"
AnimationLine.Parent = Load
AnimationLine.BackgroundColor3 = Color3.fromRGB(134, 148, 175)
AnimationLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
AnimationLine.BorderSizePixel = 0
AnimationLine.Position = UDim2.new(0, -30, 0, 0) -- Начинаем слева за пределами
AnimationLine.Size = UDim2.new(0, 30, 0, 4)
AnimationLine.BackgroundTransparency = 0.14

local UIGradient_2 = Instance.new("UIGradient")
UIGradient_2.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0.00, 1.00),
    NumberSequenceKeypoint.new(0.30, 0.49),
    NumberSequenceKeypoint.new(1.00, 0.00)
}
UIGradient_2.Parent = AnimationLine

-- Создаем LoadStatus
local LoadStatus = Instance.new("TextLabel")
LoadStatus.Name = "LoadStatus"
LoadStatus.Parent = Loading
LoadStatus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadStatus.BackgroundTransparency = 1.000
LoadStatus.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadStatus.BorderSizePixel = 0
LoadStatus.Position = UDim2.new(0.349999994, 0, 0.649999976, 0)
LoadStatus.Size = UDim2.new(0, 60, 0, 20)
LoadStatus.Font = Enum.Font.SourceSans
LoadStatus.Text = "Start...."
LoadStatus.TextColor3 = Color3.fromRGB(147, 152, 156)
LoadStatus.TextSize = 12.000
LoadStatus.TextTransparency = 1
LoadStatus.Visible = false

-- Функция для создания твинов
local function createTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Linear, easingDirection or Enum.EasingDirection.Out)
    return TweenService:Create(object, tweenInfo, properties)
end

-- Переменные для контроля анимации
local isUIVisible = true
local statusConnection = nil
local dotAnimationTime = 0
local dotAnimationStage = 0

-- Функция для обновления текста статуса
local function updateStatusText()
    if not isUIVisible or not LoadStatus then return end

    local statusText = "Start"
    if _G.Status then
        statusText = tostring(_G.Status)
    end

    -- Проверяем, заканчивается ли текст на "..."
    local hasDots = string.sub(statusText, -3) == "..."
    local baseText = statusText

    if hasDots then
        -- Убираем троеточие для базового текста
        baseText = string.sub(statusText, 1, -4)
    end

    if hasDots then
        -- Анимация троеточия: . -> .. -> ... -> (цикл)
        dotAnimationTime = dotAnimationTime + STATUS_CHECK_INTERVAL

        if dotAnimationTime >= DOT_ANIMATION_SPEED then
            dotAnimationTime = 0
            dotAnimationStage = (dotAnimationStage + 1) % 4
        end

        if dotAnimationStage == 0 then
            LoadStatus.Text = baseText .. "."
        elseif dotAnimationStage == 1 then
            LoadStatus.Text = baseText .. ".."
        elseif dotAnimationStage == 2 then
            LoadStatus.Text = baseText .. "..."
        else
            LoadStatus.Text = baseText .. "." -- Начинаем цикл заново
            dotAnimationStage = 0
        end
    else
        -- Без анимации, просто устанавливаем текст
        LoadStatus.Text = statusText
        dotAnimationTime = 0
        dotAnimationStage = 0
    end
end

-- Функция для анимации линии загрузки
local function startLoadingLineAnimation()
    local animationSpeed = 1.5 -- 1.5 секунды на один цикл

    -- Функция для одного цикла анимации
    local function runAnimationCycle()
        if not isUIVisible then return end

        -- Начинаем слева за пределами видимой области
        AnimationLine.Position = UDim2.new(0, -30, 0, 0)

        -- Анимация движения слева направо
        local lineTween = createTween(AnimationLine, {
            Position = UDim2.new(0, Load.AbsoluteSize.X, 0, 0)
        }, animationSpeed, Enum.EasingStyle.Linear)

        lineTween:Play()

        lineTween.Completed:Connect(function()
            if isUIVisible then
                -- Повторяем анимацию
                runAnimationCycle()
            end
        end)
    end

    -- Запускаем проверку статуса
    statusConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isUIVisible then
            if statusConnection then
                statusConnection:Disconnect()
            end
            return
        end

        updateStatusText()
    end)

    -- Запускаем первый цикл анимации
    runAnimationCycle()
end

-- Основная функция анимации загрузки
local function startLoadingAnimation()
    -- Анимация появления фрейма Loading с обводкой
    local frameAppearTween = createTween(Loading, {BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Quad)
    frameAppearTween:Play()

    frameAppearTween.Completed:Connect(function()
        -- Анимация движения градиента слева направо (останавливается у правого края)
        local gradientTween = createTween(UIGradient, {Offset = Vector2.new(0, 0)}, 1, Enum.EasingStyle.Quad)
        gradientTween:Play()

        gradientTween.Completed:Connect(function()
            -- Градиент остается у правого края UI
            UIGradient.Offset = Vector2.new(0, 0)

            -- Показываем и анимируем все остальные элементы
            Load.Visible = true
            LoadStatus.Visible = true
            Logo.Visible = true

            -- Анимация появления Load
            local loadTween = createTween(Load, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
            loadTween:Play()

            -- Анимация появления LoadStatus
            local statusTween = createTween(LoadStatus, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
            statusTween:Play()

            -- Анимация появления Logo и его дочерних элементов
            local logoTween = createTween(Logo, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
            logoTween:Play()

            local wTween = createTween(W, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
            local pTween = createTween(P, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
            local wareTween = createTween(PizdecWare, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
            local devTween = createTween(PizdecDevelopers, {TextTransparency = 0}, 0.3, Enum.EasingStyle.Quad)

            wTween:Play()
            pTween:Play()
            wareTween:Play()
            devTween:Play()

            -- Запускаем анимацию линии загрузки
            startLoadingLineAnimation()

            -- Устанавливаем таймер жизни UI
            delay(UI_LIFETIME, function()
                if isUIVisible then
                    isUIVisible = false

                    -- Отключаем соединения
                    if statusConnection then
                        statusConnection:Disconnect()
                    end

                    -- Анимация исчезновения всех элементов
                    local disappearTween = createTween(Loading, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quad)
                    disappearTween:Play()

                    disappearTween.Completed:Connect(function()
                        ScreenGui:Destroy() -- Полностью удаляем UI
                    end)
                end
            end)
        end)
    end)
end

-- Запускаем анимацию
wait(0.1)
startLoadingAnimation()