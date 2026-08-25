if getgenv().LanternHUB_Pass ~= true then
    game.Players.LocalPlayer:Kick("Security Error: Please run the script through the Key System!")
    return
end

-- [[ 1. Load Library and Addons ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ 2. Create Window ]] --
local Window = Fluent:CreateWindow({
    Title = "Lantern HUB v1.0 (Beta)",
    SubTitle = "Support by idontknow",
    TabWidth = 160,
    Size = UDim2.fromOffset(720, 460),
    Acrylic = true, 
    Theme = "Dark",
})

-- [[ 3. Create Tabs ]] --
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "leaf" }),
    Monster = Window:AddTab({ Title = "Monster", Icon = "swords" }),
    Vending = Window:AddTab({ Title = "Vending", Icon = "shopping-cart" }),
    Players = Window:AddTab({ Title = "Players", Icon = "users" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Notify when UI is successfully loaded
Fluent:Notify({
    Title = "Lantern HUB",
    Content = "UI successfully loaded!",
    Duration = 5
})



-- ==================================================
-- 🏠 MAIN TAB
-- ==================================================

Tabs.Main:AddParagraph({
    Title = "Lantern HUB v1.0",
    Content = "Thank you for choosing Lantern HUB and welcome.\nVersion: v1.0 (Beta)\nLast Update : August 22nd 2026"
})

-- Real-time User Statistics Paragraph
local UserStats = Tabs.Main:AddParagraph({
    Title = "Account Statistics",
    Content = "Loading stats..."
})

Tabs.Main:AddButton({
    Title = "Community",
    Description = "Join our Discord server for updates and support.",
    Callback = function()
        setclipboard("https://discord.gg/ewqTWQs8Aq")
        Fluent:Notify({
            Title = "Lantern HUB",
            Content = "Discord link copied to clipboard!",
            Duration = 3
        })
    end
})

-- Real-time Loop for updating Stats
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CurrentFPS = 0
RunService.RenderStepped:Connect(function(deltaTime)
    CurrentFPS = math.floor(1 / deltaTime)
end)

task.spawn(function()
    while task.wait(0.5) do
        if LocalPlayer then
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            local name = LocalPlayer.DisplayName .. ""
            local statsText = string.format("User : %s\nPing : %d ms FPS : %d", name, ping, CurrentFPS)
            UserStats:SetDesc(statsText)
        end
    end
end)




-- ==================================================
-- 🧑 PLAYERS TAB
-- ==================================================

local PlayerSettings = {
    WalkSpeed = { Enabled = false, Value = 30 }, -- Fixed at max safe speed 30
    JumpPower = { Enabled = false, Value = 50 },
    Noclip = false,
    Fly = { Enabled = false, Speed = 30 },
    Freecam = { Enabled = false, Speed = 100 }
}

Tabs.Players:AddParagraph({
    Title = "Player Enhancements",
    Content = "Adjust your character's physical abilities."
})

local WalkSpeedToggle = Tabs.Players:AddToggle("WalkSpeedToggle", {
    Title = "WalkSpeed Modification",
    Description = "Overrides your default movement speed.",
    Default = false,
    Callback = function(Value)
        PlayerSettings.WalkSpeed.Enabled = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 
        end
    end
})

local JumpPowerToggle = Tabs.Players:AddToggle("JumpPowerToggle", {
    Title = "JumpPower Modification",
    Description = "Enhances your character's jumping ability.",
    Default = false,
    Callback = function(Value)
        PlayerSettings.JumpPower.Enabled = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = 50 
        end
    end
})

local JumpPowerSlider = Tabs.Players:AddSlider("JumpPowerSlider", {
    Title = "Jump Height",
    Description = "Adjust the vertical power of your jumps.",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        PlayerSettings.JumpPower.Value = math.floor(Value)
    end
})

local NoclipToggle = Tabs.Players:AddToggle("NoclipToggle", {
    Title = "Noclip Mode",
    Description = "Walk freely through solid objects and walls.",
    Default = false,
    Callback = function(Value)
        PlayerSettings.Noclip = Value
        -- Explicitly restore collision when turned off
        if not Value and LocalPlayer.Character then
            local coreParts = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
            for _, name in pairs(coreParts) do
                local part = LocalPlayer.Character:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

local FlyMover, FlyGyro
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local function StopFly()
    if FlyMover then FlyMover:Destroy() FlyMover = nil end
    if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
        -- Reset WalkSpeed back to normal when flying stops
        if PlayerSettings.WalkSpeed.Enabled then
            LocalPlayer.Character.Humanoid.WalkSpeed = PlayerSettings.WalkSpeed.Value
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end

local function StartFly()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    StopFly() -- Clear existing movers to prevent bugs
    local HRP = LocalPlayer.Character.HumanoidRootPart
    
    FlyMover = Instance.new("BodyVelocity")
    FlyMover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyMover.Velocity = Vector3.new(0, 0, 0)
    FlyMover.Parent = HRP
    
    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyGyro.P = 10000
    FlyGyro.D = 50
    FlyGyro.Parent = HRP
    
    LocalPlayer.Character.Humanoid.PlatformStand = true
end

local FlyToggle = Tabs.Players:AddToggle("FlyToggle", {
    Title = "Flight Mode",
    Description = "Allows you to fly freely. Steer with your camera.",
    Default = false,
    Callback = function(Value)
        PlayerSettings.Fly.Enabled = Value
        if Value then
            StartFly()
        else
            StopFly()
        end
    end
})

local FlySpeedSlider = Tabs.Players:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Description = "Adjust your flying speed (Max 30 due to anticheat)",
    Default = 30,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        PlayerSettings.Fly.Speed = math.floor(Value)
    end
})

-- ================== Freecam System ==================
local FC_CFrame = Camera.CFrame
local FC_Pitch = 0
local FC_Yaw = 0

local function StartFreecam()
    FC_CFrame = Camera.CFrame
    local x, y, z = FC_CFrame:ToEulerAnglesYXZ()
    FC_Pitch = x
    FC_Yaw = y
    Camera.CameraType = Enum.CameraType.Scriptable
    
    -- Anchor the character so they don't walk when pressing WASD
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end
end

local function StopFreecam()
    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    -- Unanchor the character when returning
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
end

local FreecamToggle = Tabs.Players:AddToggle("FreecamToggle", {
    Title = "Freecam Mode",
    Description = "Detach and move your camera freely. Toggle with [G].",
    Default = false,
    Callback = function(Value)
        PlayerSettings.Freecam.Enabled = Value
        if Value then
            StartFreecam()
        else
            StopFreecam()
        end
    end
})

local FreecamSpeedSlider = Tabs.Players:AddSlider("FreecamSpeedSlider", {
    Title = "Freecam Speed",
    Description = "Adjust camera movement speed",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        PlayerSettings.Freecam.Speed = math.floor(Value)
    end
})

-- Freecam Hotkey Logic (G)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        FreecamToggle:SetValue(not PlayerSettings.Freecam.Enabled)
    end
end)


-- Advanced Bypass to enforce modified values (Works better for games like Islands)
local function SetupBypass(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            -- If flying, strictly enforce 0 to prevent the humanoid from walking in mid-air
            if PlayerSettings.Fly.Enabled then
                if humanoid.WalkSpeed ~= 0 then humanoid.WalkSpeed = 0 end
            -- Otherwise, enforce the WalkSpeed setting
            elseif PlayerSettings.WalkSpeed.Enabled and humanoid.WalkSpeed ~= PlayerSettings.WalkSpeed.Value then
                humanoid.WalkSpeed = PlayerSettings.WalkSpeed.Value
            end
        end)
        
        humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if PlayerSettings.JumpPower.Enabled and humanoid.JumpPower ~= PlayerSettings.JumpPower.Value then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = PlayerSettings.JumpPower.Value
            end
        end)
    end
end

-- Apply to current character and future respawns
if LocalPlayer.Character then SetupBypass(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    SetupBypass(char)
    -- If they were flying before respawning, fly again
    if PlayerSettings.Fly.Enabled then
        task.wait(0.5) 
        StartFly()
    end
end)

-- Continuous loop for movement and noclip
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Noclip logic must be on Stepped to override Roblox physics engine
    if PlayerSettings.Noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    local character = LocalPlayer.Character
    
    -- Freecam Logic
    if PlayerSettings.Freecam.Enabled then
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + FC_CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - FC_CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - FC_CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + FC_CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
        
        -- Handle Mouse look for Freecam
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local delta = UserInputService:GetMouseDelta()
            FC_Yaw = FC_Yaw - math.rad(delta.X * 0.3)
            FC_Pitch = math.clamp(FC_Pitch - math.rad(delta.Y * 0.3), -math.rad(89), math.rad(89))
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        
        -- Apply rotation and movement
        FC_CFrame = CFrame.new(FC_CFrame.Position) * CFrame.Angles(0, FC_Yaw, 0) * CFrame.Angles(FC_Pitch, 0, 0)
        FC_CFrame = FC_CFrame + (moveDir * (PlayerSettings.Freecam.Speed * deltaTime))
        Camera.CFrame = FC_CFrame
    end

    if not character then return end
    
    -- Fly logic
    if PlayerSettings.Fly.Enabled and FlyMover and FlyGyro then
        local HRP = character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            
            -- Normalize vector to prevent diagonal speed boost which triggers anticheat
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
            
            FlyMover.Velocity = moveDir * PlayerSettings.Fly.Speed
            FlyGyro.CFrame = Camera.CFrame
        end
    end

    -- Enforce WalkSpeed/JumpPower continuously
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        if PlayerSettings.Fly.Enabled then
            -- Disable physical walking mechanics entirely while flying
            humanoid.PlatformStand = true
            if humanoid.WalkSpeed ~= 0 then humanoid.WalkSpeed = 0 end
        else
            if PlayerSettings.WalkSpeed.Enabled and humanoid.WalkSpeed ~= PlayerSettings.WalkSpeed.Value then
                humanoid.WalkSpeed = PlayerSettings.WalkSpeed.Value
            end
            if PlayerSettings.JumpPower.Enabled and humanoid.JumpPower ~= PlayerSettings.JumpPower.Value then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = PlayerSettings.JumpPower.Value
            end
        end
    end
end)




-- ==================================================
-- 🌾 FARMING TAB
-- ==================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NET
pcall(function()
    NET = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
end)

local function getblocksfolder()
    local islands = workspace:FindFirstChild("Islands")
    if islands then
        for _, island in ipairs(islands:GetChildren()) do
            local b = island:FindFirstChild("Blocks")
            if b then return b end
        end
    end
    return workspace:FindFirstChild("Blocks") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Blocks"))
end

local function filledcheck(Position)
    local Parts = workspace:FindPartsInRegion3(Region3.new(Position - Vector3.new(0.1,0.1,0.1), Position + Vector3.new(0.1,0.1,0.1)), nil, 50)
    for _, v in ipairs(Parts) do
        local parent = v.Parent
        if parent and parent.Name == "Blocks" then return true end
        if parent and parent.Parent and parent.Parent.Name == "Blocks" then return true end
    end
    return false
end

local CropMap = {
    ["Berry Bush"] = "berryBush",
    ["Blackberry Bush"] = "blackberryBush",
    ["Blueberry Bush"] = "blueberryBush",
    ["Cactus"] = "cactus",
    ["Candy Cane"] = "candyCane",
    ["Carrot"] = "carrot",
    ["Chili Pepper"] = "chiliPepper",
    ["Cranberry Bush"] = "cranberryBush",
    ["Crystalline Ivy"] = "crystallineIvy",
    ["Dragonfruit"] = "dragonfruit",
    ["Grape"] = "grape",
    ["Melon"] = "melon",
    ["Onion"] = "onion",
    ["Optuntia"] = "optuntia",
    ["Pineapple"] = "pineapple",
    ["Potato"] = "potato",
    ["Pumpkin"] = "pumpkin",
    ["Radish"] = "radish",
    ["Raspberry Bush"] = "raspberryBush",
    ["Rice"] = "rice",
    ["Seaweed"] = "seaweed",
    ["Spinach"] = "spinach",
    ["Spirit"] = "spiritCrop",
    ["Starfruit"] = "starfruit",
    ["Strawberry Bush"] = "strawberryBush",
    ["Tomato"] = "tomato",
    ["Vine Stem"] = "vineStem",
    ["Void Parasite"] = "voidParasite",
    ["Wheat"] = "wheat"
}

local FarmingSettings = {
    SelectedCrop = "Wheat",
    AutoHarvest = false,
    AutoPlant = false,
    AutoPlow = false,
    ActionDelayMs = 50
}

local MiningSettings = {
    SelectedRock = "All",
    TargetArea = "Wilderness (Public)",
    RockAura = false,
    TweenToRock = false
}


Tabs.Farming:AddParagraph({
    Title = "Crop Automation",
    Content = "Select your desired crop and toggle the automations."
})


local CropDropdown = Tabs.Farming:AddDropdown("CropDropdown", {
    Title = "Target Crop",
    Values = {
        "Berry Bush", "Blackberry Bush", "Blueberry Bush", "Cactus", "Candy Cane", 
        "Carrot", "Chili Pepper", "Cranberry Bush", "Crystalline Ivy", "Dragonfruit", 
        "Grape", "Melon", "Onion", "Optuntia", "Pineapple", "Potato", "Pumpkin", 
        "Radish", "Raspberry Bush", "Rice", "Seaweed", "Spinach", "Spirit", 
        "Starfruit", "Strawberry Bush", "Tomato", "Vine Stem", "Void Parasite", "Wheat"
    },
    Multi = false,
    Default = 29, -- Default to Wheat
    Callback = function(Value)
        FarmingSettings.SelectedCrop = Value
    end
})

local HarvestThread = nil
local AutoHarvestToggle = Tabs.Farming:AddToggle("AutoHarvestToggle", {
    Title = "Auto Harvest Crops",
    Description = "Automatically harvests fully grown crops around you.",
    Default = false,
    Callback = function(Value)
        FarmingSettings.AutoHarvest = Value
        if Value then
            if HarvestThread then task.cancel(HarvestThread) end
            HarvestThread = task.spawn(function()
                while FarmingSettings.AutoHarvest do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and NET then
                        local actualName = CropMap[FarmingSettings.SelectedCrop] or "wheat"
                        local blocks = getblocksfolder()
                        if blocks then
                            pcall(function()
                                local HarvestRemote = NET:FindFirstChild("CLIENT_HARVEST_CROP_REQUEST")
                                if HarvestRemote then
                                    local radSq = 1600 -- 40^2, easily covers a 16x16 block grid
                                    local count = 0
                                    for i, block in ipairs(blocks:GetChildren()) do
                                        if not FarmingSettings.AutoHarvest then break end
                                        if string.lower(block.Name) == string.lower(actualName) then
                                            local bp = block:FindFirstChildWhichIsA("BasePart")
                                            if bp then
                                                local currentPos = hrp.Position
                                                local d = bp.Position - currentPos
                                                -- Use a strict Box Check (16x16 blocks = 24 studs radius) to perfectly match square farms
                                                if math.abs(d.X) <= 24 and math.abs(d.Z) <= 24 and math.abs(d.Y) <= 20 then
                                                    if not block:GetAttribute("HarvestAttempted") then
                                                        block:SetAttribute("HarvestAttempted", true)
                                                        task.spawn(function()
                                                            pcall(function()
                                                                HarvestRemote:InvokeServer({
                                                                    dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                                                    player = LocalPlayer, 
                                                                    model = block,
                                                                })
                                                            end)
                                                            task.wait(15) -- Long debounce prevents choking on un-grown crops
                                                            if block and block.Parent then block:SetAttribute("HarvestAttempted", nil) end
                                                        end)
                                                        
                                                        -- Wait exactly 200ms per crop as requested to prevent server overload
                                                        task.wait(0.2)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

local PlantThread = nil
local AutoPlantToggle = Tabs.Farming:AddToggle("AutoPlantToggle", {
    Title = "Auto Plant Seeds",
    Description = "Automatically plants selected seeds in empty soil.",
    Default = false,
    Callback = function(Value)
        FarmingSettings.AutoPlant = Value
        if Value then
            if PlantThread then task.cancel(PlantThread) end
            PlantThread = task.spawn(function()
                while FarmingSettings.AutoPlant do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and NET then
                        local actualName = CropMap[FarmingSettings.SelectedCrop] or "wheat"
                        local isBerry = string.find(string.lower(actualName), "bush") ~= nil
                        pcall(function()
                            local PlaceRemote = NET:FindFirstChild("CLIENT_BLOCK_PLACE_REQUEST")
                            if PlaceRemote then
                                local targetBlock = isBerry and "grass" or "soil"
                                local center = hrp.Position
                                local r = 24 -- 48 studs box, perfect for exactly 16x16 blocks
                                local regionParts = workspace:FindPartsInRegion3(
                                    Region3.new(center - Vector3.new(r,r,r), center + Vector3.new(r,r,r)), nil, math.huge
                                )
                                local placeOff = Vector3.new(0, 3, 0)
                                local count = 0
                                for _, v2 in ipairs(regionParts) do
                                    if not FarmingSettings.AutoPlant then break end
                                    if v2.Name == targetBlock and not filledcheck(v2.Position + placeOff) then
                                        if not v2:GetAttribute("PlantAttempted") then
                                            v2:SetAttribute("PlantAttempted", true)
                                            task.spawn(function()
                                                pcall(function()
                                                    PlaceRemote:InvokeServer({
                                                        uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                                        cframe = CFrame.new(v2.Position + placeOff),
                                                        blockType = actualName, 
                                                        upperBlock = false,
                                                    })
                                                end)
                                                task.wait(5)
                                                if v2 and v2.Parent then v2:SetAttribute("PlantAttempted", nil) end
                                            end)
                                            -- Wait exactly 200ms per block
                                            task.wait(0.2)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

local PlowThread = nil
local AutoPlowToggle = Tabs.Farming:AddToggle("AutoPlowToggle", {
    Title = "Auto Plow Grass",
    Description = "Converts surrounding grass blocks into tillable soil.",
    Default = false,
    Callback = function(Value)
        FarmingSettings.AutoPlow = Value
        if Value then
            if PlowThread then task.cancel(PlowThread) end
            PlowThread = task.spawn(function()
                while FarmingSettings.AutoPlow do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and NET then
                        pcall(function()
                            local PlowRemote = NET:FindFirstChild("CLIENT_PLOW_BLOCK_REQUEST")
                            if PlowRemote then
                                local center = hrp.Position
                                local r = 22.5 -- 45 studs box, exactly 15x15 blocks
                                local regionParts = workspace:FindPartsInRegion3(
                                    Region3.new(center - Vector3.new(r,r,r), center + Vector3.new(r,r,r)), nil, math.huge
                                )
                                local count = 0
                                for _, v2 in ipairs(regionParts) do
                                    if not FarmingSettings.AutoPlow then break end
                                    if v2.Name == "grass" then
                                        if not v2:GetAttribute("PlowAttempted") then
                                            v2:SetAttribute("PlowAttempted", true)
                                            task.spawn(function()
                                                pcall(function()
                                                    PlowRemote:InvokeServer({["block"] = v2})
                                                end)
                                                task.wait(5)
                                                if v2 and v2.Parent then v2:SetAttribute("PlowAttempted", nil) end
                                            end)
                                            -- Wait exactly 200ms per block
                                            task.wait(0.2)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

local function isTargetTree(name, selected)
    if selected == "All" then return true end
    if selected == "Oak" then
        local others = {"CherryBlossom", "Birch", "Pine", "Maple", "Hickory", "Spirit"}
        for _, other in ipairs(others) do
            if string.find(name, other) then return false end
        end
        return true
    else
        local matchName = string.gsub(selected, " ", "")
        return string.find(name, matchName) ~= nil
    end
end

FarmingSettings.SelectedTree = "All"
FarmingSettings.AutoTrees = false

Tabs.Farming:AddParagraph({
    Title = "Timber Automation",
    Content = "Select your desired tree type and toggle the automation."
})

local TreeTypes = {
    "All", "Oak", "Birch", "Cherry Blossom", 
    "Hickory", "Maple", "Pine", "Spirit"
}

local TreeDropdown = Tabs.Farming:AddDropdown("TreeDropdown", {
    Title = "Target Tree",
    Values = TreeTypes,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        FarmingSettings.SelectedTree = Value
    end
})

local function getTreePosition(v)
    if v:IsA("Model") then
        if v.PrimaryPart then return v.PrimaryPart.Position end
        local part = v:FindFirstChildWhichIsA("BasePart")
        if part then return part.Position end
    elseif v:IsA("BasePart") then
        return v.Position
    end
end

local function hitblock(HitRemote, block, part)
    if not block then return false end
    part = part or block:FindFirstChildWhichIsA("BasePart") or block
    local args = {
        {
            Xoeoxuqilfgenamojfjmj = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nohIstskUiftvgjy",
            part = part,
            block = block,
            norm = Vector3.new(-3502.331787109375, 39.44426345825195, -3521.013671875),
            pos = Vector3.new(0.9916929006576538, 0.07807211577892303, -0.10222448408603668)
        }
    }
    HitRemote:InvokeServer(unpack(args))
    return true
end


local TreeThread = nil
local TreeNoclipConn = nil

local function ManageTreeThread()
    if FarmingSettings.TreeAura or FarmingSettings.TweenToTree then
        if not TreeNoclipConn then
            TreeNoclipConn = RunService.Stepped:Connect(function()
                if FarmingSettings.TweenToTree then
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
        
        if not TreeThread then
            TreeThread = task.spawn(function()
                while FarmingSettings.TreeAura or FarmingSettings.TweenToTree do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and NET then
                        local blocks = getblocksfolder()
                        if blocks then
                            pcall(function()
                                local HitRemote = NET:FindFirstChild("CLIENT_BLOCK_HIT_REQUEST")
                                if HitRemote then
                                    local currentPos = hrp.Position
                                    local maxDistSq = FarmingSettings.TweenToTree and math.huge or 2500 -- Infinite or 50 studs
                                    local closestDist, closestTree, hitPart = maxDistSq, nil, nil
                                    
                                    for _, block in ipairs(blocks:GetChildren()) do
                                        if string.find(block.Name, "tree", 1, true) then
                                            if isTargetTree(block.Name, FarmingSettings.SelectedTree) then
                                                local pos = getTreePosition(block)
                                                if pos then
                                                    local d = pos - currentPos
                                                    local distSq = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                                                    if distSq < closestDist then
                                                        local trunk = block:FindFirstChild("trunk") or block:FindFirstChild("MeshPart") or block:FindFirstChildWhichIsA("BasePart")
                                                        if trunk then 
                                                            closestDist = distSq
                                                            closestTree = block
                                                            hitPart = trunk 
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    
                                    if closestTree and hitPart then
                                        if FarmingSettings.TweenToTree then
                                            local treePos = getTreePosition(closestTree)
                                            if treePos then
                                                local dist = (treePos - currentPos).Magnitude
                                                if dist > 5 then
                                                    if FarmingSettings.TreeTween then
                                                        pcall(function() FarmingSettings.TreeTween:Cancel() end)
                                                    end
                                                    local speed = 23
                                                    local info = TweenInfo.new(math.max(dist / speed, 0.05), Enum.EasingStyle.Linear)
                                                    
                                                    local bv = hrp:FindFirstChild("TreeFloatBV")
                                                    if not bv then
                                                        bv = Instance.new("BodyVelocity")
                                                        bv.Name = "TreeFloatBV"
                                                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                                        bv.Velocity = Vector3.new(0, 0, 0)
                                                        bv.Parent = hrp
                                                    end

                                                    local TweenService = game:GetService("TweenService")
                                                    FarmingSettings.TreeTween = TweenService:Create(hrp, info, {CFrame = CFrame.new(treePos + Vector3.new(0, 6, 0)) * hrp.CFrame.Rotation})
                                                    FarmingSettings.TreeTween:Play()
                                                end
                                            end
                                        end
                                        
                                        task.spawn(function()
                                            pcall(function()
                                                hitblock(HitRemote, closestTree, hitPart)
                                            end)
                                        end)
                                    else
                                        if FarmingSettings.TweenToTree then
                                            local bv = hrp:FindFirstChild("TreeFloatBV")
                                            if bv then bv:Destroy() end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    else
        if TreeNoclipConn then
            TreeNoclipConn:Disconnect()
            TreeNoclipConn = nil
        end
        if TreeThread then
            task.cancel(TreeThread)
            TreeThread = nil
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("TreeFloatBV")
            if bv then bv:Destroy() end
        end
        if FarmingSettings.TreeTween then
            pcall(function() FarmingSettings.TreeTween:Cancel() end)
            FarmingSettings.TreeTween = nil
        end
    end
end

local TreeAuraToggle = Tabs.Farming:AddToggle("TreeAuraToggle", {
    Title = "Auto Chop Trees",
    Description = "Automatically cuts down selected trees within your radius.",
    Default = false,
    Callback = function(Value)
        FarmingSettings.TreeAura = Value
        ManageTreeThread()
    end
})

local TweenToTreeToggle = Tabs.Farming:AddToggle("TweenToTreeToggle", {
    Title = "Tween to Trees",
    Description = "Smoothly navigates to distant trees for continuous harvesting.",
    Default = false,
    Callback = function(Value)
        FarmingSettings.TweenToTree = Value
        ManageTreeThread()
    end
})



local RockTypes = {
    "All", "Iron", "Gold", "Diamond", "Amethyst Stone", "Amethyst",
    "Obsidian", "Opal", "Copper", "Diorite", "Coal", "Stone", "Electrite"
}

local RockNameMap = {
    ["Iron"] = "rockIron",
    ["Gold"] = "rockGold",
    ["Diamond"] = "rockDiamond",
    ["Amethyst Stone"] = "rockAmethystStone",
    ["Amethyst"] = "rockAmethyst", 
    ["Obsidian"] = "rockObsidian",
    ["Opal"] = "rockOpal",
    ["Copper"] = "rockCopper",
    ["Diorite"] = "rockDiorite",
    ["Coal"] = "rockCoal",
    ["Stone"] = "rockStone",
    ["Electrite"] = "rockElectrite"
}

local function isTargetRock(name, selected)
    if selected == "All" then
        return string.find(name, "rock") ~= nil
    end
    
    local matchName = RockNameMap[selected]
    if not matchName then return false end
    
    -- Special case for Amethyst vs AmethystStone
    if selected == "Amethyst" then
        return string.find(name, matchName) ~= nil and not string.find(name, "rockAmethystStone")
    else
        return string.find(name, matchName) ~= nil
    end
end

local RockThread = nil
local RockNoclipConn = nil

local function ManageRockThread()
    if MiningSettings.RockAura or MiningSettings.TweenToRock then
        if not RockNoclipConn then
            RockNoclipConn = RunService.Stepped:Connect(function()
                if MiningSettings.TweenToRock then
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
        
        if not RockThread then
            RockThread = task.spawn(function()
                while MiningSettings.RockAura or MiningSettings.TweenToRock do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and NET then
                        pcall(function()
                            local HitRemote = NET:FindFirstChild("CLIENT_BLOCK_HIT_REQUEST")
                            if HitRemote then
                                local currentPos = hrp.Position
                                local maxDistSq = MiningSettings.TweenToRock and 360000 or 2500 -- 600 studs or 50 studs
                                local closestDist, closestRock, hitPart = maxDistSq, nil, nil
                                
                                local blockList = {}
                                if MiningSettings.TargetArea == "Private Island" then
                                    local blocks = getblocksfolder()
                                    if blocks then for _, v in ipairs(blocks:GetChildren()) do table.insert(blockList, v) end end
                                end
                                if MiningSettings.TargetArea == "Wilderness (Public)" then
                                    local wild = workspace:FindFirstChild("WildernessBlocks")
                                    if wild then for _, v in ipairs(wild:GetChildren()) do table.insert(blockList, v) end end
                                end
                                
                                for _, block in ipairs(blockList) do
                                        if string.find(block.Name, "rock", 1, true) then
                                            if isTargetRock(block.Name, MiningSettings.SelectedRock) then
                                                local pos = getTreePosition(block)
                                                if pos then
                                                    local d = pos - currentPos
                                                    local distSq = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                                                    if distSq < closestDist then
                                                        local bp = block:IsA("BasePart") and block or block:FindFirstChildWhichIsA("BasePart")
                                                        if bp then 
                                                            closestDist = distSq
                                                            closestRock = block
                                                            hitPart = bp 
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    
                                    if closestRock and hitPart then
                                        if MiningSettings.TweenToRock then
                                            local rockPos = getTreePosition(closestRock)
                                            if rockPos then
                                                local dist = (rockPos - currentPos).Magnitude
                                                if dist > 5 then
                                                    if MiningSettings.RockTween then
                                                        pcall(function() MiningSettings.RockTween:Cancel() end)
                                                    end
                                                    local speed = 23
                                                    local info = TweenInfo.new(math.max(dist / speed, 0.05), Enum.EasingStyle.Linear)
                                                    
                                                    local bv = hrp:FindFirstChild("RockFloatBV")
                                                    if not bv then
                                                        bv = Instance.new("BodyVelocity")
                                                        bv.Name = "RockFloatBV"
                                                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                                        bv.Velocity = Vector3.new(0, 0, 0)
                                                        bv.Parent = hrp
                                                    end

                                                    local TweenService = game:GetService("TweenService")
                                                    MiningSettings.RockTween = TweenService:Create(hrp, info, {CFrame = CFrame.new(rockPos + Vector3.new(0, 4, 0)) * hrp.CFrame.Rotation})
                                                    MiningSettings.RockTween:Play()
                                                end
                                            end
                                        end
                                        
                                        task.spawn(function()
                                            pcall(function()
                                                hitblock(HitRemote, closestRock, hitPart)
                                            end)
                                        end)
                                    else
                                        if MiningSettings.TweenToRock then
                                            local bv = hrp:FindFirstChild("RockFloatBV")
                                            if bv then bv:Destroy() end
                                        end
                                    end
                                end
                            end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    else
        if RockNoclipConn then
            RockNoclipConn:Disconnect()
            RockNoclipConn = nil
        end
        if RockThread then
            task.cancel(RockThread)
            RockThread = nil
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("RockFloatBV")
            if bv then bv:Destroy() end
        end
        if MiningSettings.RockTween then
            pcall(function() MiningSettings.RockTween:Cancel() end)
            MiningSettings.RockTween = nil
        end
    end
end

Tabs.Farming:AddParagraph({
    Title = "Mining Automation",
    Content = "Select your desired ore/rock and toggle the automation."
})

local RockDropdown = Tabs.Farming:AddDropdown("RockDropdown", {
    Title = "Target Ore",
    Values = RockTypes,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        MiningSettings.SelectedRock = Value
    end
})

local MiningAreaDropdown = Tabs.Farming:AddDropdown("MiningAreaDropdown", {
    Title = "Mining Radius",
    Values = {"Wilderness (Public)", "Private Island"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        MiningSettings.TargetArea = Value
    end
})

local RockAuraToggle = Tabs.Farming:AddToggle("RockAuraToggle", {
    Title = "Auto Mine Ores",
    Description = "Automatically mines selected ore nodes within your radius.",
    Default = false,
    Callback = function(Value)
        MiningSettings.RockAura = Value
        ManageRockThread()
    end
})

local TweenToRockToggle = Tabs.Farming:AddToggle("TweenToRockToggle", {
    Title = "Tween to Ores",
    Description = "Smoothly navigates to distant ores for continuous mining.",
    Default = false,
    Callback = function(Value)
        MiningSettings.TweenToRock = Value
        ManageRockThread()
    end
})



local ForageSettings = {
    SelectedItem = "Red Mushroom",
    AutoForage = false,
    ForageTween = nil
}

local ForageNameMap = {
    ["Red Mushroom"] = "mushroomRed",
    ["Acorn"] = "acorn",
    ["Crocus Flower"] = "flowerCrocus",
    ["Daffodil Flower"] = "flowerDaffodil",
    ["Horseradish"] = "horseradish",
    ["All Items"] = "All"
}

local ForageTypes = {"All Items", "Red Mushroom", "Acorn", "Crocus Flower", "Daffodil Flower", "Horseradish"}

local ForageThread = nil
local ForageNoclipConn = nil

local function ManageForageThread()
    if ForageSettings.AutoForage then
        if not ForageNoclipConn then
            ForageNoclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
        
        if not ForageThread then
            ForageThread = task.spawn(function()
                while ForageSettings.AutoForage do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local wildBlocks = workspace:FindFirstChild("WildernessBlocks")
                        if wildBlocks then
                            local searchName = ForageNameMap[ForageSettings.SelectedItem]
                            local closestItem = nil
                            local closestDist = math.huge
                            
                            local validForage = {
                                ["mushroomRed"] = true,
                                ["acorn"] = true,
                                ["flowerCrocus"] = true,
                                ["flowerDaffodil"] = true,
                                ["horseradish"] = true
                            }
                            
                            for _, item in ipairs(wildBlocks:GetChildren()) do
                                if (searchName == "All" and validForage[item.Name]) or item.Name == searchName then
                                    local part = item:FindFirstChildWhichIsA("BasePart", true)
                                    if part then
                                        local dist = (part.Position - hrp.Position).Magnitude
                                        if dist < closestDist then
                                            closestDist = dist
                                            closestItem = part
                                        end
                                    end
                                end
                            end
                            
                            if closestItem then
                                local targetPart = closestItem
                                local dist = (targetPart.Position - hrp.Position).Magnitude
                                
                                if dist > 6 then
                                    local speed = 25
                                    local info = TweenInfo.new(math.max(dist / speed, 0.01), Enum.EasingStyle.Linear)
                                    local TweenService = game:GetService("TweenService")
                                    
                                    local bv = hrp:FindFirstChild("ForageFloatBV")
                                    if not bv then
                                        bv = Instance.new("BodyVelocity")
                                        bv.Name = "ForageFloatBV"
                                        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                                        bv.Velocity = Vector3.new(0, 0, 0)
                                        bv.Parent = hrp
                                    end
                                    
                                    ForageSettings.ForageTween = TweenService:Create(hrp, info, {CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)})
                                    ForageSettings.ForageTween:Play()
                                    ForageSettings.ForageTween.Completed:Wait()
                                else
                                    if ForageSettings.ForageTween then
                                        pcall(function() ForageSettings.ForageTween:Cancel() end)
                                    end
                                    local bv = hrp:FindFirstChild("ForageFloatBV")
                                    if bv then bv:Destroy() end
                                    
                                    -- Use Remote to harvest (no zoom, no virtual mouse)
                                    pcall(function()
                                        local net = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
                                        local harvestRemote = net:FindFirstChild("CLIENT_HARVEST_CROP_REQUEST")
                                        if harvestRemote then
                                            pcall(function()
                                                harvestRemote:InvokeServer({
                                                    dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                                    player = LocalPlayer,
                                                    model = targetPart.Parent -- The model of the forage item
                                                })
                                            end)
                                        end
                                        
                                        -- Flowers (and sometimes other wild items) use specific obfuscated remotes
                                        local req1 = net:FindFirstChild("client_request_1")
                                        if req1 then
                                            pcall(function()
                                                req1:InvokeServer({ flower = targetPart.Parent })
                                            end)
                                            -- Just in case it needs the standard payload on this remote
                                            pcall(function()
                                                req1:InvokeServer({
                                                    dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                                    player = LocalPlayer,
                                                    model = targetPart.Parent
                                                })
                                            end)
                                        end
                                    end)
                                    
                                    task.wait(0.2)
                                end
                            else
                                task.wait(1)
                            end
                        else
                            task.wait(1)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    else
        if ForageNoclipConn then
            ForageNoclipConn:Disconnect()
            ForageNoclipConn = nil
        end
        if ForageThread then
            task.cancel(ForageThread)
            ForageThread = nil
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("ForageFloatBV")
            if bv then bv:Destroy() end
        end
        if ForageSettings.ForageTween then
            pcall(function() ForageSettings.ForageTween:Cancel() end)
            ForageSettings.ForageTween = nil
        end
    end
end

Tabs.Farming:AddParagraph({
    Title = "Foraging Automation",
    Content = "Select your desired forage item and toggle the automation."
})

local ForageDropdown = Tabs.Farming:AddDropdown("ForageDropdown", {
    Title = "Target Resource",
    Values = ForageTypes,
    Default = 1,
    Callback = function(Value)
        ForageSettings.SelectedItem = Value
    end
})

local AutoForageToggle = Tabs.Farming:AddToggle("AutoForageToggle", {
    Title = "Auto Forage",
    Description = "Smoothly navigates to and collects selected wild resources.",
    Default = false,
    Callback = function(Value)
        ForageSettings.AutoForage = Value
        ManageForageThread()
    end
})


local FishingSettings = {
    AutoFishing = false
}

local FishingThread = nil

local LabelSettings = {
    VendingLabels = false,
    ChestLabels = false,
    MaxDist = 15
}

local ActiveLabels = {}

local function getGuiParent()
    local success, res = pcall(function() return gethui and gethui() or game:GetService("CoreGui") end)
    if success and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function ClearAllLabels()
    pcall(function()
        for v, bg in pairs(ActiveLabels) do
            if bg and bg.Parent then bg:Destroy() end
        end
        ActiveLabels = {}
    end)
end

local LabelsThread = nil
local function ManageLabelsThread()
    if LabelSettings.VendingLabels or LabelSettings.ChestLabels then
        if not LabelsThread then
            LabelsThread = task.spawn(function()
                while LabelSettings.VendingLabels or LabelSettings.ChestLabels do
                    local success, err = pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local blocks = getblocksfolder()
                        
                        local currentValidBlocks = {}
                        
                        if hrp and blocks then
                            for _, v in ipairs(blocks:GetChildren()) do
                                local nameLower = v.Name:lower()
                                local isVending = LabelSettings.VendingLabels and nameLower:find("vending")
                                local isChest = LabelSettings.ChestLabels and nameLower:find("chest")
                                
                                if isVending or isChest then
                                    local pos = v:IsA("Model") and (v.PrimaryPart and v.PrimaryPart.Position or v:GetPivot().Position) or v:IsA("BasePart") and v.Position
                                    
                                    if pos then
                                        local dist = (pos - hrp.Position).Magnitude
                                        local targetPart = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v
                                        
                                        if targetPart and dist <= LabelSettings.MaxDist then
                                            currentValidBlocks[v] = true
                                            local bg = ActiveLabels[v]
                                            
                                            if not bg then
                                                bg = Instance.new("BillboardGui")
                                                bg.Name = "LanternLabel"
                                                bg.Size = UDim2.new(0, 150, 0, 40)
                                                bg.StudsOffset = Vector3.new(0, 5, 0)
                                                bg.AlwaysOnTop = true
                                                bg.Adornee = targetPart
                                                bg.Parent = getGuiParent()
                                                ActiveLabels[v] = bg
                                                
                                                local tl = Instance.new("TextLabel", bg)
                                                tl.Size = UDim2.new(1, 0, 1, 0)
                                                tl.BackgroundTransparency = 1
                                                tl.TextColor3 = Color3.new(1, 1, 1)
                                                tl.TextStrokeColor3 = Color3.new(0, 0, 0)
                                                tl.TextStrokeTransparency = 0
                                                tl.TextScaled = false
                                                tl.TextSize = 16
                                                tl.Font = Enum.Font.SourceSansBold
                                            end
                                            
                                            local textLabel = bg:FindFirstChildOfClass("TextLabel")
                                            if textLabel then
                                                if isVending then
                                                    local cb = v:FindFirstChild("CoinBalance")
                                                    local coins = cb and (cb.Value or 0) or 0
                                                    
                                                    local sc = v:FindFirstChild("SellingContents")
                                                    local items = 0
                                                    if sc then
                                                        for _, it in ipairs(sc:GetChildren()) do
                                                            local a = it:FindFirstChild("Amount") or it:FindFirstChild("Value")
                                                            if a then items = items + (a.Value or 0) end
                                                        end
                                                    end
                                                    
                                                    bg.StudsOffset = Vector3.new(0, 7, 0)
                                                    textLabel.Text = "Items : " .. tostring(items) .. "\nCoins : " .. tostring(coins)
                                                    
                                                elseif isChest then
                                                    local items = 0
                                                    local contents = v:FindFirstChild("Contents")
                                                    if contents then
                                                        for _, it in ipairs(contents:GetChildren()) do
                                                            local a = it:FindFirstChild("Amount") or it:FindFirstChild("Value")
                                                            if a then items = items + (a.Value or 0) end
                                                        end
                                                    end
                                                    
                                                    bg.StudsOffset = Vector3.new(0, 3, 0)
                                                    textLabel.Text = "Items : " .. tostring(items) .. "\nName : " .. tostring(v.Name)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        for v, bg in pairs(ActiveLabels) do
                            if not currentValidBlocks[v] then
                                if bg and bg.Parent then bg:Destroy() end
                                ActiveLabels[v] = nil
                            end
                        end
                        
                    end)
                    if not success then warn("[Labels Error] " .. tostring(err)) end
                    task.wait(0.5)
                end
                ClearAllLabels()
                LabelsThread = nil
            end)
        end
    else
        if LabelsThread then
            task.cancel(LabelsThread)
            LabelsThread = nil
        end
        ClearAllLabels()
    end
end


local VendingSettings = {
    SnipeItem = "",
    MaxPrice = 0,
    ScanRadius = 60,
    BuyAnyItem = false,
    AutoSnipe = false
}

local VendingThread = nil

local function ManageVendingThread()
    if VendingSettings.AutoSnipe then
        if not VendingThread then
            VendingThread = task.spawn(function()
                local net = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
                
                local openName = "deGzdggahhjo/qkXeOxsmwiafothorpqogpS"
                local buyName = "deGzdggahhjo/dfiQxh"
                local closeName = "deGzdggahhjo/ifzkjsqjzFvJn"

                while VendingSettings.AutoSnipe do
                    if (VendingSettings.SnipeItem ~= "" or VendingSettings.BuyAnyItem) and VendingSettings.MaxPrice > 0 then
                        pcall(function()
                            local blocks = getblocksfolder()
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            
                            if blocks and hrp then
                                local playerCoins = tonumber(LocalPlayer:GetAttribute("Coins")) or 0
                                
                                for _, V in ipairs(blocks:GetChildren()) do
                                    if V.Name:lower():find("vendingmachine") then
                                        local pos = V:IsA("Model") and (V.PrimaryPart and V.PrimaryPart.Position or V:GetPivot().Position) or V:IsA("BasePart") and V.Position
                                        if pos then
                                            local dist = (pos - hrp.Position).Magnitude
                                            if dist > VendingSettings.ScanRadius then
                                                continue
                                            end
                                        end
                                        
                                        local mode = V:GetAttribute("mode") or V:GetAttribute("Mode")
                                        if mode == nil then 
                                            local mc = V:FindFirstChild("mode") or V:FindFirstChild("Mode")
                                            if mc then mode = mc.Value end 
                                        end
                                        
                                        if mode == 0 then
                                            local price = V:GetAttribute("Price") or V:GetAttribute("TransactionPrice")
                                            if price == nil then 
                                                local pc = V:FindFirstChild("Price") or V:FindFirstChild("TransactionPrice")
                                                if pc then price = pc.Value end 
                                            end
                                            
                                            if price and price > 0 and price <= VendingSettings.MaxPrice then
                                                local contents = V:FindFirstChild("SellingContents")
                                                if contents then
                                                    local itemsToBuy = {}
                                                    
                                                    if VendingSettings.BuyAnyItem then
                                                        for _, item in ipairs(contents:GetChildren()) do
                                                            table.insert(itemsToBuy, item)
                                                        end
                                                    else
                                                        local targetLower = VendingSettings.SnipeItem:lower()
                                                        for _, item in ipairs(contents:GetChildren()) do
                                                            if item.Name:lower():find(targetLower) then
                                                                table.insert(itemsToBuy, item)
                                                            end
                                                        end
                                                    end
                                                    
                                                    if #itemsToBuy > 0 then
                                                        local Guid = game:GetService("HttpService"):GenerateGUID(false)
                                                        
                                                        -- Open
                                                        net:FindFirstChild(openName):FireServer(Guid, {{vendingMachine=V}})
                                                        task.wait(0.05)
                                                        
                                                        for _, itemToBuy in ipairs(itemsToBuy) do
                                                            if playerCoins < price then break end
                                                            
                                                            local amtObj = itemToBuy:FindFirstChild("Amount") or itemToBuy:FindFirstChild("Value")
                                                            local available = amtObj and amtObj.Value or 0
                                                            
                                                            if available > 0 then
                                                                local amtToBuy = math.min(available, math.floor(playerCoins / price))
                                                                if amtToBuy > 0 then
                                                                    local success = pcall(function()
                                                                        net:FindFirstChild(buyName):FireServer(Guid, {{
                                                                            vendingMachine = V, 
                                                                            player_tracking_category = "join_from_web",
                                                                            tool = itemToBuy, 
                                                                            amount = amtToBuy,
                                                                        }})
                                                                    end)
                                                                    
                                                                    if success then
                                                                        playerCoins = playerCoins - (price * amtToBuy)
                                                                        print("[Vending Sniper] Successfully sniped " .. tostring(amtToBuy) .. "x " .. itemToBuy.Name .. " for " .. tostring(price) .. " coins each!")
                                                                    end
                                                                    task.wait(0.05)
                                                                end
                                                            end
                                                        end
                                                        
                                                        -- Close
                                                        net:FindFirstChild(closeName):FireServer({vendingMachine = V})
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    task.wait(2)
                end
                VendingThread = nil
            end)
        end
    else
        if VendingThread then
            task.cancel(VendingThread)
            VendingThread = nil
        end
    end
end


local function ManageFishingThread()
    if FishingSettings.AutoFishing then
        if not FishingThread then
            FishingThread = task.spawn(function()
                local net = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
                
                local winName = "bybFwzowayukxnCeCx/iNxxqhXmhuflLjt"
                local finishName = "bybFwzowayukxnCeCx/ilmIfpmuwieupafcjj"
                local castName = "bybFwzowayukxnCeCx/ecxnnzkznjuFaqtmlrjrov"

                local currentCastGuid = nil
                local lastCastTime = 0

                while FishingSettings.AutoFishing do
                    local isMinigameActive = false
                    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                    local actionbar = pgui and pgui:FindFirstChild("ActionBarScreenGui") and pgui.ActionBarScreenGui:FindFirstChild("ActionBar")
                    
                    if actionbar then
                        local minigame = actionbar:FindFirstChild("Minigame", true)
                        if minigame and minigame.Visible ~= false then
                            isMinigameActive = true
                            
                            pcall(function()
                                local winRemote = net:FindFirstChild(winName)
                                if winRemote then
                                    winRemote:FireServer({ success = true })
                                end
                                
                                local finishRemote = net:FindFirstChild(finishName)
                                if finishRemote then
                                    local guid = currentCastGuid or game:GetService("HttpService"):GenerateGUID(false)
                                    finishRemote:FireServer(guid, { {} })
                                end
                            end)
                            
                            -- Force close the entire RoactTree to completely clear the fishing state
                            pcall(function()
                                local current = minigame
                                while current and current.Parent and current.Parent.Name ~= "RoactTree" do
                                    current = current.Parent
                                end
                                if current and current.Parent then
                                    local roactTree = current.Parent
                                    
                                    local node2 = roactTree:FindFirstChild("2")
                                    if node2 then node2:Destroy() end
                                    
                                    current.Visible = false
                                    task.wait(0.1)
                                    current:Destroy()
                                end
                            end)
                            
                            -- Reset Fishing Rod state by forcing a jump
                            pcall(function()
                                local char = LocalPlayer.Character
                                local hum = char and char:FindFirstChild("Humanoid")
                                if hum then
                                    hum.Jump = true
                                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end)
                            
                            lastCastTime = 0 -- Reset timer to cast again immediately
                            task.wait(1)
                        end
                        
                        -- Aggressively check for and destroy GameOverScreen
                        pcall(function()
                            local gameOver = actionbar:FindFirstChild("GameOverScreen")
                            if gameOver then
                                gameOver.Visible = false
                                gameOver:Destroy()
                            end
                        end)
                    end
                    
                    -- Auto Cast Logic
                    if not isMinigameActive then
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local tool = char and char:FindFirstChildWhichIsA("Tool")
                        local isHoldingRod = tool and tool.Name:lower():find("rod")
                        
                        -- Auto Equip (DISABLED as per user request to avoid inventory bouncing)
                        --[[
                        if not isHoldingRod then
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            local hum = char and char:FindFirstChild("Humanoid")
                            if backpack and hum then
                                for _, item in ipairs(backpack:GetChildren()) do
                                    if item:IsA("Tool") and item.Name:lower():find("rod") then
                                        hum:EquipTool(item)
                                        isHoldingRod = true
                                        break
                                    end
                                end
                            end
                        end
                        ]]
                        
                        -- Cast if 10 seconds passed since last cast
                        if isHoldingRod and hrp and (tick() - lastCastTime > 10) then
                            local closest = nil
                            local minDist = 150
                            
                            for _, v in ipairs(workspace:GetDescendants()) do
                                if v.Name == "fishShadow" or v.Name == "fishShadowSpirit" then
                                    local pos = v:IsA("BasePart") and v.Position or (v:IsA("Model") and v.PrimaryPart and v.PrimaryPart.Position)
                                    if pos then
                                        local d = (pos - hrp.Position).Magnitude
                                        if d < minDist then
                                            minDist = d
                                            closest = pos
                                        end
                                    end
                                end
                            end
                            
                            if not closest then
                                closest = hrp.Position + (hrp.CFrame.LookVector * 15)
                            end
                            
                            if closest then
                                local guid = game:GetService("HttpService"):GenerateGUID(false)
                                currentCastGuid = guid
                                local dir = (closest - hrp.Position).Unit
                                
                                pcall(function()
                                    net:FindFirstChild(castName):FireServer(guid, {{
                                        playerLocation = hrp.Position,
                                        direction = dir,
                                        strength = 1.06427796681722005
                                    }})
                                end)
                                
                                lastCastTime = tick()
                            end
                        end
                    end
                    
                    task.wait(0.1)
                end
                FishingThread = nil
            end)
        end
    else
        if FishingThread then
            task.cancel(FishingThread)
            FishingThread = nil
        end
    end
end


local MobTypes = {
    "Slime", "Skeleton Pirate", "Angry Crab", "Buffalkor", "Rock Mimic", 
    "Wizard Lizard", "Skorp", "Magma Blob", "Magma Golem", "Void Hound"
}

local BossTypes = {
    "Slime King", "Slime Queen", "Kor", "Wizard Boss", 
    "Bhaa", "Infernal Dragon", "Fhanhorn", "Void Serpent"
}

local MonsterNameMap = {
    ["Slime"] = "slime",
    ["Skeleton Pirate"] = "skeletonPirate",
    ["Angry Crab"] = "crab",
    ["Buffalkor"] = "buffalkor",
    ["Rock Mimic"] = "rockmimic",
    ["Wizard Lizard"] = "wizardlizard",
    ["Skorp"] = "skorp",
    ["Magma Blob"] = "magmablob",
    ["Magma Golem"] = "magmagolem",
    ["Void Hound"] = "voiddog",
    ["Slime King"] = "slimeking",
    ["Slime Queen"] = "slimequeen",
    ["Kor"] = "golem",
    ["Wizard Boss"] = "wizardboss",
    ["Bhaa"] = "desertboss",
    ["Infernal Dragon"] = "dragon",
    ["Fhanhorn"] = "deerboss",
    ["Void Serpent"] = "voidserpent"
}

local BossSpawnMap = {
    ["Slime King"] = "slime_king_spawn",
    ["Slime Queen"] = "slime_queen_spawn",
    ["Kor"] = "golem_spawn",
    ["Wizard Boss"] = "wizard_boss_spawn",
    ["Bhaa"] = "desert_boss_spawn",
    ["Infernal Dragon"] = "dragon_boss_spawn",
    ["Fhanhorn"] = "deer_boss_spawn",
    ["Void Serpent"] = "void_serpent_spawn"
}

local MonsterSettings = {
    SelectedMob = "Slime",
    SelectedBoss = "Slime King",
    MonsterAura = false,
    TweenToMob = false,
    TweenToBoss = false,
    AutoEquip = false,
    LastWeapon = nil,
    TweenMaxDistance = 1500
}

local MonsterThread = nil
local MonsterNoclipConn = nil
local MonsterAntiProjConn = nil

local function ManageMonsterThread()
    local isFarmingMob = MonsterSettings.TweenToMob
    local isFarmingBoss = MonsterSettings.TweenToBoss
    local isAura = MonsterSettings.MonsterAura
    
    if isAura or isFarmingMob or isFarmingBoss then
        if not MonsterNoclipConn then
            MonsterNoclipConn = RunService.Stepped:Connect(function()
                if MonsterSettings.TweenToMob or MonsterSettings.TweenToBoss then
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
        
        if not MonsterThread then
            MonsterThread = task.spawn(function()
                local lastHit = 0
                local currentTarget = nil
                while MonsterSettings.MonsterAura or MonsterSettings.TweenToMob or MonsterSettings.TweenToBoss do
                    local char = LocalPlayer.Character
                    if char then
                        local currentTool = char:FindFirstChildWhichIsA("Tool")
                        if currentTool then
                            MonsterSettings.LastWeapon = currentTool.Name
                        elseif MonsterSettings.AutoEquip and MonsterSettings.LastWeapon then
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            local toolToEquip = backpack and backpack:FindFirstChild(MonsterSettings.LastWeapon)
                            local hum = char:FindFirstChild("Humanoid")
                            if toolToEquip and hum and hum.Health > 0 then
                                pcall(function() hum:EquipTool(toolToEquip) end)
                            end
                        end
                    end
                    
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and NET then
                        local entities = workspace:FindFirstChild("Entities")
                        local wildIsland = workspace:FindFirstChild("WildernessIsland")
                        local wildEntities = wildIsland and wildIsland:FindFirstChild("Entities")
                        
                        pcall(function()
                            local HitRemote = NET:FindFirstChild("fLafXsVXagmlXhlc/UlpaomJfNzwc")
                            if HitRemote then
                                local currentPos = hrp.Position
                                local maxDistSq = (MonsterSettings.TweenToMob or MonsterSettings.TweenToBoss) and (MonsterSettings.TweenMaxDistance * MonsterSettings.TweenMaxDistance) or 2500
                                local closestDist, closestMob, hitPart = maxDistSq, nil, nil
                                
                                local mobList = {}
                                if entities then for _, v in ipairs(entities:GetChildren()) do table.insert(mobList, v) end end
                                if wildEntities then for _, v in ipairs(wildEntities:GetChildren()) do table.insert(mobList, v) end end
                                
                                local targetSetting = MonsterSettings.TweenToBoss and MonsterSettings.SelectedBoss or MonsterSettings.SelectedMob
                                local searchName1 = MonsterNameMap[targetSetting]:lower()
                                local searchName2 = targetSetting:lower():gsub("%s", "")
                                
                                local function isValidTarget(mobInst)
                                    if not mobInst then return false end
                                    local cName = mobInst.Name:lower():gsub("_", "")
                                    local isMatch = cName:find(searchName1) or cName:find(searchName2)
                                    
                                    if isMatch and MonsterSettings.TweenToMob and not MonsterSettings.TweenToBoss then
                                        -- Prevent "Slime" from targeting "Slime King" or "Slime Queen"
                                        if targetSetting == "Slime" then
                                            if cName:find("king") or cName:find("queen") then
                                                return false
                                            end
                                        end
                                    end
                                    return isMatch
                                end
                                
                                if currentTarget then
                                    local hum = currentTarget:FindFirstChild("Humanoid")
                                    local mobHrp = currentTarget:FindFirstChild("HumanoidRootPart")
                                    if hum and hum.Health > 0 and mobHrp and isValidTarget(currentTarget) then
                                        local d = mobHrp.Position - currentPos
                                        local distSq = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                                        if distSq <= maxDistSq then
                                            closestMob = currentTarget
                                            hitPart = mobHrp
                                        else
                                            currentTarget = nil
                                        end
                                    else
                                        currentTarget = nil
                                    end
                                end

                                if not currentTarget then
                                    for _, mob in ipairs(mobList) do
                                        local hum = mob:FindFirstChild("Humanoid")
                                        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                                        if hum and hum.Health > 0 and mobHrp then
                                            if isValidTarget(mob) then
                                                local d = mobHrp.Position - currentPos
                                                local distSq = d.X*d.X + d.Y*d.Y + d.Z*d.Z
                                                if distSq < closestDist then
                                                    closestDist = distSq
                                                    closestMob = mob
                                                    hitPart = mobHrp 
                                                end
                                            end
                                        end
                                    end
                                    if closestMob then currentTarget = closestMob end
                                end
                                
                                if not closestMob and MonsterSettings.TweenToBoss then
                                    local bossKey = MonsterSettings.SelectedBoss
                                    local spawnPartName = BossSpawnMap[bossKey]
                                    if spawnPartName then
                                        local spawnPart = nil
                                        local spawnPrefabs = workspace:FindFirstChild("spawnPrefabs")
                                        local wildTriggers = spawnPrefabs and spawnPrefabs:FindFirstChild("WildEventTriggers")
                                        spawnPart = wildTriggers and wildTriggers:FindFirstChild(spawnPartName)
                                        if not spawnPart then
                                            for _, v in ipairs(workspace:GetDescendants()) do
                                                if v.Name:lower() == spawnPartName:lower() then
                                                    if v:IsA("BasePart") or v:IsA("Model") then
                                                        spawnPart = v
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                        if spawnPart then
                                            local spPos = spawnPart:IsA("Model") and spawnPart:GetPivot().Position or spawnPart.Position
                                            local TargetPos = spPos + Vector3.new(0, 3, 0)
                                            local dist = (TargetPos - currentPos).Magnitude
                                            if dist > 6 then
                                                if MonsterSettings.MonsterTween then pcall(function() MonsterSettings.MonsterTween:Cancel() end) end
                                                local speed = 23
                                                local info = TweenInfo.new(math.max(dist / speed, 0.01), Enum.EasingStyle.Linear)
                                                local TweenService = game:GetService("TweenService")
                                                local aimCFrame = CFrame.new(TargetPos) * (hrp.CFrame - hrp.CFrame.Position)
                                                MonsterSettings.MonsterTween = TweenService:Create(hrp, info, {CFrame = aimCFrame})
                                                MonsterSettings.MonsterTween:Play()
                                            else
                                                local Prompt = spawnPart:FindFirstChildOfClass("ProximityPrompt", true)
                                                if Prompt and Prompt.Enabled then
                                                    fireproximityprompt(Prompt)
                                                    task.wait(0.5)
                                                end
                                            end
                                            
                                            local bv = hrp:FindFirstChild("MonsterFloatBV")
                                            if not bv then
                                                bv = Instance.new("BodyVelocity")
                                                bv.Name = "MonsterFloatBV"
                                                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                                bv.Velocity = Vector3.new(0, 0, 0)
                                                bv.Parent = hrp
                                            end
                                        end
                                    end
                                elseif closestMob and hitPart then
                                    if MonsterSettings.TweenToMob or MonsterSettings.TweenToBoss then
                                        local mobPos = hitPart.Position
                                        local targetSetting = MonsterSettings.TweenToBoss and MonsterSettings.SelectedBoss or MonsterSettings.SelectedMob
                                        local customOffsets = {
                                            ["Slime"] = -12,
                                            ["Skeleton Pirate"] = -12,
                                            ["Angry Crab"] = -12,
                                            ["Buffalkor"] = -12,
                                            ["Rock Mimic"] = -12,
                                            ["Wizard Lizard"] = -22,
                                            ["Skorp"] = -12,
                                            ["Magma Blob"] = 40,
                                            ["Magma Golem"] = 40,
                                            ["Void Hound"] = -12,
                                            ["Slime King"] = -12,
                                            ["Slime Queen"] = -12,
                                            ["Kor"] = 12,
                                            ["Wizard Boss"] = -22,
                                            ["Bhaa"] = -12,
                                            ["Infernal Dragon"] = 40,
                                            ["Fhanhorn"] = -12,
                                            ["Void Serpent"] = -12
                                        }
                                        local YO = customOffsets[targetSetting] or MonsterSettings.TweenDepth or -11
                                                
                                        local targetPos = mobPos + Vector3.new(0, YO, 0)
                                        local dist = (targetPos - currentPos).Magnitude
                                        
                                        if dist > 4 then
                                            if MonsterSettings.MonsterTween then
                                                pcall(function() MonsterSettings.MonsterTween:Cancel() end)
                                            end
                                            local speed = 23
                                            local info = TweenInfo.new(math.max(dist / speed, 0.01), Enum.EasingStyle.Linear)
                                            local TweenService = game:GetService("TweenService")
                                            local isMagic = false
                                            local tool = char:FindFirstChildWhichIsA("Tool")
                                            if tool then
                                                local tName = tool.Name:lower()
                                                isMagic = tName:find("spellbook") or tName:find("staff") or tName:find("scepter") or tName:find("tome") or tName:find("grimoire") or tName:find("magic")
                                            end
                                            
                                            local aimCFrame
                                            if isMagic then
                                                aimCFrame = CFrame.lookAt(targetPos, mobPos)
                                            else
                                                aimCFrame = CFrame.new(targetPos) * (hrp.CFrame - hrp.CFrame.Position)
                                            end
                                            MonsterSettings.MonsterTween = TweenService:Create(hrp, info, {CFrame = aimCFrame})
                                            MonsterSettings.MonsterTween:Play()
                                        end
                                            
                                        local bv = hrp:FindFirstChild("MonsterFloatBV")
                                        if not bv then
                                            bv = Instance.new("BodyVelocity")
                                            bv.Name = "MonsterFloatBV"
                                            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                            bv.Velocity = Vector3.new(0, 0, 0)
                                            bv.Parent = hrp
                                        end
                                    end
                                    
                                    if tick() - lastHit > 0.5 then
                                        lastHit = tick()
                                        task.spawn(function()
                                            pcall(function()
                                                local char = LocalPlayer.Character
                                                local tool = char and char:FindFirstChildWhichIsA("Tool")
                                                local toolName = tool and tool.Name:lower() or ""
                                                local isMagic = toolName:find("spellbook") or toolName:find("staff") or toolName:find("scepter") or toolName:find("tome") or toolName:find("grimoire") or toolName:find("magic")
                                                
                                                if tool and not isMagic then
                                                    tool:Activate()
                                                end
                                                
                                                pcall(function()
                                                    local vim = game:GetService("VirtualInputManager")
                                                    local camera = workspace.CurrentCamera
                                                    if closestMob and closestMob:FindFirstChild("HumanoidRootPart") then
                                                        local targetPos = closestMob.HumanoidRootPart.Position
                                                        if isMagic then
                                                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                                                            if not onScreen then
                                                                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
                                                                screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                                                            end
                                                            if onScreen then
                                                                vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                                                                task.wait(0.05)
                                                                vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                                                            end
                                                        else
                                                            vim:SendKeyEvent(true, Enum.KeyCode.ButtonR2, false, game)
                                                            task.wait(0.05)
                                                            vim:SendKeyEvent(false, Enum.KeyCode.ButtonR2, false, game)
                                                        end
                                                    end
                                                end)
                                                
                                                HitRemote:FireServer("6164F31F-7600-48E7-866C-7229FEA1FDE1", {{
                                                    hitUnit = closestMob,
                                                    IucpoZdgwp = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nefmmgivC",
                                                }})
                                            end)
                                        end)
                                    end
                                else
                                    if MonsterSettings.TweenToMob or MonsterSettings.TweenToBoss then
                                        local bv = hrp:FindFirstChild("MonsterFloatBV")
                                        if bv then bv:Destroy() end
                                    end
                                end
                            end
                        end)
                    end
                    task.wait(0.2)
                end
            end)
        end
    else
        if MonsterNoclipConn then
            MonsterNoclipConn:Disconnect()
            MonsterNoclipConn = nil
        end

        if MonsterThread then
            task.cancel(MonsterThread)
            MonsterThread = nil
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("MonsterFloatBV")
            if bv then bv:Destroy() end
        end
        if MonsterSettings.MonsterTween then
            pcall(function() MonsterSettings.MonsterTween:Cancel() end)
            MonsterSettings.MonsterTween = nil
        end
    end
end



-- ==================================================
-- ⚔️ MONSTER TAB
-- ==================================================
Tabs.Monster:AddParagraph({
    Title = "Combat Automation",
    Content = "Select your desired monster and toggle the automation."
})

local MobDropdown = Tabs.Monster:AddDropdown("MobDropdown", {
    Title = "Target Mob",
    Values = MobTypes,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        MonsterSettings.SelectedMob = Value
    end
})

local BossDropdown = Tabs.Monster:AddDropdown("BossDropdown", {
    Title = "Target Boss",
    Values = BossTypes,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        MonsterSettings.SelectedBoss = Value
    end
})

local MonsterAuraToggle = Tabs.Monster:AddToggle("MonsterAuraToggle", {
    Title = "Kill Aura",
    Description = "Automatically damages hostile entities within your radius.",
    Default = false,
    Callback = function(Value)
        MonsterSettings.MonsterAura = Value
        ManageMonsterThread()
    end
})

local TweenToMobToggle = Tabs.Monster:AddToggle("TweenToMobToggle", {
    Title = "Auto Farm Mobs",
    Description = "Smoothly navigates to and eliminates standard enemies.",
    Default = false,
    Callback = function(Value)
        MonsterSettings.TweenToMob = Value
        if Value then MonsterSettings.TweenToBoss = false end
        ManageMonsterThread()
    end
})

local TweenToBossToggle = Tabs.Monster:AddToggle("TweenToBossToggle", {
    Title = "Auto Farm Bosses",
    Description = "Automatically summons and defeats the selected boss.",
    Default = false,
    Callback = function(Value)
        MonsterSettings.TweenToBoss = Value
        if Value then MonsterSettings.TweenToMob = false end
        ManageMonsterThread()
    end
})

local AutoEquipToggle = Tabs.Monster:AddToggle("AutoEquipToggle", {
    Title = "Auto Equip Weapon",
    Description = "Automatically restores your last held weapon after dying or unequipped.",
    Default = false,
    Callback = function(Value)
        MonsterSettings.AutoEquip = Value
    end
})



local MonsterDistanceSlider = Tabs.Monster:AddSlider("MonsterDistanceSlider", {
    Title = "Max Tween Distance",
    Description = "The maximum distance the script will travel to find enemies.",
    Default = 1500,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value)
        MonsterSettings.TweenMaxDistance = Value
    end
})

-- ========================================== --
-- Vending Tab Features
-- ========================================== --


-- ==================================================
-- 🛒 VENDING TAB
-- ==================================================
Tabs.Vending:AddParagraph({
    Title = "Market Sniper",
    Content = "Automatically scans the current island for vending machines and buys items if they meet your target price."
})

local VendingItemInput = Tabs.Vending:AddInput("VendingItemInput", {
    Title = "Target Item",
    Description = "Name of the item you want to purchase.",
    Default = "",
    Placeholder = "e.g. apple",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        VendingSettings.SnipeItem = Value
    end
})

local VendingPriceInput = Tabs.Vending:AddInput("VendingPriceInput", {
    Title = "Price Limit",
    Description = "The maximum amount of coins you are willing to pay per item.",
    Default = "1000",
    Placeholder = "1000",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        VendingSettings.MaxPrice = tonumber(Value) or 0
    end
})

local BuyAnyItemToggle = Tabs.Vending:AddToggle("BuyAnyItemToggle", {
    Title = "Buy Anything (Price Only)",
    Description = "Ignores item names and purchases anything below the price limit.",
    Default = false,
    Callback = function(Value)
        VendingSettings.BuyAnyItem = Value
    end
})

local VendingRadiusSlider = Tabs.Vending:AddSlider("VendingRadiusSlider", {
    Title = "Scan Radius",
    Description = "The scanning range for nearby vending machines.",
    Default = 60,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        VendingSettings.ScanRadius = Value
    end
})

local AutoSnipeToggle = Tabs.Vending:AddToggle("AutoSnipeToggle", {
    Title = "Enable Sniper",
    Description = "Automatically scans and purchases items from nearby vending machines.",
    Default = false,
    Callback = function(Value)
        VendingSettings.AutoSnipe = Value
        ManageVendingThread()
    end
})

-- ========================================== --
-- Misc Tab Features
-- ========================================== --


-- ==================================================
-- 📦 MISC TAB
-- ==================================================
Tabs.Misc:AddParagraph({
    Title = "Utility Systems",
    Content = "Useful features to enhance your gameplay experience."
})

local AutoFishingToggle = Tabs.Misc:AddToggle("AutoFishingToggle", {
    Title = "Auto Fishing",
    Description = "Fully automates the fishing minigame (auto-cast and auto-catch).",
    Default = false,
    Callback = function(Value)
        FishingSettings.AutoFishing = Value
        ManageFishingThread()
    end
})

local AntiAFKToggle = Tabs.Misc:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK",
    Description = "Prevents you from being disconnected for idle behavior (Error 268).",
    Default = false,
    Callback = function(Value)
        _G.AntiAFK_Enabled = Value
        
        local function doJump()
            pcall(function()
                -- Method 1: Hardware-like spacebar press (works best when focused)
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                
                -- Method 2: Engine-level jump (works best when out of focus / tabbed out)
                local char = game:GetService("Players").LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.Jump = true
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    end
                end
            end)
        end
        
        if Value then
            -- Connect to Idled event to prevent actual kick
            if not _G.AntiAFK_Connection then
                local Players = game:GetService("Players")
                _G.AntiAFK_Connection = Players.LocalPlayer.Idled:Connect(function()
                    local vu = game:GetService("VirtualUser")
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
            
            -- Jump immediately
            doJump()
            
            -- Update the start time for the loop
            _G.AntiAFK_Tick = tick()
            
            -- Spawn a thread to jump periodically
            if not _G.AntiAFK_ThreadRunning then
                _G.AntiAFK_ThreadRunning = true
                task.spawn(function()
                    while _G.AntiAFK_Enabled do
                        task.wait(1) -- Check every second to allow quick breaks
                        if _G.AntiAFK_Enabled and (tick() - _G.AntiAFK_Tick >= 60) then
                            _G.AntiAFK_Tick = tick()
                            doJump()
                        end
                    end
                    _G.AntiAFK_ThreadRunning = false
                end)
            end
        else
            if _G.AntiAFK_Connection then
                _G.AntiAFK_Connection:Disconnect()
                _G.AntiAFK_Connection = nil
            end
        end
    end
})

-- [[ 4. SaveManager & InterfaceManager Settings ]] --


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

-- Set folder for saving configs
InterfaceManager:SetFolder("LanternHUB")
SaveManager:SetFolder("LanternHUB/configs")

-- Build UI settings in Settings tab
  
  -- NEW MISC FEATURES
  local JoinCodeTarget = ""
  Tabs.Misc:AddInput("JoinCodeInput", {
      Title = "Join Code Spoofer",
      Description = "Spoofs your visible join code.",
      Default = "",
      Placeholder = "e.g. ABC12",
      Numeric = false,
      Finished = true,
      Callback = function(Value)
          JoinCodeTarget = Value
          local jc = LocalPlayer:FindFirstChild("JoinCode")
          if jc then jc.Value = Value end
      end
  })
  
  Tabs.Misc:AddButton({
      Title = "Join Island",
      Description = "Teleports you to the specified island code.",
      Callback = function()
          if JoinCodeTarget ~= "" then
              pcall(function()
                  local net = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
                  -- Try to invoke the standard join remote if it exists
                  local joinRemote = net:FindFirstChild("client_request_6")
                  if joinRemote then
                      joinRemote:InvokeServer(JoinCodeTarget)
                  end
              end)
          end
      end
  })
  
  local InviteTarget = ""
  Tabs.Misc:AddInput("InviteInput", {
      Title = "Invite Player",
      Description = "Enter the username of the player you want to invite.",
      Default = "",
      Placeholder = "Username...",
      Numeric = false,
      Finished = true,
      Callback = function(Value)
          InviteTarget = Value
      end
  })
  
  Tabs.Misc:AddButton({
      Title = "Send Island Invite",
      Description = "Sends an island invitation to the specified player.",
      Callback = function()
          if InviteTarget ~= "" then
              task.spawn(function()
                  local ok, uid = pcall(function() 
                      return game:GetService("Players"):GetUserIdFromNameAsync(InviteTarget) 
                  end)
                  if ok and uid then
                      local net = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
                      local inviteRemote = net:FindFirstChild("client_request_8")
                      if inviteRemote then
                          inviteRemote:InvokeServer({userId=uid, name=InviteTarget})
                      end
                  end
              end)
          end
      end
  })
  
  local ViewInvTarget = ""
  Tabs.Misc:AddInput("ViewInvInput", {
      Title = "Target Username",
      Description = "Enter the username of the player to inspect.",
      Default = "",
      Placeholder = "Username...",
      Numeric = false,
      Finished = true,
      Callback = function(Value)
          ViewInvTarget = Value
      end
  })
  
  Tabs.Misc:AddButton({
      Title = "Inspect Inventory",
      Description = "Opens a UI showing the target player's current inventory.",
      Callback = function()
          pcall(function()
              local RoactModule = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("roact"):WaitForChild("src")
              local Roact = require(RoactModule)
              local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
              
              local current = PlayerScripts
              for _, name in ipairs({"TS", "flame", "controllers", "moderation", "ui", "inventory-peek-wrapper"}) do 
                  current = current:WaitForChild(name, 5)
                  if not current then return end 
              end
              local PeekWrapperModule = current
              if not PeekWrapperModule then return end
              
              local InventoryPeekWrapper = require(PeekWrapperModule).InventoryPeekWrapper
              local TargetPlayer = LocalPlayer
              
              if ViewInvTarget ~= "" then
                  for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                      if p.Name:lower():find(ViewInvTarget:lower()) or p.DisplayName:lower():find(ViewInvTarget:lower()) then
                          TargetPlayer = p
                          break
                      end
                  end
              end
              
              local RealTools = {}
              local backpack = TargetPlayer:FindFirstChild("Backpack")
              if backpack then
                  for _, tool in ipairs(backpack:GetChildren()) do
                      local amount = 1
                      local AmtObj = tool:FindFirstChild("Amount") or tool:FindFirstChild("Value")
                      if AmtObj and (AmtObj:IsA("IntValue") or AmtObj:IsA("NumberValue")) then amount = AmtObj.Value end
                      table.insert(RealTools, {name=tool.Name, amount=amount, displayName=tool.Name})
                  end
              end
              
              if TargetPlayer.Character then
                  local equipped = TargetPlayer.Character:FindFirstChildWhichIsA("Tool")
                  if equipped then
                      local amount = 1
                      local AmtObj = equipped:FindFirstChild("Amount") or equipped:FindFirstChild("Value")
                      if AmtObj and (AmtObj:IsA("IntValue") or AmtObj:IsA("NumberValue")) then amount = AmtObj.Value end
                      table.insert(RealTools, {name=equipped.Name, amount=amount, displayName=equipped.Name})
                  end
              end
              
              if #RealTools == 0 then 
                  table.insert(RealTools, {name="barrier", amount=0, displayName="No Items Found (Not Replicated)"}) 
              end
              
              if _G.MountedInventoryView then 
                  Roact.unmount(_G.MountedInventoryView)
                  _G.MountedInventoryView = nil 
              end
              
              local app = Roact.createElement("ScreenGui", {DisplayOrder=10000, IgnoreGuiInset=true, ResetOnSpawn=false}, {
                  Roact.createElement(InventoryPeekWrapper, {
                      headerText = TargetPlayer.Name,
                      tools = RealTools,
                      onClose = function()
                          if _G.MountedInventoryView then 
                              Roact.unmount(_G.MountedInventoryView)
                              _G.MountedInventoryView = nil 
                          end
                      end
                  })
              })
              _G.MountedInventoryView = Roact.mount(app, LocalPlayer:WaitForChild("PlayerGui"))
          end)
      end
  })
  
  Tabs.Misc:AddButton({
      Title = "Open Time Menu",
      Description = "Opens the in-game Time Cycle menu.",
      Callback = function()
          pcall(function()
              local path1 = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LeftSidebar")
              if path1 then
                  local btn = path1:FindFirstChild("1") and path1["1"]:FindFirstChild("6") and path1["1"]["6"]:FindFirstChild("5")
                  if not btn then return end
                  
                  if firesignal then
                      pcall(function() firesignal(btn.MouseButton1Click) end)
                      pcall(function() firesignal(btn.Activated) end)
                  elseif getconnections then
                      for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Function() end
                      for _, conn in ipairs(getconnections(btn.Activated)) do conn:Function() end
                  end
              end
              
              -- Also try to just Enable the UI if it's already mounted but hidden
              local tc = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Time Cycle")
              if tc then
                  tc.Enabled = true
              end
          end)
      end
  })
  
  Tabs.Misc:AddParagraph({
      Title = "World ESP",
      Content = "View details of specific blocks in the world."
  })
  
  Tabs.Misc:AddToggle("VendingLabelsToggle", {
      Title = "Vending Machine ESP",
      Description = "Displays available items and coin balance above vending machines.",
      Default = false,
      Callback = function(Value)
          LabelSettings.VendingLabels = Value
          ManageLabelsThread()
      end
  })
  
  Tabs.Misc:AddToggle("ChestLabelsToggle", {
      Title = "Chest ESP",
      Description = "Displays item counts and names above storage chests.",
      Default = false,
      Callback = function(Value)
          LabelSettings.ChestLabels = Value
          ManageLabelsThread()
      end
  })
  
  InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Fluent.Options.MenuKeybind:SetValue("RightControl")
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select the first tab (Main) by default
Window:SelectTab(1)

-- Load the latest saved config
SaveManager:LoadAutoloadConfig()
