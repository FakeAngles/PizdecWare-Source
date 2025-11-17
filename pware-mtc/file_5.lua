-- CRACKED BY WHODOTRU & FAKEANGLES
-- LITVIN SOSAL

_G.Status = "Ready!"
local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}

local Detected, Kill

setthreadidentity(2)

for i, v in pairs(getgc(true)) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")

        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc

            local Old; Old = hookfunction(DetectFunc, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then
                        warn(`Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info}`)
                    end
                end
                return true
            end)

            table.insert(Hooked, DetectFunc)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(KillFunc, function(Info)
                if DEBUG then
                    warn(`Adonis AntiCheat tried to kill (fallback): {Info}`)
                end
                return nil
            end)

            table.insert(Hooked, KillFunc)
        end
    end
end

local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...

    if Detected and LevelOrFunc == Detected then
        if DEBUG then
            warn(`zins | adonis bypassed`)
        end
        return coroutine.yield()
    end

    return Old(...)
end))

setthreadidentity(7)
local hook
hook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local selfName = tostring(self)
    
    if method == "FireServer" then
        if selfName == "Fire" or selfName == "Damage" then
            return nil
        end
    end
    
    return hook(self, ...)
end)

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/razedZ/UI/refs/heads/main/V3"))()

-- Объявляем переменные ДО создания UI
local weaponMods = {
    infAmmo = false,
    fireRate = false,
    noRecoil = false,
    rapidFire = false,
    loopActive = false,
    loopConnection = nil
}
local resizeMultiplier = 3.5
local customSoundID = ""

local ui = UILibrary.new({
    Info = "MTC V2.0",
    discordURL = "https://discord.gg/QhfzDG7Ju8",
    FileName = "MTC.json"
})

-- Загружаем сохраненные настройки СРАЗУ после создания UI
if ui.settings then
    if ui.settings.ResizeMultiplier then
        local num = tonumber(ui.settings.ResizeMultiplier)
        if num and num > 0 then
            resizeMultiplier = num
        end
    end
    if ui.settings.ShootSoundID then
        customSoundID = ui.settings.ShootSoundID
    end
end



-- Fly System
local FlyEnabled = false
local FlyToggleKey = Enum.KeyCode.B
local FlightSpeed = 550
local FlightAcceleration = 4
local QEfly = true

local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local CurrentVelocity = Vector3.new(0,0,0)
local CurrentVehicleSeat = nil
local InVehicle = false
local flyKeyDown, flyKeyUp, flyConnection

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CurrentCharacter, CurrentRootPart, CurrentHumanoid

-- Fly Functions
local function setupCharacter()
    CurrentCharacter = LocalPlayer.Character
    if CurrentCharacter then
        CurrentRootPart = CurrentCharacter:FindFirstChild("HumanoidRootPart")
        CurrentHumanoid = CurrentCharacter:FindFirstChildOfClass("Humanoid")
    end
    CurrentVehicleSeat = nil
    InVehicle = false
end

local function checkVehicle()
    if not CurrentCharacter then return false end
    
    for _, part in pairs(CurrentCharacter:GetChildren()) do
        if part:IsA("BasePart") then
            local seat = part:FindFirstAncestorOfClass("VehicleSeat")
            if seat then
                CurrentVehicleSeat = seat
                InVehicle = true
                return true
            end
        end
    end
    
    if CurrentHumanoid and CurrentHumanoid.SeatPart then
        CurrentVehicleSeat = CurrentHumanoid.SeatPart
        InVehicle = true
        return true
    end
    
    CurrentVehicleSeat = nil
    InVehicle = false
    return false
end

local function setupFlyInput()
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    
    flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not FlyEnabled then return end
        
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = FlightSpeed
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = -FlightSpeed
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = -FlightSpeed
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = FlightSpeed
        elseif input.KeyCode == Enum.KeyCode.E and QEfly then
            CONTROL.Q = FlightSpeed * 2
        elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
            CONTROL.E = -FlightSpeed * 2
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
        if processed or not FlyEnabled then return end
        
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 0
        elseif input.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = 0
        elseif input.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = 0
        end
    end)
end

local function flyUpdate(delta)
    if not FlyEnabled then
        CurrentVelocity = Vector3.new(0,0,0)
        return
    end

    checkVehicle()
    
    local moveVector = Vector3.new(0,0,0)
    local isMoving = CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0

    if isMoving then
        moveVector = ((Camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + 
                     ((Camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - Camera.CFrame.p))
        lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
    else
        moveVector = Vector3.new(0, 0, 0)
        lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    end

    if InVehicle and CurrentVehicleSeat then
        local vehicle = CurrentVehicleSeat
        if not vehicle.Anchored then
            local vehicleRoot = vehicle:GetRootPart()
            if vehicleRoot then
                CurrentVelocity = CurrentVelocity:Lerp(moveVector, math.clamp(delta * FlightAcceleration, 0, 1))
                vehicleRoot.Velocity = CurrentVelocity + Vector3.new(0, 2, 0)
                
                local camDir = Camera.CFrame
                local newCFrame = CFrame.new(vehicleRoot.Position) * (camDir - camDir.Position)
                vehicleRoot.CFrame = newCFrame
                vehicleRoot.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    elseif CurrentRootPart then
        local rootPart = CurrentRootPart:GetRootPart()
        if rootPart and not rootPart.Anchored and (isnetworkowner == nil or isnetworkowner(rootPart)) then
            CurrentVelocity = CurrentVelocity:Lerp(moveVector, math.clamp(delta * FlightAcceleration, 0, 1))
            rootPart.Velocity = CurrentVelocity + Vector3.new(0, 2, 0)
            
            if CurrentHumanoid then
                local camDir = Camera.CFrame
                local newCFrame = CFrame.new(rootPart.Position) * (camDir - camDir.Position)
                rootPart.CFrame = newCFrame
                rootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

local function toggleFlight()
    FlyEnabled = not FlyEnabled
    
    if FlyEnabled then
        checkVehicle()
        CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        setupFlyInput()
        
        if not flyConnection then
            flyConnection = RunService.Heartbeat:Connect(flyUpdate)
        end
        
        if CurrentHumanoid and not InVehicle then
            CurrentHumanoid.PlatformStand = true
        end
    else
        CurrentVelocity = Vector3.new(0,0,0)
        
        if InVehicle and CurrentVehicleSeat then
            local vehicleRoot = CurrentVehicleSeat:GetRootPart()
            if vehicleRoot then
                vehicleRoot.Velocity = Vector3.new(0,0,0)
                vehicleRoot.RotVelocity = Vector3.new(0,0,0)
            end
        elseif CurrentRootPart then
            local rootPart = CurrentRootPart:GetRootPart()
            if rootPart and not rootPart.Anchored then
                rootPart.Velocity = Vector3.new(0,0,0)
                rootPart.RotVelocity = Vector3.new(0,0,0)
            end
        end
        
        if CurrentHumanoid and not InVehicle then
            CurrentHumanoid.PlatformStand = false
        end
        
        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
setupCharacter()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == FlyToggleKey then
        toggleFlight()
    end
end)

RunService.Heartbeat:Connect(function()
    if FlyEnabled then
        checkVehicle()
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    FlyEnabled = false
    CurrentVelocity = Vector3.new(0,0,0)
end)

-- RemoveArmor
local armorRemovalActive = false
local connections = {}
local processedArmor = {}
local lastArmorUpdate = 0
local UPDATE_INTERVAL = 10

local function removeArmor()
    local currentTime = os.time()
    if currentTime - lastArmorUpdate < UPDATE_INTERVAL then return end
    lastArmorUpdate = currentTime
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ArmourValue" and obj:IsA("ValueBase") and not processedArmor[obj] and obj.Value ~= 0 then
            obj.Value = 0
            processedArmor[obj] = true
        end
    end
end

local function trackNewVehicles()
    local spawnedVehicles = workspace:WaitForChild("SpawnedVehicles")
    local connection = spawnedVehicles.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "ArmourValue" and descendant:IsA("ValueBase") and not processedArmor[descendant] then
            descendant.Value = 0
            processedArmor[descendant] = true
        end
    end)
    table.insert(connections, connection)
end

local function startArmorRemoval()
    armorRemovalActive = true
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    removeArmor()
    trackNewVehicles()
    local loop = game:GetService("RunService").Heartbeat:Connect(function()
        if not armorRemovalActive then
            loop:Disconnect()
            return
        end
        removeArmor()
    end)
    table.insert(connections, loop)
end

local function stopArmorRemoval()
    armorRemovalActive = false
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    processedArmor = {}
end

-- Highlight Tank ESP
local tankHighlightActive = false
local highlightedTanks = {}
local tankHighlightSettings = {
    fillColor = Color3.fromRGB(170, 0, 255),
    outlineColor = Color3.fromRGB(255, 50, 255),
    fillTransparency = 0.2,
    outlineTransparency = 0,
    textColor = Color3.fromRGB(255, 255, 255),
    infoTextColor = Color3.fromRGB(255, 200, 0),
    ignoreTeam = false
}

local function isEnemyTank(vehicle)
    if not tankHighlightSettings.ignoreTeam then
        return true
    end
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local ownerName = vehicle:GetAttribute("Owner") or vehicle:GetAttribute("Requester")
    if ownerName then
        local ownerPlayer = Players:FindFirstChild(ownerName)
        if ownerPlayer and ownerPlayer.Team and LocalPlayer.Team then
            return ownerPlayer.Team ~= LocalPlayer.Team
        end
    end
    
    local turrets = vehicle:FindFirstChild("Turrets")
    if turrets then
        for _, turret in ipairs(turrets:GetChildren()) do
            local seat = turret:FindFirstChildWhichIsA("VehicleSeat")
            if seat then
                local occupant = seat.Occupant
                if occupant then
                    local humanoid = occupant.Parent:FindFirstChildWhichIsA("Humanoid")
                    if humanoid then
                        local player = Players:GetPlayerFromCharacter(humanoid.Parent)
                        if player and player.Team and LocalPlayer.Team then
                            return player.Team ~= LocalPlayer.Team
                        end
                    end
                end
            end
        end
    end
    
    return true
end

local function createTankHighlight(vehicle)
    if vehicle.Name == "DONOT" then
        return
    end
    
    if tankHighlightSettings.ignoreTeam and not isEnemyTank(vehicle) then
        if highlightedTanks[vehicle] then
            highlightedTanks[vehicle].highlight:Destroy()
            highlightedTanks[vehicle] = nil
        end
        return
    end
    
    if highlightedTanks[vehicle] then
        local data = highlightedTanks[vehicle]
        if data.highlight then
            data.highlight.FillColor = tankHighlightSettings.fillColor
            data.highlight.OutlineColor = tankHighlightSettings.outlineColor
            data.highlight.FillTransparency = tankHighlightSettings.fillTransparency
            data.highlight.OutlineTransparency = tankHighlightSettings.outlineTransparency
        end
        if data.billboard then
            local mainLabel = data.billboard:FindFirstChild("MainLabel")
            local infoLabel = data.billboard:FindFirstChild("InfoLabel")
            if mainLabel then
                mainLabel.TextColor3 = tankHighlightSettings.textColor
            end
            if infoLabel then
                infoLabel.TextColor3 = tankHighlightSettings.infoTextColor
            end
        end
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "TankHighlight"
    highlight.FillColor = tankHighlightSettings.fillColor
    highlight.OutlineColor = tankHighlightSettings.outlineColor
    highlight.FillTransparency = tankHighlightSettings.fillTransparency
    highlight.OutlineTransparency = tankHighlightSettings.outlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = vehicle
       
    vehicle.Destroying:Connect(function()
        if highlightedTanks[vehicle] then
            highlightedTanks[vehicle].highlight:Destroy()
            highlightedTanks[vehicle] = nil
        end
    end)
end

-- сбавь управление
local moduleSwapActive = false
local moduleSwapConnection = nil
local originalModuleNames = {}
local alreadySwapped = false

local function swapModuleNames()
    if alreadySwapped then return end
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local spawnedVehicles = Workspace:FindFirstChild("SpawnedVehicles")
    if not spawnedVehicles then return end
    
    for _, vehicleModel in ipairs(spawnedVehicles:GetChildren()) do
        if vehicleModel.Name == "DONOT" then
            continue
        end
        
        if vehicleModel:IsA("Model") then
            local vehiclePrimaryPart = vehicleModel.PrimaryPart
            if vehiclePrimaryPart then
                local distance = (humanoidRootPart.Position - vehiclePrimaryPart.Position).Magnitude
                
                if distance <= 10 then -- Если расстояние меньше или равно 10 studs
                    local vehicleName = vehicleModel.Name
                    
                    local vehiclesFolder = ReplicatedStorage.NewDriveData.Vehicles
                    
                    local targetModule = vehiclesFolder:FindFirstChild("15 tonnin rynnäkkötykkipanssarivaunu")
                    if not targetModule then
                        continue
                    end
                    
                    local vehicleModule = vehiclesFolder:FindFirstChild(vehicleName)
                    if not vehicleModule then
                        continue
                    end
                    
                    if not originalModuleNames[targetModule] then
                        originalModuleNames[targetModule] = targetModule.Name
                    end
                    if not originalModuleNames[vehicleModule] then
                        originalModuleNames[vehicleModule] = vehicleModule.Name
                    end
                    
                    vehicleModule.Name = "TempName_" .. vehicleName
                    targetModule.Name = vehicleName
                    vehicleModule.Name = "15 tonnin rynnäkkötykkipanssarivaunu"
                    
                    local vehicleData = require(game:GetService("ReplicatedStorage").NewDriveData.Vehicles["15 tonnin rynnäkkötykkipanssarivaunu"])
                    vehicleData.MassTon = 2
                    
                    alreadySwapped = true 
                    break 
                end
            end
        end
    end
end

local function restoreModuleNames()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local vehiclesFolder = ReplicatedStorage.NewDriveData.Vehicles
    
    for module, originalName in pairs(originalModuleNames) do
        if module and module.Parent then
            module.Name = originalName
        end
    end
    
    originalModuleNames = {}
    alreadySwapped = false
end

local function startModuleSwap()
    moduleSwapActive = true
    alreadySwapped = false
    
    moduleSwapConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not moduleSwapActive then
            moduleSwapConnection:Disconnect()
            return
        end
        swapModuleNames()
    end)
end

local function stopModuleSwap()
    moduleSwapActive = false
    
    if moduleSwapConnection then
        moduleSwapConnection:Disconnect()
        moduleSwapConnection = nil
    end
    
    restoreModuleNames()
end

-- Resize Ammo
local resizeMultiplier = 3.5

local function resizeAmmo(changeSize, customMultiplier)
    local multiplier = customMultiplier or resizeMultiplier
    local spawnedVehicles = workspace:FindFirstChild("SpawnedVehicles")
    if spawnedVehicles then
        for _, vehicle in pairs(spawnedVehicles:GetChildren()) do
            if vehicle:IsA("Model") then
                local damageModules = vehicle:FindFirstChild("DamageModules")
                if damageModules then
                    for _, module in pairs(damageModules:GetChildren()) do
                        local ammoModel1 = module:FindFirstChild("AmmoModel1")
                        if ammoModel1 then
                            if changeSize then
                                ammoModel1.Size = ammoModel1.Size * multiplier
                            else
                                ammoModel1.Size = ammoModel1.Size / multiplier
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Ruka Blood
local rukaBloodActive = false
local rukaBloodConnection = nil
local originalProperties = {}

-- Shoot Sound
local shootSoundActive = false
local shootSoundConnection = nil
local processedSounds = {}



local function applyWeaponMods()
    local player = game:GetService("Players").LocalPlayer
    local backpack = player.Backpack
    
    for _, item in pairs(backpack:GetChildren()) do
        local acsSettings = item:FindFirstChild("ACS_Settings")
        if acsSettings then
            local success, m = pcall(function()
                return require(acsSettings)
            end)
            
            if success and m then
                if weaponMods.infAmmo then
                    m.AmmoInGun = 10000000000
                end
                if weaponMods.fireRate then
                    m.ShootRate = 10000000000
                end
                if weaponMods.noRecoil then
                    m.MinRecoilPower = 0
                    m.MaxRecoilPower = 0
                    if m.camRecoil then
                        m.camRecoil.camRecoilUp = {0, 0}
                        m.camRecoil.camRecoilTilt = {0, 0}
                        m.camRecoil.camRecoilLeft = {0, 0}
                        m.camRecoil.camRecoilRight = {0, 0}
                    end
                    if m.gunRecoil then
                        m.gunRecoil.gunRecoilUp = {0, 0}
                        m.gunRecoil.gunRecoilTilt = {0, 0}
                        m.gunRecoil.gunRecoilLeft = {0, 0}
                        m.gunRecoil.gunRecoilRight = {0, 0}
                    end
                end
                if weaponMods.rapidFire then
                    m.ShootType = 3
                    if m.FireModes then
                        m.FireModes.Auto = true
                    end
                end
            end
        end
    end
end

local function startWeaponLoop()
    weaponMods.loopActive = true
    
    spawn(function()
        while weaponMods.loopActive do
            applyWeaponMods()
            wait(1)
        end
    end)
end

local function stopWeaponLoop()
    weaponMods.loopActive = false
    if weaponMods.loopConnection then
        weaponMods.loopConnection:Disconnect()
        weaponMods.loopConnection = nil
    end
end

local processedParts = {}
local function startRukaBlood()
    rukaBloodActive = true
    processedParts = {}
    
    local function processPart(obj)
        if obj:IsA("BasePart") and not processedParts[obj] then
            pcall(function()
                originalProperties[obj] = {
                    Material = obj.Material,
                    Color = obj.Color
                }
                local forcefield = Instance.new("ForceField")
                forcefield.Visible = true
                forcefield.Parent = obj
                obj.Material = Enum.Material.ForceField
                obj.Color = Color3.fromRGB(170, 0, 255)
                processedParts[obj] = true
            end)
        end
    end
    
    for _, obj in pairs(workspace.Camera:GetDescendants()) do
        processPart(obj)
    end
    
    rukaBloodConnection = workspace.Camera.DescendantAdded:Connect(function(obj)
        if rukaBloodActive then
            processPart(obj)
        end
    end)
end

local function stopRukaBlood()
    rukaBloodActive = false
    
    if rukaBloodConnection then
        rukaBloodConnection:Disconnect()
        rukaBloodConnection = nil
    end
    
    for _, obj in pairs(workspace.Camera:GetDescendants()) do
        local forcefield = obj:FindFirstChild("ForceField")
        
        if forcefield then
            forcefield:Destroy()
        end
        
        if originalProperties[obj] then
            obj.Material = originalProperties[obj].Material
            obj.Color = originalProperties[obj].Color
            originalProperties[obj] = nil
        end
    end
end


-- Resize Ammo
local resizeMultiplier = 3.5

local function resizeAmmo(changeSize, customMultiplier)
    local multiplier = customMultiplier or resizeMultiplier
    local spawnedVehicles = workspace:FindFirstChild("SpawnedVehicles")
    if spawnedVehicles then
        for _, vehicle in pairs(spawnedVehicles:GetChildren()) do
            if vehicle:IsA("Model") then
                local damageModules = vehicle:FindFirstChild("DamageModules")
                if damageModules then
                    for _, module in pairs(damageModules:GetChildren()) do
                        local ammoModel1 = module:FindFirstChild("AmmoModel1")
                        if ammoModel1 then
                            if changeSize then
                                ammoModel1.Size = ammoModel1.Size * multiplier
                            else
                                ammoModel1.Size = ammoModel1.Size / multiplier
                            end
                        end
                    end
                end
            end
        end
    end
end

-- сбавь управление
local moduleSwapActive = false
local moduleSwapConnection = nil
local originalModuleNames = {}
local alreadySwapped = false

local function swapModuleNames()
    if alreadySwapped then return end
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local spawnedVehicles = Workspace:FindFirstChild("SpawnedVehicles")
    if not spawnedVehicles then return end
    
    for _, vehicleModel in ipairs(spawnedVehicles:GetChildren()) do
        if vehicleModel.Name == "DONOT" then
            continue
        end
        
        if vehicleModel:IsA("Model") then
            local vehiclePrimaryPart = vehicleModel.PrimaryPart
            if vehiclePrimaryPart then
                local distance = (humanoidRootPart.Position - vehiclePrimaryPart.Position).Magnitude
                
                if distance <= 10 then -- Если расстояние меньше или равно 10 studs
                    local vehicleName = vehicleModel.Name
                    
                    local vehiclesFolder = ReplicatedStorage.NewDriveData.Vehicles
                    
                    local targetModule = vehiclesFolder:FindFirstChild("15 tonnin rynnäkkötykkipanssarivaunu")
                    if not targetModule then
                        continue
                    end
                    
                    local vehicleModule = vehiclesFolder:FindFirstChild(vehicleName)
                    if not vehicleModule then
                        continue
                    end
                    
                    if not originalModuleNames[targetModule] then
                        originalModuleNames[targetModule] = targetModule.Name
                    end
                    if not originalModuleNames[vehicleModule] then
                        originalModuleNames[vehicleModule] = vehicleModule.Name
                    end
                    
                    vehicleModule.Name = "TempName_" .. vehicleName
                    targetModule.Name = vehicleName
                    vehicleModule.Name = "15 tonnin rynnäkkötykkipanssarivaunu"
                    
                    local vehicleData = require(game:GetService("ReplicatedStorage").NewDriveData.Vehicles["15 tonnin rynnäkkötykkipanssarivaunu"])
                    vehicleData.MassTon = 2
                    
                    alreadySwapped = true 
                    break 
                end
            end
        end
    end
end

local function restoreModuleNames()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local vehiclesFolder = ReplicatedStorage.NewDriveData.Vehicles
    
    for module, originalName in pairs(originalModuleNames) do
        if module and module.Parent then
            module.Name = originalName
        end
    end
    
    originalModuleNames = {}
    alreadySwapped = false
end

local function startModuleSwap()
    moduleSwapActive = true
    alreadySwapped = false
    
    moduleSwapConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not moduleSwapActive then
            moduleSwapConnection:Disconnect()
            return
        end
        swapModuleNames()
    end)
end

local function stopModuleSwap()
    moduleSwapActive = false
    
    if moduleSwapConnection then
        moduleSwapConnection:Disconnect()
        moduleSwapConnection = nil
    end
    
    restoreModuleNames()
end

local function highlightExistingTanks()
    local spawnedVehicles = workspace:FindFirstChild("SpawnedVehicles")
    if spawnedVehicles then
        for _, vehicle in ipairs(spawnedVehicles:GetChildren()) do
            if vehicle:IsA("Model") then
                createTankHighlight(vehicle)
            end
        end
    end
end

local function removeAllTankHighlights()
    local spawnedVehicles = workspace:FindFirstChild("SpawnedVehicles")
    if spawnedVehicles then
        for _, vehicle in ipairs(spawnedVehicles:GetChildren()) do
            local highlight = vehicle:FindFirstChild("TankHighlight")
            local billboard = vehicle:FindFirstChild("TankLabel")
            
            if highlight then
                highlight:Destroy()
            end
            if billboard then
                billboard:Destroy()
            end
        end
    end
    
    highlightedTanks = {}
end

local function updateAllTankHighlights()
    if not tankHighlightActive then return end
    
    removeAllTankHighlights()
    highlightExistingTanks()
end

local function startTankHighlight()
    tankHighlightActive = true
    
    highlightExistingTanks()
    
    local spawnedVehicles = workspace:WaitForChild("SpawnedVehicles")
    spawnedVehicles.ChildAdded:Connect(function(vehicle)
        if vehicle:IsA("Model") then
            wait(0.3)
            createTankHighlight(vehicle)
        end
    end)
end

local function stopTankHighlight()
    tankHighlightActive = false
    removeAllTankHighlights()
end

-- InfAmmo
local function InfAmmo()


    local hooked = false

    local originalNamecall
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if not hooked and method == "FireServer" and tostring(self) == "AmmoDataEvt" then
            hooked = true
            
            local args = {...}
            for i, arg in ipairs(args) do
                if type(arg) == "table" then
                    local function modifyMags(t)
                        for key, value in pairs(t) do
                            if type(value) == "table" then
                                modifyMags(value)
                            elseif key == "Mag" then
                                t[key] = 1000000000
                            end
                        end
                    end
                    modifyMags(arg)
                end
            end
        end
        
        return originalNamecall(self, ...)
    end)



    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local function freezeValue(property)
        local originalValue = property.Value
        property.Changed:Connect(function()
            if property.Value ~= originalValue then
                property.Value = originalValue
            end
        end)
        property.Value = originalValue
    end

    local function findNearestModel()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local closestModel = nil
        local closestDistance = math.huge
        
        local searchFolders = {
            workspace:FindFirstChild("PlacedBuildings"),
            workspace:FindFirstChild("SpawnedVehicles")
        }
        
        for _, folder in ipairs(searchFolders) do
            if not folder then continue end
            
            for _, model in ipairs(folder:GetChildren()) do
                if not model:IsA("Model") then continue end
                
                local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local distance = (humanoidRootPart.Position - primaryPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestModel = model
                    end
                end
            end
        end
        
        return closestModel
    end

    local function processNearestModel()
        local nearestModel = findNearestModel()
        
        if nearestModel and nearestModel:FindFirstChild("Turrets") then
            for _, turret in ipairs(nearestModel.Turrets:GetChildren()) do
                if turret:FindFirstChild("Weapons") then
                    for _, weapon in ipairs(turret.Weapons:GetChildren()) do
                        local weaponClone = weapon:Clone()
                        weapon:Destroy()
                        weaponClone.Parent = turret.Weapons
                        
                        if weaponClone:FindFirstChild("CurrentlyLoaded") then
                            freezeValue(weaponClone.CurrentlyLoaded)
                        end
                    end
                end
            end
        end
    end

    processNearestModel()
end

-- Fast Place
local FastPlace = {
    Enabled = false,
    Connection = nil,
    Zacep = false
}

local function setupFastPlace()
    local player = game:GetService("Players").LocalPlayer
    local mouse = player:GetMouse()
    local BuildingFolder = workspace:WaitForChild("BuildingScriptTemporary")

    local function getBaseObjectName(fullName)
        return fullName:gsub("Pick up ", "")
    end

    local function hasParentheses(name)
        return name:find("%(") and name:find("%)") 
    end

    local function getPhantomData(toolName)
        if hasParentheses(toolName) then return nil end
        local phantom = BuildingFolder:FindFirstChild(toolName)
        return phantom and phantom:GetPivot()
    end

    return mouse.Button1Down:Connect(function()
        local character = player.Character
        if not character or not character.PrimaryPart then return end

        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then return end

        local phantomCFrame = getPhantomData(tool.Name)
        local targetObject = mouse.Target

        -- Если попали в BuildingScriptTemporary, ищем объект под ним через raycast
        if targetObject and targetObject:IsDescendantOf(workspace.BuildingScriptTemporary) then
            local camera = workspace.CurrentCamera
            local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {workspace.BuildingScriptTemporary}
            
            local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            targetObject = raycastResult and raycastResult.Instance or nil
        end

        if targetObject then

        end






        if tool.Name:match("Pick up") then
            local baseName = getBaseObjectName(tool.Name)
            



            for _, building in pairs(workspace.PlacedBuildings:GetChildren()) do
                if building.Name == baseName then
                    local ownershipTag = building:FindFirstChild("OwnershipTag")
                    if ownershipTag and ownershipTag.Value == player.Name then
                        game:GetService("ReplicatedStorage").Events.DestroyPlacementEvent:FireServer(building)
                        break
                    end
                end
            end
        else
            if phantomCFrame and targetObject then
                local relativeCFrame = FastPlace.Zacep and CFrame.new(10000, 10000, 10000) or CFrame.new(0, 0, 0)
                game:GetService("ReplicatedStorage").Events.PlacementEvent:FireServer(
                    tool.Name,
                    phantomCFrame,
                    targetObject,
                    relativeCFrame,
                    nil,
                    {}
                )
            elseif phantomCFrame then
                game:GetService("ReplicatedStorage").Events.PlacementEvent:FireServer(
                    tool.Name,
                    phantomCFrame,
                    nil,
                    nil,
                    nil,
                    {}
                )
            end
        end
    end)
end

-- ZOV Striker
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local ZOVStriker = {
    Active = false,
    Connection = nil,
    MuzzleParts = {},
    Distance = 20,
    Visible = false,
    OriginalProperties = {},
    Vehicle = nil
}

local function findNearestVehicle()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local vehicles = workspace.SpawnedVehicles:GetChildren()
    local nearestVehicle = nil
    local shortestDistance = math.huge
    
    for _, vehicle in ipairs(vehicles) do
        if vehicle:IsA("Model") then
            local primaryPart = vehicle.PrimaryPart
            if primaryPart then
                local distance = (humanoidRootPart.Position - primaryPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestVehicle = vehicle
                end
            end
        end
    end
    
    return nearestVehicle
end

local function setupMuzzles(vehicle)
    local muzzles = vehicle:FindFirstChild("Muzzles")
    if not muzzles or not muzzles:IsA("Model") then
        return nil
    end
    
    local muzzleParts = {}
    ZOVStriker.OriginalProperties = {}
    
    for _, child in ipairs(muzzles:GetChildren()) do
        if child:IsA("BasePart") then
            ZOVStriker.OriginalProperties[child] = {
                Anchored = child.Anchored,
                CanCollide = child.CanCollide,
                Transparency = child.Transparency,
                Material = child.Material,
                Color = child.Color,
                Constraints = {}
            }
            
            for _, constraint in ipairs(child:GetChildren()) do
                if constraint:IsA("WeldConstraint") or 
                   constraint:IsA("Weld") or
                   constraint:IsA("Motor6D") then
                    table.insert(ZOVStriker.OriginalProperties[child].Constraints, {
                        Constraint = constraint,
                        Enabled = constraint.Enabled
                    })
                    constraint.Enabled = false
                end
            end
            
            if ZOVStriker.Visible then
                child.Transparency = 0
                child.Material = Enum.Material.Neon
                child.Color = Color3.fromRGB(170, 0, 255)
            else
                child.Transparency = 1
            end
            
            child.Anchored = true
            child.CanCollide = false
            
            table.insert(muzzleParts, child)
            table.insert(ZOVStriker.MuzzleParts, child)
        end
    end
    
    return muzzleParts
end

local function resetZOVStriker()
    if not ZOVStriker.Active and not ZOVStriker.Connection then
        return
    end
    
    if ZOVStriker.Connection then
        ZOVStriker.Connection:Disconnect()
        ZOVStriker.Connection = nil
    end
    
    ZOVStriker.Active = false
    
    for part, properties in pairs(ZOVStriker.OriginalProperties) do
        if part and part.Parent then
            pcall(function()
                part.Anchored = properties.Anchored
                part.CanCollide = properties.CanCollide
                part.Transparency = properties.Transparency
                part.Material = properties.Material
                part.Color = properties.Color
                
                for _, constraintData in ipairs(properties.Constraints) do
                    if constraintData.Constraint and constraintData.Constraint.Parent then
                        constraintData.Constraint.Enabled = constraintData.Enabled
                    end
                end
            end)
        end
    end
    
    ZOVStriker.MuzzleParts = {}
    ZOVStriker.OriginalProperties = {}
    ZOVStriker.Vehicle = nil
end

local function startFollowing()
    if ZOVStriker.Active or ZOVStriker.Connection then
        return
    end
    
    local vehicle = findNearestVehicle()
    if not vehicle then
        return
    end
    
    ZOVStriker.Vehicle = vehicle
    
    local muzzleParts = setupMuzzles(vehicle)
    if not muzzleParts or #muzzleParts == 0 then
        ZOVStriker.Vehicle = nil
        return
    end
    
    ZOVStriker.Active = true
    ZOVStriker.Connection = RunService.Heartbeat:Connect(function()
        if not ZOVStriker.Active or not ZOVStriker.Vehicle or not ZOVStriker.Vehicle.Parent then
            resetZOVStriker()
            return
        end
        
        local mouseHit = mouse.Hit
        local targetPosition = mouseHit.Position + Vector3.new(0, ZOVStriker.Distance, 0)
        
        for _, part in ipairs(muzzleParts) do
            if part and part.Parent then
                pcall(function()
                    part.Position = targetPosition
                    
                    local lookCFrame = CFrame.lookAt(part.Position, mouseHit.Position)
                    lookCFrame = lookCFrame * CFrame.Angles(math.rad(180), 0, 0)
                    
                    part.CFrame = lookCFrame
                end)
            end
        end
    end)
    
    if vehicle then
        vehicle.AncestryChanged:Connect(function()
            if not vehicle.Parent then
                pcall(resetZOVStriker)
            end
        end)
    end
end

-- Silent Aim
getgenv().SilentAim = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = false,
    FOV = {
        Radius = 200,
        Visible = true,
        Color = Color3.fromRGB(171, 0, 255)
    },
    Tracer = {
        Enabled = true,
        Color = Color3.fromRGB(171, 0, 255),
        Thickness = 1
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.Camera
local FOVCircle, TargetDot, CenterDot, TracerLine
local IsTargeting = false
local GunFirePointFound = false
local GunFirePoint = nil

local function InitDrawings()
    FOVCircle = Drawing.new("Circle")
    TargetDot = Drawing.new("Circle")
    CenterDot = Drawing.new("Circle")
    TracerLine = Drawing.new("Line")
    
    FOVCircle.Visible = SilentAim.FOV.Visible
    FOVCircle.Transparency = 0.7
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Radius = SilentAim.FOV.Radius
    FOVCircle.Color = SilentAim.FOV.Color
    
    TargetDot.Visible = false
    TargetDot.Transparency = 1
    TargetDot.Thickness = 1
    TargetDot.Filled = true
    TargetDot.Radius = 2
    TargetDot.Color = Color3.fromRGB(171, 0, 255)
    
    CenterDot.Visible = SilentAim.FOV.Visible
    CenterDot.Transparency = 1
    CenterDot.Thickness = 1
    CenterDot.Filled = true
    CenterDot.Radius = 2
    CenterDot.Color = Color3.fromRGB(171, 0, 255)
    
    TracerLine.Visible = false
    TracerLine.Transparency = 1
    TracerLine.Thickness = SilentAim.Tracer.Thickness
    TracerLine.Color = SilentAim.Tracer.Color
end

local function getCursorCenter()
    local viewportSize = CurrentCamera.ViewportSize
    return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end

local function isVisible(targetPosition)
    if not SilentAim.WallCheck then return true end
    
    local cameraPosition = CurrentCamera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    local distance = (targetPosition - cameraPosition).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, CurrentCamera}
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(cameraPosition, direction * distance, raycastParams)
    
    return raycastResult == nil
end

local function isEnemy(player)
    if not SilentAim.TeamCheck then return true end
    
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    return true
end

local function getGunFirePoint()
    if GunFirePoint and GunFirePoint:IsDescendantOf(CurrentCamera) then
        GunFirePointFound = true
        return GunFirePoint
    end
    
    local descendants = CurrentCamera:GetDescendants()
    GunFirePoint = nil
    GunFirePointFound = false
    
    for _, descendant in ipairs(descendants) do
        if (descendant.Name:find("GunFirePoint") or descendant.Name:find("FirePoint") or descendant.Name:find("Muzzle")) 
           and (descendant:IsA("Attachment") or descendant:IsA("Part")) then
            GunFirePoint = descendant
            GunFirePointFound = true
            break
        end
    end
    
    if not GunFirePoint then
        for _, descendant in ipairs(descendants) do
            if descendant:IsA("Attachment") then
                GunFirePoint = descendant
                GunFirePointFound = true
                break
            end
        end
    end
    
    return GunFirePoint
end

local function setGunFirePointToCameraDirection()
    local gunFirePoint = getGunFirePoint()
    if not gunFirePoint then return end
    
    local cameraCFrame = CurrentCamera.CFrame
    local cameraDirection = cameraCFrame.LookVector
    
    local viewmodel = CurrentCamera:FindFirstChild("Viewmodel")
    if not viewmodel then return end
    
    local viewmodelPart = viewmodel:FindFirstChildWhichIsA("BasePart")
    if not viewmodelPart then return end
    
    local frontPosition = viewmodelPart.Position + (cameraDirection * 1)
    
    if gunFirePoint:IsA("Attachment") then
        gunFirePoint.WorldPosition = frontPosition
    elseif gunFirePoint:IsA("BasePart") then
        gunFirePoint.Position = frontPosition
    end
end

local function FindBestTarget()
    if not SilentAim.Enabled then return nil end
    
    local bestTarget = nil
    local closestDistance = math.huge
    local screenCenter = getCursorCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if not isEnemy(player) then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local head = character:FindFirstChild("Head")
        if not head then continue end
        
        if SilentAim.WallCheck and not isVisible(head.Position) then continue end
        
        local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (targetPos - screenCenter).Magnitude
        
        if distance < SilentAim.FOV.Radius and distance < closestDistance then
            closestDistance = distance
            bestTarget = {
                Player = player,
                Head = head,
                Distance = distance,
                Position = head.Position
            }
        end
    end
    
    IsTargeting = bestTarget ~= nil
    return bestTarget
end

local function updateGunFirePointToTarget(targetHead)
    local gunFirePoint = getGunFirePoint()
    if not gunFirePoint or not targetHead then 
        TracerLine.Visible = false
        return false
    end
    
    local targetPosition = targetHead.Position
    local cameraPosition = CurrentCamera.CFrame.Position
    local directionToTarget = (targetPosition - cameraPosition).Unit
    local offsetPosition = targetPosition - (directionToTarget * 2)
    
    if gunFirePoint:IsA("Attachment") then
        gunFirePoint.WorldPosition = offsetPosition
    elseif gunFirePoint:IsA("BasePart") then
        gunFirePoint.Position = offsetPosition
    end
    
    return true
end

local function UpdateVisuals()
    if not FOVCircle or not CenterDot or not TargetDot or not TracerLine then return end
    
    if not SilentAim.Enabled then
        FOVCircle.Visible = false
        CenterDot.Visible = false
        TargetDot.Visible = false
        TracerLine.Visible = false
        setGunFirePointToCameraDirection()
        return
    end
    
    local center = getCursorCenter()
    FOVCircle.Position = center
    TargetDot.Position = center
    CenterDot.Position = center
    
    FOVCircle.Visible = SilentAim.FOV.Visible
    CenterDot.Visible = SilentAim.FOV.Visible
    TargetDot.Visible = IsTargeting and GunFirePointFound
    
    if SilentAim.Tracer.Enabled then
        local targetData = FindBestTarget()
        if targetData and GunFirePointFound then
            local screenPos = CurrentCamera:WorldToViewportPoint(targetData.Position)
            TracerLine.From = center
            TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
            TracerLine.Visible = updateGunFirePointToTarget(targetData.Head)
        else
            TracerLine.Visible = false
            setGunFirePointToCameraDirection()
        end
    else
        TracerLine.Visible = false
        setGunFirePointToCameraDirection()
    end
end

RunService.Heartbeat:Connect(function()
    UpdateVisuals()
end)

InitDrawings()

-- UI Creation
local main = ui:CreateTabSection("Main")
local render = ui:CreateTabSection("Render")

local misc = main:CreateTab("Misc", "rbxassetid://11781209985")
local aiming = main:CreateTab("Aiming", "rbxassetid://139650104834071")
local movement = main:CreateTab("Movement", "rbxassetid://13587579249")
local weapon = main:CreateTab("Weapon", "rbxassetid://15286655815")

local esp = render:CreateTab("ESP", "rbxassetid://15790339977")
local visual = render:CreateTab("Visual", "rbxassetid://14956448939")

-- Misc Tab
local othersLeft = misc:CreateSection("Others", "left")
local fastPlaceRight = misc:CreateSection("Fast Place", "right")
local vehicleBottom = misc:CreateSection("ZOV Striker", "left")
local resizeAmmoSection = misc:CreateSection("Resize Ammo", "right")

CreateInput({
    section = resizeAmmoSection,
    name = "Multiplier",
    placeholder = "Enter multiplier...",
    default = tostring(resizeMultiplier),
    save = true,
    id = "ResizeMultiplier",
    callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            resizeMultiplier = num
        end
    end
})

CreateToggle({
    section = resizeAmmoSection,
    name = "Resize Ammo",
    default = false,
    save = false,
    callback = function(state)
        resizeAmmo(state, resizeMultiplier)
    end
})

CreateToggle({
    section = othersLeft,
    name = "сбавь управление",
    default = false,
    save = false,
    id = "ModuleSwap",
    callback = function(state)
        if state then
            startModuleSwap()
        else
            stopModuleSwap()
        end
    end
})

CreateToggle({
    section = othersLeft,
    name = "Remove Armor",
    default = false,
    save = true,
    id = "RemoveArmor",
    callback = function(state)
        if state then
            startArmorRemoval()
        else
            stopArmorRemoval()
        end
    end
})

CreateToggle({
    section = fastPlaceRight,
    name = "Enable",
    default = false,
    save = true,
    id = "FastPlace",
    callback = function(state)
        FastPlace.Enabled = state
        if state then
            if FastPlace.Connection then
                FastPlace.Connection:Disconnect()
            end
            FastPlace.Connection = setupFastPlace()
        else
            if FastPlace.Connection then
                FastPlace.Connection:Disconnect()
                FastPlace.Connection = nil
            end
        end
    end
})

CreateToggle({
    section = fastPlaceRight,
    name = "Zacep",
    default = false,
    save = true,
    id = "FastPlaceZacep",
    callback = function(state)
        FastPlace.Zacep = state
    end
})

CreateButton({
    section = othersLeft,
    name = "Inf Ammo",
    callback = function()
        InfAmmo()
    end
})

CreateButton({
    section = othersLeft,
    name = "Ammo Crate",
    position = "right",
    callback = function()
        local crate = workspace.Map.ToolGivers.AmmoPallet.Model.AmmoCrate

        if crate then
            local player = game.Players.LocalPlayer
            local character = player.Character
            local hrp = character and character.HumanoidRootPart

            if hrp then
                local pos = hrp.Position + (hrp.CFrame.LookVector * 5)
                pos = Vector3.new(pos.X, pos.Y + 2, pos.Z)
                crate:PivotTo(CFrame.new(pos))
            end
        end
    end
})





CreateSlider({
    section = vehicleBottom,
    name = "Distance",
    min = 1,
    max = 200,
    default = ZOVStriker.Distance,
    save = true,
    id = "ZOVStrikerDistance",
    callback = function(value)
        ZOVStriker.Distance = value
    end
})

CreateToggle({
    section = vehicleBottom,
    name = "Visible",
    default = false,
    save = true,
    id = "ZOVStrikerVisible",
    callback = function(state)
        ZOVStriker.Visible = state
        
        if ZOVStriker.Active then
            for _, part in ipairs(ZOVStriker.MuzzleParts) do
                if part and part.Parent then
                    if state then
                        part.Transparency = 0
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromRGB(170, 0, 255)
                    else
                        part.Transparency = 1
                    end
                end
            end
        end
    end
})

CreateButton({
    section = vehicleBottom,
    name = "Reset",
    callback = function()
        resetZOVStriker()
    end
})

CreateButton({
    section = vehicleBottom,
    name = "Connect",
    position = "right",
    callback = function()
        if not ZOVStriker.Active then
            startFollowing()
        end
    end
})

-- Aiming Tab
local silentAimLeft = aiming:CreateSection("Silent Aim", "left")

CreateToggle({
    section = silentAimLeft,
    name = "SilentAim",
    default = false,
    save = true,
    id = "SilentAimEnabled",
    callback = function(state)
        SilentAim.Enabled = state
        FOVCircle.Visible = state and SilentAim.FOV.Visible
        CenterDot.Visible = state and SilentAim.FOV.Visible
    end
})

CreateSlider({
    section = silentAimLeft,
    name = "Silent FOV",
    min = 1,
    max = 500,
    default = SilentAim.FOV.Radius,
    save = true,
    id = "SilentAimFOV",
    callback = function(value)
        SilentAim.FOV.Radius = value
        FOVCircle.Radius = value
    end
})

CreateToggle({
    section = silentAimLeft,
    name = "Wall Check",
    default = false,
    save = true,
    id = "SilentAimWallCheck",
    callback = function(state)
        SilentAim.WallCheck = state
    end
})



-- Click TP
local ClickTP = {
    Enabled = false,
    Key = Enum.KeyCode.LeftControl,
    Connection = nil
}

local function setupClickTP()
    local UserInputService = game:GetService("UserInputService")
    local mouse = player:GetMouse()
    
    return mouse.Button1Down:Connect(function()
        if not ClickTP.Enabled then return end
        
        local character = player.Character
        if not character or not character.PrimaryPart then return end
        
        if not UserInputService:IsKeyDown(ClickTP.Key) then return end
        
        local targetPosition = mouse.Hit.Position
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    end)
end

-- FreeCam (IY Style)
local FreeCam = {
    Enabled = false,
    Active = false,
    Key = Enum.KeyCode.F2,
    Speed = (ui.settings and ui.settings.FreeCamSpeed) or 10,
    cameraPos = Vector3.new()
}

local function StepFreecam(dt)
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local actualSpeed = FreeCam.Speed * 20
    
    local kx = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
    local kz = (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    local ky = (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0)
    
    FreeCam.cameraPos = FreeCam.cameraPos + (Camera.CFrame.RightVector * kx + Camera.CFrame.LookVector * -kz + Vector3.new(0, ky, 0)) * actualSpeed * dt
    
    Camera.CFrame = CFrame.new(FreeCam.cameraPos) * (Camera.CFrame - Camera.CFrame.Position)
end

local function StartFreecam()
    if FreeCam.Active then return end
    local Camera = workspace.CurrentCamera
    local character = player.Character
    
    FreeCam.cameraPos = Camera.CFrame.Position
    FreeCam.Active = true
    
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.AutoRotate = false
    end
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.Anchored = true
    end
    
    Camera.CameraType = Enum.CameraType.Custom
    RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
end

local function StopFreecam()
    if not FreeCam.Active then return end
    local character = player.Character
    
    RunService:UnbindFromRenderStep("Freecam")
    
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.AutoRotate = true
    end
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.Anchored = false
    end
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = character and character:FindFirstChild("Humanoid")
    FreeCam.Active = false
end

local function toggleFreeCam()
    if FreeCam.Active then
        StopFreecam()
    else
        StartFreecam()
    end
end

local function setupFreeCamBind()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not FreeCam.Enabled then return end
        if input.KeyCode == FreeCam.Key then
            toggleFreeCam()
        end
    end)
end

setupFreeCamBind()

-- Movement Tab
local flyLeft = movement:CreateSection("Fly", "left")
local freeCamRight = movement:CreateSection("Free Camera", "right")
local clickTPLeft = movement:CreateSection("Click TP", "left")

CreateToggle({
    section = flyLeft,
    name = "Enable",
    default = false,
    save = false,
    id = "FlyEnabled",
    callback = function(state)
        if state ~= FlyEnabled then
            toggleFlight()
        end
    end
})

CreateBind({
    section = flyLeft,
    name = "Fly Bind",
    default = Enum.KeyCode.B,
    save = true,
    id = "FlyBind",
    callback = function(key)
        FlyToggleKey = key
    end
})

CreateSlider({
    section = flyLeft,
    name = "Fly Speed",
    min = 1,
    max = 500,
    default = FlightSpeed,
    save = true,
    id = "FlySpeed",
    callback = function(value)
        FlightSpeed = value
    end
})

CreateToggle({
    section = freeCamRight,
    name = "Enable",
    default = false,
    save = true,
    id = "FreeCamEnabled",
    callback = function(state)
        FreeCam.Enabled = state
        if not state and FreeCam.Active then
            toggleFreeCam()
        end
    end
})

CreateBind({
    section = freeCamRight,
    name = "Cam Bind",
    default = Enum.KeyCode.F2,
    save = false,
    id = "FreeCamBind",
    callback = function(key)
        FreeCam.Key = key
    end
})

CreateSlider({
    section = freeCamRight,
    name = "Speed",
    min = 1,
    max = 100,
    default = FreeCam.Speed,
    save = true,
    id = "FreeCamSpeed",
    callback = function(value)
        FreeCam.Speed = value
    end
})

CreateToggle({
    section = clickTPLeft,
    name = "Enable",
    default = false,
    save = true,
    id = "ClickTPEnabled",
    callback = function(state)
        ClickTP.Enabled = state
        if state then
            if ClickTP.Connection then
                ClickTP.Connection:Disconnect()
            end
            ClickTP.Connection = setupClickTP()
        else
            if ClickTP.Connection then
                ClickTP.Connection:Disconnect()
                ClickTP.Connection = nil
            end
        end
    end
})

CreateBind({
    section = clickTPLeft,
    name = "TP Key",
    default = Enum.KeyCode.LeftControl,
    save = true,
    id = "ClickTPKey",
    callback = function(key)
        ClickTP.Key = key
    end
})

-- Weapon Tab
local modsLeft = weapon:CreateSection("Mods", "left")
local applyRight = weapon:CreateSection("Apply", "right")


CreateToggle({
    section = modsLeft,
    name = "Inf Ammo",
    default = false,
    save = true,
    id = "WeaponInfAmmo",
    callback = function(state)
        weaponMods.infAmmo = state
    end
})



CreateToggle({
    section = modsLeft,
    name = "Fire Rate",
    default = false,
    save = true,
    id = "WeaponFireRate",
    callback = function(state)
        weaponMods.fireRate = state
    end
})

CreateToggle({
    section = modsLeft,
    name = "No Recoil",
    default = false,
    save = true,
    id = "WeaponNoRecoil",
    callback = function(state)
        weaponMods.noRecoil = state
    end
})

CreateToggle({
    section = modsLeft,
    name = "Rapid Fire",
    default = false,
    save = true,
    id = "WeaponRapidFire",
    callback = function(state)
        weaponMods.rapidFire = state
    end
})





CreateToggle({
    section = applyRight,
    name = "Loop",
    default = false,
    save = false,
    callback = function(state)
        if state then
            startWeaponLoop()
        else
            stopWeaponLoop()
        end
    end
})

CreateButton({
    section = applyRight,
    name = "Once",
    callback = function()
        applyWeaponMods()
    end
})

-- ESP System
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local playerEspEnabled = false
local teamCheck = false
local pwareEnabled = false
local playerEspCache = {}
local pwareUsernames = {}

local KENT_URL = "https://pizdecware.pw/kent/usernames"
local ENCRYPTION_KEY = "Kx9mP2vL8qR5nW3jF7tY1eU6oI4sA0zC"

local function base64_decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function xor_decrypt(encrypted_data, key)
    local decoded = base64_decode(encrypted_data)
    local result = ""
    for i = 1, #decoded do
        local key_index = ((i - 1) % #key) + 1
        local key_byte = key:byte(key_index)
        local data_byte = decoded:byte(i)
        local decrypt_byte = bit32.bxor(data_byte, key_byte)
        result = result .. string.char(decrypt_byte)
    end
    return result
end

local function getActiveUsernames()
    local success, encrypted_data = pcall(function()
        return game:HttpGet(KENT_URL)
    end)
    if not success then return {} end
    local decrypted = xor_decrypt(encrypted_data, ENCRYPTION_KEY)
    local usernames = HttpService:JSONDecode(decrypted)
    return usernames
end

local function updatePWareUsernames()
    while pwareEnabled do
        pwareUsernames = getActiveUsernames()
        for p, data in pairs(playerEspCache) do
            local isPWare = isPWarePlayer(p)
            if data.isPWare ~= isPWare then
                data.isPWare = isPWare
                local teamColor = p.Team and p.Team.TeamColor.Color or Color3.new(1, 1, 1)
                local highlightColor = isPWare and Color3.fromRGB(0, 255, 0) or teamColor
                if data.highlight then
                    data.highlight.FillColor = highlightColor
                    data.highlight.OutlineColor = highlightColor
                end
                if data.label then
                    data.label.TextColor3 = highlightColor
                end
            end
        end
        wait(5)
    end
end

local function isPWarePlayer(targetPlayer)
    if not targetPlayer then return false end
    for _, username in ipairs(pwareUsernames) do
        if targetPlayer.Name == username then return true end
    end
    return false
end

local function createHighlight(adornee, color, fillTransparency, outlineColor)
    if not adornee then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = fillTransparency
    highlight.OutlineColor = outlineColor or color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = adornee
    highlight.Enabled = true
    return highlight
end

local function getPlayerPosition(character)
    if not character or not character.Parent then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position end
    local head = character:FindFirstChild("Head")
    return head and head.Position or nil
end

local function getPlayerHealth(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and math.floor(humanoid.Health) or 0
end

local function setupPlayerESP(targetPlayer)
    if not targetPlayer or targetPlayer == player or not targetPlayer.Character then return end
    if playerEspCache[targetPlayer] then return end
    if teamCheck and targetPlayer.Team == player.Team then return end

    local character = targetPlayer.Character
    local position = getPlayerPosition(character)
    if not position then return end

    local mainContainer = Instance.new("ScreenGui")
    mainContainer.Name = "PlayerESP_Container_" .. targetPlayer.Name
    mainContainer.Parent = CoreGui
    
    local isPWare = isPWarePlayer(targetPlayer)
    local teamColor = targetPlayer.Team and targetPlayer.Team.TeamColor.Color or Color3.new(1, 1, 1)
    local highlightColor = isPWare and Color3.fromRGB(148, 0, 211) or teamColor
    
    local playerHighlight = createHighlight(character, highlightColor, 0.7, highlightColor)
    playerHighlight.Parent = mainContainer
    
    local head = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 150, 0, 35)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Parent = mainContainer

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansSemibold
        label.TextSize = 11
        label.TextColor3 = highlightColor
        label.TextStrokeTransparency = 0.5
        label.Parent = billboard

        playerEspCache[targetPlayer] = {
            mainContainer = mainContainer, 
            label = label, 
            position = position, 
            character = character,
            highlight = playerHighlight,
            isPWare = isPWare
        }
    end
end

local function cleanupPlayerESP(targetPlayer)
    local data = playerEspCache[targetPlayer]
    if not data then return end
    if data.mainContainer then data.mainContainer:Destroy() end
    playerEspCache[targetPlayer] = nil
end

local function refreshPlayerESP()
    for p in pairs(playerEspCache) do
        cleanupPlayerESP(p)
    end

    if playerEspEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            setupPlayerESP(p)
        end
    end
end

local function updateLabels()
    if not CurrentCamera then return end
    local cameraPos = CurrentCamera.CFrame.Position
    
    for p, data in pairs(playerEspCache) do
        if not p or not p.Parent or not p.Character or not p.Character.Parent then
            cleanupPlayerESP(p)
        else
            local newPos = getPlayerPosition(data.character)
            if newPos and data.label then
                local distanceMeters = math.floor((newPos - cameraPos).Magnitude * 0.36)
                local health = getPlayerHealth(data.character)
                data.label.Text = string.format("%s | HP:%d | %dm", p.Name, health, distanceMeters)
            else
                cleanupPlayerESP(p)
            end
        end
    end
end

local function onPlayerAdded(p)
    p.CharacterAdded:Connect(function()
        cleanupPlayerESP(p)
        if playerEspEnabled then 
            task.wait(0.5)
            setupPlayerESP(p) 
        end
    end)
    if playerEspEnabled then
        task.wait(1)
        setupPlayerESP(p)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(cleanupPlayerESP)

for _, p in ipairs(Players:GetPlayers()) do 
    onPlayerAdded(p) 
end

RunService.Heartbeat:Connect(updateLabels)

-- ESP Tab
local espLeft = esp:CreateSection("ESP", "left")
local tankESPRight = esp:CreateSection("Tank ESP", "right")

-- Visual Tab
local pwareLeft = visual:CreateSection("PWare", "left")
local shootSoundRight = visual:CreateSection("Shoot Sound", "right")

CreateToggle({
    section = tankESPRight,
    name = "Tank Highlight",
    default = false,
    save = false,
    id = "TankHighlight",
    callback = function(state)
        if state then
            startTankHighlight()
        else
            stopTankHighlight()
        end
    end
})

CreateToggle({
    section = tankESPRight,
    name = "Ignore Team",
    default = false,
    save = false,
    id = "TankIgnoreTeam",
    callback = function(state)
        tankHighlightSettings.ignoreTeam = state
        updateAllTankHighlights()
    end
})

CreateSlider({
    section = tankESPRight,
    name = "Fill Transparency",
    min = 0,
    max = 100,
    default = 20,
    suffix = "%",
    save = true,
    id = "TankFillTransparency",
    callback = function(value)
        tankHighlightSettings.fillTransparency = value / 100
        updateAllTankHighlights()
    end
})

CreateToggle({
    section = espLeft,
    name = "Enable",
    default = false,
    save = true,
    id = "EnablePlayerESP",
    callback = function(state)
        playerEspEnabled = state
        refreshPlayerESP()
    end
})

CreateToggle({
    section = espLeft,
    name = "Team Check",
    default = false,
    save = true,
    id = "ESPTeamCheck",
    callback = function(state)
        teamCheck = state
        refreshPlayerESP()
    end
})



CreateToggle({
    section = pwareLeft,
    name = "Lighting",
    default = false,
    save = true,
    id = "PWLighting",
    callback = function(state)
        local Lighting = game:GetService("Lighting")
        local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
        
        if not colorCorrection then
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Name = "ColorCorrection"
            colorCorrection.Parent = Lighting
        end
        
        if state then
            colorCorrection.TintColor = Color3.fromRGB(170, 0, 255)
        else
            colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        end
    end
})

CreateToggle({
    section = pwareLeft,
    name = "Ruka Blood",
    default = false,
    save = true,
    id = "RukaBlood",
    callback = function(state)
        if state then
            startRukaBlood()
        else
            stopRukaBlood()
        end
    end
})

CreateInput({
    section = shootSoundRight,
    name = "Sound ID",
    placeholder = "Enter sound id...",
    default = customSoundID,
    save = true,
    id = "ShootSoundID",
    callback = function(text)
        customSoundID = text
    end
})



-- Применяем звук если переключатель включен
spawn(function()
    wait(0.5)
    local savedToggleState = ui.settings and ui.settings.ChangeShootSound or false
    if savedToggleState and customSoundID ~= "" then
        shootSoundActive = true
        for _, obj in pairs(workspace.Camera:GetDescendants()) do
            if obj.Name == "Fire" and obj:IsA("Sound") then
                obj.SoundId = "rbxassetid://" .. customSoundID
                obj.MaxDistance = 6000
                obj:SetAttribute("RollOffMaxDistance", 6000)
                obj:SetAttribute("RollOffMinDistance", 6000)
                processedSounds[obj] = true
            end
        end
        
        shootSoundConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not shootSoundActive then
                shootSoundConnection:Disconnect()
                return
            end
            
            for _, obj in pairs(workspace.Camera:GetDescendants()) do
                if obj.Name == "Fire" and obj:IsA("Sound") and not processedSounds[obj] and customSoundID ~= "" then
                    obj.SoundId = "rbxassetid://" .. customSoundID
                    obj.MaxDistance = 6000
                    obj:SetAttribute("RollOffMaxDistance", 6000)
                    obj:SetAttribute("RollOffMinDistance", 6000)
                    processedSounds[obj] = true
                end
            end
        end)
    end
end)

CreateToggle({
    section = shootSoundRight,
    name = "Change Sound",
    default = false,
    save = true,
    id = "ChangeShootSound",
    callback = function(state)
        shootSoundActive = state
        processedSounds = {}
        
        if state and customSoundID ~= "" then
            for _, obj in pairs(workspace.Camera:GetDescendants()) do
                if obj.Name == "Fire" and obj:IsA("Sound") then
                    obj.SoundId = "rbxassetid://" .. customSoundID
                    obj.MaxDistance = 6000
                    obj:SetAttribute("RollOffMaxDistance", 6000)
                    obj:SetAttribute("RollOffMinDistance", 6000)
                    processedSounds[obj] = true
                end
            end
            
            shootSoundConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not shootSoundActive then
                    shootSoundConnection:Disconnect()
                    return
                end
                
                for _, obj in pairs(workspace.Camera:GetDescendants()) do
                    if obj.Name == "Fire" and obj:IsA("Sound") and not processedSounds[obj] and customSoundID ~= "" then
                        obj.SoundId = "rbxassetid://" .. customSoundID
                        obj.MaxDistance = 6000
                        obj:SetAttribute("RollOffMaxDistance", 6000)
                        obj:SetAttribute("RollOffMinDistance", 6000)
                        processedSounds[obj] = true
                    end
                end
            end)
        else
            if shootSoundConnection then
                shootSoundConnection:Disconnect()
                shootSoundConnection = nil
            end
        end
    end
})

