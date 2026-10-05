-- ============================================
-- AIMBOT HEAD LOCK - INSTANT SNAP - 80 PIXEL FOV
-- ERROR-PROOF VERSION
-- Locks camera instantly onto the closest player's Head within 80 pixels
-- Shows "Activated" notification for 1 second
-- Includes a draggable mobile toggle button
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIG
local aimbotEnabled = false
local fovRadius = 80
local aimPartName = "Head"

-- Safely get the current camera
local function getCamera()
    local cam = Workspace.CurrentCamera
    if cam and cam.Parent then
        return cam
    end
    return nil
end

-- ============================================
-- GUI (wrapped in pcall for safety)
-- ============================================
local screenGui, notifyLabel, toggleBtn

local ok, err = pcall(function()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui", 10)

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

    toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 140, 0, 60)
    toggleBtn.Position = UDim2.new(0, 30, 0.3, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Text = "AIM: OFF"
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = screenGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)
end)

if not ok then
    warn("[Aimbot] GUI creation failed: " .. tostring(err))
    return
end

-- ============================================
-- NOTIFICATION (safe)
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
-- DRAGGING (safe)
-- ============================================
pcall(function()
    local dragging, dragStart, startPos
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = toggleBtn.Position
        end
    end)
    toggleBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end)

-- ============================================
-- TOGGLE (safe)
-- ============================================
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    pcall(function()
        if toggleBtn and toggleBtn.Parent then
            toggleBtn.Text = "AIM: " .. (aimbotEnabled and "ON" or "OFF")
            toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end
    end)
    if aimbotEnabled then
        showNotification("Activated")
    end
end

pcall(function()
    toggleBtn.MouseButton1Click:Connect(toggleAimbot)
end)

-- ============================================
-- AIMBOT LOGIC (fully wrapped)
-- ============================================
local function getClosestHead()
    local cam = getCamera()
    if not cam then return nil end

    local closestHead = nil
    local shortestDist = fovRadius
    local screenCenter = cam.ViewportSize / 2

    local players
    local ok2, err2 = pcall(function()
        players = Players:GetPlayers()
    end)
    if not ok2 then return nil end

    for _, otherPlayer in ipairs(players) do
        local ok3 = pcall(function()
            if otherPlayer ~= player and otherPlayer.Character then
                local head = otherPlayer.Character:FindFirstChild(aimPartName)
                local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                if head and head:IsA("BasePart") and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distToCenter <= fovRadius and distToCenter < shortestDist then
                            shortestDist = distToCenter
                            closestHead = head
                        end
                    end
                end
            end
        end)
        if not ok3 then
            -- skip this player, continue with next
        end
    end

    return closestHead
end

local function aimStep()
    if not aimbotEnabled then return end
    local ok, err = pcall(function()
        local cam = getCamera()
        if not cam then return end
        local targetHead = getClosestHead()
        if targetHead and targetHead.Parent then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetHead.Position)
        end
    end)
    if not ok then
        -- silently ignore errors to prevent crash
    end
end

-- Bind with error handling
local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 1
pcall(function()
    RunService:BindToRenderStep("AimbotHeadLock", AIM_PRIORITY, aimStep)
end)

-- ============================================
-- PC KEYBIND (F)
-- ============================================
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F then
            toggleAimbot()
        end
    end)
end)

-- ============================================
-- RESPAWN HANDLING
-- ============================================
pcall(function()
    player.CharacterAdded:Connect(function()
        -- Keep aimbot state, just wait for new character
        task.wait(0.5)
    end)
end)

print("[Aimbot Head Lock] ERROR-PROOF loaded. Press F or tap AIM button.")
