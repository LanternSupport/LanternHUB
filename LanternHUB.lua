local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Lantern HUB",
    SubTitle = "v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftShift
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "leaf" }),
    Vending = Window:AddTab({ Title = "Vending", Icon = "shopping-cart" }),
    Building = Window:AddTab({ Title = "Building", Icon = "hammer" }),
    Players = Window:AddTab({ Title = "Players", Icon = "users" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    -- การแจ้งเตือนเมื่อรันสคริปต์
    Fluent:Notify({
        Title = "Lantern HUB",
        Content = "โหลดสคริปต์สำเร็จแล้ว!",
        Duration = 5
    })

    -- ข้อความแสดงในหน้าหลัก
    Tabs.Main:AddParagraph({
        Title = "ยินดีต้อนรับสู่ Lantern HUB",
        Content = "นี่คือโครงสร้าง UI เริ่มต้น คุณสามารถเพิ่มฟังก์ชันต่างๆ ได้ที่นี่"
    })

    -- ตัวอย่างปุ่ม
    Tabs.Main:AddButton({
        Title = "ปุ่มทดสอบ",
        Description = "คลิกเพื่อดู Dialog",
        Callback = function()
            Window:Dialog({
                Title = "ข้อความแจ้งเตือน",
                Content = "คุณได้คลิกปุ่มทดสอบแล้ว!",
                Buttons = {
                    {
                        Title = "ตกลง",
                        Callback = function()
                            print("คลิกตกลง")
                        end
                    },
                    {
                        Title = "ยกเลิก",
                        Callback = function()
                            print("คลิกยกเลิก")
                        end
                    }
                }
            })
        end
    })
    
    -- ตัวอย่างสวิตช์เปิดปิด (Toggle)
    local Toggle = Tabs.Main:AddToggle("AutoFarm", {Title = "เปิดใช้งานฟังก์ชัน", Default = false })
    Toggle:OnChanged(function()
        print("สถานะปุ่มถูกเปลี่ยนเป็น:", Options.AutoFarm.Value)
        -- โค้ดทำงานเมื่อเปิด/ปิด
    end)
    
    -- ตัวอย่างแถบเลื่อน (Slider)
    local Slider = Tabs.Main:AddSlider("WalkSpeed", {
        Title = "ความเร็วเดิน (WalkSpeed)",
        Description = "ปรับความเร็วของตัวละคร",
        Default = 16,
        Min = 16,
        Max = 200,
        Rounding = 1,
        Callback = function(Value)
            print("ความเร็วปรับเป็น:", Value)
        end
    })

    Slider:OnChanged(function(Value)
        print("Slider เปลี่ยนแปลงเป็น:", Value)
    end)

    -------------------------------------------------------------------------
    -- หมวดหมู่: Players (ผู้เล่น)
    -------------------------------------------------------------------------
    Tabs.Players:AddParagraph({
        Title = "Player Settings",
        Content = "ปรับแต่งความสามารถของตัวละครของคุณ"
    })

    -- ตัวแปรและ Service สำหรับระบบล็อกค่า
    local Player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    _G.WalkSpeedEnabled = false
    _G.JumpPowerEnabled = false
    _G.JumpPowerValue = 50
    _G.NoclipEnabled = false
    _G.FlyEnabled = false
    _G.FlySpeed = 0.2

    -- ระบบ Noclip เดินทะลุกำแพง (ใช้ Stepped Event)
    RunService.Stepped:Connect(function()
        if _G.NoclipEnabled and Player.Character then
            for _, part in ipairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    _G.JumpPowerEnabled = false
    _G.JumpPowerValue = 50

    Tabs.Players:AddToggle("WalkSpeedToggle", {
        Title = "Walk Speed",
        Description = "เปิด/ปิด การล็อกความเร็วการเดินไว้ที่ 25",
        Default = false,
        Callback = function(Value)
            _G.WalkSpeedEnabled = Value
            -- คืนค่าเริ่มต้น (16) เมื่อกดปิด
            if not Value and Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.WalkSpeed = 16 
            end
        end
    })

    Tabs.Players:AddToggle("JumpPowerToggle", {
        Title = "Jump Power",
        Description = "เปิด/ปิด การล็อกพลังกระโดด",
        Default = false,
        Callback = function(Value)
            _G.JumpPowerEnabled = Value
            -- คืนค่าเริ่มต้น (50) เมื่อกดปิด
            if not Value and Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.UseJumpPower = true
                Player.Character.Humanoid.JumpPower = 50
            end
        end
    })

    Tabs.Players:AddSlider("JumpPowerSlider", {
        Title = "Jump Power Level",
        Description = "ปรับความสูงในการกระโดด",
        Default = 50,
        Min = 50,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            _G.JumpPowerValue = Value
        end
    })

    -- ----------------------------------------------------
    -- ระบบ Fly (บินอิสระ)
    -- ----------------------------------------------------
    local function getRoot()
        return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    end

    local FlyToggle = Tabs.Players:AddToggle("FlyToggle", {
        Title = "Fly (บินอิสระ)",
        Description = "ล็อกความเร็วบินที่ 0.2 (ควบคุมด้วย W A S D)",
        Default = false,
        Callback = function(Value)
            _G.FlyEnabled = Value
            local root = getRoot()
            if root then
                if Value then
                    -- สร้างตัวยึดจับกลางอากาศ
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "IYFlyBV"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.zero
                    bv.Parent = root
                    
                    local bg = Instance.new("BodyGyro")
                    bg.Name = "IYFlyBG"
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.P = 9e4
                    bg.CFrame = root.CFrame
                    bg.Parent = root
                    
                    if Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.PlatformStand = true
                    end
                else
                    -- ลบตัวยึดทิ้งเมื่อปิด
                    if root:FindFirstChild("IYFlyBV") then root.IYFlyBV:Destroy() end
                    if root:FindFirstChild("IYFlyBG") then root.IYFlyBG:Destroy() end
                    if Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.PlatformStand = false
                    end
                end
            end
        end
    })

    -- ปุ่มลัดสำหรับเปิด/ปิด Fly
    Tabs.Players:AddKeybind("FlyKeybind", {
        Title = "Fly Keybind",
        Description = "ปุ่มลัดสำหรับเปิด/ปิดระบบบิน",
        Mode = "Toggle",
        Default = "G",
        Callback = function(Value)
            FlyToggle:SetValue(Value)
        end
    })

    -- ระบบควบคุมทิศทางเวลาบิน
    RunService.RenderStepped:Connect(function()
        if _G.FlyEnabled then
            local root = getRoot()
            local camera = workspace.CurrentCamera
            if root and camera and root:FindFirstChild("IYFlyBG") and root:FindFirstChild("IYFlyBV") then
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                -- ถอดปุ่ม LeftShift ออก ไม่ให้ตัวไหลลงเวลาเบิร์นความเร็ว
                
                -- ทิศทางอิงตามมุมกล้อง
                local moveVector = camera.CFrame:VectorToWorldSpace(moveDir)
                
                -- หมุนตัวละครตามกล้อง
                root.IYFlyBG.CFrame = camera.CFrame
                
                -- นำ 0.2 มาคูณ 100 เพื่อให้แปลงเป็นความเร็ว BodyVelocity ที่เหมาะสมเหมือน Infinite Yield
                root.IYFlyBV.Velocity = moveVector * (_G.FlySpeed * 100)
            end
        end
    end)

    -- ----------------------------------------------------
    -- ระบบ Noclip
    -- ----------------------------------------------------
    Tabs.Players:AddToggle("NoclipToggle", {
        Title = "Noclip (เดินทะลุกำแพง)",
        Description = "เปิด/ปิด การเดินทะลุวัตถุต่างๆ",
        Default = false,
        Callback = function(Value)
            _G.NoclipEnabled = Value
            -- คืนค่า CanCollide กลับเป็นปกติเมื่อกดปิด
            if not Value and Player.Character then
                for _, part in ipairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Head") then
                        part.CanCollide = true
                    end
                end
            end
        end
    })

    -- ระบบ Hook เพื่อแก้ไข WalkSpeed ทันทีเมื่อเกมพยายามรีเซ็ต
    local function SetupCharacterBypass(character)
        -- รอให้ Humanoid โหลดเสร็จ
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            -- เมื่อเกมพยายามเปลี่ยน WalkSpeed สคริปต์จะเปลี่ยนกลับทันทีแบบไม่มีดีเลย์
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if _G.WalkSpeedEnabled then
                    humanoid.WalkSpeed = 25
                end
            end)
            
            -- บังคับพลังกระโดดด้วยวิธีเดียวกัน
            humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if _G.JumpPowerEnabled then
                    humanoid.UseJumpPower = true
                    humanoid.JumpPower = _G.JumpPowerValue
                end
            end)
        end
    end

    -- ดึงตัวละครปัจจุบันมาทำงาน
    if Player.Character then
        SetupCharacterBypass(Player.Character)
    end

    -- ป้องกันกรณีตายแล้วเกิดใหม่ ให้สคริปต์ยังทำงานต่อ
    Player.CharacterAdded:Connect(function(char)
        SetupCharacterBypass(char)
    end)
    
    -- ลูปสำหรับช่วยเช็คความชัวร์ (เสริมทัพให้ GetPropertyChangedSignal อีกที)
    RunService.RenderStepped:Connect(function()
        local char = Player.Character 
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                if _G.WalkSpeedEnabled and hum.WalkSpeed ~= 25 then
                    hum.WalkSpeed = 25
                end
                
                if _G.JumpPowerEnabled and hum.JumpPower ~= _G.JumpPowerValue then
                    hum.UseJumpPower = true
                    hum.JumpPower = _G.JumpPowerValue
                end
            end
        end
    end)

    -------------------------------------------------------------------------
    -- หมวดหมู่: Farming (ฟาร์ม Islands)
    -------------------------------------------------------------------------
    Tabs.Farming:AddParagraph({
        Title = "Crop Farms",
        Content = "ระบบฟาร์มและปลูกพืชอัตโนมัติ"
    })

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NET
    pcall(function()
        NET = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
    end)
    
    local Remotes = {}
    if NET then
        Remotes.HarvestCrop = NET:WaitForChild("CLIENT_HARVEST_CROP_REQUEST", 2)
        Remotes.BlockPlace = NET:WaitForChild("CLIENT_BLOCK_PLACE_REQUEST", 2)
    end

    local function getblocksfolder()
        local islands = workspace:FindFirstChild("Islands")
        if not islands then return nil end
        for _, island in ipairs(islands:GetChildren()) do
            local b = island:FindFirstChild("Blocks")
            if b then return b end
        end
        return nil
    end

    -- ตรวจสอบว่าตรงจุดนั้นมีบล็อกอะไรวางอยู่แล้วหรือเปล่า (เอามาจาก Example)
    local function filledcheck(Position)
        local Parts = workspace:FindPartsInRegion3(Region3.new(Position, Position), nil, 50)
        for _, v in ipairs(Parts) do
            local Parent = v.Parent
            if Parent then
                if Parent.Name == "Blocks" then return true, v end
                Parent = Parent.Parent
                if Parent and Parent.Name == "Blocks" then return true, v end
                Parent = Parent and Parent.Parent
                if Parent and Parent.Name == "Blocks" then return true, v end
            end
        end
        return false, nil
    end

    -- รายการพืชที่ถูกจัดกลุ่มเป็นหมวดหมู่ (จะได้ไม่รก)
    local CropCategories = {"Farmland", "Pond Planter", "Trellis", "Berry", "Sand"}
    local CropItems = {
        ["Farmland"] = {"Wheat", "Tomato", "Potato", "Carrot", "Spinach", "Onion", "Starfruit", "Radish", "Pineapple", "Pumpkin", "Watermelon", "Spirit", "Chili Pepper", "Void Parasite", "Crystalline"},
        ["Pond Planter"] = {"Rice", "Seaweed"},
        ["Trellis"] = {"Grape", "Dragon Fruit", "Bean", "Candy Cane"},
        ["Berry"] = {"Red Berry", "Black Berry", "Blue Berry", "Raspberry"},
        ["Sand"] = {"Cactus"}
    }

    -- แผนที่แปลงชื่อใน UI ไปเป็นชื่อบล็อกจริงๆ ภายในเกม (ไม่ต้องมีวงเล็บแล้ว)
    local CropInternalMap = {
        ["Wheat"] = "wheat", ["Tomato"] = "tomato", ["Potato"] = "potato",
        ["Carrot"] = "carrot", ["Spinach"] = "spinach", ["Onion"] = "onion",
        ["Starfruit"] = "starfruit", ["Radish"] = "radish", ["Pineapple"] = "pineapple",
        ["Pumpkin"] = "pumpkin", ["Watermelon"] = "melon", ["Spirit"] = "spirit",
        ["Chili Pepper"] = "chiliPepper", ["Void Parasite"] = "voidParasite", ["Crystalline"] = "crystallineIvy",
        ["Rice"] = "rice", ["Seaweed"] = "seaweed",
        ["Grape"] = "grape", ["Dragon Fruit"] = "dragonfruit", ["Bean"] = "bean", ["Candy Cane"] = "candyCane",
        ["Red Berry"] = "berryBush", ["Black Berry"] = "blackberryBush", ["Blue Berry"] = "blueberryBush", ["Raspberry"] = "raspberryBush",
        ["Cactus"] = "cactus"
    }

    -- 1. เลือกหมวดหมู่หลักก่อน (เมื่อเปลี่ยนหมวดหมู่ จะไปเปลี่ยนตัวเลือกในพืช)
    local SelectCategory = Tabs.Farming:AddDropdown("SelectCategory", {
        Title = "Select Category (เลือกหมวดหมู่พืช)",
        Values = CropCategories,
        Multi = false,
        Default = 1,
    })

    -- 2. Select Crops (เลือกพืชที่จะเก็บเกี่ยว)
    local SelectCrops = Tabs.Farming:AddDropdown("SelectCrops", {
        Title = "Select Crops (เลือกพืชที่จะเก็บ)",
        Values = CropItems["Farmland"],
        Multi = false,
        Default = 1,
    })

    -- 3. Auto Crops (เปิด/ปิดเก็บเกี่ยว)
    local AutoCrops = Tabs.Farming:AddToggle("AutoCrops", {Title = "Auto Crops (Auto Harvest)", Default = false })

    -- 4. Select Planting (เลือกเมล็ดที่จะปลูก)
    local SelectPlanting = Tabs.Farming:AddDropdown("SelectPlanting", {
        Title = "Select Planting (เลือกเมล็ดพันธุ์)",
        Values = CropItems["Farmland"],
        Multi = false,
        Default = 1,
    })

    -- รัศมีการทำงานกำหนดตายตัวที่ 15
    local PlantingRadius = 15 

    -- 5. Auto Planting (เปิด/ปิดปลูกอัตโนมัติ)
    local AutoPlanting = Tabs.Farming:AddToggle("AutoPlanting", {Title = "Auto Planting", Default = false })

    -- โค้ดสำหรับอัปเดตตัวเลือกพืช เมื่อเปลี่ยนหมวดหมู่
    SelectCategory:OnChanged(function(Value)
        -- อัปเดตรายการใน Dropdown ตามหมวดหมู่ที่เลือก
        SelectCrops:SetValues(CropItems[Value])
        SelectCrops:SetValue(CropItems[Value][1])
        
        SelectPlanting:SetValues(CropItems[Value])
        SelectPlanting:SetValue(CropItems[Value][1])
    end)

    -- ลูปทำงานอัตโนมัติสำหรับ Farming (นำมาจากโค้ด Example เพื่อให้ทำงานได้จริง)
    task.spawn(function()
        while task.wait(0.2) do
            -- ระบบเก็บเกี่ยว
            if Options.AutoCrops.Value and Remotes.HarvestCrop then
                pcall(function()
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local blocks = getblocksfolder()
                    
                    if hrp and blocks then
                        local radSq = (PlantingRadius * 3)^2
                        local selectedCropName = Options.SelectCrops.Value
                        local actualCropName = CropInternalMap[selectedCropName] or "wheat"

                        for i, block in ipairs(blocks:GetChildren()) do
                            if not Options.AutoCrops.Value then break end
                            if i % 50 == 0 then task.wait() end -- กันกระตุก
                            
                            if block.Name == actualCropName then
                                local bp = block:FindFirstChildWhichIsA("BasePart")
                                if bp then
                                    local d = bp.Position - hrp.Position
                                    if d.X*d.X + d.Y*d.Y + d.Z*d.Z < radSq then
                                        Remotes.HarvestCrop:InvokeServer({
                                            dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                            player = Player, 
                                            model = block,
                                        })
                                        task.wait(0.1) -- หน่วงเวลา 0.1 วิเพื่อค่อยๆ เก็บเกี่ยว
                                    end
                                end
                            end
                        end
                    end
                end)
            end

            -- ระบบปลูกพืช
            if Options.AutoPlanting.Value and Remotes.BlockPlace then
                pcall(function()
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local selectedSeedName = Options.SelectPlanting.Value
                        local actualSeedName = CropInternalMap[selectedSeedName] or "wheat"
                        
                        -- ตรวจสอบว่าปลูกเบอร์รี่หรือไม่ เพื่อหาดิน หรือ หญ้า
                        local isBerryBush = actualSeedName:find("berryBush") ~= nil or actualSeedName:find("Bush") ~= nil
                        local targetBlock = isBerryBush and "grass" or "soil"
                        
                        local center = hrp.Position
                        local r2 = PlantingRadius * 2
                        
                        -- ค้นหาพื้นที่รอบตัวด้วย Region3 (หาดินที่อยู่ใกล้ๆ)
                        local regionParts = workspace:FindPartsInRegion3(
                            Region3.new(center - Vector3.new(r2,r2,r2)/2, center + Vector3.new(r2,r2,r2)/2), nil, math.huge
                        )
                        local placeOff = Vector3.new(0,3,0)
                        
                        for i, v2 in ipairs(regionParts) do
                            if not Options.AutoPlanting.Value then break end
                            
                            -- ถ้าเจอดิน และตรงตำแหน่งปลูกพืชยังว่างอยู่ (ไม่โดนบัง)
                            if v2.Name == targetBlock and not filledcheck(v2.Position + placeOff) then
                                task.spawn(function()
                                    Remotes.BlockPlace:InvokeServer({
                                        uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                        cframe = CFrame.new(v2.Position + placeOff),
                                        blockType = actualSeedName, 
                                        upperBlock = false,
                                    })
                                end)
                                task.wait(0.1) -- หน่วงเวลา 0.1 วิเพื่อค่อยๆ ปลูก
                            end
                            if i % 30 == 0 then task.wait() end -- กันกระตุก
                        end
                    end
                end)
            end
        end
    end)

    -------------------------------------------------------------------------
    -- หมวดหมู่: Misc (ระบบเสริมและ ESP)
    -------------------------------------------------------------------------
    Tabs.Misc:AddParagraph({
        Title = "Utilities",
        Content = "ฟีเจอร์ช่วยเหลือจิปาถะต่างๆ"
    })

    -- 1. Anti AFK
    local VirtualUser = game:GetService("VirtualUser")
    local AntiAfkConnection
    Tabs.Misc:AddToggle("AntiAfkToggle", {
        Title = "Anti AFK",
        Description = "ป้องกันการโดนเตะเมื่ออยู่นิ่งนานเกิน 20 นาที",
        Default = false,
        Callback = function(Value)
            if Value then
                AntiAfkConnection = Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            else
                if AntiAfkConnection then
                    AntiAfkConnection:Disconnect()
                    AntiAfkConnection = nil
                end
            end
        end
    })

    -- 2. Join Code Spoofer
    Tabs.Misc:AddInput("JoinCodeInput", {
        Title = "Join Code Spoofer",
        Description = "สุ่มหรือตั้งรหัสเกาะปลอม",
        Default = "",
        Placeholder = "กรอกโค้ด...",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            if Value == "" then return end
            local jc = Player:FindFirstChild("JoinCode")
            if jc then jc.Value = Value end
        end
    })

    -- 3. Invite Player
    local InviteUsernameTarget = ""
    Tabs.Misc:AddInput("InviteInput", {
        Title = "Invite Player",
        Description = "กรอกชื่อเพื่อนที่ต้องการส่งคำเชิญ",
        Default = "",
        Placeholder = "Username...",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            InviteUsernameTarget = Value
        end
    })
    
    Tabs.Misc:AddButton({
        Title = "Send Invite",
        Description = "ส่งคำเชิญให้ผู้เล่นที่ระบุ",
        Callback = function()
            if InviteUsernameTarget == "" then return end
            task.spawn(function()
                local ok, uid = pcall(function() return game:GetService("Players"):GetUserIdFromNameAsync(InviteUsernameTarget) end)
                if ok and uid then
                    local NET = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@net"):WaitForChild("out"):WaitForChild("_NetManaged")
                    local CLIENT_INVITE = NET:WaitForChild("client_request_8")
                    CLIENT_INVITE:InvokeServer({userId = uid, name = InviteUsernameTarget})
                end
            end)
        end
    })

    -- 4. View Inventory
    local ViewInvTarget = ""
    Tabs.Misc:AddInput("ViewInvInput", {
        Title = "Target Username (View Inv)",
        Description = "ระบุชื่อคนที่จะส่องกระเป๋า",
        Default = "",
        Placeholder = "Username...",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            ViewInvTarget = Value
        end
    })
    
    local MountedInventoryView = nil
    Tabs.Misc:AddButton({
        Title = "View Inventory",
        Description = "ส่องกระเป๋าของคนที่ระบุ",
        Callback = function()
            pcall(function()
                local RoactModule = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("roact"):WaitForChild("src")
                local Roact = require(RoactModule)
                local PlayerScripts = Player:WaitForChild("PlayerScripts")
                
                local function GetModule(PathTable)
                    local current = PlayerScripts
                    for _, name in ipairs(PathTable) do 
                        current = current:WaitForChild(name, 5)
                        if not current then return nil end 
                    end
                    return current
                end
                
                local PeekWrapperModule = GetModule({"TS", "flame", "controllers", "moderation", "ui", "inventory-peek-wrapper"})
                if not PeekWrapperModule then return end
                local InventoryPeekWrapper = require(PeekWrapperModule).InventoryPeekWrapper
                
                local TargetPlayer = Player
                if ViewInvTarget ~= "" then
                    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                        if string.find(string.lower(p.Name), string.lower(ViewInvTarget)) or string.find(string.lower(p.DisplayName), string.lower(ViewInvTarget)) then
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
                if #RealTools == 0 then table.insert(RealTools, {name="barrier", amount=0, displayName="No Items Found (Not Replicated)"}) end
                
                if MountedInventoryView then Roact.unmount(MountedInventoryView); MountedInventoryView = nil end
                
                local app = Roact.createElement("ScreenGui", {DisplayOrder=10000, IgnoreGuiInset=true, ResetOnSpawn=false}, {
                    Roact.createElement(InventoryPeekWrapper, {
                        headerText = TargetPlayer.Name,
                        tools = RealTools,
                        onClose = function()
                            if MountedInventoryView then Roact.unmount(MountedInventoryView); MountedInventoryView = nil end
                        end
                    })
                })
                MountedInventoryView = Roact.mount(app, Player:WaitForChild("PlayerGui"))
            end)
        end
    })

    -- 5. ESP และ Labels
    Tabs.Misc:AddParagraph({ Title = "Labels (ESP)", Content = "ระบบแสกนตู้กดน้ำและกล่อง" })
    
    local ESPConfig = {
        VendingLabels = false,
        ChestLabels = false,
        IgnoreRadius = false,
        RadiusCircle = false,
        VendingRadius = 15,
        LabelDistance = 100,
        MaxLabels = 25
    }

    Tabs.Misc:AddToggle("VendingLabelsToggle", {
        Title = "Vending Labels",
        Description = "แสดงป้ายชื่อตู้กดน้ำทั้งหมด",
        Default = false,
        Callback = function(Value) ESPConfig.VendingLabels = Value end
    })

    Tabs.Misc:AddToggle("ChestLabelsToggle", {
        Title = "Chest Labels",
        Description = "แสดงป้ายชื่อกล่องเก็บของทั้งหมด",
        Default = false,
        Callback = function(Value) ESPConfig.ChestLabels = Value end
    })

    Tabs.Misc:AddParagraph({ Title = "Radius & Selection", Content = "ปรับแต่งรัศมีวงกลม" })

    Tabs.Misc:AddToggle("IgnoreRadiusToggle", {
        Title = "Ignore Radius",
        Description = "ไม่สนใจระยะรัศมี",
        Default = false,
        Callback = function(Value) ESPConfig.IgnoreRadius = Value end
    })
    
    Tabs.Misc:AddToggle("RadiusCircleToggle", {
        Title = "Radius Circle",
        Description = "วาดเส้นวงกลมรอบตัว",
        Default = false,
        Callback = function(Value) ESPConfig.RadiusCircle = Value end
    })
    
    Tabs.Misc:AddSlider("VendingRadiusSlider", {
        Title = "Vending Radius",
        Description = "ปรับขนาดรัศมีวงกลม",
        Default = 15,
        Min = 5,
        Max = 450,
        Rounding = 1,
        Callback = function(Value) ESPConfig.VendingRadius = Value end
    })

    Tabs.Misc:AddParagraph({ Title = "Label Settings", Content = "ตั้งค่าป้าย ESP" })

    Tabs.Misc:AddSlider("LabelDistanceSlider", {
        Title = "Label Distance",
        Description = "ระยะมองเห็นป้ายสูงสุด",
        Default = 100,
        Min = 50,
        Max = 1000,
        Rounding = 0,
        Callback = function(Value) ESPConfig.LabelDistance = Value end
    })

    Tabs.Misc:AddSlider("MaxLabelsSlider", {
        Title = "Max Labels",
        Description = "จำนวนป้ายสูงสุดที่จะแสดง (กันแลค)",
        Default = 25,
        Min = 10,
        Max = 200,
        Rounding = 0,
        Callback = function(Value) ESPConfig.MaxLabels = Value end
    })

    -- ระบบการวาด ESP และ Circle แบบรวบรัด (ประหยัดสเปคกว่า Example.txt)
    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "LanternHUB_ESP"
    ESPFolder.Parent = game:GetService("CoreGui")
    
    local function CreateESP(part, text, color)
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESP"
        bg.Size = UDim2.new(0, 100, 0, 50)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        bg.MaxDistance = ESPConfig.LabelDistance
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = color
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = bg
        
        bg.Parent = ESPFolder
        bg.Adornee = part
        return bg
    end
    
    local VendingCache = {}
    local ChestCache = {}
    
    task.spawn(function()
        while true do
            task.wait(1)
            local labelCount = 0
            if ESPConfig.VendingLabels or ESPConfig.ChestLabels then
                local islands = workspace:FindFirstChild("Islands")
                if islands then
                    for _, island in ipairs(islands:GetChildren()) do
                        if island:IsA("Model") then
                            local blocks = island:FindFirstChild("Blocks")
                            if blocks then
                                for _, block in ipairs(blocks:GetChildren()) do
                                    if labelCount >= ESPConfig.MaxLabels then break end
                                    
                                    if block.Name:find("vendingMachine") and ESPConfig.VendingLabels then
                                        if not VendingCache[block] then
                                            local primary = block:FindFirstChild("Primary") or block:FindFirstChildWhichIsA("BasePart")
                                            if primary then
                                                local text = "Vending"
                                                local selling = block:FindFirstChild("SellingContents")
                                                if selling and #selling:GetChildren() > 0 then
                                                    text = "Vending [" .. selling:GetChildren()[1].Name .. "]"
                                                end
                                                VendingCache[block] = CreateESP(primary, text, Color3.fromRGB(100, 255, 100))
                                                labelCount = labelCount + 1
                                            end
                                        else
                                            labelCount = labelCount + 1
                                        end
                                    end
                                    
                                    if (block.Name:find("chest") or block.Name:find("Chest")) and ESPConfig.ChestLabels then
                                        if not ChestCache[block] then
                                            local primary = block:FindFirstChild("Primary") or block:FindFirstChildWhichIsA("BasePart")
                                            if primary then
                                                ChestCache[block] = CreateESP(primary, "Chest", Color3.fromRGB(255, 150, 50))
                                                labelCount = labelCount + 1
                                            end
                                        else
                                            labelCount = labelCount + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            for block, esp in pairs(VendingCache) do
                if not ESPConfig.VendingLabels or not block.Parent then
                    esp:Destroy()
                    VendingCache[block] = nil
                else
                    esp.MaxDistance = ESPConfig.LabelDistance
                end
            end
            for block, esp in pairs(ChestCache) do
                if not ESPConfig.ChestLabels or not block.Parent then
                    esp:Destroy()
                    ChestCache[block] = nil
                else
                    esp.MaxDistance = ESPConfig.LabelDistance
                end
            end
        end
    end)
    
    local circleLines = {}
    local numSegments = 36
    for i = 1, numSegments do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = Color3.fromRGB(255, 100, 100)
        line.Visible = false
        table.insert(circleLines, line)
    end
    
    RunService.RenderStepped:Connect(function()
        if ESPConfig.RadiusCircle and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            local radius = ESPConfig.IgnoreRadius and 10000 or ESPConfig.VendingRadius
            local pos = hrp.Position - Vector3.new(0, 3, 0)
            local camera = workspace.CurrentCamera
            
            for i = 1, numSegments do
                local angle1 = math.rad((i - 1) * (360 / numSegments))
                local angle2 = math.rad(i * (360 / numSegments))
                
                local p1 = pos + Vector3.new(math.cos(angle1) * radius, 0, math.sin(angle1) * radius)
                local p2 = pos + Vector3.new(math.cos(angle2) * radius, 0, math.sin(angle2) * radius)
                
                local s1, on1 = camera:WorldToViewportPoint(p1)
                local s2, on2 = camera:WorldToViewportPoint(p2)
                
                if on1 and on2 then
                    circleLines[i].From = Vector2.new(s1.X, s1.Y)
                    circleLines[i].To = Vector2.new(s2.X, s2.Y)
                    circleLines[i].Visible = true
                else
                    circleLines[i].Visible = false
                end
            end
        else
            for i = 1, numSegments do
                circleLines[i].Visible = false
            end
        end
    end)
end

-- ตั้งค่าระบบ Addons (SaveManager & InterfaceManager)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

-- กำหนดโฟลเดอร์สำหรับบันทึกการตั้งค่า
InterfaceManager:SetFolder("LanternHUB")
SaveManager:SetFolder("LanternHUB/configs")

-- สร้างส่วนของการตั้งค่า UI (หน้า Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- เลือกแท็บที่ 1 เป็นค่าเริ่มต้นเมื่อเปิด UI
Window:SelectTab(1)

-- โหลดคอนฟิกอัตโนมัติ (ถ้ามีตั้งไว้)
SaveManager:LoadAutoloadConfig()
