--!nonstrict
--!nolint
-- Roblox Luau Script: Nurpukan Integrated GUI + HUD + All Modules
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local CUSTOM_LOGO_ID = "rbxassetid://139568612294283"

if CoreGui:FindFirstChild("NurpukanUI") then CoreGui.NurpukanUI:Destroy() end
if CoreGui:FindFirstChild("NurpukanPopups") then CoreGui.NurpukanPopups:Destroy() end
local oldHB = CoreGui:FindFirstChild("NurpukanHotbar")
if oldHB then oldHB:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NurpukanUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local PopupGui = Instance.new("ScreenGui")
PopupGui.Name = "NurpukanPopups"
PopupGui.ResetOnSpawn = false
PopupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
PopupGui.DisplayOrder = 100
PopupGui.IgnoreGuiInset = true
PopupGui.Parent = (gethui and gethui()) or CoreGui

local THEME = {
    Background    = Color3.fromRGB(12, 9, 11),
    CardBg        = Color3.fromRGB(18, 13, 16),
    PillBg        = Color3.fromRGB(16, 12, 14),
    SidebarActive = Color3.fromRGB(27, 16, 19),
    Border        = Color3.fromRGB(36, 24, 28),
    BorderActive  = Color3.fromRGB(90, 36, 42),
    Accent        = Color3.fromRGB(246, 92, 82),
    AccentSoft    = Color3.fromRGB(255, 165, 155),
    AccentDark    = Color3.fromRGB(130, 40, 42),
    TextPrimary   = Color3.fromRGB(235, 235, 235),
    TextMuted     = Color3.fromRGB(120, 110, 115),
    TextDim       = Color3.fromRGB(72, 64, 68),
    Divider       = Color3.fromRGB(48, 36, 40),
    BadgeBg       = Color3.fromRGB(25, 18, 22),
    ToggleOff     = Color3.fromRGB(36, 28, 32),
    KnobOff       = Color3.fromRGB(78, 68, 73),
    KnobOn        = Color3.fromRGB(255, 255, 255),
    PopupBg       = Color3.fromRGB(22, 16, 19)
}

local ICONS = {
    Search="rbxassetid://7733911828", Chevron="rbxassetid://7733717447",
    More="rbxassetid://7734021300", Menu="rbxassetid://7733993211",
    Combat="rbxassetid://7734053426", Movement="rbxassetid://7733799901",
    Visuals="rbxassetid://7733774602", Player="rbxassetid://7733954760",
    Misc="rbxassetid://7734056411", Presets="rbxassetid://7733964719",
    AutoBuy="rbxassetid://7733942651", Accounts="rbxassetid://7733765307",
    User="rbxassetid://7733954760", Chart="rbxassetid://7733749837",
    Clock="rbxassetid://7733734762", Compass="rbxassetid://7733720755",
    Signal="rbxassetid://7734058495", Radar="rbxassetid://7734053426",
    Speed="rbxassetid://7733799901", Settings="rbxassetid://7734056411"
}

local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local STATE = {
    esp = false, hotbar = false, fullbright = false,
    speed = false, spin = false, gunsight = false,
    aimbot = false, hud = true, hudDraggable = false
}

local currentSettings = {
    espColor = "#FFFFFF", hotbarColor = "#000000", hotbarGlow = "#FFFFFF",
    showNames = true, showHP = true, showInventory = true, roleColors = true,
    gunSight = false, walkSpeed = 50, spinSpeed = 35, hudScale = 1.0,
    hotbarSize = 50, hotbarTransparency = 0.4
}

local aimBotSettings = {
    enabled = false, radius = 150, showRadius = true,
    leftClick = true, rightClick = false, priority = "Only Murderer"
}

local origLighting = {
    Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd
}

local espList = {}
local bodyGyro = nil
local espEnabled = false
local hotbarEnabled = false
local fullbrightEnabled = false
local spinEnabled = false
local Keybinds = {}

local Main = nil
local HudContainer = nil
local HudScale = nil
local SearchInput = nil
local Pages = {}
local sidebarButtons = {}
local registeredRows = {}
local allSelectors = {}
local openPopups = {}
local ActiveDropdown = nil
local KeybindListening = nil
local closeAllPopups = nil
_G.NurpukanMenuKey = "LeftControl"

-- =============================================================================
-- UTILS
-- =============================================================================
local function hexToColor(hex)
    if not hex or type(hex) ~= "string" then return Color3.new(1, 1, 1) end
    hex = hex:gsub("#", "")
    if #hex < 6 then return Color3.new(1, 1, 1) end
    local r = (tonumber(hex:sub(1, 2), 16) or 255) / 255
    local g = (tonumber(hex:sub(3, 4), 16) or 255) / 255
    local b = (tonumber(hex:sub(5, 6), 16) or 255) / 255
    return Color3.new(r, g, b)
end

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
    end
    return nil
end

local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then return i end
        if i.Character and i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

local function getFullInventory(player)
    local items = {}
    local function scan(dir)
        if not dir then return end
        for _, t in ipairs(dir:GetChildren()) do
            if t:IsA("Tool") and t.TextureId ~= "" then table.insert(items, t.TextureId) end
        end
    end
    scan(player.Character); scan(player:FindFirstChild("Backpack"))
    return items
end

-- =============================================================================
-- ESP
-- =============================================================================
local function removeESP(player)
    if espList[player] then
        pcall(function() espList[player].highlight:Destroy() end)
        pcall(function() espList[player].billboard:Destroy() end)
        espList[player] = nil
    end
end

local function createESP(player)
    if not espEnabled or player == LocalPlayer or not player.Character then return end
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    removeESP(player)
    local highlight = Instance.new("Highlight", char)
    highlight.Name = "ESP_H"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local billboard = Instance.new("BillboardGui", hrp)
    billboard.Name = "ESP_B"
    billboard.Size = UDim2.new(0, 150, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    local bgFrame = Instance.new("Frame", billboard)
    bgFrame.Name = "NameBG"
    bgFrame.AnchorPoint = Vector2.new(0.5, 0)
    bgFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    bgFrame.AutomaticSize = Enum.AutomaticSize.XY
    bgFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bgFrame.BackgroundTransparency = 0.4
    bgFrame.BorderSizePixel = 0
    Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 4)
    local padding = Instance.new("UIPadding", bgFrame)
    padding.PaddingLeft = UDim.new(0, 8); padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 4); padding.PaddingBottom = UDim.new(0, 4)
    local label = Instance.new("TextLabel", bgFrame)
    label.Name = "Info"
    label.Size = UDim2.new(0, 0, 0, 15)
    label.AutomaticSize = Enum.AutomaticSize.X
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = ""
    local invFrame = Instance.new("Frame", billboard)
    invFrame.Name = "Inv"
    invFrame.AnchorPoint = Vector2.new(0.5, 1)
    invFrame.Position = UDim2.new(0.5, 0, 0.5, -5)
    invFrame.Size = UDim2.new(1, 0, 0, 35)
    invFrame.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", invFrame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 5)
    espList[player] = { highlight = highlight, billboard = billboard, lastHash = "" }
end

-- =============================================================================
-- HOTBAR
-- =============================================================================
local toolOrder = {}
local backpackConnections = {}
local hotbarGui = nil

local function getSortedTools()
    local tools = LocalPlayer.Backpack:GetChildren()
    if LocalPlayer.Character then
        for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    for _, tool in ipairs(tools) do
        if not toolOrder[tool] then toolOrder[tool] = tick() end
    end
    for tool, _ in pairs(toolOrder) do
        if not tool or not tool.Parent or (tool.Parent ~= LocalPlayer.Backpack and tool.Parent ~= LocalPlayer.Character) then
            toolOrder[tool] = nil
        end
    end
    local validTools = {}
    for tool, _ in pairs(toolOrder) do table.insert(validTools, tool) end
    table.sort(validTools, function(a, b) return (toolOrder[a] or 0) < (toolOrder[b] or 0) end)
    return validTools
end

local function equipItem(index)
    if not hotbarEnabled then return end
    local tools = getSortedTools()
    local targetTool = tools[index]
    if targetTool and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if hum then
            if currentTool == targetTool then hum:UnequipTools() else hum:EquipTool(targetTool) end
        end
    end
end

local function updateHotbarItems()
    if not hotbarGui or not hotbarEnabled then return end
    local container = hotbarGui:FindFirstChild("MainContainer")
    if not container then return end
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") and child.Name == "Slot" then child:Destroy() end
    end
    local tools = getSortedTools()
    local sSize = currentSettings.hotbarSize
    for i = 1, #tools do
        local tool = tools[i]
        local slot = Instance.new("Frame", container)
        slot.Name = "Slot"
        slot.Size = UDim2.new(0, sSize, 0, sSize)
        slot.BackgroundColor3 = Color3.new(0, 0, 0)
        slot.BackgroundTransparency = 0.5
        local stroke = Instance.new("UIStroke", slot)
        stroke.Color = hexToColor(currentSettings.hotbarGlow)
        stroke.Thickness = 2
        Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 8)
        if LocalPlayer.Character and tool.Parent == LocalPlayer.Character then
            slot.BackgroundTransparency = 0.2
            stroke.Thickness = 3
        end
        local icon = Instance.new("ImageButton", slot)
        icon.Size = UDim2.new(0.8, 0, 0.8, 0)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = (tool.TextureId ~= "") and tool.TextureId or "rbxassetid://1511655697"
        icon.MouseButton1Down:Connect(function() equipItem(i) end)
        local txt = Instance.new("TextLabel", slot)
        txt.Text = tostring(i)
        txt.Position = UDim2.new(0, 5, 0, 5)
        txt.Size = UDim2.new(0, 10, 0, 10)
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.BackgroundTransparency = 1
        txt.TextSize = 12
        txt.Font = Enum.Font.GothamBold
    end
end

local function applyHotbarStyle()
    if not hotbarGui then return end
    local container = hotbarGui:FindFirstChild("MainContainer")
    if container then
        container.BackgroundColor3 = hexToColor(currentSettings.hotbarColor)
        container.BackgroundTransparency = currentSettings.hotbarTransparency
        local stroke = container:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = hexToColor(currentSettings.hotbarGlow) end
    end
    updateHotbarItems()
end

local function toggleHotbar(enable)
    hotbarEnabled = enable
    for _, c in pairs(backpackConnections) do c:Disconnect() end
    backpackConnections = {}
    local old = CoreGui:FindFirstChild("NurpukanHotbar")
    if old then old:Destroy() end
    if not enable then
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        hotbarGui = nil
        return
    end
    hotbarGui = Instance.new("ScreenGui", CoreGui)
    hotbarGui.Name = "NurpukanHotbar"
    hotbarGui.ResetOnSpawn = false
    local container = Instance.new("Frame", hotbarGui)
    container.Name = "MainContainer"
    container.AnchorPoint = Vector2.new(0.5, 1)
    container.Position = UDim2.new(0.5, 0, 1, -5)
    container.AutomaticSize = Enum.AutomaticSize.XY
    container.BackgroundColor3 = hexToColor(currentSettings.hotbarColor)
    container.BackgroundTransparency = currentSettings.hotbarTransparency
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke", container)
    mainStroke.Color = hexToColor(currentSettings.hotbarGlow)
    mainStroke.Thickness = 1
    local layout = Instance.new("UIListLayout", container)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    local padding = Instance.new("UIPadding", container)
    padding.PaddingLeft = UDim.new(0, 2); padding.PaddingRight = UDim.new(0, 2)
    padding.PaddingTop = UDim.new(0, 2); padding.PaddingBottom = UDim.new(0, 2)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    local function connectInventory(target)
        if not target then return end
        table.insert(backpackConnections, target.ChildAdded:Connect(updateHotbarItems))
        table.insert(backpackConnections, target.ChildRemoved:Connect(updateHotbarItems))
    end
    connectInventory(LocalPlayer.Backpack)
    LocalPlayer.CharacterAdded:Connect(function(char)
        connectInventory(char); updateHotbarItems()
    end)
    if LocalPlayer.Character then connectInventory(LocalPlayer.Character) end
    task.spawn(function()
        while hotbarEnabled do
            local currentTools = getSortedTools()
            local c2 = hotbarGui and hotbarGui:FindFirstChild("MainContainer")
            if c2 then
                local cnt = 0
                for _, ch in ipairs(c2:GetChildren()) do
                    if ch.Name == "Slot" then cnt = cnt + 1 end
                end
                if cnt ~= #currentTools then updateHotbarItems() end
            end
            task.wait(0.5)
        end
    end)
    updateHotbarItems()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local map = {
        [Enum.KeyCode.One]=1, [Enum.KeyCode.Two]=2, [Enum.KeyCode.Three]=3, [Enum.KeyCode.Four]=4,
        [Enum.KeyCode.Five]=5, [Enum.KeyCode.Six]=6, [Enum.KeyCode.Seven]=7, [Enum.KeyCode.Eight]=8, [Enum.KeyCode.Nine]=9
    }
    if map[input.KeyCode] then equipItem(map[input.KeyCode]) end
end)

-- =============================================================================
-- FULLBRIGHT / SPIN / SPEED
-- =============================================================================
local function setFullbright(on)
    fullbrightEnabled = on
    if on then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = origLighting.Ambient
        Lighting.Brightness = origLighting.Brightness
    end
end

local function setSpin(on)
    spinEnabled = on
    if on then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not bodyGyro then bodyGyro = Instance.new("BodyGyro", hrp) end
            bodyGyro.P = 1e6
            bodyGyro.MaxTorque = Vector3.new(0, 1e6, 0)
        end
    elseif bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

local function applySpeed()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = currentSettings.walkSpeed end
end

-- =============================================================================
-- AIMBOT
-- =============================================================================
local aimFovCircle = Drawing.new("Circle")
aimFovCircle.Thickness = 1
aimFovCircle.Color = Color3.fromRGB(255, 255, 255)
aimFovCircle.Transparency = 0.6
aimFovCircle.Filled = false
aimFovCircle.Visible = false

local function hasBlockedTool()
    if not LocalPlayer.Character then return false end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local name = tool.Name:lower()
    return name:find("prank bomb") or name:find("bomb") or name:find("spray paint") or name:find("spraypaint")
end

local function findMurdererGlobal()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack:FindFirstChild("Knife") then return p end
            if p.Character and p.Character:FindFirstChild("Knife") then return p end
        end
    end
    return nil
end

local function isTargetVisible(hrp)
    if not hrp then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local origin = cam.CFrame.p
    local direction = (hrp.Position - origin).Unit
    local distance = (hrp.Position - origin).Magnitude
    local result = workspace:Raycast(origin, direction * distance, params)
    return not result or result.Instance:IsDescendantOf(hrp.Parent)
end

local function getAimTarget()
    if not STATE.aimbot or not aimBotSettings.enabled then return nil end
    if hasBlockedTool() then return nil end
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local bestTarget = nil
    local bestScore = math.huge

    if aimBotSettings.priority == "Only Murderer" then
        local murderer = findMurdererGlobal()
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = murderer.Character.HumanoidRootPart
            local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distToMouse <= aimBotSettings.radius then return hrp end
            end
            return nil
        end
    end

    if aimBotSettings.priority == "Murderer" then
        local murderer = findMurdererGlobal()
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = murderer.Character.HumanoidRootPart
            local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distToMouse <= aimBotSettings.radius then return hrp end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local skip = false
                if aimBotSettings.priority == "Distance" and not isTargetVisible(hrp) then skip = true end
                if not skip then
                    local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distToMouse <= aimBotSettings.radius then
                            local score = distToMouse
                            if aimBotSettings.priority == "HP" then
                                local hum = player.Character:FindFirstChild("Humanoid")
                                if hum then score = hum.Health / hum.MaxHealth * 100 end
                            end
                            if score < bestScore then bestScore = score; bestTarget = hrp end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not STATE.aimbot or not aimBotSettings.enabled then return end
    if hasBlockedTool() then return end
    local target = getAimTarget()
    if not target then return end
    local isLeft = input.UserInputType == Enum.UserInputType.MouseButton1
    local isRight = input.UserInputType == Enum.UserInputType.MouseButton2
    local shouldClick = (aimBotSettings.leftClick and isLeft) or (aimBotSettings.rightClick and isRight)
    if shouldClick then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
        task.wait(0.01)
        pcall(function()
            if isLeft then
                VirtualUser:Button1Down(Vector2.new(0, 0), cam.CFrame)
                task.wait(0.01)
                VirtualUser:Button1Up(Vector2.new(0, 0), cam.CFrame)
            else
                VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
                task.wait(0.01)
                VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
            end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    aimFovCircle.Visible = STATE.aimbot and aimBotSettings.enabled and aimBotSettings.showRadius
    if aimFovCircle.Visible then
        aimFovCircle.Position = UserInputService:GetMouseLocation()
        aimFovCircle.Radius = aimBotSettings.radius
    end
end)

-- =============================================================================
-- RENDER LOOP
-- =============================================================================
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local data = espList[player]
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and not data then
                    createESP(player); data = espList[player]
                end
                if data and char then
                    local hum = char:FindFirstChild("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and hum then
                        local m = findMurderer()
                        local s = findSheriff()
                        local finalCol
                        if player == m then finalCol = Color3.fromRGB(255, 0, 0)
                        elseif player == s then finalCol = Color3.fromRGB(0, 0, 255)
                        else finalCol = hexToColor(currentSettings.espColor) end
                        if data.highlight then
                            data.highlight.Enabled = true
                            data.highlight.FillColor = finalCol
                            data.highlight.OutlineColor = finalCol
                        end
                        local nameTag = data.billboard:FindFirstChild("NameBG")
                        if nameTag then
                            nameTag.Visible = currentSettings.showNames
                            nameTag.Info.Text = player.Name
                            if currentSettings.showHP then
                                nameTag.Info.Text = nameTag.Info.Text .. " [" .. math.floor(hum.Health) .. "HP]"
                            end
                        end
                        if currentSettings.showInventory then
                            local inv = getFullInventory(player)
                            local hash = table.concat(inv, "|")
                            if data.lastHash ~= hash then
                                data.lastHash = hash
                                for _, c in ipairs(data.billboard.Inv:GetChildren()) do
                                    if c:IsA("ImageLabel") then c:Destroy() end
                                end
                                for _, icon in ipairs(inv) do
                                    local img = Instance.new("ImageLabel", data.billboard.Inv)
                                    img.Size = UDim2.new(0, 30, 0, 30)
                                    img.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                    img.BackgroundTransparency = 0.5
                                    img.BorderSizePixel = 0
                                    img.Image = icon
                                    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 6)
                                end
                            end
                        end
                        data.billboard.Inv.Visible = currentSettings.showInventory
                    else
                        removeESP(player)
                    end
                elseif data and not char then
                    removeESP(player)
                end
            end
        end
    else
        for p, _ in pairs(espList) do removeESP(p) end
    end
    local gunDrop = workspace:FindFirstChild("GunDrop")
    if gunDrop and currentSettings.roleColors then
        if not gunDrop:FindFirstChild("ESP_Highlight") then
            local h = Instance.new("Highlight", gunDrop)
            h.Name = "ESP_Highlight"
            h.FillColor = Color3.fromRGB(255, 255, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local isGun = tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver"))
    if currentSettings.gunSight then
        UserInputService.MouseIcon = isGun and "rbxassetid://2157404409" or ""
    else
        UserInputService.MouseIcon = isGun and "rbxassetid://79658449" or ""
    end
    if spinEnabled and bodyGyro and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then bodyGyro.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(currentSettings.spinSpeed), 0) end
    end
end)

-- =============================================================================
-- NEW MODULES
-- =============================================================================

-- FLIGHT
local FlyState = { active = false, bodyVel = nil, bodyGyro = nil, conn = nil }
local FlySettings = { speed = 100, acceleration = 8 }

local function FlyEnable()
    if FlyState.active then return end
    FlyState.active = true
    FlyState.conn = RunService.RenderStepped:Connect(function()
        if not FlyState.active then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not FlyState.bodyVel or not FlyState.bodyVel.Parent then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            FlyState.bodyVel = bv
        end
        if not FlyState.bodyGyro or not FlyState.bodyGyro.Parent then
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 1e4
            bg.Parent = hrp
            FlyState.bodyGyro = bg
        end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        local target = dir * FlySettings.speed
        local alpha = math.clamp(FlySettings.acceleration / 20, 0.02, 1)
        FlyState.bodyVel.Velocity = FlyState.bodyVel.Velocity:Lerp(target, alpha)
        FlyState.bodyGyro.CFrame = cam.CFrame
    end)
end

local function FlyDisable()
    if not FlyState.active then return end
    FlyState.active = false
    if FlyState.conn then FlyState.conn:Disconnect() FlyState.conn = nil end
    if FlyState.bodyVel then FlyState.bodyVel:Destroy() FlyState.bodyVel = nil end
    if FlyState.bodyGyro then FlyState.bodyGyro:Destroy() FlyState.bodyGyro = nil end
end

-- JUMP
local JumpState = { active = false, conn = nil }
local JumpSettings = { power = 100 }

local function JumpApply()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.UseJumpPower = true
    hum.JumpPower = JumpSettings.power
end

local function JumpEnable()
    JumpState.active = true
    JumpApply()
    JumpState.conn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if JumpState.active then JumpApply() end
    end)
end

local function JumpDisable()
    JumpState.active = false
    if JumpState.conn then JumpState.conn:Disconnect() JumpState.conn = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 50 end
    end
end

-- ANTI-FLING
local AntiFlingState = { active = false, conn = nil }

local function AntiFlingEnable()
    AntiFlingState.active = true
    AntiFlingState.conn = RunService.Heartbeat:Connect(function()
        if not AntiFlingState.active then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.Velocity.Magnitude > 250 then
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end
        if hrp.RotVelocity.Magnitude > 25 then
            hrp.RotVelocity = Vector3.zero
        end
    end)
end

local function AntiFlingDisable()
    AntiFlingState.active = false
    if AntiFlingState.conn then AntiFlingState.conn:Disconnect() AntiFlingState.conn = nil end
end

-- NOCLIP
local NoclipState = { active = false, conn = nil }

local function NoclipEnable()
    NoclipState.active = true
    NoclipState.conn = RunService.Stepped:Connect(function()
        if not NoclipState.active then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function NoclipDisable()
    NoclipState.active = false
    if NoclipState.conn then NoclipState.conn:Disconnect() NoclipState.conn = nil end
end

-- INFINITE JUMP
local InfJumpState = { active = false, conn = nil }

local function InfJumpEnable()
    InfJumpState.active = true
    InfJumpState.conn = UserInputService.JumpRequest:Connect(function()
        if not InfJumpState.active then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function InfJumpDisable()
    InfJumpState.active = false
    if InfJumpState.conn then InfJumpState.conn:Disconnect() InfJumpState.conn = nil end
end

-- CUSTOM SKYBOX
local SkyboxPresets = {
    ["Default"] = nil,
    ["Space"] = {
        SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454296",
        SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454286",
        SkyboxRt = "rbxassetid://159454300", SkyboxUp = "rbxassetid://159454288",
    },
    ["Night"] = {
        SkyboxBk = "rbxassetid://12064107", SkyboxDn = "rbxassetid://12064152",
        SkyboxFt = "rbxassetid://12064105", SkyboxLf = "rbxassetid://12064101",
        SkyboxRt = "rbxassetid://12064095", SkyboxUp = "rbxassetid://12064156",
    },
    ["Sunset"] = {
        SkyboxBk = "rbxassetid://6263069461", SkyboxDn = "rbxassetid://6263069612",
        SkyboxFt = "rbxassetid://6263069180", SkyboxLf = "rbxassetid://6263068847",
        SkyboxRt = "rbxassetid://6263068474", SkyboxUp = "rbxassetid://6263068923",
    },
    ["Clouds"] = {
        SkyboxBk = "rbxassetid://5705570338", SkyboxDn = "rbxassetid://5705570374",
        SkyboxFt = "rbxassetid://5705570433", SkyboxLf = "rbxassetid://5705570549",
        SkyboxRt = "rbxassetid://5705570675", SkyboxUp = "rbxassetid://5705570570",
    },
}
local SkyboxState = { active = false, instance = nil, currentPreset = "Default" }

local function SkyboxApply(presetName)
    SkyboxState.currentPreset = presetName
    if SkyboxState.instance then SkyboxState.instance:Destroy() SkyboxState.instance = nil end
    local preset = SkyboxPresets[presetName]
    if not preset then return end
    local sky = Instance.new("Sky")
    sky.Name = "NurpukanSky"
    sky.SkyboxBk = preset.SkyboxBk
    sky.SkyboxDn = preset.SkyboxDn
    sky.SkyboxFt = preset.SkyboxFt
    sky.SkyboxLf = preset.SkyboxLf
    sky.SkyboxRt = preset.SkyboxRt
    sky.SkyboxUp = preset.SkyboxUp
    sky.Parent = Lighting
    SkyboxState.instance = sky
end

local function SkyboxEnable()
    SkyboxState.active = true
    SkyboxApply(SkyboxState.currentPreset)
end

local function SkyboxDisable()
    SkyboxState.active = false
    if SkyboxState.instance then SkyboxState.instance:Destroy() SkyboxState.instance = nil end
end

-- TIME CHANGER
local TimeState = { active = false, value = 12, original = nil }

local function TimeApply()
    if TimeState.active then Lighting.ClockTime = TimeState.value end
end

local function TimeEnable()
    if not TimeState.original then TimeState.original = Lighting.ClockTime end
    TimeState.active = true
    TimeApply()
end

local function TimeDisable()
    TimeState.active = false
    if TimeState.original then Lighting.ClockTime = TimeState.original end
end

-- REMOVE FOG
local FogState = { active = false, original = nil }

local function FogEnable()
    if not FogState.original then
        FogState.original = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart }
    end
    FogState.active = true
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
end

local function FogDisable()
    FogState.active = false
    if FogState.original then
        Lighting.FogEnd = FogState.original.FogEnd
        Lighting.FogStart = FogState.original.FogStart
    end
end

-- GIVE ALL (MM2)
local MM2State = {
    running = false,
    loopThread = nil,
    stuckConn = nil,
    originalOwned = nil,
    data = nil,
    ProfileData = nil,
    InventoryModule = nil,
    Sync = nil,
    UpdateInventory = nil,
}

local function MM2UpdateInventory()
    pcall(function()
        if not MM2State.UpdateInventory then
            MM2State.UpdateInventory = filtergc("table", { Keys = { "UpdateInventory" } }, true).UpdateInventory
        end
        for _, func in pairs(getgc()) do
            if typeof(func) == "function" and islclosure(func) and debug.info(func, "l") == 122 and #debug.getupvalues(func) == 2 then
                MM2State.UpdateInventory(debug.getupvalue(func, 2), MM2State.InventoryModule.MyInventory)
            end
        end
    end)
end

local function MM2Enable()
    if MM2State.running then return end

    if not MM2State.data then
        local ok, loaded = pcall(function()
            if not isfile("mm2data.lua") then
                local result = request({
                    Url = "https://raw.githubusercontent.com/Lutosys/opensrc/refs/heads/main/mm2meshes.lua",
                    Method = "GET",
                })
                if result.Success then
                    writefile("mm2data.lua", result.Body)
                end
            end
            return loadfile("mm2data.lua")()
        end)
        if not ok or not loaded then
            warn("[Nurpukan] MM2 data load failed")
            return
        end
        MM2State.data = loaded
    end

    local ok2, err2 = pcall(function()
        MM2State.InventoryModule = require(game.ReplicatedStorage.Modules.InventoryModule)
        MM2State.ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
        MM2State.Sync = require(game.ReplicatedStorage.Database.Sync)
    end)
    if not ok2 then
        warn("[Nurpukan] MM2 modules not found: " .. tostring(err2))
        return
    end

    MM2State.originalOwned = {}
    for k, v in pairs(MM2State.ProfileData.Weapons.Owned) do
        MM2State.originalOwned[k] = v
    end

    local data = MM2State.data
    local ProfileData = MM2State.ProfileData
    local Sync = MM2State.Sync

    local function findMeshAndTexture(n)
        if not n or type(n) ~= "table" then return nil end
        local props = n.Props
        if props then
            local meshId = props.MeshId or props.MeshID
            if meshId and meshId ~= "" then
                local textureId = props.TextureId or props.TextureID or ""
                local scale = props.Scale or Vector3.new(0.045, 0.045, 0.045)
                local size = props.Size or Vector3.new(0.045, 0.045, 0.045)
                return { meshid = meshId, textureid = textureId, scale = scale, size = size }
            end
        end
        if n.Display and type(n.Display) == "table" then
            for _, child in ipairs(n.Display) do
                local res = findMeshAndTexture(child)
                if res then return res end
            end
        end
        return nil
    end

    local function getWeaponData(name)
        local weaponData = data[name]
        if not weaponData then return nil end
        return findMeshAndTexture(weaponData)
    end

    local function applyWeaponMesh(refPart, weaponData, weaponName, weapontype)
        if not weaponData or not weaponData.meshid then return end
        if weaponData.meshid:find("79401392") then
            if weapontype == "Gun" then
                local tool = refPart:FindFirstAncestorOfClass("Tool")
                if tool then
                    tool.Grip = CFrame.fromMatrix(
                        Vector3.new(0, -0.699999988, -0.300000012),
                        Vector3.new(1, 0, 0),
                        Vector3.new(0, 0, 1),
                        Vector3.new(0, -1, 0)
                    )
                end
            end
        elseif weaponData.meshid:find("6600918074") then
            if weapontype == "Gun" then
                local tool = refPart:FindFirstAncestorOfClass("Tool")
                if tool then
                    tool.Grip = CFrame.new(1, -0.359999988, 0.00000012, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                end
            end
        else
            if weapontype == "Gun" then
                local tool = refPart:FindFirstAncestorOfClass("Tool")
                if tool then
                    tool.Grip = CFrame.fromMatrix(
                        Vector3.new(0, -0.5, 0.7),
                        Vector3.new(1, 0, 0),
                        Vector3.new(0, 1, 0),
                        Vector3.new(0, 0, 1)
                    )
                end
            end
        end
        if refPart:IsA("MeshPart") then
            local sm = refPart:FindFirstChildOfClass("SpecialMesh")
            if sm then sm:Destroy() end
            refPart.Size = weaponData.size
            refPart.MeshId = weaponData.meshid
            refPart.TextureID = weaponData.textureid
        else
            local mesh = refPart:FindFirstChildOfClass("SpecialMesh")
            if not mesh then
                mesh = Instance.new("SpecialMesh")
                mesh.Name = "Mesh"
                mesh.Parent = refPart
            end
            refPart.Size = weaponData.size
            mesh.MeshId = weaponData.meshid
            mesh.TextureId = weaponData.textureid
            mesh.Scale = weaponData.scale
        end
    end

    for name, itemData in pairs(Sync.Weapons) do
        itemData.SortWithinGroup = itemData.SortWithinGroup or 0
        itemData.SortGroup = itemData.SortGroup or nil
        itemData.Name = itemData.Name or itemData.ItemName or name
        itemData.Rarity = itemData.Rarity or "Common"
        if Sync.Rarities[itemData.Rarity] then
            local info = getWeaponData(name)
            if info and info.meshid and info.textureid and info.scale and info.size then
                ProfileData.Weapons.Owned[name] = 1
            end
        end
    end

    MM2UpdateInventory()

    local function isMurder()
        local success, result = pcall(function()
            for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if typeof(v) == "Instance" and v:IsA("Tool") and v:GetAttribute("ItemType") == "Knife" then
                    return true
                end
            end
            for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if typeof(v) == "Instance" and v:IsA("Tool") and v:GetAttribute("ItemType") == "Knife" then
                    return true
                end
            end
            return false
        end)
        if success then return result end
        return false
    end

    MM2State.stuckConn = game.Workspace.ChildAdded:Connect(function(ch)
        if ch and ch:IsA("BasePart") and ch.Name == "StuckKnife" then
            local mesh = ch:WaitForChild("Mesh", 3)
            if mesh then
                local equippedKnifeName = ProfileData.Weapons.Equipped.Knife
                local knifedata = getWeaponData(equippedKnifeName)
                if knifedata and isMurder() then
                    mesh.MeshId = knifedata.meshid
                    mesh.TextureId = knifedata.textureid
                    mesh.Scale = knifedata.scale
                end
            end
        end
    end)

    MM2State.running = true
    MM2State.loopThread = task.spawn(function()
        while MM2State.running do
            local char = game.Players.LocalPlayer.Character
            if char then
                local equippedKnifeName = ProfileData.Weapons.Equipped.Knife
                local equippedGunName = ProfileData.Weapons.Equipped.Gun
                for _, tool in pairs(char:GetChildren()) do
                    if tool and tool:IsA("Tool") then
                        local itemType = tool:GetAttribute("ItemType")
                        local Handle = tool:FindFirstChild("Handle")
                        if Handle then
                            if itemType == "Knife" and equippedKnifeName then
                                local kd = getWeaponData(equippedKnifeName)
                                if kd and kd.meshid and kd.textureid and kd.scale and kd.size then
                                    applyWeaponMesh(Handle, kd, equippedKnifeName, "Knife")
                                end
                            elseif itemType == "Gun" and equippedGunName then
                                local gd = getWeaponData(equippedGunName)
                                if gd and gd.meshid and gd.textureid and gd.scale and gd.size then
                                    applyWeaponMesh(Handle, gd, equippedGunName, "Gun")
                                end
                            end
                        end
                    end
                end
                local DisplayRefGun = char:FindFirstChild("DisplayRefGun")
                if DisplayRefGun then
                    local refVal = DisplayRefGun.Value
                    if refVal and typeof(refVal) == "Instance" and equippedGunName then
                        local gd = getWeaponData(equippedGunName)
                        if gd and gd.meshid and gd.textureid and gd.scale and gd.size then
                            applyWeaponMesh(refVal, gd, equippedGunName)
                        end
                    end
                end
                local DisplayRefKnife = char:FindFirstChild("DisplayRefKnife")
                if DisplayRefKnife then
                    local refVal = DisplayRefKnife.Value
                    if refVal and typeof(refVal) == "Instance" and equippedKnifeName then
                        local kd = getWeaponData(equippedKnifeName)
                        if kd and kd.meshid and kd.textureid and kd.scale and kd.size then
                            applyWeaponMesh(refVal, kd, equippedKnifeName)
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end

local function MM2Disable()
    if not MM2State.running then return end
    MM2State.running = false
    if MM2State.stuckConn then
        MM2State.stuckConn:Disconnect()
        MM2State.stuckConn = nil
    end
    if MM2State.originalOwned and MM2State.ProfileData then
        MM2State.ProfileData.Weapons.Owned = MM2State.originalOwned
        MM2UpdateInventory()
    end
end

-- =============================================================================
-- HUD
-- =============================================================================
do
    HudContainer = Instance.new("Frame")
    HudContainer.Name = "HudContainer"
    HudContainer.Size = UDim2.new(0, 600, 0, 50)
    HudContainer.Position = UDim2.new(0, 16, 0, 48)
    HudContainer.BackgroundTransparency = 1
    HudContainer.Parent = ScreenGui

    HudScale = Instance.new("UIScale", HudContainer)
    HudScale.Scale = 1.0

    local HudVerticalLayout = Instance.new("UIListLayout", HudContainer)
    HudVerticalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    HudVerticalLayout.Padding = UDim.new(0, 4)

    local dragging, dragStart, startPos
    HudContainer.InputBegan:Connect(function(input)
        if not STATE.hudDraggable then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = HudContainer.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            HudContainer.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local function createHudRow(name, height, order)
        local row = Instance.new("Frame", HudContainer)
        row.Name = name
        row.Size = UDim2.new(1, 0, 0, height)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        local hLayout = Instance.new("UIListLayout", row)
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.SortOrder = Enum.SortOrder.LayoutOrder
        hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        hLayout.Padding = UDim.new(0, 5)
        return row
    end

    local function createHudPill(parent, order)
        local pill = Instance.new("Frame", parent)
        pill.AutomaticSize = Enum.AutomaticSize.X
        pill.Size = UDim2.new(0, 0, 1, 0)
        pill.BackgroundColor3 = THEME.PillBg
        pill.BorderSizePixel = 0
        pill.LayoutOrder = order
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 5)
        local stroke = Instance.new("UIStroke", pill)
        stroke.Color = THEME.Border
        stroke.Thickness = 1
        local pad = Instance.new("UIPadding", pill)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        local layout = Instance.new("UIListLayout", pill)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 5)
        return pill
    end

    local function addHudDivider(parent, order)
        local div = Instance.new("Frame", parent)
        div.Size = UDim2.new(0, 1, 0, 10)
        div.BackgroundColor3 = THEME.Divider
        div.BorderSizePixel = 0
        div.LayoutOrder = order
    end

    local function addHudText(parent, text, isMuted, order)
        local lbl = Instance.new("TextLabel", parent)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 10.5
        lbl.TextColor3 = isMuted and THEME.TextMuted or THEME.TextPrimary
        lbl.LayoutOrder = order
        return lbl
    end

    local function addHudSmallIcon(parent, iconId, order)
        local icon = Instance.new("ImageLabel", parent)
        icon.Size = UDim2.new(0, 11, 0, 11)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ImageColor3 = THEME.Accent
        icon.LayoutOrder = order
        return icon
    end

    local TopHudRow = createHudRow("TopRow", 22, 1)
    local BottomHudRow = createHudRow("BottomRow", 22, 2)

    local BrandPill = createHudPill(TopHudRow, 1)
    local HudLogoWrap = Instance.new("Frame", BrandPill)
    HudLogoWrap.Size = UDim2.new(0, 20, 0, 20)
    HudLogoWrap.BackgroundTransparency = 1
    HudLogoWrap.LayoutOrder = 1
    local HudLogoGlow = Instance.new("ImageLabel", HudLogoWrap)
    HudLogoGlow.Size = UDim2.new(2, 0, 2, 0)
    HudLogoGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    HudLogoGlow.BackgroundTransparency = 1
    HudLogoGlow.Image = "rbxassetid://5028857084"
    HudLogoGlow.ImageColor3 = THEME.Accent
    HudLogoGlow.ImageTransparency = 0.65
    HudLogoGlow.ZIndex = 1
    local HudBrandLogo = Instance.new("ImageLabel", HudLogoWrap)
    HudBrandLogo.Size = UDim2.new(1.35, 0, 1.35, 0)
    HudBrandLogo.Position = UDim2.new(-0.175, 0, -0.175, 0)
    HudBrandLogo.BackgroundTransparency = 1
    HudBrandLogo.Image = CUSTOM_LOGO_ID
    HudBrandLogo.ScaleType = Enum.ScaleType.Fit
    HudBrandLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    HudBrandLogo.ZIndex = 2
    local HudLogoGrad = Instance.new("UIGradient", HudBrandLogo)
    HudLogoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
        ColorSequenceKeypoint.new(0.45, THEME.Accent),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(165, 32, 42))
    })
    HudLogoGrad.Rotation = -35
    addHudDivider(BrandPill, 2)
    local HudBrandText = addHudText(BrandPill, "Nurpukan", false, 3)
    local HudBrandGrad = Instance.new("UIGradient", HudBrandText)
    HudBrandGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
        ColorSequenceKeypoint.new(1.0, THEME.Accent)
    })

    local StatsPill = createHudPill(TopHudRow, 2)
    addHudSmallIcon(StatsPill, ICONS.User, 1)
    addHudText(StatsPill, string.lower(LocalPlayer.Name), false, 2)
    addHudDivider(StatsPill, 3)
    addHudSmallIcon(StatsPill, ICONS.Chart, 4)
    local FpsLabel = addHudText(StatsPill, "0 Fps", false, 5)
    addHudDivider(StatsPill, 6)
    addHudSmallIcon(StatsPill, ICONS.Clock, 7)
    local TimeLabel = addHudText(StatsPill, "00:00:00", false, 8)

    local PosPill = createHudPill(BottomHudRow, 1)
    addHudSmallIcon(PosPill, ICONS.Compass, 1)
    addHudDivider(PosPill, 2)
    local PosLabel = addHudText(PosPill, "0, 0, 0", false, 3)

    local PingPill = createHudPill(BottomHudRow, 2)
    addHudSmallIcon(PingPill, ICONS.Signal, 1)
    addHudDivider(PingPill, 2)
    local PingLabel = addHudText(PingPill, "0 Ping", false, 3)

    local TickPill = createHudPill(BottomHudRow, 3)
    addHudSmallIcon(TickPill, ICONS.Radar, 1)
    addHudDivider(TickPill, 2)
    local TickLabel = addHudText(TickPill, "20.0 Ticks", false, 3)

    local SpeedPill = createHudPill(BottomHudRow, 4)
    addHudSmallIcon(SpeedPill, ICONS.Speed, 1)
    addHudDivider(SpeedPill, 2)
    local SpeedLabel = addHudText(SpeedPill, "0.0 Bps", false, 3)

    local fpsCounter = 0
    local lastFpsCheck = os.clock()
    local lastPosition = Vector3.zero
    local lastPosTime = os.clock()

    RunService.RenderStepped:Connect(function()
        if not STATE.hud then return end
        fpsCounter = fpsCounter + 1
        local now = os.clock()
        if now - lastFpsCheck >= 1 then
            FpsLabel.Text = string.format("%d Fps", fpsCounter)
            fpsCounter = 0
            lastFpsCheck = now
        end
        TimeLabel.Text = os.date("%H:%M:%S")
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        PingLabel.Text = string.format("%d Ping", ping)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local currentPos = hrp.Position
            PosLabel.Text = string.format("%d, %d, %d",
                math.floor(currentPos.X), math.floor(currentPos.Y), math.floor(currentPos.Z))
            local deltaTime = now - lastPosTime
            if deltaTime >= 0.1 then
                local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPosition.X, 0, lastPosition.Z)).Magnitude
                SpeedLabel.Text = string.format("%.1f Bps", dist / deltaTime)
                lastPosition = currentPos
                lastPosTime = now
            end
        else
            PosLabel.Text = "0, 0, 0"
            SpeedLabel.Text = "0.0 Bps"
        end
    end)
end

-- =============================================================================
-- MAIN GUI
-- =============================================================================
do
    local function isMouseInFrame(frame)
        if not frame or not frame.Parent then return false end
        local mp = UserInputService:GetMouseLocation()
        local ap = frame.AbsolutePosition
        local as = frame.AbsoluteSize
        return mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
    end

    local function registerPopup(frame, onClose)
        table.insert(openPopups, { frame = frame, onClose = onClose })
    end

    local function unregisterPopup(frame)
        for i, entry in ipairs(openPopups) do
            if entry.frame == frame then
                table.remove(openPopups, i)
                return
            end
        end
    end

    closeAllPopups = function()
        for _, entry in ipairs(openPopups) do
            if entry.frame and entry.frame.Parent then
                if entry.onClose then entry.onClose() end
                entry.frame:Destroy()
            end
        end
        openPopups = {}
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if #openPopups == 0 then return end
        for _, entry in ipairs(openPopups) do
            if isMouseInFrame(entry.frame) then return end
        end
        for _, sel in ipairs(allSelectors) do
            if isMouseInFrame(sel) then return end
        end
        closeAllPopups()
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel and #openPopups > 0 then
            closeAllPopups()
        end
    end)

    local function calcPopupPos(anchor, popupSize)
        local cam = workspace.CurrentCamera
        if not cam then return UDim2.new(0, 100, 0, 100) end
        local vs = cam.ViewportSize
        local ap = anchor.AbsolutePosition
        local as = anchor.AbsoluteSize
        local px = ap.X + as.X - popupSize.X
        local py = ap.Y + as.Y + 2
        if px < 10 then px = 10 end
        if px + popupSize.X > vs.X - 10 then px = vs.X - popupSize.X - 10 end
        if py + popupSize.Y > vs.Y - 10 then py = ap.Y - popupSize.Y - 2 end
        if py < 10 then py = 10 end
        return UDim2.fromOffset(px, py)
    end

    local function startKeybindListen(badge, moduleId, onBind)
        if KeybindListening then KeybindListening:Disconnect() end
        badge.Text = "..."
        badge.TextColor3 = THEME.Accent
        KeybindListening = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                if keyName == "Escape" then
                    Keybinds[moduleId] = nil
                    badge.Text = "-"
                else
                    Keybinds[moduleId] = { keyCode = input.KeyCode, onBind = onBind }
                    badge.Text = keyName
                end
                badge.TextColor3 = THEME.TextMuted
                KeybindListening:Disconnect()
                KeybindListening = nil
            end
        end)
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        for _, data in pairs(Keybinds) do
            if data.keyCode and input.KeyCode == data.keyCode and data.onBind then
                data.onBind()
            end
        end
    end)

    local function toggleKeybindDropdown(parentRow, badgeLabel, moduleId, getStateFn, setStateFn)
        if ActiveDropdown then ActiveDropdown:Destroy() ActiveDropdown = nil return end
        local drop = Instance.new("Frame")
        drop.Size = UDim2.new(0, 115, 0, 58)
        drop.Position = UDim2.new(1, -120, 1, 3)
        drop.BackgroundColor3 = THEME.PopupBg
        drop.ZIndex = 30
        drop.Parent = parentRow
        Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", drop)
        s.Color = THEME.Border
        s.Thickness = 1
        local list = Instance.new("UIListLayout", drop)
        list.Padding = UDim.new(0, 1)
        local pad = Instance.new("UIPadding", drop)
        pad.PaddingTop = UDim.new(0, 3)
        pad.PaddingBottom = UDim.new(0, 3)
        pad.PaddingLeft = UDim.new(0, 5)
        pad.PaddingRight = UDim.new(0, 5)

        local function addOption(name, onClick)
            local btn = Instance.new("TextButton", drop)
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.BackgroundTransparency = 1
            btn.Text = " " .. name
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 10.5
            btn.TextColor3 = THEME.TextPrimary
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 31
            btn.MouseEnter:Connect(function() btn.TextColor3 = THEME.Accent end)
            btn.MouseLeave:Connect(function() btn.TextColor3 = THEME.TextPrimary end)
            btn.MouseButton1Click:Connect(function()
                drop:Destroy()
                ActiveDropdown = nil
                if onClick then onClick() end
            end)
        end

        addOption("Bind Key", function()
            startKeybindListen(badgeLabel, moduleId, function()
                if setStateFn and getStateFn then setStateFn(not getStateFn()) end
            end)
        end)
        addOption("Reset Value", function()
            badgeLabel.Text = "-"
            Keybinds[moduleId] = nil
        end)
        ActiveDropdown = drop
    end

    -- TOGGLE
    local function addToggle(card, name, description, defaultState, keybindDefault, callback, moduleId)
        moduleId = moduleId or name
        local row = Instance.new("Frame", card)
        row.Name = name
        row.Size = UDim2.new(1, 0, 0, description and 30 or 21)
        row.BackgroundTransparency = 1
        table.insert(registeredRows, { Frame = row, Name = name:lower() })

        local textContainer = Instance.new("Frame", row)
        textContainer.Size = UDim2.new(1, -80, 1, 0)
        textContainer.BackgroundTransparency = 1

        local rowTitle = Instance.new("TextLabel", textContainer)
        rowTitle.Size = UDim2.new(1, 0, 0, 14)
        rowTitle.BackgroundTransparency = 1
        rowTitle.Text = name
        rowTitle.Font = Enum.Font.GothamMedium
        rowTitle.TextSize = 11
        rowTitle.TextColor3 = THEME.TextPrimary
        rowTitle.TextXAlignment = Enum.TextXAlignment.Left

        if description then
            local rowDesc = Instance.new("TextLabel", textContainer)
            rowDesc.Size = UDim2.new(1, 0, 0, 12)
            rowDesc.Position = UDim2.new(0, 0, 0, 14)
            rowDesc.BackgroundTransparency = 1
            rowDesc.Text = description
            rowDesc.Font = Enum.Font.Gotham
            rowDesc.TextSize = 9
            rowDesc.TextColor3 = THEME.TextMuted
            rowDesc.TextXAlignment = Enum.TextXAlignment.Left
        end

        local badge = Instance.new("TextLabel", row)
        badge.Size = UDim2.new(0, 22, 0, 14)
        badge.Position = UDim2.new(1, -76, 0.5, -7)
        badge.BackgroundColor3 = THEME.BadgeBg
        badge.Text = keybindDefault or "-"
        badge.Font = Enum.Font.GothamBold
        badge.TextSize = 8.5
        badge.TextColor3 = THEME.TextMuted
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)
        local bs = Instance.new("UIStroke", badge)
        bs.Color = THEME.Border
        bs.Thickness = 0.8

        local optBtn = Instance.new("ImageButton", row)
        optBtn.Size = UDim2.new(0, 13, 0, 13)
        optBtn.Position = UDim2.new(1, -52, 0.5, -6.5)
        optBtn.BackgroundTransparency = 1
        optBtn.Image = ICONS.More
        optBtn.ImageColor3 = THEME.TextDim
        optBtn.MouseEnter:Connect(function() TweenService:Create(optBtn, TWEEN_FAST, { ImageColor3 = THEME.TextPrimary }):Play() end)
        optBtn.MouseLeave:Connect(function() TweenService:Create(optBtn, TWEEN_FAST, { ImageColor3 = THEME.TextDim }):Play() end)

        local switch = Instance.new("TextButton", row)
        switch.Size = UDim2.new(0, 32, 0, 16)
        switch.Position = UDim2.new(1, -32, 0.5, -8)
        switch.BackgroundColor3 = defaultState and THEME.Accent or THEME.ToggleOff
        switch.Text = ""
        switch.AutoButtonColor = false
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", switch)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = defaultState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        knob.BackgroundColor3 = defaultState and THEME.KnobOn or THEME.KnobOff
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local isToggled = defaultState

        local function render()
            TweenService:Create(switch, TWEEN_FAST, {
                BackgroundColor3 = isToggled and THEME.Accent or THEME.ToggleOff
            }):Play()
            TweenService:Create(knob, TWEEN_FAST, {
                BackgroundColor3 = isToggled and THEME.KnobOn or THEME.KnobOff,
                Position = isToggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            }):Play()
        end

        local function setState(value)
            isToggled = value
            render()
            if callback then callback(value) end
        end

        switch.MouseButton1Click:Connect(function() setState(not isToggled) end)
        optBtn.MouseButton1Click:Connect(function()
            toggleKeybindDropdown(row, badge, moduleId,
                function() return isToggled end,
                function(v) setState(v) end
            )
        end)

        if keybindDefault then
            local ok, code = pcall(function() return Enum.KeyCode[keybindDefault] end)
            if ok and code then
                Keybinds[moduleId] = { keyCode = code, onBind = function() setState(not isToggled) end }
            end
        end
        if callback then callback(defaultState) end
        return { setState = setState, getState = function() return isToggled end }
    end

    -- SLIDER
    local function addSlider(card, name, minVal, maxVal, defaultVal, callback, moduleId)
        moduleId = moduleId or name
        local row = Instance.new("Frame", card)
        row.Name = name
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundTransparency = 1
        table.insert(registeredRows, { Frame = row, Name = name:lower() })

        local title = Instance.new("TextLabel", row)
        title.Size = UDim2.new(1, -60, 0, 14)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 11
        title.TextColor3 = THEME.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left

        local valueLbl = Instance.new("TextLabel", row)
        valueLbl.Size = UDim2.new(0, 55, 0, 14)
        valueLbl.Position = UDim2.new(1, -55, 0, 0)
        valueLbl.BackgroundTransparency = 1
        valueLbl.Text = tostring(defaultVal)
        valueLbl.Font = Enum.Font.GothamBold
        valueLbl.TextSize = 10
        valueLbl.TextColor3 = THEME.Accent
        valueLbl.TextXAlignment = Enum.TextXAlignment.Right

        local trackHit = Instance.new("TextButton", row)
        trackHit.Size = UDim2.new(1, 0, 0, 16)
        trackHit.Position = UDim2.new(0, 0, 0, 17)
        trackHit.BackgroundTransparency = 1
        trackHit.Text = ""
        trackHit.AutoButtonColor = false

        local track = Instance.new("Frame", trackHit)
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0.5, -3)
        track.BackgroundColor3 = THEME.ToggleOff
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = THEME.Accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 0.5, 0)
        knob.BackgroundColor3 = THEME.KnobOn
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local currentValue = defaultVal
        local dragging = false

        local function updateFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = minVal + (maxVal - minVal) * rel
            if maxVal - minVal >= 20 then
                val = math.floor(val + 0.5)
            else
                val = math.floor(val * 10 + 0.5) / 10
            end
            currentValue = val
            valueLbl.Text = tostring(val)
            local p = (val - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            if callback then callback(val) end
        end

        trackHit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        if callback then callback(defaultVal) end
        return {
            setValue = function(v)
                local rel = (v - minVal) / (maxVal - minVal)
                updateFromX(track.AbsolutePosition.X + track.AbsoluteSize.X * rel)
            end,
            getValue = function() return currentValue end
        }
    end

    -- DROPDOWN
    local function addDropdown(card, name, options, defaultOption, callback, moduleId)
        moduleId = moduleId or name
        local row = Instance.new("Frame", card)
        row.Name = name
        row.Size = UDim2.new(1, 0, 0, 21)
        row.BackgroundTransparency = 1
        table.insert(registeredRows, { Frame = row, Name = name:lower() })

        local title = Instance.new("TextLabel", row)
        title.Size = UDim2.new(1, -105, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 11
        title.TextColor3 = THEME.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left

        local selector = Instance.new("TextButton", row)
        selector.Size = UDim2.new(0, 100, 0, 18)
        selector.Position = UDim2.new(1, -100, 0.5, -9)
        selector.BackgroundColor3 = THEME.BadgeBg
        selector.Text = ""
        selector.AutoButtonColor = false
        Instance.new("UICorner", selector).CornerRadius = UDim.new(0, 4)
        local selStroke = Instance.new("UIStroke", selector)
        selStroke.Color = THEME.Border
        selStroke.Thickness = 0.8
        table.insert(allSelectors, selector)

        local selText = Instance.new("TextLabel", selector)
        selText.Size = UDim2.new(1, -16, 1, 0)
        selText.Position = UDim2.new(0, 6, 0, 0)
        selText.BackgroundTransparency = 1
        selText.Text = defaultOption
        selText.Font = Enum.Font.GothamMedium
        selText.TextSize = 9.5
        selText.TextColor3 = THEME.TextPrimary
        selText.TextXAlignment = Enum.TextXAlignment.Left

        local chevron = Instance.new("ImageLabel", selector)
        chevron.Size = UDim2.new(0, 10, 0, 10)
        chevron.Position = UDim2.new(1, -13, 0.5, -5)
        chevron.BackgroundTransparency = 1
        chevron.Image = ICONS.Chevron
        chevron.ImageColor3 = THEME.TextMuted
        chevron.Rotation = 90

        local currentValue = defaultOption
        local popup = nil

        local function closePopup()
            if popup then
                unregisterPopup(popup)
                popup:Destroy()
                popup = nil
            end
        end

        local function openPopup()
            if popup then closePopup() return end
            closeAllPopups()

            local popH = #options * 24 + 6
            popup = Instance.new("Frame")
            popup.Size = UDim2.fromOffset(130, popH)
            popup.BackgroundColor3 = THEME.PopupBg
            popup.BorderSizePixel = 0
            popup.ZIndex = 10
            popup.Parent = PopupGui
            Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 6)
            local ps = Instance.new("UIStroke", popup)
            ps.Color = THEME.BorderActive
            ps.Thickness = 1
            local pl = Instance.new("UIListLayout", popup)
            pl.Padding = UDim.new(0, 1)
            local pp = Instance.new("UIPadding", popup)
            pp.PaddingTop = UDim.new(0, 3)
            pp.PaddingBottom = UDim.new(0, 3)
            pp.PaddingLeft = UDim.new(0, 4)
            pp.PaddingRight = UDim.new(0, 4)

            popup.Position = calcPopupPos(selector, Vector2.new(130, popH))

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton", popup)
                optBtn.Size = UDim2.new(1, 0, 0, 22)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = " " .. opt
                optBtn.Font = Enum.Font.GothamMedium
                optBtn.TextSize = 10
                optBtn.TextColor3 = (opt == currentValue) and THEME.Accent or THEME.TextPrimary
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.MouseEnter:Connect(function() optBtn.TextColor3 = THEME.Accent end)
                optBtn.MouseLeave:Connect(function()
                    if opt ~= currentValue then optBtn.TextColor3 = THEME.TextPrimary end
                end)
                optBtn.MouseButton1Click:Connect(function()
                    currentValue = opt
                    selText.Text = opt
                    closePopup()
                    if callback then callback(opt) end
                end)
            end
            registerPopup(popup, closePopup)
        end

        selector.MouseButton1Click:Connect(openPopup)
        if callback then callback(defaultOption) end
        return {
            setValue = function(v) currentValue = v selText.Text = v end,
            getValue = function() return currentValue end
        }
    end

    -- COLOR PICKER
    local function addColorPicker(card, name, defaultHex, callback, moduleId)
        moduleId = moduleId or name
        local row = Instance.new("Frame", card)
        row.Name = name
        row.Size = UDim2.new(1, 0, 0, 21)
        row.BackgroundTransparency = 1
        table.insert(registeredRows, { Frame = row, Name = name:lower() })

        local title = Instance.new("TextLabel", row)
        title.Size = UDim2.new(1, -80, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 11
        title.TextColor3 = THEME.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left

        local preview = Instance.new("TextButton", row)
        preview.Size = UDim2.new(0, 40, 0, 16)
        preview.Position = UDim2.new(1, -60, 0.5, -8)
        preview.BackgroundColor3 = hexToColor(defaultHex)
        preview.Text = ""
        preview.AutoButtonColor = false
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 3)
        local pStroke = Instance.new("UIStroke", preview)
        pStroke.Color = THEME.Border
        pStroke.Thickness = 1
        table.insert(allSelectors, preview)

        local hexLbl = Instance.new("TextLabel", row)
        hexLbl.Size = UDim2.new(0, 18, 1, 0)
        hexLbl.Position = UDim2.new(1, -18, 0, 0)
        hexLbl.BackgroundTransparency = 1
        hexLbl.Text = defaultHex:gsub("#", ""):sub(1, 3):upper()
        hexLbl.Font = Enum.Font.GothamBold
        hexLbl.TextSize = 8
        hexLbl.TextColor3 = THEME.TextMuted

        local currentHex = defaultHex:gsub("#", ""):upper()
        local popup = nil

        local function closePopup()
            if popup then
                unregisterPopup(popup)
                popup:Destroy()
                popup = nil
            end
        end

        local function parseHex(hex)
            hex = hex:gsub("#", "")
            if #hex ~= 6 then return nil end
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if not r or not g or not b then return nil end
            return Color3.fromRGB(r, g, b)
        end

        local function openPopup()
            if popup then closePopup() return end
            closeAllPopups()

            local POP_W, POP_H = 210, 200
            popup = Instance.new("Frame")
            popup.Size = UDim2.fromOffset(POP_W, POP_H)
            popup.BackgroundColor3 = THEME.PopupBg
            popup.BorderSizePixel = 0
            popup.ZIndex = 10
            popup.Parent = PopupGui
            Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 6)
            local ps = Instance.new("UIStroke", popup)
            ps.Color = THEME.BorderActive
            ps.Thickness = 1
            popup.Position = calcPopupPos(preview, Vector2.new(POP_W, POP_H))

            local hexBox = Instance.new("TextBox", popup)
            hexBox.Size = UDim2.new(1, -12, 0, 20)
            hexBox.Position = UDim2.new(0, 6, 0, 6)
            hexBox.BackgroundColor3 = THEME.BadgeBg
            hexBox.Text = currentHex
            hexBox.PlaceholderText = "RRGGBB"
            hexBox.Font = Enum.Font.GothamBold
            hexBox.TextSize = 10
            hexBox.TextColor3 = THEME.TextPrimary
            hexBox.ClearTextOnFocus = false
            hexBox.TextXAlignment = Enum.TextXAlignment.Center
            Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 4)
            local hbStroke = Instance.new("UIStroke", hexBox)
            hbStroke.Color = THEME.Border
            hbStroke.Thickness = 1

            local SQ_W, SQ_H = 190, 100
            local sv = Instance.new("Frame", popup)
            sv.Size = UDim2.fromOffset(SQ_W, SQ_H)
            sv.Position = UDim2.fromOffset(10, 34)
            sv.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            sv.BorderSizePixel = 0
            sv.ClipsDescendants = true
            Instance.new("UICorner", sv).CornerRadius = UDim.new(0, 4)

            local satOverlay = Instance.new("Frame", sv)
            satOverlay.Size = UDim2.new(1, 0, 1, 0)
            satOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
            satOverlay.BorderSizePixel = 0
            local satGrad = Instance.new("UIGradient", satOverlay)
            satGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
            satGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            satGrad.Rotation = 0

            local valOverlay = Instance.new("Frame", sv)
            valOverlay.Size = UDim2.new(1, 0, 1, 0)
            valOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
            valOverlay.BorderSizePixel = 0
            local valGrad = Instance.new("UIGradient", valOverlay)
            valGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
            valGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            })
            valGrad.Rotation = 90

            local svBorder = Instance.new("UIStroke", sv)
            svBorder.Color = THEME.Border
            svBorder.Thickness = 1

            local dot = Instance.new("Frame", sv)
            dot.Size = UDim2.fromOffset(10, 10)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
            dot.BorderSizePixel = 0
            dot.ZIndex = 5
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            local dotStroke = Instance.new("UIStroke", dot)
            dotStroke.Color = Color3.new(0, 0, 0)
            dotStroke.Thickness = 1.5

            local HUE_Y = 34 + SQ_H + 12
            local hueHit = Instance.new("TextButton", popup)
            hueHit.Size = UDim2.fromOffset(SQ_W, 14)
            hueHit.Position = UDim2.fromOffset(10, HUE_Y)
            hueHit.BackgroundTransparency = 1
            hueHit.Text = ""
            hueHit.AutoButtonColor = false

            local hueBar = Instance.new("Frame", hueHit)
            hueBar.Size = UDim2.new(1, 0, 0, 10)
            hueBar.Position = UDim2.new(0, 0, 0.5, -5)
            hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            hueBar.BorderSizePixel = 0
            Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)

            local hueGrad = Instance.new("UIGradient", hueBar)
            hueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))
            })

            local hueKnob = Instance.new("Frame", hueBar)
            hueKnob.Size = UDim2.fromOffset(6, 14)
            hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            hueKnob.Position = UDim2.new(0, 0, 0.5, 0)
            hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            hueKnob.BorderSizePixel = 0
            hueKnob.ZIndex = 5
            Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 3)
            local hkStroke = Instance.new("UIStroke", hueKnob)
            hkStroke.Color = Color3.new(0, 0, 0)
            hkStroke.Thickness = 1

            local prevBar = Instance.new("Frame", popup)
            prevBar.Size = UDim2.fromOffset(SQ_W, 10)
            prevBar.Position = UDim2.fromOffset(10, HUE_Y + 22)
            prevBar.BackgroundColor3 = hexToColor(currentHex)
            prevBar.BorderSizePixel = 0
            Instance.new("UICorner", prevBar).CornerRadius = UDim.new(1, 0)
            local pbStroke = Instance.new("UIStroke", prevBar)
            pbStroke.Color = THEME.Border
            pbStroke.Thickness = 1

            local h, s, v = Color3.toHSV(hexToColor(currentHex))

            local function hsvToHexRgb()
                local col = Color3.fromHSV(h, s, v)
                local r = math.floor(col.R * 255 + 0.5)
                local g = math.floor(col.G * 255 + 0.5)
                local b = math.floor(col.B * 255 + 0.5)
                return col, r, g, b
            end

            local function updateAll()
                sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                dot.Position = UDim2.new(s, 0, 1 - v, 0)
                hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
                local col, r, g, b = hsvToHexRgb()
                prevBar.BackgroundColor3 = col
                preview.BackgroundColor3 = col
                currentHex = string.format("%02X%02X%02X", r, g, b)
                hexLbl.Text = currentHex:sub(1, 3)
                if not hexBox:IsFocused() then
                    hexBox.Text = currentHex
                end
                if callback then callback("#" .. currentHex) end
            end

            local svDrag = false
            local function updateSVFromPos(mx, my)
                local relX = math.clamp((mx - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((my - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                s = relX
                v = 1 - relY
                updateAll()
            end

            local svClick = Instance.new("TextButton", sv)
            svClick.Size = UDim2.new(1, 0, 1, 0)
            svClick.BackgroundTransparency = 1
            svClick.Text = ""
            svClick.ZIndex = 6
            svClick.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDrag = true
                    updateSVFromPos(input.Position.X, input.Position.Y)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if svDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSVFromPos(input.Position.X, input.Position.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
            end)

            local hDrag = false
            local function updateHueFromX(x)
                local rel = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                h = rel
                updateAll()
            end

            hueHit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hDrag = true
                    updateHueFromX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if hDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateHueFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then hDrag = false end
            end)

            hexBox.FocusLost:Connect(function()
                local col = parseHex(hexBox.Text)
                if col then
                    h, s, v = Color3.toHSV(col)
                    updateAll()
                else
                    hexBox.Text = currentHex
                end
            end)

            updateAll()
            registerPopup(popup, closePopup)
        end

        preview.MouseButton1Click:Connect(openPopup)
        if callback then callback("#" .. currentHex) end

        return {
            setValue = function(hex)
                currentHex = hex:gsub("#", ""):upper()
                preview.BackgroundColor3 = hexToColor(currentHex)
                hexLbl.Text = currentHex:sub(1, 3)
            end,
            getValue = function() return currentHex end
        }
    end

    -- MAIN FRAME
    Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 790, 0, 490)
    Main.Position = UDim2.new(0.5, -395, 0.5, -245)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false
    Main.Parent = ScreenGui
    Main.Visible = false
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = THEME.Border
    MainStroke.Thickness = 1.2

    local GlowBackdrop = Instance.new("ImageLabel", Main)
    GlowBackdrop.BackgroundTransparency = 1
    GlowBackdrop.Position = UDim2.new(0, -45, 0, -45)
    GlowBackdrop.Size = UDim2.new(1, 90, 1, 90)
    GlowBackdrop.ZIndex = 0
    GlowBackdrop.Image = "rbxassetid://5028857084"
    GlowBackdrop.ImageColor3 = THEME.AccentDark
    GlowBackdrop.ImageTransparency = 0.83
    GlowBackdrop.ScaleType = Enum.ScaleType.Slice
    GlowBackdrop.SliceCenter = Rect.new(24, 24, 276, 276)

    do
        local dragging, dragStart, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 56)
    TopBar.BackgroundTransparency = 1

    local MainLogoHolder = Instance.new("Frame", TopBar)
    MainLogoHolder.Size = UDim2.new(0, 64, 0, 64)
    MainLogoHolder.Position = UDim2.new(0, 52, 0, -4)
    MainLogoHolder.BackgroundTransparency = 1

    local MainLogoHalo = Instance.new("ImageLabel", MainLogoHolder)
    MainLogoHalo.Size = UDim2.new(2.1, 0, 2.1, 0)
    MainLogoHalo.Position = UDim2.new(-0.55, 0, -0.55, 0)
    MainLogoHalo.BackgroundTransparency = 1
    MainLogoHalo.Image = "rbxassetid://5028857084"
    MainLogoHalo.ImageColor3 = THEME.Accent
    MainLogoHalo.ImageTransparency = 0.58
    MainLogoHalo.ZIndex = 1

    local MainLogoImg = Instance.new("ImageLabel", MainLogoHolder)
    MainLogoImg.Size = UDim2.new(1, 0, 1, 0)
    MainLogoImg.BackgroundTransparency = 1
    MainLogoImg.Image = CUSTOM_LOGO_ID
    MainLogoImg.ScaleType = Enum.ScaleType.Fit
    MainLogoImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MainLogoImg.ZIndex = 3

    local MainLogoGrad = Instance.new("UIGradient", MainLogoImg)
    MainLogoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 175, 165)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(246, 92, 82)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(165, 32, 42))
    })
    MainLogoGrad.Rotation = -35

    local SearchBox = Instance.new("Frame", TopBar)
    SearchBox.Size = UDim2.new(0, 250, 0, 26)
    SearchBox.Position = UDim2.new(0, 185, 0, 15)
    SearchBox.BackgroundColor3 = THEME.CardBg
    SearchBox.BorderSizePixel = 0
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    local SearchStroke = Instance.new("UIStroke", SearchBox)
    SearchStroke.Color = THEME.Border
    SearchStroke.Thickness = 0.8

    local SearchIcon = Instance.new("ImageLabel", SearchBox)
    SearchIcon.Size = UDim2.new(0, 13, 0, 13)
    SearchIcon.Position = UDim2.new(0, 9, 0.5, -6.5)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = ICONS.Search
    SearchIcon.ImageColor3 = THEME.TextMuted

    SearchInput = Instance.new("TextBox", SearchBox)
    SearchInput.PlaceholderText = "Search something"
    SearchInput.PlaceholderColor3 = THEME.TextMuted
    SearchInput.TextColor3 = THEME.TextPrimary
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 11
    SearchInput.Position = UDim2.new(0, 30, 0, 0)
    SearchInput.Size = UDim2.new(1, -36, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, item in ipairs(registeredRows) do
            item.Frame.Visible = (query == "" or string.find(item.Name, query, 1, true)) and true or false
        end
    end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 155, 1, -58)
    Sidebar.Position = UDim2.new(0, 14, 0, 54)
    Sidebar.BackgroundTransparency = 1
    local SideList = Instance.new("UIListLayout", Sidebar)
    SideList.Padding = UDim.new(0, 2)
    SideList.SortOrder = Enum.SortOrder.LayoutOrder

    local Footer = Instance.new("Frame", Main)
    Footer.Size = UDim2.new(0, 160, 0, 28)
    Footer.Position = UDim2.new(0, 18, 1, -38)
    Footer.BackgroundTransparency = 1

    local UserLabel = Instance.new("TextLabel", Footer)
    UserLabel.Size = UDim2.new(1, 0, 0, 13)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Text = string.lower(LocalPlayer.Name)
    UserLabel.Font = Enum.Font.GothamBold
    UserLabel.TextSize = 10
    UserLabel.TextColor3 = THEME.TextMuted
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SubLabel = Instance.new("TextLabel", Footer)
    SubLabel.Size = UDim2.new(1, 0, 0, 11)
    SubLabel.Position = UDim2.new(0, 0, 0, 13)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Nurpukan • LCTRL to toggle"
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 7.5
    SubLabel.TextColor3 = THEME.TextDim
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ContentArea = Instance.new("Frame", Main)
    ContentArea.Size = UDim2.new(1, -195, 1, -62)
    ContentArea.Position = UDim2.new(0, 182, 0, 54)
    ContentArea.BackgroundTransparency = 1

    local function createPage(name)
        local page = Instance.new("Frame", ContentArea)
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false

        local c1 = Instance.new("ScrollingFrame", page)
        c1.Size = UDim2.new(0.485, 0, 1, 0)
        c1.BackgroundTransparency = 1
        c1.ScrollBarThickness = 0
        c1.CanvasSize = UDim2.new(0, 0, 0, 0)
        c1.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local c2 = Instance.new("ScrollingFrame", page)
        c2.Size = UDim2.new(0.485, 0, 1, 0)
        c2.Position = UDim2.new(0.515, 0, 0, 0)
        c2.BackgroundTransparency = 1
        c2.ScrollBarThickness = 0
        c2.CanvasSize = UDim2.new(0, 0, 0, 0)
        c2.AutomaticCanvasSize = Enum.AutomaticSize.Y

        for _, col in ipairs({ c1, c2 }) do
            local l = Instance.new("UIListLayout", col)
            l.Padding = UDim.new(0, 12)
            l.SortOrder = Enum.SortOrder.LayoutOrder
        end
        Pages[name] = page
        return c1, c2
    end

    local function createCard(parent, titleText, order)
        local card = Instance.new("Frame", parent)
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = THEME.CardBg
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", card)
        s.Color = THEME.Border
        s.Thickness = 0.8
        local p = Instance.new("UIPadding", card)
        p.PaddingTop = UDim.new(0, 11)
        p.PaddingBottom = UDim.new(0, 13)
        p.PaddingLeft = UDim.new(0, 12)
        p.PaddingRight = UDim.new(0, 12)
        local list = Instance.new("UIListLayout", card)
        list.Padding = UDim.new(0, 10)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        local header = Instance.new("Frame", card)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.LayoutOrder = 0

        local title = Instance.new("TextLabel", header)
        title.Size = UDim2.new(1, -20, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextColor3 = THEME.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left

        local icon = Instance.new("ImageLabel", header)
        icon.Size = UDim2.new(0, 12, 0, 12)
        icon.Position = UDim2.new(1, -12, 0.5, -6)
        icon.BackgroundTransparency = 1
        icon.Image = ICONS.Chevron
        icon.ImageColor3 = THEME.Accent

        return card
    end

    local function addCategory(name, order)
        local lbl = Instance.new("TextLabel", Sidebar)
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.LayoutOrder = order
        lbl.BackgroundTransparency = 1
        lbl.Text = "   " .. name:upper()
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextColor3 = THEME.TextDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function switchPage(pageName)
        for name, frame in pairs(Pages) do
            frame.Visible = (name == pageName)
        end
        for name, tab in pairs(sidebarButtons) do
            local isActive = (name == pageName)
            TweenService:Create(tab.Btn, TWEEN_FAST, {
                BackgroundTransparency = isActive and 0 or 1,
                BackgroundColor3 = isActive and THEME.SidebarActive or THEME.Background
            }):Play()
            TweenService:Create(tab.Stroke, TWEEN_FAST, {
                Transparency = isActive and 0 or 1,
                Color = isActive and THEME.BorderActive or Color3.fromRGB(0, 0, 0)
            }):Play()
            TweenService:Create(tab.Icon, TWEEN_FAST, { ImageColor3 = isActive and THEME.Accent or THEME.TextMuted }):Play()
            TweenService:Create(tab.Title, TWEEN_FAST, { TextColor3 = isActive and THEME.TextPrimary or THEME.TextMuted }):Play()
        end
    end

    local function addSidebarItem(name, iconId, isDefaultActive, order)
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, -4, 0, 29)
        btn.LayoutOrder = order
        btn.BackgroundColor3 = isDefaultActive and THEME.SidebarActive or THEME.Background
        btn.BackgroundTransparency = isDefaultActive and 0 or 1
        btn.Text = ""
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = isDefaultActive and THEME.BorderActive or Color3.fromRGB(0, 0, 0)
        stroke.Transparency = isDefaultActive and 0 or 1
        stroke.Thickness = 1

        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0, 9, 0.5, -7)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageColor3 = isDefaultActive and THEME.Accent or THEME.TextMuted

        local title = Instance.new("TextLabel", btn)
        title.Size = UDim2.new(1, -32, 1, 0)
        title.Position = UDim2.new(0, 30, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 11
        title.TextColor3 = isDefaultActive and THEME.TextPrimary or THEME.TextMuted
        title.TextXAlignment = Enum.TextXAlignment.Left

        sidebarButtons[name] = { Btn = btn, Icon = icon, Title = title, Stroke = stroke }

        btn.MouseEnter:Connect(function()
            if not Pages[name] or not Pages[name].Visible then
                TweenService:Create(title, TWEEN_FAST, { TextColor3 = THEME.TextPrimary }):Play()
                TweenService:Create(icon, TWEEN_FAST, { ImageColor3 = THEME.TextPrimary }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if not Pages[name] or not Pages[name].Visible then
                TweenService:Create(title, TWEEN_FAST, { TextColor3 = THEME.TextMuted }):Play()
                TweenService:Create(icon, TWEEN_FAST, { ImageColor3 = THEME.TextMuted }):Play()
            end
        end)
        btn.MouseButton1Click:Connect(function() switchPage(name) end)
    end

    local combatC1, combatC2 = createPage("Combat")
    local movementC1, movementC2 = createPage("Movement")
    local visualsC1, visualsC2 = createPage("Visuals")
    local playerC1, playerC2 = createPage("Player")
    local miscC1, miscC2 = createPage("Misc")
    local presetsC1, presetsC2 = createPage("Presets")
    local autobuyC1, autobuyC2 = createPage("Auto Buy")
    local accountsC1, accountsC2 = createPage("Accounts")
    local settingsC1, settingsC2 = createPage("Settings")

    addCategory("Features", 1)
    addSidebarItem("Combat", ICONS.Combat, true, 2)
    addSidebarItem("Movement", ICONS.Movement, false, 3)
    addSidebarItem("Visuals", ICONS.Visuals, false, 4)
    addSidebarItem("Player", ICONS.Player, false, 5)
    addSidebarItem("Misc", ICONS.Misc, false, 6)
    addCategory("Manager", 7)
    addSidebarItem("Presets", ICONS.Presets, false, 8)
    addSidebarItem("Auto Buy", ICONS.AutoBuy, false, 9)
    addSidebarItem("Accounts", ICONS.Accounts, false, 10)
    addCategory("Config", 11)
    addSidebarItem("Settings", ICONS.Settings, false, 12)

    -- COMBAT
    local cardKillAura = createCard(combatC1, "Kill Aura", 1)
    local cutLabel = Instance.new("TextLabel", cardKillAura)
    cutLabel.Size = UDim2.new(1, 0, 0, 21)
    cutLabel.BackgroundTransparency = 1
    cutLabel.Text = "(вырезано)"
    cutLabel.Font = Enum.Font.GothamMedium
    cutLabel.TextSize = 11
    cutLabel.TextColor3 = THEME.TextMuted
    cutLabel.TextXAlignment = Enum.TextXAlignment.Left

    local cardAimBot = createCard(combatC2, "Aim Bot", 1)
    addToggle(cardAimBot, "Aim Bot", "Snap to closest target", false, nil, function(on)
        STATE.aimbot = on
        aimBotSettings.enabled = on
    end, "aimbot")
    addSlider(cardAimBot, "FOV Radius", 30, 1000, 150, function(v) aimBotSettings.radius = v end, "aimbot_radius")
    addToggle(cardAimBot, "Show Radius", nil, true, nil, function(on) aimBotSettings.showRadius = on end, "aimbot_showradius")
    addToggle(cardAimBot, "Left Click", nil, true, nil, function(on) aimBotSettings.leftClick = on end, "aimbot_left")
    addToggle(cardAimBot, "Right Click", nil, false, nil, function(on) aimBotSettings.rightClick = on end, "aimbot_right")
    addDropdown(cardAimBot, "Priority", { "Only Murderer", "Murderer", "Distance", "HP" }, "Only Murderer", function(v) aimBotSettings.priority = v end, "aimbot_priority")

    -- MOVEMENT
    local cardSpeed = createCard(movementC1, "Speed", 1)
    addToggle(cardSpeed, "Speed", "Enable walk speed boost", false, nil, function(on)
        STATE.speed = on
        if on then applySpeed()
        else
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end, "speed")
    addSlider(cardSpeed, "Walk Speed", 16, 200, 50, function(v)
        currentSettings.walkSpeed = v
        if STATE.speed then applySpeed() end
    end, "speed_value")

    local cardSpin = createCard(movementC2, "Spin", 1)
    addToggle(cardSpin, "Spin", "Rotate character", false, nil, function(on)
        STATE.spin = on
        setSpin(on)
    end, "spin")
    addSlider(cardSpin, "Spin Speed", 5, 180, 35, function(v) currentSettings.spinSpeed = v end, "spin_speed")

    local cardFly = createCard(movementC1, "Flight", 2)
    addToggle(cardFly, "Flight", "Space=up, Shift=down", false, nil, function(on)
        if on then FlyEnable() else FlyDisable() end
    end, "flight")
    addSlider(cardFly, "Fly Speed", 10, 500, 100, function(v) FlySettings.speed = v end, "fly_speed")
    addSlider(cardFly, "Acceleration", 1, 20, 8, function(v) FlySettings.acceleration = v end, "fly_accel")

    local cardJump = createCard(movementC2, "Jump", 2)
    addToggle(cardJump, "Jump Boost", "Custom jump power", false, nil, function(on)
        if on then JumpEnable() else JumpDisable() end
    end, "jump")
    addSlider(cardJump, "Jump Power", 50, 500, 100, function(v)
        JumpSettings.power = v
        if JumpState.active then JumpApply() end
    end, "jump_power")

    local cardNoclip = createCard(movementC1, "Noclip", 3)
    addToggle(cardNoclip, "Noclip", "Walk through walls", false, nil, function(on)
        if on then NoclipEnable() else NoclipDisable() end
    end, "noclip")

    local cardInfJump = createCard(movementC2, "Infinite Jump", 3)
    addToggle(cardInfJump, "Infinite Jump", "Jump midair", false, nil, function(on)
        if on then InfJumpEnable() else InfJumpDisable() end
    end, "inf_jump")

    -- VISUALS
    local cardESP = createCard(visualsC1, "ESP", 1)
    addToggle(cardESP, "ESP", "Highlight players", false, nil, function(on)
        espEnabled = on
        STATE.esp = on
        if on then
            for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
        else
            for p, _ in pairs(espList) do removeESP(p) end
        end
    end, "esp")
    addToggle(cardESP, "Show Names", nil, true, nil, function(on) currentSettings.showNames = on end, "esp_names")
    addToggle(cardESP, "Show HP", nil, true, nil, function(on) currentSettings.showHP = on end, "esp_hp")
    addToggle(cardESP, "Show Inventory", nil, true, nil, function(on) currentSettings.showInventory = on end, "esp_inv")
    addToggle(cardESP, "Role Colors", nil, true, nil, function(on) currentSettings.roleColors = on end, "esp_roles")
    addColorPicker(cardESP, "ESP Color", "#FFFFFF", function(hex) currentSettings.espColor = hex end, "esp_color")

    local cardFB = createCard(visualsC2, "Fullbright", 1)
    addToggle(cardFB, "Fullbright", "Bright lighting", false, nil, function(on)
        STATE.fullbright = on
        setFullbright(on)
    end, "fullbright")

    local cardGunSight = createCard(visualsC2, "Gun Sight", 2)
    addToggle(cardGunSight, "Gun Sight", "Custom cursor with guns", false, nil, function(on)
        STATE.gunsight = on
        currentSettings.gunSight = on
    end, "gunsight")

    local cardHotbar = createCard(visualsC1, "Custom Hotbar", 2)
    addToggle(cardHotbar, "Custom Hotbar", "Custom inventory bar", false, nil, function(on)
        STATE.hotbar = on
        toggleHotbar(on)
    end, "hotbar")
    addSlider(cardHotbar, "Slot Size", 30, 90, 50, function(v)
        currentSettings.hotbarSize = v
        if STATE.hotbar then updateHotbarItems() end
    end, "hotbar_size")
    addSlider(cardHotbar, "BG Opacity", 0, 1, 0.4, function(v)
        currentSettings.hotbarTransparency = v
        if STATE.hotbar then applyHotbarStyle() end
    end, "hotbar_transparency")
    addColorPicker(cardHotbar, "BG Color", "#000000", function(hex)
        currentSettings.hotbarColor = hex
        if STATE.hotbar then applyHotbarStyle() end
    end, "hotbar_color")
    addColorPicker(cardHotbar, "Glow Color", "#FFFFFF", function(hex)
        currentSettings.hotbarGlow = hex
        if STATE.hotbar then applyHotbarStyle() end
    end, "hotbar_glow")

    local cardHud = createCard(visualsC2, "HUD", 3)
    addToggle(cardHud, "Show HUD", "Toggle watermark", true, nil, function(on)
        STATE.hud = on
        if HudContainer then HudContainer.Visible = on end
    end, "hud_show")
    addToggle(cardHud, "HUD Draggable", "Drag with mouse", false, nil, function(on)
        STATE.hudDraggable = on
    end, "hud_drag")
    addSlider(cardHud, "HUD Size", 0.5, 2, 1, function(v)
        if HudScale then HudScale.Scale = v end
        currentSettings.hudScale = v
    end, "hud_scale")

    local cardSkybox = createCard(visualsC2, "Custom Skybox", 4)
    addToggle(cardSkybox, "Custom Skybox", "Apply custom skybox", false, nil, function(on)
        if on then SkyboxEnable() else SkyboxDisable() end
    end, "skybox")
    addDropdown(cardSkybox, "Preset", { "Default", "Space", "Night", "Sunset", "Clouds" }, "Default",
        function(v)
            SkyboxState.currentPreset = v
            if SkyboxState.active then SkyboxApply(v) end
        end, "skybox_preset")

    local cardTime = createCard(visualsC1, "Time Changer", 3)
    addToggle(cardTime, "Time Changer", "Change time of day", false, nil, function(on)
        if on then TimeEnable() else TimeDisable() end
    end, "time_changer")
    addSlider(cardTime, "Time (hours)", 0, 24, 12, function(v)
        TimeState.value = v
        TimeApply()
    end, "time_value")

    local cardFog = createCard(visualsC1, "Remove Fog", 4)
    addToggle(cardFog, "Remove Fog", "Disable fog", false, nil, function(on)
        if on then FogEnable() else FogDisable() end
    end, "remove_fog")

    local cardGiveAll = createCard(visualsC2, "Give All (MM2)", 5)
    addToggle(cardGiveAll, "Give All Weapons", "Give all MM2 weapons + meshes", false, nil, function(on)
        if on then MM2Enable() else MM2Disable() end
    end, "give_all_mm2")

    -- PLAYER
    local cardPlayer = createCard(playerC1, "Player", 1)
    addToggle(cardPlayer, "Anti-Fling", "Prevent getting flung", false, nil, function(on)
        if on then AntiFlingEnable() else AntiFlingDisable() end
    end, "anti_fling")

    local cardPlayerRight = createCard(playerC2, "Info", 1)

    -- MISC
    local cardMisc = createCard(miscC1, "Misc", 1)

    -- SETTINGS
    local cardMenu = createCard(settingsC1, "Menu", 1)
    addDropdown(cardMenu, "Menu Toggle Key",
        { "LeftControl", "RightControl", "RightShift", "LeftShift", "Insert", "Delete", "Home", "End", "F1", "F2", "F3", "F4", "F5" },
        "LeftControl",
        function(v)
            _G.NurpukanMenuKey = v
        end, "menu_key")

    switchPage("Combat")

    local isUIVisible = false
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local wantedName = _G.NurpukanMenuKey or "LeftControl"
        local wantedKey = Enum.KeyCode[wantedName]
        if wantedKey and input.KeyCode == wantedKey then
            isUIVisible = not isUIVisible
            closeAllPopups()
            if isUIVisible then
                Main.Visible = true
                Main.Position = UDim2.new(0.5, -395, 0.5, -215)
                TweenService:Create(Main, TWEEN_SLOW, {
                    Position = UDim2.new(0.5, -395, 0.5, -245)
                }):Play()
            else
                local t = TweenService:Create(Main, TWEEN_SLOW, {
                    Position = UDim2.new(0.5, -395, 0.5, -215)
                })
                t:Play()
                t.Completed:Connect(function()
                    if not isUIVisible then Main.Visible = false end
                end)
            end
        end
    end)
end

print("[Nurpukan] GUI loaded — (Kill Aura removed)")
