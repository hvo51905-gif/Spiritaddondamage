-- ============================================
-- FLY (WASD) + ESP + SPEED - UNIVERSAL SCRIPT
-- Fly: W/A/S/D + Space (up) + Shift (down)
-- ESP: Name + Distance
-- Speed: 1-100 (WalkSpeed)
-- Mobile toggle buttons, error-proof
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- CONFIG
local flying = false
local espEnabled = false
local flySpeed = 80
local minFlySpeed = 20
local maxFlySpeed = 300
local flySpeedStep = 10

local walkSpeed = 16
local minWalkSpeed = 1
local maxWalkSpeed = 100
local walkSpeedStep = 5

local bodyVelocity, bodyGyro
local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local espCache = {}

local keysDown = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

-- ============================================
-- GUI
-- ============================================
local screenGui, notifyLabel, flyBtn, espBtn, flySpeedUpBtn, flySpeedDownBtn, flySpeedLabel
local speedUpBtn, speedDownBtn, speedLabel

pcall(function()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlyEspUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player:WaitForChild("PlayerGui", 10)

    notifyLabel = Instance.new("TextLabel")
    notifyLabel.Size = UDim2.new(0, 300, 0, 45)
    notifyLabel.Position = UDim2.new(0.5, -150, 0.08, 0)
    notifyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifyLabel.BackgroundTransparency = 0.3
    notifyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    notifyLabel.Text = "Activated"
    notifyLabel.TextScaled = true
    notifyLabel.Font = Enum.Font.GothamBold
    notifyLabel.Visible = false
    notifyLabel.Parent = screenGui
    Instance.new("UICorner", notifyLabel).CornerRadius = UDim.new(0, 8)

    local function makeBtn(text, yPos, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 150, 0, 38)
        b.Position = UDim2.new(0, 30, 0.3, yPos)
        b.BackgroundColor3 = color
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Text = text
        b.TextScaled = true
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.Parent = screenGui
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    local function makeLabel(text, yPos, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0, 150, 0, 22)
        l.Position = UDim2.new(0, 30, 0.3, yPos)
        l.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        l.BackgroundTransparency = 0.4
        l.TextColor3 = color
        l.Text = text
        l.TextScaled = true
        l.Font = Enum.Font.Code
        l.Parent = screenGui
        Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)
        return l
    end

    flyBtn = makeBtn("FLY: OFF", 0, Color3.fromRGB(200, 50, 50))
    espBtn = makeBtn("ESP: OFF", 42, Color3.fromRGB(200, 50, 50))

    flySpeedUpBtn = makeBtn("FLY SPEED +", 84, Color3.fromRGB(50, 150, 50))
    flySpeedDownBtn = makeBtn("FLY SPEED -", 126, Color3.fromRGB(150, 50, 50))
    flySpeedLabel = makeLabel("Fly Speed: 80", 168, Color3.fromRGB(255, 255, 0))

    speedUpBtn = makeBtn("SPEED +", 195, Color3.fromRGB(50, 150, 200))
    speedDownBtn = makeBtn("SPEED -", 237, Color3.fromRGB(100, 50, 150))
    speedLabel = makeLabel("Speed: 16", 279, Color3.fromRGB(100, 255, 255))
end)

-- ============================================
-- NOTIFICATION
-- ============================================
local function showNotification(text)
    pcall(function()
        if notifyLabel and notifyLabel.Parent then
            notifyLabel.Text = text
            notifyLabel.Visible = true
            task.delay(1, function()
                pcall(function()
                    if notifyLabel and notifyLabel.Parent then
                        notifyLabel.Visible = false
                    end
                end)
            end)
        end
    end)
end

-- ============================================
-- FLY
-- ============================================
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
    pcall(function()
        if flyBtn then
            flyBtn.Text = "FLY: ON"
            flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        end
    end)
end

local function stopFly()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    bodyVelocity, bodyGyro = nil, nil
    pcall(function()
        if flyBtn then
            flyBtn.Text = "FLY: OFF"
            flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
end

local function toggleFly()
    if flying then stopFly() else startFly() end
    if flying then showNotification("Fly: ON") end
end

-- ============================================
-- ESP
-- ============================================
local function createESP(plr)
    if espCache[plr] or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0
    label.Text = plr.Name
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    espCache[plr] = {Billboard = billboard, Label = label}
end

local function removeESP(plr)
    if espCache[plr] then
        pcall(function() espCache[plr].Billboard:Destroy() end)
        espCache[plr] = nil
    end
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            createESP(plr)
            local esp = espCache[plr]
            local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if esp and esp.Label and myRoot and hrp then
                local dist = (hrp.Position - myRoot.Position).Magnitude * 0.28
                esp.Label.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
            end
        else
            removeESP(plr)
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    pcall(function()
        if espBtn then
            espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
            espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end
    end)
    if espEnabled then
        showNotification("ESP: ON")
    else
        for plr in pairs(espCache) do removeESP(plr) end
    end
end

RunService.RenderStepped:Connect(function()
    if espEnabled then updateESP() end
end)

-- ============================================
-- SPEED (WalkSpeed)
-- ============================================
local function applySpeed()
    pcall(function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeed
        end
    end)
end

-- ============================================
-- BUTTON EVENTS
-- ============================================
pcall(function()
    flyBtn.MouseButton1Click:Connect(toggleFly)
    espBtn.MouseButton1Click:Connect(toggleESP)

    flySpeedUpBtn.MouseButton1Click:Connect(function()
        flySpeed = math.clamp(flySpeed + flySpeedStep, minFlySpeed, maxFlySpeed)
        flySpeedLabel.Text = "Fly Speed: " .. flySpeed
    end)
    flySpeedDownBtn.MouseButton1Click:Connect(function()
        flySpeed = math.clamp(flySpeed - flySpeedStep, minFlySpeed, maxFlySpeed)
        flySpeedLabel.Text = "Fly Speed: " .. flySpeed
    end)

    speedUpBtn.MouseButton1Click:Connect(function()
        walkSpeed = math.clamp(walkSpeed + walkSpeedStep, minWalkSpeed, maxWalkSpeed)
        speedLabel.Text = "Speed: " .. walkSpeed
        applySpeed()
    end)
    speedDownBtn.MouseButton1Click:Connect(function()
        walkSpeed = math.clamp(walkSpeed - walkSpeedStep, minWalkSpeed, maxWalkSpeed)
        speedLabel.Text = "Speed: " .. walkSpeed
        applySpeed()
    end)
end)

-- ============================================
-- KEYBOARD INPUT
-- ============================================
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.W then keysDown.W = true end
        if key == Enum.KeyCode.A then keysDown.A = true end
        if key == Enum.KeyCode.S then keysDown.S = true end
        if key == Enum.KeyCode.D then keysDown.D = true end
        if key == Enum.KeyCode.Space then keysDown.Space = true end
        if key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then keysDown.Shift = true end

        if key == Enum.KeyCode.F then toggleFly() end
        if key == Enum.KeyCode.G then toggleESP() end
        if key == Enum.KeyCode.Equals or key == Enum.KeyCode.KeypadPlus then
            flySpeed = math.clamp(flySpeed + flySpeedStep, minFlySpeed, maxFlySpeed)
            pcall(function() flySpeedLabel.Text = "Fly Speed: " .. flySpeed end)
        end
        if key == Enum.KeyCode.Minus or key == Enum.KeyCode.KeypadMinus then
            flySpeed = math.clamp(flySpeed - flySpeedStep, minFlySpeed, maxFlySpeed)
            pcall(function() flySpeedLabel.Text = "Fly Speed: " .. flySpeed end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        local key = input.KeyCode
        if key == Enum.KeyCode.W then keysDown.W = false end
        if key == Enum.KeyCode.A then keysDown.A = false end
        if key == Enum.KeyCode.S then keysDown.S = false end
        if key == Enum.KeyCode.D then keysDown.D = false end
        if key == Enum.KeyCode.Space then keysDown.Space = false end
        if key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then keysDown.Shift = false end
    end)
end)

-- ============================================
-- FLY LOOP (WASD)
-- ============================================
RunService.Heartbeat:Connect(function()
    if flying and bodyVelocity and bodyGyro and humanoidRootPart then
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector

        local move = Vector3.zero
        if keysDown.W then move = move + forward end
        if keysDown.S then move = move - forward end
        if keysDown.D then move = move + right end
        if keysDown.A then move = move - right end
        if keysDown.Space then move = move + Vector3.new(0, 1, 0) end
        if keysDown.Shift then move = move - Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            bodyVelocity.Velocity = move.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end
        bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + forward)
    end
end)

-- ============================================
-- RESPAWN
-- ============================================
player.CharacterAdded:Connect(function(newChar)
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    stopFly()
    task.wait(0.5)
    applySpeed()
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then createESP(plr) end
        end
    end
end)

print("[FlyEspUI] Loaded. F = Fly, G = ESP, WASD = move, +/- = fly speed, Speed buttons = WalkSpeed 1-100.")
