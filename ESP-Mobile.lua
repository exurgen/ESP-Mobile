-- ═══════════════════════════════════════════════════════════
-- PLAYER ESP — Enhanced Edition
-- 2D Boxes · 3D Boxes · Tracers · Height · Box Grouping
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Drawing API availability check
local HasDrawing = false
pcall(function()
    local test = Drawing.new("Line")
    test:Remove()
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

-- 3D box edges (12 edges connecting 8 corners)
local EDGES_3D = {
    {1, 2}, {2, 4}, {4, 3}, {3, 1},  -- bottom face
    {5, 6}, {6, 8}, {8, 7}, {7, 5},  -- top face
    {1, 5}, {2, 6}, {3, 7}, {4, 8},  -- vertical edges
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

-- ═══════════════════════════════════════════════════════════
-- ESP OBJECTS STORAGE
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
    Author = "Enhanced ESP",
    Folder = "PlayerESP",

    Size = UDim2.fromOffset(560, 480),
    MinSize = Vector2.new(390, 330),
    MaxSize = Vector2.new(900, 720),

    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = true,
    ScrollBarEnabled = true,

    User = {
        Enabled = true,
        Anonymous = false,
    },
})

-- ═══════════════════════════════════════════════════════════
-- SECTIONS & TABS
-- ═══════════════════════════════════════════════════════════

local Sections = {
    About = Window:Section({ Title = "ABOUT", Opened = true }),
    Features = Window:Section({ Title = "FEATURES", Opened = true }),
    Config = Window:Section({ Title = "CONFIG", Opened = true }),
}

local Tabs = {
    About = Sections.About:Tab({
        Title = "About",
        Icon = "house",
        Desc = "Features and tips",
    }),
    ESP = Sections.Features:Tab({
        Title = "ESP",
        Icon = "eye",
        Desc = "Main ESP features and distances",
    }),
    Detection = Sections.Features:Tab({
        Title = "Detection",
        Icon = "scan-search",
        Desc = "Visibility and raycast",
    }),
    Profiles = Sections.Features:Tab({
        Title = "Profiles",
        Icon = "users",
        Desc = "Enemy and teammate settings",
    }),
    Text = Sections.Config:Tab({
        Title = "Text",
        Icon = "type",
        Desc = "Text appearance and sizing",
    }),
    Colors = Sections.Config:Tab({
        Title = "Colors",
        Icon = "palette",
        Desc = "All ESP colors",
    }),
    Settings = Sections.Config:Tab({
        Title = "Settings",
        Icon = "settings",
        Desc = "Theme and reset",
    }),
}

-- ═══════════════════════════════════════════════════════════
-- ABOUT TAB
-- ═══════════════════════════════════════════════════════════

Tabs.About:Paragraph({
    Title = "PLAYER ESP",
    Desc = "Enhanced player visualization with 2D/3D boxes, tracers, height and grouping",
    Image = "eye",
    ImageSize = 26,
})

local AboutFeatures = Tabs.About:Section({
    Title = "Features",
    Icon = "info",
    Opened = true,
    Box = true,
})

AboutFeatures:Paragraph({
    Title = "2D Boxes",
    Desc = "Screen-space rectangles with Performance and Accurate modes.",
    Image = "square",
    ImageSize = 18,
})

AboutFeatures:Paragraph({
    Title = "3D Boxes",
    Desc = "Wireframe cubes projected from the character bounding box. Requires Drawing API.",
    Image = "box",
    ImageSize = 18,
})

AboutFeatures:Paragraph({
    Title = "Tracers",
    Desc = "Lines from screen bottom, center, or your character to each player.",
    Image = "move",
    ImageSize = 18,
})

AboutFeatures:Paragraph({
    Title = "Height",
    Desc = "Shows each player's Y coordinate elevation.",
    Image = "move-vertical",
    ImageSize = 18,
})

AboutFeatures:Paragraph({
    Title = "Box Grouping",
    Desc = "When multiple 2D boxes overlap, they merge into one with a player count label.",
    Image = "group",
    ImageSize = 18,
})

AboutFeatures:Paragraph({
    Title = "Detection",
    Desc = "Body-part or normal raycasting with selectable origin and automatic fallback.",
    Image = "scan-search",
    ImageSize = 18,
})

AboutFeatures:Paragraph({
    Title = "Profiles",
    Desc = "Independent enemy and teammate settings for every ESP element.",
    Image = "users",
    ImageSize = 18,
})

local AboutTips = Tabs.About:Section({
    Title = "Tips",
    Icon = "lightbulb",
    Opened = true,
    Box = true,
})

AboutTips:Paragraph({
    Title = "Performance",
    Desc = "Use Performance box mode and lower highlight distance on mobile for better FPS.",
    Image = "zap",
    ImageSize = 18,
})

AboutTips:Paragraph({
    Title = "Profiles",
    Desc = "Switch between Enemy and Teammate profiles to configure each side independently.",
    Image = "users",
    ImageSize = 18,
})

AboutTips:Paragraph({
    Title = "Dynamic Text",
    Desc = "Dynamic mode scales text based on distance — closer players get larger text.",
    Image = "move-diagonal-2",
    ImageSize = 18,
})

-- ═══════════════════════════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════════════════════════

local ESPSection = Tabs.ESP:Section({
    Title = "Features",
    Icon = "scan",
    Opened = true,
    Box = true,
})

ESPSection:Toggle({
    Title = "ESP",
    Desc = "Master toggle for all ESP features",
    Value = Settings.ESP,
    Callback = function(Value) Settings.ESP = Value end,
})

ESPSection:Toggle({
    Title = "Names",
    Desc = "Show player display names",
    Value = Settings.ShowName,
    Callback = function(Value) Settings.ShowName = Value end,
})

ESPSection:Toggle({
    Title = "Distance",
    Desc = "Show distance to each player in studs",
    Value = Settings.ShowDistance,
    Callback = function(Value) Settings.ShowDistance = Value end,
})

ESPSection:Toggle({
    Title = "Height",
    Desc = "Show player Y-coordinate elevation",
    Value = Settings.ShowHeight,
    Callback = function(Value) Settings.ShowHeight = Value end,
})

ESPSection:Toggle({
    Title = "Highlight",
    Desc = "Highlight player body parts with color overlay",
    Value = Settings.Highlight,
    Callback = function(Value) Settings.Highlight = Value end,
})

ESPSection:Toggle({
    Title = "2D Boxes",
    Desc = "Draw screen-space rectangles around players",
    Value = Settings.Boxes,
    Callback = function(Value) Settings.Boxes = Value end,
})

ESPSection:Toggle({
    Title = "3D Boxes",
    Desc = "Draw 3D wireframe cubes around players (requires Drawing API)",
    Value = Settings.Box3D,
    Callback = function(Value) Settings.Box3D = Value end,
})

ESPSection:Toggle({
    Title = "Tracers",
    Desc = "Draw lines from screen origin to each player",
    Value = Settings.Tracers,
    Callback = function(Value) Settings.Tracers = Value end,
})

ESPSection:Toggle({
    Title = "Box Grouping",
    Desc = "Merge overlapping 2D boxes and show player count",
    Value = Settings.BoxGrouping,
    Callback = function(Value) Settings.BoxGrouping = Value end,
})

ESPSection:Toggle({
    Title = "Team Check",
    Desc = "Separate enemies and teammates with different colors",
    Value = Settings.TeamCheck,
    Callback = function(Value) Settings.TeamCheck = Value end,
})

-- Distances
local DistanceSection = Tabs.ESP:Section({
    Title = "Distances",
    Icon = "maximize",
    Opened = true,
    Box = true,
})

DistanceSection:Slider({
    Title = "Text Distance",
    Desc = "Maximum distance for name, distance and height text",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE },
    Step = 1,
    Callback = function(Value) Settings.ESPDistance = Value end,
})

DistanceSection:Slider({
    Title = "Highlight Distance",
    Desc = "Maximum distance for body-part highlights",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE },
    Step = 1,
    Callback = function(Value) Settings.HighlightDistance = Value end,
})

DistanceSection:Slider({
    Title = "2D Box Distance",
    Desc = "Maximum distance for 2D boxes",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE },
    Step = 1,
    Callback = function(Value) Settings.BoxDistance = Value end,
})

DistanceSection:Slider({
    Title = "3D Box Distance",
    Desc = "Maximum distance for 3D wireframe boxes",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE },
    Step = 1,
    Callback = function(Value) Settings.Box3DDistance = Value end,
})

DistanceSection:Slider({
    Title = "Tracer Distance",
    Desc = "Maximum distance for tracer lines",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = DEFAULT_DISTANCE },
    Step = 1,
    Callback = function(Value) Settings.TracerDistance = Value end,
})

-- Appearance
local AppearanceSection = Tabs.ESP:Section({
    Title = "Box & Tracer Appearance",
    Icon = "sliders-horizontal",
    Opened = true,
    Box = true,
})

AppearanceSection:Dropdown({
    Title = "2D Box Mode",
    Desc = "Performance: fast approximate box. Accurate: precise per-limb calculation.",
    Values = { "Performance", "Accurate" },
    Value = Settings.BoxMode,
    Callback = function(Value) Settings.BoxMode = Value end,
})

AppearanceSection:Dropdown({
    Title = "Tracer Origin",
    Desc = "Where tracer lines start from",
    Values = { "Bottom", "Center", "Player" },
    Value = Settings.TracerOrigin,
    Callback = function(Value) Settings.TracerOrigin = Value end,
})

AppearanceSection:Slider({
    Title = "3D Box Thickness",
    Desc = "Line thickness for 3D wireframe boxes",
    Value = { Min = MIN_THICKNESS, Max = MAX_THICKNESS, Default = DEFAULT_THICKNESS },
    Step = 1,
    Callback = function(Value) Settings.Box3DThickness = Value end,
})

AppearanceSection:Slider({
    Title = "Tracer Thickness",
    Desc = "Line thickness for tracer lines",
    Value = { Min = MIN_THICKNESS, Max = MAX_THICKNESS, Default = DEFAULT_THICKNESS },
    Step = 1,
    Callback = function(Value) Settings.TracerThickness = Value end,
})

-- Reset ESP
local ESPResetSection = Tabs.ESP:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true,
})

ESPResetSection:Divider()

ESPResetSection:Button({
    Title = "Reset ESP",
    Desc = "Restore ESP features, distances and appearance to defaults",
    Icon = "rotate-ccw",
    Callback = function()
        for _, Key in ipairs({
            "ESP", "ShowName", "ShowDistance", "ShowHeight",
            "Highlight", "Boxes", "Box3D", "Tracers", "BoxGrouping", "TeamCheck",
            "ESPDistance", "HighlightDistance", "BoxDistance",
            "Box3DDistance", "TracerDistance",
            "BoxMode", "TracerOrigin", "TracerThickness", "Box3DThickness",
        }) do
            Settings[Key] = DEFAULT_SETTINGS[Key]
        end
        WindUI:Notify({
            Title = "ESP Reset",
            Content = "ESP settings restored to defaults",
            Icon = "check",
            Duration = 2,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- DETECTION TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Detection:Paragraph({
    Title = "Visibility Detection",
    Desc = "Control how ESP determines if a player is visible or behind walls.",
    Image = "scan-search",
    ImageSize = 20,
})

local DetectionSection = Tabs.Detection:Section({
    Title = "Raycast",
    Icon = "crosshair",
    Opened = true,
    Box = true,
})

DetectionSection:Toggle({
    Title = "Visibility Check",
    Desc = "Raycast to determine if players are behind walls",
    Value = Settings.VisibilityCheck,
    Callback = function(Value) Settings.VisibilityCheck = Value end,
})

DetectionSection:Toggle({
    Title = "Body Part Raycast",
    Desc = "Check each body part individually for precise visibility",
    Value = Settings.BodyPartRaycast,
    Callback = function(Value) Settings.BodyPartRaycast = Value end,
})

DetectionSection:Toggle({
    Title = "Automatic Fallback",
    Desc = "Switch to single-raycast at long distances to save performance",
    Value = Settings.BodyPartRaycastFallback,
    Callback = function(Value) Settings.BodyPartRaycastFallback = Value end,
})

DetectionSection:Slider({
    Title = "Fallback Distance",
    Desc = "Distance at which body-part raycast switches to normal",
    Value = { Min = MIN_DISTANCE, Max = MAX_DISTANCE, Default = Settings.BodyPartRaycastDistance },
    Step = 1,
    Callback = function(Value) Settings.BodyPartRaycastDistance = Value end,
})

DetectionSection:Dropdown({
    Title = "Raycast Origin",
    Desc = "Where rays originate: your character or the camera",
    Values = { "Character", "Camera" },
    Value = Settings.RayOrigin,
    Callback = function(Value) Settings.RayOrigin = Value end,
})

local DetectionResetSection = Tabs.Detection:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true,
})

DetectionResetSection:Divider()

DetectionResetSection:Button({
    Title = "Reset Detection",
    Desc = "Restore detection settings to defaults",
    Icon = "rotate-ccw",
    Callback = function()
        for _, Key in ipairs({
            "VisibilityCheck", "BodyPartRaycast",
            "BodyPartRaycastFallback", "BodyPartRaycastDistance", "RayOrigin",
        }) do
            Settings[Key] = DEFAULT_SETTINGS[Key]
        end
        WindUI:Notify({
            Title = "Detection Reset",
            Content = "Detection settings restored",
            Icon = "check",
            Duration = 2,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- PROFILES TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Profiles:Paragraph({
    Title = "Side Profiles",
    Desc = "Configure enemy and teammate ESP independently. Switch the profile to edit each side.",
    Image = "users",
    ImageSize = 20,
})

local SelectedSide = "Enemy"
local SideControls = {}

local function RefreshSideControls()
    local side = SideSettings[SelectedSide]
    for feature, controls in pairs(SideControls) do
        local data = side[feature]
        if data then
            if controls.Enabled then
                pcall(function() controls.Enabled:Set(data.Enabled) end)
            end
            if controls.NearDisable then
                pcall(function() controls.NearDisable:Set(data.NearDisable) end)
            end
            if controls.NearDistance then
                pcall(function() controls.NearDistance:Set(data.NearDistance) end)
            end
        end
    end
end

Tabs.Profiles:Dropdown({
    Title = "Active Profile",
    Desc = "Select which side to configure",
    Values = { "Enemy", "Teammate" },
    Value = SelectedSide,
    Callback = function(Value)
        SelectedSide = Value
        RefreshSideControls()
    end,
})

local SideSection = Tabs.Profiles:Section({
    Title = "Elements",
    Icon = "layers-3",
    Opened = true,
    Box = true,
})

local function CreateSideControl(Name, Title, Description)
    SideControls[Name] = {}

    SideControls[Name].Enabled = SideSection:Toggle({
        Title = Title,
        Desc = Description,
        Value = SideSettings.Enemy[Name].Enabled,
        Callback = function(Value)
            SideSettings[SelectedSide][Name].Enabled = Value
        end,
    })

    SideControls[Name].NearDisable = SideSection:Toggle({
        Title = "Disable " .. Title .. " Near",
        Desc = "Hide this element when player is within close range",
        Value = SideSettings.Enemy[Name].NearDisable,
        Callback = function(Value)
            SideSettings[SelectedSide][Name].NearDisable = Value
        end,
    })

    SideControls[Name].NearDistance = SideSection:Slider({
        Title = Title .. " Near Distance",
        Desc = "Elements hidden below this distance (in studs)",
        Value = {
            Min = MIN_NEAR_DISTANCE,
            Max = MAX_NEAR_DISTANCE,
            Default = SideSettings.Enemy[Name].NearDistance,
        },
        Step = 1,
        Callback = function(Value)
            SideSettings[SelectedSide][Name].NearDistance = Value
        end,
    })

    SideSection:Divider()
end

CreateSideControl("Highlight", "Highlight", "Body part highlight overlay")
CreateSideControl("Box", "2D Box", "Screen-space rectangle")
CreateSideControl("Box3D", "3D Box", "3D wireframe cube")
CreateSideControl("Tracer", "Tracer", "Line from origin to player")
CreateSideControl("Name", "Name", "Player display name")
CreateSideControl("Distance", "Distance", "Distance in studs")
CreateSideControl("Height", "Height", "Y-coordinate elevation")

local ProfilesResetSection = Tabs.Profiles:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true,
})

ProfilesResetSection:Divider()

ProfilesResetSection:Button({
    Title = "Reset Profiles",
    Desc = "Restore both Enemy and Teammate profiles to defaults",
    Icon = "rotate-ccw",
    Callback = function()
        ResetSideSettings()
        RefreshSideControls()
        WindUI:Notify({
            Title = "Profiles Reset",
            Content = "Enemy and Teammate profiles restored",
            Icon = "check",
            Duration = 2,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- TEXT TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Text:Paragraph({
    Title = "Text Settings",
    Desc = "Configure name, distance and height text appearance.",
    Image = "type",
    ImageSize = 20,
})

local TextModeSection = Tabs.Text:Section({
    Title = "Mode",
    Icon = "sliders-horizontal",
    Opened = true,
    Box = true,
})

TextModeSection:Dropdown({
    Title = "Text Mode",
    Desc = "Standard: fixed size. Dynamic: size scales with distance.",
    Values = { "Standard", "Dynamic" },
    Value = Settings.TextMode,
    Callback = function(Value) Settings.TextMode = Value end,
})

TextModeSection:Dropdown({
    Title = "Dynamic Mode",
    Desc = "Far Bigger: text grows with distance. Far Smaller: text shrinks with distance.",
    Values = { "Far Bigger", "Far Smaller" },
    Value = Settings.DynamicTextMode,
    Callback = function(Value) Settings.DynamicTextMode = Value end,
})

local BasicTextSection = Tabs.Text:Section({
    Title = "Standard Sizes",
    Icon = "text-cursor-input",
    Opened = true,
    Box = true,
})

BasicTextSection:Slider({
    Title = "Name Size",
    Desc = "Font size for player names",
    Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = DEFAULT_NAME_SIZE },
    Step = 1,
    Callback = function(Value) Settings.NameSize = Value end,
})

BasicTextSection:Slider({
    Title = "Distance Size",
    Desc = "Font size for distance text",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = DEFAULT_DISTANCE_SIZE },
    Step = 1,
    Callback = function(Value) Settings.DistanceSize = Value end,
})

BasicTextSection:Slider({
    Title = "Height Size",
    Desc = "Font size for height text",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = DEFAULT_DISTANCE_SIZE },
    Step = 1,
    Callback = function(Value) Settings.HeightSize = Value end,
})

local DynamicSection = Tabs.Text:Section({
    Title = "Dynamic Size",
    Icon = "move-diagonal-2",
    Opened = true,
    Box = true,
})

DynamicSection:Slider({
    Title = "Curve",
    Desc = "Controls how aggressively size changes with distance",
    Value = { Min = MIN_TEXT_CURVE, Max = MAX_TEXT_CURVE, Default = DEFAULT_TEXT_CURVE },
    Step = 0.05,
    Callback = function(Value) Settings.DynamicTextCurve = Value end,
})

DynamicSection:Slider({
    Title = "Name Minimum",
    Desc = "Minimum dynamic name size",
    Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = MIN_NAME_SIZE },
    Step = 1,
    Callback = function(Value) Settings.NameMinSize = Value end,
})

DynamicSection:Slider({
    Title = "Name Maximum",
    Desc = "Maximum dynamic name size",
    Value = { Min = MIN_NAME_SIZE, Max = MAX_NAME_SIZE, Default = MAX_NAME_SIZE },
    Step = 1,
    Callback = function(Value) Settings.NameMaxSize = Value end,
})

DynamicSection:Slider({
    Title = "Distance Minimum",
    Desc = "Minimum dynamic distance size",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = MIN_DISTANCE_SIZE },
    Step = 1,
    Callback = function(Value) Settings.DistanceMinSize = Value end,
})

DynamicSection:Slider({
    Title = "Distance Maximum",
    Desc = "Maximum dynamic distance size",
    Value = { Min = MIN_DISTANCE_SIZE, Max = MAX_DISTANCE_SIZE, Default = MAX_DISTANCE_SIZE },
    Step = 1,
    Callback = function(Value) Settings.DistanceMaxSize = Value end,
})

local TextResetSection = Tabs.Text:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true,
})

TextResetSection:Divider()

TextResetSection:Button({
    Title = "Reset Text",
    Desc = "Restore text settings to defaults",
    Icon = "rotate-ccw",
    Callback = function()
        for _, Key in ipairs({
            "NameSize", "DistanceSize", "HeightSize",
            "TextMode", "DynamicTextMode", "DynamicTextCurve",
            "NameMinSize", "NameMaxSize", "DistanceMinSize", "DistanceMaxSize",
        }) do
            Settings[Key] = DEFAULT_SETTINGS[Key]
        end
        WindUI:Notify({
            Title = "Text Reset",
            Content = "Text settings restored",
            Icon = "check",
            Duration = 2,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- COLORS TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Colors:Paragraph({
    Title = "ESP Colors",
    Desc = "Customize every color independently. 3D boxes use the same colors as 2D boxes.",
    Image = "palette",
    ImageSize = 20,
})

local function CreateColorPicker(Parent, Title, Description, Key)
    Parent:Colorpicker({
        Title = Title,
        Desc = Description,
        Default = Colors[Key],
        Transparency = 0,
        Callback = function(Color)
            if typeof(Color) == "Color3" then
                Colors[Key] = Color
            end
        end,
    })
end

-- Highlight Colors
local HighlightColors = Tabs.Colors:Section({
    Title = "Highlight",
    Icon = "eye",
    Opened = true,
    Box = true,
})

CreateColorPicker(HighlightColors, "Enemy Visible", "Visible enemy highlight", "EnemyVisible")
CreateColorPicker(HighlightColors, "Enemy Behind Wall", "Hidden enemy highlight", "EnemyHidden")
CreateColorPicker(HighlightColors, "Teammate Visible", "Visible teammate highlight", "TeamVisible")
CreateColorPicker(HighlightColors, "Teammate Behind Wall", "Hidden teammate highlight", "TeamHidden")

-- Text Colors
local TextColors = Tabs.Colors:Section({
    Title = "Text",
    Icon = "type",
    Opened = true,
    Box = true,
})

CreateColorPicker(TextColors, "Enemy Name", "Enemy name text color", "EnemyName")
CreateColorPicker(TextColors, "Teammate Name", "Teammate name text color", "TeamName")
CreateColorPicker(TextColors, "Enemy Distance", "Enemy distance text color", "EnemyDistance")
CreateColorPicker(TextColors, "Teammate Distance", "Teammate distance text color", "TeamDistance")

-- Box Colors (shared 2D + 3D)
local BoxColors = Tabs.Colors:Section({
    Title = "2D & 3D Boxes",
    Icon = "square",
    Opened = true,
    Box = true,
})

CreateColorPicker(BoxColors, "Enemy Visible", "Visible enemy box", "EnemyBoxVisible")
CreateColorPicker(BoxColors, "Enemy Behind Wall", "Hidden enemy box", "EnemyBoxHidden")
CreateColorPicker(BoxColors, "Teammate Visible", "Visible teammate box", "TeamBoxVisible")
CreateColorPicker(BoxColors, "Teammate Behind Wall", "Hidden teammate box", "TeamBoxHidden")

-- Tracer Colors
local TracerColors = Tabs.Colors:Section({
    Title = "Tracers",
    Icon = "move",
    Opened = true,
    Box = true,
})

CreateColorPicker(TracerColors, "Enemy Visible", "Visible enemy tracer", "EnemyTracerVisible")
CreateColorPicker(TracerColors, "Enemy Behind Wall", "Hidden enemy tracer", "EnemyTracerHidden")
CreateColorPicker(TracerColors, "Teammate Visible", "Visible teammate tracer", "TeamTracerVisible")
CreateColorPicker(TracerColors, "Teammate Behind Wall", "Hidden teammate tracer", "TeamTracerHidden")

-- Misc Colors
local MiscColors = Tabs.Colors:Section({
    Title = "Misc",
    Icon = "settings-2",
    Opened = true,
    Box = true,
})

CreateColorPicker(MiscColors, "Group Count", "Text color for box grouping count label", "GroupCount")

-- Reset Colors
local ColorsResetSection = Tabs.Colors:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true,
})

ColorsResetSection:Divider()

ColorsResetSection:Button({
    Title = "Reset Colors",
    Desc = "Restore all colors to defaults",
    Icon = "rotate-ccw",
    Callback = function()
        ResetColors()
        WindUI:Notify({
            Title = "Colors Reset",
            Content = "All colors restored",
            Icon = "check",
            Duration = 2,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════════════════

Tabs.Settings:Paragraph({
    Title = "Interface",
    Desc = "Customize the interface theme and perform a complete reset.",
    Image = "settings",
    ImageSize = 20,
})

local AppearanceSection = Tabs.Settings:Section({
    Title = "Appearance",
    Icon = "palette",
    Opened = true,
    Box = true,
})

local Themes = {}
for ThemeName in pairs(WindUI:GetThemes()) do
    table.insert(Themes, ThemeName)
end
table.sort(Themes)

local ThemeDropdown = AppearanceSection:Dropdown({
    Title = "Theme",
    Desc = "Choose interface color theme",
    Values = Themes,
    Value = "Dark",
    SearchBarEnabled = true,
    MenuWidth = 280,
    Callback = function(Theme)
        if Theme then WindUI:SetTheme(Theme) end
    end,
})

AppearanceSection:Button({
    Title = "Reset Theme",
    Desc = "Return to Dark theme",
    Icon = "rotate-ccw",
    Callback = function()
        WindUI:SetTheme("Dark")
        if ThemeDropdown and ThemeDropdown.Select then
            ThemeDropdown:Select("Dark")
        end
    end,
})

local ResetAllSection = Tabs.Settings:Section({
    Title = "Complete Reset",
    Icon = "refresh-cw",
    Opened = true,
    Box = true,
})

ResetAllSection:Paragraph({
    Title = "Reset Everything",
    Desc = "Restore ESP, profiles, colors, text and interface theme to defaults.",
    Image = "info",
    ImageSize = 18,
})

ResetAllSection:Divider()

ResetAllSection:Button({
    Title = "Reset All",
    Desc = "Restore the complete configuration",
    Icon = "refresh-cw",
    Callback = function()
        ResetSettings()
        ResetColors()
        ResetSideSettings()
        RefreshSideControls()

        for _, Data in pairs(ESPObjects) do
            ClearHighlights(Data)
            Data.HighlightMode = nil
            Data.Visibility = nil
        end

        WindUI:SetTheme("Dark")
        if ThemeDropdown and ThemeDropdown.Select then
            ThemeDropdown:Select("Dark")
        end

        WindUI:Notify({
            Title = "Everything Reset",
            Content = "All settings restored to defaults",
            Icon = "check",
            Duration = 2,
        })
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

-- Count label pool for box grouping
local CountLabelPool = {}

local function GetCountLabel()
    for _, label in ipairs(CountLabelPool) do
        if not label.Visible then
            return label
        end
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
        and LocalPlayer.Team
        and Player.Team
        and LocalPlayer.Team == Player.Team then
        return "Teammate"
    end
    return "Enemy"
end

local function IsFeatureEnabled(Side, Feature, Distance)
    local Data = SideSettings[Side][Feature]
    if not Data then return false end
    if not Data.Enabled then return false end
    if Data.NearDisable and Distance <= Data.NearDistance then
        return false
    end
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
    local Parts = GetBodyParts(Character)
    local UseBodyParts = Settings.BodyPartRaycast
        and (not Settings.BodyPartRaycastFallback or Distance <= Settings.BodyPartRaycastDistance)

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
    for _, Part in ipairs(Parts) do
        local Visible = IsPartVisible(Character, Part, Origin)
        VisibleParts[Part] = Visible
        if Visible then AnyVisible = true end
    end
    return { AnyVisible = AnyVisible, Parts = VisibleParts, UseBodyParts = true }
end

-- Color functions
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

local function GetBoxColor(Player, Visible)
    if GetSide(Player) == "Teammate" then
        return Visible and Colors.TeamBoxVisible or Colors.TeamBoxHidden
    end
    return Visible and Colors.EnemyBoxVisible or Colors.EnemyBoxHidden
end

local function GetTracerColor(Player, Visible)
    if GetSide(Player) == "Teammate" then
        return Visible and Colors.TeamTracerVisible or Colors.TeamTracerHidden
    end
    return Visible and Colors.EnemyTracerVisible or Colors.EnemyTracerHidden
end

local function GetHeightColor(Player)
    return GetDistanceColor(Player)
end

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

local function GetNameSize(Distance)
    return GetDynamicSize(Distance, Settings.NameMinSize, Settings.NameMaxSize) or Settings.NameSize
end

local function GetDistanceSize(Distance)
    return GetDynamicSize(Distance, Settings.DistanceMinSize, Settings.DistanceMaxSize) or Settings.DistanceSize
end

local function GetHeightSize(Distance)
    return GetDynamicSize(Distance, Settings.DistanceMinSize, Settings.DistanceMaxSize) or Settings.HeightSize
end

-- 3D box corner calculation
local function GetBoxCorners(cf, size)
    local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
    return {
        cf:PointToWorldSpace(Vector3.new(-hx, -hy, -hz)), -- 1
        cf:PointToWorldSpace(Vector3.new( hx, -hy, -hz)), -- 2
        cf:PointToWorldSpace(Vector3.new(-hx, -hy,  hz)), -- 3
        cf:PointToWorldSpace(Vector3.new( hx, -hy,  hz)), -- 4
        cf:PointToWorldSpace(Vector3.new(-hx,  hy, -hz)), -- 5
        cf:PointToWorldSpace(Vector3.new( hx,  hy, -hz)), -- 6
        cf:PointToWorldSpace(Vector3.new(-hx,  hy,  hz)), -- 7
        cf:PointToWorldSpace(Vector3.new( hx,  hy,  hz)), -- 8
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

local function BuildHighlights(Data, Character)
    ClearHighlights(Data)
    for _, Part in ipairs(GetBodyParts(Character)) do
        Data.Highlights[Part] = CreateHighlight(Part)
    end
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
    if Settings.BoxMode == "Accurate" then
        return GetAccurateBounds(Character)
    end
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
        while parent[i] ~= i do
            parent[i] = parent[parent[i]]
            i = parent[i]
        end
        return i
    end

    local function union(i, j)
        local ri, rj = find(i), find(j)
        if ri ~= rj then parent[ri] = rj end
    end

    for i = 1, #boxes do
        for j = i + 1, #boxes do
            local a, b = boxes[i], boxes[j]
            if a.minX <= b.maxX and b.minX <= a.maxX
               and a.minY <= b.maxY and b.minY <= a.maxY then
                union(i, j)
            end
        end
    end

    local groupMap = {}
    for i, box in ipairs(boxes) do
        local root = find(i)
        if not groupMap[root] then
            groupMap[root] = {
                boxes = {},
                minX = box.minX, minY = box.minY,
                maxX = box.maxX, maxY = box.maxY,
                count = 0,
            }
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
    for _, g in pairs(groupMap) do
        groups[#groups + 1] = g
    end
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

    if Data.Box3DLines then
        for _, line in ipairs(Data.Box3DLines) do
            line.Visible = false
        end
    end
    if Data.Tracer then
        Data.Tracer.Visible = false
    end

    Data.ScreenBounds = nil
    Data.BoxVisible = false

    ClearHighlights(Data)
    Data.HighlightMode = nil
end

local function CreateESP(Player)
    if Player == LocalPlayer or ESPObjects[Player] then return end

    -- Billboard for text
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

    -- Name label
    local Name = Instance.new("TextLabel")
    Name.Name = "Name"
    Name.Size = UDim2.new(1, 0, 0, 30)
    Name.Position = UDim2.fromOffset(0, 0)
    Name.BackgroundTransparency = 1
    Name.Text = Player.DisplayName
    Name.TextColor3 = Colors.EnemyName
    Name.TextSize = Settings.NameSize
    Name.TextTransparency = 0
    Name.TextStrokeTransparency = 0.35
    Name.TextXAlignment = Enum.TextXAlignment.Center
    Name.Font = Enum.Font.GothamBold
    Name.Visible = false
    Name.Parent = Billboard

    -- Distance label
    local Distance = Instance.new("TextLabel")
    Distance.Name = "Distance"
    Distance.Size = UDim2.new(1, 0, 0, 20)
    Distance.Position = UDim2.fromOffset(0, 30)
    Distance.BackgroundTransparency = 1
    Distance.TextColor3 = Colors.EnemyDistance
    Distance.TextSize = Settings.DistanceSize
    Distance.TextTransparency = 0
    Distance.TextStrokeTransparency = 0.5
    Distance.TextXAlignment = Enum.TextXAlignment.Center
    Distance.Font = Enum.Font.GothamMedium
    Distance.Visible = false
    Distance.Parent = Billboard

    -- Height label
    local Height = Instance.new("TextLabel")
    Height.Name = "Height"
    Height.Size = UDim2.new(1, 0, 0, 20)
    Height.Position = UDim2.fromOffset(0, 50)
    Height.BackgroundTransparency = 1
    Height.TextColor3 = Colors.EnemyDistance
    Height.TextSize = Settings.HeightSize
    Height.TextTransparency = 0
    Height.TextStrokeTransparency = 0.5
    Height.TextXAlignment = Enum.TextXAlignment.Center
    Height.Font = Enum.Font.GothamMedium
    Height.Visible = false
    Height.Parent = Billboard

    -- 2D box
    local Box, BoxStroke = CreateBox()

    -- 3D box lines (lazy creation in Update3DBox)
    local Box3DLines = nil
    if HasDrawing then
        Box3DLines = {}
        for i = 1, 12 do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Visible = false
            Box3DLines[i] = line
        end
    end

    -- Tracer line
    local Tracer = nil
    if HasDrawing then
        Tracer = Drawing.new("Line")
        Tracer.Thickness = 1
        Tracer.Visible = false
    end

    local Data = {
        Billboard = Billboard,
        Name = Name,
        Distance = Distance,
        Height = Height,
        Box = Box,
        BoxStroke = BoxStroke,
        Box3DLines = Box3DLines,
        Tracer = Tracer,
        Highlights = {},
        FullHighlight = nil,
        Character = nil,
        Connection = nil,
        Visibility = nil,
        HighlightMode = nil,
        ScreenBounds = nil,
        BoxColor = nil,
        BoxVisible = false,
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
        if Character and Root and Player.Parent == Players then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Distance = (MyRoot.Position - Root.Position).Magnitude
                local Side = GetSide(Player)
                if Distance <= Settings.HighlightDistance
                   and IsFeatureEnabled(Side, "Highlight", Distance) then
                    local PartCount = #GetBodyParts(Character)
                    Candidates[#Candidates + 1] = {
                        Player = Player, Data = Data,
                        Distance = Distance, PartCount = PartCount,
                    }
                else
                    ClearHighlights(Data)
                    Data.HighlightMode = nil
                end
            else
                ClearHighlights(Data)
                Data.HighlightMode = nil
            end
        else
            ClearHighlights(Data)
            Data.HighlightMode = nil
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
        if not Candidate.Data.HighlightMode then
            ClearHighlights(Candidate.Data)
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
        local Color = GetHighlightColor(Player, Visibility.AnyVisible)
        SetFullHighlight(Data, Data.Character, Color)
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

    local ExistingParts = {}
    for _, Part in ipairs(GetBodyParts(Data.Character)) do
        ExistingParts[Part] = true
        local Visible
        if not Settings.VisibilityCheck then
            Visible = true
        elseif Visibility.UseBodyParts then
            Visible = Visibility.Parts[Part] == true
        else
            Visible = Visibility.AnyVisible
        end
        local Color = GetHighlightColor(Player, Visible)
        SetBodyPartHighlight(Data, Part, Color)
    end

    for Part, Highlight in pairs(Data.Highlights) do
        if not ExistingParts[Part] or not Part.Parent then
            Highlight:Destroy()
            Data.Highlights[Part] = nil
        end
    end
end

local function Update3DBox(Player, Data, Character, Distance, Side, Visibility)
    if not Data.Box3DLines then return end

    if not Settings.Box3D or not Settings.ESP
       or Distance > Settings.Box3DDistance
       or not IsFeatureEnabled(Side, "Box3D", Distance) then
        for _, line in ipairs(Data.Box3DLines) do
            line.Visible = false
        end
        return
    end

    local cf, size
    local ok = pcall(function()
        cf, size = Character:GetBoundingBox()
    end)
    if not ok or not cf then
        for _, line in ipairs(Data.Box3DLines) do
            line.Visible = false
        end
        return
    end

    local Camera = workspace.CurrentCamera
    if not Camera then return end

    local corners = GetBoxCorners(cf, size)
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
            line.Visible = true
        else
            line.Visible = false
        end
    end
end

local function UpdateTracer(Player, Data, Distance, Side, Visibility)
    if not Data.Tracer then return end

    if not Settings.Tracers or not Settings.ESP
       or Distance > Settings.TracerDistance
       or not IsFeatureEnabled(Side, "Tracer", Distance) then
        Data.Tracer.Visible = false
        return
    end

    local Camera = workspace.CurrentCamera
    if not Camera then return end

    local root = GetRoot(Data.Character)
    if not root then
        Data.Tracer.Visible = false
        return
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen or screenPos.Z <= 0 then
        Data.Tracer.Visible = false
        return
    end

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
    else -- Bottom
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    end

    Data.Tracer.From = origin
    Data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    Data.Tracer.Color = GetTracerColor(Player, Visibility.AnyVisible)
    Data.Tracer.Thickness = Settings.TracerThickness
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

    local NameEnabled = Settings.ShowName
        and Distance <= Settings.ESPDistance
        and IsFeatureEnabled(Side, "Name", Distance)

    local DistanceEnabled = Settings.ShowDistance
        and Distance <= Settings.ESPDistance
        and IsFeatureEnabled(Side, "Distance", Distance)

    local HeightEnabled = Settings.ShowHeight
        and Distance <= Settings.ESPDistance
        and IsFeatureEnabled(Side, "Height", Distance)

    Data.Billboard.Adornee = Root
    Data.Billboard.MaxDistance = MAX_DISTANCE
    Data.Billboard.AlwaysOnTop = true

    -- Name
    Data.Name.Text = Player.DisplayName
    Data.Name.TextSize = GetNameSize(Distance)
    Data.Name.TextColor3 = GetNameColor(Player)
    Data.Name.Visible = NameEnabled

    -- Distance
    Data.Distance.TextSize = GetDistanceSize(Distance)
    Data.Distance.TextColor3 = GetDistanceColor(Player)
    if DistanceEnabled then
        Data.Distance.Text = tostring(math.floor(Distance + 0.5)) .. " studs"
    else
        Data.Distance.Text = ""
    end
    Data.Distance.Visible = DistanceEnabled

    -- Height
    Data.Height.TextSize = GetHeightSize(Distance)
    Data.Height.TextColor3 = GetHeightColor(Player)
    if HeightEnabled then
        Data.Height.Text = string.format("Y: %.1f", Root.Position.Y)
    else
        Data.Height.Text = ""
    end
    Data.Height.Visible = HeightEnabled

    Data.Billboard.Enabled = NameEnabled or DistanceEnabled or HeightEnabled
end

local function UpdateBoxes()
    -- Hide all count labels
    for _, label in ipairs(CountLabelPool) do
        label.Visible = false
    end

    if not Settings.Boxes or not Settings.ESP then
        for _, data in pairs(ESPObjects) do
            if data.Box then data.Box.Visible = false end
        end
        return
    end

    -- No grouping: draw individual boxes
    if not Settings.BoxGrouping then
        for _, data in pairs(ESPObjects) do
            if data.ScreenBounds and data.BoxVisible and data.Box then
                local sb = data.ScreenBounds
                data.Box.Position = UDim2.fromOffset(sb.minX, sb.minY)
                data.Box.Size = UDim2.fromOffset(
                    math.max(sb.maxX - sb.minX, 2),
                    math.max(sb.maxY - sb.minY, 2)
                )
                data.BoxStroke.Color = data.BoxColor or Color3.fromRGB(255, 255, 255)
                data.Box.Visible = true
            elseif data.Box then
                data.Box.Visible = false
            end
        end
        return
    end

    -- Grouping enabled: collect visible boxes
    local visibleBoxes = {}
    for player, data in pairs(ESPObjects) do
        if data.ScreenBounds and data.BoxVisible then
            visibleBoxes[#visibleBoxes + 1] = {
                player = player,
                data = data,
                minX = data.ScreenBounds.minX,
                minY = data.ScreenBounds.minY,
                maxX = data.ScreenBounds.maxX,
                maxY = data.ScreenBounds.maxY,
            }
        end
    end

    if #visibleBoxes == 0 then
        for _, data in pairs(ESPObjects) do
            if data.Box then data.Box.Visible = false end
        end
        return
    end

    local groups = GroupBoxes(visibleBoxes)

    for _, group in ipairs(groups) do
        if group.count > 1 then
            -- Merged box: use first player's box frame
            local first = group.boxes[1]
            first.data.Box.Position = UDim2.fromOffset(group.minX, group.minY)
            first.data.Box.Size = UDim2.fromOffset(
                math.max(group.maxX - group.minX, 2),
                math.max(group.maxY - group.minY, 2)
            )
            first.data.BoxStroke.Color = first.data.BoxColor or Colors.GroupCount
            first.data.Box.Visible = true

            -- Hide other boxes in the group
            for i = 2, #group.boxes do
                if group.boxes[i].data.Box then
                    group.boxes[i].data.Box.Visible = false
                end
            end

            -- Count label
            local label = GetCountLabel()
            label.Text = "\xC3\x97" .. group.count
            label.Position = UDim2.fromOffset(
                math.floor((group.minX + group.maxX) / 2),
                math.floor(group.minY - 18)
            )
            label.TextColor3 = Colors.GroupCount
            label.Visible = true
        else
            -- Individual box
            local box = group.boxes[1]
            if box.data.Box then
                box.data.Box.Position = UDim2.fromOffset(box.minX, box.minY)
                box.data.Box.Size = UDim2.fromOffset(
                    math.max(box.maxX - box.minX, 2),
                    math.max(box.maxY - box.minY, 2)
                )
                box.data.BoxStroke.Color = box.data.BoxColor or Color3.fromRGB(255, 255, 255)
                box.data.Box.Visible = true
            end
        end
    end

    -- Hide boxes for players not in any group
    local drawnData = {}
    for _, group in ipairs(groups) do
        for _, box in ipairs(group.boxes) do
            drawnData[box.data] = true
        end
    end
    for _, data in pairs(ESPObjects) do
        if not drawnData[data] and data.Box then
            data.Box.Visible = false
        end
    end
end

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
        ClearHighlights(Data)
    end

    Data.Billboard.Adornee = Root

    local Distance = (MyRoot.Position - Root.Position).Magnitude
    local Side = GetSide(Player)

    if Settings.VisibilityCheck then
        Data.Visibility = GetVisibility(Character, Distance)
    else
        Data.Visibility = { AnyVisible = true, Parts = {}, UseBodyParts = false }
    end

    -- Text
    UpdateText(Player, Data, Distance, Side)

    -- Highlights
    UpdateHighlights(Player, Data, Distance, Side, Data.Visibility)

    -- Calculate box bounds (store, don't draw — drawn in UpdateBoxes)
    local boxEnabled = Settings.Boxes
        and Settings.ESP
        and Distance <= Settings.BoxDistance
        and IsFeatureEnabled(Side, "Box", Distance)

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

    -- 3D box
    Update3DBox(Player, Data, Character, Distance, Side, Data.Visibility)

    -- Tracer
    UpdateTracer(Player, Data, Distance, Side, Data.Visibility)
end

-- ═══════════════════════════════════════════════════════════
-- PLAYER CONNECTIONS
-- ═══════════════════════════════════════════════════════════

for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
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

    -- Draw 2D boxes with grouping (after all players are updated)
    UpdateBoxes()
end)