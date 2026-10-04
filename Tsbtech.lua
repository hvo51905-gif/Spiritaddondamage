-- ============================================
-- TAB TSGB - FULL TECHS (SparkHub)
-- ============================================
local tsgbTab = tabContents[3] -- Tab thứ 3 là TSGB
local y = 5

-- Nút load SparkHub (chứa đầy đủ tech bạn cần)
local loadSparkButton = createButton(tsgbTab, "🔥 LOAD SPARKHUB (FULL TECHS)", y, Color3.fromRGB(200, 100, 50)); y = y + 32

loadSparkButton.MouseButton1Click:Connect(function()
    loadSparkButton.Text = "⏳ ĐANG LOAD..."
    loadSparkButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ultimatep568/Spark-Hub/refs/heads/main/SparkHub_Loader.lua"))()
    end)
    
    if success then
        loadSparkButton.Text = "✅ ĐÃ LOAD SPARKHUB"
        loadSparkButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        print("[Spirit Menu] SparkHub loaded!")
    else
        loadSparkButton.Text = "❌ LỖI LOAD"
        loadSparkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        warn("[Spirit Menu] Load failed: " .. tostring(err))
    end
end)

-- Các nút tech hiển thị (chỉ để tham khảo, không cần code riêng)
local supaTechButton = createButton(tsgbTab, "SUPA TECH: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local kyotoTechButton = createButton(tsgbTab, "KYOTO TECH: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local twistedTechButton = createButton(tsgbTab, "TWISTED TECH: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local lethalTechButton = createButton(tsgbTab, "LETHAL DASH: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local m1ResetButton = createButton(tsgbTab, "M1 RESET: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local backDashButton = createButton(tsgbTab, "BACK DASH CANCEL: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local autoCounterButton = createButton(tsgbTab, "AUTO COUNTER: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32
local autoBlockButton = createButton(tsgbTab, "AUTO BLOCK: OFF", y, Color3.fromRGB(200,50,50)); y = y + 32

-- Nút load KittyWare (script dự phòng có Auto Tech, Auto Counter, M1 Reset)
local loadKittyButton = createButton(tsgbTab, "🐱 LOAD KITTYWARE (DỰ PHÒNG)", y, Color3.fromRGB(100, 150, 200)); y = y + 32

loadKittyButton.MouseButton1Click:Connect(function()
    loadKittyButton.Text = "⏳ ĐANG LOAD..."
    loadKittyButton.BackgroundColor3 = Color3.fromRGB(150, 150, 200)
    
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0mam0ri/KittyWare/refs/heads/main/obf.lua"))()
    end)
    
    if success then
        loadKittyButton.Text = "✅ ĐÃ LOAD KITTYWARE"
        loadKittyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        print("[Spirit Menu] KittyWare loaded!")
    else
        loadKittyButton.Text = "❌ LỖI LOAD"
        loadKittyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        warn("[Spirit Menu] KittyWare load failed: " .. tostring(err))
    end
end)

tsgbTab.CanvasSize = UDim2.new(0, 0, 0, y + 10)
