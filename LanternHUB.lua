local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Lantern HUB",
    SubTitle = "v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftShift
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
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
            -- if game.Players.LocalPlayer.Character then
            --     game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
            -- end
        end
    })

    Slider:OnChanged(function(Value)
        print("Slider เปลี่ยนแปลงเป็น:", Value)
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
