-- Z4K4 HUB | Murder Mystery 2
-- Kolory: różowy (#FF69B4) i czarny (#000000)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Plakalhub/mm2/refs/heads/main/mm2.lua"))()
local Window = Library:CreateWindow("Z4K4 HUB", Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 0, 0))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Globalne zmienne (ustawienia domyślne)
_G.Speed = false
_G.SpeedValue = 16
_G.Fly = false
_G.FlySpeed = 50
_G.Noclip = false
_G.Jump = false
_G.JumpPower = 50
_G.ESPSheriff = false
_G.ESPMurderer = false

-- Funkcje pomocnicze do wykrywania ról w MM2
local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                return p
            end
        end
    end
    return nil
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                return p
            end
        end
    end
    return nil
end

local function getGun()
    -- Szuka upuszczonego pistoletu na ziemi
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "Normal" and v:IsA("Tool") and v:FindFirstChild("Candidate") then
            return v
        elseif v.Name == "GunDrop" then -- Częste oznaczenie w niektórych wersjach MM2
            return v
        end
    end
    return nil
end

-- Obsługa ESP (Zabezpieczona przed duplikowaniem)
local function applyESP(player, color, name)
    if not player or not player.Character then return end
    local char = player.Character
    
    -- Usuń stare ESP jeśli istnieje
    if char:FindFirstChild("ESP_Highlight") then
        char.ESP_Highlight:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char
end

local function removeESP(player)
    if player and player.Character and player.Character:FindFirstChild("ESP_Highlight") then
        player.Character.ESP_Highlight:Destroy()
    end
end

-- Pętla obsługująca fizykę, ruch i ESP
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid and hrp then
        -- Speed (Bezpieczniejsza metoda przez WalkSpeed)
        if _G.Speed then
            humanoid.WalkSpeed = _G.SpeedValue
        else
            humanoid.WalkSpeed = 16 -- Domyślna prędkość w Roblox
        end
        
        -- Jump
        if _G.Jump then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = _G.JumpPower
        else
            humanoid.JumpPower = 50
        end
        
        -- Fly (Latanie góra/dół za pomocą kierunku kamery)
        if _G.Fly then
            local camera = workspace.CurrentCamera
            local moveDirection = humanoid.MoveDirection
            local flyVec = Vector3.new(0, 0, 0)
            
            if moveDirection.Magnitude > 0 then
                flyVec = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, 0, moveDirection.Z)) * _G.FlySpeed
            end
            
            hrp.Velocity = Vector3.new(flyVec.X, flyVec.Y, flyVec.Z)
        end
    end
    
    -- Noclip (Musi być wywoływany w Stepped co klatkę)
    if _G.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    -- Aktualizacja ESP Mordercy i Szeryfa
    local murderer = getMurderer()
    if _G.ESPMurderer and murderer then
        applyESP(murderer, Color3.fromRGB(255, 0, 0))
    elseif murderer then
        removeESP(murderer)
    end
    
    local sheriff = getSheriff()
    if _G.ESPSheriff and sheriff then
        applyESP(sheriff, Color3.fromRGB(0, 100, 255))
    elseif sheriff then
        removeESP(sheriff)
    end
end)

-- UI Taby i Sekcje
local Tab1 = Window:CreateTab("Główne")
local Tab2 = Window:CreateTab("ESP")
local Tab3 = Window:CreateTab("Teleporty")

-- Zakładka Ruch
local Section1 = Tab1:CreateSection("Ruch")
Section1:CreateToggle("Speed", false, function(value) _G.Speed = value end)
Section1:CreateSlider("Speed Value", 16, 150, 50, function(value) _G.SpeedValue = value end)
Section1:CreateToggle("Fly", false, function(value) _G.Fly = value end)
Section1:CreateSlider("Fly Speed", 10, 150, 50, function(value) _G.FlySpeed = value end)
Section1:CreateToggle("Noclip", false, function(value) _G.Noclip = value end)
Section1:CreateToggle("Jump Boost", false, function(value) _G.Jump = value end)
Section1:CreateSlider("Jump Power", 50, 300, 100, function(value) _G.JumpPower = value end)

-- Zakładka ESP
local Section3 = Tab2:CreateSection("ESP")
Section3:CreateToggle("ESP Sheriff", false, function(value) _G.ESPSheriff = value end)
Section3:CreateToggle("ESP Murderer", false, function(value) _G.ESPMurderer = value end)

-- Zakładka Teleporty
local Section4 = Tab3:CreateSection("Teleporty")
Section4:CreateButton("TP do pistoletu", function()
    local gun = getGun()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if gun then
            if gun:IsA("Tool") and gun:FindFirstChild("Handle") then
                hrp.CFrame = gun.Handle.CFrame
            elseif gun:IsA("BasePart") then
                hrp.CFrame = gun.CFrame
            end
        else
            -- Powiadomienie jeśli pistoletu nie ma na ziemi
            print("Pistolet nie został jeszcze upuszczony!")
        end
    end
end)
