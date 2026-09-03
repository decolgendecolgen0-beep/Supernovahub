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
local zoneList = {"Forest", "Lake", "Jungle", "Desert", "Snow", "Volcano", "Beach", "Abyss", "Cosmic"}
local rarityList = {"Common", "Rare", "Legendary", "Mythic", "Divine", "Celestial", "Eternal", "Insane"}

local states = {
    AutoFarm = false,
    AutoSellEgg = false,
    AutoSellChicken = false,
    SelectedZones = {
        ["Forest"] = true, ["Lake"] = true, ["Jungle"] = true,
        ["Desert"] = true, ["Snow"] = true, ["Volcano"] = true,
        ["Beach"] = true, ["Abyss"] = true, ["Cosmic"] = true
    },
    SelectedRarities = { ["Insane"] = true }
}

-- SAFE REMOTE GETTER
local stealRemote, takeInsaneRemote, sellAllRemote

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
        end
    end)
end)

-- Instant Proximity Prompt
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
-- LOGIKA AUTO SELL
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
    end
end)

---------------------------------------------------------
-- LOGIKA FARMING (DIRECT CFRAME RETURN & HIGH ELEVATION)
---------------------------------------------------------
local centerSafeZoneCFrame = nil
local blacklistedPrompts = {}

task.spawn(function()
    while true do
        task.wait(3)
        blacklistedPrompts = {}
    end
end)

local function getValidSelectedZone(obj)
    local current = obj
    while current and current ~= workspace do
        local currentName = current.Name:lower():gsub("%s+", "")
        
        local zAttr = current:GetAttribute("Zone") or (current:FindFirstChild("Zone") and current.Zone.Value)
        if zAttr and type(zAttr) == "string" then
            local cleanAttr = zAttr:lower():gsub("%s+", "")
            for zName, enabled in pairs(states.SelectedZones) do
                if enabled and cleanAttr:find(zName:lower():gsub("%s+", "")) then
                    return zName:lower()
                end
            end
        end

        for zName, enabled in pairs(states.SelectedZones) do
            if enabled and currentName:find(zName:lower():gsub("%s+", "")) then
                return zName:lower()
            end
        end
        current = current.Parent
    end

    for _, desc in pairs(obj:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("StringValue") then
            local txt = (desc.Text or desc.Value)
            if type(txt) == "string" then
                local cleanTxt = txt:lower():gsub("%s+", "")
                for zName, enabled in pairs(states.SelectedZones) do
                    if enabled and cleanTxt:find(zName:lower():gsub("%s+", "")) then
                        return zName:lower()
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
    if not isInsane and eggParent then
        for _, v in pairs(eggParent:GetDescendants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) then
                local txt = tostring(v.Text):upper()
                if txt:find("INSANE") then
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
                -- Simpan koordinat di tempat pemain berdiri saat mengaktifkan toggle
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
                        -- 1. Teleport di atas telur (+5 stud tinggi agar tidak tersangkut di Abyss/Cosmic)
                        resetCharacterMomentum(hrp)
                        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                        task.wait(0.18)

                        -- 2. Trigger Proximity Prompt
                        targetPrompt.HoldDuration = 0
                        if fireproximityprompt then
                            fireproximityprompt(targetPrompt)
                        end
                        pcall(function()
                            targetPrompt:InputHoldBegin()
                            targetPrompt:InputHoldEnd()
                        end)

                        -- 3. Invoke/Fire Remote
                        pcall(function()
                            if targetIsInsane and takeInsaneRemote then
                                takeInsaneRemote:InvokeServer(targetZone)
                            elseif stealRemote then
                                stealRemote:InvokeServer(targetZone, Vector3.new(targetPos.X, targetPos.Y, targetPos.Z))
                            end
                        end)

                        task.wait(0.18)

                        -- 4. LANGSUNG PAKSA TELEPORT C-FRAME KEMBALI KE TITIK TENAH
                        if centerSafeZoneCFrame then
                            resetCharacterMomentum(hrp)
                            hrp.CFrame = centerSafeZoneCFrame
                        end

                        task.wait(0.15)
                    end
                end
            end
        else
            centerSafeZoneCFrame = nil
        end
    end
end)
