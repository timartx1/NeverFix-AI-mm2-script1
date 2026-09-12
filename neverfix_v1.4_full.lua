-- ============================================================================
-- NEVERFIX v1.4 - FULL EXPANDED EDITION (ALL-IN-ONE)
-- FEATURES:
--   * Base AA, Rage Jitter Desync, FakeLag, Custom Yaw/Pitch (1-360), Pitch Speed
--   * Legit Aim Assist, FOV Visuals
--   * 2D Box ESP, Avatar ESP, Names ESP, Highlight Chams, MM2 Roles, Team Colors
--   * Physics Surf System, Waypoint Runner, Surf Sounds
--   * NEW: SlideWalk (Neverlose/Skeet Moonwalk Style)
--   * NEW: AirStuck System (Freeze in air on keybind)
--   * NEW: Smooth Watermark HUD with Background Transparency Customization
--   * NEW: Animated Hotkeys / Keybinds List HUD with Transparency Slider
--   * NEW: Complete Rage Tab Keybinds Configurator
--   * TrashTalk, Clantag System, Themes & Custom Hex/RGB Theme Builder
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global references
local aaToggleBtn = nil
local rageAAToggleBtnGlobal = nil
local fakeLagToggleBtnGlobal = nil
local slideWalkToggleBtnGlobal = nil
local airStuckToggleBtnGlobal = nil

-- Получение названия игры (кэшируем)
local CurrentGameName = "Loading..."
task.spawn(function()
    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    if success then CurrentGameName = result else CurrentGameName = "Unknown Game" end
end)

-- ==========================================
-- СИСТЕМА БЕЗОПАСНЫХ ШРИФТОВ (FONT RESOLVER)
-- ==========================================
local function getSafeFont(fontName)
    local success, result = pcall(function()
        return Enum.Font[fontName]
    end)
    if success and result then
        return result
    end
    for _, fallback in ipairs({"GothamMedium", "SourceSans", "Arial"}) do
        local s, f = pcall(function() return Enum.Font[fallback] end)
        if s and f then return f end
    end
    return Enum.Font.SourceSans
end

local Font_Code = getSafeFont("Code")
local Font_Gotham = getSafeFont("Gotham")
local Font_GothamMedium = getSafeFont("GothamMedium")
local Font_GothamBold = getSafeFont("GothamBold")
local Font_FredokaOne = getSafeFont("FredokaOne")
local Font_SourceSans = getSafeFont("SourceSans")
local Font_SourceSansBold = getSafeFont("SourceSansBold")

-- ==========================================
-- НАСТРОЙКИ СКРИПТА И ПЕРЕМЕННЫЕ
-- ==========================================

local Config = {
    uiScaleValue = 1.0,
    activeThemeColor = Color3.fromRGB(0, 162, 255),
    customBgColor = Color3.fromRGB(13, 16, 23),
    customPanelColor = Color3.fromRGB(18, 23, 34),
    currentStylePreset = "Default",

    -- Animated theme options
    themeAnimated = false,
    themeType = "Rainbow", -- "Rainbow" / "Space" / "Ocean" / "None"
    themeSpeed = 1.0,
    themeTransparency = 0.0,

    menuVisible = true,
    menuToggleKey = Enum.KeyCode.Insert,
    bindingMenuToggleKey = false,

    -- HUD / Watermark Settings
    showWatermarkHUD = true,
    hudNickname = LocalPlayer.DisplayName or LocalPlayer.Name,
    hudStyle = "Round",
    showFps = true,
    showPing = true,
    showTime = true,
    showGameName = true,
    hudTransparency = 0.15,
    hudSmoothness = true,

    -- Keybinds Menu Settings
    showKeybindsMenu = true,
    keybindsTransparency = 0.2,
    keybindsPosition = UDim2.new(0.02, 0, 0.45, 0),

    -- Anti-Aim Settings
    aaEnabled = false,
    aaToggleKey = Enum.KeyCode.Unknown,
    aaToggleKeyMode = "Toggle",
    bindingAAToggleKey = false,

    aaModeIndex = 2,
    aaModes = {"Manual", "Spin", "Camera", "Custom"},

    aaPitchIndex = 2,
    aaPitchModes = {"Off", "Down", "Up", "Zero", "Custom"},

    aaYawOffset = 0,
    aaPitchOffset = 0,
    pitchChangeSpeed = 5,
    aaSpinSpeed = 15,
    aaManualDirIndex = 1,
    aaManualDirs = {"Back", "Left", "Right", "Front"},
    currentSpinAngle = 0,

    aaKeyLeft = Enum.KeyCode.Z,
    aaKeyBack = Enum.KeyCode.X,
    aaKeyRight = Enum.KeyCode.C,
    aaKeyFront = Enum.KeyCode.F,

    bindingAAKeyLeft = false,
    bindingAAKeyBack = false,
    bindingAAKeyRight = false,
    bindingAAKeyFront = false,

    -- Rage Jitter / Desync Settings
    rageAAEnabled = false,
    rageAAAngle = 75,
    rageAASpeed = 15,
    rageAADelay = 0.066,
    rageRandomSpeedEnabled = false,
    rageSpeedMin = 5,
    rageSpeedMax = 30,
    currentRandomDelay = 0.066,
    rageAAFlipState = false,
    lastRageAATick = 0,
    rageAABindKey = Enum.KeyCode.Unknown,
    rageAABindMode = "Toggle",
    bindingRageAABindKey = false,

    -- Fake Lag Settings
    fakeLagEnabled = false,
    fakeLagLimit = 10,
    fakeLagModeIndex = 1,
    fakeLagModes = {"Static", "Random", "Adaptive"},
    fakeLagBindKey = Enum.KeyCode.Unknown,
    fakeLagBindMode = "Toggle",
    bindingFakeLagBindKey = false,

    -- Movement Additions (SlideWalk & AirStuck)
    slideWalkEnabled = false,
    slideWalkKey = Enum.KeyCode.Unknown,
    slideWalkKeyMode = "Toggle",
    bindingSlideWalkKey = false,

    airStuckEnabled = false,
    airStuckKey = Enum.KeyCode.E,
    airStuckKeyMode = "Hold", -- "Toggle" / "Hold"
    isAirStuckActive = false,
    airStuckFrozenCFrame = nil,
    bindingAirStuckKey = false,

    -- Physics Surf Settings
    pixelSurfSpeed = 60,
    pixelSurfKey = Enum.KeyCode.V,
    surfKeyMode = "Hold",
    isSurfKeyPressed = false,
    bindingSurfKey = false,
    wasSurfing = false,

    surfModeIndex = 1,
    surfModes = {"Free", "Waypoints"},
    setWaypointKey = Enum.KeyCode.X,
    bindingWaypointKey = false,

    waypoints = {},
    currentWaypointIndex = 1,

    -- TrashTalk System
    trashTalkEnabled = false,
    trashTalkKey = Enum.KeyCode.T,
    trashTalkKeyMode = "Toggle",
    bindingTrashTalkKey = false,

    -- Visuals / Chat Clantag
    clantagEnabled = true,
    clantagText = "[ NEVERFIX ]",
    showVelocityHUD = true,

    boxEspEnabled = false,
    teamColorsEnabled = true,
    highlightChamsEnabled = false,
    namesEspEnabled = false,

    -- MM2 Role ESP Settings
    mm2RoleEspEnabled = false,
    murdererColor = Color3.fromRGB(255, 35, 35),
    sheriffColor = Color3.fromRGB(35, 135, 255),
    innocentColor = Color3.fromRGB(35, 225, 75),

    enemyColor = Color3.fromRGB(255, 60, 60),
    teammateColor = Color3.fromRGB(80, 220, 100),

    -- World Visuals Settings
    worldVisualsEnabled = false,
    timeOfDayValue = 14,
    customFogEnd = 400,
    customFogColor = Color3.fromRGB(170, 0, 255),
    worldPresetIndex = 1,
    worldPresets = {"Default", "Purple Night", "Cyberpunk", "Fullbright"},

    showMiniAvatar = true,

    aimbotEnabled = false,
    aimbotFov = 150,
    aimbotSmoothness = 0.15,
    aimbotPrediction = 0.05,
    aimbotKey = Enum.UserInputType.MouseButton2,

    showFovCircle = false,
    fovCircleFilled = false,
    fovCircleTransparency = 0.7,
    fovColor = Color3.fromRGB(0, 162, 255),

    -- Hit Sounds
    surfHitVolume = 0.8,
    endHitVolume = 1.0,
    currentHitSound = "rbxassetid://4817809188",
    hitSoundInterval = 0.12,
    lastHitSoundTime = 0
}

Config.requestSurfFallAnimation = false

local trashTalkCommon = {
    "[NeverFix] Сядь отдохни, бро!",
    "[NeverFix] Слишком легко, попробуй включить монитор",
    "[NeverFix] Тебе стоит еще немного потренироваться",
    "[NeverFix] Отправляйся обратно в лобби!",
    "[NeverFix] Спасибо за легкую победу!",
    "[NeverFix] Ты точно играешь с включенной мышкой?",
    "[NeverFix] Кажется у кого-то жестко лагает ПК"
}

local trashTalkRare = {
    "[NeverFix] Ты буквально наблюдаешь за своей же виртуальной жизни!",
    "[NeverFix] Моя бабушка играет лучше, без обид!",
    "[NeverFix] Это был туториал или ты правда старался?",
    "[NeverFix] Скорость твоей реакции: 3-5 рабочих дней!",
    "[NeverFix] Нажми Alt+F4 для улучшения аима!"
}

local defaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    TimeOfDay = Lighting.TimeOfDay,
    Brightness = Lighting.Brightness
}

local hitSounds = {
    {name = "Default", id = "rbxassetid://4817809188"},
    {name = "Metallic", id = "rbxassetid://6607204501"},
    {name = "Skeet / Bell", id = "rbxassetid://4981500369"}
}

local endSounds = {
    "rbxassetid://7463103082",
    "rbxassetid://6444160460",
    "rbxassetid://122567604280409",
    "rbxassetid://6410924125",
    "rbxassetid://80101615094724",
    "rbxassetid://76056711922637",
    "rbxassetid://125621554040822"
}

local soundButtons = {}

-- ==========================================
-- ТЕМЫ ОФОРМЛЕНИЯ И ИХ ПАЛИТРЫ
-- ==========================================
local StylePresets = {
    ["Default"] = {
        bg = Color3.fromRGB(13, 16, 23),
        panel = Color3.fromRGB(18, 23, 34),
        group = Color3.fromRGB(22, 29, 43),
        border = Color3.fromRGB(32, 42, 62),
        accent = Color3.fromRGB(0, 162, 255),
        text = Color3.fromRGB(230, 235, 245),
        darkText = Color3.fromRGB(110, 125, 150),
        font = Font_GothamMedium,
        boldFont = Font_GothamBold,
        titleText = "NEVERFIX | Version by tima 1.4"
    },
    ["Skeet"] = {
        bg = Color3.fromRGB(12, 12, 12),
        panel = Color3.fromRGB(16, 16, 16),
        group = Color3.fromRGB(20, 20, 20),
        border = Color3.fromRGB(45, 45, 45),
        accent = Color3.fromRGB(120, 225, 30),
        text = Color3.fromRGB(235, 235, 235),
        darkText = Color3.fromRGB(135, 135, 135),
        font = Font_Code,
        boldFont = Font_Code,
        titleText = "gamesense | NeverFix 1.4"
    },
    ["Neverlose"] = {
        bg = Color3.fromRGB(8, 12, 20),
        panel = Color3.fromRGB(12, 19, 30),
        group = Color3.fromRGB(16, 26, 42),
        border = Color3.fromRGB(0, 150, 255),
        accent = Color3.fromRGB(0, 180, 255),
        text = Color3.fromRGB(240, 248, 255),
        darkText = Color3.fromRGB(100, 140, 180),
        font = Font_Gotham,
        boldFont = Font_GothamBold,
        titleText = "NEVERLOSE // NeverFix 1.4"
    },
    ["Primordial"] = {
        bg = Color3.fromRGB(20, 18, 28),
        panel = Color3.fromRGB(28, 24, 38),
        group = Color3.fromRGB(36, 30, 50),
        border = Color3.fromRGB(120, 90, 200),
        accent = Color3.fromRGB(160, 100, 255),
        text = Color3.fromRGB(245, 240, 255),
        darkText = Color3.fromRGB(150, 130, 180),
        font = Font_FredokaOne,
        boldFont = Font_FredokaOne,
        titleText = "primordial.dev | tima 1.4"
    },
    ["One tap v3"] = {
        bg = Color3.fromRGB(25, 25, 28),
        panel = Color3.fromRGB(33, 33, 38),
        group = Color3.fromRGB(42, 42, 48),
        border = Color3.fromRGB(255, 140, 0),
        accent = Color3.fromRGB(255, 150, 0),
        text = Color3.fromRGB(245, 245, 245),
        darkText = Color3.fromRGB(170, 150, 120),
        font = Font_SourceSans,
        boldFont = Font_SourceSansBold,
        titleText = "onetap v3 | NeverFix Edition"
    },
    ["Space"] = {
        bg = Color3.fromRGB(5, 8, 18),
        panel = Color3.fromRGB(12, 10, 22),
        group = Color3.fromRGB(20, 18, 36),
        border = Color3.fromRGB(80, 60, 140),
        accent = Color3.fromRGB(130, 80, 255),
        text = Color3.fromRGB(220, 230, 255),
        darkText = Color3.fromRGB(140, 150, 180),
        font = Font_Code,
        boldFont = Font_Code,
        titleText = "Theme: Space (Animated)"
    },
    ["Ocean"] = {
        bg = Color3.fromRGB(6, 18, 30),
        panel = Color3.fromRGB(10, 28, 42),
        group = Color3.fromRGB(14, 34, 52),
        border = Color3.fromRGB(10, 110, 160),
        accent = Color3.fromRGB(0, 160, 210),
        text = Color3.fromRGB(220, 245, 255),
        darkText = Color3.fromRGB(120, 150, 170),
        font = Font_Code,
        boldFont = Font_Code,
        titleText = "Theme: Ocean (Animated)"
    }
}

local activeStyle = StylePresets["Default"]
local NF_BG        = activeStyle.bg
local NF_PANEL     = activeStyle.panel
local NF_GROUP     = activeStyle.group
local NF_ACCENT    = activeStyle.accent
local NF_ORANGE    = Color3.fromRGB(255, 140, 30)
local NF_TEXT      = activeStyle.text
local NF_DARK_TEXT = activeStyle.darkText
local NF_BORDER    = activeStyle.border

local function hexToColor3(hex)
    if not hex or hex == "" then return nil end
    hex = hex:gsub("#", "")
    if #hex == 3 then
        local r = tonumber(hex:sub(1,1) .. hex:sub(1,1), 16)
        local g = tonumber(hex:sub(2,2) .. hex:sub(2,2), 16)
        local b = tonumber(hex:sub(3,3) .. hex:sub(3,3), 16)
        return Color3.fromRGB(r or 0, g or 0, b or 0)
    elseif #hex == 6 then
        local r = tonumber(hex:sub(1,2), 16)
        local g = tonumber(hex:sub(3,4), 16)
        local b = tonumber(hex:sub(5,6), 16)
        return Color3.fromRGB(r or 0, g or 0, b or 0)
    end
    return nil
end

local function parseColor(text)
    local hexColor = hexToColor3(text)
    if hexColor then return hexColor end
    local r, g, b = string.match(text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    if r and g and b then
        return Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
    end
    return nil
end

-- ==========================================
-- Очистка старых GUI
-- ==========================================
local parentGui
if gethui then
    parentGui = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
    parentGui = CoreGui
else
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

for _, name in ipairs({
    "NeverfixSurfGui", "NeverfixVelHUD", "NeverfixWatermarkHUD", "NeverfixKeybindsHUD",
    "NeverfixEspGui", "NeverfixFovGui", "NeverfixVisualIndicator", "NeverfixWaypointsGui", "NeverfixIntroGui"
}) do
    if parentGui:FindFirstChild(name) then parentGui[name]:Destroy() end
end

-- ==========================================
-- УНИВЕРСАЛЬНЫЙ DRAGGABLE С ПОДДЕРЖКОЙ TWEEN
-- ==========================================
local function makeDraggable(guiObj)
    if not guiObj then return end
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    guiObj.InputBegan:Connect(onInputBegan)
    guiObj.InputChanged:Connect(onInputChanged)
end

-- ==========================================
-- PS INDICATOR GUI
-- ==========================================
local indicatorGui = Instance.new("ScreenGui")
indicatorGui.Name = "NeverfixVisualIndicator"
indicatorGui.ResetOnSpawn = false
indicatorGui.Parent = parentGui

local indicatorFrame = Instance.new("Frame")
indicatorFrame.Size = UDim2.new(0, 120, 0, 50)
indicatorFrame.Position = UDim2.new(0.5, -60, 0.65, 0)
indicatorFrame.BackgroundTransparency = 1
indicatorFrame.Parent = indicatorGui

local indicatorLabel = Instance.new("TextLabel")
indicatorLabel.Size = UDim2.new(1, 0, 1, 0)
indicatorLabel.BackgroundTransparency = 1
indicatorLabel.Text = "PS"
indicatorLabel.TextColor3 = activeStyle.accent
indicatorLabel.Font = Font_FredokaOne
indicatorLabel.TextSize = 28
indicatorLabel.TextStrokeTransparency = 1
indicatorLabel.TextTransparency = 1
indicatorLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
indicatorLabel.Parent = indicatorFrame

local psTween = nil
local function setPSIndicatorVisible(visible)
    if psTween then psTween:Cancel() end
    local targetTextTrans = visible and 0 or 1
    local targetStrokeTrans = visible and 0.2 or 1
    
    psTween = TweenService:Create(indicatorLabel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = targetTextTrans,
        TextStrokeTransparency = targetStrokeTrans
    })
    psTween:Play()
end

-- ==========================================
-- СИСТЕМА WAYPOINTS VISUAL RENDER
-- ==========================================
local waypointsGui = Instance.new("ScreenGui")
waypointsGui.Name = "NeverfixWaypointsGui"
waypointsGui.ResetOnSpawn = false
waypointsGui.Parent = parentGui

local waypointRenderFolder = Instance.new("Folder")
waypointRenderFolder.Name = "WaypointsRender"
waypointRenderFolder.Parent = waypointsGui

local function createWaypointVisual()
    local outerCircle = Instance.new("Frame")
    outerCircle.Size = UDim2.new(0, 28, 0, 28)
    outerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    outerCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outerCircle.BackgroundTransparency = 0.4
    outerCircle.BorderSizePixel = 0
    outerCircle.Visible = false

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outerCircle

    local innerDot = Instance.new("Frame")
    innerDot.Size = UDim2.new(0, 10, 0, 10)
    innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    innerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerDot.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    innerDot.BackgroundTransparency = 0.0
    innerDot.BorderSizePixel = 0
    innerDot.Parent = outerCircle

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = innerDot

    return outerCircle
end

local activeWaypointDots = {}

RunService.RenderStepped:Connect(function()
    for i, pos in ipairs(Config.waypoints) do
        if not activeWaypointDots[i] then
            local dot = createWaypointVisual()
            dot.Parent = waypointRenderFolder
            activeWaypointDots[i] = dot
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if onScreen then
            activeWaypointDots[i].Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            activeWaypointDots[i].Visible = true
        else
            activeWaypointDots[i].Visible = false
        end
    end

    for i = #Config.waypoints + 1, #activeWaypointDots do
        if activeWaypointDots[i] then
            activeWaypointDots[i]:Destroy()
            activeWaypointDots[i] = nil
        end
    end
end)

-- ==========================================
-- СИСТЕМА ОТПРАВКИ ТРЕШТОЛКА
-- ==========================================
local function sendTrashTalk()
    local phrase = ""
    if math.random(1, 100) <= 85 then
        phrase = trashTalkCommon[math.random(1, #trashTalkCommon)]
    else
        phrase = trashTalkRare[math.random(1, #trashTalkRare)]
    end

    pcall(function()
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            local channel = textChannels and textChannels:FindFirstChild("RBXGeneral")
            if channel and channel:IsA("TextChannel") then
                channel:SendAsync(phrase)
            end
        else
            local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            local sayMsg = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")
            if sayMsg then
                sayMsg:FireServer(phrase, "All")
            end
        end
    end)
end

-- ==========================================
-- СИСТЕМА КЛАНОТЕГА
-- ==========================================
task.spawn(function()
    local function attachTagToTextBox(tb)
        if tb:IsA("TextBox") and not tb:GetAttribute("NeverfixHooked") then
            tb:SetAttribute("NeverfixHooked", true)
            tb.FocusLost:Connect(function(enterPressed)
                if enterPressed and Config.clantagEnabled and tb.Text ~= "" then
                    local cleanPrefix = Config.clantagText .. " "
                    if not string.find(tb.Text, "^" .. string.gsub(Config.clantagText, "([%[%]%(%)%.%%+%-%*%?%^%$])", "%%%1")) then
                        tb.Text = cleanPrefix .. tb.Text
                    end
                end
            end)
        end
    end

    while task.wait(0.5) do
        if Config.clantagEnabled then
            pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, obj in ipairs(pg:GetDescendants()) do
                        if obj:IsA("TextBox") then
                            attachTagToTextBox(obj)
                        end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- FOV CIRCLE
-- ==========================================
local fovCircleDrawing = nil
local fovGuiFrame = nil

if typeof(Drawing) == "table" and type(Drawing.new) == "function" then
    fovCircleDrawing = Drawing.new("Circle")
    fovCircleDrawing.Thickness = 1.5
    fovCircleDrawing.NumSides = 64
    fovCircleDrawing.Radius = Config.aimbotFov
    fovCircleDrawing.Filled = Config.fovCircleFilled
    fovCircleDrawing.Visible = false
    fovCircleDrawing.Color = Config.fovColor
else
    local fovGui = Instance.new("ScreenGui")
    fovGui.Name = "NeverfixFovGui"
    fovGui.ResetOnSpawn = false
    fovGui.Parent = parentGui

    fovGuiFrame = Instance.new("Frame")
    fovGuiFrame.Name = "FOVCircle"
    fovGuiFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovGuiFrame.BackgroundTransparency = 1
    fovGuiFrame.Visible = false
    fovGuiFrame.Parent = fovGui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Config.fovColor
    stroke.Parent = fovGuiFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fovGuiFrame
end

-- ==========================================
-- VELOCITY HUD
-- ==========================================
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "NeverfixVelHUD"
hudGui.ResetOnSpawn = false
hudGui.Parent = parentGui

local hudFrame = Instance.new("Frame")
hudFrame.Name = "VelHUDFrame"
hudFrame.Size = UDim2.new(0, 180, 0, 55)
hudFrame.Position = UDim2.new(0.05, 0, 0.75, 0)
hudFrame.BackgroundColor3 = NF_BG
hudFrame.BackgroundTransparency = Config.hudTransparency
hudFrame.BorderSizePixel = 0
hudFrame.Active = true
hudFrame.Visible = Config.showVelocityHUD
hudFrame.Parent = hudGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 6)
hudCorner.Parent = hudFrame

local hudStroke = Instance.new("UIStroke")
hudStroke.Color = NF_BORDER
hudStroke.Thickness = 1
hudStroke.Parent = hudFrame

local hudHeader = Instance.new("Frame")
hudHeader.Size = UDim2.new(1, 0, 0, 2)
hudHeader.BackgroundColor3 = NF_ACCENT
hudHeader.BorderSizePixel = 0
hudHeader.Parent = hudFrame

local speedTextLabel = Instance.new("TextLabel")
speedTextLabel.Size = UDim2.new(1, -16, 0, 22)
speedTextLabel.Position = UDim2.new(0, 8, 0, 6)
speedTextLabel.BackgroundTransparency = 1
speedTextLabel.Text = "SPEED: 0"
speedTextLabel.TextColor3 = NF_ACCENT
speedTextLabel.TextXAlignment = Enum.TextXAlignment.Left
speedTextLabel.Font = Font_GothamBold
speedTextLabel.TextSize = 13
speedTextLabel.Parent = hudFrame

local heightTextLabel = Instance.new("TextLabel")
heightTextLabel.Size = UDim2.new(1, -16, 0, 20)
heightTextLabel.Position = UDim2.new(0, 8, 0, 28)
heightTextLabel.BackgroundTransparency = 1
heightTextLabel.Text = "HEIGHT: 0"
heightTextLabel.TextColor3 = NF_TEXT
heightTextLabel.TextXAlignment = Enum.TextXAlignment.Left
heightTextLabel.Font = Font_GothamMedium
heightTextLabel.TextSize = 12
heightTextLabel.Parent = hudFrame

makeDraggable(hudFrame)

-- ==========================================
-- WATERMARK HUD (СВЕРХУ ПО ЦЕНТРУ С ОБЛОЖКОЙ)
-- ==========================================
local wmGui = Instance.new("ScreenGui")
wmGui.Name = "NeverfixWatermarkHUD"
wmGui.ResetOnSpawn = false
wmGui.Parent = parentGui

local wmFrame = Instance.new("Frame")
wmFrame.Name = "WatermarkFrame"
wmFrame.Size = UDim2.new(0, 380, 0, 26)
wmFrame.AnchorPoint = Vector2.new(0.5, 0)
wmFrame.Position = UDim2.new(0.5, 0, 0, 15)
wmFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
wmFrame.BackgroundTransparency = Config.hudTransparency
wmFrame.BorderSizePixel = 0
wmFrame.Active = true
wmFrame.Visible = Config.showWatermarkHUD
wmFrame.Parent = wmGui

local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0, 13)
wmCorner.Parent = wmFrame

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = NF_ACCENT
wmStroke.Thickness = 1.2
wmStroke.Parent = wmFrame

local wmLeft = Instance.new("Frame")
wmLeft.Size = UDim2.new(0, 30, 1, 0)
wmLeft.Position = UDim2.new(0, 0, 0, 0)
wmLeft.BackgroundTransparency = 1
wmLeft.Parent = wmFrame

local wmIcon = Instance.new("TextLabel")
wmIcon.Size = UDim2.new(1, 0, 1, 0)
wmIcon.Position = UDim2.new(0, 8, 0, 0)
wmIcon.BackgroundTransparency = 1
wmIcon.Text = "NF"
wmIcon.TextColor3 = NF_ACCENT
wmIcon.Font = Font_FredokaOne
wmIcon.TextSize = 14
wmIcon.TextXAlignment = Enum.TextXAlignment.Left
wmIcon.Parent = wmLeft

local wmGameCover = Instance.new("ImageLabel")
wmGameCover.Size = UDim2.new(0, 18, 0, 18)
wmGameCover.Position = UDim2.new(0, 32, 0.5, -9)
wmGameCover.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
wmGameCover.BorderSizePixel = 0
wmGameCover.Image = "rbxthumb://type=Asset&id=" .. game.PlaceId .. "&w=150&h=150"
wmGameCover.ScaleType = Enum.ScaleType.Crop
wmGameCover.Parent = wmFrame

local coverRound = Instance.new("UICorner")
coverRound.CornerRadius = UDim.new(0, 4)
coverRound.Parent = wmGameCover

local wmText = Instance.new("TextLabel")
wmText.Size = UDim2.new(1, -64, 1, 0)
wmText.Position = UDim2.new(0, 56, 0, 0)
wmText.BackgroundTransparency = 1
wmText.Text = "Loading details..."
wmText.TextColor3 = Color3.fromRGB(240, 240, 240)
wmText.Font = Font_Code
wmText.TextSize = 12
wmText.TextXAlignment = Enum.TextXAlignment.Left
wmText.Parent = wmFrame

makeDraggable(wmFrame)

-- ==========================================
-- KEYBINDS LIST HUD (ГОЛОГРАФИЧЕСКОЕ ОКНО КЕЙБИНДОВ)
-- ==========================================
local kbGui = Instance.new("ScreenGui")
kbGui.Name = "NeverfixKeybindsHUD"
kbGui.ResetOnSpawn = false
kbGui.Parent = parentGui

local kbMainFrame = Instance.new("Frame")
kbMainFrame.Name = "KeybindsList"
kbMainFrame.Size = UDim2.new(0, 190, 0, 140)
kbMainFrame.Position = Config.keybindsPosition
kbMainFrame.BackgroundColor3 = NF_BG
kbMainFrame.BackgroundTransparency = Config.keybindsTransparency
kbMainFrame.BorderSizePixel = 0
kbMainFrame.Active = true
kbMainFrame.Visible = Config.showKeybindsMenu
kbMainFrame.Parent = kbGui

local kbCorner = Instance.new("UICorner")
kbCorner.CornerRadius = UDim.new(0, 6)
kbCorner.Parent = kbMainFrame

local kbStroke = Instance.new("UIStroke")
kbStroke.Color = NF_BORDER
kbStroke.Thickness = 1
kbStroke.Parent = kbMainFrame

local kbHeader = Instance.new("Frame")
kbHeader.Size = UDim2.new(1, 0, 0, 24)
kbHeader.BackgroundColor3 = NF_PANEL
kbHeader.BackgroundTransparency = Config.keybindsTransparency
kbHeader.BorderSizePixel = 0
kbHeader.Parent = kbMainFrame

local kbHeaderCorner = Instance.new("UICorner")
kbHeaderCorner.CornerRadius = UDim.new(0, 6)
kbHeaderCorner.Parent = kbHeader

local kbHeaderTitle = Instance.new("TextLabel")
kbHeaderTitle.Size = UDim2.new(1, -12, 1, 0)
kbHeaderTitle.Position = UDim2.new(0, 8, 0, 0)
kbHeaderTitle.BackgroundTransparency = 1
kbHeaderTitle.Text = "Keybinds"
kbHeaderTitle.TextColor3 = NF_TEXT
kbHeaderTitle.Font = Font_Code
kbHeaderTitle.TextSize = 12
kbHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
kbHeaderTitle.Parent = kbHeader

local kbHeaderGlow = Instance.new("Frame")
kbHeaderGlow.Size = UDim2.new(1, 0, 0, 1.5)
kbHeaderGlow.Position = UDim2.new(0, 0, 1, -1)
kbHeaderGlow.BackgroundColor3 = NF_ACCENT
kbHeaderGlow.BorderSizePixel = 0
kbHeaderGlow.Parent = kbHeader

local kbListContainer = Instance.new("Frame")
kbListContainer.Size = UDim2.new(1, -10, 1, -28)
kbListContainer.Position = UDim2.new(0, 5, 0, 26)
kbListContainer.BackgroundTransparency = 1
kbListContainer.Parent = kbMainFrame

local kbListLayout = Instance.new("UIListLayout")
kbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
kbListLayout.Padding = UDim.new(0, 3)
kbListLayout.Parent = kbListContainer

makeDraggable(kbMainFrame)

-- ==========================================
-- ОБНОВЛЕНИЕ СПИСКА КЕЙБИНДОВ
-- ==========================================
local activeKeybindEntries = {}

local function updateKeybindItem(name, keyName, mode, isActive)
    local entry = activeKeybindEntries[name]
    if isActive then
        if not entry then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 18)
            row.BackgroundTransparency = 1

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
            nameLbl.Position = UDim2.new(0, 4, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = name
            nameLbl.TextColor3 = NF_DARK_TEXT
            nameLbl.Font = Font_Code
            nameLbl.TextSize = 11
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = row

            local statusLbl = Instance.new("TextLabel")
            statusLbl.Size = UDim2.new(0.45, -4, 1, 0)
            statusLbl.Position = UDim2.new(0.55, 0, 0, 0)
            statusLbl.BackgroundTransparency = 1
            statusLbl.Text = "[" .. tostring(mode) .. "]"
            statusLbl.TextColor3 = NF_ACCENT
            statusLbl.Font = Font_Code
            statusLbl.TextSize = 11
            statusLbl.TextXAlignment = Enum.TextXAlignment.Right
            statusLbl.Parent = row

            row.Parent = kbListContainer
            activeKeybindEntries[name] = {frame = row, nameLbl = nameLbl, statusLbl = statusLbl}
        else
            entry.statusLbl.Text = "[" .. tostring(mode) .. "]"
            entry.frame.Visible = true
        end
    else
        if entry then
            entry.frame:Destroy()
            activeKeybindEntries[name] = nil
        end
    end
end

-- ==========================================
-- ИНТЕРФЕЙС ГЛАВНОГО МЕНЮ (NEVERFIX UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NeverfixSurfGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 550, 0, 420)
mainFrame.Position = UDim2.new(0.5, -275, 0.4, -210)
mainFrame.BackgroundColor3 = NF_BG
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = NF_BORDER
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local uiScaleObj = Instance.new("UIScale")
uiScaleObj.Scale = Config.uiScaleValue
uiScaleObj.Parent = mainFrame

makeDraggable(mainFrame)

-- Шапка
local topHeader = Instance.new("Frame")
topHeader.Size = UDim2.new(1, 0, 0, 35)
topHeader.BackgroundColor3 = NF_PANEL
topHeader.BorderSizePixel = 0
topHeader.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = topHeader

local headerLogo = Instance.new("Frame")
headerLogo.Size = UDim2.new(0, 140, 1, 0)
headerLogo.Position = UDim2.new(0, 12, 0, 0)
headerLogo.BackgroundTransparency = 1
headerLogo.Parent = topHeader

local headerLogoIcon = Instance.new("TextLabel")
headerLogoIcon.Size = UDim2.new(0, 36, 0, 26)
headerLogoIcon.Position = UDim2.new(0, 0, 0.5, -13)
headerLogoIcon.BackgroundTransparency = 1
headerLogoIcon.Text = "NF"
headerLogoIcon.TextColor3 = NF_ACCENT
headerLogoIcon.TextXAlignment = Enum.TextXAlignment.Left
headerLogoIcon.Font = Font_FredokaOne
headerLogoIcon.TextSize = 16
headerLogoIcon.Parent = headerLogo

local headerText = Instance.new("TextLabel")
headerText.Size = UDim2.new(1, -40, 1, 0)
headerText.Position = UDim2.new(0, 42, 0, 0)
headerText.BackgroundTransparency = 1
headerText.Text = "| Version by tima 1.4"
headerText.TextColor3 = NF_DARK_TEXT
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.Font = Font_Code
headerText.TextSize = 13
headerText.Parent = headerLogo

local glowLine = Instance.new("Frame")
glowLine.Size = UDim2.new(1, 0, 0, 2)
glowLine.Position = UDim2.new(0, 0, 1, -2)
glowLine.BackgroundColor3 = NF_ACCENT
glowLine.BorderSizePixel = 0
glowLine.Parent = topHeader

-- Сайдбар
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -45)
sidebar.Position = UDim2.new(0, 10, 0, 40)
sidebar.BackgroundColor3 = NF_PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 6)
sidebarCorner.Parent = sidebar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -150, 1, -45)
tabContainer.Position = UDim2.new(0, 145, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabs = {"Rage", "Legit", "Visuals", "Movement", "Misc"}
local activeTab = "Rage"
local tabButtons = {}
local tabFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, 6 + (i - 1) * 34)
    btn.BackgroundColor3 = (tabName == activeTab) and NF_GROUP or Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = (tabName == activeTab) and 0 or 1
    btn.Text = "  " .. tabName
    btn.TextColor3 = (tabName == activeTab) and NF_ACCENT or NF_DARK_TEXT
    btn.Font = Font_Code
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn

    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.new(0, 0, 0, 1000)
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = NF_ACCENT
    frame.Visible = (tabName == activeTab)
    frame.Parent = tabContainer

    tabFrames[tabName] = frame
    tabButtons[tabName] = btn

    btn.MouseButton1Click:Connect(function()
        activeTab = tabName
        for name, tFrame in pairs(tabFrames) do
            tFrame.Visible = (name == tabName)
            if tabButtons[name] then
                tabButtons[name].TextColor3 = (name == tabName) and NF_ACCENT or NF_DARK_TEXT
                tabButtons[name].BackgroundTransparency = (name == tabName) and 0 or 1
                tabButtons[name].BackgroundColor3 = (name == tabName) and NF_GROUP or Color3.fromRGB(0,0,0)
            end
        end
    end)
end

-- Вкладка Settings
local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0.9, 0, 0, 30)
settingsBtn.Position = UDim2.new(0.05, 0, 1, -36)
settingsBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
settingsBtn.BackgroundTransparency = 1
settingsBtn.Text = "  Settings"
settingsBtn.TextColor3 = NF_DARK_TEXT
settingsBtn.Font = Font_Code
settingsBtn.TextSize = 13
settingsBtn.TextXAlignment = Enum.TextXAlignment.Left
settingsBtn.Parent = sidebar

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 5)
settingsCorner.Parent = settingsBtn

local settingsFrame = Instance.new("ScrollingFrame")
settingsFrame.Size = UDim2.new(1, 0, 1, 0)
settingsFrame.BackgroundTransparency = 1
settingsFrame.BorderSizePixel = 0
settingsFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
settingsFrame.ScrollBarThickness = 4
settingsFrame.ScrollBarImageColor3 = NF_ACCENT
settingsFrame.Visible = false
settingsFrame.Parent = tabContainer

tabFrames["Settings"] = settingsFrame
tabButtons["Settings"] = settingsBtn

settingsBtn.MouseButton1Click:Connect(function()
    activeTab = "Settings"
    for name, tFrame in pairs(tabFrames) do
        tFrame.Visible = (name == "Settings")
        if tabButtons[name] then
            tabButtons[name].TextColor3 = (name == "Settings") and NF_ACCENT or NF_DARK_TEXT
            tabButtons[name].BackgroundTransparency = (name == "Settings") and 0 or 1
            tabButtons[name].BackgroundColor3 = (name == "Settings") and NF_GROUP or Color3.fromRGB(0,0,0)
        end
    end
end)

local themeableElements = {}

local function registerThemeElement(obj, role)
    table.insert(themeableElements, {object = obj, role = role})
end

local function updateUITheme(presetName)
    local preset = StylePresets[presetName] or StylePresets["Default"]
    Config.currentStylePreset = presetName
    activeStyle = preset

    NF_BG     = Config.customBgColor or preset.bg
    NF_PANEL  = Config.customPanelColor or preset.panel
    NF_GROUP  = preset.group
    NF_ACCENT = preset.accent
    NF_BORDER = preset.border
    NF_TEXT   = preset.text
    NF_DARK_TEXT = preset.darkText

    mainFrame.BackgroundColor3 = NF_BG
    mainStroke.Color = NF_BORDER
    topHeader.BackgroundColor3 = NF_PANEL
    sidebar.BackgroundColor3 = NF_PANEL
    headerText.Text = "| " .. preset.titleText
    headerText.TextColor3 = NF_DARK_TEXT
    glowLine.BackgroundColor3 = NF_ACCENT
    
    hudFrame.BackgroundColor3 = NF_BG
    hudStroke.Color = NF_BORDER
    hudHeader.BackgroundColor3 = NF_ACCENT
    speedTextLabel.TextColor3 = NF_ACCENT
    heightTextLabel.TextColor3 = NF_TEXT
    indicatorLabel.TextColor3 = NF_ACCENT
    wmStroke.Color = NF_ACCENT
    wmIcon.TextColor3 = NF_ACCENT

    kbMainFrame.BackgroundColor3 = NF_BG
    kbStroke.Color = NF_BORDER
    kbHeader.BackgroundColor3 = NF_PANEL
    kbHeaderGlow.BackgroundColor3 = NF_ACCENT
    kbHeaderTitle.TextColor3 = NF_TEXT

    for name, btn in pairs(tabButtons) do
        btn.Font = Font_Code
        btn.TextXAlignment = Enum.TextXAlignment.Left
        if name == activeTab then
            btn.TextColor3 = NF_ACCENT
            btn.BackgroundColor3 = NF_GROUP
        else
            btn.TextColor3 = NF_DARK_TEXT
        end
    end

    for _, frame in pairs(tabFrames) do
        frame.ScrollBarImageColor3 = NF_ACCENT
    end

    for _, entry in ipairs(themeableElements) do
        local obj = entry.object
        local role = entry.role
        if obj and obj.Parent then
            if role == "group" then
                obj.BackgroundColor3 = NF_GROUP
            elseif role == "groupStroke" then
                obj.Color = NF_BORDER
            elseif role == "title" then
                obj.TextColor3 = NF_TEXT
            elseif role == "label" then
                obj.TextColor3 = NF_DARK_TEXT
            elseif role == "accentText" then
                obj.TextColor3 = NF_ACCENT
            elseif role == "inputBox" then
                obj.BackgroundColor3 = NF_PANEL
                obj.TextColor3 = NF_ACCENT
            elseif role == "buttonPanel" then
                obj.BackgroundColor3 = NF_PANEL
                obj.TextColor3 = NF_ACCENT
            elseif role == "activeToggle" then
                if obj.Text == "ON" then
                    obj.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    obj.TextColor3 = NF_DARK_TEXT
                end
            elseif role == "activeToggleText" then
                if obj.Text == "ON" then
                    obj.TextColor3 = NF_ACCENT
                else
                    obj.TextColor3 = NF_DARK_TEXT
                end
            end
        end
    end
end

-- Сворачиваемые секции
local function setupCollapsibleSections(scrollingFrame, sections, initialTopPadding)
    local TOP_PADDING = initialTopPadding or 5
    local SECTION_GAP = 15
    local COLLAPSED_HEIGHT = 32

    local function relayoutSections()
        local currentY = TOP_PADDING
        for _, sec in ipairs(sections) do
            local group = sec.group
            group.Position = UDim2.new(0.02, 0, 0, currentY)
            local height = sec.collapsed and COLLAPSED_HEIGHT or sec.fullHeight
            currentY = currentY + height + SECTION_GAP
        end
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, currentY)
    end

    for _, sec in ipairs(sections) do
        local group = sec.group
        local title = sec.title
        sec.collapsed = false

        group.ClipsDescendants = true
        if title then title.Size = UDim2.new(1, -50, 0, 25) end

        local arrowButton = Instance.new("TextButton")
        arrowButton.Name = "CollapseArrow"
        arrowButton.Size = UDim2.new(0, 26, 0, 26)
        arrowButton.Position = UDim2.new(1, -34, 0, 3)
        arrowButton.BackgroundTransparency = 1
        arrowButton.Text = "∧"
        arrowButton.TextColor3 = NF_ORANGE
        arrowButton.Font = Font_Code
        arrowButton.TextSize = 16
        arrowButton.ZIndex = 10
        arrowButton.Parent = group

        local childElements = {}
        for _, child in ipairs(group:GetChildren()) do
            if child:IsA("GuiObject") and child ~= title and child ~= arrowButton then
                table.insert(childElements, child)
            end
        end

        local function toggleCollapse()
            sec.collapsed = not sec.collapsed
            arrowButton.Text = sec.collapsed and "∨" or "∧"
            for _, child in ipairs(childElements) do child.Visible = not sec.collapsed end
            group.Size = UDim2.new(group.Size.X.Scale, group.Size.X.Offset, 0, sec.collapsed and COLLAPSED_HEIGHT or sec.fullHeight)
            relayoutSections()
        end

        arrowButton.MouseButton1Click:Connect(toggleCollapse)
        if title then
            title.Active = true
            title.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggleCollapse()
                end
            end)
        end
    end

    relayoutSections()
end

-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ ВКЛАДОК
-- ==========================================
local UI_Binds = {
    manualDirBtn = nil,
    aaLeftBtn = nil, aaBackBtn = nil, aaRightBtn = nil, aaFrontBtn = nil, aaToggleBtnKey = nil,
    rageAABindBtnKey = nil, rageAABindModeBtn = nil,
    fakeLagBindBtnKey = nil, fakeLagBindModeBtn = nil,
    slideWalkKeyBtn = nil, slideWalkModeBtn = nil,
    airStuckKeyBtn = nil, airStuckModeBtn = nil,
    surfKeyBtn = nil, surfKeyModeBtn = nil, surfModeBtn = nil,
    waypointKeyBtn = nil, trashTalkKeyBtn = nil, menuToggleBtnKey = nil,
    aaToggleModeBtn = nil, trashTalkModeBtn = nil
}

-- 1. RAGE TAB
local function buildRageTab()
    local rageFrame = tabFrames["Rage"]
    local sections = {}

    -- BASE ANTI-AIM (YAW & PITCH)
    do
        local aaGroup = Instance.new("Frame")
        aaGroup.Size = UDim2.new(0.96, 0, 0, 520)
        aaGroup.BackgroundColor3 = NF_GROUP
        aaGroup.BorderSizePixel = 0
        aaGroup.Parent = rageFrame
        registerThemeElement(aaGroup, "group")

        Instance.new("UICorner", aaGroup).CornerRadius = UDim.new(0, 6)
        local aaGroupStroke = Instance.new("UIStroke")
        aaGroupStroke.Color = NF_BORDER
        aaGroupStroke.Thickness = 1
        aaGroupStroke.Parent = aaGroup
        registerThemeElement(aaGroupStroke, "groupStroke")

        local aaTitle = Instance.new("TextLabel")
        aaTitle.Size = UDim2.new(1, -20, 0, 25)
        aaTitle.Position = UDim2.new(0, 12, 0, 4)
        aaTitle.BackgroundTransparency = 1
        aaTitle.Text = "BASE ANTI-AIM (YAW & PITCH)"
        aaTitle.TextColor3 = NF_TEXT
        aaTitle.TextXAlignment = Enum.TextXAlignment.Left
        aaTitle.Font = Font_Code
        aaTitle.TextSize = 12
        aaTitle.Parent = aaGroup
        registerThemeElement(aaTitle, "title")

        local aaToggleLbl = Instance.new("TextLabel")
        aaToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        aaToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        aaToggleLbl.BackgroundTransparency = 1
        aaToggleLbl.Text = "Enable Anti-Aim"
        aaToggleLbl.TextColor3 = NF_DARK_TEXT
        aaToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        aaToggleLbl.Font = Font_Code
        aaToggleLbl.TextSize = 13
        aaToggleLbl.Parent = aaGroup
        registerThemeElement(aaToggleLbl, "label")

        aaToggleBtn = Instance.new("TextButton")
        aaToggleBtn.Size = UDim2.new(0, 110, 0, 26)
        aaToggleBtn.Position = UDim2.new(1, -122, 0, 35)
        aaToggleBtn.BackgroundColor3 = Config.aaEnabled and NF_ACCENT or NF_PANEL
        aaToggleBtn.TextColor3 = Config.aaEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        aaToggleBtn.Font = Font_Code
        aaToggleBtn.TextSize = 12
        aaToggleBtn.Text = Config.aaEnabled and "ON" or "OFF"
        aaToggleBtn.Parent = aaGroup
        Instance.new("UICorner", aaToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(aaToggleBtn, "activeToggle")

        aaToggleBtn.MouseButton1Click:Connect(function()
            Config.aaEnabled = not Config.aaEnabled
            aaToggleBtn.Text = Config.aaEnabled and "ON" or "OFF"
            aaToggleBtn.BackgroundColor3 = Config.aaEnabled and NF_ACCENT or NF_PANEL
            aaToggleBtn.TextColor3 = Config.aaEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            updateKeybindItem("Anti-Aim", Config.aaToggleKey.Name, Config.aaToggleKeyMode, Config.aaEnabled)
        end)

        local yawModeLbl = Instance.new("TextLabel")
        yawModeLbl.Size = UDim2.new(0, 150, 0, 25)
        yawModeLbl.Position = UDim2.new(0, 12, 0, 72)
        yawModeLbl.BackgroundTransparency = 1
        yawModeLbl.Text = "Yaw Mode"
        yawModeLbl.TextColor3 = NF_DARK_TEXT
        yawModeLbl.TextXAlignment = Enum.TextXAlignment.Left
        yawModeLbl.Font = Font_Code
        yawModeLbl.TextSize = 13
        yawModeLbl.Parent = aaGroup
        registerThemeElement(yawModeLbl, "label")

        local yawModeBtn = Instance.new("TextButton")
        yawModeBtn.Size = UDim2.new(0, 110, 0, 26)
        yawModeBtn.Position = UDim2.new(1, -122, 0, 72)
        yawModeBtn.BackgroundColor3 = NF_PANEL
        yawModeBtn.TextColor3 = NF_ACCENT
        yawModeBtn.Font = Font_Code
        yawModeBtn.TextSize = 12
        yawModeBtn.Text = Config.aaModes[Config.aaModeIndex]
        yawModeBtn.Parent = aaGroup
        Instance.new("UICorner", yawModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(yawModeBtn, "buttonPanel")

        yawModeBtn.MouseButton1Click:Connect(function()
            Config.aaModeIndex = Config.aaModeIndex % #Config.aaModes + 1
            yawModeBtn.Text = Config.aaModes[Config.aaModeIndex]
        end)

        local pitchModeLbl = Instance.new("TextLabel")
        pitchModeLbl.Size = UDim2.new(0, 150, 0, 25)
        pitchModeLbl.Position = UDim2.new(0, 12, 0, 108)
        pitchModeLbl.BackgroundTransparency = 1
        pitchModeLbl.Text = "Pitch Mode"
        pitchModeLbl.TextColor3 = NF_DARK_TEXT
        pitchModeLbl.TextXAlignment = Enum.TextXAlignment.Left
        pitchModeLbl.Font = Font_Code
        pitchModeLbl.TextSize = 13
        pitchModeLbl.Parent = aaGroup
        registerThemeElement(pitchModeLbl, "label")

        local pitchModeBtn = Instance.new("TextButton")
        pitchModeBtn.Size = UDim2.new(0, 110, 0, 26)
        pitchModeBtn.Position = UDim2.new(1, -122, 0, 108)
        pitchModeBtn.BackgroundColor3 = NF_PANEL
        pitchModeBtn.TextColor3 = NF_ACCENT
        pitchModeBtn.Font = Font_Code
        pitchModeBtn.TextSize = 12
        pitchModeBtn.Text = Config.aaPitchModes[Config.aaPitchIndex]
        pitchModeBtn.Parent = aaGroup
        Instance.new("UICorner", pitchModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(pitchModeBtn, "buttonPanel")

        pitchModeBtn.MouseButton1Click:Connect(function()
            Config.aaPitchIndex = Config.aaPitchIndex % #Config.aaPitchModes + 1
            pitchModeBtn.Text = Config.aaPitchModes[Config.aaPitchIndex]
        end)

        -- CUSTOM YAW / PITCH
        local customYawLbl = Instance.new("TextLabel")
        customYawLbl.Size = UDim2.new(0, 150, 0, 25)
        customYawLbl.Position = UDim2.new(0, 12, 0, 145)
        customYawLbl.BackgroundTransparency = 1
        customYawLbl.Text = "Custom Yaw (1-360)"
        customYawLbl.TextColor3 = NF_DARK_TEXT
        customYawLbl.TextXAlignment = Enum.TextXAlignment.Left
        customYawLbl.Font = Font_Code
        customYawLbl.TextSize = 13
        customYawLbl.Parent = aaGroup
        registerThemeElement(customYawLbl, "label")

        local customYawBox = Instance.new("TextBox")
        customYawBox.Size = UDim2.new(0, 70, 0, 26)
        customYawBox.Position = UDim2.new(1, -82, 0, 145)
        customYawBox.BackgroundColor3 = NF_PANEL
        customYawBox.TextColor3 = NF_ACCENT
        customYawBox.Font = Font_Code
        customYawBox.TextSize = 13
        customYawBox.Text = tostring(Config.aaYawOffset)
        customYawBox.Parent = aaGroup
        Instance.new("UICorner", customYawBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(customYawBox, "inputBox")

        customYawBox.FocusLost:Connect(function()
            local val = tonumber(customYawBox.Text)
            if val then Config.aaYawOffset = math.clamp(val, 1, 360) customYawBox.Text = tostring(Config.aaYawOffset) else customYawBox.Text = tostring(Config.aaYawOffset) end
        end)

        local customPitchLbl = Instance.new("TextLabel")
        customPitchLbl.Size = UDim2.new(0, 150, 0, 25)
        customPitchLbl.Position = UDim2.new(0, 12, 0, 182)
        customPitchLbl.BackgroundTransparency = 1
        customPitchLbl.Text = "Custom Pitch (1-360)"
        customPitchLbl.TextColor3 = NF_DARK_TEXT
        customPitchLbl.TextXAlignment = Enum.TextXAlignment.Left
        customPitchLbl.Font = Font_Code
        customPitchLbl.TextSize = 13
        customPitchLbl.Parent = aaGroup
        registerThemeElement(customPitchLbl, "label")

        local customPitchBox = Instance.new("TextBox")
        customPitchBox.Size = UDim2.new(0, 70, 0, 26)
        customPitchBox.Position = UDim2.new(1, -82, 0, 182)
        customPitchBox.BackgroundColor3 = NF_PANEL
        customPitchBox.TextColor3 = NF_ACCENT
        customPitchBox.Font = Font_Code
        customPitchBox.TextSize = 13
        customPitchBox.Text = tostring(Config.aaPitchOffset)
        customPitchBox.Parent = aaGroup
        Instance.new("UICorner", customPitchBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(customPitchBox, "inputBox")

        customPitchBox.FocusLost:Connect(function()
            local val = tonumber(customPitchBox.Text)
            if val then Config.aaPitchOffset = math.clamp(val, 1, 360) customPitchBox.Text = tostring(Config.aaPitchOffset) else customPitchBox.Text = tostring(Config.aaPitchOffset) end
        end)

        local pitchSpeedLbl = Instance.new("TextLabel")
        pitchSpeedLbl.Size = UDim2.new(0, 150, 0, 25)
        pitchSpeedLbl.Position = UDim2.new(0, 12, 0, 219)
        pitchSpeedLbl.BackgroundTransparency = 1
        pitchSpeedLbl.Text = "Pitch Swap Speed (Hz)"
        pitchSpeedLbl.TextColor3 = NF_DARK_TEXT
        pitchSpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
        pitchSpeedLbl.Font = Font_Code
        pitchSpeedLbl.TextSize = 13
        pitchSpeedLbl.Parent = aaGroup
        registerThemeElement(pitchSpeedLbl, "label")

        local pitchSpeedBox = Instance.new("TextBox")
        pitchSpeedBox.Size = UDim2.new(0, 70, 0, 26)
        pitchSpeedBox.Position = UDim2.new(1, -82, 0, 219)
        pitchSpeedBox.BackgroundColor3 = NF_PANEL
        pitchSpeedBox.TextColor3 = NF_ACCENT
        pitchSpeedBox.Font = Font_Code
        pitchSpeedBox.TextSize = 13
        pitchSpeedBox.Text = tostring(Config.pitchChangeSpeed)
        pitchSpeedBox.Parent = aaGroup
        Instance.new("UICorner", pitchSpeedBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(pitchSpeedBox, "inputBox")

        pitchSpeedBox.FocusLost:Connect(function()
            local val = tonumber(pitchSpeedBox.Text)
            if val then Config.pitchChangeSpeed = math.max(0.1, val) pitchSpeedBox.Text = tostring(Config.pitchChangeSpeed) else pitchSpeedBox.Text = tostring(Config.pitchChangeSpeed) end
        end)

        local manualDirLbl = Instance.new("TextLabel")
        manualDirLbl.Size = UDim2.new(0, 150, 0, 25)
        manualDirLbl.Position = UDim2.new(0, 12, 0, 256)
        manualDirLbl.BackgroundTransparency = 1
        manualDirLbl.Text = "Manual Direction"
        manualDirLbl.TextColor3 = NF_DARK_TEXT
        manualDirLbl.TextXAlignment = Enum.TextXAlignment.Left
        manualDirLbl.Font = Font_Code
        manualDirLbl.TextSize = 13
        manualDirLbl.Parent = aaGroup
        registerThemeElement(manualDirLbl, "label")

        UI_Binds.manualDirBtn = Instance.new("TextButton")
        UI_Binds.manualDirBtn.Size = UDim2.new(0, 110, 0, 26)
        UI_Binds.manualDirBtn.Position = UDim2.new(1, -122, 0, 256)
        UI_Binds.manualDirBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.manualDirBtn.TextColor3 = NF_ACCENT
        UI_Binds.manualDirBtn.Font = Font_Code
        UI_Binds.manualDirBtn.TextSize = 12
        UI_Binds.manualDirBtn.Text = Config.aaManualDirs[Config.aaManualDirIndex]
        UI_Binds.manualDirBtn.Parent = aaGroup
        Instance.new("UICorner", UI_Binds.manualDirBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.manualDirBtn, "buttonPanel")

        UI_Binds.manualDirBtn.MouseButton1Click:Connect(function()
            Config.aaManualDirIndex = Config.aaManualDirIndex % #Config.aaManualDirs + 1
            UI_Binds.manualDirBtn.Text = Config.aaManualDirs[Config.aaManualDirIndex]
        end)

        local function createKeybindRow(labelText, defaultKeyName, defaultMode, posY, onKeyBindClick, onModeToggleClick)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 130, 0, 25)
            lbl.Position = UDim2.new(0, 12, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = NF_DARK_TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Font_Code
            lbl.TextSize = 13
            lbl.Parent = aaGroup
            registerThemeElement(lbl, "label")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 85, 0, 26)
            btn.Position = UDim2.new(1, -195, 0, posY)
            btn.BackgroundColor3 = NF_PANEL
            btn.TextColor3 = NF_ACCENT
            btn.Font = Font_Code
            btn.TextSize = 11
            btn.Text = "[" .. defaultKeyName .. "]"
            btn.Parent = aaGroup
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(btn, "buttonPanel")

            local modeBtn = Instance.new("TextButton")
            modeBtn.Size = UDim2.new(0, 70, 0, 26)
            modeBtn.Position = UDim2.new(1, -102, 0, posY)
            modeBtn.BackgroundColor3 = NF_PANEL
            modeBtn.TextColor3 = NF_ORANGE
            modeBtn.Font = Font_Code
            modeBtn.TextSize = 11
            modeBtn.Text = defaultMode
            modeBtn.Parent = aaGroup
            Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(modeBtn, "buttonPanel")

            btn.MouseButton1Click:Connect(function()
                btn.Text = "[ press... ]"
                onKeyBindClick()
            end)

            modeBtn.MouseButton1Click:Connect(function()
                onModeToggleClick(modeBtn)
            end)

            return btn, modeBtn
        end

        UI_Binds.aaToggleBtnKey, UI_Binds.aaToggleModeBtn = createKeybindRow("AA Toggle Bind", Config.aaToggleKey.Name, Config.aaToggleKeyMode, 293, 
            function() Config.bindingAAToggleKey = true end, 
            function(btn)
                Config.aaToggleKeyMode = (Config.aaToggleKeyMode == "Toggle") and "Hold" or "Toggle"
                btn.Text = Config.aaToggleKeyMode
            end
        )

        local function createSimpleKeybindRow(labelText, defaultKeyName, posY, onClick)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 180, 0, 25)
            lbl.Position = UDim2.new(0, 12, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = NF_DARK_TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Font_Code
            lbl.TextSize = 13
            lbl.Parent = aaGroup
            registerThemeElement(lbl, "label")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 110, 0, 26)
            btn.Position = UDim2.new(1, -122, 0, posY)
            btn.BackgroundColor3 = NF_PANEL
            btn.TextColor3 = NF_ACCENT
            btn.Font = Font_Code
            btn.TextSize = 12
            btn.Text = "[" .. defaultKeyName .. "]"
            btn.Parent = aaGroup
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(btn, "buttonPanel")

            btn.MouseButton1Click:Connect(function()
                btn.Text = "[ press... ]"
                onClick()
            end)
            return btn
        end

        UI_Binds.aaLeftBtn  = createSimpleKeybindRow("Manual Left Key", Config.aaKeyLeft.Name, 330, function() Config.bindingAAKeyLeft = true end)
        UI_Binds.aaBackBtn  = createSimpleKeybindRow("Manual Back Key", Config.aaKeyBack.Name, 367, function() Config.bindingAAKeyBack = true end)
        UI_Binds.aaRightBtn = createSimpleKeybindRow("Manual Right Key", Config.aaKeyRight.Name, 404, function() Config.bindingAAKeyRight = true end)
        UI_Binds.aaFrontBtn = createSimpleKeybindRow("Manual Front Key", Config.aaKeyFront.Name, 441, function() Config.bindingAAKeyFront = true end)

        table.insert(sections, {group = aaGroup, title = aaTitle, fullHeight = 520})
    end

    -- RAGE JITTER (DESYNC)
    do
        local rageAAGroup = Instance.new("Frame")
        rageAAGroup.Size = UDim2.new(0.96, 0, 0, 350)
        rageAAGroup.BackgroundColor3 = NF_GROUP
        rageAAGroup.BorderSizePixel = 0
        rageAAGroup.Parent = rageFrame
        registerThemeElement(rageAAGroup, "group")

        Instance.new("UICorner", rageAAGroup).CornerRadius = UDim.new(0, 6)
        local rageAAGroupStroke = Instance.new("UIStroke")
        rageAAGroupStroke.Color = NF_BORDER
        rageAAGroupStroke.Thickness = 1
        rageAAGroupStroke.Parent = rageAAGroup
        registerThemeElement(rageAAGroupStroke, "groupStroke")

        local rageAATitle = Instance.new("TextLabel")
        rageAATitle.Size = UDim2.new(1, -20, 0, 25)
        rageAATitle.Position = UDim2.new(0, 12, 0, 4)
        rageAATitle.BackgroundTransparency = 1
        rageAATitle.Text = "RAGE JITTER (DESYNC)"
        rageAATitle.TextColor3 = NF_TEXT
        rageAATitle.TextXAlignment = Enum.TextXAlignment.Left
        rageAATitle.Font = Font_Code
        rageAATitle.TextSize = 12
        rageAATitle.Parent = rageAAGroup
        registerThemeElement(rageAATitle, "title")

        local rageAAToggleLbl = Instance.new("TextLabel")
        rageAAToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        rageAAToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        rageAAToggleLbl.BackgroundTransparency = 1
        rageAAToggleLbl.Text = "Enable Jitter"
        rageAAToggleLbl.TextColor3 = NF_DARK_TEXT
        rageAAToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        rageAAToggleLbl.Font = Font_Code
        rageAAToggleLbl.TextSize = 13
        rageAAToggleLbl.Parent = rageAAGroup
        registerThemeElement(rageAAToggleLbl, "label")

        rageAAToggleBtnGlobal = Instance.new("TextButton")
        rageAAToggleBtnGlobal.Size = UDim2.new(0, 110, 0, 26)
        rageAAToggleBtnGlobal.Position = UDim2.new(1, -122, 0, 35)
        rageAAToggleBtnGlobal.BackgroundColor3 = Config.rageAAEnabled and NF_ACCENT or NF_PANEL
        rageAAToggleBtnGlobal.TextColor3 = Config.rageAAEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        rageAAToggleBtnGlobal.Font = Font_Code
        rageAAToggleBtnGlobal.TextSize = 12
        rageAAToggleBtnGlobal.Text = Config.rageAAEnabled and "ON" or "OFF"
        rageAAToggleBtnGlobal.Parent = rageAAGroup
        Instance.new("UICorner", rageAAToggleBtnGlobal).CornerRadius = UDim.new(0, 4)
        registerThemeElement(rageAAToggleBtnGlobal, "activeToggle")

        rageAAToggleBtnGlobal.MouseButton1Click:Connect(function()
            Config.rageAAEnabled = not Config.rageAAEnabled
            rageAAToggleBtnGlobal.Text = Config.rageAAEnabled and "ON" or "OFF"
            rageAAToggleBtnGlobal.BackgroundColor3 = Config.rageAAEnabled and NF_ACCENT or NF_PANEL
            rageAAToggleBtnGlobal.TextColor3 = Config.rageAAEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            updateKeybindItem("Rage Jitter", Config.rageAABindKey.Name, Config.rageAABindMode, Config.rageAAEnabled)
        end)

        -- Rage AA Keybind Row
        local rageBindLbl = Instance.new("TextLabel")
        rageBindLbl.Size = UDim2.new(0, 130, 0, 25)
        rageBindLbl.Position = UDim2.new(0, 12, 0, 70)
        rageBindLbl.BackgroundTransparency = 1
        rageBindLbl.Text = "Jitter Keybind"
        rageBindLbl.TextColor3 = NF_DARK_TEXT
        rageBindLbl.TextXAlignment = Enum.TextXAlignment.Left
        rageBindLbl.Font = Font_Code
        rageBindLbl.TextSize = 13
        rageBindLbl.Parent = rageAAGroup
        registerThemeElement(rageBindLbl, "label")

        UI_Binds.rageAABindBtnKey = Instance.new("TextButton")
        UI_Binds.rageAABindBtnKey.Size = UDim2.new(0, 85, 0, 26)
        UI_Binds.rageAABindBtnKey.Position = UDim2.new(1, -195, 0, 70)
        UI_Binds.rageAABindBtnKey.BackgroundColor3 = NF_PANEL
        UI_Binds.rageAABindBtnKey.TextColor3 = NF_ACCENT
        UI_Binds.rageAABindBtnKey.Font = Font_Code
        UI_Binds.rageAABindBtnKey.TextSize = 11
        UI_Binds.rageAABindBtnKey.Text = "[" .. Config.rageAABindKey.Name .. "]"
        UI_Binds.rageAABindBtnKey.Parent = rageAAGroup
        Instance.new("UICorner", UI_Binds.rageAABindBtnKey).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.rageAABindBtnKey, "buttonPanel")

        UI_Binds.rageAABindModeBtn = Instance.new("TextButton")
        UI_Binds.rageAABindModeBtn.Size = UDim2.new(0, 70, 0, 26)
        UI_Binds.rageAABindModeBtn.Position = UDim2.new(1, -102, 0, 70)
        UI_Binds.rageAABindModeBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.rageAABindModeBtn.TextColor3 = NF_ORANGE
        UI_Binds.rageAABindModeBtn.Font = Font_Code
        UI_Binds.rageAABindModeBtn.TextSize = 11
        UI_Binds.rageAABindModeBtn.Text = Config.rageAABindMode
        UI_Binds.rageAABindModeBtn.Parent = rageAAGroup
        Instance.new("UICorner", UI_Binds.rageAABindModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.rageAABindModeBtn, "buttonPanel")

        UI_Binds.rageAABindBtnKey.MouseButton1Click:Connect(function()
            UI_Binds.rageAABindBtnKey.Text = "[ press... ]"
            Config.bindingRageAABindKey = true
        end)

        UI_Binds.rageAABindModeBtn.MouseButton1Click:Connect(function()
            Config.rageAABindMode = (Config.rageAABindMode == "Toggle") and "Hold" or "Toggle"
            UI_Binds.rageAABindModeBtn.Text = Config.rageAABindMode
        end)

        local rageAngleLbl = Instance.new("TextLabel")
        rageAngleLbl.Size = UDim2.new(0, 150, 0, 25)
        rageAngleLbl.Position = UDim2.new(0, 12, 0, 105)
        rageAngleLbl.BackgroundTransparency = 1
        rageAngleLbl.Text = "Jitter Angle (°)"
        rageAngleLbl.TextColor3 = NF_DARK_TEXT
        rageAngleLbl.TextXAlignment = Enum.TextXAlignment.Left
        rageAngleLbl.Font = Font_Code
        rageAngleLbl.TextSize = 13
        rageAngleLbl.Parent = rageAAGroup
        registerThemeElement(rageAngleLbl, "label")

        local rageAngleBox = Instance.new("TextBox")
        rageAngleBox.Size = UDim2.new(0, 70, 0, 26)
        rageAngleBox.Position = UDim2.new(1, -82, 0, 105)
        rageAngleBox.BackgroundColor3 = NF_PANEL
        rageAngleBox.TextColor3 = NF_ACCENT
        rageAngleBox.Font = Font_Code
        rageAngleBox.TextSize = 13
        rageAngleBox.Text = tostring(Config.rageAAAngle)
        rageAngleBox.Parent = rageAAGroup
        Instance.new("UICorner", rageAngleBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(rageAngleBox, "inputBox")

        rageAngleBox.FocusLost:Connect(function()
            local val = tonumber(rageAngleBox.Text)
            if val then Config.rageAAAngle = val else rageAngleBox.Text = tostring(Config.rageAAAngle) end
        end)

        local rageSpeedLbl = Instance.new("TextLabel")
        rageSpeedLbl.Size = UDim2.new(0, 150, 0, 25)
        rageSpeedLbl.Position = UDim2.new(0, 12, 0, 140)
        rageSpeedLbl.BackgroundTransparency = 1
        rageSpeedLbl.Text = "Jitter Rate / Speed (Hz)"
        rageSpeedLbl.TextColor3 = NF_DARK_TEXT
        rageSpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
        rageSpeedLbl.Font = Font_Code
        rageSpeedLbl.TextSize = 13
        rageSpeedLbl.Parent = rageAAGroup
        registerThemeElement(rageSpeedLbl, "label")

        local rageSpeedBox = Instance.new("TextBox")
        rageSpeedBox.Size = UDim2.new(0, 70, 0, 26)
        rageSpeedBox.Position = UDim2.new(1, -82, 0, 140)
        rageSpeedBox.BackgroundColor3 = NF_PANEL
        rageSpeedBox.TextColor3 = NF_ACCENT
        rageSpeedBox.Font = Font_Code
        rageSpeedBox.TextSize = 13
        rageSpeedBox.Text = tostring(Config.rageAASpeed)
        rageSpeedBox.Parent = rageAAGroup
        Instance.new("UICorner", rageSpeedBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(rageSpeedBox, "inputBox")

        rageSpeedBox.FocusLost:Connect(function()
            local val = tonumber(rageSpeedBox.Text)
            if val and val > 0 then
                Config.rageAASpeed = val
                Config.rageAADelay = 1 / val
            else
                rageSpeedBox.Text = tostring(Config.rageAASpeed)
            end
        end)

        local randSpeedLbl = Instance.new("TextLabel")
        randSpeedLbl.Size = UDim2.new(0, 150, 0, 25)
        randSpeedLbl.Position = UDim2.new(0, 12, 0, 175)
        randSpeedLbl.BackgroundTransparency = 1
        randSpeedLbl.Text = "Random Jitter Speed"
        randSpeedLbl.TextColor3 = NF_DARK_TEXT
        randSpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
        randSpeedLbl.Font = Font_Code
        randSpeedLbl.TextSize = 13
        randSpeedLbl.Parent = rageAAGroup
        registerThemeElement(randSpeedLbl, "label")

        local randSpeedBtn = Instance.new("TextButton")
        randSpeedBtn.Size = UDim2.new(0, 110, 0, 26)
        randSpeedBtn.Position = UDim2.new(1, -122, 0, 175)
        randSpeedBtn.BackgroundColor3 = Config.rageRandomSpeedEnabled and NF_ACCENT or NF_PANEL
        randSpeedBtn.TextColor3 = Config.rageRandomSpeedEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        randSpeedBtn.Font = Font_Code
        randSpeedBtn.TextSize = 12
        randSpeedBtn.Text = Config.rageRandomSpeedEnabled and "ON" or "OFF"
        randSpeedBtn.Parent = rageAAGroup
        Instance.new("UICorner", randSpeedBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(randSpeedBtn, "activeToggle")

        randSpeedBtn.MouseButton1Click:Connect(function()
            Config.rageRandomSpeedEnabled = not Config.rageRandomSpeedEnabled
            randSpeedBtn.Text = Config.rageRandomSpeedEnabled and "ON" or "OFF"
            randSpeedBtn.BackgroundColor3 = Config.rageRandomSpeedEnabled and NF_ACCENT or NF_PANEL
            randSpeedBtn.TextColor3 = Config.rageRandomSpeedEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        table.insert(sections, {group = rageAAGroup, title = rageAATitle, fullHeight = 350})
    end

    -- FAKE LAG (DESYNC SPEED)
    do
        local fakeLagGroup = Instance.new("Frame")
        fakeLagGroup.Size = UDim2.new(0.96, 0, 0, 215)
        fakeLagGroup.BackgroundColor3 = NF_GROUP
        fakeLagGroup.BorderSizePixel = 0
        fakeLagGroup.Parent = rageFrame
        registerThemeElement(fakeLagGroup, "group")

        Instance.new("UICorner", fakeLagGroup).CornerRadius = UDim.new(0, 6)
        local fakeLagStroke = Instance.new("UIStroke")
        fakeLagStroke.Color = NF_BORDER
        fakeLagStroke.Thickness = 1
        fakeLagStroke.Parent = fakeLagGroup
        registerThemeElement(fakeLagStroke, "groupStroke")

        local fakeLagTitle = Instance.new("TextLabel")
        fakeLagTitle.Size = UDim2.new(1, -20, 0, 25)
        fakeLagTitle.Position = UDim2.new(0, 12, 0, 4)
        fakeLagTitle.BackgroundTransparency = 1
        fakeLagTitle.Text = "FAKE LAG (DESYNC SPEED)"
        fakeLagTitle.TextColor3 = NF_TEXT
        fakeLagTitle.TextXAlignment = Enum.TextXAlignment.Left
        fakeLagTitle.Font = Font_Code
        fakeLagTitle.TextSize = 12
        fakeLagTitle.Parent = fakeLagGroup
        registerThemeElement(fakeLagTitle, "title")

        local flToggleLbl = Instance.new("TextLabel")
        flToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        flToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        flToggleLbl.BackgroundTransparency = 1
        flToggleLbl.Text = "Enable Fake Lag"
        flToggleLbl.TextColor3 = NF_DARK_TEXT
        flToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        flToggleLbl.Font = Font_Code
        flToggleLbl.TextSize = 13
        flToggleLbl.Parent = fakeLagGroup
        registerThemeElement(flToggleLbl, "label")

        fakeLagToggleBtnGlobal = Instance.new("TextButton")
        fakeLagToggleBtnGlobal.Size = UDim2.new(0, 110, 0, 26)
        fakeLagToggleBtnGlobal.Position = UDim2.new(1, -122, 0, 35)
        fakeLagToggleBtnGlobal.BackgroundColor3 = Config.fakeLagEnabled and NF_ACCENT or NF_PANEL
        fakeLagToggleBtnGlobal.TextColor3 = Config.fakeLagEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        fakeLagToggleBtnGlobal.Font = Font_Code
        fakeLagToggleBtnGlobal.TextSize = 12
        fakeLagToggleBtnGlobal.Text = Config.fakeLagEnabled and "ON" or "OFF"
        fakeLagToggleBtnGlobal.Parent = fakeLagGroup
        Instance.new("UICorner", fakeLagToggleBtnGlobal).CornerRadius = UDim.new(0, 4)
        registerThemeElement(fakeLagToggleBtnGlobal, "activeToggle")

        fakeLagToggleBtnGlobal.MouseButton1Click:Connect(function()
            Config.fakeLagEnabled = not Config.fakeLagEnabled
            fakeLagToggleBtnGlobal.Text = Config.fakeLagEnabled and "ON" or "OFF"
            fakeLagToggleBtnGlobal.BackgroundColor3 = Config.fakeLagEnabled and NF_ACCENT or NF_PANEL
            fakeLagToggleBtnGlobal.TextColor3 = Config.fakeLagEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            updateKeybindItem("Fake Lag", Config.fakeLagBindKey.Name, Config.fakeLagBindMode, Config.fakeLagEnabled)
        end)

        -- Fake Lag Keybind
        local flBindLbl = Instance.new("TextLabel")
        flBindLbl.Size = UDim2.new(0, 130, 0, 25)
        flBindLbl.Position = UDim2.new(0, 12, 0, 70)
        flBindLbl.BackgroundTransparency = 1
        flBindLbl.Text = "FakeLag Keybind"
        flBindLbl.TextColor3 = NF_DARK_TEXT
        flBindLbl.TextXAlignment = Enum.TextXAlignment.Left
        flBindLbl.Font = Font_Code
        flBindLbl.TextSize = 13
        flBindLbl.Parent = fakeLagGroup
        registerThemeElement(flBindLbl, "label")

        UI_Binds.fakeLagBindBtnKey = Instance.new("TextButton")
        UI_Binds.fakeLagBindBtnKey.Size = UDim2.new(0, 85, 0, 26)
        UI_Binds.fakeLagBindBtnKey.Position = UDim2.new(1, -195, 0, 70)
        UI_Binds.fakeLagBindBtnKey.BackgroundColor3 = NF_PANEL
        UI_Binds.fakeLagBindBtnKey.TextColor3 = NF_ACCENT
        UI_Binds.fakeLagBindBtnKey.Font = Font_Code
        UI_Binds.fakeLagBindBtnKey.TextSize = 11
        UI_Binds.fakeLagBindBtnKey.Text = "[" .. Config.fakeLagBindKey.Name .. "]"
        UI_Binds.fakeLagBindBtnKey.Parent = fakeLagGroup
        Instance.new("UICorner", UI_Binds.fakeLagBindBtnKey).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.fakeLagBindBtnKey, "buttonPanel")

        UI_Binds.fakeLagBindModeBtn = Instance.new("TextButton")
        UI_Binds.fakeLagBindModeBtn.Size = UDim2.new(0, 70, 0, 26)
        UI_Binds.fakeLagBindModeBtn.Position = UDim2.new(1, -102, 0, 70)
        UI_Binds.fakeLagBindModeBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.fakeLagBindModeBtn.TextColor3 = NF_ORANGE
        UI_Binds.fakeLagBindModeBtn.Font = Font_Code
        UI_Binds.fakeLagBindModeBtn.TextSize = 11
        UI_Binds.fakeLagBindModeBtn.Text = Config.fakeLagBindMode
        UI_Binds.fakeLagBindModeBtn.Parent = fakeLagGroup
        Instance.new("UICorner", UI_Binds.fakeLagBindModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.fakeLagBindModeBtn, "buttonPanel")

        UI_Binds.fakeLagBindBtnKey.MouseButton1Click:Connect(function()
            UI_Binds.fakeLagBindBtnKey.Text = "[ press... ]"
            Config.bindingFakeLagBindKey = true
        end)

        UI_Binds.fakeLagBindModeBtn.MouseButton1Click:Connect(function()
            Config.fakeLagBindMode = (Config.fakeLagBindMode == "Toggle") and "Hold" or "Toggle"
            UI_Binds.fakeLagBindModeBtn.Text = Config.fakeLagBindMode
        end)

        local flLimitLbl = Instance.new("TextLabel")
        flLimitLbl.Size = UDim2.new(0, 150, 0, 25)
        flLimitLbl.Position = UDim2.new(0, 12, 0, 105)
        flLimitLbl.BackgroundTransparency = 1
        flLimitLbl.Text = "Choke Limit (Ticks)"
        flLimitLbl.TextColor3 = NF_DARK_TEXT
        flLimitLbl.TextXAlignment = Enum.TextXAlignment.Left
        flLimitLbl.Font = Font_Code
        flLimitLbl.TextSize = 13
        flLimitLbl.Parent = fakeLagGroup
        registerThemeElement(flLimitLbl, "label")

        local flLimitBox = Instance.new("TextBox")
        flLimitBox.Size = UDim2.new(0, 70, 0, 26)
        flLimitBox.Position = UDim2.new(1, -82, 0, 105)
        flLimitBox.BackgroundColor3 = NF_PANEL
        flLimitBox.TextColor3 = NF_ACCENT
        flLimitBox.Font = Font_Code
        flLimitBox.TextSize = 13
        flLimitBox.Text = tostring(Config.fakeLagLimit)
        flLimitBox.Parent = fakeLagGroup
        Instance.new("UICorner", flLimitBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(flLimitBox, "inputBox")

        flLimitBox.FocusLost:Connect(function()
            local val = tonumber(flLimitBox.Text)
            if val and val >= 1 then Config.fakeLagLimit = math.clamp(math.floor(val), 1, 30) else flLimitBox.Text = tostring(Config.fakeLagLimit) end
        end)

        local flModeLbl = Instance.new("TextLabel")
        flModeLbl.Size = UDim2.new(0, 150, 0, 25)
        flModeLbl.Position = UDim2.new(0, 12, 0, 140)
        flModeLbl.BackgroundTransparency = 1
        flModeLbl.Text = "Lag Mode"
        flModeLbl.TextColor3 = NF_DARK_TEXT
        flModeLbl.TextXAlignment = Enum.TextXAlignment.Left
        flModeLbl.Font = Font_Code
        flModeLbl.TextSize = 13
        flModeLbl.Parent = fakeLagGroup
        registerThemeElement(flModeLbl, "label")

        local flModeBtn = Instance.new("TextButton")
        flModeBtn.Size = UDim2.new(0, 110, 0, 26)
        flModeBtn.Position = UDim2.new(1, -122, 0, 140)
        flModeBtn.BackgroundColor3 = NF_PANEL
        flModeBtn.TextColor3 = NF_ACCENT
        flModeBtn.Font = Font_Code
        flModeBtn.TextSize = 12
        flModeBtn.Text = Config.fakeLagModes[Config.fakeLagModeIndex]
        flModeBtn.Parent = fakeLagGroup
        Instance.new("UICorner", flModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(flModeBtn, "buttonPanel")

        flModeBtn.MouseButton1Click:Connect(function()
            Config.fakeLagModeIndex = Config.fakeLagModeIndex % #Config.fakeLagModes + 1
            flModeBtn.Text = Config.fakeLagModes[Config.fakeLagModeIndex]
        end)

        table.insert(sections, {group = fakeLagGroup, title = fakeLagTitle, fullHeight = 215})
    end

    setupCollapsibleSections(rageFrame, sections)
end

-- 2. LEGIT TAB
local function buildLegitTab()
    local legitFrame = tabFrames["Legit"]
    local sections = {}

    do
        local aimGroup = Instance.new("Frame")
        aimGroup.Size = UDim2.new(0.96, 0, 0, 220)
        aimGroup.BackgroundColor3 = NF_GROUP
        aimGroup.BorderSizePixel = 0
        aimGroup.Parent = legitFrame
        registerThemeElement(aimGroup, "group")

        Instance.new("UICorner", aimGroup).CornerRadius = UDim.new(0, 6)
        local aimGroupStroke = Instance.new("UIStroke")
        aimGroupStroke.Color = NF_BORDER
        aimGroupStroke.Thickness = 1
        aimGroupStroke.Parent = aimGroup
        registerThemeElement(aimGroupStroke, "groupStroke")

        local aimTitle = Instance.new("TextLabel")
        aimTitle.Size = UDim2.new(1, -20, 0, 25)
        aimTitle.Position = UDim2.new(0, 12, 0, 4)
        aimTitle.BackgroundTransparency = 1
        aimTitle.Text = "LEGIT AIM ASSIST (RMB)"
        aimTitle.TextColor3 = NF_TEXT
        aimTitle.TextXAlignment = Enum.TextXAlignment.Left
        aimTitle.Font = Font_Code
        aimTitle.TextSize = 12
        aimTitle.Parent = aimGroup
        registerThemeElement(aimTitle, "title")

        local aimToggleLbl = Instance.new("TextLabel")
        aimToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        aimToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        aimToggleLbl.BackgroundTransparency = 1
        aimToggleLbl.Text = "Enable Legit Aim"
        aimToggleLbl.TextColor3 = NF_DARK_TEXT
        aimToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        aimToggleLbl.Font = Font_Code
        aimToggleLbl.TextSize = 13
        aimToggleLbl.Parent = aimGroup
        registerThemeElement(aimToggleLbl, "label")

        local aimToggleBtn = Instance.new("TextButton")
        aimToggleBtn.Size = UDim2.new(0, 110, 0, 26)
        aimToggleBtn.Position = UDim2.new(1, -122, 0, 35)
        aimToggleBtn.BackgroundColor3 = (Config.aimbotEnabled) and NF_ACCENT or NF_PANEL
        aimToggleBtn.TextColor3 = (Config.aimbotEnabled) and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        aimToggleBtn.Font = Font_Code
        aimToggleBtn.TextSize = 12
        aimToggleBtn.Text = (Config.aimbotEnabled) and "ON" or "OFF"
        aimToggleBtn.Parent = aimGroup
        Instance.new("UICorner", aimToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(aimToggleBtn, "activeToggle")

        aimToggleBtn.MouseButton1Click:Connect(function()
            Config.aimbotEnabled = not Config.aimbotEnabled
            aimToggleBtn.Text = Config.aimbotEnabled and "ON" or "OFF"
            aimToggleBtn.BackgroundColor3 = Config.aimbotEnabled and NF_ACCENT or NF_PANEL
            aimToggleBtn.TextColor3 = Config.aimbotEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        local fovSizeLbl = Instance.new("TextLabel")
        fovSizeLbl.Size = UDim2.new(0, 150, 0, 25)
        fovSizeLbl.Position = UDim2.new(0, 12, 0, 72)
        fovSizeLbl.BackgroundTransparency = 1
        fovSizeLbl.Text = "Aim FOV Size"
        fovSizeLbl.TextColor3 = NF_DARK_TEXT
        fovSizeLbl.TextXAlignment = Enum.TextXAlignment.Left
        fovSizeLbl.Font = Font_Code
        fovSizeLbl.TextSize = 13
        fovSizeLbl.Parent = aimGroup
        registerThemeElement(fovSizeLbl, "label")

        local fovSizeBox = Instance.new("TextBox")
        fovSizeBox.Size = UDim2.new(0, 70, 0, 26)
        fovSizeBox.Position = UDim2.new(1, -82, 0, 72)
        fovSizeBox.BackgroundColor3 = NF_PANEL
        fovSizeBox.TextColor3 = NF_ACCENT
        fovSizeBox.Font = Font_Code
        fovSizeBox.TextSize = 13
        fovSizeBox.Text = tostring(Config.aimbotFov)
        fovSizeBox.Parent = aimGroup
        Instance.new("UICorner", fovSizeBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(fovSizeBox, "inputBox")

        fovSizeBox.FocusLost:Connect(function()
            local val = tonumber(fovSizeBox.Text)
            if val then Config.aimbotFov = val else fovSizeBox.Text = tostring(Config.aimbotFov) end
        end)

        local smoothLbl = Instance.new("TextLabel")
        smoothLbl.Size = UDim2.new(0, 150, 0, 25)
        smoothLbl.Position = UDim2.new(0, 12, 0, 108)
        smoothLbl.BackgroundTransparency = 1
        smoothLbl.Text = "Aim Smoothness"
        smoothLbl.TextColor3 = NF_DARK_TEXT
        smoothLbl.TextXAlignment = Enum.TextXAlignment.Left
        smoothLbl.Font = Font_Code
        smoothLbl.TextSize = 13
        smoothLbl.Parent = aimGroup
        registerThemeElement(smoothLbl, "label")

        local smoothBox = Instance.new("TextBox")
        smoothBox.Size = UDim2.new(0, 70, 0, 26)
        smoothBox.Position = UDim2.new(1, -82, 0, 108)
        smoothBox.BackgroundColor3 = NF_PANEL
        smoothBox.TextColor3 = NF_ACCENT
        smoothBox.Font = Font_Code
        smoothBox.TextSize = 13
        smoothBox.Text = tostring(Config.aimbotSmoothness)
        smoothBox.Parent = aimGroup
        Instance.new("UICorner", smoothBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(smoothBox, "inputBox")

        smoothBox.FocusLost:Connect(function()
            local val = tonumber(smoothBox.Text)
            if val then Config.aimbotSmoothness = val else smoothBox.Text = tostring(Config.aimbotSmoothness) end
        end)

        local predictLbl = Instance.new("TextLabel")
        predictLbl.Size = UDim2.new(0, 150, 0, 25)
        predictLbl.Position = UDim2.new(0, 12, 0, 145)
        predictLbl.BackgroundTransparency = 1
        predictLbl.Text = "Aim Prediction"
        predictLbl.TextColor3 = NF_DARK_TEXT
        predictLbl.TextXAlignment = Enum.TextXAlignment.Left
        predictLbl.Font = Font_Code
        predictLbl.TextSize = 13
        predictLbl.Parent = aimGroup
        registerThemeElement(predictLbl, "label")

        local predictBox = Instance.new("TextBox")
        predictBox.Size = UDim2.new(0, 70, 0, 26)
        predictBox.Position = UDim2.new(1, -82, 0, 145)
        predictBox.BackgroundColor3 = NF_PANEL
        predictBox.TextColor3 = NF_ACCENT
        predictBox.Font = Font_Code
        predictBox.TextSize = 13
        predictBox.Text = tostring(Config.aimbotPrediction)
        predictBox.Parent = aimGroup
        Instance.new("UICorner", predictBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(predictBox, "inputBox")

        predictBox.FocusLost:Connect(function()
            local val = tonumber(predictBox.Text)
            if val then Config.aimbotPrediction = val else predictBox.Text = tostring(Config.aimbotPrediction) end
        end)

        local keyNoticeLbl = Instance.new("TextLabel")
        keyNoticeLbl.Size = UDim2.new(1, -24, 0, 20)
        keyNoticeLbl.Position = UDim2.new(0, 12, 0, 182)
        keyNoticeLbl.BackgroundTransparency = 1
        keyNoticeLbl.Text = "Trigger: Hold Right Mouse Button (RMB)"
        keyNoticeLbl.TextColor3 = NF_ACCENT
        keyNoticeLbl.TextXAlignment = Enum.TextXAlignment.Left
        keyNoticeLbl.Font = Font_Code
        keyNoticeLbl.TextSize = 11
        keyNoticeLbl.Parent = aimGroup
        registerThemeElement(keyNoticeLbl, "accentText")

        table.insert(sections, {group = aimGroup, title = aimTitle, fullHeight = 220})
    end

    -- FOV Circle Block
    do
        local fovGroup = Instance.new("Frame")
        fovGroup.Size = UDim2.new(0.96, 0, 0, 115)
        fovGroup.BackgroundColor3 = NF_GROUP
        fovGroup.BorderSizePixel = 0
        fovGroup.Parent = legitFrame
        registerThemeElement(fovGroup, "group")

        Instance.new("UICorner", fovGroup).CornerRadius = UDim.new(0, 6)
        local fovGroupStroke = Instance.new("UIStroke")
        fovGroupStroke.Color = NF_BORDER
        fovGroupStroke.Thickness = 1
        fovGroupStroke.Parent = fovGroup
        registerThemeElement(fovGroupStroke, "groupStroke")

        local fovTitle = Instance.new("TextLabel")
        fovTitle.Size = UDim2.new(1, -20, 0, 25)
        fovTitle.Position = UDim2.new(0, 12, 0, 4)
        fovTitle.BackgroundTransparency = 1
        fovTitle.Text = "FOV CIRCLE VISUALS"
        fovTitle.TextColor3 = NF_TEXT
        fovTitle.TextXAlignment = Enum.TextXAlignment.Left
        fovTitle.Font = Font_Code
        fovTitle.TextSize = 12
        fovTitle.Parent = fovGroup
        registerThemeElement(fovTitle, "title")

        local drawFovLbl = Instance.new("TextLabel")
        drawFovLbl.Size = UDim2.new(0, 150, 0, 25)
        drawFovLbl.Position = UDim2.new(0, 12, 0, 35)
        drawFovLbl.BackgroundTransparency = 1
        drawFovLbl.Text = "Draw FOV Circle"
        drawFovLbl.TextColor3 = NF_DARK_TEXT
        drawFovLbl.TextXAlignment = Enum.TextXAlignment.Left
        drawFovLbl.Font = Font_Code
        drawFovLbl.TextSize = 13
        drawFovLbl.Parent = fovGroup
        registerThemeElement(drawFovLbl, "label")

        local drawFovBtn = Instance.new("TextButton")
        drawFovBtn.Size = UDim2.new(0, 110, 0, 26)
        drawFovBtn.Position = UDim2.new(1, -122, 0, 35)
        drawFovBtn.BackgroundColor3 = Config.showFovCircle and NF_ACCENT or NF_PANEL
        drawFovBtn.TextColor3 = Config.showFovCircle and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        drawFovBtn.Font = Font_Code
        drawFovBtn.TextSize = 12
        drawFovBtn.Text = Config.showFovCircle and "ON" or "OFF"
        drawFovBtn.Parent = fovGroup
        Instance.new("UICorner", drawFovBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(drawFovBtn, "activeToggle")

        drawFovBtn.MouseButton1Click:Connect(function()
            Config.showFovCircle = not Config.showFovCircle
            drawFovBtn.Text = Config.showFovCircle and "ON" or "OFF"
            drawFovBtn.BackgroundColor3 = Config.showFovCircle and NF_ACCENT or NF_PANEL
            drawFovBtn.TextColor3 = Config.showFovCircle and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        local fillFovLbl = Instance.new("TextLabel")
        fillFovLbl.Size = UDim2.new(0, 150, 0, 25)
        fillFovLbl.Position = UDim2.new(0, 12, 0, 72)
        fillFovLbl.BackgroundTransparency = 1
        fillFovLbl.Text = "Filled FOV Background"
        fillFovLbl.TextColor3 = NF_DARK_TEXT
        fillFovLbl.TextXAlignment = Enum.TextXAlignment.Left
        fillFovLbl.Font = Font_Code
        fillFovLbl.TextSize = 13
        fillFovLbl.Parent = fovGroup
        registerThemeElement(fillFovLbl, "label")

        local fillFovBtn = Instance.new("TextButton")
        fillFovBtn.Size = UDim2.new(0, 110, 0, 26)
        fillFovBtn.Position = UDim2.new(1, -122, 0, 72)
        fillFovBtn.BackgroundColor3 = Config.fovCircleFilled and NF_ACCENT or NF_PANEL
        fillFovBtn.TextColor3 = Config.fovCircleFilled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        fillFovBtn.Font = Font_Code
        fillFovBtn.TextSize = 12
        fillFovBtn.Text = Config.fovCircleFilled and "ON" or "OFF"
        fillFovBtn.Parent = fovGroup
        Instance.new("UICorner", fillFovBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(fillFovBtn, "activeToggle")

        fillFovBtn.MouseButton1Click:Connect(function()
            Config.fovCircleFilled = not Config.fovCircleFilled
            fillFovBtn.Text = Config.fovCircleFilled and "ON" or "OFF"
            fillFovBtn.BackgroundColor3 = Config.fovCircleFilled and NF_ACCENT or NF_PANEL
            fillFovBtn.TextColor3 = Config.fovCircleFilled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        table.insert(sections, {group = fovGroup, title = fovTitle, fullHeight = 115})
    end

    setupCollapsibleSections(legitFrame, sections, 5)
end

-- 3. VISUALS TAB
local function buildVisualsTab()
    local visFrame = tabFrames["Visuals"]
    local sections = {}

    -- PLAYER ESP
    do
        local espGroup = Instance.new("Frame")
        espGroup.Size = UDim2.new(0.96, 0, 0, 260)
        espGroup.BackgroundColor3 = NF_GROUP
        espGroup.BorderSizePixel = 0
        espGroup.Parent = visFrame
        registerThemeElement(espGroup, "group")

        Instance.new("UICorner", espGroup).CornerRadius = UDim.new(0, 6)
        local espGroupStroke = Instance.new("UIStroke")
        espGroupStroke.Color = NF_BORDER
        espGroupStroke.Thickness = 1
        espGroupStroke.Parent = espGroup
        registerThemeElement(espGroupStroke, "groupStroke")

        local espTitle = Instance.new("TextLabel")
        espTitle.Size = UDim2.new(1, -20, 0, 25)
        espTitle.Position = UDim2.new(0, 12, 0, 4)
        espTitle.BackgroundTransparency = 1
        espTitle.Text = "PLAYER VISUALS (ESP)"
        espTitle.TextColor3 = NF_TEXT
        espTitle.TextXAlignment = Enum.TextXAlignment.Left
        espTitle.Font = Font_Code
        espTitle.TextSize = 12
        espTitle.Parent = espGroup
        registerThemeElement(espTitle, "title")

        local function createVisToggle(labelText, defaultVal, posY, callback)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 180, 0, 25)
            lbl.Position = UDim2.new(0, 12, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = NF_DARK_TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Font_Code
            lbl.TextSize = 13
            lbl.Parent = espGroup
            registerThemeElement(lbl, "label")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 100, 0, 24)
            btn.Position = UDim2.new(1, -112, 0, posY)
            btn.BackgroundColor3 = defaultVal and NF_ACCENT or NF_PANEL
            btn.TextColor3 = defaultVal and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            btn.Font = Font_Code
            btn.TextSize = 12
            btn.Text = defaultVal and "ON" or "OFF"
            btn.Parent = espGroup
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(btn, "activeToggle")

            btn.MouseButton1Click:Connect(function()
                local newVal = not (btn.Text == "ON")
                btn.Text = newVal and "ON" or "OFF"
                btn.BackgroundColor3 = newVal and NF_ACCENT or NF_PANEL
                btn.TextColor3 = newVal and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
                callback(newVal)
            end)
        end

        createVisToggle("2D Box ESP", Config.boxEspEnabled, 35, function(v) Config.boxEspEnabled = v end)
        createVisToggle("Show Player Names", Config.namesEspEnabled, 70, function(v) Config.namesEspEnabled = v end)
        createVisToggle("Show Avatar Above Head", Config.showMiniAvatar, 105, function(v) Config.showMiniAvatar = v end)
        createVisToggle("Highlight Chams", Config.highlightChamsEnabled, 140, function(v) Config.highlightChamsEnabled = v end)
        createVisToggle("MM2 Role Colors (ESP/Chams)", Config.mm2RoleEspEnabled, 175, function(v) Config.mm2RoleEspEnabled = v end)
        createVisToggle("Team Color Difference", Config.teamColorsEnabled, 210, function(v) Config.teamColorsEnabled = v end)

        table.insert(sections, {group = espGroup, title = espTitle, fullHeight = 260})
    end

    -- WATERMARK HUD SETTINGS
    do
        local hudsVisGroup = Instance.new("Frame")
        hudsVisGroup.Size = UDim2.new(0.96, 0, 0, 195)
        hudsVisGroup.BackgroundColor3 = NF_GROUP
        hudsVisGroup.BorderSizePixel = 0
        hudsVisGroup.Parent = visFrame
        registerThemeElement(hudsVisGroup, "group")

        Instance.new("UICorner", hudsVisGroup).CornerRadius = UDim.new(0, 6)
        local hudsVisGroupStroke = Instance.new("UIStroke")
        hudsVisGroupStroke.Color = NF_BORDER
        hudsVisGroupStroke.Thickness = 1
        hudsVisGroupStroke.Parent = hudsVisGroup
        registerThemeElement(hudsVisGroupStroke, "groupStroke")

        local hudsVisTitle = Instance.new("TextLabel")
        hudsVisTitle.Size = UDim2.new(1, -20, 0, 25)
        hudsVisTitle.Position = UDim2.new(0, 12, 0, 4)
        hudsVisTitle.BackgroundTransparency = 1
        hudsVisTitle.Text = "HUD CONFIGURATION & TRANSPARENCY"
        hudsVisTitle.TextColor3 = NF_TEXT
        hudsVisTitle.TextXAlignment = Enum.TextXAlignment.Left
        hudsVisTitle.Font = Font_Code
        hudsVisTitle.TextSize = 12
        hudsVisTitle.Parent = hudsVisGroup
        registerThemeElement(hudsVisTitle, "title")

        local wmToggleLbl = Instance.new("TextLabel")
        wmToggleLbl.Size = UDim2.new(0, 180, 0, 25)
        wmToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        wmToggleLbl.BackgroundTransparency = 1
        wmToggleLbl.Text = "Watermark HUD"
        wmToggleLbl.TextColor3 = NF_DARK_TEXT
        wmToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        wmToggleLbl.Font = Font_Code
        wmToggleLbl.TextSize = 13
        wmToggleLbl.Parent = hudsVisGroup
        registerThemeElement(wmToggleLbl, "label")

        local wmToggleBtn = Instance.new("TextButton")
        wmToggleBtn.Size = UDim2.new(0, 100, 0, 26)
        wmToggleBtn.Position = UDim2.new(1, -112, 0, 35)
        wmToggleBtn.BackgroundColor3 = Config.showWatermarkHUD and NF_ACCENT or NF_PANEL
        wmToggleBtn.TextColor3 = Config.showWatermarkHUD and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        wmToggleBtn.Font = Font_Code
        wmToggleBtn.TextSize = 12
        wmToggleBtn.Text = Config.showWatermarkHUD and "ON" or "OFF"
        wmToggleBtn.Parent = hudsVisGroup
        Instance.new("UICorner", wmToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(wmToggleBtn, "activeToggle")

        wmToggleBtn.MouseButton1Click:Connect(function()
            Config.showWatermarkHUD = not Config.showWatermarkHUD
            wmFrame.Visible = Config.showWatermarkHUD
            wmToggleBtn.Text = Config.showWatermarkHUD and "ON" or "OFF"
            wmToggleBtn.BackgroundColor3 = Config.showWatermarkHUD and NF_ACCENT or NF_PANEL
            wmToggleBtn.TextColor3 = Config.showWatermarkHUD and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        local velToggleLbl = Instance.new("TextLabel")
        velToggleLbl.Size = UDim2.new(0, 180, 0, 25)
        velToggleLbl.Position = UDim2.new(0, 12, 0, 70)
        velToggleLbl.BackgroundTransparency = 1
        velToggleLbl.Text = "Velocity Speed HUD"
        velToggleLbl.TextColor3 = NF_DARK_TEXT
        velToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        velToggleLbl.Font = Font_Code
        velToggleLbl.TextSize = 13
        velToggleLbl.Parent = hudsVisGroup
        registerThemeElement(velToggleLbl, "label")

        local velToggleBtn = Instance.new("TextButton")
        velToggleBtn.Size = UDim2.new(0, 100, 0, 26)
        velToggleBtn.Position = UDim2.new(1, -112, 0, 70)
        velToggleBtn.BackgroundColor3 = Config.showVelocityHUD and NF_ACCENT or NF_PANEL
        velToggleBtn.TextColor3 = Config.showVelocityHUD and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        velToggleBtn.Font = Font_Code
        velToggleBtn.TextSize = 12
        velToggleBtn.Text = Config.showVelocityHUD and "ON" or "OFF"
        velToggleBtn.Parent = hudsVisGroup
        Instance.new("UICorner", velToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(velToggleBtn, "activeToggle")

        velToggleBtn.MouseButton1Click:Connect(function()
            Config.showVelocityHUD = not Config.showVelocityHUD
            hudFrame.Visible = Config.showVelocityHUD
            velToggleBtn.Text = Config.showVelocityHUD and "ON" or "OFF"
            velToggleBtn.BackgroundColor3 = Config.showVelocityHUD and NF_ACCENT or NF_PANEL
            velToggleBtn.TextColor3 = Config.showVelocityHUD and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        -- Keybinds Menu Toggle
        local kbToggleLbl = Instance.new("TextLabel")
        kbToggleLbl.Size = UDim2.new(0, 180, 0, 25)
        kbToggleLbl.Position = UDim2.new(0, 12, 0, 105)
        kbToggleLbl.BackgroundTransparency = 1
        kbToggleLbl.Text = "Keybinds HUD Menu"
        kbToggleLbl.TextColor3 = NF_DARK_TEXT
        kbToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        kbToggleLbl.Font = Font_Code
        kbToggleLbl.TextSize = 13
        kbToggleLbl.Parent = hudsVisGroup
        registerThemeElement(kbToggleLbl, "label")

        local kbToggleBtn = Instance.new("TextButton")
        kbToggleBtn.Size = UDim2.new(0, 100, 0, 26)
        kbToggleBtn.Position = UDim2.new(1, -112, 0, 105)
        kbToggleBtn.BackgroundColor3 = Config.showKeybindsMenu and NF_ACCENT or NF_PANEL
        kbToggleBtn.TextColor3 = Config.showKeybindsMenu and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        kbToggleBtn.Font = Font_Code
        kbToggleBtn.TextSize = 12
        kbToggleBtn.Text = Config.showKeybindsMenu and "ON" or "OFF"
        kbToggleBtn.Parent = hudsVisGroup
        Instance.new("UICorner", kbToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(kbToggleBtn, "activeToggle")

        kbToggleBtn.MouseButton1Click:Connect(function()
            Config.showKeybindsMenu = not Config.showKeybindsMenu
            kbMainFrame.Visible = Config.showKeybindsMenu
            kbToggleBtn.Text = Config.showKeybindsMenu and "ON" or "OFF"
            kbToggleBtn.BackgroundColor3 = Config.showKeybindsMenu and NF_ACCENT or NF_PANEL
            kbToggleBtn.TextColor3 = Config.showKeybindsMenu and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        -- HUD Background Transparency
        local hudTransLbl = Instance.new("TextLabel")
        hudTransLbl.Size = UDim2.new(0, 180, 0, 25)
        hudTransLbl.Position = UDim2.new(0, 12, 0, 140)
        hudTransLbl.BackgroundTransparency = 1
        hudTransLbl.Text = "HUD Transparency (0-100%)"
        hudTransLbl.TextColor3 = NF_DARK_TEXT
        hudTransLbl.TextXAlignment = Enum.TextXAlignment.Left
        hudTransLbl.Font = Font_Code
        hudTransLbl.TextSize = 13
        hudTransLbl.Parent = hudsVisGroup
        registerThemeElement(hudTransLbl, "label")

        local hudTransBox = Instance.new("TextBox")
        hudTransBox.Size = UDim2.new(0, 70, 0, 26)
        hudTransBox.Position = UDim2.new(1, -82, 0, 140)
        hudTransBox.BackgroundColor3 = NF_PANEL
        hudTransBox.TextColor3 = NF_ACCENT
        hudTransBox.Font = Font_Code
        hudTransBox.TextSize = 13
        hudTransBox.Text = tostring(math.floor(Config.hudTransparency * 100)) .. "%"
        hudTransBox.Parent = hudsVisGroup
        Instance.new("UICorner", hudTransBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(hudTransBox, "inputBox")

        hudTransBox.FocusLost:Connect(function()
            local clean = string.gsub(hudTransBox.Text, "%%", "")
            local val = tonumber(clean)
            if val then
                Config.hudTransparency = math.clamp(val / 100, 0, 1)
                wmFrame.BackgroundTransparency = Config.hudTransparency
                hudFrame.BackgroundTransparency = Config.hudTransparency
                kbMainFrame.BackgroundTransparency = Config.hudTransparency
                hudTransBox.Text = tostring(math.floor(Config.hudTransparency * 100)) .. "%"
            else
                hudTransBox.Text = tostring(math.floor(Config.hudTransparency * 100)) .. "%"
            end
        end)

        table.insert(sections, {group = hudsVisGroup, title = hudsVisTitle, fullHeight = 195})
    end

    -- WATERMARK CUSTOMIZATION GROUP
    do
        local wmCustGroup = Instance.new("Frame")
        wmCustGroup.Size = UDim2.new(0.96, 0, 0, 350)
        wmCustGroup.BackgroundColor3 = NF_GROUP
        wmCustGroup.BorderSizePixel = 0
        wmCustGroup.Parent = visFrame
        registerThemeElement(wmCustGroup, "group")

        Instance.new("UICorner", wmCustGroup).CornerRadius = UDim.new(0, 6)
        local wmCustStroke = Instance.new("UIStroke")
        wmCustStroke.Color = NF_BORDER
        wmCustStroke.Thickness = 1
        wmCustStroke.Parent = wmCustGroup
        registerThemeElement(wmCustStroke, "groupStroke")

        local wmCustTitle = Instance.new("TextLabel")
        wmCustTitle.Size = UDim2.new(1, -20, 0, 25)
        wmCustTitle.Position = UDim2.new(0, 12, 0, 4)
        wmCustTitle.BackgroundTransparency = 1
        wmCustTitle.Text = "WATERMARK CUSTOMIZATION"
        wmCustTitle.TextColor3 = NF_TEXT
        wmCustTitle.TextXAlignment = Enum.TextXAlignment.Left
        wmCustTitle.Font = Font_Code
        wmCustTitle.TextSize = 12
        wmCustTitle.Parent = wmCustGroup
        registerThemeElement(wmCustTitle, "title")

        local nickLbl = Instance.new("TextLabel")
        nickLbl.Size = UDim2.new(0, 150, 0, 25)
        nickLbl.Position = UDim2.new(0, 12, 0, 35)
        nickLbl.BackgroundTransparency = 1
        nickLbl.Text = "HUD Nickname"
        nickLbl.TextColor3 = NF_DARK_TEXT
        nickLbl.TextXAlignment = Enum.TextXAlignment.Left
        nickLbl.Font = Font_Code
        nickLbl.TextSize = 13
        nickLbl.Parent = wmCustGroup
        registerThemeElement(nickLbl, "label")

        local nickBox = Instance.new("TextBox")
        nickBox.Size = UDim2.new(0, 130, 0, 26)
        nickBox.Position = UDim2.new(1, -142, 0, 35)
        nickBox.BackgroundColor3 = NF_PANEL
        nickBox.TextColor3 = NF_ACCENT
        nickBox.Font = Font_Code
        nickBox.TextSize = 12
        nickBox.Text = Config.hudNickname
        nickBox.Parent = wmCustGroup
        Instance.new("UICorner", nickBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(nickBox, "inputBox")

        nickBox.FocusLost:Connect(function()
            Config.hudNickname = nickBox.Text
        end)

        local styleLbl = Instance.new("TextLabel")
        styleLbl.Size = UDim2.new(0, 150, 0, 25)
        styleLbl.Position = UDim2.new(0, 12, 0, 72)
        styleLbl.BackgroundTransparency = 1
        styleLbl.Text = "Watermark Style"
        styleLbl.TextColor3 = NF_DARK_TEXT
        styleLbl.TextXAlignment = Enum.TextXAlignment.Left
        styleLbl.Font = Font_Code
        styleLbl.TextSize = 13
        styleLbl.Parent = wmCustGroup
        registerThemeElement(styleLbl, "label")

        local styleBtn = Instance.new("TextButton")
        styleBtn.Size = UDim2.new(0, 130, 0, 26)
        styleBtn.Position = UDim2.new(1, -142, 0, 72)
        styleBtn.BackgroundColor3 = NF_PANEL
        styleBtn.TextColor3 = NF_ACCENT
        styleBtn.Font = Font_Code
        styleBtn.TextSize = 12
        styleBtn.Text = Config.hudStyle
        styleBtn.Parent = wmCustGroup
        Instance.new("UICorner", styleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(styleBtn, "buttonPanel")

        styleBtn.MouseButton1Click:Connect(function()
            Config.hudStyle = (Config.hudStyle == "Round") and "Square" or "Round"
            styleBtn.Text = Config.hudStyle
        end)

        local function createWmToggle(labelText, configKey, posY)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 150, 0, 25)
            lbl.Position = UDim2.new(0, 12, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = NF_DARK_TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Font_Code
            lbl.TextSize = 13
            lbl.Parent = wmCustGroup
            registerThemeElement(lbl, "label")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 100, 0, 26)
            btn.Position = UDim2.new(1, -112, 0, posY)
            btn.BackgroundColor3 = Config[configKey] and NF_ACCENT or NF_PANEL
            btn.TextColor3 = Config[configKey] and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            btn.Font = Font_Code
            btn.TextSize = 12
            btn.Text = Config[configKey] and "ON" or "OFF"
            btn.Parent = wmCustGroup
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(btn, "activeToggle")

            btn.MouseButton1Click:Connect(function()
                Config[configKey] = not Config[configKey]
                btn.Text = Config[configKey] and "ON" or "OFF"
                btn.BackgroundColor3 = Config[configKey] and NF_ACCENT or NF_PANEL
                btn.TextColor3 = Config[configKey] and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            end)
        end

        createWmToggle("Show Game Name", "showGameName", 108)
        createWmToggle("Show FPS", "showFps", 144)
        createWmToggle("Show Ping", "showPing", 180)

        local animatedLbl = Instance.new("TextLabel")
        animatedLbl.Size = UDim2.new(0, 150, 0, 25)
        animatedLbl.Position = UDim2.new(0, 12, 0, 216)
        animatedLbl.BackgroundTransparency = 1
        animatedLbl.Text = "Animated Theme"
        animatedLbl.TextColor3 = NF_DARK_TEXT
        animatedLbl.TextXAlignment = Enum.TextXAlignment.Left
        animatedLbl.Font = Font_Code
        animatedLbl.TextSize = 13
        animatedLbl.Parent = wmCustGroup
        registerThemeElement(animatedLbl, "label")

        local animatedBtn = Instance.new("TextButton")
        animatedBtn.Size = UDim2.new(0, 100, 0, 26)
        animatedBtn.Position = UDim2.new(1, -112, 0, 216)
        animatedBtn.BackgroundColor3 = Config.themeAnimated and NF_ACCENT or NF_PANEL
        animatedBtn.TextColor3 = Config.themeAnimated and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        animatedBtn.Font = Font_Code
        animatedBtn.TextSize = 12
        animatedBtn.Text = Config.themeAnimated and "ON" or "OFF"
        animatedBtn.Parent = wmCustGroup
        Instance.new("UICorner", animatedBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(animatedBtn, "activeToggle")

        animatedBtn.MouseButton1Click:Connect(function()
            Config.themeAnimated = not Config.themeAnimated
            animatedBtn.Text = Config.themeAnimated and "ON" or "OFF"
            animatedBtn.BackgroundColor3 = Config.themeAnimated and NF_ACCENT or NF_PANEL
            animatedBtn.TextColor3 = Config.themeAnimated and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            if not Config.themeAnimated then applyAccentColorToUI(Config.activeThemeColor) end
        end)

        table.insert(sections, {group = wmCustGroup, title = wmCustTitle, fullHeight = 350})
    end

    -- WORLD LIGHTING
    do
        local worldGroup = Instance.new("Frame")
        worldGroup.Size = UDim2.new(0.96, 0, 0, 210)
        worldGroup.BackgroundColor3 = NF_GROUP
        worldGroup.BorderSizePixel = 0
        worldGroup.Parent = visFrame
        registerThemeElement(worldGroup, "group")

        Instance.new("UICorner", worldGroup).CornerRadius = UDim.new(0, 6)
        local worldGroupStroke = Instance.new("UIStroke")
        worldGroupStroke.Color = NF_BORDER
        worldGroupStroke.Thickness = 1
        worldGroupStroke.Parent = worldGroup
        registerThemeElement(worldGroupStroke, "groupStroke")

        local worldTitle = Instance.new("TextLabel")
        worldTitle.Size = UDim2.new(1, -20, 0, 25)
        worldTitle.Position = UDim2.new(0, 12, 0, 4)
        worldTitle.BackgroundTransparency = 1
        worldTitle.TextColor3 = NF_TEXT
        worldTitle.TextXAlignment = Enum.TextXAlignment.Left
        worldTitle.Font = Font_Code
        worldTitle.TextSize = 12
        worldTitle.Parent = worldGroup
        registerThemeElement(worldTitle, "title")

        local worldToggleLbl = Instance.new("TextLabel")
        worldToggleLbl.Size = UDim2.new(0, 180, 0, 25)
        worldToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        worldToggleLbl.BackgroundTransparency = 1
        worldToggleLbl.Text = "Enable World Visuals"
        worldToggleLbl.TextColor3 = NF_DARK_TEXT
        worldToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        worldToggleLbl.Font = Font_Code
        worldToggleLbl.TextSize = 13
        worldToggleLbl.Parent = worldGroup
        registerThemeElement(worldToggleLbl, "label")

        local worldToggleBtn = Instance.new("TextButton")
        worldToggleBtn.Size = UDim2.new(0, 100, 0, 26)
        worldToggleBtn.Position = UDim2.new(1, -112, 0, 35)
        worldToggleBtn.BackgroundColor3 = Config.worldVisualsEnabled and NF_ACCENT or NF_PANEL
        worldToggleBtn.TextColor3 = Config.worldVisualsEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        worldToggleBtn.Font = Font_Code
        worldToggleBtn.TextSize = 12
        worldToggleBtn.Text = Config.worldVisualsEnabled and "ON" or "OFF"
        worldToggleBtn.Parent = worldGroup
        Instance.new("UICorner", worldToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(worldToggleBtn, "activeToggle")

        worldToggleBtn.MouseButton1Click:Connect(function()
            Config.worldVisualsEnabled = not Config.worldVisualsEnabled
            worldToggleBtn.Text = Config.worldVisualsEnabled and "ON" or "OFF"
            worldToggleBtn.BackgroundColor3 = Config.worldVisualsEnabled and NF_ACCENT or NF_PANEL
            worldToggleBtn.TextColor3 = Config.worldVisualsEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            
            if not Config.worldVisualsEnabled then
                Lighting.Ambient = defaultLighting.Ambient
                Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
                Lighting.FogColor = defaultLighting.FogColor
                Lighting.FogEnd = defaultLighting.FogEnd
                Lighting.TimeOfDay = defaultLighting.TimeOfDay
                Lighting.Brightness = defaultLighting.Brightness
            end
        end)

        local presetLbl = Instance.new("TextLabel")
        presetLbl.Size = UDim2.new(0, 180, 0, 25)
        presetLbl.Position = UDim2.new(0, 12, 0, 75)
        presetLbl.BackgroundTransparency = 1
        presetLbl.Text = "World Preset"
        presetLbl.TextColor3 = NF_DARK_TEXT
        presetLbl.TextXAlignment = Enum.TextXAlignment.Left
        presetLbl.Font = Font_Code
        presetLbl.TextSize = 13
        presetLbl.Parent = worldGroup
        registerThemeElement(presetLbl, "label")

        local presetBtn = Instance.new("TextButton")
        presetBtn.Size = UDim2.new(0, 110, 0, 26)
        presetBtn.Position = UDim2.new(1, -122, 0, 75)
        presetBtn.BackgroundColor3 = NF_PANEL
        presetBtn.TextColor3 = NF_ACCENT
        presetBtn.Font = Font_Code
        presetBtn.TextSize = 12
        presetBtn.Text = Config.worldPresets[Config.worldPresetIndex]
        presetBtn.Parent = worldGroup
        Instance.new("UICorner", presetBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(presetBtn, "buttonPanel")

        presetBtn.MouseButton1Click:Connect(function()
            Config.worldPresetIndex = Config.worldPresetIndex % #Config.worldPresets + 1
            presetBtn.Text = Config.worldPresets[Config.worldPresetIndex]
        end)

        table.insert(sections, {group = worldGroup, title = worldTitle, fullHeight = 210})
    end

    setupCollapsibleSections(visFrame, sections, 5)
end

-- 4. MOVEMENT TAB (INCLUDES SLIDEWALK & AIRSTUCK)
local function buildMovementTab()
    local movFrame = tabFrames["Movement"]
    local sections = {}

    -- SlideWalk Block (Neverlose / Skeet Moonwalk)
    do
        local swGroup = Instance.new("Frame")
        swGroup.Size = UDim2.new(0.96, 0, 0, 115)
        swGroup.BackgroundColor3 = NF_GROUP
        swGroup.BorderSizePixel = 0
        swGroup.Parent = movFrame
        registerThemeElement(swGroup, "group")

        Instance.new("UICorner", swGroup).CornerRadius = UDim.new(0, 6)
        local swGroupStroke = Instance.new("UIStroke")
        swGroupStroke.Color = NF_BORDER
        swGroupStroke.Thickness = 1
        swGroupStroke.Parent = swGroup
        registerThemeElement(swGroupStroke, "groupStroke")

        local swTitle = Instance.new("TextLabel")
        swTitle.Size = UDim2.new(1, -20, 0, 25)
        swTitle.Position = UDim2.new(0, 12, 0, 4)
        swTitle.BackgroundTransparency = 1
        swTitle.Text = "SLIDEWALK (MOONWALK SYSTEM)"
        swTitle.TextColor3 = NF_TEXT
        swTitle.TextXAlignment = Enum.TextXAlignment.Left
        swTitle.Font = Font_Code
        swTitle.TextSize = 12
        swTitle.Parent = swGroup
        registerThemeElement(swTitle, "title")

        local swToggleLbl = Instance.new("TextLabel")
        swToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        swToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        swToggleLbl.BackgroundTransparency = 1
        swToggleLbl.Text = "Enable SlideWalk"
        swToggleLbl.TextColor3 = NF_DARK_TEXT
        swToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        swToggleLbl.Font = Font_Code
        swToggleLbl.TextSize = 13
        swToggleLbl.Parent = swGroup
        registerThemeElement(swToggleLbl, "label")

        slideWalkToggleBtnGlobal = Instance.new("TextButton")
        slideWalkToggleBtnGlobal.Size = UDim2.new(0, 110, 0, 26)
        slideWalkToggleBtnGlobal.Position = UDim2.new(1, -122, 0, 35)
        slideWalkToggleBtnGlobal.BackgroundColor3 = Config.slideWalkEnabled and NF_ACCENT or NF_PANEL
        slideWalkToggleBtnGlobal.TextColor3 = Config.slideWalkEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        slideWalkToggleBtnGlobal.Font = Font_Code
        slideWalkToggleBtnGlobal.TextSize = 12
        slideWalkToggleBtnGlobal.Text = Config.slideWalkEnabled and "ON" or "OFF"
        slideWalkToggleBtnGlobal.Parent = swGroup
        Instance.new("UICorner", slideWalkToggleBtnGlobal).CornerRadius = UDim.new(0, 4)
        registerThemeElement(slideWalkToggleBtnGlobal, "activeToggle")

        slideWalkToggleBtnGlobal.MouseButton1Click:Connect(function()
            Config.slideWalkEnabled = not Config.slideWalkEnabled
            slideWalkToggleBtnGlobal.Text = Config.slideWalkEnabled and "ON" or "OFF"
            slideWalkToggleBtnGlobal.BackgroundColor3 = Config.slideWalkEnabled and NF_ACCENT or NF_PANEL
            slideWalkToggleBtnGlobal.TextColor3 = Config.slideWalkEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            updateKeybindItem("SlideWalk", Config.slideWalkKey.Name, Config.slideWalkKeyMode, Config.slideWalkEnabled)
        end)

        local swKeyLbl = Instance.new("TextLabel")
        swKeyLbl.Size = UDim2.new(0, 130, 0, 25)
        swKeyLbl.Position = UDim2.new(0, 12, 0, 72)
        swKeyLbl.BackgroundTransparency = 1
        swKeyLbl.Text = "SlideWalk Keybind"
        swKeyLbl.TextColor3 = NF_DARK_TEXT
        swKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
        swKeyLbl.Font = Font_Code
        swKeyLbl.TextSize = 13
        swKeyLbl.Parent = swGroup
        registerThemeElement(swKeyLbl, "label")

        UI_Binds.slideWalkKeyBtn = Instance.new("TextButton")
        UI_Binds.slideWalkKeyBtn.Size = UDim2.new(0, 85, 0, 26)
        UI_Binds.slideWalkKeyBtn.Position = UDim2.new(1, -195, 0, 72)
        UI_Binds.slideWalkKeyBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.slideWalkKeyBtn.TextColor3 = NF_ACCENT
        UI_Binds.slideWalkKeyBtn.Font = Font_Code
        UI_Binds.slideWalkKeyBtn.TextSize = 11
        UI_Binds.slideWalkKeyBtn.Text = "[" .. Config.slideWalkKey.Name .. "]"
        UI_Binds.slideWalkKeyBtn.Parent = swGroup
        Instance.new("UICorner", UI_Binds.slideWalkKeyBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.slideWalkKeyBtn, "buttonPanel")

        UI_Binds.slideWalkModeBtn = Instance.new("TextButton")
        UI_Binds.slideWalkModeBtn.Size = UDim2.new(0, 70, 0, 26)
        UI_Binds.slideWalkModeBtn.Position = UDim2.new(1, -102, 0, 72)
        UI_Binds.slideWalkModeBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.slideWalkModeBtn.TextColor3 = NF_ORANGE
        UI_Binds.slideWalkModeBtn.Font = Font_Code
        UI_Binds.slideWalkModeBtn.TextSize = 11
        UI_Binds.slideWalkModeBtn.Text = Config.slideWalkKeyMode
        UI_Binds.slideWalkModeBtn.Parent = swGroup
        Instance.new("UICorner", UI_Binds.slideWalkModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.slideWalkModeBtn, "buttonPanel")

        UI_Binds.slideWalkKeyBtn.MouseButton1Click:Connect(function()
            UI_Binds.slideWalkKeyBtn.Text = "[ press... ]"
            Config.bindingSlideWalkKey = true
        end)

        UI_Binds.slideWalkModeBtn.MouseButton1Click:Connect(function()
            Config.slideWalkKeyMode = (Config.slideWalkKeyMode == "Toggle") and "Hold" or "Toggle"
            UI_Binds.slideWalkModeBtn.Text = Config.slideWalkKeyMode
        end)

        table.insert(sections, {group = swGroup, title = swTitle, fullHeight = 115})
    end

    -- AirStuck Block
    do
        local asGroup = Instance.new("Frame")
        asGroup.Size = UDim2.new(0.96, 0, 0, 115)
        asGroup.BackgroundColor3 = NF_GROUP
        asGroup.BorderSizePixel = 0
        asGroup.Parent = movFrame
        registerThemeElement(asGroup, "group")

        Instance.new("UICorner", asGroup).CornerRadius = UDim.new(0, 6)
        local asGroupStroke = Instance.new("UIStroke")
        asGroupStroke.Color = NF_BORDER
        asGroupStroke.Thickness = 1
        asGroupStroke.Parent = asGroup
        registerThemeElement(asGroupStroke, "groupStroke")

        local asTitle = Instance.new("TextLabel")
        asTitle.Size = UDim2.new(1, -20, 0, 25)
        asTitle.Position = UDim2.new(0, 12, 0, 4)
        asTitle.BackgroundTransparency = 1
        asTitle.Text = "AIRSTUCK (AIR FREEZE SYSTEM)"
        asTitle.TextColor3 = NF_TEXT
        asTitle.TextXAlignment = Enum.TextXAlignment.Left
        asTitle.Font = Font_Code
        asTitle.TextSize = 12
        asTitle.Parent = asGroup
        registerThemeElement(asTitle, "title")

        local asToggleLbl = Instance.new("TextLabel")
        asToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        asToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        asToggleLbl.BackgroundTransparency = 1
        asToggleLbl.Text = "Enable AirStuck"
        asToggleLbl.TextColor3 = NF_DARK_TEXT
        asToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        asToggleLbl.Font = Font_Code
        asToggleLbl.TextSize = 13
        asToggleLbl.Parent = asGroup
        registerThemeElement(asToggleLbl, "label")

        airStuckToggleBtnGlobal = Instance.new("TextButton")
        airStuckToggleBtnGlobal.Size = UDim2.new(0, 110, 0, 26)
        airStuckToggleBtnGlobal.Position = UDim2.new(1, -122, 0, 35)
        airStuckToggleBtnGlobal.BackgroundColor3 = Config.airStuckEnabled and NF_ACCENT or NF_PANEL
        airStuckToggleBtnGlobal.TextColor3 = Config.airStuckEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        airStuckToggleBtnGlobal.Font = Font_Code
        airStuckToggleBtnGlobal.TextSize = 12
        airStuckToggleBtnGlobal.Text = Config.airStuckEnabled and "ON" or "OFF"
        airStuckToggleBtnGlobal.Parent = asGroup
        Instance.new("UICorner", airStuckToggleBtnGlobal).CornerRadius = UDim.new(0, 4)
        registerThemeElement(airStuckToggleBtnGlobal, "activeToggle")

        airStuckToggleBtnGlobal.MouseButton1Click:Connect(function()
            Config.airStuckEnabled = not Config.airStuckEnabled
            if not Config.airStuckEnabled then Config.isAirStuckActive = false Config.airStuckFrozenCFrame = nil end
            airStuckToggleBtnGlobal.Text = Config.airStuckEnabled and "ON" or "OFF"
            airStuckToggleBtnGlobal.BackgroundColor3 = Config.airStuckEnabled and NF_ACCENT or NF_PANEL
            airStuckToggleBtnGlobal.TextColor3 = Config.airStuckEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
            updateKeybindItem("AirStuck", Config.airStuckKey.Name, Config.airStuckKeyMode, Config.airStuckEnabled)
        end)

        local asKeyLbl = Instance.new("TextLabel")
        asKeyLbl.Size = UDim2.new(0, 130, 0, 25)
        asKeyLbl.Position = UDim2.new(0, 12, 0, 72)
        asKeyLbl.BackgroundTransparency = 1
        asKeyLbl.Text = "AirStuck Keybind"
        asKeyLbl.TextColor3 = NF_DARK_TEXT
        asKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
        asKeyLbl.Font = Font_Code
        asKeyLbl.TextSize = 13
        asKeyLbl.Parent = asGroup
        registerThemeElement(asKeyLbl, "label")

        UI_Binds.airStuckKeyBtn = Instance.new("TextButton")
        UI_Binds.airStuckKeyBtn.Size = UDim2.new(0, 85, 0, 26)
        UI_Binds.airStuckKeyBtn.Position = UDim2.new(1, -195, 0, 72)
        UI_Binds.airStuckKeyBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.airStuckKeyBtn.TextColor3 = NF_ACCENT
        UI_Binds.airStuckKeyBtn.Font = Font_Code
        UI_Binds.airStuckKeyBtn.TextSize = 11
        UI_Binds.airStuckKeyBtn.Text = "[" .. Config.airStuckKey.Name .. "]"
        UI_Binds.airStuckKeyBtn.Parent = asGroup
        Instance.new("UICorner", UI_Binds.airStuckKeyBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.airStuckKeyBtn, "buttonPanel")

        UI_Binds.airStuckModeBtn = Instance.new("TextButton")
        UI_Binds.airStuckModeBtn.Size = UDim2.new(0, 70, 0, 26)
        UI_Binds.airStuckModeBtn.Position = UDim2.new(1, -102, 0, 72)
        UI_Binds.airStuckModeBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.airStuckModeBtn.TextColor3 = NF_ORANGE
        UI_Binds.airStuckModeBtn.Font = Font_Code
        UI_Binds.airStuckModeBtn.TextSize = 11
        UI_Binds.airStuckModeBtn.Text = Config.airStuckKeyMode
        UI_Binds.airStuckModeBtn.Parent = asGroup
        Instance.new("UICorner", UI_Binds.airStuckModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.airStuckModeBtn, "buttonPanel")

        UI_Binds.airStuckKeyBtn.MouseButton1Click:Connect(function()
            UI_Binds.airStuckKeyBtn.Text = "[ press... ]"
            Config.bindingAirStuckKey = true
        end)

        UI_Binds.airStuckModeBtn.MouseButton1Click:Connect(function()
            Config.airStuckKeyMode = (Config.airStuckKeyMode == "Toggle") and "Hold" or "Toggle"
            UI_Binds.airStuckModeBtn.Text = Config.airStuckKeyMode
        end)

        table.insert(sections, {group = asGroup, title = asTitle, fullHeight = 115})
    end

    -- Physics Surf Settings Block
    do
        local surfGroup = Instance.new("Frame")
        surfGroup.Size = UDim2.new(0.96, 0, 0, 235)
        surfGroup.BackgroundColor3 = NF_GROUP
        surfGroup.BorderSizePixel = 0
        surfGroup.Parent = movFrame
        registerThemeElement(surfGroup, "group")

        Instance.new("UICorner", surfGroup).CornerRadius = UDim.new(0, 6)
        local surfGroupStroke = Instance.new("UIStroke")
        surfGroupStroke.Color = NF_BORDER
        surfGroupStroke.Thickness = 1
        surfGroupStroke.Parent = surfGroup
        registerThemeElement(surfGroupStroke, "groupStroke")

        local surfTitle = Instance.new("TextLabel")
        surfTitle.Size = UDim2.new(1, -20, 0, 25)
        surfTitle.Position = UDim2.new(0, 12, 0, 4)
        surfTitle.BackgroundTransparency = 1
        surfTitle.Text = "PHYSICS SURF SYSTEMS"
        surfTitle.TextColor3 = NF_TEXT
        surfTitle.TextXAlignment = Enum.TextXAlignment.Left
        surfTitle.Font = Font_Code
        surfTitle.TextSize = 12
        surfTitle.Parent = surfGroup
        registerThemeElement(surfTitle, "title")

        local speedLbl = Instance.new("TextLabel")
        speedLbl.Size = UDim2.new(0, 150, 0, 25)
        speedLbl.Position = UDim2.new(0, 12, 0, 35)
        speedLbl.BackgroundTransparency = 1
        speedLbl.Text = "1. Physics Surf Speed"
        speedLbl.TextColor3 = NF_DARK_TEXT
        speedLbl.TextXAlignment = Enum.TextXAlignment.Left
        speedLbl.Font = Font_Code
        speedLbl.TextSize = 13
        speedLbl.Parent = surfGroup
        registerThemeElement(speedLbl, "label")

        local speedBox = Instance.new("TextBox")
        speedBox.Size = UDim2.new(0, 70, 0, 26)
        speedBox.Position = UDim2.new(1, -82, 0, 35)
        speedBox.BackgroundColor3 = NF_PANEL
        speedBox.TextColor3 = NF_ACCENT
        speedBox.Font = Font_Code
        speedBox.TextSize = 13
        speedBox.Text = tostring(Config.pixelSurfSpeed)
        speedBox.Parent = surfGroup
        Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(speedBox, "inputBox")

        speedBox.FocusLost:Connect(function()
            local n = tonumber(speedBox.Text)
            if n then Config.pixelSurfSpeed = n else speedBox.Text = tostring(Config.pixelSurfSpeed) end
        end)

        local surfModeLbl = Instance.new("TextLabel")
        surfModeLbl.Size = UDim2.new(0, 150, 0, 25)
        surfModeLbl.Position = UDim2.new(0, 12, 0, 72)
        surfModeLbl.BackgroundTransparency = 1
        surfModeLbl.Text = "2. Physics Surf Mode"
        surfModeLbl.TextColor3 = NF_DARK_TEXT
        surfModeLbl.TextXAlignment = Enum.TextXAlignment.Left
        surfModeLbl.Font = Font_Code
        surfModeLbl.TextSize = 13
        surfModeLbl.Parent = surfGroup
        registerThemeElement(surfModeLbl, "label")

        UI_Binds.surfModeBtn = Instance.new("TextButton")
        UI_Binds.surfModeBtn.Size = UDim2.new(0, 110, 0, 26)
        UI_Binds.surfModeBtn.Position = UDim2.new(1, -122, 0, 72)
        UI_Binds.surfModeBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.surfModeBtn.TextColor3 = NF_ACCENT
        UI_Binds.surfModeBtn.Font = Font_Code
        UI_Binds.surfModeBtn.TextSize = 12
        UI_Binds.surfModeBtn.Text = Config.surfModes[Config.surfModeIndex]
        UI_Binds.surfModeBtn.Parent = surfGroup
        Instance.new("UICorner", UI_Binds.surfModeBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.surfModeBtn, "buttonPanel")

        UI_Binds.surfModeBtn.MouseButton1Click:Connect(function()
            Config.surfModeIndex = Config.surfModeIndex % #Config.surfModes + 1
            UI_Binds.surfModeBtn.Text = Config.surfModes[Config.surfModeIndex]
            Config.waypoints = {}
            Config.currentWaypointIndex = 1
        end)

        local function createMovKeybindRow(labelText, defaultKeyName, defaultMode, posY, onKeyBindClick, onModeToggleClick)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 130, 0, 25)
            lbl.Position = UDim2.new(0, 12, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = NF_DARK_TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Font_Code
            lbl.TextSize = 13
            lbl.Parent = surfGroup
            registerThemeElement(lbl, "label")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 85, 0, 26)
            btn.Position = UDim2.new(1, -195, 0, posY)
            btn.BackgroundColor3 = NF_PANEL
            btn.TextColor3 = NF_ACCENT
            btn.Font = Font_Code
            btn.TextSize = 11
            btn.Text = "[" .. defaultKeyName .. "]"
            btn.Parent = surfGroup
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(btn, "buttonPanel")

            local modeBtn = Instance.new("TextButton")
            modeBtn.Size = UDim2.new(0, 70, 0, 26)
            modeBtn.Position = UDim2.new(1, -102, 0, posY)
            modeBtn.BackgroundColor3 = NF_PANEL
            modeBtn.TextColor3 = NF_ORANGE
            modeBtn.Font = Font_Code
            modeBtn.TextSize = 11
            modeBtn.Text = defaultMode
            modeBtn.Parent = surfGroup
            Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(modeBtn, "buttonPanel")

            btn.MouseButton1Click:Connect(function()
                btn.Text = "[ press... ]"
                onKeyBindClick()
            end)

            modeBtn.MouseButton1Click:Connect(function()
                onModeToggleClick(modeBtn)
            end)

            return btn, modeBtn
        end

        UI_Binds.surfKeyBtn, UI_Binds.surfKeyModeBtn = createMovKeybindRow("3. Physics Surf Activation", Config.pixelSurfKey.Name, Config.surfKeyMode, 108, 
            function() Config.bindingSurfKey = true end,
            function(btn)
                Config.surfKeyMode = (Config.surfKeyMode == "Toggle") and "Hold" or "Toggle"
                btn.Text = Config.surfKeyMode
            end
        )

        local waypointKeyLbl = Instance.new("TextLabel")
        waypointKeyLbl.Size = UDim2.new(0, 150, 0, 25)
        waypointKeyLbl.Position = UDim2.new(0, 12, 0, 145)
        waypointKeyLbl.BackgroundTransparency = 1
        waypointKeyLbl.Text = "4. Setup Waypoint Key"
        waypointKeyLbl.TextColor3 = NF_DARK_TEXT
        waypointKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
        waypointKeyLbl.Font = Font_Code
        waypointKeyLbl.TextSize = 13
        waypointKeyLbl.Parent = surfGroup
        registerThemeElement(waypointKeyLbl, "label")

        UI_Binds.waypointKeyBtn = Instance.new("TextButton")
        UI_Binds.waypointKeyBtn.Size = UDim2.new(0, 110, 0, 26)
        UI_Binds.waypointKeyBtn.Position = UDim2.new(1, -122, 0, 145)
        UI_Binds.waypointKeyBtn.BackgroundColor3 = NF_PANEL
        UI_Binds.waypointKeyBtn.TextColor3 = NF_ACCENT
        UI_Binds.waypointKeyBtn.Font = Font_Code
        UI_Binds.waypointKeyBtn.TextSize = 12
        UI_Binds.waypointKeyBtn.Text = "[" .. Config.setWaypointKey.Name .. "]"
        UI_Binds.waypointKeyBtn.Parent = surfGroup
        Instance.new("UICorner", UI_Binds.waypointKeyBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.waypointKeyBtn, "buttonPanel")

        UI_Binds.waypointKeyBtn.MouseButton1Click:Connect(function()
            UI_Binds.waypointKeyBtn.Text = "[ press... ]"
            Config.bindingWaypointKey = true
        end)

        local addWpBtn = Instance.new("TextButton")
        addWpBtn.Size = UDim2.new(0.46, 0, 0, 24)
        addWpBtn.Position = UDim2.new(0.02, 0, 0, 205)
        addWpBtn.BackgroundColor3 = NF_PANEL
        addWpBtn.Text = "+ Поставить точку"
        addWpBtn.TextColor3 = NF_TEXT
        addWpBtn.Font = Font_Code
        addWpBtn.TextSize = 11
        addWpBtn.Parent = surfGroup
        Instance.new("UICorner", addWpBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(addWpBtn, "buttonPanel")

        addWpBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(Config.waypoints, hrp.Position) end
        end)

        local clearWpBtn = Instance.new("TextButton")
        clearWpBtn.Size = UDim2.new(0.46, 0, 0, 24)
        clearWpBtn.Position = UDim2.new(0.51, 0, 0, 205)
        clearWpBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        clearWpBtn.Text = "Очистить точки"
        clearWpBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
        clearWpBtn.Font = Font_Code
        clearWpBtn.TextSize = 11
        clearWpBtn.Parent = surfGroup
        Instance.new("UICorner", clearWpBtn).CornerRadius = UDim.new(0, 4)

        clearWpBtn.MouseButton1Click:Connect(function()
            Config.waypoints = {}
            Config.currentWaypointIndex = 1
        end)

        table.insert(sections, {group = surfGroup, title = surfTitle, fullHeight = 235})
    end

    setupCollapsibleSections(movFrame, sections)
end

-- 5. MISC TAB
local function buildMiscTab()
    local miscFrame = tabFrames["Misc"]
    local sections = {}

    do
        local trashGroup = Instance.new("Frame")
        trashGroup.Size = UDim2.new(0.96, 0, 0, 115)
        trashGroup.BackgroundColor3 = NF_GROUP
        trashGroup.BorderSizePixel = 0
        trashGroup.Parent = miscFrame
        registerThemeElement(trashGroup, "group")

        Instance.new("UICorner", trashGroup).CornerRadius = UDim.new(0, 6)
        local trashGroupStroke = Instance.new("UIStroke")
        trashGroupStroke.Color = NF_BORDER
        trashGroupStroke.Thickness = 1
        trashGroupStroke.Parent = trashGroup
        registerThemeElement(trashGroupStroke, "groupStroke")

        local trashTitle = Instance.new("TextLabel")
        trashTitle.Size = UDim2.new(1, -20, 0, 25)
        trashTitle.Position = UDim2.new(0, 12, 0, 4)
        trashTitle.BackgroundTransparency = 1
        trashTitle.Text = "TRASHTALK SYSTEM"
        trashTitle.TextColor3 = NF_TEXT
        trashTitle.TextXAlignment = Enum.TextXAlignment.Left
        trashTitle.Font = Font_Code
        trashTitle.TextSize = 12
        trashTitle.Parent = trashGroup
        registerThemeElement(trashTitle, "title")

        local trashToggleLbl = Instance.new("TextLabel")
        trashToggleLbl.Size = UDim2.new(0, 150, 0, 25)
        trashToggleLbl.Position = UDim2.new(0, 12, 0, 35)
        trashToggleLbl.BackgroundTransparency = 1
        trashToggleLbl.Text = "Enable TrashTalk"
        trashToggleLbl.TextColor3 = NF_DARK_TEXT
        trashToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        trashToggleLbl.Font = Font_Code
        trashToggleLbl.TextSize = 13
        trashToggleLbl.Parent = trashGroup
        registerThemeElement(trashToggleLbl, "label")

        local trashToggleBtn = Instance.new("TextButton")
        trashToggleBtn.Size = UDim2.new(0, 110, 0, 26)
        trashToggleBtn.Position = UDim2.new(1, -122, 0, 35)
        trashToggleBtn.BackgroundColor3 = Config.trashTalkEnabled and NF_ACCENT or NF_PANEL
        trashToggleBtn.TextColor3 = Config.trashTalkEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        trashToggleBtn.Font = Font_Code
        trashToggleBtn.TextSize = 12
        trashToggleBtn.Text = Config.trashTalkEnabled and "ON" or "OFF"
        trashToggleBtn.Parent = trashGroup
        Instance.new("UICorner", trashToggleBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(trashToggleBtn, "activeToggle")

        trashToggleBtn.MouseButton1Click:Connect(function()
            Config.trashTalkEnabled = not Config.trashTalkEnabled
            trashToggleBtn.Text = Config.trashTalkEnabled and "ON" or "OFF"
            trashToggleBtn.BackgroundColor3 = Config.trashTalkEnabled and NF_ACCENT or NF_PANEL
            trashToggleBtn.TextColor3 = Config.trashTalkEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        local function createTrashKeybindRow(labelText, defaultKeyName, defaultMode, posY, onKeyBindClick, onModeToggleClick)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 130, 0, 25)
            lbl.Position = UDim2.new(0, 12, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = NF_DARK_TEXT
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Font_Code
            lbl.TextSize = 13
            lbl.Parent = trashGroup
            registerThemeElement(lbl, "label")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 85, 0, 26)
            btn.Position = UDim2.new(1, -195, 0, posY)
            btn.BackgroundColor3 = NF_PANEL
            btn.TextColor3 = NF_ACCENT
            btn.Font = Font_Code
            btn.TextSize = 11
            btn.Text = "[" .. defaultKeyName .. "]"
            btn.Parent = trashGroup
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(btn, "buttonPanel")

            local modeBtn = Instance.new("TextButton")
            modeBtn.Size = UDim2.new(0, 70, 0, 26)
            modeBtn.Position = UDim2.new(1, -102, 0, posY)
            modeBtn.BackgroundColor3 = NF_PANEL
            modeBtn.TextColor3 = NF_ORANGE
            modeBtn.Font = Font_Code
            modeBtn.TextSize = 11
            modeBtn.Text = defaultMode
            modeBtn.Parent = trashGroup
            Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 4)
            registerThemeElement(modeBtn, "buttonPanel")

            btn.MouseButton1Click:Connect(function()
                btn.Text = "[ press... ]"
                onKeyBindClick()
            end)

            modeBtn.MouseButton1Click:Connect(function()
                onModeToggleClick(modeBtn)
            end)

            return btn, modeBtn
        end

        UI_Binds.trashTalkKeyBtn, UI_Binds.trashTalkModeBtn = createTrashKeybindRow("TrashTalk Bind", Config.trashTalkKey.Name, Config.trashTalkKeyMode, 72, 
            function() Config.bindingTrashTalkKey = true end,
            function(btn)
                Config.trashTalkKeyMode = (Config.trashTalkKeyMode == "Toggle") and "Hold" or "Toggle"
                btn.Text = Config.trashTalkKeyMode
            end
        )

        table.insert(sections, {group = trashGroup, title = trashTitle, fullHeight = 115})
    end

    -- Chat Clantag Block
    do
        local tagGroup = Instance.new("Frame")
        tagGroup.Size = UDim2.new(0.96, 0, 0, 115)
        tagGroup.BackgroundColor3 = NF_GROUP
        tagGroup.BorderSizePixel = 0
        tagGroup.Parent = miscFrame
        registerThemeElement(tagGroup, "group")

        Instance.new("UICorner", tagGroup).CornerRadius = UDim.new(0, 6)
        local tagGroupStroke = Instance.new("UIStroke")
        tagGroupStroke.Color = NF_BORDER
        tagGroupStroke.Thickness = 1
        tagGroupStroke.Parent = tagGroup
        registerThemeElement(tagGroupStroke, "groupStroke")

        local tagTitle = Instance.new("TextLabel")
        tagTitle.Size = UDim2.new(1, -20, 0, 25)
        tagTitle.Position = UDim2.new(0, 12, 0, 4)
        tagTitle.BackgroundTransparency = 1
        tagTitle.Text = "CHAT CLANTAG"
        tagTitle.TextColor3 = NF_TEXT
        tagTitle.TextXAlignment = Enum.TextXAlignment.Left
        tagTitle.Font = Font_Code
        tagTitle.TextSize = 12
        tagTitle.Parent = tagGroup
        registerThemeElement(tagTitle, "title")

        local enableTagLbl = Instance.new("TextLabel")
        enableTagLbl.Size = UDim2.new(0, 150, 0, 25)
        enableTagLbl.Position = UDim2.new(0, 12, 0, 35)
        enableTagLbl.BackgroundTransparency = 1
        enableTagLbl.Text = "Enable Clantag"
        enableTagLbl.TextColor3 = NF_DARK_TEXT
        enableTagLbl.TextXAlignment = Enum.TextXAlignment.Left
        enableTagLbl.Font = Font_Code
        enableTagLbl.TextSize = 13
        enableTagLbl.Parent = tagGroup
        registerThemeElement(enableTagLbl, "label")

        local enableTagBtn = Instance.new("TextButton")
        enableTagBtn.Size = UDim2.new(0, 110, 0, 26)
        enableTagBtn.Position = UDim2.new(1, -122, 0, 35)
        enableTagBtn.BackgroundColor3 = Config.clantagEnabled and NF_ACCENT or NF_PANEL
        enableTagBtn.TextColor3 = Config.clantagEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        enableTagBtn.Font = Font_Code
        enableTagBtn.TextSize = 12
        enableTagBtn.Text = Config.clantagEnabled and "ON" or "OFF"
        enableTagBtn.Parent = tagGroup
        Instance.new("UICorner", enableTagBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(enableTagBtn, "activeToggle")

        enableTagBtn.MouseButton1Click:Connect(function()
            Config.clantagEnabled = not Config.clantagEnabled
            enableTagBtn.Text = Config.clantagEnabled and "ON" or "OFF"
            enableTagBtn.BackgroundColor3 = Config.clantagEnabled and NF_ACCENT or NF_PANEL
            enableTagBtn.TextColor3 = Config.clantagEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end)

        local tagTextLbl = Instance.new("TextLabel")
        tagTextLbl.Size = UDim2.new(0, 150, 0, 25)
        tagTextLbl.Position = UDim2.new(0, 12, 0, 72)
        tagTextLbl.BackgroundTransparency = 1
        tagTextLbl.Text = "Custom Clantag Text"
        tagTextLbl.TextColor3 = NF_DARK_TEXT
        tagTextLbl.TextXAlignment = Enum.TextXAlignment.Left
        tagTextLbl.Font = Font_Code
        tagTextLbl.TextSize = 13
        tagTextLbl.Parent = tagGroup
        registerThemeElement(tagTextLbl, "label")

        local tagTextBox = Instance.new("TextBox")
        tagTextBox.Size = UDim2.new(0, 110, 0, 26)
        tagTextBox.Position = UDim2.new(1, -122, 0, 72)
        tagTextBox.BackgroundColor3 = NF_PANEL
        tagTextBox.TextColor3 = NF_ACCENT
        tagTextBox.Font = Font_Code
        tagTextBox.TextSize = 12
        tagTextBox.Text = Config.clantagText
        tagTextBox.Parent = tagGroup
        Instance.new("UICorner", tagTextBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(tagTextBox, "inputBox")

        tagTextBox.FocusLost:Connect(function()
            if tagTextBox.Text ~= "" then
                Config.clantagText = tagTextBox.Text
            else
                tagTextBox.Text = Config.clantagText
            end
        end)

        table.insert(sections, {group = tagGroup, title = tagTitle, fullHeight = 115})
    end

    setupCollapsibleSections(miscFrame, sections)
end

-- 6. SETTINGS TAB
local function buildSettingsTab()
    local setFrame = tabFrames["Settings"]
    local sections = {}

    do
        local styleGroup = Instance.new("Frame")
        styleGroup.Size = UDim2.new(0.96, 0, 0, 155)
        styleGroup.BackgroundColor3 = NF_GROUP
        styleGroup.BorderSizePixel = 0
        styleGroup.Parent = setFrame
        registerThemeElement(styleGroup, "group")

        Instance.new("UICorner", styleGroup).CornerRadius = UDim.new(0, 6)
        local styleGroupStroke = Instance.new("UIStroke")
        styleGroupStroke.Color = NF_BORDER
        styleGroupStroke.Thickness = 1
        styleGroupStroke.Parent = styleGroup
        registerThemeElement(styleGroupStroke, "groupStroke")

        local styleTitle = Instance.new("TextLabel")
        styleTitle.Size = UDim2.new(1, -20, 0, 25)
        styleTitle.Position = UDim2.new(0, 12, 0, 4)
        styleTitle.BackgroundTransparency = 1
        styleTitle.TextColor3 = NF_TEXT
        styleTitle.TextXAlignment = Enum.TextXAlignment.Left
        styleTitle.Font = Font_Code
        styleTitle.TextSize = 12
        styleTitle.Parent = styleGroup
        registerThemeElement(styleTitle, "title")

        local presetList = {"Default", "Skeet", "Neverlose", "Primordial", "One tap v3", "Space", "Ocean"}
        local pRowFrame = Instance.new("Frame")
        pRowFrame.Size = UDim2.new(1, -24, 0, 105)
        pRowFrame.Position = UDim2.new(0, 12, 0, 35)
        pRowFrame.BackgroundTransparency = 1
        pRowFrame.Parent = styleGroup

        local pLayout = Instance.new("UIGridLayout")
        pLayout.CellSize = UDim2.new(0.31, 0, 0, 30)
        pLayout.CellPadding = UDim2.new(0.03, 0, 0, 8)
        pLayout.Parent = pRowFrame

        for _, pName in ipairs(presetList) do
            local pBtn = Instance.new("TextButton")
            pBtn.BackgroundColor3 = (pName == Config.currentStylePreset) and NF_ACCENT or NF_PANEL
            pBtn.TextColor3 = (pName == Config.currentStylePreset) and Color3.fromRGB(255,255,255) or NF_DARK_TEXT
            pBtn.Font = Font_Code
            pBtn.TextSize = 11
            pBtn.Text = pName
            pBtn.Parent = pRowFrame
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            pBtn.MouseButton1Click:Connect(function()
                updateUITheme(pName)
                for _, child in ipairs(pRowFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = (child.Text == pName) and NF_ACCENT or NF_PANEL
                        child.TextColor3 = (child.Text == pName) and Color3.fromRGB(255,255,255) or NF_DARK_TEXT
                    end
                end
            end)
        end

        table.insert(sections, {group = styleGroup, title = styleTitle, fullHeight = 155})
    end

    -- CUSTOM THEMES (RGB/HEX)
    do
        local customThemeGroup = Instance.new("Frame")
        customThemeGroup.Size = UDim2.new(0.96, 0, 0, 155)
        customThemeGroup.BackgroundColor3 = NF_GROUP
        customThemeGroup.BorderSizePixel = 0
        customThemeGroup.Parent = setFrame
        registerThemeElement(customThemeGroup, "group")

        Instance.new("UICorner", customThemeGroup).CornerRadius = UDim.new(0, 6)
        local customThemeStroke = Instance.new("UIStroke")
        customThemeStroke.Color = NF_BORDER
        customThemeStroke.Thickness = 1
        customThemeStroke.Parent = customThemeGroup
        registerThemeElement(customThemeStroke, "groupStroke")

        local customThemeTitle = Instance.new("TextLabel")
        customThemeTitle.Size = UDim2.new(1, -20, 0, 25)
        customThemeTitle.Position = UDim2.new(0, 12, 0, 4)
        customThemeTitle.BackgroundTransparency = 1
        customThemeTitle.Text = "CUSTOM THEME BUILDER (HEX / RGB)"
        customThemeTitle.TextColor3 = NF_TEXT
        customThemeTitle.TextXAlignment = Enum.TextXAlignment.Left
        customThemeTitle.Font = Font_Code
        customThemeTitle.TextSize = 12
        customThemeTitle.Parent = customThemeGroup
        registerThemeElement(customThemeTitle, "title")

        local customBgLbl = Instance.new("TextLabel")
        customBgLbl.Size = UDim2.new(0, 180, 0, 25)
        customBgLbl.Position = UDim2.new(0, 12, 0, 35)
        customBgLbl.BackgroundTransparency = 1
        customBgLbl.Text = "Custom Menu BG (RGB/HEX)"
        customBgLbl.TextColor3 = NF_DARK_TEXT
        customBgLbl.TextXAlignment = Enum.TextXAlignment.Left
        customBgLbl.Font = Font_Code
        customBgLbl.TextSize = 13
        customBgLbl.Parent = customThemeGroup
        registerThemeElement(customBgLbl, "label")

        local customBgBox = Instance.new("TextBox")
        customBgBox.Size = UDim2.new(0, 110, 0, 26)
        customBgBox.Position = UDim2.new(1, -122, 0, 35)
        customBgBox.BackgroundColor3 = NF_PANEL
        customBgBox.TextColor3 = NF_ACCENT
        customBgBox.Font = Font_Code
        customBgBox.TextSize = 12
        customBgBox.PlaceholderText = "13, 16, 23"
        customBgBox.Text = ""
        customBgBox.Parent = customThemeGroup
        Instance.new("UICorner", customBgBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(customBgBox, "inputBox")

        customBgBox.FocusLost:Connect(function()
            local col = parseColor(customBgBox.Text)
            if col then Config.customBgColor = col updateUITheme(Config.currentStylePreset) else customBgBox.Text = "" end
        end)

        local customPanelLbl = Instance.new("TextLabel")
        customPanelLbl.Size = UDim2.new(0, 180, 0, 25)
        customPanelLbl.Position = UDim2.new(0, 12, 0, 72)
        customPanelLbl.BackgroundTransparency = 1
        customPanelLbl.Text = "Custom Panel Color (RGB/HEX)"
        customPanelLbl.TextColor3 = NF_DARK_TEXT
        customPanelLbl.TextXAlignment = Enum.TextXAlignment.Left
        customPanelLbl.Font = Font_Code
        customPanelLbl.TextSize = 13
        customPanelLbl.Parent = customThemeGroup
        registerThemeElement(customPanelLbl, "label")

        local customPanelBox = Instance.new("TextBox")
        customPanelBox.Size = UDim2.new(0, 110, 0, 26)
        customPanelBox.Position = UDim2.new(1, -122, 0, 72)
        customPanelBox.BackgroundColor3 = NF_PANEL
        customPanelBox.TextColor3 = NF_ACCENT
        customPanelBox.Font = Font_Code
        customPanelBox.TextSize = 12
        customPanelBox.PlaceholderText = "18, 23, 34"
        customPanelBox.Text = ""
        customPanelBox.Parent = customThemeGroup
        Instance.new("UICorner", customPanelBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(customPanelBox, "inputBox")

        customPanelBox.FocusLost:Connect(function()
            local col = parseColor(customPanelBox.Text)
            if col then Config.customPanelColor = col updateUITheme(Config.currentStylePreset) else customPanelBox.Text = "" end
        end)

        local clearColorsBtn = Instance.new("TextButton")
        clearColorsBtn.Size = UDim2.new(1, -24, 0, 26)
        clearColorsBtn.Position = UDim2.new(0, 12, 0, 112)
        clearColorsBtn.BackgroundColor3 = NF_PANEL
        clearColorsBtn.TextColor3 = NF_ACCENT
        clearColorsBtn.Font = Font_Code
        clearColorsBtn.TextSize = 12
        clearColorsBtn.Text = "Reset Custom Theme Colors"
        clearColorsBtn.Parent = customThemeGroup
        Instance.new("UICorner", clearColorsBtn).CornerRadius = UDim.new(0, 4)
        registerThemeElement(clearColorsBtn, "buttonPanel")

        clearColorsBtn.MouseButton1Click:Connect(function()
            Config.customBgColor = nil
            Config.customPanelColor = nil
            customBgBox.Text = ""
            customPanelBox.Text = ""
            updateUITheme(Config.currentStylePreset)
        end)

        table.insert(sections, {group = customThemeGroup, title = customThemeTitle, fullHeight = 155})
    end

    -- Menu Scale & Keybind
    do
        local menuScaleGroup = Instance.new("Frame")
        menuScaleGroup.Size = UDim2.new(0.96, 0, 0, 115)
        menuScaleGroup.BackgroundColor3 = NF_GROUP
        menuScaleGroup.BorderSizePixel = 0
        menuScaleGroup.Parent = setFrame
        registerThemeElement(menuScaleGroup, "group")

        Instance.new("UICorner", menuScaleGroup).CornerRadius = UDim.new(0, 6)
        local menuScaleGroupStroke = Instance.new("UIStroke")
        menuScaleGroupStroke.Color = NF_BORDER
        menuScaleGroupStroke.Thickness = 1
        menuScaleGroupStroke.Parent = menuScaleGroup
        registerThemeElement(menuScaleGroupStroke, "groupStroke")

        local menuScaleTitle = Instance.new("TextLabel")
        menuScaleTitle.Size = UDim2.new(1, -20, 0, 25)
        menuScaleTitle.Position = UDim2.new(0, 12, 0, 4)
        menuScaleTitle.BackgroundTransparency = 1
        menuScaleTitle.TextColor3 = NF_TEXT
        menuScaleTitle.TextXAlignment = Enum.TextXAlignment.Left
        menuScaleTitle.Font = Font_Code
        menuScaleTitle.TextSize = 12
        menuScaleTitle.Parent = menuScaleGroup
        registerThemeElement(menuScaleTitle, "title")

        local scaleLbl = Instance.new("TextLabel")
        scaleLbl.Size = UDim2.new(0, 180, 0, 25)
        scaleLbl.Position = UDim2.new(0, 12, 0, 35)
        scaleLbl.BackgroundTransparency = 1
        scaleLbl.Text = "Menu Scale (50% - 200%)"
        scaleLbl.TextColor3 = NF_DARK_TEXT
        scaleLbl.TextXAlignment = Enum.TextXAlignment.Left
        scaleLbl.Font = Font_Code
        scaleLbl.TextSize = 13
        scaleLbl.Parent = menuScaleGroup
        registerThemeElement(scaleLbl, "label")

        local scaleBox = Instance.new("TextBox")
        scaleBox.Size = UDim2.new(0, 70, 0, 26)
        scaleBox.Position = UDim2.new(1, -82, 0, 35)
        scaleBox.BackgroundColor3 = NF_PANEL
        scaleBox.TextColor3 = NF_ACCENT
        scaleBox.Font = Font_Code
        scaleBox.TextSize = 13
        scaleBox.Text = tostring(math.floor(Config.uiScaleValue * 100)) .. "%"
        scaleBox.Parent = menuScaleGroup
        Instance.new("UICorner", scaleBox).CornerRadius = UDim.new(0, 4)
        registerThemeElement(scaleBox, "inputBox")

        scaleBox.FocusLost:Connect(function()
            local cleanVal = string.gsub(scaleBox.Text, "%%", "")
            local val = tonumber(cleanVal)
            if val then
                val = math.clamp(val, 50, 200)
                Config.uiScaleValue = val / 100
                uiScaleObj.Scale = Config.uiScaleValue
                scaleBox.Text = tostring(val) .. "%"
            else
                scaleBox.Text = tostring(math.floor(Config.uiScaleValue * 100)) .. "%"
            end
        end)

        local menuToggleLbl = Instance.new("TextLabel")
        menuToggleLbl.Size = UDim2.new(0, 180, 0, 25)
        menuToggleLbl.Position = UDim2.new(0, 12, 0, 72)
        menuToggleLbl.BackgroundTransparency = 1
        menuToggleLbl.Text = "Toggle Menu Keybind"
        menuToggleLbl.TextColor3 = NF_DARK_TEXT
        menuToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
        menuToggleLbl.Font = Font_Code
        menuToggleLbl.TextSize = 13
        menuToggleLbl.Parent = menuScaleGroup
        registerThemeElement(menuToggleLbl, "label")

        UI_Binds.menuToggleBtnKey = Instance.new("TextButton")
        UI_Binds.menuToggleBtnKey.Size = UDim2.new(0, 110, 0, 26)
        UI_Binds.menuToggleBtnKey.Position = UDim2.new(1, -122, 0, 72)
        UI_Binds.menuToggleBtnKey.BackgroundColor3 = NF_PANEL
        UI_Binds.menuToggleBtnKey.TextColor3 = NF_ACCENT
        UI_Binds.menuToggleBtnKey.Font = Font_Code
        UI_Binds.menuToggleBtnKey.TextSize = 12
        UI_Binds.menuToggleBtnKey.Text = "[" .. Config.menuToggleKey.Name .. "]"
        UI_Binds.menuToggleBtnKey.Parent = menuScaleGroup
        Instance.new("UICorner", UI_Binds.menuToggleBtnKey).CornerRadius = UDim.new(0, 4)
        registerThemeElement(UI_Binds.menuToggleBtnKey, "buttonPanel")

        UI_Binds.menuToggleBtnKey.MouseButton1Click:Connect(function()
            UI_Binds.menuToggleBtnKey.Text = "[ press... ]"
            Config.bindingMenuToggleKey = true
        end)

        table.insert(sections, {group = menuScaleGroup, title = menuScaleTitle, fullHeight = 115})
    end

    setupCollapsibleSections(setFrame, sections)
end

-- Сборка интерфейса
buildRageTab()
buildLegitTab()
buildVisualsTab()
buildMovementTab()
buildMiscTab()
buildSettingsTab()

updateUITheme("Default")

-- ==========================================
-- ПЛАВНАЯ АНИМАЦИЯ ОТКРЫТИЯ МЕНЮ (FADE IN/OUT)
-- ==========================================
local isMenuTweening = false
local function toggleMenuAnimated(visible)
    if isMenuTweening then return end
    isMenuTweening = true
    Config.menuVisible = visible
    
    if visible then
        mainFrame.Visible = true
        mainFrame.BackgroundTransparency = 1
        mainStroke.Transparency = 1
        local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        })
        TweenService:Create(mainStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Transparency = 0
        }):Play()
        openTween:Play()
        openTween.Completed:Connect(function() isMenuTweening = false end)
    else
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        TweenService:Create(mainStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Transparency = 1
        }):Play()
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            isMenuTweening = false
        end)
    end
end

-- ==========================================
-- ИНТРО
-- ==========================================
task.spawn(function()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "NeverfixIntroGui"
    introGui.ResetOnSpawn = false
    introGui.Parent = parentGui

    local introOverlay = Instance.new("Frame")
    introOverlay.Size = UDim2.new(1, 0, 1, 0)
    introOverlay.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
    introOverlay.BackgroundTransparency = 1
    introOverlay.BorderSizePixel = 0
    introOverlay.Parent = introGui

    local introBlur = Instance.new("BlurEffect")
    introBlur.Size = 0
    introBlur.Name = "NeverfixIntroBlur"
    introBlur.Parent = Lighting

    local introContainer = Instance.new("Frame")
    introContainer.Size = UDim2.new(0, 500, 0, 120)
    introContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    introContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    introContainer.BackgroundTransparency = 1
    introContainer.Parent = introGui

    local nIcon = Instance.new("TextLabel")
    nIcon.Size = UDim2.new(0, 90, 0, 90)
    nIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    nIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    nIcon.BackgroundTransparency = 1
    nIcon.Text = "N"
    nIcon.TextColor3 = NF_ACCENT
    nIcon.Font = Font_Code
    nIcon.TextSize = 85
    nIcon.TextTransparency = 1
    nIcon.Parent = introContainer

    local introTitle = Instance.new("TextLabel")
    introTitle.Size = UDim2.new(0, 320, 0, 45)
    introTitle.Position = UDim2.new(0.5, -40, 0.5, -30)
    introTitle.BackgroundTransparency = 1
    introTitle.Text = "EverFix v1.4"
    introTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
    introTitle.TextXAlignment = Enum.TextXAlignment.Left
    introTitle.Font = Font_Code
    introTitle.TextSize = 36
    introTitle.TextTransparency = 1
    introTitle.Parent = introContainer

    local introSub = Instance.new("TextLabel")
    introSub.Size = UDim2.new(0, 320, 0, 25)
    introSub.Position = UDim2.new(0.5, -40, 0.5, 15)
    introSub.BackgroundTransparency = 1
    introSub.Text = "(Made by timartx)"
    introSub.TextColor3 = Color3.fromRGB(150, 165, 195)
    introSub.TextXAlignment = Enum.TextXAlignment.Left
    introSub.Font = Font_Code
    introSub.TextSize = 18
    introSub.TextTransparency = 1
    introSub.Parent = introContainer

    TweenService:Create(introBlur, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 20}):Play()
    TweenService:Create(introOverlay, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
    TweenService:Create(nIcon, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.wait(1.0)

    TweenService:Create(nIcon, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -140, 0.5, 0)}):Play()
    task.wait(0.2)
    TweenService:Create(introTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(introSub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.wait(2.2)

    TweenService:Create(introBlur, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()
    TweenService:Create(introOverlay, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(nIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    TweenService:Create(introTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    TweenService:Create(introSub, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()

    task.wait(0.7)
    introGui:Destroy()
    introBlur:Destroy()

    toggleMenuAnimated(Config.menuVisible)
end)

-- ==========================================
-- ESP LOGIC & MM2 ROLE DETECTOR
-- ==========================================
local function getMM2Role(plr)
    if not plr or not plr.Parent then return "Innocent" end
    local char = plr.Character
    local backpack = plr:FindFirstChild("Backpack")

    local function checkItem(item)
        if item and item:IsA("Tool") then
            local lname = string.lower(item.Name)
            if lname:find("knife") or item:FindFirstChild("KnifeHost") or item:FindFirstChild("Effect") then
                return "Murderer"
            elseif lname:find("gun") or lname:find("revolver") or item:FindFirstChild("GunScript") then
                return "Sheriff"
            end
        end
        return nil
    end

    if char then
        for _, child in ipairs(char:GetChildren()) do
            local role = checkItem(child)
            if role then return role end
        end
    end

    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            local role = checkItem(child)
            if role then return role end
        end
    end

    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local pd = rep:FindFirstChild("PlayerData")
        if pd and pd:FindFirstChild(plr.Name) then
            local pFolder = pd[plr.Name]
            local roleVal = pFolder:FindFirstChild("Role") or pFolder:FindFirstChild("RoleValue")
            if roleVal then
                local rStr = tostring(roleVal.Value):lower()
                if rStr:find("murder") then return "Murderer"
                elseif rStr:find("sheriff") or rStr:find("hero") then return "Sheriff" end
            end
        end
    end)
    return "Innocent"
end

local function getMM2RoleColor(plr)
    local role = getMM2Role(plr)
    if role == "Murderer" then return Config.murdererColor, " [MURDERER]"
    elseif role == "Sheriff" then return Config.sheriffColor, " [SHERIFF]"
    else return Config.innocentColor, " [INNOCENT]" end
end

local espGui = Instance.new("ScreenGui")
espGui.Name = "NeverfixEspGui"
espGui.ResetOnSpawn = false
espGui.Parent = parentGui

local activeBoxes = {}
local activeHighlights = {}
local playerThumbnails = {}

local function getPlayerColor(plr)
    if Config.mm2RoleEspEnabled then
        local col, _ = getMM2RoleColor(plr)
        return col
    end
    if Config.teamColorsEnabled and LocalPlayer.Team and plr.Team then
        return (plr.Team == LocalPlayer.Team) and Config.teammateColor or Config.enemyColor
    end
    return (plr.TeamColor and plr.TeamColor.Color) or Config.enemyColor
end

local function applyESPToPlayer(plr)
    if plr == LocalPlayer then return end

    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESPBox_" .. plr.Name
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Visible = false
    boxFrame.Parent = espGui
    boxFrame.AnchorPoint = Vector2.new(0.5, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Config.enemyColor
    stroke.Transparency = 1
    stroke.Parent = boxFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 15)
    nameLabel.Position = UDim2.new(0, 0, 0, -18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Font_Code
    nameLabel.TextSize = 11
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = boxFrame

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 90, 0, 24)
    avatarFrame.BackgroundTransparency = 0.2
    avatarFrame.BorderSizePixel = 0
    avatarFrame.Visible = false
    avatarFrame.Parent = espGui
    local avatarCorner = Instance.new("UICorner") avatarCorner.CornerRadius = UDim.new(0,4) avatarCorner.Parent = avatarFrame

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 20, 0, 20)
    avatarImage.Position = UDim2.new(0, 4, 0, 2)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = ""
    avatarImage.Parent = avatarFrame
    Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(0,3)

    local avatarName = Instance.new("TextLabel")
    avatarName.Size = UDim2.new(1, -28, 1, 0)
    avatarName.Position = UDim2.new(0, 28, 0, 0)
    avatarName.BackgroundTransparency = 1
    avatarName.Text = plr.Name
    avatarName.TextColor3 = Color3.fromRGB(255,255,255)
    avatarName.Font = Font_Code
    avatarName.TextSize = 12
    avatarName.TextXAlignment = Enum.TextXAlignment.Left
    avatarName.Parent = avatarFrame

    activeBoxes[plr] = {box = boxFrame, stroke = stroke, nameTag = nameLabel, avatarFrame = avatarFrame, avatarImage = avatarImage, avatarName = avatarName}

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight_" .. plr.Name
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 1
    highlight.Enabled = false
    highlight.Parent = espGui

    activeHighlights[plr] = highlight

    coroutine.wrap(function()
        pcall(function()
            local success, thumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48)
            end)
            if success and thumbnail then
                playerThumbnails[plr] = thumbnail
                avatarImage.Image = thumbnail
            end
        end)
    end)()
end

for _, plr in ipairs(Players:GetPlayers()) do applyESPToPlayer(plr) end
Players.PlayerAdded:Connect(applyESPToPlayer)
Players.PlayerRemoving:Connect(function(plr)
    if activeBoxes[plr] then activeBoxes[plr].box:Destroy() activeBoxes[plr] = nil end
    if activeHighlights[plr] then activeHighlights[plr]:Destroy() activeHighlights[plr] = nil end
    if playerThumbnails[plr] then playerThumbnails[plr] = nil end
end)

local function render2DEsp(plr, data, hrp, phead)
    local box = data.box
    local stroke = data.stroke
    local nameTag = data.nameTag
    local avatarFrame = data.avatarFrame
    local avatarImage = data.avatarImage
    local avatarName = data.avatarName

    local headPos, headOnScreen = Camera:WorldToViewportPoint(phead.Position + Vector3.new(0, 0.6, 0))
    local legPos, legOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

    if headOnScreen or legOnScreen then
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height * 0.65

        box.AnchorPoint = Vector2.new(0.5, 0)
        box.Size = UDim2.new(0, width, 0, math.max(32, height))

        local topY = headPos.Y - (height * 0.9)
        box.Position = UDim2.new(0, headPos.X, 0, topY)

        stroke.Color = getPlayerColor(plr)

        if Config.namesEspEnabled then
            local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
            local roleTag = ""
            if Config.mm2RoleEspEnabled then
                local _, tag = getMM2RoleColor(plr)
                roleTag = tag
            end
            nameTag.Text = string.format("%s%s [%dm]", plr.Name, roleTag, dist)
            nameTag.TextColor3 = getPlayerColor(plr)
            nameTag.Visible = true
        else
            nameTag.Visible = false
        end

        if Config.showMiniAvatar then
            avatarFrame.Visible = true
            avatarFrame.Position = UDim2.new(0, headPos.X - 45, 0, topY - 28)
            avatarFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
            avatarFrame.BorderSizePixel = 1
            avatarFrame.BorderColor3 = getPlayerColor(plr)
            avatarName.TextColor3 = getPlayerColor(plr)
            avatarName.Text = plr.Name
            if playerThumbnails[plr] then avatarImage.Image = playerThumbnails[plr] end
        else
            avatarFrame.Visible = false
        end

        box.Visible = true
    else
        box.Visible = false
        if avatarFrame then avatarFrame.Visible = false end
    end
end

-- ==========================================
-- FAKE LAG ENGINE
-- ==========================================
local fakeLagCounter = 0
RunService.Heartbeat:Connect(function()
    if Config.fakeLagEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            fakeLagCounter = fakeLagCounter + 1
            local limit = Config.fakeLagLimit or 10
            if Config.fakeLagModes[Config.fakeLagModeIndex] == "Random" then
                limit = math.random(2, math.max(3, Config.fakeLagLimit))
            end

            if fakeLagCounter < limit then
                if sethiddenproperty then
                    pcall(function() sethiddenproperty(hrp, "NetworkIsSpatiallyDisjoint", true) end)
                end
            else
                fakeLagCounter = 0
                if sethiddenproperty then
                    pcall(function() sethiddenproperty(hrp, "NetworkIsSpatiallyDisjoint", false) end)
                end
            end
        end
    else
        fakeLagCounter = 0
    end
end)

-- ==========================================
-- КЛАВИАТУРНЫЙ ОБРАБОТЧИК БИНДОВ
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gpe)
    -- Меню кейбинд
    if Config.bindingMenuToggleKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.menuToggleKey = input.KeyCode
        if UI_Binds.menuToggleBtnKey then UI_Binds.menuToggleBtnKey.Text = "[" .. Config.menuToggleKey.Name .. "]" end
        Config.bindingMenuToggleKey = false
        return
    end

    -- AA Base Keybinds
    if Config.bindingAAToggleKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.aaToggleKey = input.KeyCode
        if UI_Binds.aaToggleBtnKey then UI_Binds.aaToggleBtnKey.Text = "[" .. Config.aaToggleKey.Name .. "]" end
        Config.bindingAAToggleKey = false
        return
    end

    if Config.bindingAAKeyLeft and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.aaKeyLeft = input.KeyCode
        if UI_Binds.aaLeftBtn then UI_Binds.aaLeftBtn.Text = "[" .. Config.aaKeyLeft.Name .. "]" end
        Config.bindingAAKeyLeft = false
        return
    end

    if Config.bindingAAKeyBack and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.aaKeyBack = input.KeyCode
        if UI_Binds.aaBackBtn then UI_Binds.aaBackBtn.Text = "[" .. Config.aaKeyBack.Name .. "]" end
        Config.bindingAAKeyBack = false
        return
    end

    if Config.bindingAAKeyRight and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.aaKeyRight = input.KeyCode
        if UI_Binds.aaRightBtn then UI_Binds.aaRightBtn.Text = "[" .. Config.aaKeyRight.Name .. "]" end
        Config.bindingAAKeyRight = false
        return
    end

    if Config.bindingAAKeyFront and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.aaKeyFront = input.KeyCode
        if UI_Binds.aaFrontBtn then UI_Binds.aaFrontBtn.Text = "[" .. Config.aaKeyFront.Name .. "]" end
        Config.bindingAAKeyFront = false
        return
    end

    -- Rage AA Jitter Keybind
    if Config.bindingRageAABindKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.rageAABindKey = input.KeyCode
        if UI_Binds.rageAABindBtnKey then UI_Binds.rageAABindBtnKey.Text = "[" .. Config.rageAABindKey.Name .. "]" end
        Config.bindingRageAABindKey = false
        return
    end

    -- FakeLag Keybind
    if Config.bindingFakeLagBindKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.fakeLagBindKey = input.KeyCode
        if UI_Binds.fakeLagBindBtnKey then UI_Binds.fakeLagBindBtnKey.Text = "[" .. Config.fakeLagBindKey.Name .. "]" end
        Config.bindingFakeLagBindKey = false
        return
    end

    -- SlideWalk Keybind
    if Config.bindingSlideWalkKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.slideWalkKey = input.KeyCode
        if UI_Binds.slideWalkKeyBtn then UI_Binds.slideWalkKeyBtn.Text = "[" .. Config.slideWalkKey.Name .. "]" end
        Config.bindingSlideWalkKey = false
        return
    end

    -- AirStuck Keybind
    if Config.bindingAirStuckKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.airStuckKey = input.KeyCode
        if UI_Binds.airStuckKeyBtn then UI_Binds.airStuckKeyBtn.Text = "[" .. Config.airStuckKey.Name .. "]" end
        Config.bindingAirStuckKey = false
        return
    end

    -- Surf / Waypoint / TrashTalk Keybinds
    if Config.bindingSurfKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.pixelSurfKey = input.KeyCode
        if UI_Binds.surfKeyBtn then UI_Binds.surfKeyBtn.Text = "[" .. Config.pixelSurfKey.Name .. "]" end
        Config.bindingSurfKey = false
        return
    end

    if Config.bindingWaypointKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.setWaypointKey = input.KeyCode
        if UI_Binds.waypointKeyBtn then UI_Binds.waypointKeyBtn.Text = "[" .. Config.setWaypointKey.Name .. "]" end
        Config.bindingWaypointKey = false
        return
    end

    if Config.bindingTrashTalkKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.trashTalkKey = input.KeyCode
        if UI_Binds.trashTalkKeyBtn then UI_Binds.trashTalkKeyBtn.Text = "[" .. Config.trashTalkKey.Name .. "]" end
        Config.bindingTrashTalkKey = false
        return
    end

    -- Menu Toggle
    if input.KeyCode == Config.menuToggleKey then
        toggleMenuAnimated(not Config.menuVisible)
        return
    end

    if UserInputService:GetFocusedTextBox() or gpe then return end

    -- AA Toggle Trigger
    if Config.aaToggleKey ~= Enum.KeyCode.Unknown and input.KeyCode == Config.aaToggleKey then
        if Config.aaToggleKeyMode == "Toggle" then
            Config.aaEnabled = not Config.aaEnabled
        else
            Config.aaEnabled = true
        end
        if aaToggleBtn then
            aaToggleBtn.Text = Config.aaEnabled and "ON" or "OFF"
            aaToggleBtn.BackgroundColor3 = Config.aaEnabled and NF_ACCENT or NF_PANEL
            aaToggleBtn.TextColor3 = Config.aaEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end
        updateKeybindItem("Anti-Aim", Config.aaToggleKey.Name, Config.aaToggleKeyMode, Config.aaEnabled)
    end

    -- Rage Jitter Key Trigger
    if Config.rageAABindKey ~= Enum.KeyCode.Unknown and input.KeyCode == Config.rageAABindKey then
        if Config.rageAABindMode == "Toggle" then
            Config.rageAAEnabled = not Config.rageAAEnabled
        else
            Config.rageAAEnabled = true
        end
        if rageAAToggleBtnGlobal then
            rageAAToggleBtnGlobal.Text = Config.rageAAEnabled and "ON" or "OFF"
            rageAAToggleBtnGlobal.BackgroundColor3 = Config.rageAAEnabled and NF_ACCENT or NF_PANEL
            rageAAToggleBtnGlobal.TextColor3 = Config.rageAAEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end
        updateKeybindItem("Rage Jitter", Config.rageAABindKey.Name, Config.rageAABindMode, Config.rageAAEnabled)
    end

    -- FakeLag Key Trigger
    if Config.fakeLagBindKey ~= Enum.KeyCode.Unknown and input.KeyCode == Config.fakeLagBindKey then
        if Config.fakeLagBindMode == "Toggle" then
            Config.fakeLagEnabled = not Config.fakeLagEnabled
        else
            Config.fakeLagEnabled = true
        end
        if fakeLagToggleBtnGlobal then
            fakeLagToggleBtnGlobal.Text = Config.fakeLagEnabled and "ON" or "OFF"
            fakeLagToggleBtnGlobal.BackgroundColor3 = Config.fakeLagEnabled and NF_ACCENT or NF_PANEL
            fakeLagToggleBtnGlobal.TextColor3 = Config.fakeLagEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end
        updateKeybindItem("Fake Lag", Config.fakeLagBindKey.Name, Config.fakeLagBindMode, Config.fakeLagEnabled)
    end

    -- SlideWalk Key Trigger
    if Config.slideWalkKey ~= Enum.KeyCode.Unknown and input.KeyCode == Config.slideWalkKey then
        if Config.slideWalkKeyMode == "Toggle" then
            Config.slideWalkEnabled = not Config.slideWalkEnabled
        else
            Config.slideWalkEnabled = true
        end
        if slideWalkToggleBtnGlobal then
            slideWalkToggleBtnGlobal.Text = Config.slideWalkEnabled and "ON" or "OFF"
            slideWalkToggleBtnGlobal.BackgroundColor3 = Config.slideWalkEnabled and NF_ACCENT or NF_PANEL
            slideWalkToggleBtnGlobal.TextColor3 = Config.slideWalkEnabled and Color3.fromRGB(255, 255, 255) or NF_DARK_TEXT
        end
        updateKeybindItem("SlideWalk", Config.slideWalkKey.Name, Config.slideWalkKeyMode, Config.slideWalkEnabled)
    end

    -- AirStuck Key Trigger
    if Config.airStuckKey ~= Enum.KeyCode.Unknown and input.KeyCode == Config.airStuckKey then
        if Config.airStuckKeyMode == "Toggle" then
            Config.isAirStuckActive = not Config.isAirStuckActive
        else
            Config.isAirStuckActive = true
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if Config.isAirStuckActive and hrp then
            Config.airStuckFrozenCFrame = hrp.CFrame
        else
            Config.airStuckFrozenCFrame = nil
        end
        updateKeybindItem("AirStuck", Config.airStuckKey.Name, Config.airStuckKeyMode, Config.isAirStuckActive)
    end

    -- Surf Key Trigger
    if input.KeyCode == Config.pixelSurfKey then
        local prevState = Config.isSurfKeyPressed
        if Config.surfKeyMode == "Toggle" then
            Config.isSurfKeyPressed = not Config.isSurfKeyPressed
            setPSIndicatorVisible(Config.isSurfKeyPressed)
        else
            Config.isSurfKeyPressed = true
            setPSIndicatorVisible(true)
        end
        if Config.isSurfKeyPressed and not prevState then Config.requestSurfFallAnimation = true end
        updateKeybindItem("Pixel Surf", Config.pixelSurfKey.Name, Config.surfKeyMode, Config.isSurfKeyPressed)
    elseif input.KeyCode == Config.setWaypointKey and Config.surfModeIndex == 2 then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then table.insert(Config.waypoints, hrp.Position) end
    elseif Config.trashTalkEnabled and input.KeyCode == Config.trashTalkKey then
        sendTrashTalk()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Config.pixelSurfKey and Config.surfKeyMode == "Hold" then
        Config.isSurfKeyPressed = false
        setPSIndicatorVisible(false)
        updateKeybindItem("Pixel Surf", Config.pixelSurfKey.Name, Config.surfKeyMode, false)
    elseif input.KeyCode == Config.aaToggleKey and Config.aaToggleKeyMode == "Hold" then
        Config.aaEnabled = false
        if aaToggleBtn then aaToggleBtn.Text = "OFF" aaToggleBtn.BackgroundColor3 = NF_PANEL end
        updateKeybindItem("Anti-Aim", Config.aaToggleKey.Name, Config.aaToggleKeyMode, false)
    elseif input.KeyCode == Config.rageAABindKey and Config.rageAABindMode == "Hold" then
        Config.rageAAEnabled = false
        if rageAAToggleBtnGlobal then rageAAToggleBtnGlobal.Text = "OFF" rageAAToggleBtnGlobal.BackgroundColor3 = NF_PANEL end
        updateKeybindItem("Rage Jitter", Config.rageAABindKey.Name, Config.rageAABindMode, false)
    elseif input.KeyCode == Config.fakeLagBindKey and Config.fakeLagBindMode == "Hold" then
        Config.fakeLagEnabled = false
        if fakeLagToggleBtnGlobal then fakeLagToggleBtnGlobal.Text = "OFF" fakeLagToggleBtnGlobal.BackgroundColor3 = NF_PANEL end
        updateKeybindItem("Fake Lag", Config.fakeLagBindKey.Name, Config.fakeLagBindMode, false)
    elseif input.KeyCode == Config.slideWalkKey and Config.slideWalkKeyMode == "Hold" then
        Config.slideWalkEnabled = false
        if slideWalkToggleBtnGlobal then slideWalkToggleBtnGlobal.Text = "OFF" slideWalkToggleBtnGlobal.BackgroundColor3 = NF_PANEL end
        updateKeybindItem("SlideWalk", Config.slideWalkKey.Name, Config.slideWalkKeyMode, false)
    elseif input.KeyCode == Config.airStuckKey and Config.airStuckKeyMode == "Hold" then
        Config.isAirStuckActive = false
        Config.airStuckFrozenCFrame = nil
        updateKeybindItem("AirStuck", Config.airStuckKey.Name, Config.airStuckKeyMode, false)
    end
end)

-- ==========================================
-- ОСНОВНОЙ РЕНДЕР И ПОВЕДЕНИЕ
-- ==========================================
local frameCount = 0
local lastFpsUpdate = tick()
local currentFps = 60

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsUpdate >= 0.5 then
        currentFps = math.floor(frameCount / (now - lastFpsUpdate))
        frameCount = 0
        lastFpsUpdate = now
    end

    local mouseLoc = UserInputService:GetMouseLocation()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- 1. WATERMARK UPDATE
    if Config.showWatermarkHUD and wmFrame.Visible then
        wmCorner.CornerRadius = (Config.hudStyle == "Round") and UDim.new(0, 13) or UDim.new(0, 0)
        local parts = {}
        if Config.hudNickname and Config.hudNickname ~= "" then table.insert(parts, Config.hudNickname) end
        if Config.showGameName then table.insert(parts, CurrentGameName) end
        if Config.showFps then table.insert(parts, currentFps .. " fps") end
        if Config.showPing then
            local pingVal = 0
            pcall(function() pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            table.insert(parts, pingVal .. " ms")
        end
        if Config.showTime then table.insert(parts, os.date("%H:%M:%S")) end

        local finalStr = table.concat(parts, "  |  ")
        if finalStr == "" then finalStr = "60 fps | 0ms" end
        wmText.Text = finalStr
        
        local textSize = game:GetService("TextService"):GetTextSize(finalStr, 12, Font_Code, Vector2.new(1200, 26))
        wmFrame.Size = UDim2.new(0, textSize.X + 80, 0, 26)
    end

    -- 2. AIRSTUCK LOGIC
    if (Config.airStuckEnabled or Config.isAirStuckActive) and hrp and hum and hum.Health > 0 then
        if Config.isAirStuckActive then
            if not Config.airStuckFrozenCFrame then Config.airStuckFrozenCFrame = hrp.CFrame end
            hrp.CFrame = Config.airStuckFrozenCFrame
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end

    -- 3. SLIDEWALK (NEVERLOSE / SKEET MOONWALK)
    if Config.slideWalkEnabled and hrp and hum and hum.Health > 0 then
        if hum.MoveDirection.Magnitude > 0 then
            -- Фиксируем направление ног и тела назад или скользящим углом
            local moveAngle = math.atan2(hum.MoveDirection.X, hum.MoveDirection.Z)
            local currentYaw = math.atan2(hrp.CFrame.LookVector.X, hrp.CFrame.LookVector.Z)
            if math.abs(moveAngle - currentYaw) < math.pi / 2 then
                -- Moonwalk inverted legs animation effect
                hum.AutoRotate = false
            end
        end
    end

    -- 4. ANTI-AIM SYSTEM
    if Config.aaEnabled and hrp and hum and hum.Health > 0 and not Config.isAirStuckActive then
        hum.AutoRotate = false
        local camLook = Camera.CFrame.LookVector
        local camYaw = math.atan2(-camLook.X, -camLook.Z)
        local targetYaw = camYaw

        if Config.rageAAEnabled then
            local delayTime = Config.rageAADelay or 0.066
            if Config.rageRandomSpeedEnabled then
                delayTime = Config.currentRandomDelay or 0.066
            end

            if now - Config.lastRageAATick >= delayTime then
                Config.lastRageAATick = now
                Config.rageAAFlipState = not Config.rageAAFlipState
            end

            local jitterAngle = Config.rageAAFlipState and Config.rageAAAngle or -Config.rageAAAngle
            targetYaw = camYaw + math.rad(jitterAngle + Config.aaYawOffset)
        else
            local mode = Config.aaModes[Config.aaModeIndex]
            if mode == "Spin" then
                Config.currentSpinAngle = (Config.currentSpinAngle + Config.aaSpinSpeed) % 360
                targetYaw = math.rad(Config.currentSpinAngle + Config.aaYawOffset)
            elseif mode == "Camera" then
                targetYaw = camYaw + math.rad(Config.aaYawOffset)
            elseif mode == "Manual" then
                local manualDir = Config.aaManualDirs[Config.aaManualDirIndex]
                local dirAngle = 180
                if manualDir == "Left" then dirAngle = -90
                elseif manualDir == "Right" then dirAngle = 90
                elseif manualDir == "Front" then dirAngle = 0 end
                targetYaw = camYaw + math.rad(dirAngle + Config.aaYawOffset)
            elseif mode == "Custom" then
                targetYaw = camYaw + math.rad(Config.aaYawOffset)
            end
        end

        local pitchMode = Config.aaPitchModes[Config.aaPitchIndex]
        local targetPitch = 0
        if pitchMode == "Down" then targetPitch = math.rad(-89)
        elseif pitchMode == "Up" then targetPitch = math.rad(89)
        elseif pitchMode == "Custom" then 
            local speed = Config.pitchChangeSpeed or 5
            targetPitch = math.rad(Config.aaPitchOffset * math.sin(tick() * speed))
        end

        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, targetYaw, 0) * CFrame.Angles(targetPitch, 0, 0)
    elseif hum and not Config.slideWalkEnabled then
        hum.AutoRotate = true
    end

    -- 5. ESP RENDER LOOP
    for plr, data in pairs(activeBoxes) do
        local pchar = plr.Character
        local phrp = pchar and pchar:FindFirstChild("HumanoidRootPart")
        local phead = pchar and pchar:FindFirstChild("Head")

        if pchar and phrp and phead and pchar:FindFirstChildOfClass("Humanoid") and pchar:FindFirstChildOfClass("Humanoid").Health > 0 then
            local color = getPlayerColor(plr)
            local highlight = activeHighlights[plr]
            if highlight then
                highlight.Adornee = pchar
                highlight.FillColor = color
                highlight.OutlineColor = color
                highlight.Enabled = Config.highlightChamsEnabled
            end

            if Config.boxEspEnabled then
                render2DEsp(plr, data, phrp, phead)
            else
                data.box.Visible = false
                if data.avatarFrame then data.avatarFrame.Visible = false end
            end
        else
            data.box.Visible = false
            if data.avatarFrame then data.avatarFrame.Visible = false end
        end
    end
end)

-- ==========================================
-- SURF ENGINE & SOUNDS
-- ==========================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function playSurfSound(hrp)
    local now = tick()
    if now - Config.lastHitSoundTime >= Config.hitSoundInterval then
        Config.lastHitSoundTime = now
        local s = Instance.new("Sound")
        s.SoundId = Config.currentHitSound
        s.Volume = Config.surfHitVolume
        s.Parent = hrp
        s:Play()
        Debris:AddItem(s, 1)
    end
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then Config.wasSurfing = false return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if Config.showVelocityHUD then
        local currentVel = math.floor(Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude)
        local currentHeight = math.floor(hrp.Position.Y)
        speedTextLabel.Text = "SPEED: " .. tostring(currentVel)
        heightTextLabel.Text = "HEIGHT: " .. tostring(currentHeight)
    end

    local currentlySurfing = false

    if Config.requestSurfFallAnimation and Config.isSurfKeyPressed and hrp then
        Config.requestSurfFallAnimation = false
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -60, hrp.AssemblyLinearVelocity.Z)
    end

    if Config.isSurfKeyPressed and not Config.isAirStuckActive then
        if Config.surfModeIndex == 1 then
            rayParams.FilterDescendantsInstances = {char}
            local ray = workspace:Raycast(hrp.Position, hrp.CFrame.RightVector * 5, rayParams) or workspace:Raycast(hrp.Position, -hrp.CFrame.RightVector * 5, rayParams)

            if ray and ray.Instance and ray.Instance.CanCollide then
                currentlySurfing = true
                local moveDir = hum.MoveDirection
                local normal = ray.Normal
                local dir = (moveDir.Magnitude > 0) and moveDir or hrp.CFrame.LookVector
                local surfDir = (dir - (dir:Dot(normal) * normal))
                if surfDir.Magnitude > 0 then surfDir = surfDir.Unit end

                hrp.AssemblyLinearVelocity = Vector3.new(surfDir.X * Config.pixelSurfSpeed, 0, surfDir.Z * Config.pixelSurfSpeed)
                playSurfSound(hrp)
            end
        elseif Config.surfModeIndex == 2 and #Config.waypoints >= 1 then
            currentlySurfing = true
            local targetPos = Config.waypoints[Config.currentWaypointIndex]
            local direction = (targetPos - hrp.Position)
            local horizontalDir = Vector3.new(direction.X, 0, direction.Z)

            if horizontalDir.Magnitude < 4 then
                Config.currentWaypointIndex = Config.currentWaypointIndex % #Config.waypoints + 1
                targetPos = Config.waypoints[Config.currentWaypointIndex]
                horizontalDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
            end

            if horizontalDir.Magnitude > 0 then horizontalDir = horizontalDir.Unit end
            hrp.AssemblyLinearVelocity = Vector3.new(horizontalDir.X * Config.pixelSurfSpeed, hrp.AssemblyLinearVelocity.Y, horizontalDir.Z * Config.pixelSurfSpeed)
            playSurfSound(hrp)
        end
    end

    Config.wasSurfing = currentlySurfing
end)
