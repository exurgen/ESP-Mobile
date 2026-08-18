local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ============================================================
-- Константы и значения по умолчанию
-- ============================================================
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

-- Новые настройки
local MIN_LINE_DISTANCE = 50
local MAX_LINE_DISTANCE = 2000
local DEFAULT_LINE_DISTANCE = 1000

local MIN_GROUP_PIXELS = 0
local MAX_GROUP_PIXELS = 200
local DEFAULT_GROUP_PIXELS = 20

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

    -- Новые цвета
    LineEnemy = Color3.fromRGB(255, 255, 255),
    LineTeam = Color3.fromRGB(255, 255, 255),
    GroupBox = Color3.fromRGB(255, 255, 255)
}

local Colors = {}

local function ResetColors()
    for Name, Color in pairs(DEFAULT_COLORS) do
        Colors[Name] = Color
    end
end

ResetColors()

local DEFAULT_SETTINGS = {
    ESP = true,
    VisibilityCheck = true,
    BodyPartRaycast = true,
    BodyPartRaycastFallback = false,
    TeamCheck = true,

    ShowName = true,
    ShowDistance = true,
    ShowHeight = true,
    ShowLines = true,

    Highlight = true,
    Boxes = true,
    Boxes3D = true,
    GroupBoxes = true,

    ESPDistance = DEFAULT_DISTANCE,
    HighlightDistance = DEFAULT_DISTANCE,
    BoxDistance = DEFAULT_DISTANCE,
    Box3DDistance = DEFAULT_DISTANCE,
    LineDistance = DEFAULT_LINE_DISTANCE,

    BodyPartRaycastDistance = 500,

    NameSize = DEFAULT_NAME_SIZE,
    DistanceSize = DEFAULT_DISTANCE_SIZE,

    TextMode = "Standard",
    DynamicTextMode = "Far Bigger",
    DynamicTextCurve = DEFAULT_TEXT_CURVE,

    NameMinSize = MIN_NAME_SIZE,
    NameMaxSize = MAX_NAME_SIZE,

    DistanceMinSize = MIN_DISTANCE_SIZE,
    DistanceMaxSize = MAX_DISTANCE_SIZE,

    BoxMode = "Accurate",

    RayOrigin = "Character",

    GroupPixelDistance = DEFAULT_GROUP_PIXELS
}

local Settings = {}

local function ResetSettings()
    for Name, Value in pairs(DEFAULT_SETTINGS) do
        Settings[Name] = Value
    end
end

ResetSettings()

-- ============================================================
-- Настройки сторон (враги / союзники)
-- ============================================================
local DEFAULT_SIDE_SETTINGS = {
    Highlight = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    },

    Box = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    },

    Box3D = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    },

    Name = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    },

    Distance = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    },

    Height = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    },

    Line = {
        Enabled = true,
        NearDisable = false,
        NearDistance = 100
    }
}

local function CopySideSettings()
    local Result = {}

    for Name, Data in pairs(DEFAULT_SIDE_SETTINGS) do
        Result[Name] = {
            Enabled = Data.Enabled,
            NearDisable = Data.NearDisable,
            NearDistance = Data.NearDistance
        }
    end

    return Result
end

local SideSettings = {
    Enemy = CopySideSettings(),
    Teammate = CopySideSettings()
}

local function ResetSideSettings()
    SideSettings.Enemy = CopySideSettings()
    SideSettings.Teammate = CopySideSettings()
end

-- ============================================================
-- Глобальные объекты
-- ============================================================
local ESPObjects = {}
local GroupBoxPool = {}

local BodyPartNames = {
    "Head",
    "UpperTorso",
    "LowerTorso",
    "Torso",

    "LeftUpperArm",
    "LeftLowerArm",
    "LeftHand",

    "RightUpperArm",
    "RightLowerArm",
    "RightHand",

    "LeftUpperLeg",
    "LeftLowerLeg",
    "LeftFoot",

    "RightUpperLeg",
    "RightLowerLeg",
    "RightFoot",

    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg",

    "HumanoidRootPart"
}

-- ============================================================
-- Создание интерфейса
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "PLAYER ESP",
    Icon = "eye",
    Author = "Mobile ESP",
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
        Anonymous = false
    }
})

local Sections = {
    About = Window:Section({
        Title = "ABOUT",
        Opened = true
    }),

    Features = Window:Section({
        Title = "FEATURES",
        Opened = true
    }),

    Settings = Window:Section({
        Title = "SETTINGS",
        Opened = true
    })
}

local Tabs = {
    About = Sections.About:Tab({
        Title = "About",
        Icon = "house",
        Desc = "Information about Player ESP"
    }),

    ESP = Sections.Features:Tab({
        Title = "ESP",
        Icon = "eye",
        Desc = "Main ESP features"
    }),

    Sides = Sections.Features:Tab({
        Title = "Sides",
        Icon = "users",
        Desc = "Enemy and teammate settings"
    }),

    Detection = Sections.Features:Tab({
        Title = "Detection",
        Icon = "scan-search",
        Desc = "Visibility detection"
    }),

    Text = Sections.Features:Tab({
        Title = "Text",
        Icon = "type",
        Desc = "Text appearance"
    }),

    Colors = Sections.Features:Tab({
        Title = "Colors",
        Icon = "palette",
        Desc = "ESP colors"
    }),

    Settings = Sections.Settings:Tab({
        Title = "Settings",
        Icon = "settings",
        Desc = "Interface settings"
    })
}

-- ============================================================
-- Вкладка About
-- ============================================================
Tabs.About:Paragraph({
    Title = "PLAYER ESP",
    Desc = "Customizable player visualization system",
    Image = "eye",
    ImageSize = 26
})

local AboutSection = Tabs.About:Section({
    Title = "Overview",
    Icon = "info",
    Opened = true,
    Box = true
})

AboutSection:Paragraph({
    Title = "ESP",
    Desc = "Names, distance, height, 3D boxes, 2D boxes and lines.",
    Image = "eye",
    ImageSize = 18
})

AboutSection:Paragraph({
    Title = "Detection",
    Desc = "Body-part or normal raycasting with selectable origin.",
    Image = "scan-search",
    ImageSize = 18
})

AboutSection:Paragraph({
    Title = "Profiles",
    Desc = "Independent enemy and teammate settings.",
    Image = "users",
    ImageSize = 18
})

AboutSection:Paragraph({
    Title = "Customization",
    Desc = "Dynamic text, custom colors and multiple box modes.",
    Image = "palette",
    ImageSize = 18
})

-- ============================================================
-- Вкладка ESP
-- ============================================================
local ESPSection = Tabs.ESP:Section({
    Title = "Features",
    Icon = "scan",
    Opened = true,
    Box = true
})

ESPSection:Toggle({
    Title = "ESP",
    Desc = "Enable player ESP",
    Value = Settings.ESP,
    Callback = function(Value)
        Settings.ESP = Value
    end
})

ESPSection:Toggle({
    Title = "Names",
    Desc = "Show player names",
    Value = Settings.ShowName,
    Callback = function(Value)
        Settings.ShowName = Value
    end
})

ESPSection:Toggle({
    Title = "Distance",
    Desc = "Show player distance",
    Value = Settings.ShowDistance,
    Callback = function(Value)
        Settings.ShowDistance = Value
    end
})

ESPSection:Toggle({
    Title = "Height",
    Desc = "Show player height in studs",
    Value = Settings.ShowHeight,
    Callback = function(Value)
        Settings.ShowHeight = Value
    end
})

ESPSection:Toggle({
    Title = "Highlight",
    Desc = "Highlight player body parts",
    Value = Settings.Highlight,
    Callback = function(Value)
        Settings.Highlight = Value
    end
})

ESPSection:Toggle({
    Title = "2D Boxes",
    Desc = "Draw a box around players",
    Value = Settings.Boxes,
    Callback = function(Value)
        Settings.Boxes = Value
    end
})

ESPSection:Toggle({
    Title = "3D Boxes",
    Desc = "Draw a 3D box around players",
    Value = Settings.Boxes3D,
    Callback = function(Value)
        Settings.Boxes3D = Value
    end
})

ESPSection:Toggle({
    Title = "Lines",
    Desc = "Draw lines from your player to others",
    Value = Settings.ShowLines,
    Callback = function(Value)
        Settings.ShowLines = Value
    end
})

ESPSection:Toggle({
    Title = "Group Boxes",
    Desc = "Merge overlapping 2D boxes and show count",
    Value = Settings.GroupBoxes,
    Callback = function(Value)
        Settings.GroupBoxes = Value
    end
})

ESPSection:Toggle({
    Title = "Team Check",
    Desc = "Separate enemies and teammates",
    Value = Settings.TeamCheck,
    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

local DistanceSection = Tabs.ESP:Section({
    Title = "Distances",
    Icon = "maximize",
    Opened = true,
    Box = true
})

DistanceSection:Slider({
    Title = "Text Distance",
    Desc = "Maximum distance for text",
    Value = {
        Min = MIN_DISTANCE,
        Max = MAX_DISTANCE,
        Default = DEFAULT_DISTANCE
    },
    Step = 1,
    Callback = function(Value)
        Settings.ESPDistance = Value
    end
})

DistanceSection:Slider({
    Title = "Highlight Distance",
    Desc = "Maximum highlight distance",
    Value = {
        Min = MIN_DISTANCE,
        Max = MAX_DISTANCE,
        Default = DEFAULT_DISTANCE
    },
    Step = 1,
    Callback = function(Value)
        Settings.HighlightDistance = Value
    end
})

DistanceSection:Slider({
    Title = "2D Box Distance",
    Desc = "Maximum 2D box distance",
    Value = {
        Min = MIN_DISTANCE,
        Max = MAX_DISTANCE,
        Default = DEFAULT_DISTANCE
    },
    Step = 1,
    Callback = function(Value)
        Settings.BoxDistance = Value
    end
})

DistanceSection:Slider({
    Title = "3D Box Distance",
    Desc = "Maximum 3D box distance",
    Value = {
        Min = MIN_DISTANCE,
        Max = MAX_DISTANCE,
        Default = DEFAULT_DISTANCE
    },
    Step = 1,
    Callback = function(Value)
        Settings.Box3DDistance = Value
    end
})

DistanceSection:Slider({
    Title = "Line Distance",
    Desc = "Maximum line drawing distance",
    Value = {
        Min = MIN_LINE_DISTANCE,
        Max = MAX_LINE_DISTANCE,
        Default = DEFAULT_LINE_DISTANCE
    },
    Step = 1,
    Callback = function(Value)
        Settings.LineDistance = Value
    end
})

local BoxModeSection = Tabs.ESP:Section({
    Title = "2D Box Mode",
    Icon = "square",
    Opened = true,
    Box = true
})

BoxModeSection:Dropdown({
    Title = "Box Mode",
    Desc = "Choose box calculation method",
    Values = {
        "Performance",
        "Accurate"
    },
    Value = Settings.BoxMode,
    Callback = function(Value)
        Settings.BoxMode = Value
    end
})

BoxModeSection:Slider({
    Title = "Group Pixel Distance",
    Desc = "Max distance between box centers to merge",
    Value = {
        Min = MIN_GROUP_PIXELS,
        Max = MAX_GROUP_PIXELS,
        Default = DEFAULT_GROUP_PIXELS
    },
    Step = 1,
    Callback = function(Value)
        Settings.GroupPixelDistance = Value
    end
})

local ESPResetSection = Tabs.ESP:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true
})

ESPResetSection:Divider()

ESPResetSection:Button({
    Title = "Reset ESP",
    Desc = "Restore ESP features and distances",
    Icon = "rotate-ccw",
    Callback = function()
        Settings.ESP = DEFAULT_SETTINGS.ESP
        Settings.ShowName = DEFAULT_SETTINGS.ShowName
        Settings.ShowDistance = DEFAULT_SETTINGS.ShowDistance
        Settings.ShowHeight = DEFAULT_SETTINGS.ShowHeight
        Settings.ShowLines = DEFAULT_SETTINGS.ShowLines
        Settings.Highlight = DEFAULT_SETTINGS.Highlight
        Settings.Boxes = DEFAULT_SETTINGS.Boxes
        Settings.Boxes3D = DEFAULT_SETTINGS.Boxes3D
        Settings.GroupBoxes = DEFAULT_SETTINGS.GroupBoxes
        Settings.TeamCheck = DEFAULT_SETTINGS.TeamCheck

        Settings.ESPDistance = DEFAULT_SETTINGS.ESPDistance
        Settings.HighlightDistance = DEFAULT_SETTINGS.HighlightDistance
        Settings.BoxDistance = DEFAULT_SETTINGS.BoxDistance
        Settings.Box3DDistance = DEFAULT_SETTINGS.Box3DDistance
        Settings.LineDistance = DEFAULT_SETTINGS.LineDistance

        WindUI:Notify({
            Title = "ESP Reset",
            Content = "ESP settings restored",
            Icon = "check",
            Duration = 2
        })
    end
})

-- ============================================================
-- Вкладка Sides
-- ============================================================
Tabs.Sides:Paragraph({
    Title = "Side Profiles",
    Desc = "Configure enemy and teammate ESP independently.",
    Image = "users",
    ImageSize = 20
})

local SelectedSide = "Enemy"

Tabs.Sides:Dropdown({
    Title = "Side",
    Desc = "Choose a profile",
    Values = {
        "Enemy",
        "Teammate"
    },
    Value = SelectedSide,
    Callback = function(Value)
        SelectedSide = Value
    end
})

local SideSection = Tabs.Sides:Section({
    Title = "Elements",
    Icon = "layers-3",
    Opened = true,
    Box = true
})

local function CreateSideControl(Name, Title, Description)
    SideSection:Toggle({
        Title = Title,
        Desc = Description,
        Value = SideSettings.Enemy[Name].Enabled,
        Callback = function(Value)
            SideSettings[SelectedSide][Name].Enabled = Value
        end
    })

    SideSection:Toggle({
        Title = "Disable " .. Title .. " Near",
        Desc = "Hide this element at close range",
        Value = SideSettings.Enemy[Name].NearDisable,
        Callback = function(Value)
            SideSettings[SelectedSide][Name].NearDisable = Value
        end
    })

    SideSection:Slider({
        Title = Title .. " Near Distance",
        Desc = "Disable below this distance",
        Value = {
            Min = MIN_NEAR_DISTANCE,
            Max = MAX_NEAR_DISTANCE,
            Default = SideSettings.Enemy[Name].NearDistance
        },
        Step = 1,
        Callback = function(Value)
            SideSettings[SelectedSide][Name].NearDistance = Value
        end
    })

    SideSection:Divider()
end

CreateSideControl("Highlight", "Highlight", "Highlight player body")
CreateSideControl("Box", "2D Box", "Draw a rectangle around player")
CreateSideControl("Box3D", "3D Box", "Draw a 3D box around player")
CreateSideControl("Name", "Name", "Show player name")
CreateSideControl("Distance", "Distance", "Show player distance")
CreateSideControl("Height", "Height", "Show player height")
CreateSideControl("Line", "Line", "Draw a line from you to player")

local SidesResetSection = Tabs.Sides:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true
})

SidesResetSection:Divider()

SidesResetSection:Button({
    Title = "Reset Sides",
    Desc = "Restore Enemy and Teammate profiles",
    Icon = "rotate-ccw",
    Callback = function()
        ResetSideSettings()
        WindUI:Notify({
            Title = "Sides Reset",
            Content = "Enemy and Teammate profiles restored",
            Icon = "check",
            Duration = 2
        })
    end
})

-- ============================================================
-- Вкладка Detection
-- ============================================================
Tabs.Detection:Paragraph({
    Title = "Visibility Detection",
    Desc = "Control visibility and raycast behavior.",
    Image = "scan-search",
    ImageSize = 20
})

local DetectionSection = Tabs.Detection:Section({
    Title = "Raycast",
    Icon = "crosshair",
    Opened = true,
    Box = true
})

DetectionSection:Toggle({
    Title = "Visibility Check",
    Desc = "Check players behind walls",
    Value = Settings.VisibilityCheck,
    Callback = function(Value)
        Settings.VisibilityCheck = Value
    end
})

DetectionSection:Toggle({
    Title = "Body Part Raycast",
    Desc = "Check body parts individually",
    Value = Settings.BodyPartRaycast,
    Callback = function(Value)
        Settings.BodyPartRaycast = Value
    end
})

DetectionSection:Toggle({
    Title = "Automatic Fallback",
    Desc = "Switch to normal raycast farther away",
    Value = Settings.BodyPartRaycastFallback,
    Callback = function(Value)
        Settings.BodyPartRaycastFallback = Value
    end
})

DetectionSection:Slider({
    Title = "Fallback Distance",
    Desc = "Distance where normal raycast starts",
    Value = {
        Min = MIN_DISTANCE,
        Max = MAX_DISTANCE,
        Default = Settings.BodyPartRaycastDistance
    },
    Step = 1,
    Callback = function(Value)
        Settings.BodyPartRaycastDistance = Value
    end
})

DetectionSection:Dropdown({
    Title = "Raycast Origin",
    Desc = "Choose where rays start",
    Values = {
        "Character",
        "Camera"
    },
    Value = Settings.RayOrigin,
    Callback = function(Value)
        Settings.RayOrigin = Value
    end
})

local DetectionResetSection = Tabs.Detection:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true
})

DetectionResetSection:Divider()

DetectionResetSection:Button({
    Title = "Reset Detection",
    Desc = "Restore detection settings",
    Icon = "rotate-ccw",
    Callback = function()
        Settings.VisibilityCheck = DEFAULT_SETTINGS.VisibilityCheck
        Settings.BodyPartRaycast = DEFAULT_SETTINGS.BodyPartRaycast
        Settings.BodyPartRaycastFallback = DEFAULT_SETTINGS.BodyPartRaycastFallback
        Settings.BodyPartRaycastDistance = DEFAULT_SETTINGS.BodyPartRaycastDistance
        Settings.RayOrigin = DEFAULT_SETTINGS.RayOrigin
        WindUI:Notify({
            Title = "Detection Reset",
            Content = "Detection settings restored",
            Icon = "check",
            Duration = 2
        })
    end
})

-- ============================================================
-- Вкладка Text
-- ============================================================
Tabs.Text:Paragraph({
    Title = "Text",
    Desc = "Configure name, distance and height text.",
    Image = "type",
    ImageSize = 20
})

local TextModeSection = Tabs.Text:Section({
    Title = "Mode",
    Icon = "sliders-horizontal",
    Opened = true,
    Box = true
})

TextModeSection:Dropdown({
    Title = "Text Mode",
    Desc = "Choose standard or dynamic sizing",
    Values = {
        "Standard",
        "Dynamic"
    },
    Value = Settings.TextMode,
    Callback = function(Value)
        Settings.TextMode = Value
    end
})

TextModeSection:Dropdown({
    Title = "Dynamic Mode",
    Desc = "Ignored when Dynamic mode is disabled",
    Values = {
        "Far Bigger",
        "Far Smaller"
    },
    Value = Settings.DynamicTextMode,
    Callback = function(Value)
        Settings.DynamicTextMode = Value
    end
})

local BasicTextSection = Tabs.Text:Section({
    Title = "Basic Size",
    Icon = "text-cursor-input",
    Opened = true,
    Box = true
})

BasicTextSection:Slider({
    Title = "Name Size",
    Desc = "Standard name size",
    Value = {
        Min = MIN_NAME_SIZE,
        Max = MAX_NAME_SIZE,
        Default = DEFAULT_NAME_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.NameSize = Value
    end
})

BasicTextSection:Slider({
    Title = "Distance Size",
    Desc = "Standard distance size",
    Value = {
        Min = MIN_DISTANCE_SIZE,
        Max = MAX_DISTANCE_SIZE,
        Default = DEFAULT_DISTANCE_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.DistanceSize = Value
    end
})

BasicTextSection:Slider({
    Title = "Height Size",
    Desc = "Standard height text size",
    Value = {
        Min = MIN_DISTANCE_SIZE,
        Max = MAX_DISTANCE_SIZE,
        Default = DEFAULT_DISTANCE_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.HeightSize = Value
    end
})

local DynamicSection = Tabs.Text:Section({
    Title = "Dynamic Size",
    Icon = "move-diagonal-2",
    Opened = true,
    Box = true
})

DynamicSection:Slider({
    Title = "Curve",
    Desc = "Controls the size transition",
    Value = {
        Min = MIN_TEXT_CURVE,
        Max = MAX_TEXT_CURVE,
        Default = DEFAULT_TEXT_CURVE
    },
    Step = 0.05,
    Callback = function(Value)
        Settings.DynamicTextCurve = Value
    end
})

DynamicSection:Slider({
    Title = "Name Minimum",
    Desc = "Minimum dynamic name size",
    Value = {
        Min = MIN_NAME_SIZE,
        Max = MAX_NAME_SIZE,
        Default = MIN_NAME_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.NameMinSize = Value
    end
})

DynamicSection:Slider({
    Title = "Name Maximum",
    Desc = "Maximum dynamic name size",
    Value = {
        Min = MIN_NAME_SIZE,
        Max = MAX_NAME_SIZE,
        Default = MAX_NAME_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.NameMaxSize = Value
    end
})

DynamicSection:Slider({
    Title = "Distance Minimum",
    Desc = "Minimum dynamic distance size",
    Value = {
        Min = MIN_DISTANCE_SIZE,
        Max = MAX_DISTANCE_SIZE,
        Default = MIN_DISTANCE_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.DistanceMinSize = Value
    end
})

DynamicSection:Slider({
    Title = "Distance Maximum",
    Desc = "Maximum dynamic distance size",
    Value = {
        Min = MIN_DISTANCE_SIZE,
        Max = MAX_DISTANCE_SIZE,
        Default = MAX_DISTANCE_SIZE
    },
    Step = 1,
    Callback = function(Value)
        Settings.DistanceMaxSize = Value
    end
})

local TextResetSection = Tabs.Text:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true
})

TextResetSection:Divider()

TextResetSection:Button({
    Title = "Reset Text",
    Desc = "Restore text defaults",
    Icon = "rotate-ccw",
    Callback = function()
        Settings.NameSize = DEFAULT_SETTINGS.NameSize
        Settings.DistanceSize = DEFAULT_SETTINGS.DistanceSize
        Settings.HeightSize = DEFAULT_SETTINGS.DistanceSize
        Settings.TextMode = DEFAULT_SETTINGS.TextMode
        Settings.DynamicTextMode = DEFAULT_SETTINGS.DynamicTextMode
        Settings.DynamicTextCurve = DEFAULT_SETTINGS.DynamicTextCurve
        Settings.NameMinSize = DEFAULT_SETTINGS.NameMinSize
        Settings.NameMaxSize = DEFAULT_SETTINGS.NameMaxSize
        Settings.DistanceMinSize = DEFAULT_SETTINGS.DistanceMinSize
        Settings.DistanceMaxSize = DEFAULT_SETTINGS.DistanceMaxSize
        WindUI:Notify({
            Title = "Text Reset",
            Content = "Text settings restored",
            Icon = "check",
            Duration = 2
        })
    end
})

-- ============================================================
-- Вкладка Colors
-- ============================================================
Tabs.Colors:Paragraph({
    Title = "ESP Colors",
    Desc = "Customize ESP colors independently.",
    Image = "palette",
    ImageSize = 20
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
        end
    })
end

local HighlightColors = Tabs.Colors:Section({
    Title = "Highlight",
    Icon = "eye",
    Opened = true,
    Box = true
})

CreateColorPicker(HighlightColors, "Enemy Visible", "Visible enemy", "EnemyVisible")
CreateColorPicker(HighlightColors, "Enemy Behind Wall", "Hidden enemy", "EnemyHidden")
CreateColorPicker(HighlightColors, "Teammate Visible", "Visible teammate", "TeamVisible")
CreateColorPicker(HighlightColors, "Teammate Behind Wall", "Hidden teammate", "TeamHidden")

local TextColors = Tabs.Colors:Section({
    Title = "Text",
    Icon = "type",
    Opened = true,
    Box = true
})

CreateColorPicker(TextColors, "Enemy Name", "Enemy name", "EnemyName")
CreateColorPicker(TextColors, "Teammate Name", "Teammate name", "TeamName")
CreateColorPicker(TextColors, "Enemy Distance", "Enemy distance", "EnemyDistance")
CreateColorPicker(TextColors, "Teammate Distance", "Teammate distance", "TeamDistance")

local BoxColors = Tabs.Colors:Section({
    Title = "2D Boxes",
    Icon = "square",
    Opened = true,
    Box = true
})

CreateColorPicker(BoxColors, "Enemy Visible", "Visible enemy box", "EnemyBoxVisible")
CreateColorPicker(BoxColors, "Enemy Behind Wall", "Hidden enemy box", "EnemyBoxHidden")
CreateColorPicker(BoxColors, "Teammate Visible", "Visible teammate box", "TeamBoxVisible")
CreateColorPicker(BoxColors, "Teammate Behind Wall", "Hidden teammate box", "TeamBoxHidden")
CreateColorPicker(BoxColors, "Group Box", "Merged group box", "GroupBox")

local LinesColors = Tabs.Colors:Section({
    Title = "Lines",
    Icon = "line",
    Opened = true,
    Box = true
})

CreateColorPicker(LinesColors, "Enemy Line", "Line to enemy", "LineEnemy")
CreateColorPicker(LinesColors, "Teammate Line", "Line to teammate", "LineTeam")

local ColorsResetSection = Tabs.Colors:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true
})

ColorsResetSection:Divider()

ColorsResetSection:Button({
    Title = "Reset Colors",
    Desc = "Restore default colors",
    Icon = "rotate-ccw",
    Callback = function()
        ResetColors()
        WindUI:Notify({
            Title = "Colors Reset",
            Content = "All colors restored",
            Icon = "check",
            Duration = 2
        })
    end
})

-- ============================================================
-- Вкладка Settings
-- ============================================================
Tabs.Settings:Paragraph({
    Title = "Interface",
    Desc = "Customize the interface theme.",
    Image = "settings",
    ImageSize = 20
})

local AppearanceSection = Tabs.Settings:Section({
    Title = "Appearance",
    Icon = "palette",
    Opened = true,
    Box = true
})

local Themes = {}

for ThemeName in pairs(WindUI:GetThemes()) do
    table.insert(Themes, ThemeName)
end

table.sort(Themes)

local ThemeDropdown = AppearanceSection:Dropdown({
    Title = "Theme",
    Desc = "Choose interface theme",
    Values = Themes,
    Value = "Dark",
    SearchBarEnabled = true,
    MenuWidth = 280,
    Callback = function(Theme)
        if Theme then
            WindUI:SetTheme(Theme)
        end
    end
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
    end
})

local ResetAllSection = Tabs.Settings:Section({
    Title = "Reset All",
    Icon = "refresh-cw",
    Opened = true,
    Box = true
})

ResetAllSection:Paragraph({
    Title = "Complete Reset",
    Desc = "Restore ESP, profiles, colors and interface theme.",
    Image = "info",
    ImageSize = 18
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

        for _, Data in pairs(ESPObjects) do
            ClearHighlights(Data)
            Data.HighlightMode = nil
            Data.Visibility = nil
            if Data.Box3D then
                Data.Box3D.Visible = false
            end
            if Data.Line then
                Data.Line.Visible = false
            end
        end

        WindUI:SetTheme("Dark")
        if ThemeDropdown and ThemeDropdown.Select then
            ThemeDropdown:Select("Dark")
        end

        WindUI:Notify({
            Title = "Everything Reset",
            Content = "All settings restored",
            Icon = "check",
            Duration = 2
        })
    end
})

-- ============================================================
-- ESP GUI
-- ============================================================
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

-- ============================================================
-- Вспомогательные функции
-- ============================================================
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
        return {
            AnyVisible = true,
            Parts = {},
            UseBodyParts = false
        }
    end

    local Origin = GetRayOrigin()
    if not Origin then
        return {
            AnyVisible = false,
            Parts = {},
            UseBodyParts = false
        }
    end

    local Parts = GetBodyParts(Character)
    local UseBodyParts = Settings.BodyPartRaycast
        and (not Settings.BodyPartRaycastFallback
            or Distance <= Settings.BodyPartRaycastDistance)

    if not UseBodyParts then
        local Root = GetRoot(Character)
        if not Root then
            return { AnyVisible = false, Parts = {}, UseBodyParts = false }
        end
        local Visible = IsPartVisible(Character, Root, Origin)
        return {
            AnyVisible = Visible,
            Parts = { [Root] = Visible },
            UseBodyParts = false
        }
    end

    local VisibleParts = {}
    local AnyVisible = false
    for _, Part in ipairs(Parts) do
        local Visible = IsPartVisible(Character, Part, Origin)
        VisibleParts[Part] = Visible
        if Visible then AnyVisible = true end
    end

    return {
        AnyVisible = AnyVisible,
        Parts = VisibleParts,
        UseBodyParts = true
    }
end

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

local function GetLineColor(Player)
    return GetSide(Player) == "Teammate" and Colors.LineTeam or Colors.LineEnemy
end

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

local function GetHeightSize()
    return Settings.HeightSize or Settings.DistanceSize
end

local function GetCharacterHeight(Character)
    if Character and Character:IsA("Model") then
        local Size = Character:GetExtentsSize()
        return Size.Y
    end
    return 0
end

-- ============================================================
-- Создание / уничтожение ESP объектов
-- ============================================================
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

local function ClearHighlights(Data)
    for Part, Highlight in pairs(Data.Highlights) do
        if Highlight then
            Highlight:Destroy()
        end
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

local function BuildHighlights(Data, Character)
    ClearHighlights(Data)
    for _, Part in ipairs(GetBodyParts(Character)) do
        Data.Highlights[Part] = CreateHighlight(Part)
    end
end

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
                    local WorldPosition = Part.CFrame:PointToWorldSpace(
                        Vector3.new(Half.X * X, Half.Y * Y, Half.Z * Z)
                    )
                    local Position = Camera:WorldToViewportPoint(WorldPosition)
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

local function HideESP(Data)
    if Data.Billboard then Data.Billboard.Enabled = false end
    if Data.Name then Data.Name.Visible = false end
    if Data.Distance then Data.Distance.Visible = false end
    if Data.HeightLabel then Data.HeightLabel.Visible = false end
    if Data.Box then Data.Box.Visible = false end
    if Data.Box3D then Data.Box3D.Visible = false end
    if Data.Line then Data.Line.Visible = false end
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
    Name.Size = UDim2.new(1, 0, 0, 25)
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

    local Distance = Instance.new("TextLabel")
    Distance.Name = "Distance"
    Distance.Size = UDim2.new(1, 0, 0, 20)
    Distance.Position = UDim2.fromOffset(0, 25)
    Distance.BackgroundTransparency = 1
    Distance.TextColor3 = Colors.EnemyDistance
    Distance.TextSize = Settings.DistanceSize
    Distance.TextTransparency = 0
    Distance.TextStrokeTransparency = 0.5
    Distance.TextXAlignment = Enum.TextXAlignment.Center
    Distance.Font = Enum.Font.GothamMedium
    Distance.Visible = false
    Distance.Parent = Billboard

    local HeightLabel = Instance.new("TextLabel")
    HeightLabel.Name = "Height"
    HeightLabel.Size = UDim2.new(1, 0, 0, 20)
    HeightLabel.Position = UDim2.fromOffset(0, 45)
    HeightLabel.BackgroundTransparency = 1
    HeightLabel.TextColor3 = Colors.EnemyDistance
    HeightLabel.TextSize = Settings.HeightSize or Settings.DistanceSize
    HeightLabel.TextTransparency = 0
    HeightLabel.TextStrokeTransparency = 0.5
    HeightLabel.TextXAlignment = Enum.TextXAlignment.Center
    HeightLabel.Font = Enum.Font.GothamMedium
    HeightLabel.Visible = false
    HeightLabel.Parent = Billboard

    local Box, BoxStroke = CreateBox()

    -- 3D Box
    local Box3D = Instance.new("BoxHandleAdornment")
    Box3D.Name = "ESPBox3D"
    Box3D.Adornee = nil
    Box3D.AlwaysOnTop = true
    Box3D.ZIndex = 10
    Box3D.Transparency = 0.5
    Box3D.Color3 = Colors.EnemyBoxVisible
    Box3D.Size = Vector3.new(2, 5, 1)
    Box3D.Visible = false
    Box3D.Parent = workspace

    -- Line
    local Line = Instance.new("Frame")
    Line.Name = "Line"
    Line.BackgroundColor3 = Colors.LineEnemy
    Line.BorderSizePixel = 0
    Line.AnchorPoint = Vector2.new(0.5, 0.5)
    Line.Size = UDim2.fromOffset(1, 1)
    Line.Visible = false
    Line.ZIndex = 5
    Line.Parent = ESPGui

    local Data = {
        Billboard = Billboard,
        Name = Name,
        Distance = Distance,
        HeightLabel = HeightLabel,
        Box = Box,
        BoxStroke = BoxStroke,
        Box3D = Box3D,
        Line = Line,
        Highlights = {},
        FullHighlight = nil,
        Character = nil,
        Connection = nil,
        Visibility = nil,
        HighlightMode = nil,
        BoxBounds = nil,
        BoxShouldShow = false
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
        CurrentData.HeightLabel.Visible = false

        local Root = GetRoot(Character)
        if Root then
            CurrentData.Billboard.Adornee = Root
            if CurrentData.Box3D then
                CurrentData.Box3D.Adornee = Root
            end
        else
            CurrentData.Billboard.Adornee = nil
            if CurrentData.Box3D then
                CurrentData.Box3D.Adornee = nil
            end
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
                if CurrentData.Box3D then
                    CurrentData.Box3D.Adornee = Root
                end
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
    if Data.Box3D then Data.Box3D:Destroy() end
    if Data.Line then Data.Line:Destroy() end

    ESPObjects[Player] = nil
end

-- ============================================================
-- Обновление подсветки (бюджет)
-- ============================================================
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
                        Player = Player,
                        Data = Data,
                        Distance = Distance,
                        PartCount = PartCount
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

    table.sort(Candidates, function(A, B)
        return A.Distance < B.Distance
    end)

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

-- ============================================================
-- Обновление отдельных элементов
-- ============================================================
local function UpdateHighlights(Player, Data, Distance, Side, Visibility)
    local Mode = Data.HighlightMode
    if not Mode
        or not Settings.Highlight
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

local function UpdateBox(Player, Data, Character, Distance, Side, Visibility)
    if not Settings.Boxes
        or not Settings.ESP
        or Distance > Settings.BoxDistance
        or not IsFeatureEnabled(Side, "Box", Distance) then
        Data.BoxShouldShow = false
        Data.BoxBounds = nil
        Data.Box.Visible = false
        return
    end

    local MinX, MinY, MaxX, MaxY = GetScreenBounds(Character)
    if not MinX then
        Data.BoxShouldShow = false
        Data.BoxBounds = nil
        Data.Box.Visible = false
        return
    end

    Data.BoxBounds = { MinX = MinX, MinY = MinY, MaxX = MaxX, MaxY = MaxY }
    Data.BoxShouldShow = true
    Data.Box.Visible = false -- будет решено в UpdateGroupedBoxes
end

local function Update3DBox(Player, Data, Distance, Side, Visibility)
    if not Settings.Boxes3D
        or not Settings.ESP
        or Distance > Settings.Box3DDistance
        or not IsFeatureEnabled(Side, "Box3D", Distance) then
        if Data.Box3D then Data.Box3D.Visible = false end
        return
    end

    local Character = Data.Character
    local Root = GetRoot(Character)
    if not Character or not Root then
        if Data.Box3D then Data.Box3D.Visible = false end
        return
    end

    if Data.Box3D then
        Data.Box3D.Adornee = Root
        local Extents = Character:GetExtentsSize()
        Data.Box3D.Size = Vector3.new(
            math.max(Extents.X, 1),
            math.max(Extents.Y, 1),
            math.max(Extents.Z, 1)
        )
        Data.Box3D.Color3 = GetBoxColor(Player, Visibility.AnyVisible)
        Data.Box3D.Visible = true
    end
end

local function UpdateLine(Player, Data, Distance, Side, Visibility)
    if not Settings.ShowLines
        or not Settings.ESP
        or Distance > Settings.LineDistance
        or not IsFeatureEnabled(Side, "Line", Distance) then
        if Data.Line then Data.Line.Visible = false end
        return
    end

    local MyRoot = GetRoot(LocalPlayer.Character)
    local TargetRoot = GetRoot(Data.Character)
    if not MyRoot or not TargetRoot then
        if Data.Line then Data.Line.Visible = false end
        return
    end

    local Camera = workspace.CurrentCamera
    if not Camera then
        if Data.Line then Data.Line.Visible = false end
        return
    end

    local MyScreen = Camera:WorldToViewportPoint(MyRoot.Position)
    local TargetScreen = Camera:WorldToViewportPoint(TargetRoot.Position)

    if MyScreen.Z <= 0 or TargetScreen.Z <= 0 then
        if Data.Line then Data.Line.Visible = false end
        return
    end

    local dx = TargetScreen.X - MyScreen.X
    local dy = TargetScreen.Y - MyScreen.Y
    local length = math.sqrt(dx * dx + dy * dy)

    if length < 1 then
        if Data.Line then Data.Line.Visible = false end
        return
    end

    if Data.Line then
        Data.Line.Size = UDim2.fromOffset(length, 1)
        Data.Line.Position = UDim2.fromOffset(
            (MyScreen.X + TargetScreen.X) / 2,
            (MyScreen.Y + TargetScreen.Y) / 2
        )
        Data.Line.Rotation = math.deg(math.atan2(dy, dx))
        Data.Line.BackgroundColor3 = GetLineColor(Player)
        Data.Line.Visible = true
    end
end

local function UpdateText(Player, Data, Distance, Side)
    local Root = GetRoot(Data.Character)
    if not Root or not Root.Parent or not Data.Billboard or not Data.Billboard.Parent then
        if Data.Billboard then Data.Billboard.Enabled = false end
        if Data.Name then Data.Name.Visible = false end
        if Data.Distance then Data.Distance.Visible = false end
        if Data.HeightLabel then Data.HeightLabel.Visible = false end
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

    Data.Name.Text = Player.DisplayName
    Data.Name.TextSize = GetNameSize(Distance)
    Data.Name.TextColor3 = GetNameColor(Player)
    Data.Name.TextTransparency = 0
    Data.Name.Visible = NameEnabled

    Data.Distance.TextSize = GetDistanceSize(Distance)
    Data.Distance.TextColor3 = GetDistanceColor(Player)
    Data.Distance.TextTransparency = 0
    Data.Distance.Visible = DistanceEnabled

    if DistanceEnabled then
        Data.Distance.Text = tostring(math.floor(Distance + 0.5)) .. " studs"
    else
        Data.Distance.Text = ""
    end

    if HeightEnabled then
        local Height = GetCharacterHeight(Data.Character)
        Data.HeightLabel.Text = tostring(math.floor(Height + 0.5)) .. " studs"
        Data.HeightLabel.TextSize = GetHeightSize()
        Data.HeightLabel.TextColor3 = GetDistanceColor(Player)
        Data.HeightLabel.Visible = true
    else
        Data.HeightLabel.Visible = false
    end

    Data.Billboard.Enabled = NameEnabled or DistanceEnabled or HeightEnabled
end

-- ============================================================
-- Группировка 2D боксов
-- ============================================================
local function GetGroupFrame()
    for _, frame in ipairs(GroupBoxPool) do
        if not frame.Visible then
            return frame
        end
    end

    local frame = Instance.new("Frame")
    frame.Name = "GroupBox"
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 15
    frame.Parent = ESPGui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Count"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.GroupBox
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = frame

    table.insert(GroupBoxPool, frame)
    return frame
end

local function BoxesClose(bounds1, bounds2, threshold)
    local c1x = (bounds1.MinX + bounds1.MaxX) / 2
    local c1y = (bounds1.MinY + bounds1.MaxY) / 2
    local c2x = (bounds2.MinX + bounds2.MaxX) / 2
    local c2y = (bounds2.MinY + bounds2.MaxY) / 2
    local dx = c1x - c2x
    local dy = c1y - c2y
    return math.sqrt(dx * dx + dy * dy) <= threshold
end

local function UpdateGroupedBoxes()
    -- Сначала скрываем все групповые рамки
    for _, frame in ipairs(GroupBoxPool) do
        frame.Visible = false
    end

    if not Settings.GroupBoxes or not Settings.Boxes or not Settings.ESP then
        -- Если группировка выключена, показываем индивидуальные боксы
        for _, Data in pairs(ESPObjects) do
            if Data.BoxShouldShow and Data.BoxBounds then
                Data.Box.Position = UDim2.fromOffset(Data.BoxBounds.MinX, Data.BoxBounds.MinY)
                Data.Box.Size = UDim2.fromOffset(
                    math.max(Data.BoxBounds.MaxX - Data.BoxBounds.MinX, 2),
                    math.max(Data.BoxBounds.MaxY - Data.BoxBounds.MinY, 2)
                )
                Data.Box.Visible = true
            else
                Data.Box.Visible = false
            end
        end
        return
    end

    -- Собираем кандидатов
    local candidates = {}
    for _, Data in pairs(ESPObjects) do
        if Data.BoxShouldShow and Data.BoxBounds then
            table.insert(candidates, { Data = Data, bounds = Data.BoxBounds })
        end
    end

    if #candidates == 0 then return end

    -- Простая кластеризация
    local groups = {}
    local assigned = {}

    for i = 1, #candidates do
        if not assigned[i] then
            local group = { i }
            assigned[i] = true
            local changed = true
            while changed do
                changed = false
                for j = 1, #candidates do
                    if not assigned[j] then
                        for _, memberIdx in ipairs(group) do
                            if BoxesClose(candidates[memberIdx].bounds, candidates[j].bounds, Settings.GroupPixelDistance) then
                                table.insert(group, j)
                                assigned[j] = true
                                changed = true
                                break
                            end
                        end
                    end
                end
            end
            table.insert(groups, group)
        end
    end

    -- Отображаем группы
    for _, group in ipairs(groups) do
        if #group == 1 then
            local idx = group[1]
            local Data = candidates[idx].Data
            Data.Box.Position = UDim2.fromOffset(Data.BoxBounds.MinX, Data.BoxBounds.MinY)
            Data.Box.Size = UDim2.fromOffset(
                math.max(Data.BoxBounds.MaxX - Data.BoxBounds.MinX, 2),
                math.max(Data.BoxBounds.MaxY - Data.BoxBounds.MinY, 2)
            )
            Data.Box.Visible = true
        else
            -- Скрываем индивидуальные боксы
            for _, idx in ipairs(group) do
                candidates[idx].Data.Box.Visible = false
            end

            -- Вычисляем объединённые границы
            local minX, minY = math.huge, math.huge
            local maxX, maxY = -math.huge, -math.huge
            for _, idx in ipairs(group) do
                local b = candidates[idx].bounds
                minX = math.min(minX, b.MinX)
                minY = math.min(minY, b.MinY)
                maxX = math.max(maxX, b.MaxX)
                maxY = math.max(maxY, b.MaxY)
            end

            local frame = GetGroupFrame()
            frame.Position = UDim2.fromOffset(minX, minY)
            frame.Size = UDim2.fromOffset(math.max(maxX - minX, 2), math.max(maxY - minY, 2))
            frame:FindFirstChild("UIStroke").Color = Colors.GroupBox
            local label = frame:FindFirstChild("Count")
            if label then
                label.TextColor3 = Colors.GroupBox
                label.Text = tostring(#group)
            end
            frame.Visible = true
        end
    end
end

-- ============================================================
-- Главное обновление ESP
-- ============================================================
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
    if Data.Box3D then
        Data.Box3D.Adornee = Root
    end

    local Distance = (MyRoot.Position - Root.Position).Magnitude
    local Side = GetSide(Player)

    if Settings.VisibilityCheck then
        Data.Visibility = GetVisibility(Character, Distance)
    else
        Data.Visibility = {
            AnyVisible = true,
            Parts = {},
            UseBodyParts = false
        }
    end

    UpdateText(Player, Data, Distance, Side)
    UpdateHighlights(Player, Data, Distance, Side, Data.Visibility)
    UpdateBox(Player, Data, Character, Distance, Side, Data.Visibility)
    Update3DBox(Player, Data, Distance, Side, Data.Visibility)
    UpdateLine(Player, Data, Distance, Side, Data.Visibility)
end

-- ============================================================
-- Инициализация игроков
-- ============================================================
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

-- ============================================================
-- Главный цикл
-- ============================================================
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

    if Timer < UPDATE_INTERVAL then
        return
    end

    Timer = 0

    UpdateHighlightBudget()

    for Player, Data in pairs(ESPObjects) do
        if Player.Parent == Players then
            UpdateESP(Player, Data)
        else
            RemoveESP(Player)
        end
    end

    UpdateGroupedBoxes()
end)