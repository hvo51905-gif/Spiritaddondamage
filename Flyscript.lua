-- Mobile-Friendly Fly Script for Roblox
-- Controls:
--   [FLY] button      = Toggle Fly
--   [+] button        = Increase Speed (Max 200)
--   [-] button        = Decrease Speed (Min 80)
--   Keyboard: F = Toggle, + = Speed Up, - = Speed Down

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local bodyVelocity = nil
local bodyGyro = nil

local speed = 80
local minSpeed = 80
local maxSpeed = 200
local speedStep = 10

-- ============================
-- GUI
-- ============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 120, 0, 160)
mainFrame.Position = UDim2.new(0, 20, 0.5, -80)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

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

local function createButton(text, yPos, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 40)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    return button
end

local flyButton = createButton("FLY: OFF", 10, Color3.fromRGB(200, 50, 50))
local speedUpButton = createButton("SPEED +", 60, Color3.fromRGB(50, 150, 50))
local speedDownButton = createButton("SPEED -", 110, Color3.fromRGB(50, 100, 200))

-- ============================
-- FLY FUNCTIONS
-- ============================
local function startFly()
    if flying then return end
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
    bodyVelocity = nil
    bodyGyro = nil

    flyButton.Text = "FLY: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

local function toggleFly()
    if flying then stopFly() else startFly() end
end

local function increaseSpeed()
    speed = math.clamp(speed + speedStep, minSpeed, maxSpeed)
    print("Fly speed: " .. speed)
end

local function decreaseSpeed()
    speed = math.clamp(speed - speedStep, minSpeed, maxSpeed)
    print("Fly speed: " .. speed)
end

flyButton.MouseButton1Click:Connect(toggleFly)
speedUpButton.MouseButton1Click:Connect(increaseSpeed)
speedDownButton.MouseButton1Click:Connect(decreaseSpeed)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus then increaseSpeed() end
    if input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then decreaseSpeed() end
end)

RunService.Heartbeat:Connect(function()
    if flying and bodyVelocity and bodyGyro then
        local camera = workspace.CurrentCamera
        local lookDirection = camera.CFrame.LookVector
        bodyVelocity.Velocity = lookDirection * speed
        bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + lookDirection)
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    stopFly()
end)
