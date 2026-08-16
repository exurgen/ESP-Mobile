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

local MIN_HIGHLIGHT_DISTANCE = 50
local MAX_HIGHLIGHT_DISTANCE = 2000
local DEFAULT_HIGHLIGHT_DISTANCE = 1000

local MIN_BOX_DISTANCE = 50
local MAX_BOX_DISTANCE = 2000
local DEFAULT_BOX_DISTANCE = 1000

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
  TeamHidden = Color3.fromRGB(255, 145, 30),
  Box = Color3.fromRGB(255, 255, 255)
}

local Settings = {
  ESP = true,
  Highlight = true,
  Box = true,
  ShowDistance = true,
  VisibilityCheck = true,
  TeamCheck = true,

  ESPDistance = DEFAULT_DISTANCE,
  HighlightDistance = DEFAULT_HIGHLIGHT_DISTANCE,
  BoxDistance = DEFAULT_BOX_DISTANCE,

  NameSize = DEFAULT_NAME_SIZE,
  DistanceSize = DEFAULT_DISTANCE_SIZE
}

local ESPObjects = {}
local RegisteredPlayers = {}

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
    Desc = "Player ESP features"
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
  Desc = "Configure how players are displayed.",
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
  Desc = "Highlight the whole character",
  Value = Settings.Highlight,
  Callback = function(value)
    Settings.Highlight = value
  end
})

ESPSection:Toggle({
  Title = "2D Box",
  Desc = "Draw a rectangle around players",
  Value = Settings.Box,
  Callback = function(value)
    Settings.Box = value
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
  Title = "Visibility Check",
  Desc = "Works with Highlight only, not 2D Boxes",
  Value = Settings.VisibilityCheck,
  Callback = function(value)
    Settings.VisibilityCheck = value
  end
})

ESPSection:Toggle({
  Title = "Team Check",
  Desc = "Use different colors for teammates",
  Value = Settings.TeamCheck,
  Callback = function(value)
    Settings.TeamCheck = value
  end
})

Tabs.ESP:Divider()

local DistanceSection = Tabs.ESP:Section({
  Title = "ESP Distance",
  Icon = "maximize",
  Opened = true,
  Box = true
})

DistanceSection:Slider({
  Title = "Highlight Distance",
  Desc = "Maximum distance for Highlight",
  Value = {
    Min = MIN_HIGHLIGHT_DISTANCE,
    Max = MAX_HIGHLIGHT_DISTANCE,
    Default = DEFAULT_HIGHLIGHT_DISTANCE
  },
  Step = 1,
  Callback = function(value)
    Settings.HighlightDistance = value
  end
})

DistanceSection:Slider({
  Title = "Box Distance",
  Desc = "Maximum distance for 2D Boxes",
  Value = {
    Min = MIN_BOX_DISTANCE,
    Max = MAX_BOX_DISTANCE,
    Default = DEFAULT_BOX_DISTANCE
  },
  Step = 1,
  Callback = function(value)
    Settings.BoxDistance = value
  end
})

Tabs.Misc:Paragraph({
  Title = "ESP Appearance",
  Desc = "Customize player information.",
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

Tabs.Settings:Paragraph({
  Title = "Interface",
  Desc = "Customize the appearance of the menu.",
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
  Desc = "Choose the interface theme",
  Values = Themes,
  Flag = "ThemeDropdown",
  SearchBarEnabled = true,
  MenuWidth = 280,
  Value = "Dark",

  Callback = function(theme)
    if theme then
      WindUI:SetTheme(theme)
    end
  end
})

AppearanceSection:Button({
  Title = "Reset Theme",
  Desc = "Return to the default dark theme",
  Icon = "rotate-ccw",

  Callback = function()
    WindUI:SetTheme("Dark")

    if ThemeDropdown then
      ThemeDropdown:Select("Dark")
    end
  end
})

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESPOverlay"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 999999
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.Parent = PlayerGui

local function GetCharacter(player)
  if player.Character and player.Character.Parent then
    return player.Character
  end

  for _, character in ipairs(workspace:GetChildren()) do
    if character:IsA("Model") and character.Name == player.Name then
      return character
    end
  end

  return nil
end

local function GetRoot(character)
  return character and character:FindFirstChild("HumanoidRootPart")
end

local function IsTeamMate(player)
  if not Settings.TeamCheck then
    return false
  end

  return LocalPlayer.Team ~= nil
    and player.Team ~= nil
    and LocalPlayer.Team == player.Team
end

local function GetBodyParts(character)
  local Parts = {}

  local Names = {
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

  for _, Name in ipairs(Names) do
    local Part = character:FindFirstChild(Name)

    if Part and Part:IsA("BasePart") then
      table.insert(Parts, Part)
    end
  end

  return Parts
end

local function IsPartVisible(character, part)
  local MyCharacter = LocalPlayer.Character
  local MyRoot = GetRoot(MyCharacter)

  if not MyRoot or not part then
    return false
  end

  local Origin = MyRoot.Position
  local Direction = part.Position - Origin

  local Parameters = RaycastParams.new()
  Parameters.FilterType = Enum.RaycastFilterType.Exclude
  Parameters.FilterDescendantsInstances = {
    MyCharacter,
    character
  }

  local Result = workspace:Raycast(
    Origin,
    Direction,
    Parameters
  )

  return Result == nil
end

local function IsCharacterVisible(character)
  if not Settings.VisibilityCheck then
    return true
  end

  local Parts = GetBodyParts(character)

  for _, Part in ipairs(Parts) do
    if IsPartVisible(character, Part) then
      return true
    end
  end

  return false
end

local function GetPlayerColor(player, character)
  local TeamMate = IsTeamMate(player)

  if Settings.VisibilityCheck then
    local Visible = IsCharacterVisible(character)

    if TeamMate then
      return Visible
        and Colors.TeamVisible
        or Colors.TeamHidden
    end

    return Visible
      and Colors.EnemyVisible
      or Colors.EnemyHidden
  end

  if TeamMate then
    return Colors.TeamVisible
  end

  return Colors.EnemyVisible
end

local function CreateBox()
  local Box = Instance.new("Frame")
  Box.Name = "Box"
  Box.BackgroundTransparency = 1
  Box.BorderSizePixel = 0
  Box.Visible = false
  Box.ZIndex = 10

  local Stroke = Instance.new("UIStroke")
  Stroke.Color = Colors.Box
  Stroke.Thickness = 1.5
  Stroke.Parent = Box

  Box.Parent = ESPGui

  return Box
end

local function GetScreenBounds(character)
  local Camera = workspace.CurrentCamera

  if not Camera then
    return nil
  end

  local Points = {}

  for _, Part in ipairs(GetBodyParts(character)) do
    local Size = Part.Size
    local CFrame = Part.CFrame

    local Corners = {
      Vector3.new(-Size.X / 2, -Size.Y / 2, -Size.Z / 2),
      Vector3.new(-Size.X / 2, -Size.Y / 2, Size.Z / 2),
      Vector3.new(-Size.X / 2, Size.Y / 2, -Size.Z / 2),
      Vector3.new(-Size.X / 2, Size.Y / 2, Size.Z / 2),
      Vector3.new(Size.X / 2, -Size.Y / 2, -Size.Z / 2),
      Vector3.new(Size.X / 2, -Size.Y / 2, Size.Z / 2),
      Vector3.new(Size.X / 2, Size.Y / 2, -Size.Z / 2),
      Vector3.new(Size.X / 2, Size.Y / 2, Size.Z / 2)
    }

    for _, Corner in ipairs(Corners) do
      local ScreenPosition, Visible =
        Camera:WorldToViewportPoint(CFrame:PointToWorldSpace(Corner))

      if Visible and ScreenPosition.Z > 0 then
        table.insert(Points, Vector2.new(
          ScreenPosition.X,
          ScreenPosition.Y
        ))
      end
    end
  end

  if #Points == 0 then
    return nil
  end

  local MinimumX = math.huge
  local MaximumX = -math.huge
  local MinimumY = math.huge
  local MaximumY = -math.huge

  for _, Point in ipairs(Points) do
    MinimumX = math.min(MinimumX, Point.X)
    MaximumX = math.max(MaximumX, Point.X)
    MinimumY = math.min(MinimumY, Point.Y)
    MaximumY = math.max(MaximumY, Point.Y)
  end

  return MinimumX, MinimumY, MaximumX, MaximumY
end

local function CreateESP(player)
  if player == LocalPlayer or ESPObjects[player] then
    return
  end

  RegisteredPlayers[player] = true

  local Billboard = Instance.new("BillboardGui")
  Billboard.Name = "PlayerESP"
  Billboard.Size = UDim2.fromOffset(220, 60)
  Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
  Billboard.AlwaysOnTop = true
  Billboard.MaxDistance = MAX_DISTANCE
  Billboard.Enabled = false
  Billboard.Parent = PlayerGui

  local Name = Instance.new("TextLabel")
  Name.Size = UDim2.new(1, 0, 0, 30)
  Name.BackgroundTransparency = 1
  Name.Text = player.DisplayName
  Name.TextSize = Settings.NameSize
  Name.Font = Enum.Font.GothamBold
  Name.TextStrokeTransparency = 0.35
  Name.TextColor3 = Colors.EnemyVisible
  Name.Parent = Billboard

  local Distance = Instance.new("TextLabel")
  Distance.Size = UDim2.new(1, 0, 0, 20)
  Distance.Position = UDim2.fromOffset(0, 30)
  Distance.BackgroundTransparency = 1
  Distance.TextSize = Settings.DistanceSize
  Distance.Font = Enum.Font.GothamMedium
  Distance.TextColor3 = Color3.fromRGB(220, 220, 220)
  Distance.TextStrokeTransparency = 0.5
  Distance.Parent = Billboard

  local Highlight = Instance.new("Highlight")
  Highlight.Name = "ESPHighlight"
  Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  Highlight.FillTransparency = 0.55
  Highlight.OutlineTransparency = 0
  Highlight.Enabled = false
  Highlight.Parent = ESPGui

  local Box = CreateBox()

  ESPObjects[player] = {
    Billboard = Billboard,
    Name = Name,
    Distance = Distance,
    Highlight = Highlight,
    Box = Box,
    Connection = nil
  }

  local function Attach(character)
    local Data = ESPObjects[player]

    if not Data or not character then
      return
    end

    local Root = character:WaitForChild(
      "HumanoidRootPart",
      5
    )

    if Root and ESPObjects[player] then
      Data.Billboard.Adornee = Root
      Data.Highlight.Adornee = character
    end
  end

  if player.Character then
    task.spawn(Attach, player.Character)
  end

  ESPObjects[player].Connection =
    player.CharacterAdded:Connect(function(character)
      task.wait(0.1)

      if ESPObjects[player] then
        Attach(character)
      end
    end)
end

local function RemoveESP(player)
  local Data = ESPObjects[player]

  RegisteredPlayers[player] = nil

  if not Data then
    return
  end

  if Data.Connection then
    Data.Connection:Disconnect()
  end

  if Data.Billboard then
    Data.Billboard:Destroy()
  end

  if Data.Highlight then
    Data.Highlight:Destroy()
  end

  if Data.Box then
    Data.Box:Destroy()
  end

  ESPObjects[player] = nil
end

local function UpdateESP(player, Data)
  if not Settings.ESP then
    Data.Billboard.Enabled = false
    Data.Highlight.Enabled = false
    Data.Box.Visible = false
    return
  end

  local Character = GetCharacter(player)

  if not Character then
    Data.Billboard.Enabled = false
    Data.Highlight.Enabled = false
    Data.Box.Visible = false
    return
  end

  local Humanoid = Character:FindFirstChildOfClass("Humanoid")
  local Root = GetRoot(Character)
  local MyRoot = GetRoot(LocalPlayer.Character)

  if not Humanoid or not Root or not MyRoot or Humanoid.Health <= 0 then
    Data.Billboard.Enabled = false
    Data.Highlight.Enabled = false
    Data.Box.Visible = false
    return
  end

  local Distance = (
    MyRoot.Position - Root.Position
  ).Magnitude

  local PlayerColor = GetPlayerColor(
    player,
    Character
  )

  if Settings.Highlight
    and Distance <= Settings.HighlightDistance then

    Data.Highlight.Enabled = true
    Data.Highlight.FillColor = PlayerColor
    Data.Highlight.OutlineColor = PlayerColor
  else
    Data.Highlight.Enabled = false
  end

  if Settings.Box
    and Distance <= Settings.BoxDistance then

    local MinimumX, MinimumY, MaximumX, MaximumY =
      GetScreenBounds(Character)

    if MinimumX then
      Data.Box.Visible = true
      Data.Box.Position = UDim2.fromOffset(
        MinimumX,
        MinimumY
      )
      Data.Box.Size = UDim2.fromOffset(
        MaximumX - MinimumX,
        MaximumY - MinimumY
      )

      local Stroke = Data.Box:FindFirstChildOfClass("UIStroke")

      if Stroke then
        Stroke.Color = IsTeamMate(player)
          and Colors.TeamVisible
          or Colors.Box
      end
    else
      Data.Box.Visible = false
    end
  else
    Data.Box.Visible = false
  end

  Data.Name.TextSize = Settings.NameSize
  Data.Distance.TextSize = Settings.DistanceSize

  if Settings.ShowDistance then
    Data.Billboard.Enabled = true
    Data.Distance.Visible = true
    Data.Distance.Text = math.floor(Distance) .. " studs"
  else
    Data.Billboard.Enabled = true
    Data.Distance.Visible = false
  end

  Data.Name.TextColor3 = PlayerColor
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

Players.PlayerRemoving:Connect(RemoveESP)

Window:Open()

local Timer = 0

RunService.RenderStepped:Connect(function(delta)
  Timer += delta

  if Timer < 0.05 then
    return
  end

  Timer = 0

  for player in pairs(RegisteredPlayers) do
    if player.Parent == Players then
      if not ESPObjects[player] then
        CreateESP(player)
      else
        UpdateESP(player, ESPObjects[player])
      end
    else
      RemoveESP(player)
    end
  end
end)