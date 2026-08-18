-- ═══════════════════════════════════════════════════════════
-- PLAYER ESP — Enhanced Edition v2
-- 2D Boxes · 3D Boxes · Tracers · Height · Animated Box Grouping
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Drawing API check
local HasDrawing = false
pcall(function()
    local test = Drawing.new("Line")
    pcall(function() test:Remove() end)
    HasDrawing = true
end)

-- ═══════════════════════════════════════════════════════════
-- CONSTANTS
-- ═══════════════════════════════════════════════════════════

local MIN_DISTANCE = 50
local MAX_DISTANCE = 2000
local DEFAULT_DISTANCE = 1000

local MIN_NAME_SIZE = 8
local MAX_NAME_SIZE = 24
local DEFAULT_NAME_SIZE = 14

local MIN_DISTANCE_SIZE = 6
local MAX_DISTANCE_SIZE = 18
local DEFAULT_DISTANCE_SIZE = 10

local MIN_NEAR_DISTANCE = 0
local MAX_NEAR_DISTANCE = 1000

local MIN_TEXT_CURVE = 0.25
local MAX_TEXT_CURVE = 4
local DEFAULT_TEXT_CURVE = 1

local MAX_HIGHLIGHT_BUDGET = 240

local MIN_THICKNESS = 1
local MAX_THICKNESS = 4
local DEFAULT_THICKNESS = 1

local LERP_FACTOR = 0.15

-- 3D box edges (12 edges connecting 8 corners)
local EDGES_3D = {
    {1, 2}, {2, 4}, {4, 3}, {3, 1},
    {5, 6}, {6, 8}, {8, 7}, {7, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8},
}

-- ═══════════════════════════════════════════════════════════
-- COLORS
-- ═══════════════════════════════════════════════════════════

local DEFAULT_COLORS = {
    EnemyVisible = Color3.fromRGB(70, 255, 100),
    EnemyHidden = Color3.fromRGB(255, 60, 60),
    TeamVisible = Color3.fromRGB(255, 235, 50),
    TeamHidden = Color3.fromRGB(255, 145, 30),

    EnemyName = Color3.fromRGB(255, 255, 255),
    TeamName = Color3.fromRGB(255, 255, 255),
    EnemyDistance = Color3.fromRGB(220, 220, 220),
    TeamDistance = Color3.fromRGB(220, 220, 220),

    EnemyBoxVisible = Color3.fromRGB(70, 255, 100),
    EnemyBoxHidden = Color3.fromRGB(255, 60, 60),
    TeamBoxVisible = Color3.fromRGB(255, 235, 50),
    TeamBoxHidden = Color3.fromRGB(255, 145, 30),

    EnemyTracerVisible = Color3.fromRGB(70, 255, 100),
    EnemyTracerHidden = Color3.fromRGB(255, 60, 60),
    TeamTracerVisible = Color3.fromRGB(255, 235, 50),
    TeamTracerHidden = Color3.fromRGB(255, 145, 30),

    GroupCount = Color3.fromRGB(255, 255, 255),
}

local Colors = {}

local function ResetColors()
    for Name, Color in pairs(DEFAULT_COLORS) do
        Colors[Name] = Color
    end
end
ResetColors()

-- ═══════════════════════════════════════════════════════════
-- SETTINGS
-- ═══════════════════════════════════════════════════════════

local DEFAULT_SETTINGS = {
    ESP = true,
    VisibilityCheck = true,
    BodyPartRaycast = true,
    BodyPartRaycastFallback = false,
    TeamCheck = true,

    ShowName = true,
    ShowDistance = true,
    ShowHeight = false,

    Highlight = true,
    Boxes = true,
    Box3D = false,
    Tracers = false,
    BoxGrouping = true,

    ESPDistance = DEFAULT_DISTANCE,
    HighlightDistance = DEFAULT_DISTANCE,
    BoxDistance = DEFAULT_DISTANCE,
    Box3DDistance = DEFAULT_DISTANCE,
    TracerDistance = DEFAULT_DISTANCE,
    BodyPartRaycastDistance = 500,

    NameSize = DEFAULT_NAME_SIZE,
    DistanceSize = DEFAULT_DISTANCE_SIZE,
    HeightSize = DEFAULT_DISTANCE_SIZE,

    TextMode = "Standard",
    DynamicTextMode = "Far Bigger",
    DynamicTextCurve = DEFAULT_TEXT_CURVE,

    NameMinSize = MIN_NAME_SIZE,
    NameMaxSize = MAX_NAME_SIZE,
    DistanceMinSize = MIN_DISTANCE_SIZE,
    DistanceMaxSize = MAX_DISTANCE_SIZE,

    BoxMode = "Accurate",
    RayOrigin = "Character",
    TracerOrigin = "Bottom",
    TracerThickness = DEFAULT_THICKNESS,
    Box3DThickness = DEFAULT_THICKNESS,
}

local Settings = {}

local function ResetSettings()
    for Name, Value in pairs(DEFAULT_SETTINGS) do
        Settings[Name] = Value
    end
end
ResetSettings()

-- ═══════════════════════════════════════════════════════════
-- SIDE SETTINGS
-- ═══════════════════════════════════════════════════════════

local DEFAULT_SIDE_SETTINGS = {
    Highlight = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Box       = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Box3D     = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Tracer    = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Name      = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Distance  = { Enabled = true, NearDisable = false, NearDistance = 100 },
    Height    = { Enabled = true, NearDisable = false, NearDistance = 100 },
}

local function CopySideSettings()
    local Result = {}
    for Name, Data in pairs(DEFAULT_SIDE_SETTINGS) do
        Result[Name] = {
            Enabled = Data.Enabled,
            NearDisable = Data.NearDisable,
            NearDistance = Data.NearDistance,
        }
    end
    return Result
end

local SideSettings = {
    Enemy = CopySideSettings(),
    Teammate = CopySideSettings(),
}

local function ResetSideSettings()
    SideSettings.Enemy = CopySideSettings()
    SideSettings.Teammate = CopySideSettings()
end

-- ═══════════════════════════════════════════════════════════
-- FORWARD DECLARATIONS
-- ═══════════════════════════════════════════════════════════

local ClearHighlights
local Update3DBox
local UpdateTracer

-- ═══════════════════════════════════════════════════════════
-- ESP OBJECTS
-- ═══════════════════════════════════════════════════════════

local ESPObjects = {}

-- ═══════════════════════════════════════════════════════════
-- WINDUI WINDOW
-- ═══════════════════════════════════════════════════════════

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "PLAYER ESP",
    Icon = "eye",
    Author = "Enhanced ESP v2",
    Folder = "PlayerESP",
    Size = UDim2.fromOffset(560, 480),
    MinSize = Vector2.new(390, 330),
    MaxSize = Vector2.new(900, 720),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

local Sections = {
    About = Window:Section({ Title = "ABOUT", Opened = true }),
    Features = Window:Section({ Title = "FEATURES", Opened = true }),
    Config = Window:Section({ Title = "CONFIG", Opened = true }),
}

local Tabs = {
    About = Sections.About:Tab({ Title = "About", Icon = "house", Desc = "Features and tips" }),
    ESP = Sections.Features:Tab({ Title = "ESP", Icon = "eye", Desc = "Main ESP features and distances" }),
    Detection = Sections.Features:Tab({ Title = "Detection", Icon = "scan-search", Desc = "Visibility and raycast" }),
    Profiles = Sections.Features:Tab({ Title = "Profiles", Icon = "users", Desc = "Enemy and teammate settings" }),
    Text = Sections.Config:Tab({ Title = "Text", Icon = "type", Desc = "Text appearance and sizing" }),
    Colors = Sections.Config:Tab({ Title = "Colors", Icon = "palette", Desc = "All ESP colors" }),
    Settings = Sections.Config:Tab({ Title = "Settings", Icon = "settings", Desc = "Theme and reset" }),
}

-- ═══════════════════════════════════════════════════════════
-- ABOUT TAB
-- ═══════════════════════════════════════════════════════════

Tabs.About:Paragraph({
    Title = "PLAYER ESP",
    Desc = "Enhanced player visualization with 2D/3D boxes, tracers, height and animated grouping",
    Image = "eye", ImageSize = 26,
})

local AboutFeatures = Tabs.About:Section({ Title = "Features", Icon = "info", Opened = true, Box = true })

AboutFeatures:Paragraph({ Title = "2D Boxes", Desc = "Screen-space rectangles with Performance and Accurate modes.", Image = "square", ImageSize = 18 })
AboutFeatures:Paragraph({ Title = "3D Boxes", Desc = "Wireframe cubes projected from the character root. Requires Drawing API.", Image = "box", ImageSize = 18 })
AboutFeatures:Paragraph({ Title = "Tracers", Desc = "Lines from screen bottom, center, or your character to each player.", Image = "move", ImageSize = 18 })
AboutFeatures:Paragraph({ Title = "Height", Desc = "Shows each player Y coordinate elevation.", Image = "move-vertical", ImageSize = 18 })
AboutFeatures:Paragraph({ Title = "Box Grouping", Desc = "Overlapping 2D boxes smoothly animate into one merged box with a player count label.", Image = "group", ImageSize = 18 })
AboutFeatures:Paragraph({ Title = "Detection", Desc = "Body-part or normal raycasting with selectable origin and automatic fallback.", Image = "scan-search", ImageSize = 18 })
AboutFeatures:Paragraph({ Title = "Profiles", Desc = "Independent enemy and teammate settings for every ESP element.", Image = "users", ImageSize = 18 })

local AboutTips = Tabs.About:Section({ Title = "Tips", Icon = "lightbulb", Opened = true, Box = true })
AboutTips:Paragraph({ Title = "Performance", Desc = "Use Performance box mode and lower highlight distance on mobile for better FPS.", Image = "zap", ImageSize = 18 })
AboutTips:Paragraph({ Title = "Profiles", Desc = "Switch between Enemy and Teammate profiles to configure each side independently.", Image = "users", ImageSize = 18 })
AboutTips:Paragraph({ Title = "Dynamic Text", Desc = "Dynamic mode scales text based on distance.", Image = "move-diagonal-2", ImageSize = 18 })

-- ═══════════════════════════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════════════════════════

local ESPSection = Tabs.ESP:Section({ Title = "Features", Icon = "scan", Opened = true, Box = true })

ESPSection:Toggle({ Title = "ESP", Desc = "Master toggle", Value = Settings.ESP, Callback = function(V) Settings.ESP = V end })
ESPSection:Toggle({ Title = "Names", Desc = "Show player display names", Value = Settings.ShowName, Callback = function(V) Settings.ShowName = V end })
ESPSection:Toggle({ Title = "Distance", Desc = "Show distance in studs", Value = Settings.ShowDistance, Callback = function(V) Settings.ShowDistance = V end })
ESPSection:Toggle({ Title = "Height", Desc = "Show player Y-coordinate", Value = Settings.ShowHeight, Callback = function(V) Settings.ShowHeight = V end })
ESPSection:Toggle({ Title = "Highlight", Desc = "Highlight body parts", Value = Settings.Highlight, Callback = function(V) Settings.Highlight = V end })
ESPSection:Toggle({ Title = "2D Boxes", Desc = "Screen-space rectangles", Value = Settings.Boxes, Callback = function(V) Settings.Boxes = V end })
ESPSection:Toggle({ Title = "3D Boxes", Desc = "3D wireframe cubes (requires Drawing API)", Value = Settings.Box3D, Callback = function(V) Settings.Box3D = V end })
ESPSection:Toggle({ Title = "Tracers", Desc = "Lines from screen origin to players", Value = Settings.Tracers, Callback = function(V) Settings.Tracers = V end })
ESPSection:Toggle({ Title = "Box Grouping", Desc = "Merge overlapping 2D boxes with smooth animation and count label", Value = Settings.BoxGrouping, Callback = function(V) Settings.BoxGrouping = V end })
ESPSection:Toggle({ Title = "Team Check", Desc = "Separate enemies and teammates", Value = Settings.TeamCheck, Callback = function(V) Settings.TeamCheck = V end })

local DistanceSection = Tabs.ESP:Section({ Title = "Distances", Icon = "maximize", Opened = true, Box = true })

DistanceSection:Slider({ Title = "Text Distance", Desc = "Max distance for text", Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE }, Step = 1, Callback = function(V) Settings.ESPDistance = V end })
DistanceSection:Slider({ Title = "Highlight Distance", Desc = "Max highlight distance", Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE }, Step = 1, Callback = function(V) Settings.HighlightDistance = V end })
DistanceSection:Slider({ Title = "2D Box Distance", Desc = "Max 2D box distance", Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE }, Step = 1, Callback = function(V) Settings.BoxDistance = V end })
DistanceSection:Slider({ Title = "3D Box Distance", Desc = "Max 3D box distance", Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE }, Step = 1, Callback = function(V) Settings.Box3DDistance = V end })
DistanceSection:Slider({ Title = "Tracer Distance", Desc = "Max tracer distance", Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE }, Step = 1, Callback = function(V) Settings.TracerDistance = V end })

local AppearanceSection = Tabs.ESP:Section({ Title = "Box & Tracer Appearance", Icon = "sliders-horizontal", Opened = true, Box = true })

AppearanceSection:Dropdown({ Title = "2D Box Mode", Desc = "Performance: fast. Accurate: precise per-limb.", Values = { "Performance", "Accurate" }, Value = Settings.BoxMode, Callback = function(V) Settings.BoxMode = V end })
AppearanceSection:Dropdown({ Title = "Tracer Origin", Desc = "Where tracer lines start", Values = { "Bottom", "Center", "Player" }, Value = Settings.TracerOrigin, Callback = function(V) Settings.TracerOrigin = V end })
AppearanceSection:Slider({ Title = "3D Box Thickness", Desc = "Line thickness", Value = { Min = MIN_THICKNESS, Max = MAX_THICKNESS, Default = DEFAULT_THICKNESS }, Step = 1, Callback = function(V) Settings.Box3DThickness = V end })
AppearanceSection:Slider({ Title = "Tracer Thickness", Desc = "Line thickness", Value = { Min = MIN_THICKNESS, Max = MAX_THICKNESS, Default = DEFAULT_THICKNESS }, Step = 1, Callback = function(V) Settings.TracerThickness = V end })

local ESPResetSection = Tabs.ESP:Section({ Title = "Reset", Icon = "rotate-ccw", Opened = true, Box = true })
ESPResetSection:Divider()
ESPResetSection:Button({
    Title = "Reset ESP", Desc = "Restore ESP features and distances", Icon = "rotate-ccw",
    Callback = function()
        for _, Key in ipairs({ "ESP", "ShowName", "ShowDistance", "ShowHeight", "Highlight", "Boxes", "Box3D", "Tracers", "BoxGrouping", "TeamCheck", "ESPDistance", "HighlightDistance", "BoxDistance", "Box3DDistance", "TracerDistance", "BoxMode", "TracerOrigin", "TracerThickness", "Box3DThickness" }) do
            Settings[Key] = DEFAULT_SETTINGS[Key]
        end
        WindUI:Notify({ Title = "ESP Reset", Content = "ESP settings restored", Icon = "check", Duration = 2 })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- DETECTION TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Detection:Paragraph({ Title = "Visibility Detection", Desc = "Control how ESP determines visibility.", Image = "scan-search", ImageSize = 20 })

local DetectionSection = Tabs.Detection:Section({ Title = "Raycast", Icon = "crosshair", Opened = true, Box = true })

DetectionSection:Toggle({ Title = "Visibility Check", Desc = "Check players behind walls", Value = Settings.VisibilityCheck, Callback = function(V) Settings.VisibilityCheck = V end })
DetectionSection:Toggle({ Title = "Body Part Raycast", Desc = "Check body parts individually", Value = Settings.BodyPartRaycast, Callback = function(V) Settings.BodyPartRaycast = V end })
DetectionSection:Toggle({ Title = "Automatic Fallback", Desc = "Switch to normal raycast at long distances", Value = Settings.BodyPartRaycastFallback, Callback = function(V) Settings.BodyPartRaycastFallback = V end })
DetectionSection:Slider({ Title = "Fallback Distance", Desc = "Distance where normal raycast starts", Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.BodyPartRaycastDistance }, Step = 1, Callback = function(V) Settings.BodyPartRaycastDistance = V end })
DetectionSection:Dropdown({ Title = "Raycast Origin", Desc = "Where rays start", Values = { "Character", "Camera" }, Value = Settings.RayOrigin, Callback = function(V) Settings.RayOrigin = V end })

local DetectionResetSection = Tabs.Detection:Section({ Title = "Reset", Icon = "rotate-ccw", Opened = true, Box = true })
DetectionResetSection:Divider()
DetectionResetSection:Button({
    Title = "Reset Detection", Desc = "Restore detection settings", Icon = "rotate-ccw",
    Callback = function()
        for _, Key in ipairs({ "VisibilityCheck", "BodyPartRaycast", "BodyPartRaycastFallback", "BodyPartRaycastDistance", "RayOrigin" }) do
            Settings[Key] = DEFAULT_SETTINGS[Key]
        end
        WindUI:Notify({ Title = "Detection Reset", Content = "Restored", Icon = "check", Duration = 2 })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- PROFILES TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Profiles:Paragraph({ Title = "Side Profiles", Desc = "Configure enemy and teammate ESP independently.", Image = "users", ImageSize = 20 })

local SelectedSide = "Enemy"
local SideControls = {}

local function RefreshSideControls()
    local side = SideSettings[SelectedSide]
    for feature, controls in pairs(SideControls) do
        local data = side[feature]
        if data then
            if controls.Enabled then pcall(function() controls.Enabled:Set(data.Enabled) end) end
            if controls.NearDisable then pcall(function() controls.NearDisable:Set(data.NearDisable) end) end
            if controls.NearDistance then pcall(function() controls.NearDistance:Set(data.NearDistance) end) end
        end
    end
end

Tabs.Profiles:Dropdown({
    Title = "Active Profile", Desc = "Select which side to configure",
    Values = { "Enemy", "Teammate" }, Value = SelectedSide,
    Callback = function(V) SelectedSide = V; RefreshSideControls() end,
})

local SideSection = Tabs.Profiles:Section({ Title = "Elements", Icon = "layers-3", Opened = true, Box = true })

local function CreateSideControl(Name, Title, Description)
    SideControls[Name] = {}
    SideControls[Name].Enabled = SideSection:Toggle({
        Title = Title, Desc = Description, Value = SideSettings.Enemy[Name].Enabled,
        Callback = function(V) SideSettings[SelectedSide][Name].Enabled = V end,
    })
    SideControls[Name].NearDisable = SideSection:Toggle({
        Title = "Disable " .. Title .. " Near", Desc = "Hide at close range", Value = SideSettings.Enemy[Name].NearDisable,
        Callback = function(V) SideSettings[SelectedSide][Name].NearDisable = V end,
    })
    SideControls[Name].NearDistance = SideSection:Slider({
        Title = Title .. " Near Distance", Desc = "Disable below this distance",
        Value = { Min = MIN_NEAR_DISTANCE, Max = MAX_NEAR_DISTANCE, Default = SideSettings.Enemy[Name].NearDistance },
        Step = 1, Callback = function(V) SideSettings[SelectedSide][Name].NearDistance = V end,
    })
    SideSection:Divider()
end

CreateSideControl("Highlight", "Highlight", "Body part highlight")
CreateSideControl("Box", "2D Box", "Screen-space rectangle")
CreateSideControl("Box3D", "3D Box", "3D wireframe cube")
CreateSideControl("Tracer", "Tracer", "Line to player")
CreateSideControl("Name", "Name", "Player name")
CreateSideControl("Distance", "Distance", "Distance in studs")
CreateSideControl("Height", "Height", "Y-coordinate")

local ProfilesResetSection = Tabs.Profiles:Section({ Title = "Reset", Icon = "rotate-ccw", Opened = true, Box = true })
ProfilesResetSection:Divider()
ProfilesResetSection:Button({
    Title = "Reset Profiles", Desc = "Restore both profiles", Icon = "rotate-ccw",
    Callback = function() ResetSideSettings(); RefreshSideControls(); WindUI:Notify({ Title = "Profiles Reset", Content = "Restored", Icon = "check", Duration = 2 }) end,
})

-- ═══════════════════════════════════════════════════════════
-- TEXT TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Text:Paragraph({ Title = "Text Settings", Desc = "Configure text appearance.", Image = "type", ImageSize = 20 })

local TextModeSection = Tabs.Text:Section({ Title = "Mode", Icon = "sliders-horizontal", Opened = true, Box = true })
TextModeSection:Dropdown({ Title = "Text Mode", Desc = "Standard or Dynamic sizing", Values = { "Standard", "Dynamic" }, Value = Settings.TextMode, Callback = function(V) Settings.TextMode = V end })
TextModeSection:Dropdown({ Title = "Dynamic Mode", Desc = "Far Bigger or Far Smaller", Values = { "Far Bigger", "Far Smaller" }, Value = Settings.DynamicTextMode, Callback = function(V) Settings.DynamicTextMode = V end })

local BasicTextSection = Tabs.Text:Section({ Title = "Standard Sizes", Icon = "text-cursor-input", Opened = true, Box = true })
BasicTextSection:Slider({ Title = "Name Size", Desc = "Font size", Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = DEFAULT_NAME_SIZE }, Step = 1, Callback = function(V) Settings.NameSize = V end })
BasicTextSection:Slider({ Title = "Distance Size", Desc = "Font size", Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = DEFAULT_DISTANCE_SIZE }, Step = 1, Callback = function(V) Settings.DistanceSize = V end })
BasicTextSection:Slider({ Title = "Height Size", Desc = "Font size", Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = DEFAULT_DISTANCE_SIZE }, Step = 1, Callback = function(V) Settings.HeightSize = V end })

local DynamicSection = Tabs.Text:Section({ Title = "Dynamic Size", Icon = "move-diagonal-2", Opened = true, Box = true })
DynamicSection:Slider({ Title = "Curve", Desc = "Size transition aggressiveness", Value = { Min = MIN_TEXT_CURVE, Max = MAX_TEXT_CURVE, Default = DEFAULT_TEXT_CURVE }, Step = 0.05, Callback = function(V) Settings.DynamicTextCurve = V end })
DynamicSection:Slider({ Title = "Name Minimum", Desc = "Min dynamic name size", Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = MIN_NAME_SIZE }, Step = 1, Callback = function(V) Settings.NameMinSize = V end })
DynamicSection:Slider({ Title = "Name Maximum", Desc = "Max dynamic name size", Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = MAX_NAME_SIZE }, Step = 1, Callback = function(V) Settings.NameMaxSize = V end })
DynamicSection:Slider({ Title = "Distance Minimum", Desc = "Min dynamic distance size", Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = MIN_DISTANCE_SIZE }, Step = 1, Callback = function(V) Settings.DistanceMinSize = V end })
DynamicSection:Slider({ Title = "Distance Maximum", Desc = "Max dynamic distance size", Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = MAX_DISTANCE_SIZE }, Step = 1, Callback = function(V) Settings.DistanceMaxSize = V end })

local TextResetSection = Tabs.Text:Section({ Title = "Reset", Icon = "rotate-ccw", Opened = true, Box = true })
TextResetSection:Divider()
TextResetSection:Button({
    Title = "Reset Text", Desc = "Restore text settings", Icon = "rotate-ccw",
    Callback = function()
        for _, Key in ipairs({ "NameSize", "DistanceSize", "HeightSize", "TextMode", "DynamicTextMode", "DynamicTextCurve", "NameMinSize", "NameMaxSize", "DistanceMinSize", "DistanceMaxSize" }) do
            Settings[Key] = DEFAULT_SETTINGS[Key]
        end
        WindUI:Notify({ Title = "Text Reset", Content = "Restored", Icon = "check", Duration = 2 })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- COLORS TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Colors:Paragraph({ Title = "ESP Colors", Desc = "3D boxes share 2D box colors.", Image = "palette", ImageSize = 20 })

local function CreateColorPicker(Parent, Title, Description, Key)
    Parent:Colorpicker({ Title = Title, Desc = Description, Default = Colors[Key], Transparency = 0, Callback = function(C) if typeof(C) == "Color3" then Colors[Key] = C end end })
end

local HighlightColors = Tabs.Colors:Section({ Title = "Highlight", Icon = "eye", Opened = true, Box = true })
CreateColorPicker(HighlightColors, "Enemy Visible", "Visible enemy", "EnemyVisible")
CreateColorPicker(HighlightColors, "Enemy Behind Wall", "Hidden enemy", "EnemyHidden")
CreateColorPicker(HighlightColors, "Teammate Visible", "Visible teammate", "TeamVisible")
CreateColorPicker(HighlightColors, "Teammate Behind Wall", "Hidden teammate", "TeamHidden")

local TextColors = Tabs.Colors:Section({ Title = "Text", Icon = "type", Opened = true, Box = true })
CreateColorPicker(TextColors, "Enemy Name", "Enemy name", "EnemyName")
CreateColorPicker(TextColors, "Teammate Name", "Teammate name", "TeamName")
CreateColorPicker(TextColors, "Enemy Distance", "Enemy distance", "EnemyDistance")
CreateColorPicker(TextColors, "Teammate Distance", "Teammate distance", "TeamDistance")

local BoxColors = Tabs.Colors:Section({ Title = "2D & 3D Boxes", Icon = "square", Opened = true, Box = true })
CreateColorPicker(BoxColors, "Enemy Visible", "Visible enemy box", "EnemyBoxVisible")
CreateColorPicker(BoxColors, "Enemy Behind Wall", "Hidden enemy box", "EnemyBoxHidden")
CreateColorPicker(BoxColors, "Teammate Visible", "Visible teammate box", "TeamBoxVisible")
CreateColorPicker(BoxColors, "Teammate Behind Wall", "Hidden teammate box", "TeamBoxHidden")

local TracerColors = Tabs.Colors:Section({ Title = "Tracers", Icon = "move", Opened = true, Box = true })
CreateColorPicker(TracerColors, "Enemy Visible", "Visible enemy tracer", "EnemyTracerVisible")
CreateColorPicker(TracerColors, "Enemy Behind Wall", "Hidden enemy tracer", "EnemyTracerHidden")
CreateColorPicker(TracerColors, "Teammate Visible", "Visible teammate tracer", "TeamTracerVisible")
CreateColorPicker(TracerColors, "Teammate Behind Wall", "Hidden teammate tracer", "TeamTracerHidden")

local MiscColors = Tabs.Colors:Section({ Title = "Misc", Icon = "settings-2", Opened = true, Box = true })
CreateColorPicker(MiscColors, "Group Count", "Box grouping count label color", "GroupCount")

local ColorsResetSection = Tabs.Colors:Section({ Title = "Reset", Icon = "rotate-ccw", Opened = true, Box = true })
ColorsResetSection:Divider()
ColorsResetSection:Button({ Title = "Reset Colors", Desc = "Restore all colors", Icon = "rotate-ccw", Callback = function() ResetColors(); WindUI:Notify({ Title = "Colors Reset", Content = "Restored", Icon = "check", Duration = 2 }) end })

-- ═══════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Settings:Paragraph({ Title = "Interface", Desc = "Theme and reset.", Image = "settings", ImageSize = 20 })

local AppearanceTabSection = Tabs.Settings:Section({ Title = "Appearance", Icon = "palette", Opened = true, Box = true })

local Themes = {}
for ThemeName in pairs(WindUI:GetThemes()) do table.insert(Themes, ThemeName) end
table.sort(Themes)

local ThemeDropdown = AppearanceTabSection:Dropdown({ Title = "Theme", Desc = "Interface color theme", Values = Themes, Value = "Dark", SearchBarEnabled = true, MenuWidth = 280, Callback = function(T) if T then WindUI:SetTheme(T) end end })

AppearanceTabSection:Button({ Title = "Reset Theme", Desc = "Return to Dark", Icon = "rotate-ccw", Callback = function() WindUI:SetTheme("Dark"); if ThemeDropdown and ThemeDropdown.Select then ThemeDropdown:Select("Dark") end end })

local ResetAllSection = Tabs.Settings:Section({ Title = "Complete Reset", Icon = "refresh-cw", Opened = true, Box = true })
ResetAllSection:Paragraph({ Title = "Reset Everything", Desc = "Restore all settings to defaults.", Image = "info", ImageSize = 18 })
ResetAllSection:Divider()
ResetAllSection:Button({
    Title = "Reset All", Desc = "Restore the complete configuration", Icon = "refresh-cw",
    Callback = function()
        ResetSettings(); ResetColors(); ResetSideSettings(); RefreshSideControls()
        for _, Data in pairs(ESPObjects) do
            ClearHighlights(Data)
            Data.HighlightMode = nil; Data.Visibility = nil; Data.DisplayBounds = nil
        end
        WindUI:SetTheme("Dark")
        if ThemeDropdown and ThemeDropdown.Select then ThemeDropdown:Select("Dark") end
        WindUI:Notify({ Title = "Everything Reset", Content = "All settings restored", Icon = "check", Duration = 2 })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- ESP GUI
-- ═══════════════════════════════════════════════════════════

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

local CountLabelPool = {}

local function GetCountLabel()
    for _, label in ipairs(CountLabelPool) do
        if not label.Visible then return label end
    end
    local label = Instance.new("TextLabel")
    label.Name = "GroupCount"
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.3
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.Visible = false
    label.ZIndex = 11
    label.Parent = ESPGui
    CountLabelPool[#CountLabelPool + 1] = label
    return label
end

-- ═══════════════════════════════════════════════════════════
-- BODY PART NAMES
-- ═══════════════════════════════════════════════════════════

local BodyPartNames = {
    "Head", "UpperTorso", "LowerTorso", "Torso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
    "Left Arm", "Right Arm", "Left Leg", "Right Leg",
    "HumanoidRootPart",
}

-- ═══════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function GetCharacter(Player)
    local Character = Player.Character
    if Character and Character.Parent then return Character end
    return nil
end

local function GetRoot(Character)
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function GetSide(Player)
    if Settings.TeamCheck and LocalPlayer.Team and Player.Team and LocalPlayer.Team == Player.Team then
        return "Teammate"
    end
    return "Enemy"
end

local function IsFeatureEnabled(Side, Feature, Distance)
    local Data = SideSettings[Side][Feature]
    if not Data or not Data.Enabled then return false end
    if Data.NearDisable and Distance <= Data.NearDistance then return false end
    return true
end

local function GetBodyParts(Character)
    local Parts = {}
    for _, Name in ipairs(BodyPartNames) do
        local Part = Character:FindFirstChild(Name)
        if Part and Part:IsA("BasePart") then Parts[#Parts + 1] = Part end
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
    if not Origin then return { AnyVisible = false, Parts = {}, UseBodyParts = false } end
    local Parts = GetBodyParts(Character)
    local UseBodyParts = Settings.BodyPartRaycast
        and (not Settings.BodyPartRaycastFallback or Distance <= Settings.BodyPartRaycastDistance)
    if not UseBodyParts then
        local Root = GetRoot(Character)
        if not Root then return { AnyVisible = false, Parts = {}, UseBodyParts = false } end
        local Visible = IsPartVisible(Character, Root, Origin)
        return { AnyVisible = Visible, Parts = { [Root] = Visible }, UseBodyParts = false }
    end
    local VisibleParts = {}
    local AnyVisible = false
    for _, Part in ipairs(Parts) do
        local Visible = IsPartVisible(Character, Part, Origin)
        VisibleParts[Part] = Visible
        if Visible then AnyVisible = true end
    end
    return { AnyVisible = AnyVisible, Parts = VisibleParts, UseBodyParts = true }
end

-- Color functions
local function GetHighlightColor(Player, Visible)
    if GetSide(Player) == "Teammate" then return Visible and Colors.TeamVisible or Colors.TeamHidden end
    return Visible and Colors.EnemyVisible or Colors.EnemyHidden
end
local function GetNameColor(Player) return GetSide(Player) == "Teammate" and Colors.TeamName or Colors.EnemyName end
local function GetDistanceColor(Player) return GetSide(Player) == "Teammate" and Colors.TeamDistance or Colors.EnemyDistance end
local function GetBoxColor(Player, Visible)
    if GetSide(Player) == "Teammate" then return Visible and Colors.TeamBoxVisible or Colors.TeamBoxHidden end
    return Visible and Colors.EnemyBoxVisible or Colors.EnemyBoxHidden
end
local function GetTracerColor(Player, Visible)
    if GetSide(Player) == "Teammate" then return Visible and Colors.TeamTracerVisible or Colors.TeamTracerHidden end
    return Visible and Colors.EnemyTracerVisible or Colors.EnemyTracerHidden
end
local function GetHeightColor(Player) return GetDistanceColor(Player) end

-- Dynamic text sizing
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
local function GetNameSize(Distance) return GetDynamicSize(Distance, Settings.NameMinSize, Settings.NameMaxSize) or Settings.NameSize end
local function GetDistanceSize(Distance) return GetDynamicSize(Distance, Settings.DistanceMinSize, Settings.DistanceMaxSize) or Settings.DistanceSize end
local function GetHeightSize(Distance) return GetDynamicSize(Distance, Settings.DistanceMinSize, Settings.DistanceMaxSize) or Settings.HeightSize end

-- 3D box corners: manual calculation from root CFrame (reliable, no GetBoundingBox)
local function Get3DCorners(Character)
    local root = GetRoot(Character)
    if not root then return nil end
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local height = math.clamp(humanoid.HipHeight + 5, 4, 7)
    local width = 3
    local depth = 1.5
    local centerCF = root.CFrame * CFrame.new(0, height / 2 - 1, 0)
    local hx, hy, hz = width / 2, height / 2, depth / 2
    return {
        (centerCF * CFrame.new(-hx, -hy, -hz)).Position,
        (centerCF * CFrame.new( hx, -hy, -hz)).Position,
        (centerCF * CFrame.new(-hx, -hy,  hz)).Position,
        (centerCF * CFrame.new( hx, -hy,  hz)).Position,
        (centerCF * CFrame.new(-hx,  hy, -hz)).Position,
        (centerCF * CFrame.new( hx,  hy, -hz)).Position,
        (centerCF * CFrame.new(-hx,  hy,  hz)).Position,
        (centerCF * CFrame.new( hx,  hy,  hz)).Position,
    }
end

-- ═══════════════════════════════════════════════════════════
-- HIGHLIGHT MANAGEMENT
-- ═══════════════════════════════════════════════════════════

local function CreateBox()
    local Box = Instance.new("Frame")
    Box.Name = "ESPBox"
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 0
    Box.Visible = false
    Box.Active = false
    Box.ZIndex = 10
    Box.Parent = ESPGui
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Parent = Box
    return Box, Stroke
end

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

ClearHighlights = function(Data)
    if Data.Highlights then
        for Part, Highlight in pairs(Data.Highlights) do
            if Highlight then Highlight:Destroy() end
            Data.Highlights[Part] = nil
        end
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

-- ═══════════════════════════════════════════════════════════
-- BOUNDS CALCULATION
-- ═══════════════════════════════════════════════════════════

local function GetPerformanceBounds(Character)
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end
    local Root = GetRoot(Character)
    if not Root then return nil end
    local Position, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if Position.Z <= 0 or not OnScreen then return nil end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return nil end
    local Height = math.clamp(Humanoid.HipHeight * 2 + 5.6, 4.8, 11.5)
    local Width = Height * 0.52
    local Top = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, Height / 2, 0))
    local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, Height / 2, 0))
    local SizeY = math.abs(Top.Y - Bottom.Y)
    if SizeY <= 2 then return nil end
    local SizeX = SizeY * Width / Height
    return Position.X - SizeX / 2, Position.Y - SizeY / 2, Position.X + SizeX / 2, Position.Y + SizeY / 2
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
                    local WorldPos = Part.CFrame:PointToWorldSpace(Vector3.new(Half.X * X, Half.Y * Y, Half.Z * Z))
                    local Position = Camera:WorldToViewportPoint(WorldPos)
                    if Position.Z > 0 then
                        MinX = math.min(MinX, Position.X)
                        MinY = math.min(MinY, Position.Y)
                        MaxX = math.max(MaxX, Position.X)
                        MaxY = math.max(MaxY, Position.Y)
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
    if Settings.BoxMode == "Accurate" then return GetAccurateBounds(Character) end
    return GetPerformanceBounds(Character)
end

-- ═══════════════════════════════════════════════════════════
-- BOX GROUPING (Union-Find)
-- ═══════════════════════════════════════════════════════════

local function GroupBoxes(boxes)
    if #boxes == 0 then return {} end
    local parent = {}
    for i = 1, #boxes do parent[i] = i end
    local function find(i)
        while parent[i] ~= i do parent[i] = parent[parent[i]]; i = parent[i] end
        return i
    end
    local function union(i, j)
        local ri, rj = find(i), find(j)
        if ri ~= rj then parent[ri] = rj end
    end
    for i = 1, #boxes do
        for j = i + 1, #boxes do
            local a, b = boxes[i], boxes[j]
            if a.minX <= b.maxX and b.minX <= a.maxX and a.minY <= b.maxY and b.minY <= a.maxY then
                union(i, j)
            end
        end
    end
    local groupMap = {}
    for i, box in ipairs(boxes) do
        local root = find(i)
        if not groupMap[root] then
            groupMap[root] = { boxes = {}, minX = box.minX, minY = box.minY, maxX = box.maxX, maxY = box.maxY, count = 0 }
        end
        local g = groupMap[root]
        g.boxes[#g.boxes + 1] = box
        g.minX = math.min(g.minX, box.minX)
        g.minY = math.min(g.minY, box.minY)
        g.maxX = math.max(g.maxX, box.maxX)
        g.maxY = math.max(g.maxY, box.maxY)
        g.count = g.count + 1
    end
    local groups = {}
    for _, g in pairs(groupMap) do groups[#groups + 1] = g end
    return groups
end

-- ═══════════════════════════════════════════════════════════
-- ESP OBJECT MANAGEMENT
-- ═══════════════════════════════════════════════════════════

local function HideESP(Data)
    if Data.Billboard then Data.Billboard.Enabled = false end
    if Data.Name then Data.Name.Visible = false end
    if Data.Distance then Data.Distance.Visible = false end
    if Data.Height then Data.Height.Visible = false end
    if Data.Box then Data.Box.Visible = false end
    if Data.Box3DLines then for _, line in ipairs(Data.Box3DLines) do line.Visible = false end end
    if Data.Tracer then Data.Tracer.Visible = false end
    Data.ScreenBounds = nil
    Data.BoxVisible = false
    ClearHighlights(Data)
    Data.HighlightMode = nil
end

local function CreateESP(Player)
    if Player == LocalPlayer or ESPObjects[Player] then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "PlayerESP"
    Billboard.Size = UDim2.fromOffset(220, 80)
    Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    Billboard.AlwaysOnTop = true
    Billboard.LightInfluence = 0
    Billboard.MaxDistance = MAX_DISTANCE
    Billboard.ResetOnSpawn = false
    Billboard.Enabled = false
    Billboard.Parent = PlayerGui

    local Name = Instance.new("TextLabel")
    Name.Name = "Name"
    Name.Size = UDim2.new(1, 0, 0, 30)
    Name.Position = UDim2.fromOffset(0, 0)
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
    Distance.Size = UDim2.new(1, 0, 0, 20)
    Distance.Position = UDim2.fromOffset(0, 30)
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
    Height.Size = UDim2.new(1, 0, 0, 20)
    Height.Position = UDim2.fromOffset(0, 50)
    Height.BackgroundTransparency = 1
    Height.TextColor3 = Colors.EnemyDistance
    Height.TextSize = Settings.HeightSize
    Height.TextStrokeTransparency = 0.5
    Height.TextXAlignment = Enum.TextXAlignment.Center
    Height.Font = Enum.Font.GothamMedium
    Height.Visible = false
    Height.Parent = Billboard

    local Box, BoxStroke = CreateBox()

    -- 3D box lines: create with Transparency = 1 (visible in Drawing API)
    local Box3DLines = nil
    if HasDrawing then
        Box3DLines = {}
        for i = 1, 12 do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Transparency = 1
            line.Visible = false
            Box3DLines[i] = line
        end
    end

    -- Tracer line: create with Transparency = 1
    local Tracer = nil
    if HasDrawing then
        Tracer = Drawing.new("Line")
        Tracer.Thickness = 1
        Tracer.Transparency = 1
        Tracer.Visible = false
    end

    local Data = {
        Billboard = Billboard, Name = Name, Distance = Distance, Height = Height,
        Box = Box, BoxStroke = BoxStroke,
        Box3DLines = Box3DLines, Tracer = Tracer,
        Highlights = {}, FullHighlight = nil,
        Character = nil, Connection = nil,
        Visibility = nil, HighlightMode = nil,
        ScreenBounds = nil, BoxColor = nil, BoxVisible = false,
        DisplayBounds = nil,
        Distance = 0, Side = "Enemy",
    }

    ESPObjects[Player] = Data

    local function Attach(Character)
        local CurrentData = ESPObjects[Player]
        if not CurrentData then return end
        CurrentData.Character = Character
        CurrentData.Visibility = nil
        CurrentData.HighlightMode = nil
        ClearHighlights(CurrentData)
        CurrentData.Billboard.Enabled = false
        CurrentData.Billboard.AlwaysOnTop = true
        CurrentData.Billboard.MaxDistance = MAX_DISTANCE
        CurrentData.Name.Visible = false
        CurrentData.Distance.Visible = false
        CurrentData.Height.Visible = false
        local Root = GetRoot(Character)
        if Root then
            CurrentData.Billboard.Adornee = Root
        else
            CurrentData.Billboard.Adornee = nil
        end
    end

    if Player.Character then
        task.spawn(Attach, Player.Character)
    end

    Data.Connection = Player.CharacterAdded:Connect(function(Character)
        local CurrentData = ESPObjects[Player]
        if not CurrentData then return end
        Attach(Character)
        task.spawn(function()
            local Root = Character:WaitForChild("HumanoidRootPart", 3)
            if ESPObjects[Player] == CurrentData and Root and Root.Parent then
                CurrentData.Character = Character
                CurrentData.Billboard.Adornee = Root
            end
        end)
    end)
end

local function RemoveESP(Player)
    local Data = ESPObjects[Player]
    if not Data then return end
    if Data.Connection then Data.Connection:Disconnect() end
    ClearHighlights(Data)
    if Data.Billboard then Data.Billboard:Destroy() end
    if Data.Box then Data.Box:Destroy() end
    if Data.Box3DLines then
        for _, line in ipairs(Data.Box3DLines) do
            pcall(function() line:Remove() end)
        end
    end
    if Data.Tracer then
        pcall(function() Data.Tracer:Remove() end)
    end
    ESPObjects[Player] = nil
end

-- ═══════════════════════════════════════════════════════════
-- UPDATE FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function UpdateHighlightBudget()
    if not Settings.ESP or not Settings.Highlight then
        for _, Data in pairs(ESPObjects) do ClearHighlights(Data); Data.HighlightMode = nil end
        return
    end
    local MyRoot = GetRoot(LocalPlayer.Character)
    if not MyRoot then
        for _, Data in pairs(ESPObjects) do ClearHighlights(Data); Data.HighlightMode = nil end
        return
    end
    local Candidates = {}
    for Player, Data in pairs(ESPObjects) do
        local Character = GetCharacter(Player)
        local Root = GetRoot(Character)
        if Character and Root and Player.Parent == Players then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Distance = (MyRoot.Position - Root.Position).Magnitude
                local Side = GetSide(Player)
                if Distance <= Settings.HighlightDistance and IsFeatureEnabled(Side, "Highlight", Distance) then
                    Candidates[#Candidates + 1] = { Player = Player, Data = Data, Distance = Distance, PartCount = #GetBodyParts(Character) }
                else
                    ClearHighlights(Data); Data.HighlightMode = nil
                end
            else
                ClearHighlights(Data); Data.HighlightMode = nil
            end
        else
            ClearHighlights(Data); Data.HighlightMode = nil
        end
    end
    table.sort(Candidates, function(A, B) return A.Distance < B.Distance end)
    local Remaining = MAX_HIGHLIGHT_BUDGET
    for _, Candidate in ipairs(Candidates) do
        if Candidate.PartCount > 0 and Candidate.PartCount <= Remaining then
            Candidate.Data.HighlightMode = "BodyParts"
            Remaining -= Candidate.PartCount
        else
            Candidate.Data.HighlightMode = nil
        end
    end
    if Remaining > 0 then
        for Index = #Candidates, 1, -1 do
            local Candidate = Candidates[Index]
            if not Candidate.Data.HighlightMode then
                Candidate.Data.HighlightMode = "Full"
                Remaining -= 1
                if Remaining <= 0 then break end
            end
        end
    end
    for _, Candidate in ipairs(Candidates) do
        if not Candidate.Data.HighlightMode then ClearHighlights(Candidate.Data) end
    end
end

local function UpdateHighlights(Player, Data, Distance, Side, Visibility)
    local Mode = Data.HighlightMode
    if not Mode or not Settings.Highlight or Distance > Settings.HighlightDistance or not IsFeatureEnabled(Side, "Highlight", Distance) then
        ClearHighlights(Data); Data.HighlightMode = nil; return
    end
    if Mode == "Full" then
        local Color = GetHighlightColor(Player, Visibility.AnyVisible)
        SetFullHighlight(Data, Data.Character, Color)
        for Part, Highlight in pairs(Data.Highlights) do Highlight:Destroy(); Data.Highlights[Part] = nil end
        return
    end
    if Data.FullHighlight then Data.FullHighlight:Destroy(); Data.FullHighlight = nil end
    local ExistingParts = {}
    for _, Part in ipairs(GetBodyParts(Data.Character)) do
        ExistingParts[Part] = true
        local Visible = not Settings.VisibilityCheck and true or (Visibility.UseBodyParts and Visibility.Parts[Part] == true or Visibility.AnyVisible)
        SetBodyPartHighlight(Data, Part, GetHighlightColor(Player, Visible))
    end
    for Part, Highlight in pairs(Data.Highlights) do
        if not ExistingParts[Part] or not Part.Parent then Highlight:Destroy(); Data.Highlights[Part] = nil end
    end
end

-- 3D box: uses manual corner calculation from root CFrame + Transparency = 1
Update3DBox = function(Player, Data, Character, Distance, Side, Visibility)
    if not Data.Box3DLines then return end
    if not Settings.Box3D or not Settings.ESP or Distance > Settings.Box3DDistance or not IsFeatureEnabled(Side, "Box3D", Distance) then
        for _, line in ipairs(Data.Box3DLines) do line.Visible = false end
        return
    end
    local corners = Get3DCorners(Character)
    if not corners then
        for _, line in ipairs(Data.Box3DLines) do line.Visible = false end
        return
    end
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    local screenPos = {}
    for i = 1, 8 do
        local sp = Camera:WorldToViewportPoint(corners[i])
        screenPos[i] = { x = sp.X, y = sp.Y, z = sp.Z }
    end
    local color = GetBoxColor(Player, Visibility.AnyVisible)
    for i, edge in ipairs(EDGES_3D) do
        local p1 = screenPos[edge[1]]
        local p2 = screenPos[edge[2]]
        local line = Data.Box3DLines[i]
        if p1.z > 0 and p2.z > 0 then
            line.From = Vector2.new(p1.x, p1.y)
            line.To = Vector2.new(p2.x, p2.y)
            line.Color = color
            line.Thickness = Settings.Box3DThickness
            line.Transparency = 1
            line.Visible = true
        else
            line.Visible = false
        end
    end
end

-- Tracer: Transparency = 1 on update
UpdateTracer = function(Player, Data, Distance, Side, Visibility)
    if not Data.Tracer then return end
    if not Settings.Tracers or not Settings.ESP or Distance > Settings.TracerDistance or not IsFeatureEnabled(Side, "Tracer", Distance) then
        Data.Tracer.Visible = false
        return
    end
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    local root = GetRoot(Data.Character)
    if not root then Data.Tracer.Visible = false; return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen or screenPos.Z <= 0 then Data.Tracer.Visible = false; return end
    local origin
    if Settings.TracerOrigin == "Center" then
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    elseif Settings.TracerOrigin == "Player" then
        local myRoot = GetRoot(LocalPlayer.Character)
        if myRoot then
            local myScreen = Camera:WorldToViewportPoint(myRoot.Position)
            origin = Vector2.new(myScreen.X, myScreen.Y)
        else
            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        end
    else
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    end
    Data.Tracer.From = origin
    Data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    Data.Tracer.Color = GetTracerColor(Player, Visibility.AnyVisible)
    Data.Tracer.Thickness = Settings.TracerThickness
    Data.Tracer.Transparency = 1
    Data.Tracer.Visible = true
end

local function UpdateText(Player, Data, Distance, Side)
    local Root = GetRoot(Data.Character)
    if not Root or not Root.Parent or not Data.Billboard or not Data.Billboard.Parent then
        if Data.Billboard then Data.Billboard.Enabled = false end
        if Data.Name then Data.Name.Visible = false end
        if Data.Distance then Data.Distance.Visible = false end
        if Data.Height then Data.Height.Visible = false end
        return
    end
    local NameEnabled = Settings.ShowName and Distance <= Settings.ESPDistance and IsFeatureEnabled(Side, "Name", Distance)
    local DistanceEnabled = Settings.ShowDistance and Distance <= Settings.ESPDistance and IsFeatureEnabled(Side, "Distance", Distance)
    local HeightEnabled = Settings.ShowHeight and Distance <= Settings.ESPDistance and IsFeatureEnabled(Side, "Height", Distance)
    Data.Billboard.Adornee = Root
    Data.Billboard.MaxDistance = MAX_DISTANCE
    Data.Billboard.AlwaysOnTop = true
    Data.Name.Text = Player.DisplayName
    Data.Name.TextSize = GetNameSize(Distance)
    Data.Name.TextColor3 = GetNameColor(Player)
    Data.Name.Visible = NameEnabled
    Data.Distance.TextSize = GetDistanceSize(Distance)
    Data.Distance.TextColor3 = GetDistanceColor(Player)
    Data.Distance.Text = DistanceEnabled and (tostring(math.floor(Distance + 0.5)) .. " studs") or ""
    Data.Distance.Visible = DistanceEnabled
    Data.Height.TextSize = GetHeightSize(Distance)
    Data.Height.TextColor3 = GetHeightColor(Player)
    Data.Height.Text = HeightEnabled and string.format("Y: %.1f", Root.Position.Y) or ""
    Data.Height.Visible = HeightEnabled
    Data.Billboard.Enabled = NameEnabled or DistanceEnabled or HeightEnabled
end

-- ═══════════════════════════════════════════════════════════
-- ANIMATED BOX UPDATE (called every frame)
-- ═══════════════════════════════════════════════════════════

local function UpdateBoxes()
    -- Hide all count labels
    for _, label in ipairs(CountLabelPool) do label.Visible = false end

    if not Settings.Boxes or not Settings.ESP then
        for _, data in pairs(ESPObjects) do
            if data.Box then data.Box.Visible = false end
            data.DisplayBounds = nil
        end
        return
    end

    -- Collect visible boxes
    local visibleBoxes = {}
    for player, data in pairs(ESPObjects) do
        if data.ScreenBounds and data.BoxVisible then
            visibleBoxes[#visibleBoxes + 1] = {
                player = player, data = data,
                minX = data.ScreenBounds.minX, minY = data.ScreenBounds.minY,
                maxX = data.ScreenBounds.maxX, maxY = data.ScreenBounds.maxY,
            }
        end
    end

    if #visibleBoxes == 0 then
        for _, data in pairs(ESPObjects) do
            if data.Box then data.Box.Visible = false end
        end
        return
    end

    -- Group
    local groups
    if Settings.BoxGrouping and #visibleBoxes > 1 then
        groups = GroupBoxes(visibleBoxes)
    else
        groups = {}
        for _, box in ipairs(visibleBoxes) do
            groups[#groups + 1] = { boxes = { box }, minX = box.minX, minY = box.minY, maxX = box.maxX, maxY = box.maxY, count = 1 }
        end
    end

    -- Process each group with lerp animation
    for _, group in ipairs(groups) do
        local isMerged = group.count > 1
        local primaryData = group.boxes[1].data
        local targetMinX, targetMinY = group.minX, group.minY
        local targetMaxX, targetMaxY = group.maxX, group.maxY

        -- Initialize or lerp primary box
        if not primaryData.DisplayBounds then
            primaryData.DisplayBounds = { minX = targetMinX, minY = targetMinY, maxX = targetMaxX, maxY = targetMaxY }
        else
            local db = primaryData.DisplayBounds
            db.minX = db.minX + (targetMinX - db.minX) * LERP_FACTOR
            db.minY = db.minY + (targetMinY - db.minY) * LERP_FACTOR
            db.maxX = db.maxX + (targetMaxX - db.maxX) * LERP_FACTOR
            db.maxY = db.maxY + (targetMaxY - db.maxY) * LERP_FACTOR
        end

        local db = primaryData.DisplayBounds
        if primaryData.Box then
            primaryData.Box.Position = UDim2.fromOffset(db.minX, db.minY)
            primaryData.Box.Size = UDim2.fromOffset(math.max(db.maxX - db.minX, 2), math.max(db.maxY - db.minY, 2))
            if primaryData.BoxStroke then
                primaryData.BoxStroke.Color = primaryData.BoxColor or Color3.fromRGB(255, 255, 255)
            end
            primaryData.Box.Visible = true
        end

        -- Hide other boxes in group but keep their DisplayBounds lerping
        for i = 2, #group.boxes do
            local otherData = group.boxes[i].data
            if otherData.Box then otherData.Box.Visible = false end
            if not otherData.DisplayBounds then
                otherData.DisplayBounds = { minX = targetMinX, minY = targetMinY, maxX = targetMaxX, maxY = targetMaxY }
            else
                local db2 = otherData.DisplayBounds
                db2.minX = db2.minX + (targetMinX - db2.minX) * LERP_FACTOR
                db2.minY = db2.minY + (targetMinY - db2.minY) * LERP_FACTOR
                db2.maxX = db2.maxX + (targetMaxX - db2.maxX) * LERP_FACTOR
                db2.maxY = db2.maxY + (targetMaxY - db2.maxY) * LERP_FACTOR
            end
        end

        -- Count label for merged groups
        if isMerged then
            local label = GetCountLabel()
            label.Text = "x" .. group.count
            label.Position = UDim2.fromOffset(math.floor((db.minX + db.maxX) / 2), math.floor(db.minY - 18))
            label.TextColor3 = Colors.GroupCount
            label.Visible = true
        end
    end

    -- Hide boxes for players not in any group
    local drawnData = {}
    for _, group in ipairs(groups) do
        for _, box in ipairs(group.boxes) do drawnData[box.data] = true end
    end
    for _, data in pairs(ESPObjects) do
        if not drawnData[data] and data.Box then
            data.Box.Visible = false
            data.DisplayBounds = nil
        end
    end
end

-- Per-frame Drawing updates (3D boxes + tracers at full framerate)
local function UpdateDrawings()
    if not Settings.ESP then return end
    local myRoot = GetRoot(LocalPlayer.Character)
    for player, data in pairs(ESPObjects) do
        if player.Parent == Players and data.Character then
            local character = data.Character
            local root = GetRoot(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local distance = myRoot and (myRoot.Position - root.Position).Magnitude or data.Distance
                local side = data.Side or "Enemy"
                local visibility = data.Visibility or { AnyVisible = true, Parts = {}, UseBodyParts = false }
                Update3DBox(player, data, character, distance, side, visibility)
                UpdateTracer(player, data, distance, side, visibility)
            else
                if data.Box3DLines then for _, line in ipairs(data.Box3DLines) do line.Visible = false end end
                if data.Tracer then data.Tracer.Visible = false end
            end
        end
    end
end

-- Main ESP update (0.05s interval)
local function UpdateESP(Player, Data)
    if not Settings.ESP then HideESP(Data); return end
    local Character = GetCharacter(Player)
    if not Character then HideESP(Data); return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = GetRoot(Character)
    local MyRoot = GetRoot(LocalPlayer.Character)
    if not Humanoid or not Root or not MyRoot or Humanoid.Health <= 0 then HideESP(Data); return end

    if Data.Character ~= Character then
        Data.Character = Character
        Data.Visibility = nil
        Data.HighlightMode = nil
        ClearHighlights(Data)
    end
    Data.Billboard.Adornee = Root
    local Distance = (MyRoot.Position - Root.Position).Magnitude
    local Side = GetSide(Player)
    Data.Distance = Distance
    Data.Side = Side

    if Settings.VisibilityCheck then
        Data.Visibility = GetVisibility(Character, Distance)
    else
        Data.Visibility = { AnyVisible = true, Parts = {}, UseBodyParts = false }
    end

    UpdateText(Player, Data, Distance, Side)
    UpdateHighlights(Player, Data, Distance, Side, Data.Visibility)

    -- Calculate box bounds (store for UpdateBoxes to draw with animation)
    local boxEnabled = Settings.Boxes and Settings.ESP and Distance <= Settings.BoxDistance and IsFeatureEnabled(Side, "Box", Distance)
    if boxEnabled then
        local MinX, MinY, MaxX, MaxY = GetScreenBounds(Character)
        if MinX then
            Data.ScreenBounds = { minX = MinX, minY = MinY, maxX = MaxX, maxY = MaxY }
            Data.BoxColor = GetBoxColor(Player, Data.Visibility.AnyVisible)
            Data.BoxVisible = true
        else
            Data.ScreenBounds = nil
            Data.BoxVisible = false
        end
    else
        Data.ScreenBounds = nil
        if Data.Box then Data.Box.Visible = false end
        Data.BoxVisible = false
    end
end

-- ═══════════════════════════════════════════════════════════
-- PLAYER CONNECTIONS
-- ═══════════════════════════════════════════════════════════

for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then CreateESP(Player) end
end

Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then CreateESP(Player) end
end)

Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
end)

-- ═══════════════════════════════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════════════════════════════

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

    -- Per-frame updates: smooth 3D boxes, tracers, and animated box grouping
    UpdateDrawings()
    UpdateBoxes()

    -- Periodic ESP update (0.05s)
    if Timer < UPDATE_INTERVAL then return end
    Timer = 0

    UpdateHighlightBudget()

    for Player, Data in pairs(ESPObjects) do
        if Player.Parent == Players then
            UpdateESP(Player, Data)
        else
            RemoveESP(Player)
        end
    end
end)