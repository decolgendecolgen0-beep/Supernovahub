-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SUPERNOVA HUB",
   LoadingTitle = "Supernova Hub Loading...",
   LoadingSubtitle = "by DIZ",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Services & Local Player
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- Data List
local zoneList = {"Forest", "Lake", "Jungle", "Desert", "Snow", "Volcano", "Beach", "Abyss", "Cosmic", "Crystal"}
local rarityList = {"Common", "Rare", "Legendary", "Mythic", "Divine", "Celestial", "Eternal", "Insane"}

local states = {
    AutoFarm = false,
    AutoSellEgg = false,
    AutoSellChicken = false,
    AutoClaimEggs = false,
    EquipBest = false,
    SelectedZones = {
        ["Forest"] = true, ["Lake"] = true, ["Jungle"] = true,
        ["Desert"] = true, ["Snow"] = true, ["Volcano"] = true,
        ["Beach"] = true, ["Abyss"] = true, ["Cosmic"] = true,
        ["Crystal"] = true
    },
    SelectedRarities = { ["Insane"] = true }
}

-- SAFE REMOTE GETTER
local stealRemote, takeInsaneRemote, sellAllRemote, claimAllEggsRemote, equipBestRemote

task.spawn(function()
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local packages = rep:WaitForChild("packages", 5)
        local index = packages and packages:WaitForChild("_Index", 5)
        local litten = index and index:WaitForChild("littensy_remo@1.5.3", 5)
        local remo = litten and litten:WaitForChild("remo", 5)
        local container = remo and remo:WaitForChild("container", 5)
        
        if container then
            stealRemote = container:FindFirstChild("game.nests.stealEgg")
            takeInsaneRemote = container:FindFirstChild("game.nests.takeInsaneEgg")
            sellAllRemote = container:FindFirstChild("data.backpack.sellAllItems")
            claimAllEggsRemote = container:FindFirstChild("data.base.claimAllEggs")
            equipBestRemote = container:FindFirstChild("data.base.equipBestChickens")
        end
    end)
end)

-- Instant Proximity Prompt Override
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    prompt.HoldDuration = 0
    if fireproximityprompt then
        fireproximityprompt(prompt)
    end
end)

---------------------------------------------------------
-- UI TABS & SECTIONS
---------------------------------------------------------
local FarmTab = Window:CreateTab("Farming", 4483362458)

FarmTab:CreateSection("Auto Farm Options")

FarmTab:CreateToggle({
   Name = "Auto Farm (Skyforge)",
   CurrentValue = false,
   Flag = "AutoFarmFlag",
   Callback = function(v)
       states.AutoFarm = v
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Sell Egg",
   CurrentValue = false,
   Flag = "AutoSellEggFlag",
   Callback = function(v)
       states.AutoSellEgg = v
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Sell Chicken",
   CurrentValue = false,
   Flag = "AutoSellChickenFlag",
   Callback = function(v)
       states.AutoSellChicken = v
   end,
})

FarmTab:CreateSection("Filter Options")

FarmTab:CreateDropdown({
   Name = "Select Zone",
   Options = zoneList,
   CurrentOption = zoneList,
   MultipleOptions = true,
   Flag = "ZoneDropdown",
   Callback = function(selectedTable)
       states.SelectedZones = {}
       for _, z in ipairs(selectedTable) do
           states.SelectedZones[z] = true
       end
   end,
})

FarmTab:CreateDropdown({
   Name = "Target Rarity",
   Options = rarityList,
   CurrentOption = {"Insane"},
   MultipleOptions = true,
   Flag = "RarityDropdown",
   Callback = function(selectedTable)
       states.SelectedRarities = {}
       for _, r in ipairs(selectedTable) do
           states.SelectedRarities[r] = true
       end
   end,
})

local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Base Utilities")

MiscTab:CreateToggle({
   Name = "Auto Claim All Eggs",
   CurrentValue = false,
   Flag = "AutoClaimEggsFlag",
   Callback = function(v)
       states.AutoClaimEggs = v
   end,
})

MiscTab:CreateToggle({
   Name = "Equip Best Chickens",
   CurrentValue = false,
   Flag = "EquipBestFlag",
   Callback = function(v)
       states.EquipBest = v
   end,
})

MiscTab:CreateSection("Player Utilities")

MiscTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SpeedBoostFlag",
   Callback = function(v)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = v and 50 or 16
       end
   end,
})

---------------------------------------------------------
-- LOGIKA AUTO SELL, AUTO CLAIM, & EQUIP BEST
---------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1)
        if sellAllRemote then
            if states.AutoSellEgg then
                pcall(function() sellAllRemote:FireServer("egg") end)
            end
            if states.AutoSellChicken then
                pcall(function() sellAllRemote:FireServer("chicken") end)
            end
        end
        if states.AutoClaimEggs and claimAllEggsRemote then
            pcall(function() claimAllEggsRemote:FireServer() end)
        end
        if states.EquipBest and equipBestRemote then
            pcall(function() equipBestRemote:FireServer() end)
        end
    end
end)

---------------------------------------------------------
-- LOGIKA FARMING (ENHANCED STRICTOR ZONE & PICKUP LOGIC)
---------------------------------------------------------
local centerSafeZoneCFrame = nil
local blacklistedPrompts = {}

task.spawn(function()
    while true do
        task.wait(2.5)
        blacklistedPrompts = {}
    end
end)

-- UN-EQUIP / MELEPAS TELUR YANG SEDANG DIPEGANG
local function dropCurrentEgg()
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Melepas Tool jika telur berupa Tool
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
    end

    -- 2. Memutus joint/weld jika telur menempel pada fisik karakter
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") or child.Name:lower():find("egg") or child.Name:lower():find("holding") then
            child.Parent = LocalPlayer:FindFirstChildOfClass("Backpack") or workspace
        end
    end
end

-- PENGECEKAN ZONE SECARA KETAT (STRICT DETECTION)
local function getValidSelectedZone(obj)
    local current = obj
    
    -- Memeriksa hirarki tempat telur berada
    while current and current ~= workspace do
        local currentName = current.Name:lower():gsub("%s+", "")
        
        -- Cek Atribut / Child Value "Zone"
        local zAttr = current:GetAttribute("Zone") or (current:FindFirstChild("Zone") and current.Zone.Value)
        if zAttr and type(zAttr) == "string" then
            local cleanAttr = zAttr:lower():gsub("%s+", "")
            for zName, enabled in pairs(states.SelectedZones) do
                if enabled and cleanAttr:find(zName:lower():gsub("%s+", "")) then
                    return zName
                end
            end
        end

        -- Cek Nama Model / Parent
        for zName, enabled in pairs(states.SelectedZones) do
            if enabled and currentName:find(zName:lower():gsub("%s+", "")) then
                return zName
            end
        end
        current = current.Parent
    end

    -- Memeriksa deskriptor teks di dalam objek
    for _, desc in pairs(obj:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("StringValue") then
            local txt = (desc.Text or desc.Value)
            if type(txt) == "string" then
                local cleanTxt = txt:lower():gsub("%s+", "")
                for zName, enabled in pairs(states.SelectedZones) do
                    if enabled and cleanTxt:find(zName:lower():gsub("%s+", "")) then
                        return zName
                    end
                end
            end
        end
    end

    -- PENTING: Fallback tanpa izin DIBUANG total agar tidak mengambil zone yang tidak dipilih!
    return nil
end

local function checkRarityMatch(prompt)
    local actText = prompt.ActionText:lower()
    local objText = prompt.ObjectText:lower()
    local eggParent = prompt.Parent

    local isInsaneText = actText:find("insane") or objText:find("insane")
    if not isInsaneText and eggParent then
        for _, v in pairs(eggParent:GetDescendants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) then
                local txt = tostring(v.Text):upper()
                if txt:find("INSANE") then
                    isInsaneText = true
                    break
                end
            end
        end
    end

    if isInsaneText then
        if states.SelectedRarities["Insane"] then
            return true, true
        else
            return false, false
        end
    end

    for rarityName, isEnabled in pairs(states.SelectedRarities) do
        if isEnabled and rarityName ~= "Insane" then
            local rLower = rarityName:lower()
            if actText:find(rLower) or objText:find(rLower) then
                return true, false
            end
        end
    end

    return false, false
end

local function resetCharacterMomentum(hrp)
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        
        if states.AutoFarm then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                if not centerSafeZoneCFrame then
                    centerSafeZoneCFrame = hrp.CFrame
                end

                local targetPrompt = nil
                local targetObj = nil
                local targetZone = nil
                local targetIsInsane = false

                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled and not blacklistedPrompts[prompt] then
                        local actText = prompt.ActionText:lower()
                        local objText = prompt.ObjectText:lower()

                        if actText:find("steal") or actText:find("chicken") or objText:find("chicken") or actText:find("take") or actText:find("egg") then
                            local validZone = getValidSelectedZone(prompt.Parent)
                            
                            -- Hanya memproses jika zone benar-benar VALID & DIPILIH
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
                    blacklistedPrompts[targetPrompt] = true

                    local targetPos
                    if targetObj:IsA("Model") then
                        targetPos = targetObj:GetPivot().Position
                    elseif targetObj:IsA("BasePart") then
                        targetPos = targetObj.Position
                    else
                        targetPos = targetPrompt.Parent and targetPrompt.Parent.Position or nil
                    end

                    if targetPos then
                        -- 1. Teleport tepat di lokasi telur (ketinggian disesuaikan)
                        resetCharacterMomentum(hrp)
                        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))
                        
                        -- Penundaan kecil agar physics & server menyadari keberadaan karakter
                        task.wait(0.18)

                        -- 2. Interaksi Proximity Prompt & Trigger Remote
                        targetPrompt.HoldDuration = 0
                        if fireproximityprompt then
                            fireproximityprompt(targetPrompt)
                        end
                        pcall(function()
                            targetPrompt:InputHoldBegin()
                            targetPrompt:InputHoldEnd()
                        end)

                        local zoneParam = tostring(targetZone):lower()
                        pcall(function()
                            if targetIsInsane and takeInsaneRemote then
                                takeInsaneRemote:InvokeServer(zoneParam)
                            elseif stealRemote then
                                stealRemote:InvokeServer(zoneParam, Vector3.new(targetPos.X, targetPos.Y, targetPos.Z))
                            end
                        end)

                        -- Waktu jeda agar animasi & pendaftaran item dari server selesai
                        task.wait(0.25)

                        -- 3. Kembali ke Base / Safe Zone
                        if centerSafeZoneCFrame then
                            resetCharacterMomentum(hrp)
                            hrp.CFrame = centerSafeZoneCFrame
                        end

                        -- 4. Melepas/Menjatuhkan telur yang dipegang agar bisa TP ke telur berikutnya
                        task.wait(0.1)
                        dropCurrentEgg()

                        task.wait(0.2)
                    end
                end
            end
        else
            centerSafeZoneCFrame = nil
        end
    end
end)
