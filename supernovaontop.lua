-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Clean GUI Lama
pcall(function()
    if CoreGui:FindFirstChild("SimpleNameChanger") then
        CoreGui.SimpleNameChanger:Destroy()
    end
    if player.PlayerGui:FindFirstChild("SimpleNameChanger") then
        player.PlayerGui.SimpleNameChanger:Destroy()
    end
end)

-- 1. Buat ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleNameChanger"
screenGui.ResetOnSpawn = false

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 2. Frame Utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0.5, -120, 0.4, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "SUPERNOVA ON TOP (PERFECT)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.Parent = frame

-- Input Box
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.85, 0, 0, 35)
textBox.Position = UDim2.new(0.075, 0, 0, 40)
textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
textBox.PlaceholderText = "Ketik nama baru..."
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 12
textBox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = textBox

-- Execute Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.85, 0, 0, 35)
button.Position = UDim2.new(0.075, 0, 0, 85)
button.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
button.Text = "TERAPKAN NAMA"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 12
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = button

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- 3. LOGIKA OPTIMAL & SUPER RINGAN
local newName = ""

-- Fungsi untuk memeriksa & mengunci teks secara instant
local function processLabel(label)
    if not label:IsA("TextLabel") or label:IsDescendantOf(screenGui) then return end
    
    local text = label.Text
    local rawName = player.Name
    local dispName = player.DisplayName
    
    -- Cek jika teks mengandung nama asli kamu
    if text == rawName or text == dispName or string.find(string.lower(text), "kentoes") then
        if text ~= newName then
            pcall(function() label.Text = newName end)
        end
        
        -- Kunci Teks agar TIDAK BERUBAH saat tambah item di trade
        if not label:GetAttribute("NameLocked") then
            label:SetAttribute("NameLocked", true)
            label:GetPropertyChangedSignal("Text"):Connect(function()
                if newName ~= "" and label.Text ~= newName then
                    local currentText = label.Text
                    if currentText == rawName or currentText == dispName or string.find(string.lower(currentText), "kentoes") then
                        pcall(function() label.Text = newName end)
                    end
                end
            end)
        end
    end
end

-- Scan ringan ke area tertentu
local function updateAllNames()
    if newName == "" then return end
    
    -- 1. Tampilan Atas Kepala (Workspace Character)
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.DisplayName = newName end) end
        
        for _, obj in ipairs(player.Character:GetDescendants()) do
            processLabel(obj)
        end
    end
    
    -- 2. Tampilan UI Game & Trade (PlayerGui)
    local pGui = player:FindFirstChild("PlayerGui")
    if pGui then
        for _, obj in ipairs(pGui:GetDescendants()) do
            processLabel(obj)
        end
    end
end

-- Tombol Terapkan
button.MouseButton1Click:Connect(function()
    if textBox.Text ~= "" then
        newName = textBox.Text
        button.Text = "NAMA TERKUNCI!"
        updateAllNames()
        task.wait(1)
        button.Text = "TERAPKAN NAMA"
    end
end)

-- Pasang Event Listener Ringan untuk UI Baru (Menu Trade Muncul)
local playerGui = player:WaitForChild("PlayerGui")
playerGui.DescendantAdded:Connect(function(descendant)
    if newName ~= "" then
        task.defer(function()
            processLabel(descendant)
        end)
    end
end)

-- Pantau saat Karakter Respawn
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    updateAllNames()
end)
