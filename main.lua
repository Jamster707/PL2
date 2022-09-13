if not syn or not protectgui then
    getgenv().protectgui = function()end
end
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Jamster707/PL2/main/EspLib.lua'),true))()
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jamster707/PL2/main/UiLib'))()
Library:SetWatermark("By Jammsterr707")
Library:Notify('Press Right-CTRL To Toggle The UI')
Library:Notify('')
espLib:Load()

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

local Window = Library:CreateWindow("V0.0.1")

local GeneralTab = Window:AddTab("Aim")
local VisTab = Window:AddTab("Visuals")
local VisBOX = VisTab:AddLeftTabbox("General")
local Vismain =VisBOX:AddTab("Global")
Vismain:AddToggle("VisEnabled", {Text = "Enabled"}):OnChanged(function()
    espLib.options.enabled = Toggles.VisEnabled.Value
end)
Vismain:AddToggle("VisTeamColor", {Text = "Team Color"}):OnChanged(function()
    espLib.options.teamColor = Toggles.VisTeamColor.Value
end)
Vismain:AddToggle("VisTeamCheck", {Text = "Team Check"}):OnChanged(function()
    espLib.options.teamCheck = Toggles.VisTeamCheck.Value
end)
Vismain:AddToggle("VisVisibleCheck", {Text = "Visible Check"}):OnChanged(function()
    espLib.options.visibleOnly = Toggles.VisVisibleCheck.Value
end)
Vismain:AddToggle("VisLimitDisctance", {Text = "Limit Distance"}):OnChanged(function()
    espLib.options.limitDistance = Toggles.VisLimitDisctance.Value
end)
local VisBOX3 = VisTab:AddLeftTabbox("VISBOX3")
local VisChams =VisBOX3:AddTab("Chams")
VisChams:AddToggle("ChamsEnabled", {Text = "Chams"}):AddColorPicker("ChamColorFill", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.chams = Toggles.ChamsEnabled.Value
    while Toggles.ChamsEnabled.Value do
        espLib.options.chamsFillColor = Options.ChamColorFill.Value
        task.wait()
    end
end)
VisChams:AddSlider("ChamsFillTrans", {Text = "Chams Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2}):OnChanged(function()
    espLib.options.chamsFillTransparency = Options.ChamsFillTrans.Value
end)
VisChams:AddSlider("ChamsOutTrans", {Text = "Chams Outline Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2}):OnChanged(function()
    espLib.options.chamsOutlineTransparency = Options.ChamsOutTrans.Value
end)

local VisBOX2 = VisTab:AddRightTabbox("ESP")
local VisESP =VisBOX2:AddTab("ESP")
VisESP:AddToggle("Visboxes", {Text = "Boxes"}):AddColorPicker("BoxColor", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.boxes = Toggles.Visboxes.Value 
    while Toggles.Visboxes.Value do
    espLib.options.boxesColor = Options.BoxColor.Value
    task.wait()
    end
end)
VisESP:AddSlider("BoxTrans", {Text = "Boxes Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.boxesTransparency = Options.BoxTrans.Value
end)
VisESP:AddToggle("Visboxesfill", {Text = "Boxes Fill"}):AddColorPicker("BoxColorFill", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.boxFill = Toggles.Visboxesfill.Value 
    while Toggles.Visboxesfill.Value do
    espLib.options.boxFillColor = Options.BoxColorFill.Value
    task.wait()
    end
end)
VisESP:AddSlider("BoxFillTrans", {Text = "Boxes Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2}):OnChanged(function()
    espLib.options.boxFillTransparency = Options.BoxFillTrans.Value
end)
VisESP:AddToggle("VisHealthBars", {Text = "Health Bars"}):AddColorPicker("HealthBarcolor", {Default = Color3.fromRGB(0, 255, 0)}):OnChanged(function()
    espLib.options.healthBars = Toggles.VisHealthBars.Value 
    while Toggles.VisHealthBars.Value do
    espLib.options.healthBarsColor = Options.HealthBarcolor.Value
    task.wait()
    end
end)
VisESP:AddToggle("VisNames", {Text = "Names"}):AddColorPicker("NameColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
    espLib.options.names = Toggles.VisNames.Value 
    while Toggles.VisNames.Value do
    espLib.options.nameColor = Options.NameColor.Value
    task.wait()
    end
end)
VisESP:AddSlider("nameTrans", {Text = "Names Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.nameTransparency = Options.nameTrans.Value
end)
VisESP:AddToggle("VisHPTXT", {Text = "Health Text"}):AddColorPicker("HPTXTColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
    espLib.options.healthText = Toggles.VisHPTXT.Value 
    while Toggles.VisHPTXT.Value do
    espLib.options.healthTextColor = Options.HPTXTColor.Value
    task.wait()
    end
end)
VisESP:AddSlider("HPTXTTrans", {Text = "Health Text Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.healthTextTransparency = Options.HPTXTTrans.Value
end)
VisESP:AddToggle("VisDistance", {Text = "Distance Text"}):AddColorPicker("VisDistanceColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
    espLib.options.distance = Toggles.VisDistance.Value 
    while Toggles.VisDistance.Value do
    espLib.options.distanceColor = Options.VisDistanceColor.Value
    task.wait()
    end
end)
VisESP:AddSlider("DistanceTextTrans", {Text = "Distance Text Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.distanceTransparency = Options.DistanceTextTrans.Value
end)
VisESP:AddToggle("VisTracers", {Text = "Tracers"}):AddColorPicker("VisTracercolor", {Default = Color3.fromRGB(1, 0, 0)}):OnChanged(function()
    espLib.options.tracers = Toggles.VisTracers.Value 
    while Toggles.VisTracers.Value do
    espLib.options.tracerColor = Options.VisTracercolor.Value
    task.wait()
    end
end)
VisESP:AddDropdown("TracerOrigin", {Text = "Tracer Origin", Default = 1, Values = {
    "Bottom",
    "Mouse",
    "Top"
}}):OnChanged(function()
    espLib.options.tracerOrigin = Options.TracerOrigin.Value
end)
VisESP:AddSlider("TracerTrans", {Text = "Tracers Transparency", Min = 0, Max = 1, Default = 1, Rounding = 2}):OnChanged(function()
    espLib.options.tracerTransparency = Options.TracerTrans.Value
end)





local MainBOX = GeneralTab:AddLeftTabbox("Silent Aim")
do
    local Main = MainBOX:AddTab("Main")
    Main:AddToggle("aim_Enabled", {Text = "Enabled"})
    Main:AddToggle("TeamCheck", {Text = "Team Check"})
    Main:AddToggle("VisibleCheck", {Text = "Visible Check"})
    Main:AddDropdown("TargetPart", {Text = "Target Part", Default = 1, Values = {
        "Head", "HumanoidRootPart"
    }})
    Main:AddDropdown("Method", {Text = "Silent Aim Method", Default = 1, Values = {
        "Raycast","FindPartOnRay",
        "FindPartOnRayWithWhitelist",
        "FindPartOnRayWithIgnoreList",
        "Mouse.Hit/Target"
    }})
end
local FieldOfViewBOX = GeneralTab:AddLeftTabbox("Silent Aim FOV")
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

    local Main = FieldOfViewBOX:AddTab("Field Of View")
    Main:AddToggle("fov_Enabled", {Text = "Enabled"})
    Main:AddSlider("Radius", {Text = "Radius", Min = 0, Max = 360, Default = 180, Rounding = 0}):OnChanged(function()
        fov_circle.Radius = Options.Radius.Value
    end)
    Main:AddToggle("Visible", {Text = "Visible"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)}):OnChanged(function()
        fov_circle.Visible = Toggles.Visible.Value
        while Toggles.Visible.Value do
            fov_circle.Visible = Toggles.Visible.Value
            fov_circle.Color = Options.Color.Value
            fov_circle.Position = getMousePosition() + Vector2.new(0, 36)
            task.wait()
        end
    end)
    Main:AddToggle("MousePosition", {Text = "Show Fake Mouse Position"}):AddColorPicker("MouseVisualizeColor", {Default = Color3.fromRGB(54, 57, 241)}):OnChanged(function()
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

    
