
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jamster707/PL2/main/UiLib'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jamster707/PL2/main/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jamster707/PL2/main/SaveManager.lua'))()
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Jamster707/PL2/main/EspLib.lua'),true))()
espLib:Load()
--silent aim
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local WorldToScreen = Camera.WorldToScreenPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local GuiInset = GuiService.GetGuiInset

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getMousePosition()
    return Vector2.new(Mouse.X, Mouse.Y)
end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    
    if not (PlayerCharacter or LocalPlayerCharacter) then return end 
    
    local PlayerRoot = FindFirstChild(PlayerCharacter, Options.TargetPart.Value) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    
    if not PlayerRoot then return end 
    
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    
    return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

local function getClosestPlayer()
    if not Options.TargetPart.Value then return end
    local Closest
    local DistanceToMouse
    for _, Player in next, GetChildren(Players) do
        if Player == LocalPlayer then continue end
        if Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end

        local Character = Player.Character

        if not Character then continue end
        
        if Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")

        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)

        if not OnScreen then continue end

        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or (Toggles.fov_Enabled.Value and Options.Radius.Value) or 2000) then
            Closest = Character[Options.TargetPart.Value]
            DistanceToMouse = Distance
        end
    end
    return Closest
end

local Window = Library:CreateWindow({
    -- Set Center to true if you want the menu to appear in the center
    -- Set AutoShow to true if you want the menu to appear when it is created
    -- Position and Size are also valid options here
    -- but you do not need to define them unless you are changing them :)

    Title = 'V0.0.0.1',
    Center = true, 
    AutoShow = true,
})
-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'), 
    Aim = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

local visglobalbox = Tabs.Visuals:AddLeftGroupbox('Global')
local VisChams = Tabs.Visuals:AddLeftGroupbox('Chams')
local visespbox = Tabs.Visuals:AddRightGroupbox('ESP')
VisChams:AddToggle("ChamsEnabled", {Text = "Chams"}):AddColorPicker("ChamColorFill", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.chams = Toggles.ChamsEnabled.Value
    while Toggles.ChamsEnabled.Value do
        espLib.options.chamsFillColor = Options.ChamColorFill.Value
        espLib.options.chamsOutlineColor = Options.ChamColorFill.Value
        task.wait()
    end
end)
VisChams:AddSlider("ChamsFillTrans", {Text = "Chams Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2}):OnChanged(function()
    espLib.options.chamsFillTransparency = Options.ChamsFillTrans.Value
end)
VisChams:AddSlider("ChamsOutTrans", {Text = "Chams Outline Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2}):OnChanged(function()
    espLib.options.chamsOutlineTransparency = Options.ChamsOutTrans.Value
end)
visglobalbox:AddToggle("VisEnabled", {Text = "Enabled"}):OnChanged(function()
    espLib.options.enabled = Toggles.VisEnabled.Value
end)
visglobalbox:AddToggle("VisTeamColor", {Text = "Team Color"}):OnChanged(function()
    espLib.options.teamColor = Toggles.VisTeamColor.Value
end)
visglobalbox:AddToggle("VisTeamCheck", {Text = "Team Check"}):OnChanged(function()
    espLib.options.teamCheck = Toggles.VisTeamCheck.Value
end)
visglobalbox:AddToggle("VisVisibleCheck", {Text = "Visible Check"}):OnChanged(function()
    espLib.options.visibleOnly = Toggles.VisVisibleCheck.Value
end)
visglobalbox:AddToggle("VisLimitDisctance", {Text = "Limit Distance"}):OnChanged(function()
    espLib.options.limitDistance = Toggles.VisLimitDisctance.Value
end)

visespbox:AddToggle("Visboxes", {Text = "Boxes"}):AddColorPicker("BoxColor", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.boxes = Toggles.Visboxes.Value 
    while Toggles.Visboxes.Value do
    espLib.options.boxesColor = Options.BoxColor.Value
    task.wait()
    end
end)
visespbox:AddSlider("BoxTrans", {Text = "Boxes Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.boxesTransparency = Options.BoxTrans.Value
end)
visespbox:AddToggle("Visboxesfill", {Text = "Boxes Fill"}):AddColorPicker("BoxColorFill", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.boxFill = Toggles.Visboxesfill.Value 
    while Toggles.Visboxesfill.Value do
    espLib.options.boxFillColor = Options.BoxColorFill.Value
    task.wait()
    end
end)
visespbox:AddSlider("BoxFillTrans", {Text = "Boxes Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2}):OnChanged(function()
    espLib.options.boxFillTransparency = Options.BoxFillTrans.Value
end)
visespbox:AddToggle("VisHealthBars", {Text = "Health Bars"}):AddColorPicker("HealthBarcolor", {Default = Color3.fromRGB(0, 255, 0)}):OnChanged(function()
    espLib.options.healthBars = Toggles.VisHealthBars.Value 
    while Toggles.VisHealthBars.Value do
    espLib.options.healthBarsColor = Options.HealthBarcolor.Value
    task.wait()
    end
end)
visespbox:AddToggle("VisNames", {Text = "Names"}):AddColorPicker("NameColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
    espLib.options.names = Toggles.VisNames.Value 
    while Toggles.VisNames.Value do
    espLib.options.nameColor = Options.NameColor.Value
    task.wait()
    end
end)
visespbox:AddSlider("nameTrans", {Text = "Names Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.nameTransparency = Options.nameTrans.Value
end)
visespbox:AddToggle("VisHPTXT", {Text = "Health Text"}):AddColorPicker("HPTXTColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
    espLib.options.healthText = Toggles.VisHPTXT.Value 
    while Toggles.VisHPTXT.Value do
    espLib.options.healthTextColor = Options.HPTXTColor.Value
    task.wait()
    end
end)
visespbox:AddSlider("HPTXTTrans", {Text = "Health Text Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.healthTextTransparency = Options.HPTXTTrans.Value
end)
visespbox:AddToggle("VisDistance", {Text = "Distance Text"}):AddColorPicker("VisDistanceColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
    espLib.options.distance = Toggles.VisDistance.Value 
    while Toggles.VisDistance.Value do
    espLib.options.distanceColor = Options.VisDistanceColor.Value
    task.wait()
    end
end)
visespbox:AddSlider("DistanceTextTrans", {Text = "Distance Text Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.distanceTransparency = Options.DistanceTextTrans.Value
end)
visespbox:AddToggle("VisTracers", {Text = "Tracers"}):AddColorPicker("VisTracercolor", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.tracers = Toggles.VisTracers.Value 
    while Toggles.VisTracers.Value do
    espLib.options.tracerColor = Options.VisTracercolor.Value
    task.wait()
    end
end)
visespbox:AddDropdown("TracerOrigin", {Text = "Tracer Origin", Default = 1, Values = {
    "Bottom",
    "Mouse",
    "Top"
}}):OnChanged(function()
    espLib.options.tracerOrigin = Options.TracerOrigin.Value
end)
visespbox:AddSlider("TracerTrans", {Text = "Tracers Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.tracerTransparency = Options.TracerTrans.Value
end)
local SAbox = Tabs.Aim:AddLeftGroupbox('Sient Aim')
local SAFOVBox = Tabs.Aim:AddLeftGroupbox('FOV')
    SAbox:AddToggle("aim_Enabled", {Text = "Enabled"})
    SAbox:AddToggle("TeamCheck", {Text = "Team Check"})
    SAbox:AddToggle("VisibleCheck", {Text = "Visible Check"})
    SAbox:AddDropdown("TargetPart", {Text = "Target Part", Default = 1, Values = {
        "Head", "HumanoidRootPart"
    }})
    SAbox:AddDropdown("Method", {Text = "Silent Aim Method", Default = 1, Values = {
        "Raycast","FindPartOnRay",
        "FindPartOnRayWithWhitelist",
        "FindPartOnRayWithIgnoreList",
        "Mouse.Hit/Target"
    }})
do
    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.NumSides = 100
    fov_circle.Radius = 180
    fov_circle.Filled = false
    fov_circle.Visible = false
    fov_circle.ZIndex = 999
    fov_circle.Transparency = 1
    fov_circle.Color = Color3.fromRGB(54, 57, 241)
    
    local mouse_box = Drawing.new("Square")
    mouse_box.Visible = true 
    mouse_box.ZIndex = 999 
    mouse_box.Color = Color3.fromRGB(54, 57, 241)
    mouse_box.Thickness = 20 
    mouse_box.Size = Vector2.new(20, 20)
    mouse_box.Filled = true 
    
    --[[while task.wait() do 
        mouse_box.Position = Vector2.new(Mouse.X, Mouse.Y + GuiInset(GuiService).Y)
    end]]

    SAFOVBox:AddToggle("fov_Enabled", {Text = "Enabled"})
    SAFOVBox:AddSlider("Radius", {Text = "Radius", Min = 0, Max = 360, Default = 180, Rounding = 0}):OnChanged(function()
        fov_circle.Radius = Options.Radius.Value
    end)
    SAFOVBox:AddToggle("Visible", {Text = "Visible"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)}):OnChanged(function()
        fov_circle.Visible = Toggles.Visible.Value
        while Toggles.Visible.Value do
            fov_circle.Visible = Toggles.Visible.Value
            fov_circle.Color = Options.Color.Value
            fov_circle.Position = getMousePosition() + Vector2.new(0, 36)
            task.wait()
        end
    end)
    SAFOVBox:AddToggle("MousePosition", {Text = "Show Fake Mouse Position"}):AddColorPicker("MouseVisualizeColor", {Default = Color3.fromRGB(54, 57, 241)}):OnChanged(function()
        mouse_box.Visible = Toggles.MousePosition.Value 
        while Toggles.MousePosition.Value do 
            if Toggles.aim_Enabled.Value == true and Options.Method.Value == "Mouse.Hit/Target" then
                mouse_box.Color = Options.MouseVisualizeColor.Value 
                
                mouse_box.Visible = ((getClosestPlayer() and true) or false)
                mouse_box.Position = ((getClosestPlayer() and Vector2.new(Camera:WorldToViewportPoint(getClosestPlayer().Position).X, Camera:WorldToViewportPoint(getClosestPlayer().Position).Y)) or Vector2.new(0, 0))
            end
            
            task.wait()
        end
    end)
end
local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean", "boolean"
        }
    },
    FindPartOnRayWithWhitelist = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean"
        }
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = {
            "Instance", "Ray", "Instance", "boolean", "boolean"
        }
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
        }
    }
}


local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]

    if Toggles.aim_Enabled.Value and self == workspace then
        if Method == "FindPartOnRayWithIgnoreList" and Options.Method.Value == Method then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                local A_Ray = Arguments[2]

                local HitPart = getClosestPlayer()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)

                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif Method == "FindPartOnRayWithWhitelist" and Options.Method.Value == Method then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                local A_Ray = Arguments[2]

                local HitPart = getClosestPlayer()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)

                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and Options.Method.Value:lower() == Method:lower() then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                local A_Ray = Arguments[2]

                local HitPart = getClosestPlayer()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)

                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif Method == "Raycast" and Options.Method.Value == Method then
            if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                local A_Origin = Arguments[2]

                local HitPart = getClosestPlayer()
                if HitPart then
                    Arguments[3] = getDirection(A_Origin, HitPart.Position)

                    return oldNamecall(unpack(Arguments))
                end
            end
        end
    end
    return oldNamecall(...)
end)

local oldIndex = nil 
oldIndex = hookmetamethod(game, "__index", function(self, Index)
    if self == Mouse and (Index == "Hit" or Index == "Target") then 
        if Toggles.aim_Enabled.Value == true and Options.Method.Value == "Mouse.Hit/Target" and getClosestPlayer() then
            local HitPart = getClosestPlayer()

            return ((Index == "Hit" and HitPart.CFrame) or (Index == "Target" and HitPart))
        end
    end

    return oldIndex(self, Index)
end)

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Groupbox')

-- Tabboxes are a tiny bit different, but here's a basic example:
--[[

local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab('Tab 1')
local Tab2 = TabBox:AddTab('Tab 2')

-- You can now call AddToggle, etc on the tabs you added to the Tabbox
]]


LeftGroupBox:AddToggle('MyToggle', {
    Text = 'This is a toggle',
    Default = true, 
    Tooltip = 'This is a tooltip', 
})



Toggles.MyToggle:OnChanged(function()

    print('MyToggle changed to:', Toggles.MyToggle.Value)
end)


Toggles.MyToggle:SetValue(false)



local MyButton = LeftGroupBox:AddButton('Button', function()
    print('You clicked a button!')
end)



local MyButton2 = MyButton:AddButton('Sub button', function()
    print('You clicked a sub button!')
end)



MyButton:AddTooltip('This is a button')
MyButton2:AddTooltip('This is a sub button')

-- NOTE:button change method 
--[[
    EXAMPLE: 

    LeftGroupBox:AddButton('Kill all', Functions.KillAll):AddTooltip('This will kill everyone in the game!')
        :AddButton('Kick all', Functions.KickAll):AddTooltip('This will kick everyone in the game!')
]]


LeftGroupBox:AddLabel('This is a label')
LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)


LeftGroupBox:AddDivider()


LeftGroupBox:AddSlider('MySlider', {
    Text = 'This is my slider!',



    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,

    Compact = false, 
})



local Number = Options.MySlider.Value
Options.MySlider:OnChanged(function()
    print('MySlider was changed! New value:', Options.MySlider.Value)
end)


Options.MySlider:SetValue(3)


LeftGroupBox:AddInput('MyTextbox', {
    Default = 'My textbox!',
    Numeric = false, 
    Finished = false,

    Text = 'This is a textbox',
    Tooltip = 'This is a tooltip', 

    Placeholder = 'Placeholder text',

})

Options.MyTextbox:OnChanged(function()
    print('Text updated. New text:', Options.MyTextbox.Value)
end)



LeftGroupBox:AddDropdown('MyDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = false,

    Text = 'A dropdown',
    Tooltip = 'This is a tooltip',
})

Options.MyDropdown:OnChanged(function()
    print('Dropdown got changed. New value:', Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue('This')


LeftGroupBox:AddDropdown('MyMultiDropdown', {

    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1, 
    Multi = true,

    Text = 'A dropdown',
    Tooltip = 'This is a tooltip',
})

Options.MyMultiDropdown:OnChanged(function()
    print('Multi dropdown got changed:')
    for key, value in next, Options.MyMultiDropdown.Value do
        print(key, value) 
    end
end)

Options.MyMultiDropdown:SetValue({
    This = true,
    is = true,
})



LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = Color3.new(0, 1, 0),
    Title = 'Some color', 
})

Options.ColorPicker:OnChanged(function()
    print('Color changed!', Options.ColorPicker.Value)
end)

Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {


    Default = 'MB2', 
    SyncToggleState = false, 


   
    Mode = 'Toggle', 

    Text = 'Auto lockpick safes',
    NoUI = false,
})


Options.KeyPicker:OnClick(function()
    print('Keybind clicked!', Options.KeyPicker.Value)
end)

task.spawn(function()
    while true do
        wait(1)

        -- example for checking if a keybind is being pressed
        local state = Options.KeyPicker:GetState()
        if state then
            print('KeyPicker is being held down')
        end

        if Library.Unloaded then break end
    end
end)

Options.KeyPicker:SetValue({ 'MB2', 'Toggle' })


Library:SetWatermarkVisibility(true)

-- Sets the watermark text
Library:SetWatermark('Made By Jammsterr707')

Library.KeybindFrame.Visible = true; 

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)


local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)


SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 


ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')


SaveManager:BuildConfigSection(Tabs['UI Settings']) 


ThemeManager:ApplyToTab(Tabs['UI Settings'])

