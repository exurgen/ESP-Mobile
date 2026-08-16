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
  TeamBox = Color3.fromRGB(255, 235, 50)
}

local Colors = {}

for Name, Color in pairs(DEFAULT_COLORS) do
  Colors[Name] = Color
end

local Settings = {
  ESP = true,
  VisibilityCheck = true,
  BodyPartRaycast = true,
  TeamCheck = true,

  ShowName = true,
  ShowDistance = true,

  Highlight = true,
  Boxes = true,

  ESPDistance = DEFAULT_DISTANCE,
  HighlightDistance = DEFAULT_DISTANCE,
  BoxDistance = DEFAULT_DISTANCE,

  BodyPartRaycastDistance = 500,
  BodyPartRaycastFallback = true,

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

local SideSettings = {
  Enemy = {
    Highlight = {Enabled = true, NearDisable = false, NearDistance = 100},
    Box = {Enabled = true, NearDisable = false, NearDistance = 100},
    Name = {Enabled = true, NearDisable = false, NearDistance = 100},
    Distance = {Enabled = true, NearDisable = false, NearDistance = 100}
  },

  Teammate = {
    Highlight = {Enabled = true, NearDisable = false, NearDistance = 100},
    Box = {Enabled = true, NearDisable = false, NearDistance = 100},
    Name = {Enabled = true, NearDisable = false, NearDistance = 100},
    Distance = {Enabled = true, NearDisable = false, NearDistance = 100}
  }
}

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
}

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
  Callback = function(value)
    Settings.ESP = value
  end
})

ESPSection:Toggle({
  Title = "Names",
  Desc = "Show player names",
  Value = Settings.ShowName,
  Callback = function(value)
    Settings.ShowName = value
  end
})

ESPSection:Toggle({
  Title = "Distance",
  Desc = "Show distance to players",
  Value = Settings.ShowDistance,
  Callback = function(value)
    Settings.ShowDistance = value
  end
})

ESPSection:Toggle({
  Title = "Highlight",
  Desc = "Highlight body parts separately",
  Value = Settings.Highlight,
  Callback = function(value)
    Settings.Highlight = value
  end
})

ESPSection:Toggle({
  Title = "2D Boxes",
  Desc = "Draw a 2D box around players",
  Value = Settings.Boxes,
  Callback = function(value)
    Settings.Boxes = value
  end
})

ESPSection:Toggle({
  Title = "Team Check",
  Desc = "Separate enemies and teammates",
  Value = Settings.TeamCheck,
  Callback = function(value)
    Settings.TeamCheck = value
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
  Callback = function(value)
    Settings.ESPDistance = value
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
  Callback = function(value)
    Settings.HighlightDistance = value
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
  Callback = function(value)
    Settings.BoxDistance = value
  end
})

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
  Callback = function(value)
    SelectedSide = value
  end
})

local SideSection = Tabs.Sides:Section({
  Title = "Elements",
  Icon = "layers-3",
  Opened = true,
  Box = true
})

local SideControls = {}

local function CreateSideControl(name, title, description)
  SideControls[name] = {
    Enabled = SideSection:Toggle({
      Title = title,
      Desc = description,
      Value = SideSettings.Enemy[name].Enabled,
      Callback = function(value)
        SideSettings[SelectedSide][name].Enabled = value
      end
    }),

    NearDisable = SideSection:Toggle({
      Title = "Disable " .. title .. " Near",
      Desc = "Hide this element when the player is close",
      Value = SideSettings.Enemy[name].NearDisable,
      Callback = function(value)
        SideSettings[SelectedSide][name].NearDisable = value
      end
    }),

    NearDistance = SideSection:Slider({
      Title = title .. " Near Distance",
      Desc = "Disable below this distance",
      Value = {
        Min = MIN_NEAR_DISTANCE,
        Max = MAX_NEAR_DISTANCE,
        Default = SideSettings.Enemy[name].NearDistance
      },
      Step = 1,
      Callback = function(value)
        SideSettings[SelectedSide][name].NearDistance = value
      end
    })
  }
end

CreateSideControl("Highlight", "Highlight", "Highlight player body")
CreateSideControl("Box", "2D Box", "Draw a rectangle around player")
CreateSideControl("Name", "Name", "Show player name")
CreateSideControl("Distance", "Distance", "Show player distance")

Tabs.Sides:Paragraph({
  Title = "Near Disable",
  Desc = "Each feature can have its own close-range distance or stay enabled at any distance.",
  Image = "info",
  ImageSize = 18
})

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
  Callback = function(value)
    Settings.VisibilityCheck = value
  end
})

DetectionSection:Toggle({
  Title = "Body Part Raycast",
  Desc = "Check each body part separately",
  Value = Settings.BodyPartRaycast,
  Callback = function(value)
    Settings.BodyPartRaycast = value
  end
})

DetectionSection:Toggle({
  Title = "Automatic Raycast Fallback",
  Desc = "Switch to normal raycast after the selected distance",
  Value = Settings.BodyPartRaycastFallback,
  Callback = function(value)
    Settings.BodyPartRaycastFallback = value
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
  Callback = function(value)
    Settings.RayOrigin = value
  end
})

DetectionSection:Slider({
  Title = "Body Part Raycast Distance",
  Desc = "Distance used before normal raycast",
  Value = {
    Min = MIN_DISTANCE,
    Max = MAX_DISTANCE,
    Default = Settings.BodyPartRaycastDistance
  },
  Step = 1,
  Callback = function(value)
    Settings.BodyPartRaycastDistance = value
  end
})

Tabs.Detection:Paragraph({
  Title = "Optimization",
  Desc = "Body-part raycasting is more precise but more expensive. Automatic fallback can switch to one normal raycast at longer distances.",
  Image = "zap",
  ImageSize = 18
})

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
  Callback = function(value)
    Settings.NameSize = value
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
  Callback = function(value)
    Settings.DistanceSize = value
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
  Callback = function(value)
    Settings.DynamicText = value
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
  Callback = function(value)
    Settings.DynamicTextMode = value
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
  Callback = function(value)
    Settings.DynamicTextCurve = value
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
  Callback = function(value)
    Settings.NameMinSize = value
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
  Callback = function(value)
    Settings.NameMaxSize = value
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
  Callback = function(value)
    Settings.DistanceMinSize = value
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
  Callback = function(value)
    Settings.DistanceMaxSize = value
  end
})

Tabs.Colors:Paragraph({
  Title = "ESP Colors",
  Desc = "Customize colors for every ESP state and element.",
  Image = "palette",
  ImageSize = 20
})

local VisibilityColorsSection = Tabs.Colors:Section({
  Title = "Visibility",
  Icon = "eye",
  Opened = true,
  Box = true
})

local function CreateColorPicker(parent, title, description, colorKey)
  parent:Colorpicker({
    Title = title,
    Desc = description,
    Default = Colors[colorKey],
    Transparency = 0,

    Callback = function(color)
      Colors[colorKey] = color
    end
  })
end

CreateColorPicker(
  VisibilityColorsSection,
  "Enemy Visible",
  "Enemy body parts with clear visibility",
  "EnemyVisible"
)

CreateColorPicker(
  VisibilityColorsSection,
  "Enemy Hidden",
  "Enemy body parts behind walls",
  "EnemyHidden"
)

CreateColorPicker(
  VisibilityColorsSection,
  "Teammate Visible",
  "Teammate body parts with clear visibility",
  "TeamVisible"
)

CreateColorPicker(
  VisibilityColorsSection,
  "Teammate Hidden",
  "Teammate body parts behind walls",
  "TeamHidden"
)

local TextColorsSection = Tabs.Colors:Section({
  Title = "Text",
  Icon = "type",
  Opened = true,
  Box = true
})

CreateColorPicker(
  TextColorsSection,
  "Enemy Name",
  "Enemy name color",
  "EnemyName"
)

CreateColorPicker(
  TextColorsSection,
  "Teammate Name",
  "Teammate name color",
  "TeamName"
)

CreateColorPicker(
  TextColorsSection,
  "Enemy Distance",
  "Enemy distance color",
  "EnemyDistance"
)

CreateColorPicker(
  TextColorsSection,
  "Teammate Distance",
  "Teammate distance color",
  "TeamDistance"
)

local BoxColorsSection = Tabs.Colors:Section({
  Title = "2D Boxes",
  Icon = "square",
  Opened = true,
  Box = true
})

CreateColorPicker(
  BoxColorsSection,
  "Enemy Box",
  "Enemy 2D box color",
  "EnemyBox"
)

CreateColorPicker(
  BoxColorsSection,
  "Teammate Box",
  "Teammate 2D box color",
  "TeamBox"
)

local function ResetColors()
  for Name, Color in pairs(DEFAULT_COLORS) do
    Colors[Name] = Color
  end
end

Tabs.Colors:Button({
  Title = "Reset Colors",
  Desc = "Restore all ESP colors to their defaults",
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

Tabs.Settings:Paragraph({
  Title = "Interface",
  Desc = "Customize the WindUI interface.",
  Image = "palette",
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

  Callback = function(theme)
    if theme then
      WindUI:SetTheme(theme)
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

Window:Open()

local function GetCharacter(player)
  local Character = player.Character

  if Character and Character.Parent then
    return Character
  end

  return nil
end

local function GetRoot(character)
  return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetSide(player)
  if Settings.TeamCheck
    and LocalPlayer.Team ~= nil
    and player.Team ~= nil
    and LocalPlayer.Team == player.Team then
    return "Teammate"
  end

  return "Enemy"
end

local function IsFeatureEnabled(side, feature, distance)
  local Data = SideSettings[side][feature]

  if not Data.Enabled then
    return false
  end

  if Data.NearDisable and distance <= Data.NearDistance then
    return false
  end

  return true
end

local function GetBodyParts(character)
  local Parts = {}

  for _, Name in ipairs(BodyPartNames) do
    local Part = character:FindFirstChild(Name)

    if Part and Part:IsA("BasePart") then
      table.insert(Parts, Part)
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

local function IsPartVisible(character, part, origin)
  if not part or not origin then
    return false
  end

  local Direction = part.Position - origin

  if Direction.Magnitude <= 0.01 then
    return true
  end

  RaycastParams.FilterDescendantsInstances = {
    LocalPlayer.Character
  }

  local Result = workspace:Raycast(
    origin,
    Direction,
    RaycastParams
  )

  return Result == nil
    or Result.Instance:IsDescendantOf(character)
end

local function GetVisibility(character, distance)
  if not Settings.VisibilityCheck then
    return true, {}
  end

  local Origin = GetRayOrigin()

  if not Origin then
    return false, {}
  end

  local Parts = GetBodyParts(character)

  local UseBodyParts =
    Settings.BodyPartRaycast
    and (
      not Settings.BodyPartRaycastFallback
      or distance <= Settings.BodyPartRaycastDistance
    )

  if not UseBodyParts then
    local Root = GetRoot(character)

    if not Root then
      return false, {}
    end

    local Visible = IsPartVisible(
      character,
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
    local Visible = IsPartVisible(
      character,
      Part,
      Origin
    )

    VisibleParts[Part] = Visible
    AnyVisible = AnyVisible or Visible
  end

  return AnyVisible, VisibleParts
end

local function GetHighlightColor(player, visible)
  if GetSide(player) == "Teammate" then
    return visible
      and Colors.TeamVisible
      or Colors.TeamHidden
  end

  return visible
    and Colors.EnemyVisible
    or Colors.EnemyHidden
end

local function GetNameColor(player)
  if GetSide(player) == "Teammate" then
    return Colors.TeamName
  end

  return Colors.EnemyName
end

local function GetDistanceColor(player)
  if GetSide(player) == "Teammate" then
    return Colors.TeamDistance
  end

  return Colors.EnemyDistance
end

local function GetBoxColor(player)
  if GetSide(player) == "Teammate" then
    return Colors.TeamBox
  end

  return Colors.EnemyBox
end

local function GetDynamicSize(distance, minSize, maxSize)
  if not Settings.DynamicText then
    return nil
  end

  if Settings.ESPDistance <= 0 then
    return minSize
  end

  local Alpha = math.clamp(
    distance / Settings.ESPDistance,
    0,
    1
  )

  local Progress = Alpha ^ Settings.DynamicTextCurve

  if Settings.DynamicTextMode == "Far Bigger" then
    return math.floor(
      minSize + (maxSize - minSize) * Progress
    )
  end

  return math.floor(
    maxSize - (maxSize - minSize) * Progress
  )
end

local function GetNameSize(distance)
  return GetDynamicSize(
    distance,
    Settings.NameMinSize,
    Settings.NameMaxSize
  ) or Settings.NameSize
end

local function GetDistanceSize(distance)
  return GetDynamicSize(
    distance,
    Settings.DistanceMinSize,
    Settings.DistanceMaxSize
  ) or Settings.DistanceSize
end

local function CreateBox()
  local Box = Instance.new("Frame")
  Box.Name = "Box"
  Box.BackgroundTransparency = 1
  Box.BorderSizePixel = 0
  Box.Visible = false
  Box.ZIndex = 10
  Box.Parent = PlayerGui

  local Stroke = Instance.new("UIStroke")
  Stroke.Thickness = 1.5
  Stroke.Parent = Box

  return Box, Stroke
end

local function CreatePartHighlight(part)
  local Highlight = Instance.new("Highlight")

  Highlight.Name = "ESPPartHighlight"
  Highlight.Adornee = part
  Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  Highlight.FillTransparency = 0.45
  Highlight.OutlineTransparency = 0
  Highlight.Enabled = false
  Highlight.Parent = PlayerGui

  return Highlight
end

local function BuildHighlights(Data, character)
  for _, Highlight in pairs(Data.Highlights) do
    Highlight:Destroy()
  end

  Data.Highlights = {}

  for _, Part in ipairs(GetBodyParts(character)) do
    Data.Highlights[Part] = CreatePartHighlight(Part)
  end
end

local function GetScreenBounds(character)
  local Camera = workspace.CurrentCamera

  if not Camera then
    return nil
  end

  local MinX = math.huge
  local MinY = math.huge
  local MaxX = -math.huge
  local MaxY = -math.huge
  local Found = false

  for _, Part in ipairs(GetBodyParts(character)) do
    local Half = Part.Size / 2

    for X = -1, 1, 2 do
      for Y = -1, 1, 2 do
        for Z = -1, 1, 2 do
          local WorldPosition = Part.CFrame:PointToWorldSpace(
            Vector3.new(
              Half.X * X,
              Half.Y * Y,
              Half.Z * Z
            )
          )

          local Position =
            Camera:WorldToViewportPoint(WorldPosition)

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

  if not Found then
    return nil
  end

  return MinX, MinY, MaxX, MaxY
end

local function CreateESP(player)
  if player == LocalPlayer or ESPObjects[player] then
    return
  end

  local Billboard = Instance.new("BillboardGui")
  Billboard.Name = "PlayerESP"
  Billboard.Size = UDim2.fromOffset(220, 60)
  Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
  Billboard.AlwaysOnTop = true
  Billboard.MaxDistance = MAX_DISTANCE
  Billboard.Enabled = false
  Billboard.Parent = PlayerGui

  local Name = Instance.new("TextLabel")
  Name.Name = "Name"
  Name.Size = UDim2.new(1, 0, 0, 30)
  Name.BackgroundTransparency = 1
  Name.Text = player.DisplayName
  Name.Font = Enum.Font.GothamBold
  Name.TextStrokeTransparency = 0.35
  Name.Parent = Billboard

  local Distance = Instance.new("TextLabel")
  Distance.Name = "Distance"
  Distance.Size = UDim2.new(1, 0, 0, 20)
  Distance.Position = UDim2.fromOffset(0, 30)
  Distance.BackgroundTransparency = 1
  Distance.Font = Enum.Font.GothamMedium
  Distance.TextStrokeTransparency = 0.5
  Distance.Parent = Billboard

  local Box, BoxStroke = CreateBox()

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

  ESPObjects[player] = Data

  local function Attach(character)
    local CurrentData = ESPObjects[player]

    if not CurrentData then
      return
    end

    CurrentData.Character = character
    CurrentData.LastVisibility = true

    local Root = GetRoot(character)

    if Root then
      CurrentData.Billboard.Adornee = Root
    end

    BuildHighlights(CurrentData, character)
  end

  if player.Character then
    task.spawn(Attach, player.Character)
  end

  Data.Connection = player.CharacterAdded:Connect(function(character)
    task.wait(0.1)

    if ESPObjects[player] then
      Attach(character)
    end
  end)
end

local function RemoveESP(player)
  local Data = ESPObjects[player]

  if not Data then
    return
  end

  if Data.Connection then
    Data.Connection:Disconnect()
  end

  for _, Highlight in pairs(Data.Highlights) do
    Highlight:Destroy()
  end

  if Data.Billboard then
    Data.Billboard:Destroy()
  end

  if Data.Box then
    Data.Box:Destroy()
  end

  ESPObjects[player] = nil
end

local function UpdateHighlights(player, Data, character, distance, side)
  local Enabled =
    Settings.Highlight
    and Settings.ESP
    and distance <= Settings.HighlightDistance
    and IsFeatureEnabled(side, "Highlight", distance)

  if not Enabled then
    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    return
  end

  local AnyVisible, VisibleParts =
    GetVisibility(character, distance)

  for Part, Highlight in pairs(Data.Highlights) do
    if Part and Part.Parent then
      local Visible = true

      if Settings.VisibilityCheck then
        local UseBodyParts =
          Settings.BodyPartRaycast
          and (
            not Settings.BodyPartRaycastFallback
            or distance <= Settings.BodyPartRaycastDistance
          )

        if UseBodyParts then
          Visible = VisibleParts[Part] == true
        else
          Visible = AnyVisible
        end
      end

      local Color = GetHighlightColor(
        player,
        Visible
      )

      Highlight.FillColor = Color
      Highlight.OutlineColor = Color
      Highlight.Enabled = true
    else
      Highlight.Enabled = false
    end
  end
end

local function UpdateBox(player, Data, character, distance, side)
  if not Settings.Boxes
    or not Settings.ESP
    or distance > Settings.BoxDistance
    or not IsFeatureEnabled(side, "Box", distance) then

    Data.Box.Visible = false
    return
  end

  local MinX, MinY, MaxX, MaxY =
    GetScreenBounds(character)

  if not MinX then
    Data.Box.Visible = false
    return
  end

  Data.BoxStroke.Color = GetBoxColor(player)

  Data.Box.Position = UDim2.fromOffset(
    MinX,
    MinY
  )

  Data.Box.Size = UDim2.fromOffset(
    math.max(MaxX - MinX, 2),
    math.max(MaxY - MinY, 2)
  )

  Data.Box.Visible = true
end

local function UpdateText(player, Data, distance, side)
  local ShowName =
    Settings.ShowName
    and IsFeatureEnabled(side, "Name", distance)

  local ShowDistance =
    Settings.ShowDistance
    and IsFeatureEnabled(side, "Distance", distance)

  Data.Name.Visible = ShowName
  Data.Distance.Visible = ShowDistance

  Data.Name.TextSize = GetNameSize(distance)
  Data.Distance.TextSize = GetDistanceSize(distance)

  Data.Name.TextColor3 = GetNameColor(player)
  Data.Distance.TextColor3 = GetDistanceColor(player)

  if ShowDistance then
    Data.Distance.Text =
      math.floor(distance) .. " studs"
  end
end

local function DisableESP(Data)
  Data.Billboard.Enabled = false
  Data.Box.Visible = false

  for _, Highlight in pairs(Data.Highlights) do
    Highlight.Enabled = false
  end
end

local function UpdateESP(player, Data)
  if not Settings.ESP then
    DisableESP(Data)
    return
  end

  local Character = GetCharacter(player)

  if not Character then
    DisableESP(Data)
    return
  end

  if Data.Character ~= Character then
    Data.Character = Character
    BuildHighlights(Data, Character)

    local Root = GetRoot(Character)

    if Root then
      Data.Billboard.Adornee = Root
    end
  end

  local Humanoid = Character:FindFirstChildOfClass("Humanoid")
  local Root = GetRoot(Character)
  local MyRoot = GetRoot(LocalPlayer.Character)

  if not Humanoid
    or not Root
    or not MyRoot
    or Humanoid.Health <= 0 then

    DisableESP(Data)
    return
  end

  local Distance = (
    MyRoot.Position - Root.Position
  ).Magnitude

  local Side = GetSide(player)

  Data.Billboard.Enabled =
    Distance <= Settings.ESPDistance

  if Settings.VisibilityCheck then
    local AnyVisible = GetVisibility(
      Character,
      Distance
    )

    Data.LastVisibility = AnyVisible
  else
    Data.LastVisibility = true
  end

  UpdateText(
    player,
    Data,
    Distance,
    Side
  )

  UpdateHighlights(
    player,
    Data,
    Character,
    Distance,
    Side
  )

  UpdateBox(
    player,
    Data,
    Character,
    Distance,
    Side
  )
end

for _, player in ipairs(Players:GetPlayers()) do
  if player ~= LocalPlayer then
    CreateESP(player)
  end
end

Players.PlayerAdded:Connect(function(player)
  if player ~= LocalPlayer then
    CreateESP(player)
  end
end)

Players.PlayerRemoving:Connect(function(player)
  RemoveESP(player)
end)

local Timer = 0
local ScanTimer = 0

RunService.RenderStepped:Connect(function(delta)
  Timer += delta
  ScanTimer += delta

  if ScanTimer >= 1 then
    ScanTimer = 0

    for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer
        and not ESPObjects[player] then
        CreateESP(player)
      end
    end
  end

  if Timer < 0.05 then
    return
  end

  Timer = 0

  for player, Data in pairs(ESPObjects) do
    if player.Parent == Players then
      UpdateESP(player, Data)
    else
      RemoveESP(player)
    end
  end
end)