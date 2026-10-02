--[[
    ADOPT ME HALLOWEEN FARM GUI — GUI ONLY
    No farming logic, remotes, teleporting, clicking automation, or backend hooks.
    The buttons below are visual placeholders for future/manual integration.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")

-- Prevent duplicate copies.
local oldGui = playerGui:FindFirstChild("AdoptMeHalloweenFarmGUI")
if oldGui then
    oldGui:Destroy()
end

local UI = {}

-- Palette
local COLORS = {
    background = Color3.fromRGB(20, 21, 29),
    panel = Color3.fromRGB(27, 29, 39),
    panel2 = Color3.fromRGB(33, 35, 47),
    panel3 = Color3.fromRGB(40, 42, 56),
    text = Color3.fromRGB(245, 246, 250),
    muted = Color3.fromRGB(157, 162, 176),
    accent = Color3.fromRGB(255, 133, 69),
    accent2 = Color3.fromRGB(168, 92, 255),
    success = Color3.fromRGB(67, 190, 118),
    danger = Color3.fromRGB(218, 79, 88),
    stroke = Color3.fromRGB(68, 72, 92),
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or COLORS.stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function label(parent, text, size, position, font, textSize, color, align)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.Size = size
    l.Position = position
    l.Font = font or Enum.Font.Gotham
    l.TextSize = textSize or 12
    l.TextColor3 = color or COLORS.text
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function button(parent, text, size, position, bg, textColor)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = text
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = bg
    b.TextColor3 = textColor or COLORS.text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Parent = parent
    corner(b, 7)
    local s = stroke(b, COLORS.stroke, 1, 0.25)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = bg:Lerp(Color3.new(1, 1, 1), 0.07)
        }):Play()
    end)

    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = bg
        }):Play()
    end)

    return b, s
end

-- ScreenGui
UI.gui = Instance.new("ScreenGui")
UI.gui.Name = "AdoptMeHalloweenFarmGUI"
UI.gui.ResetOnSpawn = false
UI.gui.IgnoreGuiInset = true
UI.gui.DisplayOrder = 9999
UI.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.gui.Parent = playerGui

-- Main window
UI.main = Instance.new("Frame")
UI.main.Name = "Main"
UI.main.Size = UDim2.fromOffset(350, 218)
UI.main.AnchorPoint = Vector2.new(0.5, 0.5)
UI.main.Position = UDim2.new(0.5, 0, 0.5, 0)
UI.main.BackgroundColor3 = COLORS.background
UI.main.BorderSizePixel = 0
UI.main.Active = true
UI.main.Parent = UI.gui
corner(UI.main, 11)
stroke(UI.main, COLORS.stroke, 1.25, 0)

-- Soft top accent
local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, 0, 0, 3)
topAccent.BackgroundColor3 = COLORS.accent
topAccent.BorderSizePixel = 0
topAccent.Parent = UI.main
corner(topAccent, 11)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -20, 0, 39)
header.Position = UDim2.fromOffset(10, 8)
header.BackgroundColor3 = COLORS.panel
header.BorderSizePixel = 0
header.Parent = UI.main
corner(header, 9)

local iconBox = Instance.new("Frame")
iconBox.Size = UDim2.fromOffset(29, 29)
iconBox.Position = UDim2.fromOffset(6, 5)
iconBox.BackgroundColor3 = COLORS.accent2
iconBox.BorderSizePixel = 0
iconBox.Parent = header
corner(iconBox, 8)

label(iconBox, "🎃", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0),
    Enum.Font.GothamBold, 15, COLORS.text, Enum.TextXAlignment.Center)

label(header, "ADOPT ME HALLOWEEN FARM", UDim2.new(1, -115, 0, 18), UDim2.fromOffset(42, 4),
    Enum.Font.GothamBold, 12, COLORS.text)

label(header, "GUI ONLY", UDim2.new(1, -115, 0, 13), UDim2.fromOffset(42, 21),
    Enum.Font.GothamMedium, 9, COLORS.muted)

UI.close, _ = button(header, "×", UDim2.fromOffset(26, 26), UDim2.new(1, -31, 0, 6),
    COLORS.panel3, COLORS.muted)
UI.close.TextSize = 18

-- Drag area (only header)
local dragging = false
local dragStart
local startPosition
local dragConnection

local dragArea = Instance.new("TextButton")
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.Size = UDim2.new(1, -35, 1, 0)
dragArea.Position = UDim2.fromOffset(0, 0)
dragArea.ZIndex = 10
dragArea.Parent = header

dragArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = UI.main.Position

        if dragConnection then
            dragConnection:Disconnect()
        end

        dragConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = nil
                end
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart
    UI.main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

UI.close.MouseButton1Click:Connect(function()
    UI.gui.Enabled = false
end)

-- Left: controls
local controls = Instance.new("Frame")
controls.Size = UDim2.fromOffset(205, 152)
controls.Position = UDim2.fromOffset(10, 55)
controls.BackgroundColor3 = COLORS.panel
controls.BorderSizePixel = 0
controls.Parent = UI.main
corner(controls, 9)
stroke(controls, COLORS.stroke, 1, 0.3)

label(controls, "FARM CONTROL", UDim2.new(1, -16, 0, 15), UDim2.fromOffset(8, 7),
    Enum.Font.GothamBold, 10, COLORS.muted)

UI.start, _ = button(controls, "▶  START FARM", UDim2.fromOffset(125, 34),
    UDim2.fromOffset(8, 31), COLORS.success)

UI.stop, _ = button(controls, "■  STOP", UDim2.fromOffset(125, 34),
    UDim2.fromOffset(147, 31), COLORS.danger)

label(controls, "STATUS", UDim2.new(1, -16, 0, 12), UDim2.fromOffset(8, 72),
    Enum.Font.GothamSemibold, 8, COLORS.muted)

UI.status = label(controls, "READY • MANUAL", UDim2.new(1, -16, 0, 20),
    UDim2.fromOffset(8, 87), Enum.Font.GothamBold, 10, COLORS.accent)

-- Compact farm-control-only layout
UI.main.Size = UDim2.fromOffset(300, 178)

controls.Size = UDim2.fromOffset(280, 120)
controls.Position = UDim2.fromOffset(10, 55)

-- Simple visual-only farm control state
UI.start.MouseButton1Click:Connect(function()
    UI.status.Text = "READY • START PRESSED"
end)

UI.stop.MouseButton1Click:Connect(function()
    UI.status.Text = "READY • STOP PRESSED"
end)

-- Auto-scale so the small landscape GUI remains comfortable across resolutions.
local camera = workspace.CurrentCamera
local function updateScale()
    camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize
    local scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 560), 0.82, 1.0)

    local existing = UI.main:FindFirstChild("ResponsiveScale")
    if not existing then
        existing = Instance.new("UIScale")
        existing.Name = "ResponsiveScale"
        existing.Parent = UI.main
    end
    existing.Scale = scale
end

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
updateScale()

UI.gui.Enabled = true
