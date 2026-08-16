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

local DEFAULT_COLORS = {
  EnemyVisible = Color3.fromRGB(70, 255, 100),
  EnemyHidden = Color3.fromRGB(255, 60, 60),
  TeamVisible = Color3.fromRGB(255, 235, 50),
  TeamHidden = Color3.fromRGB(255, 145, 30),

  EnemyName = Color3.fromRGB(255, 255, 255),
  TeamName = Color3.fromRGB(255, 255, 255),

  EnemyDistance = Color3.fromRGB(220, 220, 220),
  TeamDistance = Color3.fromRGB(220, 220, 220),

  EnemyBox = Color3.fromRGB(255, 255, 255),
  TeamBox = Color3.fromRGB(255, 255, 255)
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

  DynamicText = false,
  DynamicTextMode = "Far Bigger",
  DynamicTextCurve = DEFAULT_TEXT_CURVE,

  NameMinSize = MIN_NAME_SIZE,
  NameMaxSize = MAX_NAME_SIZE,

  DistanceMinSize = MIN_DISTANCE_SIZE,
  DistanceMaxSize = MAX_DISTANCE_SIZE,

  RayOrigin = "Character"
}

local Settings = {}

local function ResetSettings()
  for Name, Value in pairs(DEFAULT_SETTINGS) do
    Settings[Name] = Value
  end
end

ResetSettings()

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
})

-- about
Tabs.About:Paragraph({
  Title = "PLAYER ESP",
  Desc = "Advanced player visualization system",
  Image = "eye",
  ImageSize = 26
})

local AboutSection = Tabs.About:Section({
  Title = "About",
  Icon = "info",
  Opened = true,
  Box = true
})

AboutSection:Paragraph({
  Title = "Welcome",
  Desc = "A customizable player visualization system with independent enemy and teammate profiles, advanced visibility detection and performance controls.",
  Image = "sparkles",
  ImageSize = 20
})

local FeaturesInfo = Tabs.About:Section({
  Title = "Features",
  Icon = "layers-3",
  Opened = true,
  Box = true
})

FeaturesInfo:Paragraph({
  Title = "ESP Elements",
  Desc = "Names, distance, individual body-part highlights and 2D boxes.",
  Image = "eye",
  ImageSize = 18
})

FeaturesInfo:Paragraph({
  Title = "Visibility Detection",
  Desc = "Normal or individual body-part raycasting with configurable ray origin and distance-based optimization.",
  Image = "scan-search",
  ImageSize = 18
})

FeaturesInfo:Paragraph({
  Title = "Enemy & Teammate Profiles",
  Desc = "Every ESP element can be configured independently for enemies and teammates.",
  Image = "users",
  ImageSize = 18
})

FeaturesInfo:Paragraph({
  Title = "Dynamic Text",
  Desc = "Names and distance can dynamically change size according to player distance.",
  Image = "move-diagonal-2",
  ImageSize = 18
})

FeaturesInfo:Paragraph({
  Title = "Custom Colors",
  Desc = "Independent colors for visibility states, names, distance and boxes.",
  Image = "palette",
  ImageSize = 18
})

local PerformanceInfo = Tabs.About:Section({
  Title = "Performance",
  Icon = "zap",
  Opened = true,
  Box = true
})

PerformanceInfo:Paragraph({
  Title = "Raycast Optimization",
  Desc = "Body-part raycasting provides precise visibility information. You can configure when it switches to normal raycasting or disable the automatic transition.",
  Image = "zap",
  ImageSize = 18
})

PerformanceInfo:Paragraph({
  Title = "Distance Controls",
  Desc = "Highlight, boxes, names and distance have independent maximum distances and optional close-range disabling.",
  Image = "maximize",
  ImageSize = 18
})

Tabs.About:Paragraph({
  Title = "Tip",
  Desc = "For better performance, use body-part raycasting at shorter distances and normal raycasting at longer distances.",
  Image = "lightbulb",
  ImageSize = 18
})

-- esp
Tabs.ESP:Paragraph({
  Title = "Player ESP",
  Desc = "Control the main ESP features.",
  Image = "eye",
  ImageSize = 20
})

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
  Desc = "Show distance to players",
  Value = Settings.ShowDistance,
  Callback = function(Value)
    Settings.ShowDistance = Value
  end
})

ESPSection:Toggle({
  Title = "Highlight",
  Desc = "Highlight body parts separately",
  Value = Settings.Highlight,
  Callback = function(Value)
    Settings.Highlight = Value
  end
})

ESPSection:Toggle({
  Title = "2D Boxes",
  Desc = "Draw a 2D box around players",
  Value = Settings.Boxes,
  Callback = function(Value)
    Settings.Boxes = Value
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
  Desc = "Maximum distance for names and distance",
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
  Desc = "Maximum distance for highlights",
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
  Title = "Box Distance",
  Desc = "Maximum distance for 2D boxes",
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

local ESPResetSection = Tabs.ESP:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = true,
  Box = true
})

ESPResetSection:Button({
  Title = "Reset ESP",
  Desc = "Restore ESP features and distances",
  Icon = "rotate-ccw",

  Callback = function()
    Settings.ESP = DEFAULT_SETTINGS.ESP
    Settings.ShowName = DEFAULT_SETTINGS.ShowName
    Settings.ShowDistance = DEFAULT_SETTINGS.ShowDistance
    Settings.Highlight = DEFAULT_SETTINGS.Highlight
    Settings.Boxes = DEFAULT_SETTINGS.Boxes
    Settings.TeamCheck = DEFAULT_SETTINGS.TeamCheck

    Settings.ESPDistance = DEFAULT_SETTINGS.ESPDistance
    Settings.HighlightDistance = DEFAULT_SETTINGS.HighlightDistance
    Settings.BoxDistance = DEFAULT_SETTINGS.BoxDistance

    WindUI:Notify({
      Title = "ESP Reset",
      Content = "ESP settings restored",
      Icon = "check",
      Duration = 2
    })
  end
})

-- sides
Tabs.Sides:Paragraph({
  Title = "Side Profiles",
  Desc = "Configure ESP elements independently for enemies and teammates.",
  Image = "users",
  ImageSize = 20
})

local SelectedSide = "Enemy"

Tabs.Sides:Dropdown({
  Title = "Side",
  Desc = "Choose which side to configure",
  Values = {
    "Enemy",
    "Teammate"
  },
  Value = "Enemy",
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

local function CreateSideControl(
  Name,
  Title,
  Description
)
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
    Desc = "Hide this element when the player is close",
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

CreateSideControl(
  "Highlight",
  "Highlight",
  "Highlight player body"
)

CreateSideControl(
  "Box",
  "2D Box",
  "Draw a rectangle around player"
)

CreateSideControl(
  "Name",
  "Name",
  "Show player name"
)

CreateSideControl(
  "Distance",
  "Distance",
  "Show player distance"
)

Tabs.Sides:Paragraph({
  Title = "Near Disable",
  Desc = "Each feature can have its own close-range distance.",
  Image = "info",
  ImageSize = 18
})

local SidesResetSection = Tabs.Sides:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = true,
  Box = true
})

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

-- detection
Tabs.Detection:Paragraph({
  Title = "Visibility Detection",
  Desc = "Control raycast mode, origin and optimization.",
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
  Desc = "Check whether players are behind walls",
  Value = Settings.VisibilityCheck,
  Callback = function(Value)
    Settings.VisibilityCheck = Value
  end
})

DetectionSection:Toggle({
  Title = "Body Part Raycast",
  Desc = "Check each body part separately",
  Value = Settings.BodyPartRaycast,
  Callback = function(Value)
    Settings.BodyPartRaycast = Value
  end
})

DetectionSection:Toggle({
  Title = "Automatic Raycast Fallback",
  Desc = "Switch to normal raycast after the selected distance",
  Value = Settings.BodyPartRaycastFallback,
  Callback = function(Value)
    Settings.BodyPartRaycastFallback = Value
  end
})

DetectionSection:Dropdown({
  Title = "Raycast Origin",
  Desc = "Where rays start from",
  Values = {
    "Character",
    "Camera"
  },
  Value = Settings.RayOrigin,

  Callback = function(Value)
    Settings.RayOrigin = Value
  end
})

DetectionSection:Slider({
  Title = "Body Part Raycast Distance",
  Desc = "Distance where body-part raycast stops",
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

Tabs.Detection:Paragraph({
  Title = "Optimization",
  Desc = "Body-part raycasting is more precise but more expensive. Automatic fallback can switch to one normal raycast at longer distances.",
  Image = "zap",
  ImageSize = 18
})

local DetectionResetSection = Tabs.Detection:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = true,
  Box = true
})

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

    WindUI:Notify({
      Title = "Detection Reset",
      Content = "Detection settings restored",
      Icon = "check",
      Duration = 2
    })
  end
})

-- text
Tabs.Text:Paragraph({
  Title = "Text Settings",
  Desc = "Configure normal and dynamic text size.",
  Image = "type",
  ImageSize = 20
})

local BasicTextSection = Tabs.Text:Section({
  Title = "Basic Size",
  Icon = "text-cursor-input",
  Opened = true,
  Box = true
})

BasicTextSection:Slider({
  Title = "Name Size",
  Desc = "Base name size",
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
  Desc = "Base distance size",
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

local DynamicSection = Tabs.Text:Section({
  Title = "Dynamic Size",
  Icon = "move-diagonal-2",
  Opened = true,
  Box = true
})

DynamicSection:Toggle({
  Title = "Dynamic Text",
  Desc = "Change text size based on distance",
  Value = Settings.DynamicText,

  Callback = function(Value)
    Settings.DynamicText = Value
  end
})

DynamicSection:Dropdown({
  Title = "Dynamic Mode",
  Desc = "Choose how size changes",
  Values = {
    "Far Bigger",
    "Far Smaller"
  },
  Value = Settings.DynamicTextMode,

  Callback = function(Value)
    Settings.DynamicTextMode = Value
  end
})

DynamicSection:Slider({
  Title = "Curve",
  Desc = "Controls how quickly the size changes",
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

TextResetSection:Button({
  Title = "Reset Text",
  Desc = "Restore text sizes and dynamic settings",
  Icon = "rotate-ccw",

  Callback = function()
    Settings.NameSize = DEFAULT_SETTINGS.NameSize
    Settings.DistanceSize = DEFAULT_SETTINGS.DistanceSize

    Settings.DynamicText =
      DEFAULT_SETTINGS.DynamicText

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

    WindUI:Notify({
      Title = "Text Reset",
      Content = "Text settings restored",
      Icon = "check",
      Duration = 2
    })
  end
})

-- colors
Tabs.Colors:Paragraph({
  Title = "ESP Colors",
  Desc = "Customize every ESP color independently.",
  Image = "palette",
  ImageSize = 20
})

local function CreateColorPicker(
  Parent,
  Title,
  Description,
  Key
)
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

CreateColorPicker(
  HighlightColors,
  "Enemy Visible",
  "Enemy body part that is visible",
  "EnemyVisible"
)

CreateColorPicker(
  HighlightColors,
  "Enemy Behind Wall",
  "Enemy body part behind a wall",
  "EnemyHidden"
)

CreateColorPicker(
  HighlightColors,
  "Teammate Visible",
  "Teammate body part that is visible",
  "TeamVisible"
)

CreateColorPicker(
  HighlightColors,
  "Teammate Behind Wall",
  "Teammate body part behind a wall",
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
  "Enemy Box",
  "Enemy box color",
  "EnemyBox"
)

CreateColorPicker(
  BoxColors,
  "Teammate Box",
  "Teammate box color",
  "TeamBox"
)

local ColorsResetSection = Tabs.Colors:Section({
  Title = "Reset",
  Icon = "rotate-ccw",
  Opened = true,
  Box = true
})

ColorsResetSection:Button({
  Title = "Reset Colors",
  Desc = "Restore all ESP colors to defaults",
  Icon = "rotate-ccw",

  Callback = function()
    ResetColors()

    WindUI:Notify({
      Title = "Colors Reset",
      Content = "All ESP colors restored",
      Icon = "check",
      Duration = 2
    })
  end
})

Tabs.Colors:Paragraph({
  Title = "Custom Colors",
  Desc = "ESP colors are independent from the WindUI interface theme.",
  Image = "info",
  ImageSize = 18
})

-- settings
Tabs.Settings:Paragraph({
  Title = "Interface",
  Desc = "Customize the WindUI interface.",
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
  Desc = "Restore all ESP settings, colors, Enemy/Teammate profiles and interface theme.",
  Image = "info",
  ImageSize = 18
})

ResetAllSection:Button({
  Title = "Reset All",
  Desc = "Restore the complete configuration",
  Icon = "refresh-cw",

  Callback = function()
    ResetSettings()
    ResetColors()
    ResetSideSettings()

    WindUI:SetTheme("Dark")

    if ThemeDropdown and ThemeDropdown.Select then
      ThemeDropdown:Select("Dark")
    end

    WindUI:Notify({
      Title = "Everything Reset",
      Content = "All settings restored to defaults",
      Icon = "check",
      Duration = 2
    })
  end
})

-- overlay
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

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

  if Data.NearDisable
    and Distance <= Data.NearDistance then
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

  local Root =
    GetRoot(LocalPlayer.Character)

  return Root and Root.Position
end

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType =
  Enum.RaycastFilterType.Exclude
RaycastParams.IgnoreWater = true

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
    return true, {}
  end

  local Origin = GetRayOrigin()

  if not Origin then
    return false, {}
  end

  local Parts =
    GetBodyParts(Character)

  local UseBodyParts =
    Settings.BodyPartRaycast
    and (
      not Settings.BodyPartRaycastFallback
      or Distance <= Settings.BodyPartRaycastDistance
    )

  if not UseBodyParts then
    local Root = GetRoot(Character)

    if not Root then
      return false, {}
    end

    local Visible =
      IsPartVisible(
        Character,
        Root,
        Origin
      )

    return Visible, {
      [Root] = Visible
    }
  end

  local VisibleParts = {}
  local AnyVisible = false

  for _, Part in ipairs(Parts) do
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

  return AnyVisible, VisibleParts
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

local function GetNameColor(Player)
  if GetSide(Player) == "Teammate" then
    return Colors.TeamName
  end

  return Colors.EnemyName
end

local function GetDistanceColor(Player)
  if GetSide(Player) == "Teammate" then
    return Colors.TeamDistance
  end

  return Colors.EnemyDistance
end

local function GetBoxColor(Player)
  if GetSide(Player) == "Teammate" then
    return Colors.TeamBox
  end

  return Colors.EnemyBox
end

local function GetDynamicSize(
  Distance,
  MinSize,
  MaxSize
)
  if not Settings.DynamicText then
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

  if Settings.DynamicTextMode
    == "Far Bigger" then

    return math.floor(
      MinSize
      + (MaxSize - MinSize)
      * Progress
      + 0.5
    )
  end

  return math.floor(
    MaxSize
    - (MaxSize - MinSize)
    * Progress
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

local function CreatePartHighlight(Part)
  local Highlight = Instance.new("Highlight")

  Highlight.Name = "ESPPartHighlight"
  Highlight.Adornee = Part
  Highlight.DepthMode =
    Enum.HighlightDepthMode.AlwaysOnTop
  Highlight.FillTransparency = 0.45
  Highlight.OutlineTransparency = 0
  Highlight.Enabled = false
  Highlight.Parent = PlayerGui

  return Highlight
end

local function BuildHighlights(
  Data,
  Character
)
  for _, Highlight in pairs(Data.Highlights) do
    Highlight:Destroy()
  end

  Data.Highlights = {}

  for _, Part in ipairs(
    GetBodyParts(Character)
  ) do
    Data.Highlights[Part] =
      CreatePartHighlight(Part)
  end
end

local function GetScreenBounds(Character)
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

  return MinX, MinY, MaxX, MaxY
end

local function HideESP(Data)
  Data.Billboard.Enabled = false
  Data.Box.Visible = false

  for _, Highlight in pairs(
    Data.Highlights
  ) do
    Highlight.Enabled = false
  end
end

local function CreateESP(Player)
  if Player == LocalPlayer
    or ESPObjects[Player] then
    return
  end

  local Billboard =
    Instance.new("BillboardGui")

  Billboard.Name = "PlayerESP"
  Billboard.Size =
    UDim2.fromOffset(220, 60)

  Billboard.StudsOffset =
    Vector3.new(0, 3.2, 0)

  Billboard.AlwaysOnTop = true
  Billboard.MaxDistance =
    MAX_DISTANCE

  Billboard.Enabled = false
  Billboard.Parent = PlayerGui

  local Name =
    Instance.new("TextLabel")

  Name.Name = "Name"
  Name.Size =
    UDim2.new(1, 0, 0, 30)

  Name.BackgroundTransparency = 1
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
    UDim2.new(1, 0, 0, 20)

  Distance.Position =
    UDim2.fromOffset(0, 30)

  Distance.BackgroundTransparency = 1

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

    LastVisibility = true
  }

  ESPObjects[Player] = Data

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

    CurrentData.LastVisibility =
      true

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

local function RemoveESP(Player)
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

  if Data.Billboard then
    Data.Billboard:Destroy()
  end

  if Data.Box then
    Data.Box:Destroy()
  end

  ESPObjects[Player] =
    nil
end

local function UpdateHighlights(
  Player,
  Data,
  Character,
  Distance,
  Side
)
  local Enabled =
    Settings.Highlight
    and Settings.ESP
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
      Highlight.Enabled = false
    end

    return
  end

  local AnyVisible,
    VisibleParts =
    GetVisibility(
      Character,
      Distance
    )

  local UseBodyParts =
    Settings.BodyPartRaycast
    and (
      not Settings.BodyPartRaycastFallback
      or Distance <= Settings.BodyPartRaycastDistance
    )

  for Part, Highlight in pairs(
    Data.Highlights
  ) do
    if Part and Part.Parent then
      local Visible = true

      if Settings.VisibilityCheck then
        if UseBodyParts then
          Visible =
            VisibleParts[Part] == true
        else
          Visible = AnyVisible
        end
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
  Side
)
  if not Settings.Boxes
    or not Settings.ESP
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
    GetBoxColor(Player)

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
  Distance,
  Side
)
  local ShowName =
    Settings.ShowName
    and IsFeatureEnabled(
      Side,
      "Name",
      Distance
    )

  local ShowDistance =
    Settings.ShowDistance
    and IsFeatureEnabled(
      Side,
      "Distance",
      Distance
    )

  Data.Name.Visible =
    ShowName

  Data.Distance.Visible =
    ShowDistance

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

  if ShowDistance then
    Data.Distance.Text =
      math.floor(
        Distance
      ) .. " studs"
  end
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

  if Data.Character ~= Character then
    Data.Character =
      Character

    BuildHighlights(
      Data,
      Character
    )

    local Root =
      GetRoot(Character)

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

  local Distance =
    (
      MyRoot.Position
      - Root.Position
    ).Magnitude

  local Side =
    GetSide(Player)

  Data.Billboard.Enabled =
    Distance <= Settings.ESPDistance

  if Settings.VisibilityCheck then
    local AnyVisible =
      GetVisibility(
        Character,
        Distance
      )

    Data.LastVisibility =
      AnyVisible
  else
    Data.LastVisibility =
      true
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
    Character,
    Distance,
    Side
  )

  UpdateBox(
    Player,
    Data,
    Character,
    Distance,
    Side
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

    if ScanTimer >= 1 then
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

    if Timer < 0.05 then
      return
    end

    Timer = 0

    for Player, Data in pairs(
      ESPObjects
    ) do
      if Player.Parent == Players then
        UpdateESP(
          Player,
          Data
        )
      else
        RemoveESP(Player)
      end
    end
  end
)