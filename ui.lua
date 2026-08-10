local Window = Fluent:CreateWindow({
    Title = "ชื่อ Script ของผม",
    SubTitle = "เวอร์ชัน 1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" }),
    Settings = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
}

-- เพิ่มปุ่มในแท็บ Main
Tabs.Main:AddButton({
    Title = "ปุ่มทำงาน",
    Description = "คลิกเพื่อรันฟังก์ชัน",
    Callback = function()
        print("ปุ่มถูกคลิกแล้ว!")
        -- ใส่โค้ด Script ของคุณที่นี่
    end
})

-- เพิ่ม Toggle (สวิตช์เปิด-ปิด)
local Toggle = Tabs.Main:AddToggle("AutoFarm", {Title = "ออโต้ฟาร์ม", Default = false })
Toggle:OnChanged(function()
    print("สถานะออโต้ฟาร์ม:", Options.AutoFarm.Value)
    -- ใส่โค้ดเปิด/ปิดออโต้ฟาร์มของคุณที่นี่
end)
