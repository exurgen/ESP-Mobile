local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WindUI = loadstring(game:HttpGet(
  "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- limits
local MIN_DISTANCE = 50
local MAX_DISTANCE = 2000
local DEFAULT_DISTANCE = 1000

local MIN_NAME_SIZE = 8
local MAX_NAME_SIZE = 24
local DEFAULT_NAME_SIZE = 14

local MIN_DISTANCE_SIZE = 6
local MAX_DISTANCE_SIZE = 18
local DEFAULT_DISTANCE_SIZE = 10

local MIN_UPDATE_INTERVAL = 0.05

local Colors = {
  EnemyVisible = Color3.fromRGB(70, 255, 100),
  EnemyHidden = Color3.fromRGB(255, 60, 60),
  TeamVisible = Color3.fromRGB(255, 235, 50),
  TeamHidden = Color3.fromRGB(255, 145, 30)
}

local Settings = {
  ESP = true,
  Highlight = true,
  Boxes = true,
  ShowName = true,
  ShowDistance = true,
  VisibilityCheck = true,
  BodyPartRaycast = true,
  TeamCheck = true,

  ESPDistance = DEFAULT_DISTANCE,
  HighlightDistance = DEFAULT_DISTANCE,
  BoxDistance = DEFAULT_DISTANCE,

  NameSize = DEFAULT_NAME_SIZE,
  DistanceSize = DEFAULT_DISTANCE_SIZE,

  RayOrigin = "Character"
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

-- window
local Window = WindUI:CreateWindow({
  Title = "PLAYER ESP",
  Icon = "eye",
  Author = "Mobile ESP",
  Folder = "PlayerESP",
  Size = UDim2.fromOffset(520, 440),
  MinSize = Vector2.new(360, 300),
  MaxSize = Vector2.new(800, 650),
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
  ESP = Sections.Features:Tab({
    Title = "ESP",
    Icon = "eye",
    Desc = "Main ESP features"
  }),

  Misc = Sections.Features:Tab({
    Title = "Misc",
    Icon = "sliders-horizontal",
    Desc = "Appearance settings"
  }),

  Detection = Sections.Features:Tab({
    Title = "Detection",
    Icon = "scan-search",
    Desc = "Visibility and raycast"
  }),

  Settings = Sections.Settings:Tab({
    Title = "Settings",
    Icon = "settings",
    Desc = "Interface settings"
  })
}

-- ESP
Tabs.ESP:Paragraph({
  Title = "Player ESP",
  Desc = "Control the main ESP elements.",
  Image = "eye",
  ImageSize = 20
})

local ESPSection = Tabs.ESP:Section({
  Title = "Elements",
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
  Title = "Highlight",
  Desc = "Highlight body parts separately",
  Value = Settings.Highlight,
  Callback = function(value)
    Settings.Highlight = value
  end
})

ESPSection:Toggle({
  Title = "2D Boxes",
  Desc = "Draw a 2D rectangle around players",
  Value = Settings.Boxes,
  Callback = function(value)
    Settings.Boxes = value
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
  Desc = "Show distance below names",
  Value = Settings.ShowDistance,
  Callback = function(value)
    Settings.ShowDistance = value
  end
})

local DistanceSection = Tabs.ESP:Section({
  Title = "Distance",
  Icon = "maximize",
  Opened = true,
  Box = true
})

DistanceSection:Slider({
  Title = "Name / Distance",
  Desc = "Maximum distance for ESP text",
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
  Desc = "Maximum distance for body highlights",
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

-- Misc
Tabs.Misc:Paragraph({
  Title = "ESP Appearance",
  Desc = "Customize text and visual proportions.",
  Image = "paintbrush",
  ImageSize = 20
})

local TextSection = Tabs.Misc:Section({
  Title = "Text",
  Icon = "type",
  Opened = true,
  Box = true
})

TextSection:Slider({
  Title = "Name Size",
  Desc = "Size of player names",
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

TextSection:Slider({
  Title = "Distance Text Size",
  Desc = "Size of distance text",
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

-- Detection
Tabs.Detection:Paragraph({
  Title = "Visibility Detection",
  Desc = "Choose how walls and visible body parts are detected.",
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
  Title = "Body Part Raycasting",
  Desc = "Check every body part separately",
  Value = Settings.BodyPartRaycast,
  Callback = function(value)
    Settings.BodyPartRaycast = value
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

Tabs.Detection:Paragraph({
  Title = "Raycast Modes",
  Desc = "Body Part Raycasting colors each body part separately. Normal mode checks the HumanoidRootPart. Character origin starts rays from your HumanoidRootPart; Camera origin starts them from the current camera.",
  Image = "info",
  ImageSize = 18
})

local TeamSection = Tabs.Detection:Section({
  Title = "Teams",
  Icon = "users",
  Opened = true,
  Box = true
})

TeamSection:Toggle({
  Title = "Team Check",
  Desc = "Use separate colors for teammates",
  Value = Settings.TeamCheck,
  Callback = function(value)
    Settings.TeamCheck = value
  end
})

-- Settings
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

local canchangetheme = true
local canchangedropdown = true

local ThemeDropdown = AppearanceSection:Dropdown({
  Title = "Theme",
  Desc = "Choose interface theme",
  Values = Themes,
  Flag = "ThemeDropdown",
  SearchBarEnabled = true,
  MenuWidth = 280,
  Value = "Dark",

  Callback = function(theme)
    canchangedropdown = false
    WindUI:SetTheme(theme)

    WindUI:Notify({
      Title = "Theme Applied",
      Content = theme,
      Icon = "palette",
      Duration = 2
    })

    canchangedropdown = true
  end
})

local ThemeToggle = AppearanceSection:Toggle({
  Title = "Dark Mode",
  Desc = "Quickly switch between Dark and Light",
  Value = true,

  Callback = function(value)
    if canchangetheme then
      WindUI:SetTheme(value and "Dark" or "Light")
    end

    if canchangedropdown then
      ThemeDropdown:Select(value and "Dark" or "Light")
    end
  end
})

WindUI:OnThemeChange(function(theme)
  canchangetheme = false
  ThemeToggle:Set(theme == "Dark")
  canchangetheme = true
end)

-- overlay
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

-- helpers
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

local function GetBodyParts(character)
  local Parts = {}

  for _, PartName in ipairs(BodyPartNames) do
    local Part = character:FindFirstChild(PartName)

    if Part and Part:IsA("BasePart") then
      table.insert(Parts, Part)
    end
  end

  return Parts
end

local function IsTeamMate(player)
  if not Settings.TeamCheck then
    return false
  end

  return LocalPlayer.Team ~= nil
    and player.Team ~= nil
    and LocalPlayer.Team == player.Team
end

local function GetColor(player, visible)
  if IsTeamMate(player) then
    return visible
      and Colors.TeamVisible
      or Colors.TeamHidden
  end

  return visible
    and Colors.EnemyVisible
    or Colors.EnemyHidden
end

local function GetRayOrigin()
  if Settings.RayOrigin == "Camera" then
    local Camera = workspace.CurrentCamera

    if Camera then
      return Camera.CFrame.Position
    end

    return nil
  end

  local Character = LocalPlayer.Character
  local Root = GetRoot(Character)

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
    LocalPlayer.Character,
    character
  }

  local Result = workspace:Raycast(
    origin,
    Direction,
    RaycastParams
  )

  return Result == nil
end

local function GetVisibility(character)
  local Origin = GetRayOrigin()

  if not Origin then
    return false
  end

  local Parts = GetBodyParts(character)

  if Settings.BodyPartRaycast then
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

local function CreateBox()
  local Box = Instance.new("Frame")
  Box.Name = "Box"
  Box.BackgroundTransparency = 1
  Box.BorderSizePixel = 0
  Box.Visible = false
  Box.ZIndex = 10
  Box.Parent = ESPGui

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
  Highlight.Parent = ESPGui

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
    local HalfSize = Part.Size / 2

    for X = -1, 1, 2 do
      for Y = -1, 1, 2 do
        for Z = -1, 1, 2 do
          local WorldPosition = Part.CFrame:PointToWorldSpace(
            Vector3.new(
              HalfSize.X * X,
              HalfSize.Y * Y,
              HalfSize.Z * Z
            )
          )

          local ScreenPosition =
            Camera:WorldToViewportPoint(WorldPosition)

          if ScreenPosition.Z > 0 then
            MinX = math.min(MinX, ScreenPosition.X)
            MinY = math.min(MinY, ScreenPosition.Y)
            MaxX = math.max(MaxX, ScreenPosition.X)
            MaxY = math.max(MaxY, ScreenPosition.Y)
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

-- ESP creation
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
  Name.TextSize = Settings.NameSize
  Name.Font = Enum.Font.GothamBold
  Name.TextStrokeTransparency = 0.35
  Name.Parent = Billboard

  local Distance = Instance.new("TextLabel")
  Distance.Name = "Distance"
  Distance.Size = UDim2.new(1, 0, 0, 20)
  Distance.Position = UDim2.fromOffset(0, 30)
  Distance.BackgroundTransparency = 1
  Distance.TextSize = Settings.DistanceSize
  Distance.Font = Enum.Font.GothamMedium
  Distance.TextColor3 = Color3.fromRGB(220, 220, 220)
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
    HighlightDistanceState = false
  }

  ESPObjects[player] = Data

  local function Attach(character)
    local CurrentData = ESPObjects[player]

    if not CurrentData then
      return
    end

    CurrentData.Character = character
    CurrentData.HighlightDistanceState = false

    CurrentData.Billboard.Adornee =
      character:FindFirstChild("HumanoidRootPart")

    for _, Highlight in pairs(CurrentData.Highlights) do
      Highlight:Destroy()
    end

    CurrentData.Highlights = {}
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

local function UpdateHighlight(player, Data, character, distance)
  local Active =
    Settings.ESP and
    Settings.Highlight and
    distance <= Settings.HighlightDistance

  if not Active then
    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    Data.HighlightDistanceState = false
    return
  end

  if not Data.HighlightDistanceState
    or next(Data.Highlights) == nil then

    BuildHighlights(Data, character)
    Data.HighlightDistanceState = true
  end

  local AnyVisible, VisibleParts =
    GetVisibility(character)

  for Part, Highlight in pairs(Data.Highlights) do
    if Part and Part.Parent then
      local Visible

      if Settings.VisibilityCheck then
        if Settings.BodyPartRaycast then
          Visible = VisibleParts[Part] == true
        else
          Visible = AnyVisible
        end
      else
        Visible = true
      end

      local Color = GetColor(
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

  Data.LastVisibility = AnyVisible
end

local function UpdateBox(player, Data, character, distance)
  if not Settings.ESP
    or not Settings.Boxes
    or distance > Settings.BoxDistance then

    Data.Box.Visible = false
    return
  end

  local MinX, MinY, MaxX, MaxY =
    GetScreenBounds(character)

  if not MinX then
    Data.Box.Visible = false
    return
  end

  local Visible = Data.LastVisibility

  if Visible == nil then
    Visible = true
  end

  Data.BoxStroke.Color = GetColor(
    player,
    Visible
  )

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

local function UpdateESP(player, Data)
  if not Settings.ESP then
    Data.Billboard.Enabled = false
    Data.Box.Visible = false

    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    return
  end

  local Character = GetCharacter(player)

  if not Character then
    Data.Billboard.Enabled = false
    Data.Box.Visible = false

    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    return
  end

  if Data.Character ~= Character then
    Data.Character = Character
    Data.HighlightDistanceState = false
    Data.LastVisibility = nil

    for _, Highlight in pairs(Data.Highlights) do
      Highlight:Destroy()
    end

    Data.Highlights = {}

    local Root = GetRoot(Character)

    if Root then
      Data.Billboard.Adornee = Root
    end
  end

  local Humanoid = Character:FindFirstChildOfClass("Humanoid")
  local Root = GetRoot(Character)
  local MyRoot = GetRoot(LocalPlayer.Character)

  if not Humanoid or not Root or not MyRoot
    or Humanoid.Health <= 0 then

    Data.Billboard.Enabled = false
    Data.Box.Visible = false

    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    return
  end

  local Distance = (
    MyRoot.Position - Root.Position
  ).Magnitude

  if Distance <= Settings.ESPDistance then
    Data.Billboard.Enabled = true

    Data.Name.Visible = Settings.ShowName
    Data.Distance.Visible = Settings.ShowDistance

    Data.Name.TextSize = Settings.NameSize
    Data.Distance.TextSize = Settings.DistanceSize

    if Settings.ShowDistance then
      Data.Distance.Text =
        math.floor(Distance) .. " studs"
    end
  else
    Data.Billboard.Enabled = false
  end

  UpdateHighlight(
    player,
    Data,
    Character,
    Distance
  )

  UpdateBox(
    player,
    Data,
    Character,
    Distance
  )
end

-- players
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

Players.PlayerRemoving:Connect(RemoveESP)

-- loop
local Timer = 0

RunService.RenderStepped:Connect(function(delta)
  Timer += delta

  if Timer < MIN_UPDATE_INTERVAL then
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

  for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and not ESPObjects[player] then
      CreateESP(player)
    end
  end
end)