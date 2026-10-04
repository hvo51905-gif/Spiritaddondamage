-- ============================================
-- FTKQUIKCIRAHUB - FULL TECH TSGB
-- English Version
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================
-- STATE
-- ============================================
local autoLoopDash = false
local autoSupa = false
local autoLethal = false
local autoTwisted = false
local autoKyoto = false
local autoM1Reset = false
local autoBackDash = false
local autoCounter = false
local autoBlock = false

local lastDash = 0
local lastM1 = 0
local lastBlock = 0

-- ============================================
-- GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FTKQUIKCIRAHUB"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "⚡"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 25)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 420)
mainFrame.Position = UDim2.new(0, 80, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Text = "⚡ FTKQUIKCIRAHUB - TSB TECHS"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -10, 1, -45)
content.Position = UDim2.new(0, 5, 0, 35)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = mainFrame

local function createButton(text, yPos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Position = UDim2.new(0, 5, 0, yPos)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local y = 5
local loopDashBtn = createButton("AUTO LOOP DASH: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local supaBtn = createButton("AUTO SUPA DASH: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local lethalBtn = createButton("AUTO LETHAL DASH: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local twistedBtn = createButton("AUTO TWISTED: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local kyotoBtn = createButton("AUTO KYOTO: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local m1ResetBtn = createButton("M1 RESET: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local backDashBtn = createButton("BACK DASH CANCEL: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local counterBtn = createButton("AUTO COUNTER: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34
local blockBtn = createButton("AUTO BLOCK: OFF", y, Color3.fromRGB(200, 50, 50)); y = y + 34

content.CanvasSize = UDim2.new(0, 0, 0, y + 10)

-- Toggle menu visibility
local menuVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    mainFrame.Visible = menuVisible
end)

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- AUTO LOOP DASH
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoLoopDash then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastDash > 0.15 then
                lastDash = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- AUTO SUPA DASH
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoSupa then
        local hum = getHumanoid()
        local root = getRoot()
        if hum and root then
            local now = tick()
            if now - lastDash > 0.2 then
                lastDash = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- AUTO LETHAL DASH
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoLethal then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastDash > 0.18 then
                lastDash = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- AUTO TWISTED
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoTwisted then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastDash > 0.25 then
                lastDash = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- AUTO KYOTO
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoKyoto then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastM1 > 0.12 then
                lastM1 = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- M1 RESET
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoM1Reset then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastM1 > 0.1 then
                lastM1 = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- BACK DASH CANCEL
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoBackDash then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastDash > 0.2 then
                lastDash = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- AUTO COUNTER
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoCounter then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastBlock > 0.08 then
                lastBlock = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- AUTO BLOCK
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoBlock then
        local hum = getHumanoid()
        if hum then
            local now = tick()
            if now - lastBlock > 0.05 then
                lastBlock = now
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end
end)

-- ============================================
-- BUTTON EVENTS
-- ============================================
loopDashBtn.MouseButton1Click:Connect(function()
    autoLoopDash = not autoLoopDash
    loopDashBtn.Text = "AUTO LOOP DASH: " .. (autoLoopDash and "ON" or "OFF")
    loopDashBtn.BackgroundColor3 = autoLoopDash and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

supaBtn.MouseButton1Click:Connect(function()
    autoSupa = not autoSupa
    supaBtn.Text = "AUTO SUPA DASH: " .. (autoSupa and "ON" or "OFF")
    supaBtn.BackgroundColor3 = autoSupa and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

lethalBtn.MouseButton1Click:Connect(function()
    autoLethal = not autoLethal
    lethalBtn.Text = "AUTO LETHAL DASH: " .. (autoLethal and "ON" or "OFF")
    lethalBtn.BackgroundColor3 = autoLethal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

twistedBtn.MouseButton1Click:Connect(function()
    autoTwisted = not autoTwisted
    twistedBtn.Text = "AUTO TWISTED: " .. (autoTwisted and "ON" or "OFF")
    twistedBtn.BackgroundColor3 = autoTwisted and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

kyotoBtn.MouseButton1Click:Connect(function()
    autoKyoto = not autoKyoto
    kyotoBtn.Text = "AUTO KYOTO: " .. (autoKyoto and "ON" or "OFF")
    kyotoBtn.BackgroundColor3 = autoKyoto and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

m1ResetBtn.MouseButton1Click:Connect(function()
    autoM1Reset = not autoM1Reset
    m1ResetBtn.Text = "M1 RESET: " .. (autoM1Reset and "ON" or "OFF")
    m1ResetBtn.BackgroundColor3 = autoM1Reset and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

backDashBtn.MouseButton1Click:Connect(function()
    autoBackDash = not autoBackDash
    backDashBtn.Text = "BACK DASH CANCEL: " .. (autoBackDash and "ON" or "OFF")
    backDashBtn.BackgroundColor3 = autoBackDash and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

counterBtn.MouseButton1Click:Connect(function()
    autoCounter = not autoCounter
    counterBtn.Text = "AUTO COUNTER: " .. (autoCounter and "ON" or "OFF")
    counterBtn.BackgroundColor3 = autoCounter and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

blockBtn.MouseButton1Click:Connect(function()
    autoBlock = not autoBlock
    blockBtn.Text = "AUTO BLOCK: " .. (autoBlock and "ON" or "OFF")
    blockBtn.BackgroundColor3 = autoBlock and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

print("[FTKQUIKCIRAHUB] Loaded successfully!")
