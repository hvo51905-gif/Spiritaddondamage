-- ============================================
-- FLING THINGS AND PEOPLE - SCRIPT
-- Features:
--   Auto Fling, Super Throw, Anti-Grab
--   Silent Aim, ESP
--   FOV 0-180 (RED circle at center)
--   Range 0-200m
--   Stats panel
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIG
local autoFlingEnabled = false
local superThrowEnabled = false
local antiGrabEnabled = false
local silentAimEnabled = false
local espEnabled = false
local fovRadius = 80
local minFov = 0
local maxFov = 180
local fovStep = 5
local aimRange = 200
local minRange = 0
local maxRange = 200
local rangeStep = 10
local superThrowPower = 5
local flingDelay = 0.1

local currentTargetName = "None"
local currentTargetDist = 0

local function getCamera()
    local cam = Workspace.CurrentCamera
    if cam and cam.Parent then return cam end
    return nil
end

-- ============================================
-- GUI
-- ============================================
local screenGui, notifyLabel, autoFlingBtn, superThrowBtn, antiGrabBtn, silentBtn, espBtn
local fovCircle, rangeLabel, fovLabel, statsLabel

pcall(function()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlingUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player:WaitForChild("PlayerGui", 10)

    -- ============================================
    -- FOV CIRCLE (RED) - LUÔN Ở GIỮA MÀN HÌNH
    -- ============================================
    fovCircle = Instance.new("Frame")
    fovCircle.Name = "FovCircle"
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 4
    fovCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
    fovCircle.ZIndex = 9999
    fovCircle.Visible = true
    fovCircle.Parent = screenGui
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

    local fovStroke = Instance.new("UIStroke")
    fovStroke.Color = Color3.fromRGB(255, 0, 0)
    fovStroke.Thickness = 2
    fovStroke.Transparency = 0.3
    fovStroke.Parent = fovCircle

    -- Notification
    notifyLabel = Instance.new("TextLabel")
    notifyLabel.Size = UDim2.new(0, 300, 0, 50)
    notifyLabel.Position = UDim2.new(0.5, -150, 0.05, 0)
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
        b.Size = UDim2.new(0, 140, 0, 32)
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

    autoFlingBtn = makeBtn("AUTO FLING: OFF", 0, Color3.fromRGB(200, 50, 50))
    superThrowBtn = makeBtn("SUPER THROW: OFF", 35, Color3.fromRGB(200, 50, 50))
    antiGrabBtn = makeBtn("ANTI-GRAB: OFF", 70, Color3.fromRGB(200, 50, 50))
    silentBtn = makeBtn("SILENT AIM: OFF", 105, Color3.fromRGB(200, 50, 50))
    espBtn = makeBtn("ESP: OFF", 140, Color3.fromRGB(200, 50, 50))

    rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0, 140, 0, 25)
    rangeLabel.Position = UDim2.new(0, 30, 0.3, 175)
    rangeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    rangeLabel.BackgroundTransparency = 0.4
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    rangeLabel.Text = "Range: 200m"
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Code
    rangeLabel.Parent = screenGui
    Instance.new("UICorner", rangeLabel).CornerRadius = UDim.new(0, 6)

    local rangeUpBtn = makeBtn("R +", 200, Color3.fromRGB(50, 150, 50))
    rangeUpBtn.Size = UDim2.new(0, 60, 0, 25)
    rangeUpBtn.Position = UDim2.new(0, 30, 0.3, 200)

    local rangeDownBtn = makeBtn("R -", 200, Color3.fromRGB(150, 50, 50))
    rangeDownBtn.Size = UDim2.new(0, 60, 0, 25)
    rangeDownBtn.Position = UDim2.new(0, 100, 0.3, 200)

    fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0, 140, 0, 25)
    fovLabel.Position = UDim2.new(0, 30, 0.3, 230)
    fovLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fovLabel.BackgroundTransparency = 0.4
    fovLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
    fovLabel.Text = "FOV: 80"
    fovLabel.TextScaled = true
    fovLabel.Font = Enum.Font.Code
    fovLabel.Parent = screenGui
    Instance.new("UICorner", fovLabel).CornerRadius = UDim.new(0, 6)

    local fovUpBtn = makeBtn("FOV +", 255, Color3.fromRGB(150, 50, 150))
    fovUpBtn.Size = UDim2.new(0, 60, 0, 25)
    fovUpBtn.Position = UDim2.new(0, 30, 0.3, 255)

    local fovDownBtn = makeBtn("FOV -", 255, Color3.fromRGB(100, 50, 100))
    fovDownBtn.Size = UDim2.new(0, 60, 0, 25)
    fovDownBtn.Position = UDim2.new(0, 100, 0.3, 255)

    statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0, 140, 0, 90)
    statsLabel.Position = UDim2.new(0, 30, 0.3, 285)
    statsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statsLabel.BackgroundTransparency = 0.4
    statsLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
    statsLabel.Text = "FOV: 80\nRange: 200m\nTarget: None\nDist: 0m"
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.Code
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Parent = screenGui
    Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 6)

    -- Events
    rangeUpBtn.MouseButton1Click:Connect(function()
        aimRange = math.clamp(aimRange + rangeStep, minRange, maxRange)
        rangeLabel.Text = "Range: " .. aimRange .. "m"
    end)
    rangeDownBtn.MouseButton1Click:Connect(function()
        aimRange = math.clamp(aimRange - rangeStep, minRange, maxRange)
        rangeLabel.Text = "Range: " .. aimRange .. "m"
    end)
    fovUpBtn.MouseButton1Click:Connect(function()
        fovRadius = math.clamp(fovRadius + fovStep, minFov, maxFov)
        fovLabel.Text = "FOV: " .. fovRadius
        fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    end)
    fovDownBtn.MouseButton1Click:Connect(function()
        fovRadius = math.clamp(fovRadius - fovStep, minFov, maxFov)
        fovLabel.Text = "FOV: " .. fovRadius
        fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    end)
end)

-- ============================================
-- STATS
-- ============================================
local function updateStats()
    pcall(function()
        if statsLabel and statsLabel.Parent then
            statsLabel.Text = string.format(
                "FOV: %d\nRange: %dm\nTarget: %s\nDist: %dm",
                fovRadius, aimRange, currentTargetName, math.floor(currentTargetDist)
            )
        end
    end)
end
task.spawn(function()
    while task.wait(0.25) do updateStats() end
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
-- TARGET FINDER
-- ============================================
local function getClosestPlayer()
    local cam = getCamera()
    if not cam then return nil end
    local closest, closestPlayer = nil, nil
    local shortest = fovRadius
    local screenCenter = cam.ViewportSize / 2
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, other in ipairs(Players:GetPlayers()) do
        pcall(function()
            if other ~= player and other.Character then
                local hrp = other.Character:FindFirstChild("HumanoidRootPart")
                local hum = other.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if myRoot then
                        local distM = (hrp.Position - myRoot.Position).Magnitude * 0.28
                        if distM > aimRange then return end
                    end
                    local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if d <= fovRadius and d < shortest then
                            shortest = d
                            closest = hrp
                            closestPlayer = other
                        end
                    end
                end
            end
        end)
    end

    if closest and closestPlayer and myRoot then
        currentTargetName = closestPlayer.Name
        currentTargetDist = (closest.Position - myRoot.Position).Magnitude * 0.28
    else
        currentTargetName = "None"
        currentTargetDist = 0
    end
    return closest, closestPlayer
end

-- ============================================
-- AUTO FLING
-- ============================================
task.spawn(function()
    while task.wait(flingDelay) do
        if autoFlingEnabled and player.Character then
            local target = getClosestPlayer()
            if target then
                pcall(function()
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        task.wait(0.05)
                        local cam = getCamera()
                        if cam then
                            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
                        end
                    end
                end)
            end
        end
    end
end)

-- ============================================
-- SUPER THROW
-- ============================================
RunService.Heartbeat:Connect(function()
    if superThrowEnabled and player.Character then
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("RopeConstraint") and v.Parent and v.Parent:IsDescendantOf(player.Character) then
                    v.Length = v.Length * superThrowPower
                end
            end
        end)
    end
end)

-- ============================================
-- ANTI-GRAB
-- ============================================
RunService.Heartbeat:Connect(function()
    if antiGrabEnabled and player.Character then
        pcall(function()
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("Constraint") then
                        local parent = v.Parent
                        if parent and not parent:IsDescendantOf(player.Character) then
                            v:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================
-- SILENT AIM
-- ============================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if silentAimEnabled and not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local target = getClosestPlayer()
            if target then
                local cam = getCamera()
                if cam then
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- ============================================
-- ESP
-- ============================================
local espCache = {}
local function createESP(plr)
    if espCache[plr] or not plr.Character then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
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

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                createESP(plr)
                local esp = espCache[plr]
                if esp and esp.Label then
                    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and hrp then
                        local distM = (hrp.Position - myRoot.Position).Magnitude * 0.28
                        esp.Label.Text = plr.Name .. " | " .. math.floor(distM) .. "m"
                    end
                end
            end
        end
    else
        for plr in pairs(espCache) do removeESP(plr) end
    end
end)

-- ============================================
-- BUTTON EVENTS
-- ============================================
pcall(function()
    autoFlingBtn.MouseButton1Click:Connect(function()
        autoFlingEnabled = not autoFlingEnabled
        autoFlingBtn.Text = "AUTO FLING: " .. (autoFlingEnabled and "ON" or "OFF")
        autoFlingBtn.BackgroundColor3 = autoFlingEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if autoFlingEnabled then showNotification("Auto Fling: ON") end
    end)
    superThrowBtn.MouseButton1Click:Connect(function()
        superThrowEnabled = not superThrowEnabled
        superThrowBtn.Text = "SUPER THROW: " .. (superThrowEnabled and "ON" or "OFF")
        superThrowBtn.BackgroundColor3 = superThrowEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if superThrowEnabled then showNotification("Super Throw: ON") end
    end)
    antiGrabBtn.MouseButton1Click:Connect(function()
        antiGrabEnabled = not antiGrabEnabled
        antiGrabBtn.Text = "ANTI-GRAB: " .. (antiGrabEnabled and "ON" or "OFF")
        antiGrabBtn.BackgroundColor3 = antiGrabEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if antiGrabEnabled then showNotification("Anti-Grab: ON") end
    end)
    silentBtn.MouseButton1Click:Connect(function()
        silentAimEnabled = not silentAimEnabled
        silentBtn.Text = "SILENT AIM: " .. (silentAimEnabled and "ON" or "OFF")
        silentBtn.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if silentAimEnabled then showNotification("Silent Aim: ON") end
    end)
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if espEnabled then showNotification("ESP: ON") end
    end)
end)

-- ============================================
-- PC KEYBINDS
-- ============================================
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Z then autoFlingEnabled = not autoFlingEnabled end
        if input.KeyCode == Enum.KeyCode.X then superThrowEnabled = not superThrowEnabled end
        if input.KeyCode == Enum.KeyCode.C then antiGrabEnabled = not antiGrabEnabled end
        if input.KeyCode == Enum.KeyCode.V then silentAimEnabled = not silentAimEnabled end
        if input.KeyCode == Enum.KeyCode.B then espEnabled = not espEnabled end
    end)
end)

print("[FlingUI] Loaded with RED FOV circle at center.")
