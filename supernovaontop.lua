-- Services & Local Player
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- Target UI Parent
local parentUI
if gethui then
    parentUI = gethui()
elseif syn and syn.protect_gui then
    parentUI = CoreGui; syn.protect_gui(parentUI)
else
    parentUI = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
end

if parentUI:FindFirstChild("SupernovaHub") then parentUI.SupernovaHub:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SupernovaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

-- HIERARKI ZONES
local zoneList = {"Forest", "Lake", "Jungle", "Desert", "Snow", "Volcano", "Beach", "Abyss", "Cosmic"}
local rarityList = {"Common", "Rare", "Legendary", "Mythic", "Divine", "Celestial", "Eternal", "Insane"}

local states = {
    AutoFarm = false,
    AutoSell = false,
    SelectedZones = {
        ["Forest"] = true, ["Lake"] = true, ["Jungle"] = true,
        ["Desert"] = true, ["Snow"] = true, ["Volcano"] = true,
        ["Beach"] = true, ["Abyss"] = true, ["Cosmic"] = true
    },
    SelectedRarities = { ["Insane"] = true }
}

-- Remotes dari SimpleSpy
local remoFolder = game:GetService("ReplicatedStorage")
    :WaitForChild("packages")
    :WaitForChild("_Index")
    :WaitForChild("littensy_remo@1.5.3")
    :WaitForChild("remo")
    :WaitForChild("container")

local stealRemote = remoFolder:WaitForChild("game.nests.stealEgg")
local takeInsaneRemote = remoFolder:WaitForChild("game.nests.takeInsaneEgg")
local teleportBaseRemote = remoFolder:WaitForChild("game.base.teleportToBase")

---------------------------------------------------------
-- INSTANT PROXIMITY PROMPT OVERRIDE
---------------------------------------------------------
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    prompt.HoldDuration = 0
    if fireproximityprompt then
        fireproximityprompt(prompt)
    end
end)

---------------------------------------------------------
-- TOGGLE/OPEN BUTTON
---------------------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
OpenBtn.Text = "HUB"
OpenBtn.TextColor3 = Color3.fromRGB(255, 70, 80)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 14
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenBtn

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(180, 30, 40)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenBtn

---------------------------------------------------------
-- MAIN CONTAINER
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(150, 25, 35)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SUPERNOVA HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CloseBtn.Text = "-"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

---------------------------------------------------------
-- SIDEBAR & CONTENT LAYOUT
---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 40)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -50)
ContentArea.Position = UDim2.new(0, 135, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

---------------------------------------------------------
-- TAB SYSTEM
---------------------------------------------------------
local tabs = {}

local function createTab(name)
    local index = #tabs
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.Position = UDim2.new(0, 0, 0, index * 38)
    tabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
    tabBtn.Font = Enum.Font.SourceSans
    tabBtn.TextSize = 12
    tabBtn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(150, 25, 35)
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
            t.Button.TextColor3 = Color3.fromRGB(150, 150, 155)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 40)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    local tabData = {Button = tabBtn, Page = page}
    table.insert(tabs, tabData)

    if #tabs == 1 then
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 40)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    return page
end

---------------------------------------------------------
-- UI COMPONENTS
---------------------------------------------------------
local function createToggle(parent, titleText, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 45, 0, 20)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -10)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = defaultState and "ON" or "OFF"
    toggleBtn.TextColor3 = defaultState and Color3.fromRGB(255, 70, 80) or Color3.fromRGB(100, 100, 105)
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 11
    toggleBtn.Parent = frame

    local state = defaultState
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.TextColor3 = state and Color3.fromRGB(255, 70, 80) or Color3.fromRGB(100, 100, 105)
        callback(state)
    end)
end

local function createMultiDropdown(parent, titleText, optionsList, targetStateTable, defaultBtnText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0, 95, 0, 24)
    selectBtn.Position = UDim2.new(1, -105, 0.5, -12)
    selectBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    selectBtn.Text = defaultBtnText
    selectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectBtn.Font = Enum.Font.SourceSans
    selectBtn.TextSize = 11
    selectBtn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = selectBtn

    local popFrame = Instance.new("ScrollingFrame")
    popFrame.Size = UDim2.new(0, 120, 0, math.min(#optionsList * 22 + 8, 120))
    popFrame.Position = UDim2.new(1, -125, 1, 5)
    popFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    popFrame.BorderSizePixel = 0
    popFrame.ScrollBarThickness = 2
    popFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 25, 35)
    popFrame.Visible = false
    popFrame.ZIndex = 5
    popFrame.Parent = frame

    local popCorner = Instance.new("UICorner")
    popCorner.CornerRadius = UDim.new(0, 6)
    popCorner.Parent = popFrame

    local popStroke = Instance.new("UIStroke")
    popStroke.Color = Color3.fromRGB(150, 25, 35)
    popStroke.Thickness = 1
    popStroke.Parent = popFrame

    popFrame.CanvasSize = UDim2.new(0, 0, 0, #optionsList * 22 + 8)

    for idx, item in ipairs(optionsList) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, -10, 0, 20)
        optionBtn.Position = UDim2.new(0, 5, 0, (idx - 1) * 22 + 4)
        optionBtn.BackgroundTransparency = 1
        optionBtn.Text = (targetStateTable[item] and "[✓] " or "[  ] ") .. item
        optionBtn.TextColor3 = targetStateTable[item] and Color3.fromRGB(255, 70, 80) or Color3.fromRGB(160, 160, 160)
        optionBtn.Font = Enum.Font.SourceSans
        optionBtn.TextSize = 11
        optionBtn.TextXAlignment = Enum.TextXAlignment.Left
        optionBtn.ZIndex = 6
        optionBtn.Parent = popFrame

        optionBtn.MouseButton1Click:Connect(function()
            if targetStateTable[item] then
                targetStateTable[item] = nil
                optionBtn.Text = "[  ] " .. item
                optionBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            else
                targetStateTable[item] = true
                optionBtn.Text = "[✓] " .. item
                optionBtn.TextColor3 = Color3.fromRGB(255, 70, 80)
            end
        end)
    end

    selectBtn.MouseButton1Click:Connect(function()
        popFrame.Visible = not popFrame.Visible
    end)
end

---------------------------------------------------------
-- ISI TAB
---------------------------------------------------------
local FarmPage = createTab("Farming")
createToggle(FarmPage, "Auto Farm (Skyforge)", states.AutoFarm, function(v) states.AutoFarm = v end)
createMultiDropdown(FarmPage, "Select Zone", zoneList, states.SelectedZones, "Select Zones")
createMultiDropdown(FarmPage, "Target Rarity", rarityList, states.SelectedRarities, "Select Rarity")
createToggle(FarmPage, "Auto Sell All", states.AutoSell, function(v) states.AutoSell = v end)

local UpgradesPage = createTab("Upgrades")
createToggle(UpgradesPage, "Auto Upgrade Stat", false, function(v) end)

local NamePage = createTab("Name Changer")
createToggle(NamePage, "Hide Name/Level", false, function(v) end)

local MiscPage = createTab("Misc")
createToggle(MiscPage, "Speed Boost", false, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v and 50 or 16
    end
end)

---------------------------------------------------------
-- TOGGLE / MINIMIZE
---------------------------------------------------------
local function toggleUI() MainFrame.Visible = not MainFrame.Visible end
CloseBtn.MouseButton1Click:Connect(toggleUI)
OpenBtn.MouseButton1Click:Connect(toggleUI)

---------------------------------------------------------
-- LOGIKA FARMING + SYSTEM AKURASI ZONE ALL MAP
---------------------------------------------------------
local lockedSafeZoneCFrame = nil
local blacklistedPrompts = {}

-- PENDEKETAN ULTRA AKURAT UNTUK DETEKSI ZONE DI WORKSPACE
local function getValidSelectedZone(obj)
    local current = obj
    
    -- 1. Scan semua parent/ancestor sampai ke Workspace
    while current and current ~= workspace do
        local currentName = current.Name:lower()
        
        -- Cek Value/Attribute eksplisit jika game menyimpan data Zone
        local zAttr = current:GetAttribute("Zone") or (current:FindFirstChild("Zone") and current.Zone.Value)
        if zAttr and type(zAttr) == "string" then
            for _, zName in ipairs(zoneList) do
                if zAttr:lower():find(zName:lower()) then
                    return states.SelectedZones[zName] and zName:lower() or nil
                end
            end
        end

        -- Cek pencocokan string nama folder/model
        for _, zName in ipairs(zoneList) do
            if currentName:find(zName:lower()) then
                return states.SelectedZones[zName] and zName:lower() or nil
            end
        end
        current = current.Parent
    end

    -- 2. Fallback: Jika folder bernama unik (misal "NestGroup"), pindai anak-anaknya/text-nya
    for _, desc in pairs(obj:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("StringValue") then
            local txt = desc.Text or desc.Value
            if type(txt) == "string" then
                for _, zName in ipairs(zoneList) do
                    if txt:lower():find(zName:lower()) then
                        return states.SelectedZones[zName] and zName:lower() or nil
                    end
                end
            end
        end
    end

    return nil
end

local function checkRarityMatch(prompt)
    local actText = prompt.ActionText:lower()
    local objText = prompt.ObjectText:lower()
    local eggParent = prompt.Parent

    local isInsane = actText:find("insane") or objText:find("insane")
    if not isInsane then
        for _, v in pairs(eggParent:GetDescendants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Visible then
                if v.Text:upper():find("INSANE!") then
                    isInsane = true
                    break
                end
            end
        end
    end

    if isInsane then
        return states.SelectedRarities["Insane"] == true, true
    end

    for rarityName, isEnabled in pairs(states.SelectedRarities) do
        if isEnabled and rarityName ~= "Insane" then
            if actText:find(rarityName:lower()) or objText:find(rarityName:lower()) then
                return true, false
            end
        end
    end

    return false, false
end

task.spawn(function()
    while true do
        task.wait(0.05)
        
        if states.AutoFarm then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                if not lockedSafeZoneCFrame then
                    lockedSafeZoneCFrame = hrp.CFrame
                end

                local targetPrompt = nil
                local targetObj = nil
                local targetZone = nil
                local targetIsInsane = false

                -- SCAN PROXIMITY PROMPT
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled and not blacklistedPrompts[prompt] then
                        local actText = prompt.ActionText:lower()
                        local objText = prompt.ObjectText:lower()

                        if actText:find("steal") or actText:find("chicken") or objText:find("chicken") or actText:find("take") then
                            local validZone = getValidSelectedZone(prompt.Parent)
                            
                            if validZone then
                                local isMatch, isInsane = checkRarityMatch(prompt)
                                if isMatch then
                                    targetPrompt = prompt
                                    targetObj = prompt.Parent
                                    targetZone = validZone
                                    targetIsInsane = isInsane
                                    break
                                end
                            end
                        end
                    end
                end

                if targetPrompt and targetObj and targetZone then
                    local targetPos

                    if targetObj:IsA("Model") then
                        targetPos = targetObj:GetPivot().Position
                    elseif targetObj:IsA("BasePart") then
                        targetPos = targetObj.Position
                    else
                        targetPos = targetPrompt.Parent.Position
                    end

                    blacklistedPrompts[targetPrompt] = true

                    -- 1. TELEPORT KE TELUR (POSISI TELEPORT TIDAK DIUBAH)
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    task.wait(0.15)

                    -- 2. FIRE PROXIMITY PROMPT
                    targetPrompt.HoldDuration = 0
                    if fireproximityprompt then
                        fireproximityprompt(targetPrompt)
                    end
                    pcall(function()
                        targetPrompt:InputHoldBegin()
                        targetPrompt:InputHoldEnd()
                    end)

                    -- 3. KIRIM REMOTE
                    pcall(function()
                        if targetIsInsane then
                            takeInsaneRemote:InvokeServer(targetZone)
                        else
                            stealRemote:InvokeServer(targetZone, Vector3.new(targetPos.X, targetPos.Y, targetPos.Z))
                        end
                    end)

                    task.wait(0.15)

                    -- 4. TELEPORT BALIK KE BASE
                    pcall(function()
                        teleportBaseRemote:FireServer()
                    end)
                    
                    if lockedSafeZoneCFrame then
                        hrp.CFrame = lockedSafeZoneCFrame
                    end

                    task.wait(0.3)
                end
            end
        else
            lockedSafeZoneCFrame = nil
        end
    end
end)
