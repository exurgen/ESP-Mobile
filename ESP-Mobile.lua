local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- windui
local WindUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
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

local Colors = {
  EnemyVisible = Color3.fromRGB(70, 255, 100),
  EnemyHidden = Color3.fromRGB(255, 60, 60),
  TeamVisible = Color3.fromRGB(255, 235, 50),
  TeamHidden = Color3.fromRGB(255, 145, 30)
}

-- settings
local Settings = {
  ESP = true,
  ShowDistance = true,
  VisibilityCheck = true,
  TeamCheck = true,

  ESPDistance = DEFAULT_DISTANCE,
  NameSize = DEFAULT_NAME_SIZE,
  DistanceSize = DEFAULT_DISTANCE_SIZE
}

local ESPObjects = {}

-- window
local Window = WindUI:CreateWindow({
  Title = "PLAYER ESP",
  Icon = "eye",
  Author = "Mobile ESP",
  Theme = "Dark",
  Transparent = false
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

-- tabs
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

-- esp
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
  Desc = "Show players through the world",
  Value = Settings.ESP,
  Callback = function(value)
    Settings.ESP = value
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
  Desc = "Change color depending on walls",
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
  Title = "Distance",
  Icon = "maximize",
  Opened = true,
  Box = true
})

DistanceSection:Slider({
  Title = "ESP Distance",
  Desc = "Maximum distance for ESP",
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

-- misc
Tabs.Misc:Paragraph({
  Title = "ESP Appearance",
  Desc = "Customize the appearance of player information.",
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

-- settings
Tabs.Settings:Paragraph({
  Title = "Interface",
  Desc = "Customize the appearance of the ESP menu.",
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

local UpdatingTheme = false

local ThemeDropdown = SettingsTab:Dropdown({
  Title = "Theme",
  Desc = "Choose the interface theme",
  Values = Themes,
  Value = WindUI:GetCurrentTheme(),
  Multi = false,
  AllowNone = false,

  Callback = function(Theme)
    if UpdatingTheme or not Theme then
      return
    end

    UpdatingTheme = true

    WindUI:SetTheme(Theme)

    task.defer(function()
      UpdatingTheme = false
    end)
  end
})

WindUI:OnThemeChange(function(Theme)
  if UpdatingTheme then
    return
  end

  UpdatingTheme = true

  ThemeDropdown:Select(Theme)

  task.defer(function()
    UpdatingTheme = false
  end)
end)

AppearanceSection:Divider()

AppearanceSection:Button({
  Title = "Reset Theme",
  Desc = "Return to the default dark theme",
  Icon = "rotate-ccw",

  Callback = function()
    WindUI:SetTheme("Dark")

    WindUI:Notify({
      Title = "Theme Reset",
      Content = "Dark theme applied",
      Icon = "check",
      Duration = 2
    })
  end
})

-- visibility
local function IsVisible(character)
  if not Settings.VisibilityCheck then
    return true
  end

  local Camera = workspace.CurrentCamera
  local Root = character:FindFirstChild("HumanoidRootPart")

  if not Camera or not Root then
    return false
  end

  local Origin = Camera.CFrame.Position
  local Direction = Root.Position - Origin

  local Params = RaycastParams.new()
  Params.FilterType = Enum.RaycastFilterType.Exclude

  local Ignore = {}

  if LocalPlayer.Character then
    table.insert(Ignore, LocalPlayer.Character)
  end

  table.insert(Ignore, character)

  Params.FilterDescendantsInstances = Ignore

  return workspace:Raycast(
    Origin,
    Direction,
    Params
  ) == nil
end

-- team
local function IsTeamMate(player)
  if not Settings.TeamCheck then
    return false
  end

  return LocalPlayer.Team ~= nil
    and player.Team ~= nil
    and LocalPlayer.Team == player.Team
end

-- color
local function GetPlayerColor(player, character)
  local teammate = IsTeamMate(player)
  local visible = IsVisible(character)

  if teammate then
    return visible
      and Colors.TeamVisible
      or Colors.TeamHidden
  end

  return visible
    and Colors.EnemyVisible
    or Colors.EnemyHidden
end

-- create esp
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
  Name.TextColor3 = Colors.EnemyVisible
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

  ESPObjects[player] = {
    Billboard = Billboard,
    Name = Name,
    Distance = Distance,
    Connection = nil
  }

  local function Attach(character)
    local Root = character:WaitForChild(
      "HumanoidRootPart",
      5
    )

    if Root and ESPObjects[player] then
      ESPObjects[player].Billboard.Adornee = Root
    end
  end

  if player.Character then
    task.spawn(Attach, player.Character)
  end

  ESPObjects[player].Connection =
    player.CharacterAdded:Connect(function(character)
      task.wait(0.15)

      if ESPObjects[player] then
        Attach(character)
      end
    end)
end

-- remove esp
local function RemoveESP(player)
  local Data = ESPObjects[player]

  if not Data then
    return
  end

  if Data.Connection then
    Data.Connection:Disconnect()
  end

  if Data.Billboard then
    Data.Billboard:Destroy()
  end

  ESPObjects[player] = nil
end

-- update esp
local function UpdateESP(player, Data)
  if not Settings.ESP then
    Data.Billboard.Enabled = false
    return
  end

  local Character = player.Character

  if not Character then
    Data.Billboard.Enabled = false
    return
  end

  local Humanoid = Character:FindFirstChildOfClass("Humanoid")
  local Root = Character:FindFirstChild("HumanoidRootPart")

  if not Humanoid or not Root or Humanoid.Health <= 0 then
    Data.Billboard.Enabled = false
    return
  end

  local MyCharacter = LocalPlayer.Character
  local MyRoot = MyCharacter
    and MyCharacter:FindFirstChild("HumanoidRootPart")

  if not MyRoot then
    Data.Billboard.Enabled = false
    return
  end

  local Distance = (
    MyRoot.Position - Root.Position
  ).Magnitude

  if Distance > Settings.ESPDistance then
    Data.Billboard.Enabled = false
    return
  end

  Data.Billboard.Enabled = true

  Data.Name.TextSize = Settings.NameSize
  Data.Distance.TextSize = Settings.DistanceSize

  Data.Name.TextColor3 = GetPlayerColor(
    player,
    Character
  )

  if Settings.ShowDistance then
    Data.Distance.Visible = true
    Data.Distance.Text =
      math.floor(Distance) .. " studs"
  else
    Data.Distance.Visible = false
  end
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