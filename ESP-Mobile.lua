--==================================================================
--  PLAYER ESP  |  WindUI  |  Delta / mobile executors
--  Fixed + extended: 3D boxes, height, snaplines, 2D clustering
--==================================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--==================================================================
--  CONSTANTS
--==================================================================
local MIN_DISTANCE        = 50
local MAX_DISTANCE        = 2000
local DEFAULT_DISTANCE    = 1000

local MIN_NAME_SIZE       = 8
local MAX_NAME_SIZE       = 24
local DEFAULT_NAME_SIZE   = 14

local MIN_DISTANCE_SIZE   = 6
local MAX_DISTANCE_SIZE   = 18
local DEFAULT_DISTANCE_SIZE = 10

local MIN_HEIGHT_SIZE     = 6
local MAX_HEIGHT_SIZE     = 18
local DEFAULT_HEIGHT_SIZE = 10

local MIN_NEAR_DISTANCE   = 0
local MAX_NEAR_DISTANCE   = 1000

local MIN_TEXT_CURVE      = 0.25
local MAX_TEXT_CURVE      = 4
local DEFAULT_TEXT_CURVE  = 1

local MAX_HIGHLIGHT_BUDGET = 240
local BOX3D_THICKNESS      = 1.5
local LINE_THICKNESS       = 1.5

--==================================================================
--  COLORS
--==================================================================
local DEFAULT_COLORS = {
    EnemyVisible       = Color3.fromRGB(70, 255, 100),
    EnemyHidden        = Color3.fromRGB(255, 60, 60),
    TeamVisible        = Color3.fromRGB(255, 235, 50),
    TeamHidden         = Color3.fromRGB(255, 145, 30),

    EnemyName          = Color3.fromRGB(255, 255, 255),
    TeamName           = Color3.fromRGB(255, 255, 255),
    EnemyDistance      = Color3.fromRGB(220, 220, 220),
    TeamDistance       = Color3.fromRGB(220, 220, 220),
    EnemyHeight        = Color3.fromRGB(160, 220, 255),
    TeamHeight         = Color3.fromRGB(160, 220, 255),

    EnemyBoxVisible    = Color3.fromRGB(70, 255, 100),
    EnemyBoxHidden     = Color3.fromRGB(255, 60, 60),
    TeamBoxVisible     = Color3.fromRGB(255, 235, 50),
    TeamBoxHidden      = Color3.fromRGB(255, 145, 30),

    EnemyBox3DVisible  = Color3.fromRGB(70, 200, 255),
    EnemyBox3DHidden   = Color3.fromRGB(255, 90, 90),
    TeamBox3DVisible   = Color3.fromRGB(180, 255, 120),
    TeamBox3DHidden    = Color3.fromRGB(255, 180, 60),

    EnemyLineVisible   = Color3.fromRGB(70, 255, 100),
    EnemyLineHidden    = Color3.fromRGB(255, 60, 60),
    TeamLineVisible    = Color3.fromRGB(255, 235, 50),
    TeamLineHidden     = Color3.fromRGB(255, 145, 30),

    GroupBox           = Color3.fromRGB(255, 255, 255),
    GroupLabel         = Color3.fromRGB(255, 255, 255),
}

local Colors = {}
local function ResetColors()
    for Name, Color in pairs(DEFAULT_COLORS) do
        Colors[Name] = Color
    end
end
ResetColors()

--==================================================================
--  SETTINGS
--==================================================================
local DEFAULT_SETTINGS = {
    ESP                 = true,
    VisibilityCheck     = true,
    BodyPartRaycast     = true,
    BodyPartRaycastFallback = false,
    TeamCheck           = true,

    ShowName            = true,
    ShowDistance        = true,
    ShowHeight          = false,
    Highlight           = true,
    Boxes               = true,
    Box3D               = false,
    SnapLines           = false,
    GroupBoxes          = true,

    ESPDistance         = DEFAULT_DISTANCE,
    HighlightDistance   = DEFAULT_DISTANCE,
    BoxDistance         = DEFAULT_DISTANCE,
    Box3DDistance       = DEFAULT_DISTANCE,
    LineDistance        = DEFAULT_DISTANCE,
    BodyPartRaycastDistance = 500,
    GroupPadding        = 10,

    NameSize            = DEFAULT_NAME_SIZE,
    DistanceSize        = DEFAULT_DISTANCE_SIZE,
    HeightSize          = DEFAULT_HEIGHT_SIZE,

    TextMode            = "Standard",
    DynamicTextMode     = "Far Bigger",
    DynamicTextCurve    = DEFAULT_TEXT_CURVE,
    NameMinSize         = MIN_NAME_SIZE,
    NameMaxSize         = MAX_NAME_SIZE,
    DistanceMinSize     = MIN_DISTANCE_SIZE,
    DistanceMaxSize     = MAX_DISTANCE_SIZE,
    HeightMinSize       = MIN_HEIGHT_SIZE,
    HeightMaxSize       = MAX_HEIGHT_SIZE,

    BoxMode             = "Accurate",
    RayOrigin           = "Character",
}

local Settings = {}
local function ResetSettings()
    for Name, Value in pairs(DEFAULT_SETTINGS) do
        Settings[Name] = Value
    end
end
ResetSettings()

--==================================================================
--  SIDE SETTINGS  (Enemy / Teammate profiles)
--==================================================================
local DEFAULT_SIDE_SETTINGS = {
    Highlight = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Box       = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Box3D     = { Enabled = false, NearDisable = false, NearDistance = 100 },
    Line      = { Enabled = false, NearDisable = false, NearDistance = 100 },
    Name      = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Distance  = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Height    = { Enabled = false, NearDisable = false, NearDistance = 100 },
}

local function CopySideSettings()
    local Result = {}
    for Name, Data in pairs(DEFAULT_SIDE_SETTINGS) do
        Result[Name] = {
            Enabled      = Data.Enabled,
            NearDisable  = Data.NearDisable,
            NearDistance = Data.NearDistance,
        }
    end
    return Result
end

local SideSettings = {
    Enemy    = CopySideSettings(),
    Teammate = CopySideSettings(),
}

local function ResetSideSettings()
    SideSettings.Enemy    = CopySideSettings()
    SideSettings.Teammate = CopySideSettings()
end

--==================================================================
--  STATE
--==================================================================
local ESPObjects = {}
local SelectedSide = "Enemy"

local BodyPartNames = {
    "Head","UpperTorso","LowerTorso","Torso",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot",
    "Left Arm","Right Arm","Left Leg","Right Leg",
    "HumanoidRootPart",
}

--==================================================================
--  OVERLAY GUI
--==================================================================
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

--==================================================================
--  UTILITY
--==================================================================
local function GetCharacter(Player)
    local Character = Player.Character
    if Character and Character.Parent then
        return Character
    end
    return nil
end

local function GetRoot(Character)
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function GetSide(Player)
    if Settings.TeamCheck
        and LocalPlayer.Team and Player.Team
        and LocalPlayer.Team == Player.Team then
        return "Teammate"
    end
    return "Enemy"
end

local function IsFeatureEnabled(Side, Feature, Distance)
    local Data = SideSettings[Side] and SideSettings[Side][Feature]
    if not Data or not Data.Enabled then return false end
    if Data.NearDisable and Distance <= Data.NearDistance then return false end
    return true
end

local function GetBodyParts(Character)
    local Parts = {}
    for _, Name in ipairs(BodyPartNames) do
        local Part = Character:FindFirstChild(Name)
        if Part and Part:IsA("BasePart") then
            Parts[#Parts + 1] = Part
        end
    end
    return Parts
end

local function GetRayOrigin()
    if Settings.RayOrigin == "Camera" then
        local Camera = workspace.CurrentCamera
        return Camera and Camera.CFrame.Position
    end
    local Root = GetRoot(LocalPlayer.Character)
    return Root and Root.Position
end

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
RaycastParams.IgnoreWater = true

local function IsPartVisible(Character, Part, Origin)
    if not Part or not Origin then return false end
    local Direction = Part.Position - Origin
    if Direction.Magnitude <= 0.01 then return true end
    RaycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
    local Result = workspace:Raycast(Origin, Direction, RaycastParams)
    return Result == nil or Result.Instance:IsDescendantOf(Character)
end

local function GetVisibility(Character, Distance)
    if not Settings.VisibilityCheck then
        return { AnyVisible = true, Parts = {}, UseBodyParts = false }
    end
    local Origin = GetRayOrigin()
    if not Origin then
        return { AnyVisible = false, Parts = {}, UseBodyParts = false }
    end
    local UseBodyParts = Settings.BodyPartRaycast and (
        not Settings.BodyPartRaycastFallback
        or Distance <= Settings.BodyPartRaycastDistance
    )
    if not UseBodyParts then
        local Root = GetRoot(Character)
        if not Root then
            return { AnyVisible = false, Parts = {}, UseBodyParts = false }
        end
        local Visible = IsPartVisible(Character, Root, Origin)
        return { AnyVisible = Visible, Parts = { [Root] = Visible }, UseBodyParts = false }
    end
    local VisibleParts = {}
    local AnyVisible = false
    for _, Part in ipairs(GetBodyParts(Character)) do
        local Visible = IsPartVisible(Character, Part, Origin)
        VisibleParts[Part] = Visible
        if Visible then AnyVisible = true end
    end
    return { AnyVisible = AnyVisible, Parts = VisibleParts, UseBodyParts = true }
end

--==================================================================
--  COLOR GETTERS
--==================================================================
local function GetHighlightColor(Player, Visible)
    if GetSide(Player) == "Teammate" then
        return Visible and Colors.TeamVisible or Colors.TeamHidden
    end
    return Visible and Colors.EnemyVisible or Colors.EnemyHidden
end

local function GetNameColor(Player)
    return GetSide(Player) == "Teammate" and Colors.TeamName or Colors.EnemyName
end

local function GetDistanceColor(Player)
    return GetSide(Player) == "Teammate" and Colors.TeamDistance or Colors.EnemyDistance
end

local function GetHeightColor(Player)
    return GetSide(Player) == "Teammate" and Colors.TeamHeight or Colors.EnemyHeight
end

local function GetBoxColor(Player, Visible)
    if GetSide(Player) == "Teammate" then
        return Visible and Colors.TeamBoxVisible or Colors.TeamBoxHidden
    end
    return Visible and Colors.EnemyBoxVisible or Colors.EnemyBoxHidden
end

local function GetBox3DColor(Player, Visible)
    if GetSide(Player) == "Teammate" then
        return Visible and Colors.TeamBox3DVisible or Colors.TeamBox3DHidden
    end
    return Visible and Colors.EnemyBox3DVisible or Colors.EnemyBox3DHidden
end

local function GetLineColor(Player, Visible)
    if GetSide(Player) == "Teammate" then
        return Visible and Colors.TeamLineVisible or Colors.TeamLineHidden
    end
    return Visible and Colors.EnemyLineVisible or Colors.EnemyLineHidden
end

--==================================================================
--  TEXT SIZE
--==================================================================
local function GetDynamicSize(Distance, MinSize, MaxSize)
    if Settings.TextMode ~= "Dynamic" then return nil end
    local Range = math.max(Settings.ESPDistance, 1)
    local Alpha = math.clamp(Distance / Range, 0, 1)
    local Progress = Alpha ^ Settings.DynamicTextCurve
    if Settings.DynamicTextMode == "Far Bigger" then
        return math.floor(MinSize + (MaxSize - MinSize) * Progress + 0.5)
    end
    return math.floor(MaxSize - (MaxSize - MinSize) * Progress + 0.5)
end

local function GetNameSize(Distance)
    return GetDynamicSize(Distance, Settings.NameMinSize, Settings.NameMaxSize) or Settings.NameSize
end
local function GetDistanceSize(Distance)
    return GetDynamicSize(Distance, Settings.DistanceMinSize, Settings.DistanceMaxSize) or Settings.DistanceSize
end
local function GetHeightSize(Distance)
    return GetDynamicSize(Distance, Settings.HeightMinSize, Settings.HeightMaxSize) or Settings.HeightSize
end

--==================================================================
--  CHARACTER HEIGHT  (cached per character)
--==================================================================
local function GetCharacterHeight(Character)
    local ok, _, size = pcall(function() return Character:GetBoundingBox() end)
    if ok and size then return size.Y end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then return Humanoid.HipHeight * 2 + 2 end
    return 5
end

--==================================================================
--  HIGHLIGHTS
--==================================================================
local function CreateHighlight(Adornee)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESPHighlight"
    Highlight.Adornee = Adornee
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillTransparency = 0.45
    Highlight.OutlineTransparency = 0
    Highlight.Enabled = true
    Highlight.Parent = ESPGui
    return Highlight
end

local function ClearHighlights(Data)
    for Part, Highlight in pairs(Data.Highlights) do
        if Highlight then Highlight:Destroy() end
        Data.Highlights[Part] = nil
    end
    if Data.FullHighlight then
        Data.FullHighlight:Destroy()
        Data.FullHighlight = nil
    end
end

local function SetFullHighlight(Data, Character, Color)
    if not Data.FullHighlight then
        Data.FullHighlight = CreateHighlight(Character)
    else
        Data.FullHighlight.Adornee = Character
    end
    Data.FullHighlight.FillColor = Color
    Data.FullHighlight.OutlineColor = Color
end

local function SetBodyPartHighlight(Data, Part, Color)
    local Highlight = Data.Highlights[Part]
    if not Highlight then
        Highlight = CreateHighlight(Part)
        Data.Highlights[Part] = Highlight
    end
    Highlight.FillColor = Color
    Highlight.OutlineColor = Color
end

--==================================================================
--  2D BOX BOUNDS
--==================================================================
local function GetPerformanceBounds(Character)
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end
    local Root = GetRoot(Character)
    if not Root then return nil end
    local Position, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if Position.Z <= 0 or not OnScreen then return nil end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return nil end
    -- realistic proportions: hip*2 + head room
    local Height = math.clamp(Humanoid.HipHeight * 2 + 2, 3, 9)
    local Width = Height * 0.45
    local Top = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, Height / 2, 0))
    local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, Height / 2, 0))
    local SizeY = math.abs(Top.Y - Bottom.Y)
    if SizeY <= 2 then return nil end
    local SizeX = SizeY * Width / Height
    return Position.X - SizeX / 2, Position.Y - SizeY / 2,
           Position.X + SizeX / 2, Position.Y + SizeY / 2
end

local function GetAccurateBounds(Character)
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end
    local MinX, MinY = math.huge, math.huge
    local MaxX, MaxY = -math.huge, -math.huge
    local Found = false
    for _, Part in ipairs(GetBodyParts(Character)) do
        local Half = Part.Size / 2
        for X = -1, 1, 2 do
            for Y = -1, 1, 2 do
                for Z = -1, 1, 2 do
                    local World = Part.CFrame:PointToWorldSpace(Vector3.new(Half.X * X, Half.Y * Y, Half.Z * Z))
                    local P = Camera:WorldToViewportPoint(World)
                    if P.Z > 0 then
                        MinX = math.min(MinX, P.X); MinY = math.min(MinY, P.Y)
                        MaxX = math.max(MaxX, P.X); MaxY = math.max(MaxY, P.Y)
                        Found = true
                    end
                end
            end
        end
    end
    if not Found then return nil end
    return MinX, MinY, MaxX, MaxY
end

local function GetScreenBounds(Character)
    if Settings.BoxMode == "Accurate" then
        return GetAccurateBounds(Character)
    end
    return GetPerformanceBounds(Character)
end

--==================================================================
--  LINE / FRAME DRAWING
--==================================================================
local function DrawLineFrame(Frame, X1, Y1, X2, Y2, Thickness)
    Thickness = Thickness or LINE_THICKNESS
    local dx, dy = X2 - X1, Y2 - Y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1 then
        Frame.Visible = false
        return
    end
    Frame.Size = UDim2.fromOffset(len, Thickness)
    Frame.Position = UDim2.fromOffset((X1 + X2) / 2 - len / 2, (Y1 + Y2) / 2 - Thickness / 2)
    Frame.Rotation = math.deg(math.atan2(dy, dx))
    Frame.Visible = true
end

local function CreateLineFrame(z)
    local F = Instance.new("Frame")
    F.BorderSizePixel = 0
    F.Visible = false
    F.Active = false
    F.ZIndex = z or 9
    F.Parent = ESPGui
    return F
end

local function CreateBox(z)
    local Box = Instance.new("Frame")
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 0
    Box.Visible = false
    Box.Active = false
    Box.ZIndex = z or 10
    Box.Parent = ESPGui
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Parent = Box
    return Box, Stroke
end

--==================================================================
--  3D BOX  (8 corners -> 12 edges)
--==================================================================
local Box3DEdges = {
    {1,2},{2,3},{3,4},{4,1},   -- bottom
    {5,6},{6,7},{7,8},{8,5},   -- top
    {1,5},{2,6},{3,7},{4,8},   -- verticals
}

local function GetBox3DCorners(Character)
    local ok, cf, size = pcall(function() return Character:GetBoundingBox() end)
    if not ok or not cf then return nil end
    local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
    local base = {
        Vector3.new(-hx,-hy,-hz), Vector3.new(hx,-hy,-hz),
        Vector3.new(hx,-hy,hz),  Vector3.new(-hx,-hy,hz),
        Vector3.new(-hx,hy,-hz), Vector3.new(hx,hy,-hz),
        Vector3.new(hx,hy,hz),   Vector3.new(-hx,hy,hz),
    }
    local corners = {}
    for i, v in ipairs(base) do
        corners[i] = cf:PointToWorldSpace(v)
    end
    return corners
end

local function HideBox3D(Data)
    if Data.Box3DLines then
        for _, f in pairs(Data.Box3DLines) do
            f.Visible = false
        end
    end
end

local function UpdateBox3D(Player, Data, Character, Distance, Side, Visibility)
    if not Settings.ESP or not Settings.Box3D
        or Distance > Settings.Box3DDistance
        or not IsFeatureEnabled(Side, "Box3D", Distance) then
        HideBox3D(Data)
        return
    end
    local Camera = workspace.CurrentCamera
    local corners = GetBox3DCorners(Character)
    if not Camera or not corners then
        HideBox3D(Data)
        return
    end
    local proj = {}
    for i, c in ipairs(corners) do
        local p = Camera:WorldToViewportPoint(c)
        if p.Z <= 0 then
            HideBox3D(Data)
            return
        end
        proj[i] = { X = p.X, Y = p.Y }
    end
    Data.Box3DLines = Data.Box3DLines or {}
    local col = GetBox3DColor(Player, Visibility.AnyVisible)
    for ei, edge in ipairs(Box3DEdges) do
        local frame = Data.Box3DLines[ei]
        if not frame then
            frame = CreateLineFrame(8)
            Data.Box3DLines[ei] = frame
        end
        frame.BackgroundColor3 = col
        DrawLineFrame(frame, proj[edge[1]].X, proj[edge[1]].Y,
                             proj[edge[2]].X, proj[edge[2]].Y, BOX3D_THICKNESS)
    end
end

--==================================================================
--  SNAPLINES  (from my player to target)
--==================================================================
local function UpdateSnapLine(Player, Data, Character, Distance, Side, Visibility)
    if not Settings.ESP or not Settings.SnapLines
        or Distance > Settings.LineDistance
        or not IsFeatureEnabled(Side, "Line", Distance) then
        if Data.LineFrame then Data.LineFrame.Visible = false end
        return
    end
    local Camera = workspace.CurrentCamera
    local MyRoot = GetRoot(LocalPlayer.Character)
    local TargetRoot = GetRoot(Character)
    if not Camera or not MyRoot or not TargetRoot then
        if Data.LineFrame then Data.LineFrame.Visible = false end
        return
    end
    local from = Camera:WorldToViewportPoint(MyRoot.Position)
    local to   = Camera:WorldToViewportPoint(TargetRoot.Position)
    if from.Z <= 0 or to.Z <= 0 then
        if Data.LineFrame then Data.LineFrame.Visible = false end
        return
    end
    if not Data.LineFrame then
        Data.LineFrame = CreateLineFrame(9)
    end
    Data.LineFrame.BackgroundColor3 = GetLineColor(Player, Visibility.AnyVisible)
    DrawLineFrame(Data.LineFrame, from.X, from.Y, to.X, to.Y, LINE_THICKNESS)
end

--==================================================================
--  2D BOX  +  CLUSTERING
--==================================================================
local BoxCandidates = {}

local GroupPool = {}
local GroupLabelPool = {}

local function GetGroupBox(index)
    if not GroupPool[index] then
        local Box, Stroke = CreateBox(11)
        Stroke.Thickness = 2
        GroupPool[index] = { Box = Box, Stroke = Stroke }
    end
    return GroupPool[index]
end

local function GetGroupLabel(index)
    if not GroupLabelPool[index] then
        local L = Instance.new("TextLabel")
        L.BackgroundTransparency = 1
        L.Font = Enum.Font.GothamBold
        L.TextStrokeTransparency = 0.3
        L.Visible = false
        L.ZIndex = 12
        L.TextXAlignment = Enum.TextXAlignment.Center
        L.Parent = ESPGui
        GroupLabelPool[index] = L
    end
    return GroupLabelPool[index]
end

local function UpdateBox(Player, Data, Character, Distance, Side, Visibility)
    Data.Grouped = false
    if not Settings.ESP or not Settings.Boxes
        or Distance > Settings.BoxDistance
        or not IsFeatureEnabled(Side, "Box", Distance) then
        Data.Box.Visible = false
        return
    end
    local MinX, MinY, MaxX, MaxY = GetScreenBounds(Character)
    if not MinX then
        Data.Box.Visible = false
        return
    end
    Data.ScreenBounds = { MinX = MinX, MinY = MinY, MaxX = MaxX, MaxY = MaxY }
    Data.BoxStroke.Color = GetBoxColor(Player, Visibility.AnyVisible)
    Data.Box.Position = UDim2.fromOffset(MinX, MinY)
    Data.Box.Size = UDim2.fromOffset(math.max(MaxX - MinX, 2), math.max(MaxY - MinY, 2))
    Data.Box.Visible = true
    BoxCandidates[#BoxCandidates + 1] = {
        Data = Data, MinX = MinX, MinY = MinY, MaxX = MaxX, MaxY = MaxY,
    }
end

local function UpdateClusters()
    for _, g in pairs(GroupPool) do g.Box.Visible = false end
    for _, l in pairs(GroupLabelPool) do l.Visible = false end

    if not Settings.ESP or not Settings.Boxes or not Settings.GroupBoxes then
        return
    end

    local pad = Settings.GroupPadding
    local groups = {}
    for _, cand in ipairs(BoxCandidates) do
        local merged = false
        for _, g in ipairs(groups) do
            if cand.MinX <= g.MaxX + pad and cand.MaxX >= g.MinX - pad
               and cand.MinY <= g.MaxY + pad and cand.MaxY >= g.MinY - pad then
                g.MinX = math.min(g.MinX, cand.MinX)
                g.MinY = math.min(g.MinY, cand.MinY)
                g.MaxX = math.max(g.MaxX, cand.MaxX)
                g.MaxY = math.max(g.MaxY, cand.MaxY)
                table.insert(g.Members, cand.Data)
                merged = true
                break
            end
        end
        if not merged then
            table.insert(groups, {
                MinX = cand.MinX, MinY = cand.MinY,
                MaxX = cand.MaxX, MaxY = cand.MaxY,
                Members = { cand.Data },
            })
        end
    end

    local gi = 0
    for _, g in ipairs(groups) do
        if #g.Members > 1 then
            gi = gi + 1
            for _, m in ipairs(g.Members) do
                m.Box.Visible = false
                m.Grouped = true
            end
            local gb = GetGroupBox(gi)
            gb.Stroke.Color = Colors.GroupBox
            gb.Box.Position = UDim2.fromOffset(g.MinX, g.MinY)
            gb.Box.Size = UDim2.fromOffset(math.max(g.MaxX - g.MinX, 2), math.max(g.MaxY - g.MinY, 2))
            gb.Box.Visible = true

            local lbl = GetGroupLabel(gi)
            lbl.Text = "x" .. #g.Members
            lbl.TextColor3 = Colors.GroupLabel
            lbl.TextSize = 16
            lbl.Size = UDim2.fromOffset(g.MaxX - g.MinX, 20)
            lbl.Position = UDim2.fromOffset(g.MinX, g.MinY - 22)
            lbl.Visible = true
        end
    end
end

--==================================================================
--  TEXT  (name / distance / height)
--==================================================================
local function UpdateText(Player, Data, Distance, Side)
    local Root = GetRoot(Data.Character)
    if not Root or not Root.Parent or not Data.Billboard or not Data.Billboard.Parent then
        if Data.Billboard then Data.Billboard.Enabled = false end
        if Data.Name then Data.Name.Visible = false end
        if Data.Distance then Data.Distance.Visible = false end
        if Data.Height then Data.Height.Visible = false end
        return
    end

    local NameEnabled = Settings.ShowName and Distance <= Settings.ESPDistance
        and IsFeatureEnabled(Side, "Name", Distance)
    local DistanceEnabled = Settings.ShowDistance and Distance <= Settings.ESPDistance
        and IsFeatureEnabled(Side, "Distance", Distance)
    local HeightEnabled = Settings.ShowHeight and Distance <= Settings.ESPDistance
        and IsFeatureEnabled(Side, "Height", Distance)

    Data.Billboard.Adornee = Root
    Data.Billboard.MaxDistance = MAX_DISTANCE
    Data.Billboard.AlwaysOnTop = true

    Data.Name.Text = Player.DisplayName
    Data.Name.TextSize = GetNameSize(Distance)
    Data.Name.TextColor3 = GetNameColor(Player)
    Data.Name.Visible = NameEnabled

    Data.Distance.TextSize = GetDistanceSize(Distance)
    Data.Distance.TextColor3 = GetDistanceColor(Player)
    Data.Distance.Visible = DistanceEnabled
    Data.Distance.Text = DistanceEnabled
        and (tostring(math.floor(Distance + 0.5)) .. " studs") or ""

    if HeightEnabled then
        Data.CharacterHeight = Data.CharacterHeight or GetCharacterHeight(Data.Character)
        Data.Height.TextSize = GetHeightSize(Distance)
        Data.Height.TextColor3 = GetHeightColor(Player)
        Data.Height.Text = string.format("%.1f studs", Data.CharacterHeight)
        Data.Height.Visible = true
    else
        Data.Height.Visible = false
    end

    Data.Billboard.Enabled = NameEnabled or DistanceEnabled or HeightEnabled
end

--==================================================================
--  HIGHLIGHT BUDGET + APPLY
--==================================================================
local function UpdateHighlightBudget()
    if not Settings.ESP or not Settings.Highlight then
        for _, Data in pairs(ESPObjects) do
            ClearHighlights(Data)
            Data.HighlightMode = nil
        end
        return
    end
    local MyRoot = GetRoot(LocalPlayer.Character)
    if not MyRoot then
        for _, Data in pairs(ESPObjects) do
            ClearHighlights(Data)
            Data.HighlightMode = nil
        end
        return
    end
    local Candidates = {}
    for Player, Data in pairs(ESPObjects) do
        local Character = GetCharacter(Player)
        local Root = GetRoot(Character)
        local ok = false
        if Character and Root and Player.Parent == Players then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Distance = (MyRoot.Position - Root.Position).Magnitude
                local Side = GetSide(Player)
                if Distance <= Settings.HighlightDistance
                    and IsFeatureEnabled(Side, "Highlight", Distance) then
                    Candidates[#Candidates + 1] = {
                        Data = Data, Distance = Distance,
                        PartCount = #GetBodyParts(Character),
                    }
                    ok = true
                end
            end
        end
        if not ok then
            ClearHighlights(Data)
            Data.HighlightMode = nil
        end
    end

    table.sort(Candidates, function(A, B) return A.Distance < B.Distance end)
    local Remaining = MAX_HIGHLIGHT_BUDGET
    for _, c in ipairs(Candidates) do
        if c.PartCount > 0 and c.PartCount <= Remaining then
            c.Data.HighlightMode = "BodyParts"
            Remaining = Remaining - c.PartCount
        else
            c.Data.HighlightMode = nil
        end
    end
    if Remaining > 0 then
        for i = #Candidates, 1, -1 do
            local c = Candidates[i]
            if not c.Data.HighlightMode then
                c.Data.HighlightMode = "Full"
                Remaining = Remaining - 1
                if Remaining <= 0 then break end
            end
        end
    end
    for _, c in ipairs(Candidates) do
        if not c.Data.HighlightMode then
            ClearHighlights(c.Data)
        end
    end
end

local function UpdateHighlights(Player, Data, Distance, Side, Visibility)
    local Mode = Data.HighlightMode
    if not Mode or not Settings.Highlight
        or Distance > Settings.HighlightDistance
        or not IsFeatureEnabled(Side, "Highlight", Distance) then
        ClearHighlights(Data)
        Data.HighlightMode = nil
        return
    end
    if Mode == "Full" then
        SetFullHighlight(Data, Data.Character, GetHighlightColor(Player, Visibility.AnyVisible))
        for Part, Highlight in pairs(Data.Highlights) do
            Highlight:Destroy()
            Data.Highlights[Part] = nil
        end
        return
    end
    if Data.FullHighlight then
        Data.FullHighlight:Destroy()
        Data.FullHighlight = nil
    end
    local Existing = {}
    for _, Part in ipairs(GetBodyParts(Data.Character)) do
        Existing[Part] = true
        local Visible
        if not Settings.VisibilityCheck then Visible = true
        elseif Visibility.UseBodyParts then Visible = Visibility.Parts[Part] == true
        else Visible = Visibility.AnyVisible end
        SetBodyPartHighlight(Data, Part, GetHighlightColor(Player, Visible))
    end
    for Part, Highlight in pairs(Data.Highlights) do
        if not Existing[Part] or not Part.Parent then
            Highlight:Destroy()
            Data.Highlights[Part] = nil
        end
    end
end

--==================================================================
--  HIDE / CREATE / REMOVE
--==================================================================
local function HideESP(Data)
    if Data.Billboard then Data.Billboard.Enabled = false end
    if Data.Name then Data.Name.Visible = false end
    if Data.Distance then Data.Distance.Visible = false end
    if Data.Height then Data.Height.Visible = false end
    if Data.Box then Data.Box.Visible = false end
    if Data.LineFrame then Data.LineFrame.Visible = false end
    HideBox3D(Data)
    ClearHighlights(Data)
    Data.HighlightMode = nil
end

local function CreateESP(Player)
    if Player == LocalPlayer or ESPObjects[Player] then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "PlayerESP"
    Billboard.Size = UDim2.fromOffset(220, 80)
    Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    Billboard.AlwaysOnTop = true
    Billboard.LightInfluence = 0
    Billboard.MaxDistance = MAX_DISTANCE
    Billboard.ResetOnSpawn = false
    Billboard.Enabled = false
    Billboard.Parent = PlayerGui

    local Name = Instance.new("TextLabel")
    Name.Name = "Name"
    Name.Size = UDim2.new(1, 0, 0, 26)
    Name.BackgroundTransparency = 1
    Name.Text = Player.DisplayName
    Name.TextColor3 = Colors.EnemyName
    Name.TextSize = Settings.NameSize
    Name.TextStrokeTransparency = 0.35
    Name.TextXAlignment = Enum.TextXAlignment.Center
    Name.Font = Enum.Font.GothamBold
    Name.Visible = false
    Name.Parent = Billboard

    local Distance = Instance.new("TextLabel")
    Distance.Name = "Distance"
    Distance.Size = UDim2.new(1, 0, 0, 18)
    Distance.Position = UDim2.fromOffset(0, 26)
    Distance.BackgroundTransparency = 1
    Distance.TextColor3 = Colors.EnemyDistance
    Distance.TextSize = Settings.DistanceSize
    Distance.TextStrokeTransparency = 0.5
    Distance.TextXAlignment = Enum.TextXAlignment.Center
    Distance.Font = Enum.Font.GothamMedium
    Distance.Visible = false
    Distance.Parent = Billboard

    local Height = Instance.new("TextLabel")
    Height.Name = "Height"
    Height.Size = UDim2.new(1, 0, 0, 18)
    Height.Position = UDim2.fromOffset(0, 44)
    Height.BackgroundTransparency = 1
    Height.TextColor3 = Colors.EnemyHeight
    Height.TextSize = Settings.HeightSize
    Height.TextStrokeTransparency = 0.5
    Height.TextXAlignment = Enum.TextXAlignment.Center
    Height.Font = Enum.Font.GothamMedium
    Height.Visible = false
    Height.Parent = Billboard

    local Box, BoxStroke = CreateBox(10)

    local Data = {
        Billboard = Billboard,
        Name = Name, Distance = Distance, Height = Height,
        Box = Box, BoxStroke = BoxStroke,
        LineFrame = nil,
        Box3DLines = nil,
        Highlights = {},
        FullHighlight = nil,
        Character = nil,
        Connection = nil,
        Visibility = nil,
        HighlightMode = nil,
        CharacterHeight = nil,
        ScreenBounds = nil,
        Grouped = false,
    }
    ESPObjects[Player] = Data

    local function Attach(Character)
        local CD = ESPObjects[Player]
        if not CD then return end
        CD.Character = Character
        CD.Visibility = nil
        CD.HighlightMode = nil
        CD.CharacterHeight = nil
        ClearHighlights(CD)
        HideBox3D(CD)
        CD.Billboard.Enabled = false
        CD.Billboard.AlwaysOnTop = true
        CD.Billboard.MaxDistance = MAX_DISTANCE
        CD.Name.Visible = false
        CD.Distance.Visible = false
        CD.Height.Visible = false
        local Root = GetRoot(Character)
        CD.Billboard.Adornee = Root or nil
    end

    if Player.Character then
        task.spawn(Attach, Player.Character)
    end

    Data.Connection = Player.CharacterAdded:Connect(function(Character)
        local CD = ESPObjects[Player]
        if not CD then return end
        Attach(Character)
        task.spawn(function()
            local Root = Character:WaitForChild("HumanoidRootPart", 3)
            if ESPObjects[Player] == CD and Root and Root.Parent then
                CD.Character = Character
                CD.Billboard.Adornee = Root
            end
        end)
    end)
end

local function RemoveESP(Player)
    local Data = ESPObjects[Player]
    if not Data then return end
    if Data.Connection then Data.Connection:Disconnect() end
    ClearHighlights(Data)
    HideBox3D(Data)
    if Data.Box3DLines then
        for _, f in pairs(Data.Box3DLines) do f:Destroy() end
    end
    if Data.LineFrame then Data.LineFrame:Destroy() end
    if Data.Billboard then Data.Billboard:Destroy() end
    if Data.Box then Data.Box:Destroy() end
    ESPObjects[Player] = nil
end

--==================================================================
--  PER-PLAYER UPDATE
--==================================================================
local function UpdateESP(Player, Data)
    if not Settings.ESP then
        HideESP(Data)
        return
    end
    local Character = GetCharacter(Player)
    if not Character then
        HideESP(Data)
        return
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = GetRoot(Character)
    local MyRoot = GetRoot(LocalPlayer.Character)
    if not Humanoid or not Root or not MyRoot or Humanoid.Health <= 0 then
        HideESP(Data)
        return
    end
    if Data.Character ~= Character then
        Data.Character = Character
        Data.Visibility = nil
        Data.HighlightMode = nil
        Data.CharacterHeight = nil
        ClearHighlights(Data)
        HideBox3D(Data)
    end
    Data.Billboard.Adornee = Root
    local Distance = (MyRoot.Position - Root.Position).Magnitude
    local Side = GetSide(Player)

    Data.Visibility = Settings.VisibilityCheck
        and GetVisibility(Character, Distance)
        or { AnyVisible = true, Parts = {}, UseBodyParts = false }

    UpdateText(Player, Data, Distance, Side)
    UpdateHighlights(Player, Data, Distance, Side, Data.Visibility)
    UpdateBox(Player, Data, Character, Distance, Side, Data.Visibility)
    UpdateBox3D(Player, Data, Character, Distance, Side, Data.Visibility)
    UpdateSnapLine(Player, Data, Character, Distance, Side, Data.Visibility)
end

--==================================================================
--  SAFE GUI SETTER  (WindUI elements)
--==================================================================
local function SetElement(Element, Value)
    if not Element then return end
    if Element.Set then
        pcall(function() Element:Set(Value) end)
    elseif Element.Select then
        pcall(function() Element:Select(Value) end)
    end
end

--==================================================================
--  WINDUI  WINDOW
--==================================================================
local Window = WindUI:CreateWindow({
    Title = "PLAYER ESP",
    Icon = "eye",
    Author = "ratman4080",
    Folder = "PlayerESP",
    Size = UDim2.fromOffset(580, 500),
    MinSize = Vector2.new(400, 340),
    MaxSize = Vector2.new(920, 760),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

local Tabs = {
    About     = Window:Tab({ Title = "About",     Icon = "house",         Desc = "Info & hints" }),
    Visuals   = Window:Tab({ Title = "Visuals",   Icon = "eye",           Desc = "Main ESP features" }),
    Distances = Window:Tab({ Title = "Distances", Icon = "maximize",      Desc = "Range limits" }),
    Sides     = Window:Tab({ Title = "Sides",     Icon = "users",         Desc = "Enemy / Teammate profiles" }),
    Detection = Window:Tab({ Title = "Detection", Icon = "scan-search",   Desc = "Visibility raycast" }),
    Text      = Window:Tab({ Title = "Text",      Icon = "type",          Desc = "Text appearance" }),
    Colors    = Window:Tab({ Title = "Colors",    Icon = "palette",       Desc = "ESP colors" }),
    Interface = Window:Tab({ Title = "Interface", Icon = "settings",      Desc = "Theme & reset" }),
}

Window:SelectTab(Tabs.Visuals)

--==================================================================
--  ABOUT
--==================================================================
Tabs.About:Paragraph({
    Title = "PLAYER ESP  v2",
    Desc = "Names, distance, height, highlights, 2D/3D boxes, snaplines and clustering.",
    Image = "eye", ImageSize = 26,
})
local AboutBox = Tabs.About:Section({ Title = "Overview", Icon = "info", Opened = true, Box = true })
AboutBox:Paragraph({ Title = "2D Boxes",   Desc = "Screen-space rectangles. Overlapping boxes merge and show a count.", Image = "square",      ImageSize = 18 })
AboutBox:Paragraph({ Title = "3D Boxes",   Desc = "World-space wireframe box built from the character bounding box.",   Image = "box",         ImageSize = 18 })
AboutBox:Paragraph({ Title = "Snaplines",  Desc = "Lines from your player to every target.",                             Image = "move-diagonal",ImageSize = 18 })
AboutBox:Paragraph({ Title = "Height",     Desc = "Shows each character's height in studs.",                             Image = "ruler",       ImageSize = 18 })
AboutBox:Paragraph({ Title = "Detection",  Desc = "Body-part or normal raycast, camera or character origin.",            Image = "scan-search", ImageSize = 18 })
AboutBox:Paragraph({ Title = "Profiles",   Desc = "Independent Enemy / Teammate settings in the Sides tab.",             Image = "users",       ImageSize = 18 })

--==================================================================
--  VISUALS
--==================================================================
local VisSection = Tabs.Visuals:Section({ Title = "Features", Icon = "scan", Opened = true, Box = true })

local T_ESP = VisSection:Toggle({ Title = "ESP", Desc = "Master switch", Value = Settings.ESP,
    Callback = function(v) Settings.ESP = v end })
VisSection:Toggle({ Title = "Names", Desc = "Player names", Value = Settings.ShowName,
    Callback = function(v) Settings.ShowName = v end })
VisSection:Toggle({ Title = "Distance", Desc = "Distance in studs", Value = Settings.ShowDistance,
    Callback = function(v) Settings.ShowDistance = v end })
VisSection:Toggle({ Title = "Height", Desc = "Character height in studs", Value = Settings.ShowHeight,
    Callback = function(v) Settings.ShowHeight = v end })
VisSection:Toggle({ Title = "Highlight", Desc = "Body-part glow", Value = Settings.Highlight,
    Callback = function(v) Settings.Highlight = v end })
VisSection:Toggle({ Title = "2D Boxes", Desc = "Screen rectangles", Value = Settings.Boxes,
    Callback = function(v) Settings.Boxes = v end })
VisSection:Toggle({ Title = "3D Boxes", Desc = "World wireframe box", Value = Settings.Box3D,
    Callback = function(v) Settings.Box3D = v end })
VisSection:Toggle({ Title = "Snaplines", Desc = "Lines from you to targets", Value = Settings.SnapLines,
    Callback = function(v) Settings.SnapLines = v end })
VisSection:Toggle({ Title = "Team Check", Desc = "Split enemy / teammate", Value = Settings.TeamCheck,
    Callback = function(v) Settings.TeamCheck = v end })

local GroupSection = Tabs.Visuals:Section({ Title = "2D Clustering", Icon = "group", Opened = true, Box = true })
GroupSection:Toggle({ Title = "Group Boxes", Desc = "Merge overlapping 2D boxes and show a count", Value = Settings.GroupBoxes,
    Callback = function(v) Settings.GroupBoxes = v end })
GroupSection:Slider({ Title = "Group Padding", Desc = "Pixel gap before boxes are treated as separate",
    Value = { Min = 0, Max = 60, Default = Settings.GroupPadding }, Step = 1,
    Callback = function(v) Settings.GroupPadding = v end })

local BoxModeSection = Tabs.Visuals:Section({ Title = "2D Box Mode", Icon = "square", Opened = true, Box = true })
BoxModeSection:Dropdown({ Title = "Box Mode", Desc = "Accurate = every limb corner. Performance = fast approximation.",
    Values = { "Accurate", "Performance" }, Value = Settings.BoxMode,
    Callback = function(v) Settings.BoxMode = v end })

--==================================================================
--  DISTANCES
--==================================================================
local DistSection = Tabs.Distances:Section({ Title = "Range Limits", Icon = "maximize", Opened = true, Box = true })
DistSection:Slider({ Title = "Text Distance", Desc = "Max distance for name / distance / height",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.ESPDistance }, Step = 1,
    Callback = function(v) Settings.ESPDistance = v end })
DistSection:Slider({ Title = "Highlight Distance", Desc = "Max highlight range",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.HighlightDistance }, Step = 1,
    Callback = function(v) Settings.HighlightDistance = v end })
DistSection:Slider({ Title = "2D Box Distance", Desc = "Max 2D box range",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.BoxDistance }, Step = 1,
    Callback = function(v) Settings.BoxDistance = v end })
DistSection:Slider({ Title = "3D Box Distance", Desc = "Max 3D box range",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.Box3DDistance }, Step = 1,
    Callback = function(v) Settings.Box3DDistance = v end })
DistSection:Slider({ Title = "Snapline Distance", Desc = "Max snapline range",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.LineDistance }, Step = 1,
    Callback = function(v) Settings.LineDistance = v end })

--==================================================================
--  SIDES
--==================================================================
Tabs.Sides:Paragraph({ Title = "Side Profiles", Desc = "Configure Enemy and Teammate independently.", Image = "users", ImageSize = 20 })

local SideDropdown = Tabs.Sides:Dropdown({
    Title = "Side", Desc = "Choose a profile",
    Values = { "Enemy", "Teammate" }, Value = SelectedSide,
    Callback = function(v) SelectedSide = v; RefreshSideUI() end,
})

local SideSection = Tabs.Sides:Section({ Title = "Elements", Icon = "layers-3", Opened = true, Box = true })

local SideElements = {}

local function RefreshSideUI()
    for Name, refs in pairs(SideElements) do
        local s = SideSettings[SelectedSide][Name]
        if s then
            SetElement(refs.Toggle, s.Enabled)
            SetElement(refs.NearToggle, s.NearDisable)
            SetElement(refs.NearSlider, s.NearDistance)
        end
    end
end

local function CreateSideControl(Name, Title, Description)
    local t = SideSection:Toggle({ Title = Title, Desc = Description,
        Value = SideSettings[SelectedSide][Name].Enabled,
        Callback = function(v) SideSettings[SelectedSide][Name].Enabled = v end })
    local nt = SideSection:Toggle({ Title = "Disable Near", Desc = "Hide at close range",
        Value = SideSettings[SelectedSide][Name].NearDisable,
        Callback = function(v) SideSettings[SelectedSide][Name].NearDisable = v end })
    local ns = SideSection:Slider({ Title = "Near Distance", Desc = "Disable below this distance",
        Value = { Min = MIN_NEAR_DISTANCE, Max = MAX_NEAR_DISTANCE, Default = SideSettings[SelectedSide][Name].NearDistance },
        Step = 1,
        Callback = function(v) SideSettings[SelectedSide][Name].NearDistance = v end })
    SideSection:Divider()
    SideElements[Name] = { Toggle = t, NearToggle = nt, NearSlider = ns }
end

CreateSideControl("Highlight", "Highlight",      "Glow body parts")
CreateSideControl("Box",       "2D Box",         "Screen rectangle")
CreateSideControl("Box3D",     "3D Box",         "World wireframe box")
CreateSideControl("Line",      "Snapline",       "Line from you to target")
CreateSideControl("Name",      "Name",           "Player name")
CreateSideControl("Distance",  "Distance",       "Distance in studs")
CreateSideControl("Height",    "Height",         "Character height")

--==================================================================
--  DETECTION
--==================================================================
Tabs.Detection:Paragraph({ Title = "Visibility Detection", Desc = "Control raycast behavior.", Image = "scan-search", ImageSize = 20 })
local DetSection = Tabs.Detection:Section({ Title = "Raycast", Icon = "crosshair", Opened = true, Box = true })
DetSection:Toggle({ Title = "Visibility Check", Desc = "Detect players behind walls", Value = Settings.VisibilityCheck,
    Callback = function(v) Settings.VisibilityCheck = v end })
DetSection:Toggle({ Title = "Body Part Raycast", Desc = "Check limbs individually", Value = Settings.BodyPartRaycast,
    Callback = function(v) Settings.BodyPartRaycast = v end })
DetSection:Toggle({ Title = "Automatic Fallback", Desc = "Switch to normal raycast far away", Value = Settings.BodyPartRaycastFallback,
    Callback = function(v) Settings.BodyPartRaycastFallback = v end })
DetSection:Slider({ Title = "Fallback Distance", Desc = "Distance where normal raycast starts",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.BodyPartRaycastDistance }, Step = 1,
    Callback = function(v) Settings.BodyPartRaycastDistance = v end })
DetSection:Dropdown({ Title = "Raycast Origin", Desc = "Where rays start",
    Values = { "Character", "Camera" }, Value = Settings.RayOrigin,
    Callback = function(v) Settings.RayOrigin = v end })

--==================================================================
--  TEXT
--==================================================================
Tabs.Text:Paragraph({ Title = "Text", Desc = "Name / distance / height text.", Image = "type", ImageSize = 20 })
local TextModeSection = Tabs.Text:Section({ Title = "Mode", Icon = "sliders-horizontal", Opened = true, Box = true })
TextModeSection:Dropdown({ Title = "Text Mode", Desc = "Standard or dynamic sizing",
    Values = { "Standard", "Dynamic" }, Value = Settings.TextMode,
    Callback = function(v) Settings.TextMode = v end })
TextModeSection:Dropdown({ Title = "Dynamic Mode", Desc = "Ignored in Standard mode",
    Values = { "Far Bigger", "Far Smaller" }, Value = Settings.DynamicTextMode,
    Callback = function(v) Settings.DynamicTextMode = v end })

local BasicText = Tabs.Text:Section({ Title = "Basic Size", Icon = "text-cursor-input", Opened = true, Box = true })
BasicText:Slider({ Title = "Name Size", Desc = "Standard name size",
    Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = Settings.NameSize }, Step = 1,
    Callback = function(v) Settings.NameSize = v end })
BasicText:Slider({ Title = "Distance Size", Desc = "Standard distance size",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = Settings.DistanceSize }, Step = 1,
    Callback = function(v) Settings.DistanceSize = v end })
BasicText:Slider({ Title = "Height Size", Desc = "Standard height size",
    Value = { Min = MIN_HEIGHT_SIZE, Max = MAX_HEIGHT_SIZE, Default = Settings.HeightSize }, Step = 1,
    Callback = function(v) Settings.HeightSize = v end })

local DynSection = Tabs.Text:Section({ Title = "Dynamic Size", Icon = "move-diagonal-2", Opened = true, Box = true })
DynSection:Slider({ Title = "Curve", Desc = "Controls the size transition",
    Value = { Min = MIN_TEXT_CURVE, Max = MAX_TEXT_CURVE, Default = Settings.DynamicTextCurve }, Step = 0.05,
    Callback = function(v) Settings.DynamicTextCurve = v end })
DynSection:Slider({ Title = "Name Min",  Desc = "Min dynamic name size",
    Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = Settings.NameMinSize }, Step = 1,
    Callback = function(v) Settings.NameMinSize = v end })
DynSection:Slider({ Title = "Name Max",  Desc = "Max dynamic name size",
    Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = Settings.NameMaxSize }, Step = 1,
    Callback = function(v) Settings.NameMaxSize = v end })
DynSection:Slider({ Title = "Distance Min", Desc = "Min dynamic distance size",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = Settings.DistanceMinSize }, Step = 1,
    Callback = function(v) Settings.DistanceMinSize = v end })
DynSection:Slider({ Title = "Distance Max", Desc = "Max dynamic distance size",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = Settings.DistanceMaxSize }, Step = 1,
    Callback = function(v) Settings.DistanceMaxSize = v end })
DynSection:Slider({ Title = "Height Min", Desc = "Min dynamic height size",
    Value = { Min = MIN_HEIGHT_SIZE, Max = MAX_HEIGHT_SIZE, Default = Settings.HeightMinSize }, Step = 1,
    Callback = function(v) Settings.HeightMinSize = v end })
DynSection:Slider({ Title = "Height Max", Desc = "Max dynamic height size",
    Value = { Min = MIN_HEIGHT_SIZE, Max = MAX_HEIGHT_SIZE, Default = Settings.HeightMaxSize }, Step = 1,
    Callback = function(v) Settings.HeightMaxSize = v end })

--==================================================================
--  COLORS
--==================================================================
Tabs.Colors:Paragraph({ Title = "ESP Colors", Desc = "Customize every color.", Image = "palette", ImageSize = 20 })

local ColorPickers = {}
local function CreateColorPicker(Parent, Title, Description, Key)
    local cp = Parent:Colorpicker({
        Title = Title, Desc = Description,
        Default = Colors[Key], Transparency = 0,
        Callback = function(Color)
            if typeof(Color) == "Color3" then Colors[Key] = Color end
        end,
    })
    ColorPickers[Key] = cp
end

local C_HL = Tabs.Colors:Section({ Title = "Highlight", Icon = "eye", Opened = true, Box = true })
CreateColorPicker(C_HL, "Enemy Visible",       "Visible enemy",        "EnemyVisible")
CreateColorPicker(C_HL, "Enemy Behind Wall",   "Hidden enemy",         "EnemyHidden")
CreateColorPicker(C_HL, "Teammate Visible",    "Visible teammate",     "TeamVisible")
CreateColorPicker(C_HL, "Teammate Behind Wall","Hidden teammate",      "TeamHidden")

local C_TX = Tabs.Colors:Section({ Title = "Text", Icon = "type", Opened = true, Box = true })
CreateColorPicker(C_TX, "Enemy Name",       "Enemy name",       "EnemyName")
CreateColorPicker(C_TX, "Teammate Name",    "Teammate name",    "TeamName")
CreateColorPicker(C_TX, "Enemy Distance",   "Enemy distance",   "EnemyDistance")
CreateColorPicker(C_TX, "Teammate Distance","Teammate distance","TeamDistance")
CreateColorPicker(C_TX, "Enemy Height",     "Enemy height",     "EnemyHeight")
CreateColorPicker(C_TX, "Teammate Height",  "Teammate height",  "TeamHeight")

local C_BX = Tabs.Colors:Section({ Title = "2D Boxes", Icon = "square", Opened = true, Box = true })
CreateColorPicker(C_BX, "Enemy Visible",       "Visible enemy box",      "EnemyBoxVisible")
CreateColorPicker(C_BX, "Enemy Behind Wall",   "Hidden enemy box",       "EnemyBoxHidden")
CreateColorPicker(C_BX, "Teammate Visible",    "Visible teammate box",   "TeamBoxVisible")
CreateColorPicker(C_BX, "Teammate Behind Wall","Hidden teammate box",    "TeamBoxHidden")
CreateColorPicker(C_BX, "Group Box",           "Merged cluster box",     "GroupBox")
CreateColorPicker(C_BX, "Group Label",         "Cluster count text",     "GroupLabel")

local C_3D = Tabs.Colors:Section({ Title = "3D Boxes", Icon = "box", Opened = true, Box = true })
CreateColorPicker(C_3D, "Enemy Visible",       "Visible enemy 3D box",    "EnemyBox3DVisible")
CreateColorPicker(C_3D, "Enemy Behind Wall",   "Hidden enemy 3D box",     "EnemyBox3DHidden")
CreateColorPicker(C_3D, "Teammate Visible",    "Visible teammate 3D box", "TeamBox3DVisible")
CreateColorPicker(C_3D, "Teammate Behind Wall","Hidden teammate 3D box",  "TeamBox3DHidden")

local C_LN = Tabs.Colors:Section({ Title = "Snaplines", Icon = "move-diagonal", Opened = true, Box = true })
CreateColorPicker(C_LN, "Enemy Visible",       "Visible enemy line",    "EnemyLineVisible")
CreateColorPicker(C_LN, "Enemy Behind Wall",   "Hidden enemy line",     "EnemyLineHidden")
CreateColorPicker(C_LN, "Teammate Visible",    "Visible teammate line", "TeamLineVisible")
CreateColorPicker(C_LN, "Teammate Behind Wall","Hidden teammate line",  "TeamLineHidden")

--==================================================================
--  INTERFACE  /  RESET
--==================================================================
Tabs.Interface:Paragraph({ Title = "Interface", Desc = "Theme and full reset.", Image = "settings", ImageSize = 20 })

local AppSection = Tabs.Interface:Section({ Title = "Appearance", Icon = "palette", Opened = true, Box = true })
local Themes = {}
for ThemeName in pairs(WindUI:GetThemes()) do table.insert(Themes, ThemeName) end
table.sort(Themes)
local ThemeDropdown = AppSection:Dropdown({
    Title = "Theme", Desc = "Interface theme",
    Values = Themes, Value = "Dark",
    SearchBarEnabled = true, MenuWidth = 280,
    Callback = function(t) if t then WindUI:SetTheme(t) end end,
})
AppSection:Button({ Title = "Reset Theme", Desc = "Return to Dark", Icon = "rotate-ccw",
    Callback = function()
        WindUI:SetTheme("Dark")
        SetElement(ThemeDropdown, "Dark")
    end,
})

local ResetSection = Tabs.Interface:Section({ Title = "Reset All", Icon = "refresh-cw", Opened = true, Box = true })
ResetSection:Paragraph({ Title = "Complete Reset", Desc = "Restore settings, profiles, colors and theme.", Image = "info", ImageSize = 18 })
ResetSection:Divider()
ResetSection:Button({ Title = "Reset All", Desc = "Restore the complete configuration", Icon = "refresh-cw",
    Callback = function()
        ResetSettings()
        ResetColors()
        ResetSideSettings()
        for _, Data in pairs(ESPObjects) do
            ClearHighlights(Data)
            HideBox3D(Data)
            Data.HighlightMode = nil
            Data.Visibility = nil
        end
        WindUI:SetTheme("Dark")
        SetElement(ThemeDropdown, "Dark")
        SetElement(T_ESP, Settings.ESP)
        SetElement(SideDropdown, SelectedSide)
        RefreshSideUI()
        WindUI:Notify({ Title = "Everything Reset", Content = "All settings restored", Icon = "check", Duration = 2 })
    end,
})

--==================================================================
--  BOOT + LOOP
--==================================================================
for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then CreateESP(Player) end
end
Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then CreateESP(Player) end
end)
Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
end)

local Timer = 0
local ScanTimer = 0
local UPDATE_INTERVAL = 0.05

RunService.RenderStepped:Connect(function(Delta)
    Timer += Delta
    ScanTimer += Delta

    if ScanTimer >= 1 then
        ScanTimer = 0
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and not ESPObjects[Player] then
                CreateESP(Player)
            end
        end
    end

    if Timer < UPDATE_INTERVAL then return end
    Timer = 0

    UpdateHighlightBudget()
    for i = #BoxCandidates, 1, -1 do BoxCandidates[i] = nil end

    for Player, Data in pairs(ESPObjects) do
        if Player.Parent == Players then
            UpdateESP(Player, Data)
        else
            RemoveESP(Player)
        end
    end

    UpdateClusters()
end)