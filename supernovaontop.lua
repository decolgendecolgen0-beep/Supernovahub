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

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 2. Frame Utama (Ringan & Clean)
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
title.Text = "SUPERNOVA ON TOP (ANTI-LAG)"
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

-- 3. Logika Super Ringan (Tanpa Spam Loop)
local newName = ""

local function applyOptimizedName()
    if newName == "" then return end
    
    -- Ubah Humanoid DisplayName karakter
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            player.Character.Humanoid.DisplayName = newName
        end)
    end
    
    -- Hanya scan TextLabel yang spesifik mengandung nama lama
    local targetOldName = player.Name
    local targetDisplay = player.DisplayName
    
    -- Cek Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local t = obj.Text
            if t == targetOldName or t == targetDisplay or string.find(string.lower(t), "kentoes") then
                pcall(function() obj.Text = newName end)
            end
        end
    end
    
    -- Cek PlayerGui (Menu Trade / UI Lain)
    local pGui = player:FindFirstChild("PlayerGui")
    if pGui then
        for _, obj in ipairs(pGui:GetDescendants()) do
            if obj:IsA("TextLabel") and not obj:IsDescendantOf(screenGui) then
                local t = obj.Text
                if t == targetOldName or t == targetDisplay or string.find(string.lower(t), "kentoes") then
                    pcall(function() obj.Text = newName end)
                end
            end
        end
    end
end

button.MouseButton1Click:Connect(function()
    if textBox.Text ~= "" then
        newName = textBox.Text
        button.Text = "BERHASIL!"
        applyOptimizedName()
        task.wait(1)
        button.Text = "TERAPKAN NAMA"
    end
end)

-- Deteksi otomatis saat UI Trade atau menu baru muncul (Tanpa bikin lag patah-patah)
local playerGui = player:WaitForChild("PlayerGui")
playerGui.DescendantAdded:Connect(function(descendant)
    if newName ~= "" and descendant:IsA("TextLabel") then
        task.defer(function()
            local t = descendant.Text
            if t == player.Name or t == player.DisplayName or string.find(string.lower(t), "kentoes") then
                if not descendant:IsDescendantOf(screenGui) then
                    descendant.Text = newName
                end
            end
        end)
    end
end)
