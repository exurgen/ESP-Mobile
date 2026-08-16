local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--limits
local MIN_DISTANCE = 50
local MAX_DISTANCE = 2000
local DEFAULT_DISTANCE = 1000

local MIN_NAME_SIZE = 8
local MAX_NAME_SIZE = 24
local DEFAULT_NAME_SIZE = 14

local MIN_DISTANCE_SIZE = 6
local MAX_DISTANCE_SIZE = 18
local DEFAULT_DISTANCE_SIZE = 10

local MIN_ICON_SIZE = 20
local MAX_ICON_SIZE = 80
local DEFAULT_ICON_SIZE = 52

local MIN_MENU_WIDTH = 140
local MAX_MENU_WIDTH = 480
local DEFAULT_MENU_WIDTH = 260

local MIN_MENU_HEIGHT = 140
local MAX_MENU_HEIGHT = 480
local DEFAULT_MENU_HEIGHT = 280

local HANDLE_SIZE = 18

local Colors = {
  EnemyVisible = Color3.fromRGB(70, 255, 100),
  EnemyHidden = Color3.fromRGB(255, 60, 60),
  TeamVisible = Color3.fromRGB(255, 235, 50),
  TeamHidden = Color3.fromRGB(255, 145, 30)
}

--settings
local Settings = {
  ESP = true,
  ShowDistance = true,
  VisibilityCheck = true,
  TeamCheck = true,

  ESPDistance = DEFAULT_DISTANCE,
  NameSize = DEFAULT_NAME_SIZE,
  DistanceSize = DEFAULT_DISTANCE_SIZE,
  IconSize = DEFAULT_ICON_SIZE,

  MenuWidth = DEFAULT_MENU_WIDTH,
  MenuHeight = DEFAULT_MENU_HEIGHT
}

--gui
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 10000
ScreenGui.Parent = PlayerGui

local MenuWidth = Settings.MenuWidth
local MenuHeight = Settings.MenuHeight

local Container = Instance.new("Frame")
Container.Name = "MainElement"
Container.Size = UDim2.fromOffset(Settings.IconSize, Settings.IconSize)
Container.Position = UDim2.new(
  0.5,
  -Settings.IconSize / 2,
  0.5,
  -Settings.IconSize / 2
)
Container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Container.BorderSizePixel = 0
Container.ClipsDescendants = false
Container.Active = true
Container.ZIndex = 100
Container.Parent = ScreenGui

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(255, 255, 255)
ContainerStroke.Thickness = 2
ContainerStroke.Parent = Container

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 15)
ContainerCorner.Parent = Container

local IconDragZone = Instance.new("TextButton")
IconDragZone.Name = "IconDragZone"
IconDragZone.Size = UDim2.fromOffset(70, 70)
IconDragZone.Position = UDim2.fromScale(0.5, 0.5)
IconDragZone.AnchorPoint = Vector2.new(0.5, 0.5)
IconDragZone.BackgroundTransparency = 1
IconDragZone.BorderSizePixel = 0
IconDragZone.Text = ""
IconDragZone.AutoButtonColor = false
IconDragZone.Active = true
IconDragZone.ZIndex = 105
IconDragZone.Parent = Container

local IconButton = Instance.new("TextButton")
IconButton.Name = "Icon"
IconButton.Size = UDim2.fromScale(1, 1)
IconButton.BackgroundTransparency = 1
IconButton.BorderSizePixel = 0
IconButton.Text = "ESP"
IconButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IconButton.TextSize = 12
IconButton.Font = Enum.Font.GothamBold
IconButton.AutoButtonColor = false
IconButton.Active = true
IconButton.ZIndex = 110
IconButton.Parent = Container

local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromScale(1, 1)
Menu.BackgroundTransparency = 1
Menu.Visible = false
Menu.Active = true
Menu.ZIndex = 102
Menu.Parent = Container

--header
local TopBar = Instance.new("Frame")
TopBar.Name = "DragArea"
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundTransparency = 1
TopBar.Active = true
TopBar.ZIndex = 103
TopBar.Parent = Menu

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 25)
Title.Position = UDim2.fromOffset(16, 7)
Title.BackgroundTransparency = 1
Title.Text = "PLAYER ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 104
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -60, 0, 17)
Subtitle.Position = UDim2.fromOffset(17, 33)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Mobile ESP"
Subtitle.TextColor3 = Color3.fromRGB(145, 145, 145)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 104
Subtitle.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(36, 36)
CloseButton.Position = UDim2.new(1, -45, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 21
CloseButton.Font = Enum.Font.GothamMedium
CloseButton.AutoButtonColor = false
CloseButton.Active = true
CloseButton.ZIndex = 120
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(255, 255, 255)
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseButton

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -28, 0, 1)
Separator.Position = UDim2.fromOffset(14, 60)
Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Separator.BackgroundTransparency = 0.75
Separator.BorderSizePixel = 0
Separator.ZIndex = 104
Separator.Parent = Menu

--scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Settings"
Scroll.Position = UDim2.fromOffset(11, 70)
Scroll.Size = UDim2.new(1, -22, 1, -81)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
Scroll.ScrollBarImageTransparency = 0.5
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Active = true
Scroll.ZIndex = 104
Scroll.Parent = Menu

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
  Scroll.CanvasSize = UDim2.fromOffset(
    0,
    Layout.AbsoluteContentSize.Y + 15
  )
end)

--toggles
local function CreateToggle(title, description, setting)
  local Button = Instance.new("TextButton")
  Button.Size = UDim2.new(1, -3, 0, 57)
  Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  Button.BorderSizePixel = 0
  Button.Text = ""
  Button.AutoButtonColor = false
  Button.Active = true
  Button.ZIndex = 105
  Button.Parent = Scroll

  local Corner = Instance.new("UICorner")
  Corner.CornerRadius = UDim.new(0, 11)
  Corner.Parent = Button

  local Stroke = Instance.new("UIStroke")
  Stroke.Color = Color3.fromRGB(255, 255, 255)
  Stroke.Thickness = 1
  Stroke.Transparency = 0.72
  Stroke.ZIndex = 106
  Stroke.Parent = Button

  local Label = Instance.new("TextLabel")
  Label.Size = UDim2.new(1, -78, 0, 21)
  Label.Position = UDim2.fromOffset(13, 6)
  Label.BackgroundTransparency = 1
  Label.Text = title
  Label.TextColor3 = Color3.fromRGB(255, 255, 255)
  Label.TextSize = 13
  Label.Font = Enum.Font.GothamMedium
  Label.TextXAlignment = Enum.TextXAlignment.Left
  Label.ZIndex = 106
  Label.Parent = Button

  local Desc = Instance.new("TextLabel")
  Desc.Size = UDim2.new(1, -78, 0, 16)
  Desc.Position = UDim2.fromOffset(13, 30)
  Desc.BackgroundTransparency = 1
  Desc.Text = description
  Desc.TextColor3 = Color3.fromRGB(140, 140, 140)
  Desc.TextSize = 9
  Desc.Font = Enum.Font.Gotham
  Desc.TextXAlignment = Enum.TextXAlignment.Left
  Desc.ZIndex = 106
  Desc.Parent = Button

  local Switch = Instance.new("Frame")
  Switch.Size = UDim2.fromOffset(46, 24)
  Switch.Position = UDim2.new(1, -59, 0.5, -12)
  Switch.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  Switch.BorderSizePixel = 0
  Switch.ZIndex = 106
  Switch.Parent = Button

  local SwitchCorner = Instance.new("UICorner")
  SwitchCorner.CornerRadius = UDim.new(1, 0)
  SwitchCorner.Parent = Switch

  local SwitchStroke = Instance.new("UIStroke")
  SwitchStroke.Color = Color3.fromRGB(255, 255, 255)
  SwitchStroke.Thickness = 1
  SwitchStroke.Transparency = 0.45
  SwitchStroke.ZIndex = 107
  SwitchStroke.Parent = Switch

  local Dot = Instance.new("Frame")
  Dot.Size = UDim2.fromOffset(18, 18)
  Dot.Position = UDim2.fromOffset(3, 3)
  Dot.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
  Dot.BorderSizePixel = 0
  Dot.ZIndex = 107
  Dot.Parent = Switch

  local DotCorner = Instance.new("UICorner")
  DotCorner.CornerRadius = UDim.new(1, 0)
  DotCorner.Parent = Dot

  local function Update()
    local enabled = Settings[setting]

    TweenService:Create(Switch, TweenInfo.new(0.14), {
      BackgroundColor3 = enabled
        and Color3.fromRGB(255, 255, 255)
        or Color3.fromRGB(30, 30, 30)
    }):Play()

    TweenService:Create(Dot, TweenInfo.new(0.14), {
      Position = enabled
        and UDim2.fromOffset(25, 3)
        or UDim2.fromOffset(3, 3),
      BackgroundColor3 = enabled
        and Color3.fromRGB(0, 0, 0)
        or Color3.fromRGB(130, 130, 130)
    }):Play()
  end

  Button.Activated:Connect(function()
    Settings[setting] = not Settings[setting]
    Update()
  end)

  Update()
end

CreateToggle("ESP", "Show players through the world", "ESP")
CreateToggle("Distance", "Show distance to players", "ShowDistance")
CreateToggle("Visibility Check", "Green / red depending on walls", "VisibilityCheck")
CreateToggle("Team Check", "Yellow / orange for teammates", "TeamCheck")

--sliders
local function CreateSlider(title, minValue, maxValue, getValue, setValue, suffix)
  local Frame = Instance.new("Frame")
  Frame.Size = UDim2.new(1, -3, 0, 82)
  Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  Frame.BorderSizePixel = 0
  Frame.ZIndex = 105
  Frame.Parent = Scroll

  local Corner = Instance.new("UICorner")
  Corner.CornerRadius = UDim.new(0, 11)
  Corner.Parent = Frame

  local Stroke = Instance.new("UIStroke")
  Stroke.Color = Color3.fromRGB(255, 255, 255)
  Stroke.Thickness = 1
  Stroke.Transparency = 0.72
  Stroke.Parent = Frame

  local Label = Instance.new("TextLabel")
  Label.Size = UDim2.new(1, -105, 0, 20)
  Label.Position = UDim2.fromOffset(13, 7)
  Label.BackgroundTransparency = 1
  Label.Text = title
  Label.TextColor3 = Color3.fromRGB(255, 255, 255)
  Label.TextSize = 13
  Label.Font = Enum.Font.GothamMedium
  Label.TextXAlignment = Enum.TextXAlignment.Left
  Label.ZIndex = 106
  Label.Parent = Frame

  local ValueLabel = Instance.new("TextLabel")
  ValueLabel.Size = UDim2.fromOffset(85, 20)
  ValueLabel.Position = UDim2.new(1, -98, 0, 7)
  ValueLabel.BackgroundTransparency = 1
  ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
  ValueLabel.TextSize = 11
  ValueLabel.Font = Enum.Font.GothamBold
  ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
  ValueLabel.ZIndex = 106
  ValueLabel.Parent = Frame

  local Slider = Instance.new("TextButton")
  Slider.Size = UDim2.new(1, -28, 0, 18)
  Slider.Position = UDim2.fromOffset(14, 48)
  Slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  Slider.BorderSizePixel = 0
  Slider.Text = ""
  Slider.AutoButtonColor = false
  Slider.Active = true
  Slider.ZIndex = 106
  Slider.Parent = Frame

  local SliderCorner = Instance.new("UICorner")
  SliderCorner.CornerRadius = UDim.new(1, 0)
  SliderCorner.Parent = Slider

  local SliderStroke = Instance.new("UIStroke")
  SliderStroke.Color = Color3.fromRGB(255, 255, 255)
  SliderStroke.Thickness = 1
  SliderStroke.Transparency = 0.5
  SliderStroke.Parent = Slider

  local Fill = Instance.new("Frame")
  Fill.Size = UDim2.fromScale(0, 1)
  Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  Fill.BorderSizePixel = 0
  Fill.ZIndex = 107
  Fill.Parent = Slider

  local FillCorner = Instance.new("UICorner")
  FillCorner.CornerRadius = UDim.new(1, 0)
  FillCorner.Parent = Fill

  local Knob = Instance.new("Frame")
  Knob.Size = UDim2.fromOffset(24, 24)
  Knob.AnchorPoint = Vector2.new(0.5, 0.5)
  Knob.Position = UDim2.new(0, 0, 0.5, 0)
  Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  Knob.BorderSizePixel = 0
  Knob.ZIndex = 108
  Knob.Parent = Slider

  local KnobCorner = Instance.new("UICorner")
  KnobCorner.CornerRadius = UDim.new(1, 0)
  KnobCorner.Parent = Knob

  local TouchZone = Instance.new("TextButton")
  TouchZone.Size = UDim2.new(1, 0, 0, 42)
  TouchZone.Position = UDim2.new(0, 0, 0.5, -21)
  TouchZone.BackgroundTransparency = 1
  TouchZone.BorderSizePixel = 0
  TouchZone.Text = ""
  TouchZone.AutoButtonColor = false
  TouchZone.Active = true
  TouchZone.ZIndex = 109
  TouchZone.Parent = Slider

  local dragging = false

  local function Update(value)
    value = math.floor(math.clamp(value, minValue, maxValue))
    setValue(value)

    local alpha = (value - minValue) / (maxValue - minValue)

    Fill.Size = UDim2.new(alpha, 0, 1, 0)
    Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
    ValueLabel.Text = tostring(value) .. suffix
  end

  local function FromTouch(x)
    local left = Slider.AbsolutePosition.X
    local width = Slider.AbsoluteSize.X
    local alpha = math.clamp((x - left) / width, 0, 1)

    Update(minValue + (maxValue - minValue) * alpha)
  end

  TouchZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      FromTouch(input.Position.X)
    end
  end)

  UserInputService.TouchMoved:Connect(function(input)
    if dragging then
      FromTouch(input.Position.X)
    end
  end)

  UserInputService.TouchEnded:Connect(function()
    dragging = false
  end)

  Update(getValue())
end

CreateSlider("ESP Distance", MIN_DISTANCE, MAX_DISTANCE,
  function()
    return Settings.ESPDistance
  end,
  function(value)
    Settings.ESPDistance = value
  end,
  " studs"
)

CreateSlider("Name Size", MIN_NAME_SIZE, MAX_NAME_SIZE,
  function()
    return Settings.NameSize
  end,
  function(value)
    Settings.NameSize = value
  end,
  " px"
)

CreateSlider("Distance Text Size", MIN_DISTANCE_SIZE, MAX_DISTANCE_SIZE,
  function()
    return Settings.DistanceSize
  end,
  function(value)
    Settings.DistanceSize = value
  end,
  " px"
)

CreateSlider("Icon Size", MIN_ICON_SIZE, MAX_ICON_SIZE,
  function()
    return Settings.IconSize
  end,
  function(value)
    Settings.IconSize = value

    if not MenuOpen then
      Container.Size = UDim2.fromOffset(value, value)
    end
  end,
  " px"
)

--resize
local ResizeHandles = {}
local ResizeData

local function CreateResizeHandle(name, position, anchor, corner)
  local Handle = Instance.new("Frame")
  Handle.Name = name
  Handle.Size = UDim2.fromOffset(42, 42)
  Handle.Position = position
  Handle.AnchorPoint = anchor
  Handle.BackgroundTransparency = 1
  Handle.Visible = false
  Handle.Active = true
  Handle.ZIndex = 50
  Handle.Parent = Menu

  -- Curved corner arc made from three small segments.
  local Arc = Instance.new("Frame")
  Arc.Size = UDim2.fromOffset(26, 26)
  Arc.Position = UDim2.fromOffset(8, 8)
  Arc.BackgroundTransparency = 1
  Arc.BorderSizePixel = 0
  Arc.ZIndex = 51
  Arc.Parent = Handle

  local function CreateArcSegment(size, position, rotation)
    local Segment = Instance.new("Frame")
    Segment.Size = size
    Segment.Position = position
    Segment.AnchorPoint = Vector2.new(0.5, 0.5)
    Segment.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Segment.BackgroundTransparency = 0.45
    Segment.BorderSizePixel = 0
    Segment.Rotation = rotation
    Segment.ZIndex = 51
    Segment.Parent = Arc

    local SegmentCorner = Instance.new("UICorner")
    SegmentCorner.CornerRadius = UDim.new(1, 0)
    SegmentCorner.Parent = Segment
  end

  if corner == "TL" then
    CreateArcSegment(UDim2.fromOffset(12, 3), UDim2.fromOffset(8, 2), 0)
    CreateArcSegment(UDim2.fromOffset(12, 3), UDim2.fromOffset(2, 8), 90)
    CreateArcSegment(UDim2.fromOffset(8, 3), UDim2.fromOffset(4, 4), 45)
  elseif corner == "BL" then
    CreateArcSegment(UDim2.fromOffset(12, 3), UDim2.fromOffset(8, 24), 0)
    CreateArcSegment(UDim2.fromOffset(12, 3), UDim2.fromOffset(2, 18), 90)
    CreateArcSegment(UDim2.fromOffset(8, 3), UDim2.fromOffset(4, 22), -45)
  elseif corner == "BR" then
    CreateArcSegment(UDim2.fromOffset(12, 3), UDim2.fromOffset(18, 24), 0)
    CreateArcSegment(UDim2.fromOffset(12, 3), UDim2.fromOffset(24, 18), 90)
    CreateArcSegment(UDim2.fromOffset(8, 3), UDim2.fromOffset(22, 22), 45)
  end

  ResizeHandles[name] = Handle
  return Handle
end

local ResizeTL = CreateResizeHandle(
  "ResizeTopLeft",
  UDim2.fromOffset(0, 0),
  Vector2.new(0, 0),
  "TL"
)

local ResizeBL = CreateResizeHandle(
  "ResizeBottomLeft",
  UDim2.new(0, 0, 1, 0),
  Vector2.new(0, 1),
  "BL"
)

local ResizeBR = CreateResizeHandle(
  "ResizeBottomRight",
  UDim2.new(1, 0, 1, 0),
  Vector2.new(1, 1),
  "BR"
)

local function SetResizeVisible(value)
  for _, Handle in pairs(ResizeHandles) do
    Handle.Visible = value
  end
end

local function BeginResize(corner, input)
  if not MenuOpen or ResizeData then return end

  ResizeData = {
    Corner = corner,
    StartTouch = input.Position,
    StartPosition = Container.Position,
    StartWidth = MenuWidth,
    StartHeight = MenuHeight
  }
end

local function Resize(input)
  if not ResizeData or not MenuOpen then return end

  local delta = input.Position - ResizeData.StartTouch
  local width = ResizeData.StartWidth
  local height = ResizeData.StartHeight
  local x = ResizeData.StartPosition.X.Offset
  local y = ResizeData.StartPosition.Y.Offset
  local corner = ResizeData.Corner

  if corner == "BR" then
    width += delta.X
    height += delta.Y
  elseif corner == "BL" then
    width -= delta.X
    height += delta.Y
    x += delta.X
  elseif corner == "TL" then
    width -= delta.X
    height -= delta.Y
    x += delta.X
    y += delta.Y
  end

  local oldWidth = width
  local oldHeight = height

  width = math.clamp(width, MIN_MENU_WIDTH, MAX_MENU_WIDTH)
  height = math.clamp(height, MIN_MENU_HEIGHT, MAX_MENU_HEIGHT)

  if corner == "TL" or corner == "BL" then
    x += oldWidth - width
  end

  if corner == "TL" then
    y += oldHeight - height
  end

  MenuWidth = width
  MenuHeight = height
  Settings.MenuWidth = width
  Settings.MenuHeight = height

  Container.Size = UDim2.fromOffset(width, height)
  Container.Position = UDim2.new(
    ResizeData.StartPosition.X.Scale,
    x,
    ResizeData.StartPosition.Y.Scale,
    y
  )
end

local function EndResize()
  ResizeData = nil
end

local function SetupResizeHandle(handle, corner)
  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
      BeginResize(corner, input)
    end
  end)
end

SetupResizeHandle(ResizeTL, "TL")
SetupResizeHandle(ResizeBL, "BL")
SetupResizeHandle(ResizeBR, "BR")

UserInputService.TouchMoved:Connect(function(input)
  if ResizeData then
    Resize(input)
  end
end)

UserInputService.TouchEnded:Connect(function()
  EndResize()
end)

--drag
local Dragging = false
local DragMoved = false
local DragInput = nil
local DragStart = nil
local DragPosition = nil

local DRAG_THRESHOLD = 10

local function BeginDrag(input)
  if ResizeData or Animating then return end

  Dragging = true
  DragMoved = false
  DragInput = input
  DragStart = Vector2.new(input.Position.X, input.Position.Y)
  DragPosition = Container.Position
end

local function MoveDrag(input)
  if not Dragging or input ~= DragInput or ResizeData then
    return
  end

  local currentPosition = Vector2.new(
    input.Position.X,
    input.Position.Y
  )

  local delta = currentPosition - DragStart

  if delta.Magnitude >= DRAG_THRESHOLD then
    DragMoved = true
  end

  Container.Position = UDim2.new(
    DragPosition.X.Scale,
    DragPosition.X.Offset + delta.X,
    DragPosition.Y.Scale,
    DragPosition.Y.Offset + delta.Y
  )
end

local function EndDrag(input)
  if not Dragging or input ~= DragInput then
    return
  end

  local shouldOpen = not DragMoved and not MenuOpen

  Dragging = false
  DragMoved = false
  DragInput = nil

  if shouldOpen then
    OpenMenu()
  end
end

local MenuDragZone = Instance.new("TextButton")
MenuDragZone.Name = "MenuDragZone"
MenuDragZone.Size = UDim2.new(1, -65, 0, 60)
MenuDragZone.Position = UDim2.fromOffset(10, 0)
MenuDragZone.BackgroundTransparency = 1
MenuDragZone.BorderSizePixel = 0
MenuDragZone.Text = ""
MenuDragZone.AutoButtonColor = false
MenuDragZone.Active = true
MenuDragZone.Visible = false
MenuDragZone.ZIndex = 115
MenuDragZone.Parent = Menu

IconDragZone.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.Touch
    and not MenuOpen then
    BeginDrag(input)
  end
end)

MenuDragZone.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.Touch
    and MenuOpen then
    BeginDrag(input)
  end
end)

UserInputService.TouchMoved:Connect(function(input)
  MoveDrag(input)

  if ResizeData then
    Resize(input)
  end
end)

UserInputService.TouchEnded:Connect(function(input)
  EndDrag(input)

  if ResizeData then
    EndResize()
  end
end)

local function UpdateDragZones()
  IconDragZone.Visible = not MenuOpen
  MenuDragZone.Visible = MenuOpen
end

UpdateDragZones()

--animation
local OpenInfo = TweenInfo.new(
  0.32,
  Enum.EasingStyle.Quint,
  Enum.EasingDirection.Out
)

local CloseInfo = TweenInfo.new(
  0.27,
  Enum.EasingStyle.Quint,
  Enum.EasingDirection.In
)

local AnimatedElements = {
  Title,
  Subtitle,
  CloseButton,
  Separator,
  Scroll
}

local OriginalPositions = {}

for _, object in ipairs(AnimatedElements) do
  OriginalPositions[object] = object.Position
end

function OpenMenu()
  if MenuOpen or Animating then return end

  Animating = true
  MenuOpen = true

  IconButton.Visible = false
  IconDragZone.Visible = false

  Menu.Visible = true
  MenuDragZone.Visible = true

  SetResizeVisible(true)

  MenuWidth = math.clamp(
    MenuWidth,
    MIN_MENU_WIDTH,
    MAX_MENU_WIDTH
  )

  MenuHeight = math.clamp(
    MenuHeight,
    MIN_MENU_HEIGHT,
    MAX_MENU_HEIGHT
  )

  Settings.MenuWidth = MenuWidth
  Settings.MenuHeight = MenuHeight

  Container.Size = UDim2.fromOffset(
    Settings.IconSize,
    Settings.IconSize
  )

  TweenService:Create(Container, OpenInfo, {
    Size = UDim2.fromOffset(MenuWidth, MenuHeight)
  }):Play()

  for _, object in ipairs(AnimatedElements) do
    local position = OriginalPositions[object]

    object.Position = UDim2.new(
      position.X.Scale,
      position.X.Offset,
      position.Y.Scale,
      position.Y.Offset - 35
    )

    object.Visible = true
  end

  for index, object in ipairs(AnimatedElements) do
    local position = OriginalPositions[object]

    task.delay(index * 0.045, function()
      if not MenuOpen then return end

      TweenService:Create(object, TweenInfo.new(
        0.24,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
      ), {
        Position = position
      }):Play()
    end)
  end

  task.delay(0.35, function()
    if MenuOpen then
      Animating = false
    end
  end)
end

local function CloseMenu()
  if not MenuOpen or Animating then return end

  Animating = true

  SetResizeVisible(false)
  MenuDragZone.Visible = false

  for index, object in ipairs(AnimatedElements) do
    local position = OriginalPositions[object]

    task.delay(index * 0.025, function()
      TweenService:Create(object, TweenInfo.new(
        0.17,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
      ), {
        Position = UDim2.new(
          position.X.Scale,
          position.X.Offset,
          position.Y.Scale,
          position.Y.Offset - 35
        )
      }):Play()
    end)
  end

  task.wait(0.18)

  TweenService:Create(Container, CloseInfo, {
    Size = UDim2.fromOffset(
      Settings.IconSize,
      Settings.IconSize
    )
  }):Play()

  task.wait(0.27)

  Menu.Visible = false
  IconButton.Visible = true
  IconDragZone.Visible = true

  for _, object in ipairs(AnimatedElements) do
    object.Position = OriginalPositions[object]
  end

  MenuOpen = false
  Animating = false

  UpdateDragZones()
end

CloseButton.Activated:Connect(CloseMenu)

--visibility
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

--team
local function IsTeamMate(player)
  if not Settings.TeamCheck then
    return false
  end

  return LocalPlayer.Team ~= nil
    and player.Team ~= nil
    and LocalPlayer.Team == player.Team
end

--color
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

--esp
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
  Billboard.Parent = ScreenGui

  local Name = Instance.new("TextLabel")
  Name.Size = UDim2.new(1, 0, 0, 30)
  Name.BackgroundTransparency = 1
  Name.Text = player.DisplayName
  Name.TextSize = Settings.NameSize
  Name.Font = Enum.Font.GothamBold
  Name.TextStrokeTransparency = 0.35
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

  ESPObjects[player] = {
    Billboard = Billboard,
    Name = Name,
    Distance = Distance,
    Connection = nil
  }

  local function Attach(character)
    local Root = character:WaitForChild("HumanoidRootPart", 5)

    if Root and ESPObjects[player] then
      ESPObjects[player].Billboard.Adornee = Root
    end
  end

  if player.Character then
    task.spawn(Attach, player.Character)
  end

  ESPObjects[player].Connection = player.CharacterAdded:Connect(function(character)
    task.wait(0.15)

    if ESPObjects[player] then
      Attach(character)
    end
  end)
end

local function RemoveESP(player)
  local data = ESPObjects[player]

  if not data then return end

  if data.Connection then
    data.Connection:Disconnect()
  end

  if data.Billboard then
    data.Billboard:Destroy()
  end

  ESPObjects[player] = nil
end

--update
local function UpdateESP(player, data)
  if not Settings.ESP then
    data.Billboard.Enabled = false
    return
  end

  local Character = player.Character

  if not Character then
    data.Billboard.Enabled = false
    return
  end

  local Humanoid = Character:FindFirstChildOfClass("Humanoid")
  local Root = Character:FindFirstChild("HumanoidRootPart")

  if not Humanoid or not Root or Humanoid.Health <= 0 then
    data.Billboard.Enabled = false
    return
  end

  local MyCharacter = LocalPlayer.Character
  local MyRoot = MyCharacter and MyCharacter:FindFirstChild("HumanoidRootPart")

  if not MyRoot then
    data.Billboard.Enabled = false
    return
  end

  local distance = (MyRoot.Position - Root.Position).Magnitude

  if distance > Settings.ESPDistance then
    data.Billboard.Enabled = false
    return
  end

  data.Billboard.Enabled = true
  data.Name.TextSize = Settings.NameSize
  data.Distance.TextSize = Settings.DistanceSize
  data.Name.TextColor3 = GetPlayerColor(player, Character)

  if Settings.ShowDistance then
    data.Distance.Visible = true
    data.Distance.Text = math.floor(distance) .. " studs"
  else
    data.Distance.Visible = false
  end
end

--players
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

--loop
local timer = 0

RunService.RenderStepped:Connect(function(delta)
  timer += delta

  if timer < 0.05 then return end
  timer = 0

  for player, data in pairs(ESPObjects) do
    if player.Parent == Players then
      UpdateESP(player, data)
    else
      RemoveESP(player)
    end
  end
end)