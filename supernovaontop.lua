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
title.Text = "SUPERNOVA ON TOP (LITE)"
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

-- 3. Logika Ringan (Bebas Lag & Respon Instan)
local newName = ""

local function quickFixNames()
    if newName == "" then return end
    
    -- Ubah Humanoid DisplayName
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        pcall(function() player.Character.Humanoid.DisplayName = newName end)
    end
    
    local oldName = player.Name
    local oldDisplay = player.DisplayName
    
    -- Cek khusus PlayerGui (Menu Trade)
    local pGui = player:FindFirstChild("PlayerGui")
    if pGui then
        for _, obj in ipairs(pGui:GetDescendants()) do
            if obj:IsA("TextLabel") and not obj:IsDescendantOf(screenGui) then
                local txt = obj.Text
                if txt == oldName or txt == oldDisplay or string.find(string.lower(txt), "kentoes") then
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
        quickFixNames()
        task.wait(1)
        button.Text = "TERAPKAN NAMA"
    end
end)

-- Hanya aktif ketika ada perubahan elemen di PlayerGui (Sangat Ringan!)
local playerGui = player:WaitForChild("PlayerGui")
playerGui.DescendantAdded:Connect(function(child)
    if newName ~= "" and (child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("ImageLabel")) then
        task.defer(quickFixNames)
    end
end)
