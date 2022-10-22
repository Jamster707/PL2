local walkspeedplayer = game:GetService("Players").LocalPlayer
local walkspeedmouse = walkspeedplayer:GetMouse()

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Jamster707/PL2/main/EspLib.lua'),true))()
espLib:Load()
--silent aim

-- You can suggest changes with a pull request or something
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
    MiscTab = Window:AddTab("Misc"),
    ['UI Settings'] = Window:AddTab('UI Settings')
}
local miscbox = Tabs.MiscTab:AddRightGroupbox("Misc")
local miscbox2 = Tabs.MiscTab:AddLeftGroupbox("Movement")






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
-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Groupbox')

-- Tabboxes are a tiny bit different, but here's a basic example:
--[[

local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab('Tab 1')
local Tab2 = TabBox:AddTab('Tab 2')

-- You can now call AddToggle, etc on the tabs you added to the Tabbox
]]

-- Groupbox:AddToggle
-- Arguments: Index, Options
LeftGroupBox:AddToggle('MyToggle', {
    Text = 'This is a toggle',
    Default = true, -- Default value (true / false)
    Tooltip = 'This is a tooltip', -- Information shown when you hover over the toggle
})


-- Fetching a toggle object for later use:
-- Toggles.MyToggle.Value

-- Toggles is a table added to getgenv() by the library
-- You index Toggles with the specified index, in this case it is 'MyToggle'
-- To get the state of the toggle you do toggle.Value

-- Calls the passed function when the toggle is updated
Toggles.MyToggle:OnChanged(function()
    -- here we get our toggle object & then get its value
    print('MyToggle changed to:', Toggles.MyToggle.Value)
end)

-- This should print to the console: "My toggle state changed! New value: false"
Toggles.MyToggle:SetValue(false)

-- Groupbox:AddButton
-- Arguments: Text, Callback

local MyButton = LeftGroupBox:AddButton('Button', function()
    print('You clicked a button!')
end)

-- Button:AddButton
-- Arguments: Text, Callback
-- Adds a sub button to the side of the main button

local MyButton2 = MyButton:AddButton('Sub button', function()
    print('You clicked a sub button!')
end)

-- Button:AddTooltip
-- Arguments: ToolTip

MyButton:AddTooltip('This is a button')
MyButton2:AddTooltip('This is a sub button')

-- NOTE: You can chain the button methods!
--[[
    EXAMPLE: 

    LeftGroupBox:AddButton('Kill all', Functions.KillAll):AddTooltip('This will kill everyone in the game!')
        :AddButton('Kick all', Functions.KickAll):AddTooltip('This will kick everyone in the game!')
]]

-- Groupbox:AddLabel
-- Arguments: Text, DoesWrap
LeftGroupBox:AddLabel('This is a label')
LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)

-- Groupbox:AddDivider
-- Arguments: None
LeftGroupBox:AddDivider()

-- Groupbox:AddSlider
-- Arguments: Idx, Options
LeftGroupBox:AddSlider('MySlider', {
    Text = 'This is my slider!',

    -- Text, Default, Min, Max, Rounding must be specified.
    -- Rounding is the number of decimal places for precision.

    -- Example:
    -- Rounding 0 - 5
    -- Rounding 1 - 5.1
    -- Rounding 2 - 5.15
    -- Rounding 3 - 5.155

    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,

    Compact = false, -- If set to true, then it will hide the label
})

-- Options is a table added to getgenv() by the library
-- You index Options with the specified index, in this case it is 'MySlider'
-- To get the value of the slider you do slider.Value

local Number = Options.MySlider.Value
Options.MySlider:OnChanged(function()
    print('MySlider was changed! New value:', Options.MySlider.Value)
end)

-- This should print to the console: "MySlider was changed! New value: 3"
Options.MySlider:SetValue(3)

-- Groupbox:AddInput
-- Arguments: Idx, Info
LeftGroupBox:AddInput('MyTextbox', {
    Default = 'My textbox!',
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only calls callback when you press enter

    Text = 'This is a textbox',
    Tooltip = 'This is a tooltip', -- Information shown when you hover over the textbox

    Placeholder = 'Placeholder text', -- placeholder text when the box is empty
    -- MaxLength is also an option which is the max length of the text
})

Options.MyTextbox:OnChanged(function()
    print('Text updated. New text:', Options.MyTextbox.Value)
end)

-- Groupbox:AddDropdown
-- Arguments: Idx, Info

LeftGroupBox:AddDropdown('MyDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'A dropdown',
    Tooltip = 'This is a tooltip', -- Information shown when you hover over the textbox
})

Options.MyDropdown:OnChanged(function()
    print('Dropdown got changed. New value:', Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue('This')

-- Multi dropdowns
LeftGroupBox:AddDropdown('MyMultiDropdown', {
    -- Default is the numeric index (e.g. "This" would be 1 since it if first in the values list)
    -- Default also accepts a string as well

    -- Currently you can not set multiple values with a dropdown

    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1, 
    Multi = true, -- true / false, allows multiple choices to be selected

    Text = 'A dropdown',
    Tooltip = 'This is a tooltip', -- Information shown when you hover over the textbox
})

Options.MyMultiDropdown:OnChanged(function()
    -- print('Dropdown got changed. New value:', )
    print('Multi dropdown got changed:')
    for key, value in next, Options.MyMultiDropdown.Value do
        print(key, value) -- should print something like This, true
    end
end)

Options.MyMultiDropdown:SetValue({
    This = true,
    is = true,
})

-- Label:AddColorPicker
-- Arguments: Idx, Info

-- You can also ColorPicker & KeyPicker to a Toggle as well

LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = Color3.new(0, 1, 0), -- Bright green
    Title = 'Some color', -- Optional. Allows you to have a custom color picker title (when you open it)
})

Options.ColorPicker:OnChanged(function()
    print('Color changed!', Options.ColorPicker.Value)
end)

Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))


--LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
--    -- SyncToggleState only works with toggles. 
--    -- It allows you to make a keybind which has its state synced with its parent toggle
--
--    -- Example: Keybind which you use to toggle flyhack, etc.
--    -- Changing the toggle disables the keybind state and toggling the keybind switches the toggle state
--
--    Default = 'MB2', -- String as the name of the keybind (MB1, MB2 for mouse buttons)  
--    SyncToggleState = false, 
--
--
--    -- You can define custom Modes but I have never had a use for it.
--    Mode = 'Toggle', -- Modes: Always, Toggle, Hold
--
 --   Text = 'Auto lockpick safes', -- Text to display in the keybind menu
   -- NoUI = true, -- Set to true if you want to hide from the Keybind menu,
--})

-- OnClick is only fired when you press the keybind and the mode is Toggle
-- Otherwise, you will have to use Keybind:GetState()
--Options.KeyPicker:OnClick(function()
  --  print('Keybind clicked!', Options.KeyPicker.Value)
--end)

--task.spawn(function()
  --  while true do
    --    wait(1)
--
  --      -- example for checking if a keybind is being pressed
    --    local state = Options.KeyPicker:GetState()
      --  if state then
        --    print('KeyPicker is being held down')
    --    end

      --  if Library.Unloaded then break end
--    end
--end)

--Options.KeyPicker:SetValue({ 'MB2', 'Toggle' }) -- Sets keybind to MB2, mode to Hold

-- Library functions
-- Sets the watermark visibility
Library:SetWatermarkVisibility(true)

-- Sets the watermark text
Library:SetWatermark('Made By Jammsterr707')

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager. 
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings() 

-- Adds our MenuKeybind to the ignore list 
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

-- use case for doing it this way: 
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings']) 

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config 
-- which has been marked to be one that auto loads!

local drawing_new = Drawing.new
local vector2_new = Vector2.new
local vector3_new = Vector3.new
local cframe_new = CFrame.new
local cframe_angles = CFrame.Angles
local color3_new = Color3.new
local color3_hsv = Color3.fromHSV
local math_floor = math.floor
local raycast_params_new = RaycastParams.new
local enum_rft_blk = Enum.RaycastFilterType.Blacklist

local white = color3_new(255, 255, 255)
local green = color3_new(0, 255, 0)

local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local rep_storage = game:GetService("ReplicatedStorage")

local frame_wait = run_service.RenderStepped

local local_player = players.LocalPlayer
local mouse = local_player:GetMouse()
local dummy_part = Instance.new("Part", nil)

local camera = workspace:FindFirstChildOfClass("Camera")
local screen_size = camera.ViewportSize
local center_screen = vector2_new((screen_size.X / 2), (screen_size.Y / 2))

--<- allowed modify ->--

local _aimsp_settings; _aimsp_settings = {

    -- aimbot settings
    use_aimbot = false,
    use_wallcheck = false,
    team_check = false,
    loop_all_humanoids = false, -- will allow aimbot to everything that has a humanoid, likely *VERY* laggy
    max_dist = 9e9, -- 9e9 = very big
    allow_toggle = {
        allow = false, -- turning this to false will make the aimbot toggle on right mouse button
        key = Enum.KeyCode.E;
    },
    prefer = {
        looking_at_you = false, -- buggy
        closest_to_center_screen = false, -- stable
        closest_to_you = true, -- stable
    },
    smoothness = 3, -- anything over 5 = aim assist,  1 = lock on (using 1 might get u banned)
    fov_size = 150; -- 150-450 = preferred

    -- esp settings
    use_esp = false,
    rainbow_speed = 5,
    use_rainbow = false,
    tracers = false,
    box = false,
    name = false,
    dist = false,
    health = false; -- might not work on some games
}
print("sada 2")
--<- allowed modify ->--

if getgenv().aimsp_settings then 
    getgenv().aimsp_settings = _aimsp_settings; 
    return 
end
getgenv().aimsp_settings = _aimsp_settings

local objects; objects = {
    fov = nil,
    text = nil,
    chams = {},
    tracers = {},
    quads = {},
    labels = {},
    look_at = {
        tracer = nil,
        point = nil;
    };
}

local debounces; debounces = {
    start_aim = false,
    custom_players = false,
    spoofs_hum_health = false;
}

local utility; utility = {
    get_rainbow = function()
        return color3_hsv((tick() % aimsp_settings.rainbow_speed / aimsp_settings.rainbow_speed), 1, 1)
    end,

    get_part_corners = function(part)
        local size = part.Size * vector3_new(1, 1.5, 0)

        return {
            top_right = (part.CFrame * cframe_new(-size.X, -size.Y, 0)).Position,
            bottom_right = (part.CFrame * cframe_new(-size.X, size.Y, 0)).Position,
            top_left = (part.CFrame * cframe_new(size.X, -size.Y, 0)).Position,
            bottom_left = (part.CFrame * cframe_new(size.X, size.Y, 0)).Position,
        }
    end,

    run_player_check = function()
        local plrs = players:GetChildren()

        for idx, val in pairs(objects.tracers) do
            if not plrs[idx] then
                utility.remove_esp(idx)
            end
        end
    end,

    remove_esp = function(name)
        utility.update_drawing(objects.tracers, name, {
            Visible = false,
            instance = "Line";
        })

        utility.update_drawing(objects.quads, name, {
            Visible = false,
            instance = "Quad";
        })

        utility.update_drawing(objects.labels, name, {
            Visible = false,
            instance = "Text";
        })
    end,

    update = function(str)
        if objects.fov.Visible then
            objects.text.Text = str
            objects.text.Visible = true

            wait(1)

            objects.text.Visible = false
        end
    end,

    is_inside_fov = function(point)
        return (point.x - objects.fov.Position.X) ^ 2 + (point.y - objects.fov.Position.Y) ^ 2 <= objects.fov.Radius ^ 2
    end,
    
    to_screen = function(point)
        local screen_pos, in_screen = camera:WorldToViewportPoint(point)
        
        return (in_screen and vector2_new(screen_pos.X, screen_pos.Y)) or -1
    end,

    is_part_visible = function(origin_part, part)
        if not aimsp_settings.use_wallcheck then
            return true
        end

        local function run_cast(origin_pos)
            local raycast_params = raycast_params_new()
            raycast_params.FilterType = enum_rft_blk
            raycast_params.FilterDescendantsInstances = {origin_part.Parent}
            raycast_params.IgnoreWater = true
            
            local raycast_result = workspace:Raycast(origin_pos, (part.Position - origin_pos).Unit * aimsp_settings.max_dist, raycast_params)

            return ((raycast_result and raycast_result.Instance) or dummy_part):IsDescendantOf(part.Parent) 
        end

        local head_pos = (origin_part.Position + (origin_part.CFrame.UpVector * 2) + (origin_part.CFrame.LookVector))

        local cast_table = {
            origin_part.CFrame.UpVector * 2,
            -origin_part.CFrame.UpVector * 2,
            origin_part.CFrame.RightVector * 2,
            -origin_part.CFrame.RightVector * 2,
            vector3_new(0, 0, 0);
        }

        for idx, val in pairs(cast_table) do
            if run_cast(head_pos + val) == true then
                return true
            end
        end

        return false
    end,
    
    is_dead = function(char)
        if debounces.spoofs_hum_health then
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if torso and #(torso:GetChildren()) < 10 then
                return true
            end
        else
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health == 0 then
                return true
            end
        end

        return false
    end,

    update_drawing = function(tbl, child, val)
        if not tbl[child] then
            tbl[child] = utility.new_drawing(val.instance)(val)
        end
        
        for idx, val in pairs(val) do
            if idx ~= "instance" then
                tbl[child][idx] = val
            end
        end
        
        return tbl[child]
    end,
    
    new_drawing = function(classname)
        return function(tbl)
            local draw = drawing_new(classname)
            
            for idx, val in pairs(tbl) do
                if idx ~= "instance" then
                    draw[idx] = val
                end
            end
            
            return draw
        end
    end
}

objects.text = utility.new_drawing("Text"){
    Transparency = 1,
    Visible = false,
    Center = true,
    Size = 24,
    Color = white,
    Position = vector2_new(screen_size.X - 100, 36);
}

objects.fov = utility.new_drawing("Circle"){
    Thickness = 1,
    Transparency = 1,
    Visible = true,
    Color = white,
    Position = center_screen,
    Radius = aimsp_settings.fov_size;
}

players.PlayerRemoving:Connect(function(plr)
    utility.remove_esp(plr.Name)
end)

uis.InputBegan:Connect(function(key, gmp)
    if gmp then return end

    if key.KeyCode == aimsp_settings.allow_toggle.key then
        debounces.start_aim = not debounces.start_aim
        
        utility.update("toggled aimbot: " .. tostring(debounces.start_aim))
    elseif key.KeyCode == aimsp_settings.toggle_hud_key then
        objects.fov.Visible = not objects.fov.Visible
    elseif key.KeyCode == aimsp_settings.esp_toggle_key then
        aimsp_settings.use_esp = not aimsp_settings.use_esp

        utility.update("toggled esp: " .. tostring(aimsp_settings.use_esp))
    end
end)

if not aimsp_settings.allow_toggle.allow then
    mouse.Button2Down:Connect(function()
        debounces.start_aim = true
    end)
    
    mouse.Button2Up:Connect(function()
        debounces.start_aim = false
    end)
end

function delay()
    frame_wait:Wait()
    --[[
        if you are lagging, replace this comment with the line below
        frame_wait:Wait()
    ]]
    return true
end

local get_players; -- create custom function for every game so that it doesnt check placeid every frame

if aimsp_settings.loop_all_humanoids then -- self explanitory
    get_players = function()
        local instance_table = {}

        for idx, val in pairs(workspace:GetDescendants()) do
            if val:IsA("Model") and val:FindFirstChildOfClass("Humanoid") then
                instance_table[#instance_table + 1] = val
            end
        end

        return instance_table
    end
elseif game.PlaceId == 18164449 then -- base wars
    debounces.spoofs_hum_health = true
elseif game.PlaceId == 292439477 then -- phantom forces
    debounces.custom_players = true

    get_players = function()
        local local_team = local_player.Character.Parent -- your character is not nil

        local get_team;

        if local_team then
            if aimsp_settings.team_check then
                if local_team.Name == "Phantoms" then
                    get_team = "Ghosts"
                else
                    get_team = "Phantoms"
                end
    
                return local_team.Parent[get_team]:GetChildren()
            else
                local instance_table = {}

                for idx, val in pairs(local_team.Parent.Phantoms:GetChildren()) do
                    if val:IsA("Model") then
                        instance_table[#instance_table + 1] = val
                    end
                end

                for idx, val in pairs(local_team.Parent.Ghosts:GetChildren()) do
                    if val:IsA("Model") then
                        instance_table[#instance_table + 1] = val
                    end
                end

                return instance_table -- return both teams
            end
        end

        return {} -- player is likely dead, return empty table so the mouse doesnt go apeshit
    end
--[[
    elseif game.PlaceId == 3233893879 then -- bad business

    local TS = require(rep_storage:WaitForChild("TS"))
    local net_module

    for idx, val in pairs(rep_storage:GetChildren()) do
        local children = val:GetChildren()
        if val.Name == " " and #children ~= 1 then
            for _idx, _val in pairs(children) do
                local module = require(_val)
                if module.Fire then
                    net_module = module -- found it
                end
            end
        end
    end

    get_players = function()
        
    end

    return {}
]]
else -- normal players
    get_players = function()
        return players:GetChildren()
    end
end

coroutine.wrap(function()
    while delay() do
        local func, result = pcall(function()
            utility.update_drawing(objects, "fov", {
                Radius = aimsp_settings.fov_size,
                Color = (aimsp_settings.use_rainbow and utility.get_rainbow()) or white,
                instance = "Circle";
            })

            utility.run_player_check()

            local closest_player = nil
            local dist = aimsp_settings.max_dist
            
            for idx, plr in pairs(get_players()) do -- continue skips current index
                local plr_char = ((aimsp_settings.loop_all_humanoids or debounces.custom_players) and plr) or plr.Character
                if plr == local_player then continue; end
                if plr_char == nil then continue; end

                if debounces.custom_players then -- teamcheck for games with custom chars
                    if plr_char.Parent == local_player.Character.Parent then continue; end
                end
                
                if aimsp_settings.team_check and not aimsp_settings.loop_all_humanoids and not debounces.custom_players then
                    if plr.Team then
                        if plr.TeamColor == local_player.TeamColor then continue; end
                        if plr.Team == local_player.Team then continue; end
                    end
                end
                
                if not utility.is_dead(plr_char) then
                    local plr_screen = utility.to_screen(plr_char.HumanoidRootPart.Position + (plr_char.HumanoidRootPart.CFrame.UpVector * 2)) -- emulate head pos
                    
                    if plr_screen ~= -1 then
                        local mag = (plr_char.HumanoidRootPart.Position - local_player.Character.HumanoidRootPart.Position).Magnitude
                        
                        if aimsp_settings.use_esp then
                            local col = (aimsp_settings.use_rainbow and utility.get_rainbow()) or white
                            
                            if aimsp_settings.tracers then
                                utility.update_drawing(objects.tracers, plr_char:GetDebugId(), {
                                    Visible = objects.fov.Visible,
                                    Thickness = 1,
                                    Color = (aimsp_settings.use_rainbow and utility.get_rainbow()) or color3_new(255 / mag, mag / 255, 0),
                                    To = plr_screen,
                                    From = vector2_new(screen_size.X / 2, screen_size.Y - 36),
                                    instance = "Line";
                                })
                            end
                            
                            if aimsp_settings.box then
                                local corners = utility.get_part_corners(plr_char.HumanoidRootPart)

                                local point_a_scr = utility.to_screen(corners.top_left)
                                local point_b_scr = utility.to_screen(corners.top_right)
                                local point_c_scr = utility.to_screen(corners.bottom_right)
                                local point_d_scr = utility.to_screen(corners.bottom_left)

                                if (point_a_scr ~= -1) and (point_b_scr ~= -1) and (point_c_scr ~= -1) and (point_d_scr ~= -1) then
                                    utility.update_drawing(objects.quads, plr_char:GetDebugId(), {
                                        Visible = objects.fov.Visible,
                                        Thickness = 1,
                                        Color = col,
                                        PointA = point_a_scr,
                                        PointB = point_b_scr,
                                        PointC = point_c_scr,
                                        PointD = point_d_scr,
                                        instance = "Quad";
                                    })
                                end
                            end

                            local plr_info = ""

                            if aimsp_settings.name then
                                plr_info = plr_info .. (plr.Name .. "\n")
                            end
                            if aimsp_settings.dist then
                                plr_info = plr_info .. (tostring(math_floor(mag)) .. " Studs Away\n")
                            end
                            if aimsp_settings.health then
                                local hum = plr_char:FindFirstChildOfClass("Humanoid")

                                plr_info = (hum and plr_info .. ("[" .. tostring(hum.Health) .. "/" .. tostring(hum.MaxHealth) .. "]" )) or plr_info
                            end

                            if plr_info ~= "" then
                                local cam_mag = (camera.CFrame.Position - plr_char.HumanoidRootPart.CFrame.Position).Magnitude / 20

                                local scr_pos = utility.to_screen(
                                    plr_char.HumanoidRootPart.Position +
                                    vector3_new(0, 4, 0) +
                                    (plr_char.HumanoidRootPart.CFrame.UpVector * cam_mag)
                                )

                                if scr_pos ~= -1 then
                                    utility.update_drawing(objects.labels, plr_char:GetDebugId(), {
                                        Visible = objects.fov.Visible,
                                        Color = col,
                                        Position = scr_pos,
                                        Text = plr_info,
                                        Center = true,
                                        instance = "Text";
                                    })
                                else
                                    utility.update_drawing(objects.labels, plr_char:GetDebugId(), {
                                        Visible = false,
                                        instance = "Text";
                                    })
                                end
                            end
                        else
                            utility.remove_esp(plr_char:GetDebugId())
                        end

                        if aimsp_settings.prefer.looking_at_you then
                            local look_vector = plr_char.HumanoidRootPart.Position + (plr_char.HumanoidRootPart.CFrame.LookVector * mag)

                            local look_vector_lp_head_dist = (look_vector - local_player.Character.HumanoidRootPart.Position).Magnitude
                            if look_vector_lp_head_dist < dist and utility.is_inside_fov(plr_screen) then
                                dist = look_vector_lp_head_dist
                                closest_player = plr_char
                            end
                        elseif aimsp_settings.prefer.closest_to_center_screen then
                            local plr_scr_dist = (center_screen - plr_screen).Magnitude
                            if plr_scr_dist < dist then
                                dist = plr_scr_dist
                                closest_player = plr_char
                            end
                        elseif aimsp_settings.prefer.closest_to_you then
                            local plr_dist = (plr_char.HumanoidRootPart.Position - local_player.Character.HumanoidRootPart.Position).Magnitude
                            if plr_dist < dist then
                                dist = plr_dist
                                closest_player = plr_char
                            end
                        end
                    else
                        utility.remove_esp(plr_char:GetDebugId())
                    end
                else
                    utility.remove_esp(plr_char:GetDebugId())
                end
            end

            local visible_parts = {}
            local last
            
            if closest_player and aimsp_settings.use_aimbot then
                for idx, part in pairs(closest_player:GetChildren()) do
                    if part:IsA("BasePart") then
                        local screen_pos = utility.to_screen(part.Position)
    
                        if screen_pos ~= -1 then
                            if utility.is_inside_fov(screen_pos) and utility.is_part_visible(local_player.Character.HumanoidRootPart, part) then
                                last = {
                                    scr_pos = screen_pos,
                                    obj = part;
                                };
                                visible_parts[part.Name] = last
                            end
                        end
                    end
                end
                
                if visible_parts["Head"] then
                    visible_parts[0] = visible_parts["Head"]
                elseif visible_parts["UpperTorso"] or visible_parts["Torso"] then
                    visible_parts[0] = visible_parts["UpperTorso"] or visible_parts["Torso"]
                end

                local lock_part = visible_parts[0] or last

                if lock_part then
                    local scale = (lock_part.obj.Size.Y / 2)

                    local top = utility.to_screen((lock_part.obj.CFrame * cframe_new(0, scale, 0)).Position);
                    local bottom = utility.to_screen((lock_part.obj.CFrame * cframe_new(0, -scale, 0)).Position);
                    local radius = -(top - bottom).y;

                    utility.update_drawing(objects.look_at, "point", {
                        Transparency = 1,
                        Thickness = 1,
                        Radius = radius / 2,
                        Visible = objects.fov.Visible,
                        Color = (debounces.start_aim and green) or white,
                        Position = lock_part.scr_pos,
                        instance = "Circle";
                    })

                    if debounces.start_aim then
                        utility.update_drawing(objects.look_at, "tracer", {
                            Transparency = 1,
                            Thickness = 1,
                            Visible = objects.fov.Visible,
                            Color = green,
                            From = center_screen,
                            To = lock_part.scr_pos,
                            instance = "Line";
                        })

                        mousemoverel((lock_part.scr_pos.X - mouse.X) / aimsp_settings.smoothness, (lock_part.scr_pos.Y - (mouse.Y + 36)) / aimsp_settings.smoothness)
                    else
                        utility.update_drawing(objects.look_at, "tracer", {
                            Visible = false,
                            instance = "Line";
                        })
                    end
                else
                    utility.update_drawing(objects.look_at, "point", {
                        Visible = false,
                        instance = "Circle";
                    })
    
                    utility.update_drawing(objects.look_at, "tracer", {
                        Visible = false,
                        instance = "Line";
                    })
                end
            end
        end)
        if not func then --[[warn(result)]] end
    end
end)()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
RunService.RenderStepped:Connect(function()
    objects.fov.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)

end)


objects.fov.Visible = false

local aimbox = Tabs.Aim:AddRightGroupbox('Aimbot')

aimbox:AddToggle("enabledaim", {Text = "Enable"}):OnChanged(function()
    aimsp_settings.use_aimbot = Toggles.enabledaim.Value
end)

aimbox:AddLabel('Aimbot Key'):AddKeyPicker('AimyKey', {
Default = 'E', -- String as the name of the keybind (MB1, MB2 for mouse buttons)  
SyncToggleState = false, 
Mode = 'Toggle', -- Modes: Always, Toggle, Hold
Text = 'BINDS', -- Text to display in the keybind menu
NoUI = true, -- Set to true if you want to hide from the Keybind menu,
})

aimbox:AddToggle("enabledaimfov", {Text = "Show fov"}):OnChanged(function()
    objects.fov.Visible = Toggles.enabledaimfov.Value
end)

aimbox:AddToggle("enabledaimTC", {Text = "Team Check"}):OnChanged(function()
    aimsp_settings.team_check = Toggles.enabledaimTC.Value
end)

aimbox:AddToggle("enabledaimWC", {Text = "Visible Check"}):OnChanged(function()
    aimsp_settings.use_wallcheck = Toggles.enabledaimWC.Value
end)

aimbox:AddToggle("enabledaimLAH", {Text = "Loop All Humanoids"}):OnChanged(function()
    aimsp_settings.loop_all_humanoids = Toggles.enabledaimLAH.Value
end)

aimbox:AddSlider("aimsmootham", {Text = "Aimbot Smoothing", Min = 0, Max = 25, Default = 3, Rounding = 1}):OnChanged(function()
    aimsp_settings.smoothness = Options.aimsmootham.Value
end)

aimbox:AddSlider("aimsmoothamfov", {Text = "Aimbot FOV", Min = 0, Max = 500, Default = 30, Rounding = 0}):OnChanged(function()
    aimsp_settings.fov_size = Options.aimsmoothamfov.Value
end)

while true do
    task.wait(1)
    aimsp_settings.allow_toggle.key = Options.AimyKey.Value
    print(aimsp_settings.allow_toggle.key)
end
