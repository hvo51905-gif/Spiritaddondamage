-- ============================================
-- AIMBOT LOCK + SILENT AIM - FOV 80px RED
-- AIM LOCK: camera locks onto enemy Head
-- SILENT AIM: bullets snap to enemy Head without moving camera
-- Range: 20-200 studs (adjustable)
-- Mobile toggle buttons, error-proof
-- Stats panel showing live info
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIG
local aimLockEnabled = false
local silentAimEnabled = false
local fovRadius = 80
local aimPartName = "Head"
local aimRange = 200
local minRange = 20
local maxRange = 200
local rangeStep = 10

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
local screenGui, notifyLabel, aimLockBtn, silentBtn, fovCircle, rangeLabel, statsLabel

pcall(function()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player:WaitForChild("PlayerGui", 10)

    -- Notification
    notifyLabel = Instance.new("TextLabel")
    notifyLabel.Size = UDim2.new(0, 300, 0, 50)
    notifyLabel.Position = UDim2.new(0.5, -150, 0.1, 0)
    notifyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifyLabel.BackgroundTransparency = 0.3
    notifyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    notifyLabel.Text = "Activated"
    notifyLabel.TextScaled = true
    notifyLabel.Font = Enum.Font.GothamBold
    notifyLabel.Visible = false
    notifyLabel.Parent = screenGui
    Instance.new("UICorner", notifyLabel).CornerRadius = UDim.new(0, 8)

    -- FOV Circle (RED)
    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    fovCircle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 2
    fovCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
    fovCircle.Parent = screenGui
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

    -- AIM LOCK button
    aimLockBtn = Instance.new("TextButton")
    aimLockBtn.Size = UDim2.new(0, 140, 0, 50)
    aimLockBtn.Position = UDim2.new(0, 30, 0.3, 0)
    aimLockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    aimLockBtn.TextColor3 = Color3.new(1, 1, 1)
    aimLockBtn.Text = "AIM LOCK: OFF"
    aimLockBtn.TextScaled = true
    aimLockBtn.Font = Enum.Font.GothamBold
    aimLockBtn.BorderSizePixel = 0
    aimLockBtn.Parent = screenGui
    Instance.new("UICorner", aimLockBtn).CornerRadius = UDim.new(0, 12)

    -- SILENT AIM button
    silentBtn = Instance.new("TextButton")
    silentBtn.Size = UDim2.new(0, 140, 0, 50)
    silentBtn.Position = UDim2.new(0, 30, 0.3, 55)
    silentBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    silentBtn.TextColor3 = Color3.new(1, 1, 1)
    silentBtn.Text = "SILENT: OFF"
    silentBtn.TextScaled = true
    silentBtn.Font = Enum.Font.GothamBold
    silentBtn.BorderSizePixel = 0
    silentBtn.Parent = screenGui
    Instance.new("UICorner", silentBtn).CornerRadius = UDim.new(0, 12)

    -- Range label
    rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0, 140, 0, 30)
    rangeLabel.Position = UDim2.new(0, 30, 0.3, 110)
    rangeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    rangeLabel.BackgroundTransparency = 0.4
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    rangeLabel.Text = "Range: 200"
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Code
    rangeLabel.Parent = screenGui
    Instance.new("UICorner", rangeLabel).CornerRadius = UDim.new(0, 6)

    -- Range + button
    local rangeUpBtn = Instance.new("TextButton")
    rangeUpBtn.Size = UDim2.new(0, 60, 0, 30)
    rangeUpBtn.Position = UDim2.new(0, 30, 0.3, 145)
    rangeUpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    rangeUpBtn.TextColor3 = Color3.new(1, 1, 1)
    rangeUpBtn.Text = "R +"
    rangeUpBtn.TextScaled = true
    rangeUpBtn.Font = Enum.Font.GothamBold
    rangeUpBtn.BorderSizePixel = 0
    rangeUpBtn.Parent = screenGui
    Instance.new("UICorner", rangeUpBtn).CornerRadius = UDim.new(0, 6)

    -- Range - button
    local rangeDownBtn = Instance.new("TextButton")
    rangeDownBtn.Size = UDim2.new(0, 60, 0, 30)
    rangeDownBtn.Position = UDim2.new(0, 100, 0.3, 145)
    rangeDownBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    rangeDownBtn.TextColor3 = Color3.new(1, 1, 1)
    rangeDownBtn.Text = "R -"
    rangeDownBtn.TextScaled = true
    rangeDownBtn.Font = Enum.Font.GothamBold
    rangeDownBtn.BorderSizePixel = 0
    rangeDownBtn.Parent = screenGui
    Instance.new("UICorner", rangeDownBtn).CornerRadius = UDim.new(0, 6)

    -- STATS PANEL (new)
    statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0, 140, 0, 110)
    statsLabel.Position = UDim2.new(0, 30, 0.3, 180)
    statsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statsLabel.BackgroundTransparency = 0.4
    statsLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
    statsLabel.Text = "FOV: 80\nRange: 200\nAimLock: OFF\nSilent: OFF\nTarget: None\nDist: 0"
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.Code
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Parent = screenGui
    Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 6)

    -- Range button events
    rangeUpBtn.MouseButton1Click:Connect(function()
        aimRange = math.clamp(aimRange + rangeStep, minRange, maxRange)
        rangeLabel.Text = "Range: " .. aimRange
    end)
    rangeDownBtn.MouseButton1Click:Connect(function()
        aimRange = math.clamp(aimRange - rangeStep, minRange, maxRange)
        rangeLabel.Text = "Range: " .. aimRange
    end)
end)

-- ============================================
-- UPDATE STATS PANEL
-- ============================================
local function updateStats()
    pcall(function()
        if statsLabel and statsLabel.Parent then
            statsLabel.Text = string.format(
                "FOV: %d\nRange: %d\nAimLock: %s\nSilent: %s\nTarget: %s\nDist: %dm",
                fovRadius,
                aimRange,
                aimLockEnabled and "ON" or "OFF",
                silentAimEnabled and "ON" or "OFF",
                currentTargetName,
                math.floor(currentTargetDist)
            )
        end
    end)
end

-- Auto-update stats every 0.25s
task.spawn(function()
    while task.wait(0.25) do
        updateStats()
    end
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
-- DRAGGING
-- ============================================
pcall(function()
    local dragging, dragStart, startPos
    local function makeDraggable(btn)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = btn.Position
            end
        end)
        btn.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    makeDraggable(aimLockBtn)
    makeDraggable(silentBtn)
end)

-- ============================================
-- TOGGLES
-- ============================================
local function toggleAimLock()
    aimLockEnabled = not aimLockEnabled
    pcall(function()
        if aimLockBtn and aimLockBtn.Parent then
            aimLockBtn.Text = "AIM LOCK: " .. (aimLockEnabled and "ON" or "OFF")
            aimLockBtn.BackgroundColor3 = aimLockEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end
    end)
    if aimLockEnabled then
        showNotification("Aim Lock: ON")
    end
    updateStats()
end

local function toggleSilentAim()
    silentAimEnabled = not silentAimEnabled
    pcall(function()
        if silentBtn and silentBtn.Parent then
            silentBtn.Text = "SILENT: " .. (silentAimEnabled and "ON" or "OFF")
            silentBtn.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end
    end)
    if silentAimEnabled then
        showNotification("Silent Aim: ON")
    end
    updateStats()
end

pcall(function()
    aimLockBtn.MouseButton1Click:Connect(toggleAimLock)
    silentBtn.MouseButton1Click:Connect(toggleSilentAim)
end)

-- ============================================
-- TARGET FINDER
-- ============================================
local function getClosestHead()
    local cam = getCamera()
    if not cam then return nil end

    local closestHead = nil
    local closestPlayer = nil
    local shortestDist = fovRadius
    local screenCenter = cam.ViewportSize / 2

    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    local players
    local ok2 = pcall(function()
        players = Players:GetPlayers()
    end)
    if not ok2 then return nil end

    for _, otherPlayer in ipairs(players) do
        pcall(function()
            if otherPlayer ~= player and otherPlayer.Character then
                local head = otherPlayer.Character:FindFirstChild(aimPartName)
                local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                if head and head:IsA("BasePart") and humanoid and humanoid.Health > 0 then
                    if myRoot then
                        local distStuds = (head.Position - myRoot.Position).Magnitude
                        if distStuds > aimRange then return end
                    end
                    local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distToCenter <= fovRadius and distToCenter < shortestDist then
                            shortestDist = distToCenter
                            closestHead = head
                            closestPlayer = otherPlayer
                        end
                    end
                end
            end
        end)
    end

    -- Update stats with current target
    if closestHead and closestPlayer and myRoot then
        currentTargetName = closestPlayer.Name
        currentTargetDist = (closestHead.Position - myRoot.Position).Magnitude
    else
        currentTargetName = "None"
        currentTargetDist = 0
    end

    return closestHead
end

-- ============================================
-- AIM LOCK
-- ============================================
local function aimLockStep()
    if not aimLockEnabled then return end
    pcall(function()
        local cam = getCamera()
        if not cam then return end
        local target = getClosestHead()
        if target and target.Parent then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
        end
    end)
end

local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 1
pcall(function()
    RunService:BindToRenderStep("AimLockStep", AIM_PRIORITY, aimLockStep)
end)

-- ============================================
-- SILENT AIM
-- ============================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not silentAimEnabled then
        return oldNamecall(self, ...)
    end
    if checkcaller() then
        return oldNamecall(self, ...)
    end

    local method = getnamecallmethod()
    local args = {...}

    if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "Raycast" then
        local target = getClosestHead()
        if target then
            local cam = getCamera()
            if cam and typeof(args[1]) == "Ray" then
                local newRay = Ray.new(cam.CFrame.Position, (target.Position - cam.CFrame.Position).Unit * 1000)
                return oldNamecall(self, newRay, unpack(args, 2))
            end
        end
    end

    return oldNamecall(self, ...)
end)

pcall(function()
    local mouse = player:GetMouse()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if silentAimEnabled and not checkcaller() then
            if self == mouse and (key == "Hit" or key == "Target") then
                local target = getClosestHead()
                if target then
                    if key == "Hit" then
                        return CFrame.new(target.Position)
                    elseif key == "Target" then
                        return target
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
end)

-- ============================================
-- PC KEYBINDS
-- ============================================
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F then
            toggleAimLock()
        elseif input.KeyCode == Enum.KeyCode.G then
            toggleSilentAim()
        end
    end)
end)

print("[AimUI] AIM LOCK + SILENT AIM + STATS loaded. F = Aim Lock, G = Silent Aim.")
