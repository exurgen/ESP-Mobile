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
local MAX_HIGHLIGHT_BUDGET = 240

local DEFAULT_COLORS = {
  EnemyVisible = Color3.fromRGB(70, 255, 100),
  EnemyHidden = Color3.fromRGB(255, 60, 60),

  TeamVisible = Color3.fromRGB(255, 235, 50),
  TeamHidden = Color3.fromRGB(255, 145, 30),

  EnemyName = Color3.fromRGB(255, 255, 255),
  TeamName = Color3.fromRGB(255, 255, 255),

  EnemyDistance = Color3.fromRGB(220, 220, 220),
  TeamDistance = Color3.fromRGB(220, 220, 220)
}

local DEFAULT_SETTINGS = {
  ESP = true,
  VisibilityCheck = true,
  BodyPartRaycast = true,
  BodyPartRaycastFallback = false,
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

  BoxMode = "Accurate",
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

local Settings = {}
local Colors = {}

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
  Desc = "Names, distance, body-part highlights and 2D boxes.",
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
  Desc = "Dynamic text, custom colors and two box modes.",
  Image = "palette",
  ImageSize = 18
})

local UIControls = {
  ESP = {},
  Sides = {},
  Detection = {},
  Text = {},
  Colors = {}
}

Tabs.ESP:Paragraph({
  Title = "Player ESP",
  Desc = "Main ESP controls.",
  Image = "eye",
  ImageSize = 20
})

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

local DistanceSection = Tabs.ESP:Section({
  Title = "Distances",
  Icon = "maximize",
  Opened = true,
  Box = true
})

UIControls.ESP.ESPDistance = DistanceSection:Slider({
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

UIControls.ESP.HighlightDistance = DistanceSection:Slider({
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

UIControls.ESP.BoxDistance = DistanceSection:Slider({
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
  Desc = "Choose calculation method",
  Values = {
    "Performance",
    "Accurate"
  },
  Value = Settings.BoxMode,
  Callback = function(Value)
    Settings.BoxMode = Value
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
      Default = SideSettings.Enemy[Name].NearDistance
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
  Desc = "Check players behind walls",
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
  Desc = "Switch to normal raycast at distance",
  Value = Settings.BodyPartRaycastFallback,
  Callback = function(Value)
    Settings.BodyPartRaycastFallback = Value
  end
})

UIControls.Detection.FallbackDistance = DetectionSection:Slider({
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

local DetectionResetSection = Tabs.Detection:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = true,
  Box = true
})

DetectionResetSection:Divider()

DetectionResetSection:Button({
  Title = "Reset Detection",
  Desc = "Restore visibility and raycast settings",
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

    UIControls.Detection.FallbackDistance:Set(
      Settings.BodyPartRaycastDistance
    )

    UIControls.Detection.Origin:Select(
      Settings.RayOrigin
    )

    WindUI:Notify({
      Title = "Detection Reset",
      Content = "Detection restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Text:Paragraph({
  Title = "Text",
  Desc = "Configure name and distance text.",
  Image = "type",
  ImageSize = 20
})

local TextModeSection = Tabs.Text:Section({
  Title = "Mode",
  Icon = "sliders-horizontal",
  Opened = true,
  Box = true
})

UIControls.Text.Mode = TextModeSection:Dropdown({
  Title = "Text Mode",
  Desc = "Choose standard or dynamic",
  Values = {
    "Standard",
    "Dynamic"
  },
  Value = Settings.TextMode,
  Callback = function(Value)
    Settings.TextMode = Value
  end
})

UIControls.Text.DynamicMode =
  TextModeSection:Dropdown({
    Title = "Dynamic Mode",
    Desc = "Ignored in Standard mode",
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
  Title = "Base Size",
  Icon = "text-cursor-input",
  Opened = true,
  Box = true
})

UIControls.Text.NameSize =
  BasicTextSection:Slider({
    Title = "Name Size",
    Desc = "Standard name size",
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

UIControls.Text.DistanceSize =
  BasicTextSection:Slider({
    Title = "Distance Size",
    Desc = "Standard distance size",
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

local DynamicSection = Tabs.Text:Section({
  Title = "Dynamic Size",
  Icon = "move-diagonal-2",
  Opened = true,
  Box = true
})

UIControls.Text.Curve =
  DynamicSection:Slider({
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

UIControls.Text.NameMin =
  DynamicSection:Slider({
    Title = "Name Minimum",
    Desc = "Minimum dynamic name size",
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

UIControls.Text.NameMax =
  DynamicSection:Slider({
    Title = "Name Maximum",
    Desc = "Maximum dynamic name size",
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

UIControls.Text.DistanceMin =
  DynamicSection:Slider({
    Title = "Distance Minimum",
    Desc = "Minimum dynamic distance size",
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

UIControls.Text.DistanceMax =
  DynamicSection:Slider({
    Title = "Distance Maximum",
    Desc = "Maximum dynamic distance size",
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

local TextResetSection = Tabs.Text:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = true,
  Box = true
})

TextResetSection:Divider()

TextResetSection:Button({
  Title = "Reset Text",
  Desc = "Restore text settings",
  Icon = "rotate-ccw",
  Callback = function()
    Settings.NameSize =
      DEFAULT_SETTINGS.NameSize

    Settings.DistanceSize =
      DEFAULT_SETTINGS.DistanceSize

    Settings.TextMode =
      DEFAULT_SETTINGS.TextMode

    Settings.DynamicTextMode =
      DEFAULT_SETTINGS.DynamicTextMode

    Settings.DynamicTextCurve =
      DEFAULT_SETTINGS.DynamicTextCurve

    Settings.NameMinSize =
      DEFAULT_SETTINGS.NameMinSize

    Settings.NameMaxSize =
      DEFAULT_SETTINGS.NameMaxSize

    Settings.DistanceMinSize =
      DEFAULT_SETTINGS.DistanceMinSize

    Settings.DistanceMaxSize =
      DEFAULT_SETTINGS.DistanceMaxSize

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
  Desc = "Customize ESP colors independently.",
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

local HighlightColors =
  Tabs.Colors:Section({
    Title = "Highlight",
    Icon = "eye",
    Opened = true,
    Box = true
  })

CreateColorPicker(
  HighlightColors,
  "Enemy Visible",
  "Visible enemy",
  "EnemyVisible"
)

CreateColorPicker(
  HighlightColors,
  "Enemy Behind Wall",
  "Hidden enemy",
  "EnemyHidden"
)

CreateColorPicker(
  HighlightColors,
  "Teammate Visible",
  "Visible teammate",
  "TeamVisible"
)

CreateColorPicker(
  HighlightColors,
  "Teammate Behind Wall",
  "Hidden teammate",
  "TeamHidden"
)

local TextColors =
  Tabs.Colors:Section({
    Title = "Text",
    Icon = "type",
    Opened = true,
    Box = true
  })

CreateColorPicker(
  TextColors,
  "Enemy Name",
  "Enemy name",
  "EnemyName"
)

CreateColorPicker(
  TextColors,
  "Teammate Name",
  "Teammate name",
  "TeamName"
)

CreateColorPicker(
  TextColors,
  "Enemy Distance",
  "Enemy distance",
  "EnemyDistance"
)

CreateColorPicker(
  TextColors,
  "Teammate Distance",
  "Teammate distance",
  "TeamDistance"
)

local BoxColors =
  Tabs.Colors:Section({
    Title = "2D Boxes",
    Icon = "square",
    Opened = true,
    Box = true
  })

local BoxColorInfo =
  BoxColors:Paragraph({
    Title = "Same as Highlight",
    Desc = "Boxes use the visible/hidden highlight colors.",
    Image = "info",
    ImageSize = 16
  })

local ColorsResetSection =
  Tabs.Colors:Section({
    Title = "Reset",
    Icon = "rotate-ccw",
    Opened = true,
    Box = true
  })

ColorsResetSection:Divider()

ColorsResetSection:Button({
  Title = "Reset Colors",
  Desc = "Restore all ESP colors",
  Icon = "rotate-ccw",
  Callback = function()
    ResetColors()

    for Name, Picker in pairs(
      UIControls.Colors
    ) do
      pcall(function()
        Picker:Set(
          Colors[Name],
          0
        )
      end)
    end

    WindUI:Notify({
      Title = "Colors Reset",
      Content = "Colors restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Settings:Paragraph({
  Title = "Interface",
  Desc = "Customize the interface theme.",
  Image = "settings",
  ImageSize = 20
})

local AppearanceSection =
  Tabs.Settings:Section({
    Title = "Appearance",
    Icon = "palette",
    Opened = true,
    Box = true
  })

local Themes = {}

for ThemeName in pairs(
  WindUI:GetThemes()
) do
  Themes[#Themes + 1] = ThemeName
end

table.sort(Themes)

local ThemeDropdown =
  AppearanceSection:Dropdown({
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

    if ThemeDropdown
      and ThemeDropdown.Select then
      ThemeDropdown:Select("Dark")
    end
  end
})

local ResetAllSection =
  Tabs.Settings:Section({
    Title = "Reset All",
    Icon = "refresh-cw",
    Opened = true,
    Box = true
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

  UIControls.Detection.FallbackDistance:Set(
    Settings.BodyPartRaycastDistance
  )

  UIControls.Detection.Origin:Select(
    Settings.RayOrigin
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

  for Name, Controls in pairs(
    UIControls.Sides
  ) do
    local Data =
      SideSettings.Enemy[Name]

    Controls.Enabled:Set(
      Data.Enabled
    )

    Controls.NearDisable:Set(
      Data.NearDisable
    )

    Controls.NearDistance:Set(
      Data.NearDistance
    )
  end

  SyncingSideUI = false

  for Name, Picker in pairs(
    UIControls.Colors
  ) do
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

    for _, Data in pairs(
      ESPObjects
    ) do
      ClearHighlights(Data)
      Data.HighlightMode = nil
      Data.Visibility = nil
    end

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

  for _, Name in ipairs(
    BodyPartNames
  ) do
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

  local VisibleParts = {}
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

    VisibleParts[Part] = Visible

    if Visible then
      AnyVisible = true
    end
  end

  return {
    AnyVisible = AnyVisible,
    Parts = VisibleParts,
    UseBodyParts = true
  }
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

local function GetNameColor(
  Player
)
  if GetSide(Player) == "Teammate" then
    return Colors.TeamName
  end

  return Colors.EnemyName
end

local function GetDistanceColor(
  Player
)
  if GetSide(Player) == "Teammate" then
    return Colors.TeamDistance
  end

  return Colors.EnemyDistance
end

local function GetBoxColor(
  Player,
  Visible
)
  return GetHighlightColor(
    Player,
    Visible
  )
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
        + (Maximum - Minimum)
        * Progress
        + 0.5
    )
  end

  return math.floor(
    Maximum
      - (Maximum - Minimum)
      * Progress
      + 0.5
  )
end

local function GetNameSize(
  Distance
)
  return GetDynamicSize(
    Distance,
    Settings.NameMinSize,
    Settings.NameMaxSize
  ) or Settings.NameSize
end

local function GetDistanceSize(
  Distance
)
  return GetDynamicSize(
    Distance,
    Settings.DistanceMinSize,
    Settings.DistanceMaxSize
  ) or Settings.DistanceSize
end

local function CreateTextOverlay()
  local Container =
    Instance.new("Frame")

  Container.Name = "ESPText"
  Container.Size =
    UDim2.fromOffset(
      220,
      55
    )

  Container.AnchorPoint =
    Vector2.new(
      0.5,
      1
    )

  Container.BackgroundTransparency = 1
  Container.Visible = false
  Container.ZIndex = 20
  Container.Parent = ESPGui

  local Name =
    Instance.new("TextLabel")

  Name.Name = "Name"
  Name.Size =
    UDim2.new(
      1,
      0,
      0,
      30
    )

  Name.BackgroundTransparency = 1
  Name.TextColor3 =
    Color3.fromRGB(
      255,
      255,
      255
    )

  Name.TextSize =
    Settings.NameSize

  Name.TextTransparency = 0
  Name.TextStrokeTransparency = 0.35
  Name.TextXAlignment =
    Enum.TextXAlignment.Center

  Name.Font =
    Enum.Font.GothamBold

  Name.ZIndex = 21
  Name.Parent = Container

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

  Distance.BackgroundTransparency = 1
  Distance.TextColor3 =
    Color3.fromRGB(
      220,
      220,
      220
    )

  Distance.TextSize =
    Settings.DistanceSize

  Distance.TextTransparency = 0
  Distance.TextStrokeTransparency = 0.5
  Distance.TextXAlignment =
    Enum.TextXAlignment.Center

  Distance.Font =
    Enum.Font.GothamMedium

  Distance.ZIndex = 21
  Distance.Parent = Container

  return Container, Name, Distance
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
  Adornee
)
  local Highlight =
    Instance.new("Highlight")

  Highlight.Name =
    "ESPHighlight"

  Highlight.Adornee =
    Adornee

  Highlight.DepthMode =
    Enum.HighlightDepthMode.AlwaysOnTop

  Highlight.FillTransparency = 0.45
  Highlight.OutlineTransparency = 0
  Highlight.Enabled = true
  Highlight.Parent = ESPGui

  return Highlight
end

local function ClearHighlights(
  Data
)
  for Part, Highlight in pairs(
    Data.Highlights
  ) do
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

local function SetFullHighlight(
  Data,
  Character,
  Color
)
  if not Data.FullHighlight then
    Data.FullHighlight =
      CreateHighlight(
        Character
      )
  else
    Data.FullHighlight.Adornee =
      Character
  end

  Data.FullHighlight.FillColor =
    Color

  Data.FullHighlight.OutlineColor =
    Color
end

local function SetBodyPartHighlight(
  Data,
  Part,
  Color
)
  local Highlight =
    Data.Highlights[Part]

  if not Highlight then
    Highlight =
      CreateHighlight(
        Part
      )

    Data.Highlights[Part] =
      Highlight
  end

  Highlight.FillColor =
    Color

  Highlight.OutlineColor =
    Color
end

local function GetPerformanceBounds(
  Character
)
  local Camera =
    workspace.CurrentCamera

  if not Camera then
    return nil
  end

  local BoxCFrame,
    BoxSize =
    Character:GetBoundingBox()

  local HalfSize =
    BoxSize * 0.54

  local MinX = math.huge
  local MinY = math.huge
  local MaxX = -math.huge
  local MaxY = -math.huge
  local Found = false

  for X = -1, 1, 2 do
    for Y = -1, 1, 2 do
      for Z = -1, 1, 2 do
        local WorldPosition =
          BoxCFrame:PointToWorldSpace(
            Vector3.new(
              HalfSize.X * X,
              HalfSize.Y * Y,
              HalfSize.Z * Z
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

  return MinX, MinY, MaxX, MaxY
end

local function GetAccurateBounds(
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

          local Position =
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

            Found = true
          end
        end
      end
    end
  end

  if not Found then
    return nil
  end

  return MinX, MinY, MaxX, MaxY
end

local function GetScreenBounds(
  Character
)
  if Settings.BoxMode ==
    "Accurate" then

    return GetAccurateBounds(
      Character
    )
  end

  return GetPerformanceBounds(
    Character
  )
end

local function HideESP(Data)
  Data.TextContainer.Visible = false
  Data.Box.Visible = false

  ClearHighlights(Data)
  Data.HighlightMode = nil
end

local function CreateESP(
  Player
)
  if Player == LocalPlayer
    or ESPObjects[Player] then
    return
  end

  local TextContainer,
    Name,
    Distance =
    CreateTextOverlay()

  local Box,
    BoxStroke =
    CreateBox()

  local Data = {
    TextContainer = TextContainer,
    Name = Name,
    Distance = Distance,

    Box = Box,
    BoxStroke = BoxStroke,

    Highlights = {},
    FullHighlight = nil,

    Character = nil,
    Connection = nil,

    Visibility = nil,
    HighlightMode = nil
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

    CurrentData.HighlightMode =
      nil

    ClearHighlights(
      CurrentData
    )

    CurrentData.Name.Text =
      Player.DisplayName
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

  ClearHighlights(Data)

  if Data.TextContainer then
    Data.TextContainer:Destroy()
  end

  if Data.Box then
    Data.Box:Destroy()
  end

  ESPObjects[Player] =
    nil
end

local function UpdateHighlightBudget()
  if not Settings.ESP
    or not Settings.Highlight then

    for _, Data in pairs(
      ESPObjects
    ) do
      ClearHighlights(Data)
      Data.HighlightMode = nil
    end

    return
  end

  local MyRoot =
    GetRoot(
      LocalPlayer.Character
    )

  if not MyRoot then
    return
  end

  local Candidates = {}

  for Player, Data in pairs(
    ESPObjects
  ) do
    local Character =
      GetCharacter(Player)

    local Root =
      GetRoot(Character)

    if Character
      and Root
      and Player.Parent == Players then

      local Humanoid =
        Character:FindFirstChildOfClass(
          "Humanoid"
        )

      if Humanoid
        and Humanoid.Health > 0 then

        local Distance =
          (
            MyRoot.Position
            - Root.Position
          ).Magnitude

        local Side =
          GetSide(Player)

        if Distance <=
          Settings.HighlightDistance
          and IsFeatureEnabled(
            Side,
            "Highlight",
            Distance
          ) then

          Candidates[#Candidates + 1] = {
            Player = Player,
            Data = Data,
            Distance = Distance,
            PartCount = #GetBodyParts(
              Character
            )
          }
        else
          ClearHighlights(Data)
          Data.HighlightMode = nil
        end
      end
    end
  end

  table.sort(
    Candidates,
    function(A, B)
      return A.Distance < B.Distance
    end
  )

  local Remaining =
    MAX_HIGHLIGHT_BUDGET

  if Settings.BodyPartRaycast then
    for _, Candidate in ipairs(
      Candidates
    ) do
      if Candidate.PartCount > 0
        and Remaining >= Candidate.PartCount then

        Candidate.Data.HighlightMode =
          "BodyParts"

        Remaining -=
          Candidate.PartCount
      end
    end
  end

  for Index = #Candidates, 1, -1 do
    if Remaining <= 0 then
      break
    end

    local Candidate =
      Candidates[Index]

    if not Candidate.Data.HighlightMode then
      Candidate.Data.HighlightMode =
        "Full"

      Remaining -= 1
    end
  end

  for _, Candidate in ipairs(
    Candidates
  ) do
    if not Candidate.Data.HighlightMode then
      ClearHighlights(
        Candidate.Data
      )
    end
  end
end

local function UpdateHighlights(
  Player,
  Data,
  Distance,
  Side,
  Visibility
)
  local Mode =
    Data.HighlightMode

  if not Mode
    or not Settings.Highlight
    or Distance > Settings.HighlightDistance
    or not IsFeatureEnabled(
      Side,
      "Highlight",
      Distance
    ) then

    ClearHighlights(Data)
    Data.HighlightMode = nil
    return
  end

  if Mode == "Full" then
    local Color =
      GetHighlightColor(
        Player,
        Visibility.AnyVisible
      )

    SetFullHighlight(
      Data,
      Data.Character,
      Color
    )

    for Part, Highlight in pairs(
      Data.Highlights
    ) do
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

  for _, Part in ipairs(
    GetBodyParts(
      Data.Character
    )
  ) do
    ExistingParts[Part] = true

    local Visible

    if not Settings.VisibilityCheck then
      Visible = true
    elseif Visibility.UseBodyParts then
      Visible =
        Visibility.Parts[Part] == true
    else
      Visible =
        Visibility.AnyVisible
    end

    local Color =
      GetHighlightColor(
        Player,
        Visible
      )

    SetBodyPartHighlight(
      Data,
      Part,
      Color
    )
  end

  for Part, Highlight in pairs(
    Data.Highlights
  ) do
    if not ExistingParts[Part]
      or not Part.Parent then

      Highlight:Destroy()
      Data.Highlights[Part] = nil
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
  if not Settings.Boxes
    or Distance > Settings.BoxDistance
    or not IsFeatureEnabled(
      Side,
      "Box",
      Distance
    ) then

    Data.Box.Visible = false
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
    Data.Box.Visible = false
    return
  end

  Data.BoxStroke.Color =
    GetBoxColor(
      Player,
      Visibility.AnyVisible
    )

  Data.Box.Position =
    UDim2.fromOffset(
      MinX,
      MinY
    )

  Data.Box.Size =
    UDim2.fromOffset(
      math.max(
        MaxX - MinX,
        2
      ),
      math.max(
        MaxY - MinY,
        2
      )
    )

  Data.Box.Visible = true
end

local function UpdateText(
  Player,
  Data,
  Character,
  Distance,
  Side
)
  local Camera =
    workspace.CurrentCamera

  local Root =
    GetRoot(Character)

  if not Camera or not Root then
    Data.TextContainer.Visible =
      false

    return
  end

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

  if not NameEnabled
    and not DistanceEnabled then

    Data.TextContainer.Visible =
      false

    return
  end

  local Position,
    OnScreen =
    Camera:WorldToViewportPoint(
      Root.Position
        + Vector3.new(
          0,
          3.2,
          0
        )
    )

  if Position.Z <= 0
    or not OnScreen then

    Data.TextContainer.Visible =
      false

    return
  end

  Data.TextContainer.Position =
    UDim2.fromOffset(
      Position.X,
      Position.Y
    )

  Data.Name.Visible =
    NameEnabled

  Data.Distance.Visible =
    DistanceEnabled

  Data.Name.Text =
    Player.DisplayName

  Data.Name.TextSize =
    GetNameSize(
      Distance
    )

  Data.Name.TextColor3 =
    GetNameColor(
      Player
    )

  Data.Distance.TextSize =
    GetDistanceSize(
      Distance
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
  else
    Data.Distance.Text = ""
  end

  Data.TextContainer.Visible =
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
    GetCharacter(Player)

  if not Character then
    HideESP(Data)
    return
  end

  local Humanoid =
    Character:FindFirstChildOfClass(
      "Humanoid"
    )

  local Root =
    GetRoot(Character)

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

  if Data.Character ~= Character then
    Data.Character =
      Character

    Data.Visibility =
      nil

    Data.HighlightMode =
      nil

    ClearHighlights(Data)
  end

  local Distance =
    (
      MyRoot.Position
      - Root.Position
    ).Magnitude

  local Side =
    GetSide(Player)

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
    Character,
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
  function(Player)
    RemoveESP(Player)
  end
)

local Timer = 0
local ScanTimer = 0

RunService.RenderStepped:Connect(
  function(Delta)
    Timer += Delta
    ScanTimer += Delta

    if ScanTimer >=
      PLAYER_SCAN_INTERVAL then

      ScanTimer = 0

      for _, Player in ipairs(
        Players:GetPlayers()
      ) do
        if Player ~= LocalPlayer
          and not ESPObjects[Player] then

          CreateESP(Player)
        end
      end
    end

    if Timer <
      UPDATE_INTERVAL then
      return
    end

    Timer = 0

    UpdateHighlightBudget()

    for Player, Data in pairs(
      ESPObjects
    ) do
      if Player.Parent == Players then
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