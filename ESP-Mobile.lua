local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WindUI = loadstring(game:HttpGet(
  "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

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

local UPDATE_INTERVAL = 0.05
local PLAYER_SCAN_INTERVAL = 1

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
  TeamBoxHidden = Color3.fromRGB(255, 145, 30)
}

local DEFAULT_SETTINGS = {
  ESP = true,
  VisibilityCheck = true,
  BodyPartRaycast = true,
  BodyPartRaycastFallback = true,
  TeamCheck = true,

  ShowName = true,
  ShowDistance = true,
  Highlight = true,
  Boxes = true,

  ESPDistance = DEFAULT_DISTANCE,
  HighlightDistance = DEFAULT_DISTANCE,
  BoxDistance = DEFAULT_DISTANCE,

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

  BoxMode = "Performance",
  RayOrigin = "Character"
}

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

  Name = {
    Enabled = true,
    NearDisable = false,
    NearDistance = 100
  },

  Distance = {
    Enabled = true,
    NearDisable = false,
    NearDistance = 100
  }
}

local Settings = {}
local Colors = {}

local function CopyTable(Source)
  local Result = {}

  for Name, Value in pairs(Source) do
    if type(Value) == "table" then
      Result[Name] = CopyTable(Value)
    else
      Result[Name] = Value
    end
  end

  return Result
end

local function ResetSettings()
  table.clear(Settings)

  for Name, Value in pairs(DEFAULT_SETTINGS) do
    Settings[Name] = Value
  end
end

local function ResetColors()
  table.clear(Colors)

  for Name, Value in pairs(DEFAULT_COLORS) do
    Colors[Name] = Value
  end
end

local SideSettings = {
  Enemy = CopyTable(DEFAULT_SIDE_SETTINGS),
  Teammate = CopyTable(DEFAULT_SIDE_SETTINGS)
}

local function ResetSideSettings()
  SideSettings.Enemy = CopyTable(DEFAULT_SIDE_SETTINGS)
  SideSettings.Teammate = CopyTable(DEFAULT_SIDE_SETTINGS)
end

ResetSettings()
ResetColors()

local ESPObjects = {}

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
    Desc = "Information"
  }),

  ESP = Sections.Features:Tab({
    Title = "ESP",
    Icon = "eye",
    Desc = "Main ESP"
  }),

  Sides = Sections.Features:Tab({
    Title = "Sides",
    Icon = "users",
    Desc = "Enemy and teammate"
  }),

  Detection = Sections.Features:Tab({
    Title = "Detection",
    Icon = "scan-search",
    Desc = "Visibility"
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
    Desc = "Interface"
  })
}

Tabs.About:Paragraph({
  Title = "PLAYER ESP",
  Desc = "Advanced player visualization system",
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
  Desc = "Names, distance, individual body highlights and 2D boxes.",
  Image = "eye",
  ImageSize = 18
})

AboutSection:Paragraph({
  Title = "Detection",
  Desc = "Normal or body-part raycasting with Character or Camera origin.",
  Image = "scan-search",
  ImageSize = 18
})

AboutSection:Paragraph({
  Title = "Customization",
  Desc = "Separate enemy and teammate settings, dynamic text and custom colors.",
  Image = "palette",
  ImageSize = 18
})

Tabs.ESP:Paragraph({
  Title = "Player ESP",
  Desc = "Main ESP controls.",
  Image = "eye",
  ImageSize = 20
})

local UIControls = {
  ESP = {},
  Sides = {},
  Detection = {},
  Text = {},
  Colors = {}
}

local ESPSection = Tabs.ESP:Section({
  Title = "Features",
  Icon = "scan",
  Opened = true,
  Box = true
})

UIControls.ESP.Enabled = ESPSection:Toggle({
  Title = "ESP",
  Desc = "Enable player ESP",
  Value = Settings.ESP,
  Callback = function(Value)
    Settings.ESP = Value
  end
})

UIControls.ESP.ShowName = ESPSection:Toggle({
  Title = "Names",
  Desc = "Show player names",
  Value = Settings.ShowName,
  Callback = function(Value)
    Settings.ShowName = Value
  end
})

UIControls.ESP.ShowDistance = ESPSection:Toggle({
  Title = "Distance",
  Desc = "Show player distance",
  Value = Settings.ShowDistance,
  Callback = function(Value)
    Settings.ShowDistance = Value
  end
})

UIControls.ESP.Highlight = ESPSection:Toggle({
  Title = "Highlight",
  Desc = "Highlight body parts",
  Value = Settings.Highlight,
  Callback = function(Value)
    Settings.Highlight = Value
  end
})

UIControls.ESP.Boxes = ESPSection:Toggle({
  Title = "2D Boxes",
  Desc = "Draw player boxes",
  Value = Settings.Boxes,
  Callback = function(Value)
    Settings.Boxes = Value
  end
})

UIControls.ESP.TeamCheck = ESPSection:Toggle({
  Title = "Team Check",
  Desc = "Separate enemies and teammates",
  Value = Settings.TeamCheck,
  Callback = function(Value)
    Settings.TeamCheck = Value
  end
})

local ESPDistanceSection = Tabs.ESP:Section({
  Title = "Distances",
  Icon = "maximize",
  Opened = true,
  Box = true
})

UIControls.ESP.ESPDistance = ESPDistanceSection:Slider({
  Title = "Text Distance",
  Desc = "Maximum text distance",
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

UIControls.ESP.HighlightDistance = ESPDistanceSection:Slider({
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

UIControls.ESP.BoxDistance = ESPDistanceSection:Slider({
  Title = "Box Distance",
  Desc = "Maximum box distance",
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

local BoxModeSection = Tabs.ESP:Section({
  Title = "2D Box",
  Icon = "square",
  Opened = true,
  Box = true
})

UIControls.ESP.BoxMode = BoxModeSection:Dropdown({
  Title = "Box Mode",
  Desc = "Choose box calculation method",
  Values = {
    "Performance",
    "Precise"
  },
  Value = Settings.BoxMode,
  Callback = function(Value)
    Settings.BoxMode = Value
  end
})

BoxModeSection:Paragraph({
  Title = "Performance",
  Desc = "Faster calculation using the character bounding box.",
  Image = "zap",
  ImageSize = 16
})

BoxModeSection:Paragraph({
  Title = "Precise",
  Desc = "Calculates individual body-part corners for tighter boxes.",
  Image = "scan",
  ImageSize = 16
})

local ESPReset = Tabs.ESP:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = false,
  Box = true
})

ESPReset:Divider()

ESPReset:Button({
  Title = "Reset ESP",
  Desc = "Restore ESP features, distances and box mode",
  Icon = "rotate-ccw",

  Callback = function()
    local Keys = {
      "ESP",
      "ShowName",
      "ShowDistance",
      "Highlight",
      "Boxes",
      "TeamCheck",
      "ESPDistance",
      "HighlightDistance",
      "BoxDistance",
      "BoxMode"
    }

    for _, Key in ipairs(Keys) do
      Settings[Key] = DEFAULT_SETTINGS[Key]
    end

    UIControls.ESP.Enabled:Set(Settings.ESP)
    UIControls.ESP.ShowName:Set(Settings.ShowName)
    UIControls.ESP.ShowDistance:Set(Settings.ShowDistance)
    UIControls.ESP.Highlight:Set(Settings.Highlight)
    UIControls.ESP.Boxes:Set(Settings.Boxes)
    UIControls.ESP.TeamCheck:Set(Settings.TeamCheck)

    UIControls.ESP.ESPDistance:Set(Settings.ESPDistance)
    UIControls.ESP.HighlightDistance:Set(Settings.HighlightDistance)
    UIControls.ESP.BoxDistance:Set(Settings.BoxDistance)
    UIControls.ESP.BoxMode:Select(Settings.BoxMode)

    WindUI:Notify({
      Title = "ESP Reset",
      Content = "ESP settings restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Sides:Paragraph({
  Title = "Side Profiles",
  Desc = "Configure enemies and teammates independently.",
  Image = "users",
  ImageSize = 20
})

local SelectedSide = "Enemy"
local SyncingSideUI = false

local SideDropdown = Tabs.Sides:Dropdown({
  Title = "Profile",
  Desc = "Choose a side",
  Values = {
    "Enemy",
    "Teammate"
  },
  Value = "Enemy",

  Callback = function(Value)
    if SyncingSideUI then
      return
    end

    SelectedSide = Value

    local Data = SideSettings[SelectedSide]

    for Name, Controls in pairs(UIControls.Sides) do
      Controls.Enabled:Set(Data[Name].Enabled)
      Controls.NearDisable:Set(Data[Name].NearDisable)
      Controls.NearDistance:Set(Data[Name].NearDistance)
    end
  end
})

local SideSection = Tabs.Sides:Section({
  Title = "Elements",
  Icon = "layers-3",
  Opened = true,
  Box = true
})

local function CreateSideControl(
  Name,
  Title,
  Description
)
  local Controls = {}

  Controls.Enabled = SideSection:Toggle({
    Title = Title,
    Desc = Description,
    Value = SideSettings.Enemy[Name].Enabled,

    Callback = function(Value)
      if not SyncingSideUI then
        SideSettings[SelectedSide][Name].Enabled = Value
      end
    end
  })

  Controls.NearDisable = SideSection:Toggle({
    Title = "Disable " .. Title .. " Near",
    Desc = "Hide when player is close",
    Value = SideSettings.Enemy[Name].NearDisable,

    Callback = function(Value)
      if not SyncingSideUI then
        SideSettings[SelectedSide][Name].NearDisable = Value
      end
    end
  })

  Controls.NearDistance = SideSection:Slider({
    Title = Title .. " Near Distance",
    Desc = "Distance to hide",
    Value = {
      Min = MIN_NEAR_DISTANCE,
      Max = MAX_NEAR_DISTANCE,
      Default = 100
    },
    Step = 1,

    Callback = function(Value)
      if not SyncingSideUI then
        SideSettings[SelectedSide][Name].NearDistance = Value
      end
    end
  })

  UIControls.Sides[Name] = Controls
end

CreateSideControl(
  "Highlight",
  "Highlight",
  "Enable body highlight"
)

CreateSideControl(
  "Box",
  "2D Box",
  "Enable player box"
)

CreateSideControl(
  "Name",
  "Name",
  "Enable player name"
)

CreateSideControl(
  "Distance",
  "Distance",
  "Enable distance text"
)

local SidesReset = Tabs.Sides:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = false,
  Box = true
})

SidesReset:Divider()

SidesReset:Button({
  Title = "Reset Sides",
  Desc = "Restore both side profiles",
  Icon = "rotate-ccw",

  Callback = function()
    ResetSideSettings()

    SyncingSideUI = true
    SelectedSide = "Enemy"
    SideDropdown:Select("Enemy")

    for Name, Controls in pairs(UIControls.Sides) do
      local Data = SideSettings.Enemy[Name]

      Controls.Enabled:Set(Data.Enabled)
      Controls.NearDisable:Set(Data.NearDisable)
      Controls.NearDistance:Set(Data.NearDistance)
    end

    SyncingSideUI = false

    WindUI:Notify({
      Title = "Sides Reset",
      Content = "Profiles restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Detection:Paragraph({
  Title = "Visibility Detection",
  Desc = "Control visibility and raycasting.",
  Image = "scan-search",
  ImageSize = 20
})

local DetectionSection = Tabs.Detection:Section({
  Title = "Raycast",
  Icon = "crosshair",
  Opened = true,
  Box = true
})

UIControls.Detection.Visibility = DetectionSection:Toggle({
  Title = "Visibility Check",
  Desc = "Detect walls",
  Value = Settings.VisibilityCheck,
  Callback = function(Value)
    Settings.VisibilityCheck = Value
  end
})

UIControls.Detection.BodyParts = DetectionSection:Toggle({
  Title = "Body Part Raycast",
  Desc = "Check body parts separately",
  Value = Settings.BodyPartRaycast,
  Callback = function(Value)
    Settings.BodyPartRaycast = Value
  end
})

UIControls.Detection.Fallback = DetectionSection:Toggle({
  Title = "Automatic Fallback",
  Desc = "Use normal raycast farther away",
  Value = Settings.BodyPartRaycastFallback,
  Callback = function(Value)
    Settings.BodyPartRaycastFallback = Value
  end
})

UIControls.Detection.Origin = DetectionSection:Dropdown({
  Title = "Raycast Origin",
  Desc = "Choose ray origin",
  Values = {
    "Character",
    "Camera"
  },
  Value = Settings.RayOrigin,

  Callback = function(Value)
    Settings.RayOrigin = Value
  end
})

UIControls.Detection.Distance = DetectionSection:Slider({
  Title = "Body Part Distance",
  Desc = "Distance before fallback",
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

local DetectionReset = Tabs.Detection:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = false,
  Box = true
})

DetectionReset:Divider()

DetectionReset:Button({
  Title = "Reset Detection",
  Desc = "Restore visibility settings",
  Icon = "rotate-ccw",

  Callback = function()
    Settings.VisibilityCheck =
      DEFAULT_SETTINGS.VisibilityCheck

    Settings.BodyPartRaycast =
      DEFAULT_SETTINGS.BodyPartRaycast

    Settings.BodyPartRaycastFallback =
      DEFAULT_SETTINGS.BodyPartRaycastFallback

    Settings.BodyPartRaycastDistance =
      DEFAULT_SETTINGS.BodyPartRaycastDistance

    Settings.RayOrigin =
      DEFAULT_SETTINGS.RayOrigin

    UIControls.Detection.Visibility:Set(
      Settings.VisibilityCheck
    )

    UIControls.Detection.BodyParts:Set(
      Settings.BodyPartRaycast
    )

    UIControls.Detection.Fallback:Set(
      Settings.BodyPartRaycastFallback
    )

    UIControls.Detection.Distance:Set(
      Settings.BodyPartRaycastDistance
    )

    UIControls.Detection.Origin:Select(
      Settings.RayOrigin
    )

    WindUI:Notify({
      Title = "Detection Reset",
      Content = "Detection settings restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Text:Paragraph({
  Title = "Text Settings",
  Desc = "Configure name and distance text.",
  Image = "type",
  ImageSize = 20
})

local BasicTextSection = Tabs.Text:Section({
  Title = "Base Size",
  Icon = "text-cursor-input",
  Opened = true,
  Box = true
})

UIControls.Text.NameSize = BasicTextSection:Slider({
  Title = "Name Size",
  Desc = "Base name size",
  Value = {
    Min = MIN_NAME_SIZE,
    Max = MAX_NAME_SIZE,
    Default = Settings.NameSize
  },
  Step = 1,

  Callback = function(Value)
    Settings.NameSize = Value
  end
})

UIControls.Text.DistanceSize = BasicTextSection:Slider({
  Title = "Distance Size",
  Desc = "Base distance size",
  Value = {
    Min = MIN_DISTANCE_SIZE,
    Max = MAX_DISTANCE_SIZE,
    Default = Settings.DistanceSize
  },
  Step = 1,

  Callback = function(Value)
    Settings.DistanceSize = Value
  end
})

local TextModeSection = Tabs.Text:Section({
  Title = "Display Mode",
  Icon = "text-cursor-input",
  Opened = true,
  Box = true
})

UIControls.Text.Mode = TextModeSection:Dropdown({
  Title = "Text Mode",
  Desc = "Standard or dynamic text",
  Values = {
    "Standard",
    "Dynamic"
  },
  Value = Settings.TextMode,

  Callback = function(Value)
    Settings.TextMode = Value
  end
})

UIControls.Text.DynamicMode = TextModeSection:Dropdown({
  Title = "Dynamic Mode",
  Desc = "Used only in Dynamic mode",
  Values = {
    "Far Bigger",
    "Far Smaller"
  },
  Value = Settings.DynamicTextMode,

  Callback = function(Value)
    Settings.DynamicTextMode = Value
  end
})

local DynamicSection = Tabs.Text:Section({
  Title = "Dynamic Settings",
  Icon = "move-diagonal-2",
  Opened = true,
  Box = true
})

UIControls.Text.Curve = DynamicSection:Slider({
  Title = "Curve",
  Desc = "Controls size progression",
  Value = {
    Min = MIN_TEXT_CURVE,
    Max = MAX_TEXT_CURVE,
    Default = Settings.DynamicTextCurve
  },
  Step = 0.05,

  Callback = function(Value)
    Settings.DynamicTextCurve = Value
  end
})

UIControls.Text.NameMin = DynamicSection:Slider({
  Title = "Name Minimum",
  Desc = "Minimum name size",
  Value = {
    Min = MIN_NAME_SIZE,
    Max = MAX_NAME_SIZE,
    Default = Settings.NameMinSize
  },
  Step = 1,

  Callback = function(Value)
    Settings.NameMinSize = math.min(
      Value,
      Settings.NameMaxSize
    )
  end
})

UIControls.Text.NameMax = DynamicSection:Slider({
  Title = "Name Maximum",
  Desc = "Maximum name size",
  Value = {
    Min = MIN_NAME_SIZE,
    Max = MAX_NAME_SIZE,
    Default = Settings.NameMaxSize
  },
  Step = 1,

  Callback = function(Value)
    Settings.NameMaxSize = math.max(
      Value,
      Settings.NameMinSize
    )
  end
})

UIControls.Text.DistanceMin = DynamicSection:Slider({
  Title = "Distance Minimum",
  Desc = "Minimum distance size",
  Value = {
    Min = MIN_DISTANCE_SIZE,
    Max = MAX_DISTANCE_SIZE,
    Default = Settings.DistanceMinSize
  },
  Step = 1,

  Callback = function(Value)
    Settings.DistanceMinSize = math.min(
      Value,
      Settings.DistanceMaxSize
    )
  end
})

UIControls.Text.DistanceMax = DynamicSection:Slider({
  Title = "Distance Maximum",
  Desc = "Maximum distance size",
  Value = {
    Min = MIN_DISTANCE_SIZE,
    Max = MAX_DISTANCE_SIZE,
    Default = Settings.DistanceMaxSize
  },
  Step = 1,

  Callback = function(Value)
    Settings.DistanceMaxSize = math.max(
      Value,
      Settings.DistanceMinSize
    )
  end
})

local TextReset = Tabs.Text:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = false,
  Box = true
})

TextReset:Divider()

TextReset:Button({
  Title = "Reset Text",
  Desc = "Restore text settings",
  Icon = "rotate-ccw",

  Callback = function()
    local Keys = {
      "NameSize",
      "DistanceSize",
      "TextMode",
      "DynamicTextMode",
      "DynamicTextCurve",
      "NameMinSize",
      "NameMaxSize",
      "DistanceMinSize",
      "DistanceMaxSize"
    }

    for _, Key in ipairs(Keys) do
      Settings[Key] = DEFAULT_SETTINGS[Key]
    end

    UIControls.Text.NameSize:Set(
      Settings.NameSize
    )

    UIControls.Text.DistanceSize:Set(
      Settings.DistanceSize
    )

    UIControls.Text.Mode:Select(
      Settings.TextMode
    )

    UIControls.Text.DynamicMode:Select(
      Settings.DynamicTextMode
    )

    UIControls.Text.Curve:Set(
      Settings.DynamicTextCurve
    )

    UIControls.Text.NameMin:Set(
      Settings.NameMinSize
    )

    UIControls.Text.NameMax:Set(
      Settings.NameMaxSize
    )

    UIControls.Text.DistanceMin:Set(
      Settings.DistanceMinSize
    )

    UIControls.Text.DistanceMax:Set(
      Settings.DistanceMaxSize
    )

    WindUI:Notify({
      Title = "Text Reset",
      Content = "Text settings restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Colors:Paragraph({
  Title = "ESP Colors",
  Desc = "Customize every ESP color.",
  Image = "palette",
  ImageSize = 20
})

local function CreateColorPicker(
  Parent,
  Title,
  Description,
  Key
)
  local Picker = Parent:Colorpicker({
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

  UIControls.Colors[Key] = Picker
end

local HighlightColors = Tabs.Colors:Section({
  Title = "Highlight",
  Icon = "eye",
  Opened = true,
  Box = true
})

CreateColorPicker(
  HighlightColors,
  "Enemy Visible",
  "Enemy visible body parts",
  "EnemyVisible"
)

CreateColorPicker(
  HighlightColors,
  "Enemy Behind Wall",
  "Enemy hidden body parts",
  "EnemyHidden"
)

CreateColorPicker(
  HighlightColors,
  "Teammate Visible",
  "Teammate visible body parts",
  "TeamVisible"
)

CreateColorPicker(
  HighlightColors,
  "Teammate Behind Wall",
  "Teammate hidden body parts",
  "TeamHidden"
)

local TextColors = Tabs.Colors:Section({
  Title = "Text",
  Icon = "type",
  Opened = true,
  Box = true
})

CreateColorPicker(
  TextColors,
  "Enemy Name",
  "Enemy name color",
  "EnemyName"
)

CreateColorPicker(
  TextColors,
  "Teammate Name",
  "Teammate name color",
  "TeamName"
)

CreateColorPicker(
  TextColors,
  "Enemy Distance",
  "Enemy distance color",
  "EnemyDistance"
)

CreateColorPicker(
  TextColors,
  "Teammate Distance",
  "Teammate distance color",
  "TeamDistance"
)

local BoxColors = Tabs.Colors:Section({
  Title = "2D Boxes",
  Icon = "square",
  Opened = true,
  Box = true
})

CreateColorPicker(
  BoxColors,
  "Enemy Visible",
  "Enemy box when visible",
  "EnemyBoxVisible"
)

CreateColorPicker(
  BoxColors,
  "Enemy Behind Wall",
  "Enemy box when hidden",
  "EnemyBoxHidden"
)

CreateColorPicker(
  BoxColors,
  "Teammate Visible",
  "Teammate box when visible",
  "TeamBoxVisible"
)

CreateColorPicker(
  BoxColors,
  "Teammate Behind Wall",
  "Teammate box when hidden",
  "TeamBoxHidden"
)

local ColorsReset = Tabs.Colors:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = false,
  Box = true
})

ColorsReset:Divider()

ColorsReset:Button({
  Title = "Reset Colors",
  Desc = "Restore all ESP colors",
  Icon = "rotate-ccw",

  Callback = function()
    ResetColors()

    for Name, Picker in pairs(UIControls.Colors) do
      pcall(function()
        Picker:Set(
          Colors[Name],
          0
        )
      end)
    end

    WindUI:Notify({
      Title = "Colors Reset",
      Content = "ESP colors restored",
      Icon = "check",
      Duration = 2
    })
  end
})

local Themes = {}

for ThemeName in pairs(WindUI:GetThemes()) do
  Themes[#Themes + 1] = ThemeName
end

table.sort(Themes)

local ThemeDropdown

local AppearanceSection = Tabs.Settings:Section({
  Title = "Appearance",
  Icon = "palette",
  Opened = true,
  Box = true
})

ThemeDropdown = AppearanceSection:Dropdown({
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

local ResetAllSection = Tabs.Settings:Section({
  Title = "Reset All",
  Icon = "refresh-cw",
  Opened = false,
  Box = true
})

ResetAllSection:Paragraph({
  Title = "Complete Reset",
  Desc = "Restore all ESP settings, colors, profiles and interface theme.",
  Image = "info",
  ImageSize = 18
})

ResetAllSection:Divider()

local function SyncAllUI()
  UIControls.ESP.Enabled:Set(Settings.ESP)
  UIControls.ESP.ShowName:Set(Settings.ShowName)
  UIControls.ESP.ShowDistance:Set(Settings.ShowDistance)
  UIControls.ESP.Highlight:Set(Settings.Highlight)
  UIControls.ESP.Boxes:Set(Settings.Boxes)
  UIControls.ESP.TeamCheck:Set(Settings.TeamCheck)

  UIControls.ESP.ESPDistance:Set(
    Settings.ESPDistance
  )

  UIControls.ESP.HighlightDistance:Set(
    Settings.HighlightDistance
  )

  UIControls.ESP.BoxDistance:Set(
    Settings.BoxDistance
  )

  UIControls.ESP.BoxMode:Select(
    Settings.BoxMode
  )

  UIControls.Detection.Visibility:Set(
    Settings.VisibilityCheck
  )

  UIControls.Detection.BodyParts:Set(
    Settings.BodyPartRaycast
  )

  UIControls.Detection.Fallback:Set(
    Settings.BodyPartRaycastFallback
  )

  UIControls.Detection.Origin:Select(
    Settings.RayOrigin
  )

  UIControls.Detection.Distance:Set(
    Settings.BodyPartRaycastDistance
  )

  UIControls.Text.NameSize:Set(
    Settings.NameSize
  )

  UIControls.Text.DistanceSize:Set(
    Settings.DistanceSize
  )

  UIControls.Text.Mode:Select(
    Settings.TextMode
  )

  UIControls.Text.DynamicMode:Select(
    Settings.DynamicTextMode
  )

  UIControls.Text.Curve:Set(
    Settings.DynamicTextCurve
  )

  UIControls.Text.NameMin:Set(
    Settings.NameMinSize
  )

  UIControls.Text.NameMax:Set(
    Settings.NameMaxSize
  )

  UIControls.Text.DistanceMin:Set(
    Settings.DistanceMinSize
  )

  UIControls.Text.DistanceMax:Set(
    Settings.DistanceMaxSize
  )

  SyncingSideUI = true
  SelectedSide = "Enemy"
  SideDropdown:Select("Enemy")

  for Name, Controls in pairs(UIControls.Sides) do
    local Data = SideSettings.Enemy[Name]

    Controls.Enabled:Set(Data.Enabled)
    Controls.NearDisable:Set(Data.NearDisable)
    Controls.NearDistance:Set(Data.NearDistance)
  end

  SyncingSideUI = false

  for Name, Picker in pairs(UIControls.Colors) do
    pcall(function()
      Picker:Set(
        Colors[Name],
        0
      )
    end)
  end
end

ResetAllSection:Button({
  Title = "Reset All",
  Desc = "Restore the complete configuration",
  Icon = "refresh-cw",

  Callback = function()
    ResetSettings()
    ResetColors()
    ResetSideSettings()

    WindUI:SetTheme("Dark")
    SyncAllUI()

    WindUI:Notify({
      Title = "Everything Reset",
      Content = "All configuration restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Window:Open()

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType =
  Enum.RaycastFilterType.Exclude
RaycastParams.IgnoreWater = true

local function GetCharacter(Player)
  local Character = Player.Character

  if Character and Character.Parent then
    return Character
  end

  return nil
end

local function GetRoot(Character)
  return Character
    and Character:FindFirstChild(
      "HumanoidRootPart"
    )
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

local function GetBodyParts(Character)
  local Parts = {}

  for _, Name in ipairs(BodyPartNames) do
    local Part =
      Character:FindFirstChild(Name)

    if Part and Part:IsA("BasePart") then
      Parts[#Parts + 1] = Part
    end
  end

  return Parts
end

local function GetRayOrigin()
  if Settings.RayOrigin == "Camera" then
    local Camera =
      workspace.CurrentCamera

    return Camera
      and Camera.CFrame.Position
  end

  local Root =
    GetRoot(
      LocalPlayer.Character
    )

  return Root
    and Root.Position
end

local function IsPartVisible(
  Character,
  Part,
  Origin
)
  if not Part or not Origin then
    return false
  end

  local Direction =
    Part.Position - Origin

  if Direction.Magnitude <= 0.01 then
    return true
  end

  RaycastParams.FilterDescendantsInstances = {
    LocalPlayer.Character
  }

  local Result =
    workspace:Raycast(
      Origin,
      Direction,
      RaycastParams
    )

  return Result == nil
    or Result.Instance:IsDescendantOf(
      Character
    )
end

local function GetVisibility(
  Character,
  Distance
)
  if not Settings.VisibilityCheck then
    return {
      AnyVisible = true,
      Parts = {},
      UseBodyParts = false
    }
  end

  local Origin =
    GetRayOrigin()

  if not Origin then
    return {
      AnyVisible = false,
      Parts = {},
      UseBodyParts = false
    }
  end

  local UseBodyParts =
    Settings.BodyPartRaycast
    and (
      not Settings.BodyPartRaycastFallback
      or Distance <=
        Settings.BodyPartRaycastDistance
    )

  if not UseBodyParts then
    local Root =
      GetRoot(Character)

    if not Root then
      return {
        AnyVisible = false,
        Parts = {},
        UseBodyParts = false
      }
    end

    local Visible =
      IsPartVisible(
        Character,
        Root,
        Origin
      )

    return {
      AnyVisible = Visible,
      Parts = {
        [Root] = Visible
      },
      UseBodyParts = false
    }
  end

  local Parts = {}
  local AnyVisible = false

  for _, Part in ipairs(
    GetBodyParts(Character)
  ) do
    local Visible =
      IsPartVisible(
        Character,
        Part,
        Origin
      )

    Parts[Part] = Visible

    if Visible then
      AnyVisible = true
    end
  end

  return {
    AnyVisible = AnyVisible,
    Parts = Parts,
    UseBodyParts = true
  }
end

local function IsFeatureEnabled(
  Side,
  Feature,
  Distance
)
  local Data =
    SideSettings[Side][Feature]

  if not Data.Enabled then
    return false
  end

  return not (
    Data.NearDisable
    and Distance <= Data.NearDistance
  )
end

local function GetHighlightColor(
  Player,
  Visible
)
  if GetSide(Player) == "Teammate" then
    return Visible
      and Colors.TeamVisible
      or Colors.TeamHidden
  end

  return Visible
    and Colors.EnemyVisible
    or Colors.EnemyHidden
end

local function GetBoxColor(
  Player,
  Visible
)
  if GetSide(Player) == "Teammate" then
    return Visible
      and Colors.TeamBoxVisible
      or Colors.TeamBoxHidden
  end

  return Visible
    and Colors.EnemyBoxVisible
    or Colors.EnemyBoxHidden
end

local function GetNameColor(Player)
  return GetSide(Player) == "Teammate"
    and Colors.TeamName
    or Colors.EnemyName
end

local function GetDistanceColor(Player)
  return GetSide(Player) == "Teammate"
    and Colors.TeamDistance
    or Colors.EnemyDistance
end

local function GetDynamicSize(
  Distance,
  Minimum,
  Maximum
)
  if Settings.TextMode ~= "Dynamic" then
    return nil
  end

  local Range =
    math.max(
      Settings.ESPDistance,
      1
    )

  local Alpha =
    math.clamp(
      Distance / Range,
      0,
      1
    )

  local Progress =
    Alpha ^ Settings.DynamicTextCurve

  if Settings.DynamicTextMode ==
    "Far Bigger" then
    return math.floor(
      Minimum
      + (Maximum - Minimum) * Progress
      + 0.5
    )
  end

  return math.floor(
    Maximum
    - (Maximum - Minimum) * Progress
    + 0.5
  )
end

local function GetNameSize(Distance)
  return GetDynamicSize(
    Distance,
    Settings.NameMinSize,
    Settings.NameMaxSize
  ) or Settings.NameSize
end

local function GetDistanceSize(Distance)
  return GetDynamicSize(
    Distance,
    Settings.DistanceMinSize,
    Settings.DistanceMaxSize
  ) or Settings.DistanceSize
end

local function GetPerformanceBounds(
  Character
)
  local Camera =
    workspace.CurrentCamera

  if not Camera then
    return nil
  end

  local CFrame, Size =
    Character:GetBoundingBox()

  local Half =
    Size / 2

  local MinX = math.huge
  local MinY = math.huge
  local MaxX = -math.huge
  local MaxY = -math.huge
  local Found = false

  for X = -1, 1, 2 do
    for Y = -1, 1, 2 do
      for Z = -1, 1, 2 do
        local WorldPosition =
          CFrame:PointToWorldSpace(
            Vector3.new(
              Half.X * X,
              Half.Y * Y,
              Half.Z * Z
            )
          )

        local Position, OnScreen =
          Camera:WorldToViewportPoint(
            WorldPosition
          )

        if Position.Z > 0 then
          MinX =
            math.min(
              MinX,
              Position.X
            )

          MinY =
            math.min(
              MinY,
              Position.Y
            )

          MaxX =
            math.max(
              MaxX,
              Position.X
            )

          MaxY =
            math.max(
              MaxY,
              Position.Y
            )

          if OnScreen then
            Found = true
          end
        end
      end
    end
  end

  if not Found then
    return nil
  end

  local Viewport =
    Camera.ViewportSize

  return
    math.clamp(MinX, 0, Viewport.X),
    math.clamp(MinY, 0, Viewport.Y),
    math.clamp(MaxX, 0, Viewport.X),
    math.clamp(MaxY, 0, Viewport.Y)
end

local function GetPreciseBounds(
  Character
)
  local Camera =
    workspace.CurrentCamera

  if not Camera then
    return nil
  end

  local MinX = math.huge
  local MinY = math.huge
  local MaxX = -math.huge
  local MaxY = -math.huge
  local Found = false

  for _, Part in ipairs(
    GetBodyParts(Character)
  ) do
    local Half =
      Part.Size / 2

    for X = -1, 1, 2 do
      for Y = -1, 1, 2 do
        for Z = -1, 1, 2 do
          local WorldPosition =
            Part.CFrame:PointToWorldSpace(
              Vector3.new(
                Half.X * X,
                Half.Y * Y,
                Half.Z * Z
              )
            )

          local Position, OnScreen =
            Camera:WorldToViewportPoint(
              WorldPosition
            )

          if Position.Z > 0 then
            MinX =
              math.min(
                MinX,
                Position.X
              )

            MinY =
              math.min(
                MinY,
                Position.Y
              )

            MaxX =
              math.max(
                MaxX,
                Position.X
              )

            MaxY =
              math.max(
                MaxY,
                Position.Y
              )

            if OnScreen then
              Found = true
            end
          end
        end
      end
    end
  end

  if not Found then
    return nil
  end

  local Viewport =
    Camera.ViewportSize

  return
    math.clamp(MinX, 0, Viewport.X),
    math.clamp(MinY, 0, Viewport.Y),
    math.clamp(MaxX, 0, Viewport.X),
    math.clamp(MaxY, 0, Viewport.Y)
end

local function GetScreenBounds(
  Character
)
  if Settings.BoxMode == "Precise" then
    return GetPreciseBounds(
      Character
    )
  end

  return GetPerformanceBounds(
    Character
  )
end

local function CreateBox()
  local Box =
    Instance.new("Frame")

  Box.Name = "ESPBox"
  Box.BackgroundTransparency = 1
  Box.BorderSizePixel = 0
  Box.Visible = false
  Box.Active = false
  Box.ZIndex = 10
  Box.Parent = ESPGui

  local Stroke =
    Instance.new("UIStroke")

  Stroke.Thickness = 1.5
  Stroke.Parent = Box

  return Box, Stroke
end

local function CreateHighlight(
  Part
)
  local Highlight =
    Instance.new("Highlight")

  Highlight.Name =
    "ESPPartHighlight"

  Highlight.Adornee =
    Part

  Highlight.DepthMode =
    Enum.HighlightDepthMode.AlwaysOnTop

  Highlight.FillTransparency =
    0.45

  Highlight.OutlineTransparency =
    0

  Highlight.Enabled =
    false

  Highlight.Parent =
    ESPGui

  return Highlight
end

local function BuildHighlights(
  Data,
  Character
)
  for _, Highlight in pairs(
    Data.Highlights
  ) do
    Highlight:Destroy()
  end

  Data.Highlights = {}

  for _, Part in ipairs(
    GetBodyParts(Character)
  ) do
    Data.Highlights[Part] =
      CreateHighlight(Part)
  end
end

local function HideESP(Data)
  Data.Billboard.Enabled =
    false

  Data.Box.Visible =
    false

  for _, Highlight in pairs(
    Data.Highlights
  ) do
    Highlight.Enabled =
      false
  end
end

local function CreateESP(Player)
  if Player == LocalPlayer
    or ESPObjects[Player] then
    return
  end

  local Billboard =
    Instance.new("BillboardGui")

  Billboard.Name =
    "PlayerESP"

  Billboard.Size =
    UDim2.fromOffset(
      220,
      60
    )

  Billboard.StudsOffset =
    Vector3.new(
      0,
      3.2,
      0
    )

  Billboard.AlwaysOnTop =
    true

  Billboard.MaxDistance =
    MAX_DISTANCE

  Billboard.Enabled =
    false

  Billboard.Parent =
    PlayerGui

  local Name =
    Instance.new("TextLabel")

  Name.Name =
    "Name"

  Name.Size =
    UDim2.new(
      1,
      0,
      0,
      30
    )

  Name.BackgroundTransparency =
    1

  Name.Text =
    Player.DisplayName

  Name.Font =
    Enum.Font.GothamBold

  Name.TextStrokeTransparency =
    0.35

  Name.Parent =
    Billboard

  local Distance =
    Instance.new("TextLabel")

  Distance.Name =
    "Distance"

  Distance.Size =
    UDim2.new(
      1,
      0,
      0,
      20
    )

  Distance.Position =
    UDim2.fromOffset(
      0,
      30
    )

  Distance.BackgroundTransparency =
    1

  Distance.Font =
    Enum.Font.GothamMedium

  Distance.TextStrokeTransparency =
    0.5

  Distance.Parent =
    Billboard

  local Box, BoxStroke =
    CreateBox()

  local Data = {
    Billboard = Billboard,
    Name = Name,
    Distance = Distance,

    Box = Box,
    BoxStroke = BoxStroke,

    Highlights = {},

    Character = nil,
    Connection = nil,
    Visibility = nil
  }

  ESPObjects[Player] =
    Data

  local function Attach(
    Character
  )
    local CurrentData =
      ESPObjects[Player]

    if not CurrentData then
      return
    end

    CurrentData.Character =
      Character

    CurrentData.Visibility =
      nil

    local Root =
      GetRoot(Character)

    if Root then
      CurrentData.Billboard.Adornee =
        Root
    end

    BuildHighlights(
      CurrentData,
      Character
    )
  end

  if Player.Character then
    task.spawn(
      Attach,
      Player.Character
    )
  end

  Data.Connection =
    Player.CharacterAdded:Connect(
      function(Character)
        task.wait(0.1)

        if ESPObjects[Player] then
          Attach(Character)
        end
      end
    )
end

local function RemoveESP(
  Player
)
  local Data =
    ESPObjects[Player]

  if not Data then
    return
  end

  if Data.Connection then
    Data.Connection:Disconnect()
  end

  for _, Highlight in pairs(
    Data.Highlights
  ) do
    Highlight:Destroy()
  end

  Data.Billboard:Destroy()
  Data.Box:Destroy()

  ESPObjects[Player] =
    nil
end

local function UpdateText(
  Player,
  Data,
  Distance,
  Side
)
  local NameEnabled =
    Settings.ShowName
    and Distance <= Settings.ESPDistance
    and IsFeatureEnabled(
      Side,
      "Name",
      Distance
    )

  local DistanceEnabled =
    Settings.ShowDistance
    and Distance <= Settings.ESPDistance
    and IsFeatureEnabled(
      Side,
      "Distance",
      Distance
    )

  Data.Name.Visible =
    NameEnabled

  Data.Distance.Visible =
    DistanceEnabled

  Data.Name.TextSize =
    GetNameSize(
      Distance
    )

  Data.Distance.TextSize =
    GetDistanceSize(
      Distance
    )

  Data.Name.TextColor3 =
    GetNameColor(
      Player
    )

  Data.Distance.TextColor3 =
    GetDistanceColor(
      Player
    )

  if DistanceEnabled then
    Data.Distance.Text =
      math.floor(
        Distance
      ) .. " studs"
  end
end

local function UpdateHighlights(
  Player,
  Data,
  Distance,
  Side,
  Visibility
)
  local Enabled =
    Settings.Highlight
    and Distance <= Settings.HighlightDistance
    and IsFeatureEnabled(
      Side,
      "Highlight",
      Distance
    )

  if not Enabled then
    for _, Highlight in pairs(
      Data.Highlights
    ) do
      Highlight.Enabled =
        false
    end

    return
  end

  for Part, Highlight in pairs(
    Data.Highlights
  ) do
    if Part and Part.Parent then
      local Visible

      if not Settings.VisibilityCheck then
        Visible = true
      elseif Visibility.UseBodyParts then
        Visible =
          Visibility.Parts[Part]
          == true
      else
        Visible =
          Visibility.AnyVisible
      end

      local Color =
        GetHighlightColor(
          Player,
          Visible
        )

      Highlight.FillColor =
        Color

      Highlight.OutlineColor =
        Color

      Highlight.Enabled =
        true
    else
      Highlight.Enabled =
        false
    end
  end
end

local function UpdateBox(
  Player,
  Data,
  Character,
  Distance,
  Side,
  Visibility
)
  local Enabled =
    Settings.Boxes
    and Distance <= Settings.BoxDistance
    and IsFeatureEnabled(
      Side,
      "Box",
      Distance
    )

  if not Enabled then
    Data.Box.Visible =
      false

    return
  end

  local MinX,
    MinY,
    MaxX,
    MaxY =
    GetScreenBounds(
      Character
    )

  if not MinX then
    Data.Box.Visible =
      false

    return
  end

  local Visible =
    Visibility.AnyVisible

  Data.BoxStroke.Color =
    GetBoxColor(
      Player,
      Visible
    )

  Data.Box.Position =
    UDim2.fromOffset(
      MinX,
      MinY
    )

  Data.Box.Size =
    UDim2.fromOffset(
      MaxX - MinX,
      MaxY - MinY
    )

  Data.Box.Visible =
    true
end

local function UpdateESP(
  Player,
  Data
)
  if not Settings.ESP then
    HideESP(Data)
    return
  end

  local Character =
    GetCharacter(
      Player
    )

  if not Character then
    HideESP(Data)
    return
  end

  if Data.Character ~=
    Character then

    Data.Character =
      Character

    Data.Visibility =
      nil

    BuildHighlights(
      Data,
      Character
    )

    local Root =
      GetRoot(
        Character
      )

    if Root then
      Data.Billboard.Adornee =
        Root
    end
  end

  local Humanoid =
    Character:FindFirstChildOfClass(
      "Humanoid"
    )

  local Root =
    GetRoot(
      Character
    )

  local MyRoot =
    GetRoot(
      LocalPlayer.Character
    )

  if not Humanoid
    or not Root
    or not MyRoot
    or Humanoid.Health <= 0 then

    HideESP(Data)
    return
  end

  local Distance =
    (
      MyRoot.Position
      - Root.Position
    ).Magnitude

  local Side =
    GetSide(
      Player
    )

  Data.Billboard.Enabled =
    Distance <= Settings.ESPDistance

  if Settings.VisibilityCheck then
    Data.Visibility =
      GetVisibility(
        Character,
        Distance
      )
  else
    Data.Visibility = {
      AnyVisible = true,
      Parts = {},
      UseBodyParts = false
    }
  end

  UpdateText(
    Player,
    Data,
    Distance,
    Side
  )

  UpdateHighlights(
    Player,
    Data,
    Distance,
    Side,
    Data.Visibility
  )

  UpdateBox(
    Player,
    Data,
    Character,
    Distance,
    Side,
    Data.Visibility
  )
end

for _, Player in ipairs(
  Players:GetPlayers()
) do
  if Player ~= LocalPlayer then
    CreateESP(Player)
  end
end

Players.PlayerAdded:Connect(
  function(Player)
    if Player ~= LocalPlayer then
      CreateESP(Player)
    end
  end
)

Players.PlayerRemoving:Connect(
  RemoveESP
)

local Timer = 0
local PlayerScanTimer = 0

RunService.RenderStepped:Connect(
  function(Delta)
    Timer += Delta
    PlayerScanTimer += Delta

    if PlayerScanTimer >=
      PLAYER_SCAN_INTERVAL then

      PlayerScanTimer = 0

      for _, Player in ipairs(
        Players:GetPlayers()
      ) do
        if Player ~= LocalPlayer
          and not ESPObjects[Player] then

          CreateESP(
            Player
          )
        end
      end
    end

    if Timer <
      UPDATE_INTERVAL then
      return
    end

    Timer = 0

    for Player, Data in pairs(
      ESPObjects
    ) do
      if Player.Parent ==
        Players then

        UpdateESP(
          Player,
          Data
        )
      else
        RemoveESP(
          Player
        )
      end
    end
  end
)