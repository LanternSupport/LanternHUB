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

    -- ตัวแปรเก็บค่า WalkSpeed / JumpPower
    local Player = game.Players.LocalPlayer

    Tabs.Players:AddSlider("WalkSpeed", {
        Title = "WalkSpeed (ความเร็ว)",
        Description = "ปรับความเร็วในการเดิน",
        Default = 16,
        Min = 16,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.WalkSpeed = Value
            end
        end
    })

    Tabs.Players:AddSlider("JumpPower", {
        Title = "JumpPower (กระโดดสูง)",
        Description = "ปรับความสูงในการกระโดด",
        Default = 50,
        Min = 50,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.UseJumpPower = true
                Player.Character.Humanoid.JumpPower = Value
            end
        end
    })

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

    -- รายการพืชทั้งหมดที่จัดกลุ่มตามประเภท
    local CropList = {
        "[Farmland] Wheat", "[Farmland] Tomato", "[Farmland] Potato", "[Farmland] Carrot", "[Farmland] Spinach", "[Farmland] Onion", "[Farmland] Starfruit", "[Farmland] Radish", "[Farmland] Pineapple", "[Farmland] Pumpkin", "[Farmland] Watermelon", "[Farmland] Spirit", "[Farmland] Chili Pepper", "[Farmland] Void Parasite", "[Farmland] Crystalline",
        "[Pond Planter] Rice", "[Pond Planter] Seaweed",
        "[Trellis] Grape", "[Trellis] Dragon Fruit", "[Trellis] Bean", "[Trellis] Candy Cane",
        "[Berry] Red Berry", "[Berry] Black Berry", "[Berry] Blue Berry", "[Berry] Raspberry",
        "[Sand] Cactus"
    }

    -- แผนที่แปลงชื่อใน UI ไปเป็นชื่อบล็อกจริงๆ ภายในเกม
    local CropInternalMap = {
        ["[Farmland] Wheat"] = "wheat", ["[Farmland] Tomato"] = "tomato", ["[Farmland] Potato"] = "potato",
        ["[Farmland] Carrot"] = "carrot", ["[Farmland] Spinach"] = "spinach", ["[Farmland] Onion"] = "onion",
        ["[Farmland] Starfruit"] = "starfruit", ["[Farmland] Radish"] = "radish", ["[Farmland] Pineapple"] = "pineapple",
        ["[Farmland] Pumpkin"] = "pumpkin", ["[Farmland] Watermelon"] = "melon", ["[Farmland] Spirit"] = "spirit",
        ["[Farmland] Chili Pepper"] = "chiliPepper", ["[Farmland] Void Parasite"] = "voidParasite", ["[Farmland] Crystalline"] = "crystallineIvy",
        ["[Pond Planter] Rice"] = "rice", ["[Pond Planter] Seaweed"] = "seaweed",
        ["[Trellis] Grape"] = "grape", ["[Trellis] Dragon Fruit"] = "dragonfruit", ["[Trellis] Bean"] = "bean", ["[Trellis] Candy Cane"] = "candyCane",
        ["[Berry] Red Berry"] = "berryBush", ["[Berry] Black Berry"] = "blackberryBush", ["[Berry] Blue Berry"] = "blueberryBush", ["[Berry] Raspberry"] = "raspberryBush",
        ["[Sand] Cactus"] = "cactus"
    }

    -- 1. Select Crops (เลือกพืชที่จะเก็บเกี่ยว)
    local SelectCrops = Tabs.Farming:AddDropdown("SelectCrops", {
        Title = "Select Crops",
        Values = CropList,
        Multi = false,
        Default = 1,
    })

    -- 2. Auto Crops (เปิด/ปิดเก็บเกี่ยว)
    local AutoCrops = Tabs.Farming:AddToggle("AutoCrops", {Title = "Auto Crops (Auto Harvest)", Default = false })

    -- 3. Select Planting (เลือกเมล็ดที่จะปลูก)
    local SelectPlanting = Tabs.Farming:AddDropdown("SelectPlanting", {
        Title = "Select Planting (Select Seed)",
        Values = CropList,
        Multi = false,
        Default = 1,
    })

    -- รัศมีการทำงานกำหนดตายตัวที่ 15
    local PlantingRadius = 15 

    -- 4. Auto Planting (เปิด/ปิดปลูกอัตโนมัติ)
    local AutoPlanting = Tabs.Farming:AddToggle("AutoPlanting", {Title = "Auto Planting", Default = false })

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
                            end
                            if i % 30 == 0 then task.wait() end -- กันกระตุก
                        end
                    end
                end)
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
