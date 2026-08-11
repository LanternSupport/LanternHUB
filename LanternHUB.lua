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
        Title = "Auto Farm",
        Content = "ระบบฟาร์มอัตโนมัติสำหรับเกม Islands"
    })

    -- ตั้งค่าตัวแปรสำหรับการเชื่อมต่อกับระบบเกม Islands
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NET
    pcall(function()
        NET = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
    end)
    
    local Remotes = {}
    if NET then
        Remotes.BlockHit = NET:WaitForChild("CLIENT_BLOCK_HIT_REQUEST", 2)
        Remotes.HarvestCrop = NET:WaitForChild("CLIENT_HARVEST_CROP_REQUEST", 2)
    end

    -- ฟังก์ชันสำหรับหาโฟลเดอร์ Blocks ของเกาะ
    local function getblocksfolder()
        local islands = workspace:FindFirstChild("Islands")
        if not islands then return nil end
        for _, island in ipairs(islands:GetChildren()) do
            local b = island:FindFirstChild("Blocks")
            if b then return b end
        end
        return nil
    end

    -- สร้าง Toggle สำหรับ Auto Mine
    Tabs.Farming:AddToggle("AutoMine", {Title = "Auto Mine (ตีแร่อัตโนมัติ)", Default = false })
    
    -- สร้าง Toggle สำหรับ Auto Harvest
    Tabs.Farming:AddToggle("AutoHarvest", {Title = "Auto Harvest (เก็บเกี่ยวอัตโนมัติ)", Default = false })

    -- ลูปทำงานอัตโนมัติสำหรับ Auto Mine และ Auto Harvest
    task.spawn(function()
        while task.wait(0.2) do -- หน่วงเวลา 0.2 วินาทีเพื่อไม่ให้แลค
            if Options.AutoMine.Value and Remotes.BlockHit then
                pcall(function()
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local blocks = getblocksfolder()
                    
                    if hrp and blocks then
                        local radSq = (30)^2 -- ระยะ 30 studs
                        for i, block in ipairs(blocks:GetChildren()) do
                            if not Options.AutoMine.Value then break end
                            local bp = block:FindFirstChildWhichIsA("BasePart")
                            if bp then
                                local d = bp.Position - hrp.Position
                                if d.X*d.X + d.Y*d.Y + d.Z*d.Z < radSq then
                                    -- รหัส Bypass เพื่อให้ส่งคำสั่งตีหินได้
                                    local args = {
                                        {
                                            Xoeoxuqilfgenamojfjmj = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nohIstskUiftvgjy",
                                            part = bp,
                                            block = block,
                                            norm = Vector3.new(0, 1, 0),
                                            pos = Vector3.new(0, 0, 0)
                                        }
                                    }
                                    Remotes.BlockHit:InvokeServer(unpack(args))
                                end
                            end
                        end
                    end
                end)
            end

            if Options.AutoHarvest.Value and Remotes.HarvestCrop then
                pcall(function()
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local blocks = getblocksfolder()
                    
                    if hrp and blocks then
                        local radSq = (30)^2
                        for i, block in ipairs(blocks:GetChildren()) do
                            if not Options.AutoHarvest.Value then break end
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
