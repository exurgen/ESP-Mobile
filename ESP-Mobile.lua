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

local Colors = {
  EnemyVisible = Color3.fromRGB(70, 255, 100),
  EnemyHidden = Color3.fromRGB(255, 60, 60),
  TeamVisible = Color3.fromRGB(255, 235, 50),
  TeamHidden = Color3.fromRGB(255, 145, 30)
}

local Settings = {
  ESP = true,
  ShowDistance = true,
  VisibilityCheck = true,
  TeamCheck = true,
  Highlight = true,
  Boxes = true,

  ESPDistance = DEFAULT_DISTANCE,
  HighlightDistance = DEFAULT_DISTANCE,
  BoxDistance = DEFAULT_DISTANCE,

  NameSize = DEFAULT_NAME_SIZE,
  DistanceSize = DEFAULT_DISTANCE_SIZE
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
  "Right Leg"
}

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
    Desc = "Player ESP"
  }),

  Misc = Sections.Features:Tab({
    Title = "Misc",
    Icon = "sliders-horizontal",
    Desc = "ESP appearance"
  }),

  Settings = Sections.Settings:Tab({
    Title = "Settings",
    Icon = "settings",
    Desc = "Interface settings"
  })
}

Tabs.ESP:Paragraph({
  Title = "Player ESP",
  Desc = "Display players through the world.",
  Image = "eye",
  ImageSize = 20
})

local ESPSection = Tabs.ESP:Section({
  Title = "ESP Features",
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
  Desc = "Highlight each visible body part separately",
  Value = Settings.Highlight,
  Callback = function(value)
    Settings.Highlight = value
  end
})

ESPSection:Toggle({
  Title = "2D Boxes",
  Desc = "Show a rectangle around players",
  Value = Settings.Boxes,
  Callback = function(value)
    Settings.Boxes = value
  end
})

ESPSection:Toggle({
  Title = "Distance",
  Desc = "Show distance below player name",
  Value = Settings.ShowDistance,
  Callback = function(value)
    Settings.ShowDistance = value
  end
})

ESPSection:Toggle({
  Title = "Visibility Check",
  Desc = "Check every body part from your character",
  Value = Settings.VisibilityCheck,
  Callback = function(value)
    Settings.VisibilityCheck = value
  end
})

ESPSection:Toggle({
  Title = "Team Check",
  Desc = "Use separate colors for teammates",
  Value = Settings.TeamCheck,
  Callback = function(value)
    Settings.TeamCheck = value
  end
})

Tabs.ESP:Paragraph({
  Title = "Visibility",
  Desc = "Visibility is calculated from your character to each body part. Highlight can show visible and hidden parts separately; 2D boxes do not use individual body-part visibility.",
  Image = "info",
  ImageSize = 18
})

local DistanceSection = Tabs.ESP:Section({
  Title = "Distances",
  Icon = "maximize",
  Opened = true,
  Box = true
})

DistanceSection:Slider({
  Title = "ESP Distance",
  Desc = "Maximum distance for names",
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

Tabs.Misc:Paragraph({
  Title = "ESP Appearance",
  Desc = "Configure player information.",
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
  Desc = "Player name size",
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
  Desc = "Distance text size",
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

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

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
  Stroke.Color = Colors.EnemyVisible
  Stroke.Parent = Box

  return Box
end

local function FindCharacter(player)
  local Character = player.Character

  if Character and Character.Parent then
    return Character
  end

  return nil
end

local function FindBodyParts(character)
  local Parts = {}

  for _, name in ipairs(BodyPartNames) do
    local Part = character:FindFirstChild(name)

    if Part and Part:IsA("BasePart") then
      table.insert(Parts, Part)
    end
  end

  if #Parts == 0 then
    for _, object in ipairs(character:GetChildren()) do
      if object:IsA("BasePart") then
        table.insert(Parts, object)
      end
    end
  end

  return Parts
end

local function IsPartVisible(part, character)
  if not Settings.VisibilityCheck then
    return true
  end

  local MyCharacter = LocalPlayer.Character
  local MyRoot = MyCharacter and
    MyCharacter:FindFirstChild("HumanoidRootPart")

  if not MyRoot or not part or not part.Parent then
    return false
  end

  local Origin = MyRoot.Position
  local Direction = part.Position - Origin

  if Direction.Magnitude <= 0.01 then
    return true
  end

  local Params = RaycastParams.new()
  Params.FilterType = Enum.RaycastFilterType.Exclude
  Params.FilterDescendantsInstances = {
    MyCharacter,
    character
  }

  return workspace:Raycast(
    Origin,
    Direction,
    Params
  ) == nil
end

local function GetPlayerColor(player, visible)
  if Settings.TeamCheck and
    LocalPlayer.Team ~= nil and
    player.Team ~= nil and
    LocalPlayer.Team == player.Team then

    return visible
      and Colors.TeamVisible
      or Colors.TeamHidden
  end

  return visible
    and Colors.EnemyVisible
    or Colors.EnemyHidden
end

local function CreatePartHighlight(part)
  local Highlight = Instance.new("Highlight")
  Highlight.Name = "ESPPart"
  Highlight.Adornee = part
  Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  Highlight.FillTransparency = 0.45
  Highlight.OutlineTransparency = 0
  Highlight.Enabled = false

  return Highlight
end

local function AttachCharacter(player, character)
  local Data = ESPObjects[player]

  if not Data then
    return
  end

  for _, Highlight in pairs(Data.Highlights) do
    Highlight:Destroy()
  end

  Data.Highlights = {}
  Data.Character = character

  local Humanoid = character:FindFirstChildOfClass("Humanoid")

  if not Humanoid then
    Humanoid = character:WaitForChild("Humanoid", 5)
  end

  if not Humanoid then
    return
  end

  for _, Part in ipairs(FindBodyParts(character)) do
    local Highlight = CreatePartHighlight(Part)
    Highlight.Parent = character
    Data.Highlights[Part] = Highlight
  end
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

  local Data = {
    Billboard = Billboard,
    Name = Name,
    Distance = Distance,
    Highlights = {},
    Box = CreateBox(),
    Character = nil,
    Connection = nil
  }

  ESPObjects[player] = Data

  local function CharacterAdded(character)
    task.spawn(function()
      character:WaitForChild("Humanoid", 5)
      character:WaitForChild("HumanoidRootPart", 5)

      if ESPObjects[player] then
        AttachCharacter(player, character)
      end
    end)
  end

  if player.Character then
    CharacterAdded(player.Character)
  end

  Data.Connection = player.CharacterAdded:Connect(CharacterAdded)
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

local function UpdateHighlights(player, Data, character, distance)
  local Enabled =
    Settings.ESP and
    Settings.Highlight and
    distance <= Settings.HighlightDistance

  if not Enabled then
    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    return
  end

  for Part, Highlight in pairs(Data.Highlights) do
    if Part and Part.Parent then
      local Visible = IsPartVisible(Part, character)
      local Color = GetPlayerColor(player, Visible)

      Highlight.Enabled = true
      Highlight.FillColor = Color
      Highlight.OutlineColor = Color
    else
      Highlight.Enabled = false
    end
  end
end

local function UpdateBox(player, Data, character, distance)
  local Box = Data.Box

  if not Settings.ESP or
    not Settings.Boxes or
    distance > Settings.BoxDistance then

    Box.Visible = false
    return
  end

  local Camera = workspace.CurrentCamera

  if not Camera then
    Box.Visible = false
    return
  end

  local Parts = FindBodyParts(character)

  if #Parts == 0 then
    Box.Visible = false
    return
  end

  local MinX = math.huge
  local MinY = math.huge
  local MaxX = -math.huge
  local MaxY = -math.huge
  local Found = false

  for _, Part in ipairs(Parts) do
    local Half = Part.Size / 2

    local Corners = {
      Vector3.new(-Half.X, -Half.Y, -Half.Z),
      Vector3.new(-Half.X, -Half.Y, Half.Z),
      Vector3.new(-Half.X, Half.Y, -Half.Z),
      Vector3.new(-Half.X, Half.Y, Half.Z),
      Vector3.new(Half.X, -Half.Y, -Half.Z),
      Vector3.new(Half.X, -Half.Y, Half.Z),
      Vector3.new(Half.X, Half.Y, -Half.Z),
      Vector3.new(Half.X, Half.Y, Half.Z)
    }

    for _, Corner in ipairs(Corners) do
      local WorldPosition = Part.CFrame:PointToWorldSpace(Corner)
      local ScreenPosition, OnScreen =
        Camera:WorldToViewportPoint(WorldPosition)

      if ScreenPosition.Z > 0 then
        MinX = math.min(MinX, ScreenPosition.X)
        MinY = math.min(MinY, ScreenPosition.Y)
        MaxX = math.max(MaxX, ScreenPosition.X)
        MaxY = math.max(MaxY, ScreenPosition.Y)
        Found = Found or OnScreen
      end
    end
  end

  if not Found or MinX == math.huge then
    Box.Visible = false
    return
  end

  local Color = GetPlayerColor(
    player,
    IsPartVisible(
      character:FindFirstChild("HumanoidRootPart") or Parts[1],
      character
    )
  )

  local Stroke = Box:FindFirstChildOfClass("UIStroke")

  if Stroke then
    Stroke.Color = Color
  end

  Box.Position = UDim2.fromOffset(MinX, MinY)
  Box.Size = UDim2.fromOffset(
    math.max(MaxX - MinX, 2),
    math.max(MaxY - MinY, 2)
  )

  Box.Visible = true
end

local function UpdateESP(player, Data)
  local Character = FindCharacter(player)

  if not Character then
    Data.Billboard.Enabled = false
    Data.Box.Visible = false

    for _, Highlight in pairs(Data.Highlights) do
      Highlight.Enabled = false
    end

    return
  end

  if Data.Character ~= Character then
    AttachCharacter(player, Character)
  end

  local Humanoid = Character:FindFirstChildOfClass("Humanoid")
  local Root = Character:FindFirstChild("HumanoidRootPart")

  if not Humanoid or not Root or Humanoid.Health <= 0 then
    Data.Billboard.Enabled = false
    Data.Box.Visible = false
    return
  end

  local MyCharacter = LocalPlayer.Character
  local MyRoot = MyCharacter and
    MyCharacter:FindFirstChild("HumanoidRootPart")

  if not MyRoot then
    return
  end

  local Distance = (
    MyRoot.Position - Root.Position
  ).Magnitude

  if Settings.ESP and Distance <= Settings.ESPDistance then
    Data.Billboard.Enabled = true
    Data.Name.TextSize = Settings.NameSize
    Data.Distance.TextSize = Settings.DistanceSize

    if Settings.ShowDistance then
      Data.Distance.Visible = true
      Data.Distance.Text =
        math.floor(Distance) .. " studs"
    else
      Data.Distance.Visible = false
    end
  else
    Data.Billboard.Enabled = false
  end

  UpdateHighlights(
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

LocalPlayer.CharacterAdded:Connect(function()
  task.wait(0.2)

  for player, Data in pairs(ESPObjects) do
    if player.Parent == Players then
      UpdateESP(player, Data)
    end
  end
end)

local Timer = 0

RunService.RenderStepped:Connect(function(delta)
  Timer += delta

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