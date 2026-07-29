-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Bersihkan GUI lama jika ada
pcall(function()
    if CoreGui:FindFirstChild("SimpleNameChanger") then
        CoreGui.SimpleNameChanger:Destroy()
    end
    if player.PlayerGui:FindFirstChild("SimpleNameChanger") then
        player.PlayerGui.SimpleNameChanger:Destroy()
    end
end)

-- 1. Buat ScreenGui dengan aman
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleNameChanger"
screenGui.ResetOnSpawn = false

local success, err = pcall(function()
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
title.Text = "UBAH NAMA LOKAL (+ TRADE)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

-- Input Box
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.85, 0, 0, 35)
textBox.Position = UDim2.new(0.075, 0, 0, 40)
textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
textBox.PlaceholderText = "Ketik nama baru di sini..."
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

-- 3. Logika Pengubah Nama Lengkap (Workspace + PlayerGui / Trade Window)
local newName = ""

button.MouseButton1Click:Connect(function()
    if textBox.Text ~= "" then
        newName = textBox.Text
        button.Text = "BERHASIL DIATUR!"
        task.wait(1)
        button.Text = "TERAPKAN NAMA"
    end
end)

local function updateAllLabels()
    if newName == "" then return end
    
    -- A. Ubah Humanoid DisplayName
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            player.Character.Humanoid.DisplayName = newName
        end)
    end
    
    -- B. Cari TextLabel di Workspace (Atas Kepala)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") and (obj.Text == player.Name or obj.Text == player.DisplayName or string.find(string.lower(obj.Text), "kentoes")) then
            pcall(function() obj.Text = newName end)
        end
    end
    
    -- C. Cari TextLabel di PlayerGui (Termasuk Menu Trade & Pop-up UI)
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, guiObj in ipairs(playerGui:GetDescendants()) do
            if guiObj:IsA("TextLabel") and not guiObj:IsDescendantOf(screenGui) then
                if guiObj.Text == player.Name or guiObj.Text == player.DisplayName or string.find(string.lower(guiObj.Text), "kentoes") then
                    pcall(function() guiObj.Text = newName end)
                end
            end
        end
    end
end

-- Loop cepat (0.2s) untuk merespon munculnya menu Trade
task.spawn(function()
    while task.wait(0.2) do
        updateAllLabels()
    end
end)
