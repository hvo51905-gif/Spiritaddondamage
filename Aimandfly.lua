-- ============================================
-- COMBINED SCRIPT: Fly + Aimbot + Silent Aim + FOV
-- Mobile & PC Friendly
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- ============================================
-- STATE
-- ============================================
local flying = false
local aimbotEnabled = false
local silentAimEnabled = false
local fovValue = 100

local bodyVelocity, bodyGyro
local flySpeed = 80
local minFlySpeed = 80
local maxFlySpeed = 200
local flyStep = 10

-- ============================================
-- GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombinedGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 320)
mainFrame.Position = UDim2.new(0, 20, 0.3, -160)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Draggable
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Helper: Create Button
local function createButton(text, yPos, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 32)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

-- Helper: Create Label
local function createLabel(text, yPos, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame
    return label
end

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 120, 0, 24)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Text = "⚡ SPIRIT MENU"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Buttons
local flyButton = createButton("FLY: OFF", 35, Color3.fromRGB(200, 50, 50))
local speedUpButton = createButton("SPEED +", 72, Color3.fromRGB(50, 150, 50))
local speedDownButton = createButton("SPEED -", 109, Color3.fromRGB(50, 100, 200))
local aimbotButton = createButton("AIMBOT: OFF", 146, Color3.fromRGB(200, 50, 50))
local silentButton = createButton("SILENT: OFF", 183, Color3.fromRGB(200, 50, 50))
local fovUpButton = createButton("FOV +", 220, Color3.fromRGB(150, 100, 200))
local fovDownButton = createButton("FOV -", 257, Color3.fromRGB(150, 100, 200))

-- Info Label
local infoLabel = createLabel("Speed: 80 | FOV: 100", 294, Color3.fromRGB(200, 200, 200))

-- ============================================
-- FOV CIRCLE
-- ============================================
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovValue, 0, fovValue)
fovCircle.Position = UDim2.new(0.5, -fovValue/2, 0.5, -fovValue/2)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = Color3.fromRGB(0, 255, 0)
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local function updateFovCircle()
    fovCircle.Size = UDim2.new(0, fovValue, 0, fovValue)
    fovCircle.Position = UDim2.new(0.5, -fovValue/2, 0.5, -fovValue/2)
end

-- ============================================
-- FLY FUNCTIONS
-- ============================================
local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

local function startFly()
    if flying or not humanoidRootPart then return end
    flying = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = humanoidRootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.Parent = humanoidRootPart

    flyButton.Text = "FLY: ON"
    flyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
end

local function stopFly()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    bodyVelocity, bodyGyro = nil, nil

    flyButton.Text = "FLY: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

local function toggleFly()
    if flying then stopFly() else startFly() end
end

-- ============================================
-- AIMBOT / SILENT AIM
-- ============================================
local function getClosestTarget()
    local closest = nil
    local shortestDist = fovValue

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            if otherHrp and humanoid and humanoid.Health > 0 then
                local screenPoint, onScreen = camera:WorldToViewportPoint(otherHrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = otherHrp
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot loop (camera locks onto target)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
    end
end)

-- Silent Aim (hitbox redirect when shooting)
local function silentAimHook()
    if silentAimEnabled then
        local target = getClosestTarget()
        if target then
            return target
        end
    end
    return nil
end

-- Hook mouse hit for silent aim
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if silentAimEnabled and not checkcaller() then
        if (self == mouse or self == player:GetMouse()) and (key == "Hit" or key == "Target") then
            local target = silentAimHook()
            if target then
                return target
            end
        end
    end
    return oldIndex(self, key)
end)

-- ============================================
-- BUTTON EVENTS
-- ============================================
flyButton.MouseButton1Click:Connect(toggleFly)

speedUpButton.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed + flyStep, minFlySpeed, maxFlySpeed)
    infoLabel.Text = "Speed: " .. flySpeed .. " | FOV: " .. fovValue
end)

speedDownButton.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed - flyStep, minFlySpeed, maxFlySpeed)
    infoLabel.Text = "Speed: " .. flySpeed .. " | FOV: " .. fovValue
end)

aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimbotButton.Text = "AIMBOT: ON"
        aimbotButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        aimbotButton.Text = "AIMBOT: OFF"
        aimbotButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

silentButton.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        silentButton.Text = "SILENT: ON"
        silentButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        silentButton.Text = "SILENT: OFF"
        silentButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

fovUpButton.MouseButton1Click:Connect(function()
    fovValue = math.clamp(fovValue + 10, 10, 200)
    updateFovCircle()
    infoLabel.Text = "Speed: " .. flySpeed .. " | FOV: " .. fovValue
end)

fovDownButton.MouseButton1Click:Connect(function()
    fovValue = math.clamp(fovValue - 10, 10, 200)
    updateFovCircle()
    infoLabel.Text = "Speed: " .. flySpeed .. " | FOV: " .. fovValue
end)

-- ============================================
-- KEYBOARD SHORTCUTS (PC)
-- ============================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus then
        flySpeed = math.clamp(flySpeed + flyStep, minFlySpeed, maxFlySpeed)
        infoLabel.Text = "Speed: " .. flySpeed .. " | FOV: " .. fovValue
    end
    if input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
        flySpeed = math.clamp(flySpeed - flyStep, minFlySpeed, maxFlySpeed)
        infoLabel.Text = "Speed: " .. flySpeed .. " | FOV: " .. fovValue
    end
end)

-- ============================================
-- FLY LOOP
-- ============================================
RunService.Heartbeat:Connect(function()
    if flying and bodyVelocity and bodyGyro then
        local lookDirection = camera.CFrame.LookVector
        bodyVelocity.Velocity = lookDirection * flySpeed
        bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + lookDirection)
    end
end)

-- ============================================
-- RESPAWN HANDLING
-- ============================================
player.CharacterAdded:Connect(function(newCharacter)
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    stopFly()
end)
