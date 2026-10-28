--[[
	User Interface Library
	Made by Late
	Version: 2.0 with ToggleDropdown
]]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = { --// (Dark Theme)
	--// Frames:
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),

	--// Text:
	Tab = Color3.fromRGB(200, 200, 200),
	Title = Color3.fromRGB(240,240,240),
	Description = Color3.fromRGB(200,200,200),

	--// Outlines:
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),

	--// Image:
	Icon = Color3.fromRGB(220, 220, 220),
}

--// Services & Functions
local Type = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object, Speed, Properties, Info)
	local Style, Direction

	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object, Properties)
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end

	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}

	return UDim2.new(unpack(New))
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(Canvas.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

local Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

local Resizeable = function(Tab, Minimum, Maximum)
	spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)

				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
local Screen
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
else
	Screen = (script.Parent);
end

Screen.Main.Visible = false

local success = pcall(function()
	Screen.Parent = game.CoreGui
end)
if not success then
	Screen.Parent = Player.GUI
end

--// Tables for Data
local Animations = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Bind System Storage
local BindStorage = {}
local VisualButtonsContainer = nil

-- Create visual buttons container
local function createVisualButtonsContainer()
	if VisualButtonsContainer then return VisualButtonsContainer end
	
	local container = Instance.new("ScreenGui")
	container.Name = "VisualButtonsContainer"
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local success = pcall(function()
		container.Parent = game.CoreGui
	end)
	if not success then
		container.Parent = Player.GUI
	end
	
	VisualButtonsContainer = container
	return container
end

-- Function to create bind settings window (minimalist design)
local function createBindSettingsWindow(elementTitle, onBindChange, onToggle, currentBind, parentElement)
	local bindWindow = Instance.new("CanvasGroup")
	bindWindow.Name = "BindSettings"
	bindWindow.Size = UDim2.new(0, 140, 0, 70)
	bindWindow.BackgroundColor3 = Theme.Secondary
	bindWindow.BorderSizePixel = 0
	bindWindow.ZIndex = 999
	bindWindow.Visible = false
	bindWindow.GroupTransparency = Setup.Transparency or 0
	bindWindow.Parent = Screen
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = bindWindow
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Outline
	stroke.Thickness = 2
	stroke.Parent = bindWindow
	
	-- Close button (X)
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 16, 0, 16)
	closeButton.Position = UDim2.new(1, -18, 0, 2)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.Font = Enum.Font.GothamBold
	closeButton.ZIndex = 1001
	closeButton.Parent = bindWindow
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 3)
	closeCorner.Parent = closeButton
	
	-- Keybind text (clickable to change) - TextBox to prevent ESC menu
	local bindButton = Instance.new("TextBox")
	bindButton.Name = "BindInput"
	bindButton.Size = UDim2.new(1, -20, 0, 25)
	bindButton.Position = UDim2.new(0, 10, 0, 10)
	bindButton.BackgroundColor3 = Theme.Component
	bindButton.BorderSizePixel = 0
	bindButton.Text = "Keybind " .. (currentBind or "None")
	bindButton.TextColor3 = Theme.Title
	bindButton.TextSize = 12
	bindButton.Font = Enum.Font.Gotham
	bindButton.TextEditable = false
	bindButton.ClearTextOnFocus = false
	bindButton.ZIndex = 1000
	bindButton.Parent = bindWindow
	
	local bindCorner = Instance.new("UICorner")
	bindCorner.CornerRadius = UDim.new(0, 4)
	bindCorner.Parent = bindButton
	
	-- Create visual button
	local visualButton = Instance.new("TextButton")
	visualButton.Size = UDim2.new(1, -20, 0, 25)
	visualButton.Position = UDim2.new(0, 10, 0, 40)
	visualButton.BackgroundColor3 = Theme.Interactables
	visualButton.BorderSizePixel = 0
	visualButton.Text = "Create Button"
	visualButton.TextColor3 = Theme.Title
	visualButton.TextSize = 11
	visualButton.Font = Enum.Font.GothamBold
	visualButton.ZIndex = 1000
	visualButton.Parent = bindWindow
	
	local visualCorner = Instance.new("UICorner")
	visualCorner.CornerRadius = UDim.new(0, 4)
	visualCorner.Parent = visualButton
	
	-- Position window near gear icon (to the right)
	if parentElement then
		local function updatePosition()
			if not bindWindow or not bindWindow.Parent then return end
			if not parentElement or not parentElement.Parent then return end
			
			local iconAbsPos = parentElement.AbsolutePosition
			local iconAbsSize = parentElement.AbsoluteSize
			
			-- Position to the right of the gear icon
			bindWindow.Position = UDim2.new(0, iconAbsPos.X + iconAbsSize.X + 5, 0, iconAbsPos.Y)
		end
		
		updatePosition()
		
		-- Update position when parent scrolls or moves
		bindWindow:GetPropertyChangedSignal("Visible"):Connect(function()
			if bindWindow.Visible then
				updatePosition()
			end
		end)
	end
	
	-- Close button logic
	closeButton.MouseButton1Click:Connect(function()
		bindWindow.Visible = false
	end)
	
	-- Bind button logic with ESC menu prevention (using TextBox Focused)
	local waitingForKey = false
	local escConnection = nil
	local keyConnection = nil
	
	bindButton.Focused:Connect(function()
		if waitingForKey then return end
		waitingForKey = true
		bindButton.Text = "Press Key... (ESC - Unbind)"
		
		-- Block ESC menu while waiting for key
		if escConnection then
			escConnection:Disconnect()
		end
		escConnection = Services.Input.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Escape then
				-- Sink the ESC key so Roblox menu doesn't open
				game:GetService("ContextActionService"):BindAction(
					"BlockESC",
					function() return Enum.ContextActionResult.Sink end,
					false,
					Enum.KeyCode.Escape
				)
				-- Unbind immediately after
				task.wait()
				game:GetService("ContextActionService"):UnbindAction("BlockESC")
			end
		end)
		
		if keyConnection then
			keyConnection:Disconnect()
		end
		keyConnection = Services.Input.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local keyName = input.KeyCode.Name
				-- ESC to reset
				if keyName == "Escape" then
					bindButton.Text = "Keybind None"
					onBindChange(nil)
					waitingForKey = false
					bindButton:ReleaseFocus()
					if keyConnection then
						keyConnection:Disconnect()
						keyConnection = nil
					end
					if escConnection then
						escConnection:Disconnect()
						escConnection = nil
					end
					return
				end
				bindButton.Text = "Keybind " .. keyName
				onBindChange(keyName)
				waitingForKey = false
				bindButton:ReleaseFocus()
				if keyConnection then
					keyConnection:Disconnect()
					keyConnection = nil
				end
				if escConnection then
					escConnection:Disconnect()
					escConnection = nil
				end
			end
		end)
	end)
	
	bindButton.FocusLost:Connect(function()
		if waitingForKey then
			waitingForKey = false
			if bindButton.Text == "Press Key... (ESC - Unbind)" then
				bindButton.Text = "Keybind " .. (currentBind or "None")
			end
			if keyConnection then
				keyConnection:Disconnect()
				keyConnection = nil
			end
			if escConnection then
				escConnection:Disconnect()
				escConnection = nil
			end
		end
	end)
	
	-- Visual button logic
	visualButton.MouseButton1Click:Connect(function()
		local newText = onToggle()
		if newText then
			visualButton.Text = newText
		end
	end)
	
	return bindWindow, visualButton, bindButton
end

-- Function to create visual button on screen
local function createVisualButton(elementTitle, callback)
	local container = createVisualButtonsContainer()
	
	local button = Instance.new("TextButton")
	button.Name = "VisualButton_" .. elementTitle
	button.Size = UDim2.new(0, 60, 0, 60)
	button.Position = UDim2.new(0, 10 + ((#container:GetChildren() % 3) * 70), 0, 10 + (math.floor(#container:GetChildren() / 3) * 70))
	button.BackgroundColor3 = Theme.Component
	button.BorderSizePixel = 0
	button.Text = ""
	button.TextColor3 = Theme.Title
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.ZIndex = 100
	button.Parent = container
	
	-- Make button circular
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Outline
	stroke.Thickness = 2
	stroke.Parent = button
	
	-- Add text label inside circle
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, -10)
	label.Position = UDim2.new(0, 5, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = elementTitle
	label.TextColor3 = Theme.Title
	label.TextSize = 9
	label.Font = Enum.Font.GothamBold
	label.TextWrapped = true
	label.TextScaled = false
	label.ZIndex = 101
	label.Parent = button
	
	button.MouseButton1Click:Connect(callback)
	
	-- Make draggable
	Drag(button)
	
	return button
end

-- Global key bind handler
Services.Input.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local keyName = input.KeyCode.Name
		for title, bindData in pairs(BindStorage) do
			if bindData and bindData.key == keyName then
				if bindData.callback and type(bindData.callback) == "function" then
					local success, err = pcall(bindData.callback)
					if not success then
						-- Silent error handling
					end
				end
			end
		end
	end
end)

--// Animations [Window]
function Animations:Open(Window, Transparency, UseCurrentSize)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")


	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})

	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end

function Animations:Close(Window)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, {
		Size = Original,
	})

	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, {
		Size = Multiplied,
		GroupTransparency = 1,
	})

	wait(.25)
	Window.Size = Original
	Window.Visible = false
end


function Animations:Component(Component, Custom)	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 });
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]

function Library:CreateWindow(Settings)
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local OpenPopups = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// UI Setup
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end
	
	-- Mobile optimization: Automatically detect and scale for mobile devices
	local isMobile = Services.Input.TouchEnabled and not Services.Input.KeyboardEnabled
	local mobileScale = isMobile and 0.5 or 1 -- 50% for mobile, 100% for PC
	
	if mobileScale ~= 1 then
		local uiScale = Instance.new("UIScale")
		uiScale.Scale = mobileScale
		uiScale.Parent = Window
	end

	--// Animate
	local Close = function()
		if Opened then
			Opened = false
			Animations:Close(Window)
			Window.Visible = false
			
			-- Close all open ColorPicker and BindSettings windows
			for _, desc in pairs(Screen:GetDescendants()) do
				if desc:IsA("CanvasGroup") then
					if desc.Name == "ColorPickerFrame" or desc.Name == "BindSettings" then
						desc.Visible = false
					end
				end
			end
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true
		end
	end

    local OpenButton = Instance.new("ImageButton")
    local Corner = Instance.new("UICorner")
    local Stroke = Instance.new("UIStroke")
    local Shadow = Instance.new("ImageLabel")

    local iconAssetId = (Setup.ThemeMode == "Light") and "rbxassetid://949752421" or "rbxassetid://949752421"
    local buttonBgColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(200, 200, 200) or Theme.Secondary

    OpenButton.Name = "OpenButton"
    OpenButton.Size = UDim2.fromOffset(52, 52)
    OpenButton.Position = UDim2.new(0.5, -26, 0.5, -26)
    OpenButton.AnchorPoint = Vector2.new(0, 0)
    OpenButton.BackgroundColor3 = buttonBgColor
    OpenButton.Image = iconAssetId
    OpenButton.ImageColor3 = Theme.Icon
    OpenButton.AutoButtonColor = false
    OpenButton.Visible = false
    OpenButton.Parent = Screen

    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = OpenButton

    Stroke.Color = Theme.Outline
    Stroke.Thickness = 2
    Stroke.Parent = OpenButton

    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageTransparency = 0.55
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10,10,118,118)
    Shadow.Size = UDim2.new(1,18,1,18)
    Shadow.Position = UDim2.new(0,-9,0,-9)
    Shadow.ZIndex = OpenButton.ZIndex - 1
    Shadow.Parent = OpenButton

    local isDragging = false
    local wasDragged = false
    local dragStart = nil
    local startPosition = nil

    Connect(OpenButton.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            wasDragged = false
            dragStart = input.Position
            startPosition = OpenButton.Position
        end
    end)

    Connect(Services.Input.InputChanged, function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                wasDragged = true
            end
            OpenButton.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)

    Connect(Services.Input.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDragging then
                isDragging = false
                if not wasDragged then
                    OpenButton.Visible = false
                    Window.Visible = true
                    Animations:Open(Window, Setup.Transparency)
                    Opened = true
                end
            end
        end
    end)

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
            Button.Size = UDim2.new(0, 22, 0, 22)
			
			if Name == "Maximize" or Name == "Minimize" then
				Button.Visible = false
			else
				Animations:Component(Button, true)
			end

			Connect(Button.MouseButton1Click, function() 
				if Name == "Close" then
					Opened = false
					Animations:Close(Window)
					
					-- Close all open ColorPicker and BindSettings windows
					for _, desc in pairs(Screen:GetDescendants()) do
						if desc:IsA("CanvasGroup") then
							if desc.Name == "ColorPickerFrame" or desc.Name == "BindSettings" then
								desc.Visible = false
							end
						end
					end
					
					wait(0.3)
					Window.Visible = false
					OpenButton.Visible = true
				end
			end)
		end
	end
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(0, 200, 1, 0)
	TitleLabel.Position = UDim2.new(0, 30, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "Heartagram Hub"
	TitleLabel.TextColor3 = Theme.Title
	TitleLabel.TextSize = 14
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Sidebar.Top.Buttons

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if Input.KeyCode == Setup.Keybind and not Focused and Input.UserInputType == Enum.UserInputType.Keyboard then
			Close()
		end
	end)

	--// Tab Functions

	function Options:SetTab(Name)
		for i = #OpenPopups, 1, -1 do
			local popup = OpenPopups[i]
			if popup then
				if popup.scrollConnection then
					popup.scrollConnection:Disconnect()
				end
				if popup.heartbeatConnection then
					popup.heartbeatConnection:Disconnect()
				end
				if popup.closeCallback then
					popup.closeCallback()
				end
				if popup.Frame and popup.Frame.Parent then
					popup.Frame:Destroy()
				end
			end
			table.remove(OpenPopups, i)
		end
		
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });

				elseif not SameName and Opened.Value then
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	

					delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings)
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings)
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);

		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title
		});

		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title,
			Visible = true
		});

		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)

		return Main.ScrollingFrame
	end
	
	--// Notifications
	
	function Options:Notify(Settings) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = wait;
			
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	--// Component Functions

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")

		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);
		
		-- Create settings gear icon
		local settingsIcon = Instance.new("TextButton")
		settingsIcon.Name = "SettingsIcon"
		settingsIcon.Size = UDim2.new(0, 12, 0, 12)
		settingsIcon.Position = UDim2.new(1, -14, 1, -14)
		settingsIcon.BackgroundColor3 = Theme.Component
		settingsIcon.BorderSizePixel = 0
		settingsIcon.Text = "⚙"
		settingsIcon.TextColor3 = Theme.Description
		settingsIcon.TextSize = 9
		settingsIcon.Font = Enum.Font.GothamBold
		settingsIcon.ZIndex = 10
		settingsIcon.Parent = Button
		
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 3)
		iconCorner.Parent = settingsIcon
		
		-- Bind system variables
		local currentBind = nil
		local visualButton = nil
		local bindWindow, actionButton, bindButton = createBindSettingsWindow(
			Settings.Title,
			function(keyName)
				currentBind = keyName
				if keyName then
					if not Settings.Callback then
						return
					end
					BindStorage[Settings.Title] = {
						key = keyName,
						callback = Settings.Callback
					}
				else
					BindStorage[Settings.Title] = nil
				end
			end,
			function()
				-- Toggle visual button
				if visualButton then
					visualButton:Destroy()
					visualButton = nil
					return "Create Button"
				else
					visualButton = createVisualButton(Settings.Title, Settings.Callback)
					return "Delete Button"
				end
			end,
			"None",
			settingsIcon
		)
		
		-- Settings icon click handler (toggle bind window)
		settingsIcon.MouseButton1Click:Connect(function()
			bindWindow.Visible = not bindWindow.Visible
		end)
		
		local IconFrame = Instance.new("ImageLabel")
		IconFrame.Name = "ButtonIcon"
		IconFrame.Size = UDim2.new(0, 28, 0, 28)
		IconFrame.Position = UDim2.new(1, -44, 0.5, -14)
		IconFrame.BackgroundTransparency = 1
		IconFrame.Image = "rbxassetid://132159138464146"
		IconFrame.ImageColor3 = Theme.Icon
		IconFrame.ZIndex = 2
		IconFrame.Parent = Button

		Connect(Button.MouseButton1Click, function()
			local pressColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
			Tween(IconFrame, .1, { ImageColor3 = pressColor })
			
			pcall(Settings.Callback)
			
			wait(0.1)
			Tween(IconFrame, .2, { ImageColor3 = Theme.Icon })
		end)
		
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)
        -- фикс дура 2
		Connect(TextBox.FocusLost, function() 
			pcall(Settings.Callback, TextBox.Text)
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		-- Define Set function FIRST (before bind system)
		local Set = function(Value)
			if Value then
				if Setup.ThemeMode == "Light" then
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) });
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
				else
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) });
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -16, 0.5, 0) });
				end
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				local circleColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(0, 0, 0) or Theme.Primary
				Tween(Circle, .2, { BackgroundColor3 = circleColor, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
		end 
		
		-- Create settings gear icon
		local settingsIcon = Instance.new("TextButton")
		settingsIcon.Name = "SettingsIcon"
		settingsIcon.Size = UDim2.new(0, 12, 0, 12)
		settingsIcon.Position = UDim2.new(1, -14, 1, -14)
		settingsIcon.AnchorPoint = Vector2.new(0, 0)
		settingsIcon.BackgroundColor3 = Theme.Component
		settingsIcon.BorderSizePixel = 0
		settingsIcon.Text = "⚙"
		settingsIcon.TextColor3 = Theme.Description
		settingsIcon.TextSize = 9
		settingsIcon.Font = Enum.Font.GothamBold
		settingsIcon.ZIndex = 10
		settingsIcon.Parent = Toggle
		
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 3)
		iconCorner.Parent = settingsIcon
		
		-- Bind system variables (NOW Set is defined and accessible)
		local currentBind = nil
		local visualButton = nil
		local bindWindow, actionButton, bindButton = createBindSettingsWindow(
			Settings.Title,
			function(keyName)
				currentBind = keyName
				if keyName then
					local bindCallback = function()
						-- Toggle the state (not just enable)
						local newValue = not On.Value
						Set(newValue)
						if Settings.Callback then
							Settings.Callback(newValue)
						end
					end
					BindStorage[Settings.Title] = {
						key = keyName,
						callback = bindCallback
					}
				else
					BindStorage[Settings.Title] = nil
				end
			end,
			function()
				-- Toggle visual button
				if visualButton then
					visualButton:Destroy()
					visualButton = nil
					return "Create Button"
				else
					visualButton = createVisualButton(Settings.Title, function()
						-- Toggle the state when visual button is clicked
						local newValue = not On.Value
						Set(newValue)
						if Settings.Callback then
							Settings.Callback(newValue)
						end
					end)
					return "Delete Button"
				end
			end,
			"None",
			settingsIcon
		)
		
		-- Settings icon click handler (toggle bind window)
		settingsIcon.MouseButton1Click:Connect(function()
			bindWindow.Visible = not bindWindow.Visible
		end)
		-- фикс ебаная хуйня 3
		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			pcall(Settings.Callback, Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		
		-- Возвращаем методы для управления
		local methods = {
			SetValue = function(value)
				Set(value)
				-- Вызываем callback чтобы функция реально включилась/выключилась
				if Settings.Callback then
					Settings.Callback(value)
				end
			end,
			GetValue = function()
				return On.Value
			end
		}
		
		-- Автоматическая регистрация в глобальном реестре конфигов
        -- фикс заебал 4
		local registry = getgenv().ConfigRegistry or _G.ConfigRegistry
		if type(registry) == "table" and Settings.Title then
			local elementId = Settings.Title:gsub(" ", "_"):lower() -- Преобразуем "Auto Kill All" в "auto_kill_all"
			registry[elementId] = {
				element = methods,
				type = "toggle"
			}
		else
			-- Silent: ConfigRegistry not found
		end
		
		return methods
	end
	
	function Options:AddKeybind(Settings) 
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);
				
				if not Finished and not Focused then
					Finished = (true)
					
					if table.find(Mouse, InputType) then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB")
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, "")
						})
					end
					
					-- фикс хуйни 1
					if Detect then
						Detect:Disconnect()
						Detect = nil
					end
				end 
			end)
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						wait(2)
						Destroy(Example);
					end)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);

				Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 

					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index

						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end

					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					wait(2)
					Destroy(Example);
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			local maxValue = Settings.MaxValue or Settings.Max or 100
			
			if Number then
				Number = (Number > maxValue and maxValue) or (Number < (Settings.MinValue or Settings.Min or 0) and (Settings.MinValue or Settings.Min or 0)) or Number
			end
			
			Value = SetNumber(Number or (Scale * maxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / maxValue) or Scale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat wait()
				Update()
			until not Active
		end
		
		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		-- Initialize with default value
		if Settings.Default then
			Update(Settings.Default)
		else
			Fill.Size = UDim2.fromScale(0, 1)
			Amount.Text = "0"
		end
		
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		
		-- Возвращаем методы для управления
		local methods = {
			SetValue = function(value)
				Update(value)
			end,
			GetValue = function()
				return Value
			end
		}
		
		-- Автоматическая регистрация в глобальном реестре конфигов
        -- фикс заебал 5
		local registry = getgenv().ConfigRegistry or _G.ConfigRegistry
		if type(registry) == "table" and Settings.Title then
			local elementId = Settings.Title:gsub(" ", "_"):lower()
			registry[elementId] = {
				element = methods,
				type = "slider"
			}
		end
		
		return methods
	end

	function Options:AddInfoPanel(Settings)
		local InfoPanel = Instance.new("Frame")
		InfoPanel.Name = Settings.Title or "InfoPanel"
		InfoPanel.Size = UDim2.new(1, -20, 0, 100)
		InfoPanel.Position = UDim2.new(0, 10, 0, 0)
		InfoPanel.BackgroundColor3 = Theme.Component
		InfoPanel.BorderSizePixel = 0
		InfoPanel.Parent = Settings.Tab
		InfoPanel.Visible = true
		
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 6)
		Corner.Parent = InfoPanel
		
		local Padding = Instance.new("UIPadding")
		Padding.PaddingLeft = UDim.new(0, 6)
		Padding.PaddingRight = UDim.new(0, 6)
		Padding.PaddingTop = UDim.new(0, 4)
		Padding.PaddingBottom = UDim.new(0, 4)
		Padding.Parent = InfoPanel
		
		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "Title"
		TitleLabel.Size = UDim2.new(1, -12, 0, 20)
		TitleLabel.Position = UDim2.new(0, 6, 0, 2)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Text = Settings.Title or "Information"
		TitleLabel.TextColor3 = Theme.Title
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.TextSize = 15
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
		TitleLabel.Parent = InfoPanel
		
		local DataContainer = Instance.new("Frame")
		DataContainer.Name = "DataContainer"
		DataContainer.Size = UDim2.new(1, -12, 1, -26)
		DataContainer.Position = UDim2.new(0, 6, 0, 22)
		DataContainer.BackgroundTransparency = 1
		DataContainer.Parent = InfoPanel
		
		local ListLayout = Instance.new("UIListLayout")
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 3)
		ListLayout.Parent = DataContainer
		
		local DataLabels = {}
		
		local function CreateDataRow(key, value, order)
			local Row = Instance.new("TextLabel")
			Row.Name = key
			Row.Size = UDim2.new(1, 0, 0, 18)
			Row.BackgroundTransparency = 1
			Row.Text = key .. ": " .. tostring(value)
			Row.TextColor3 = Theme.Description
			Row.Font = Enum.Font.Gotham
			Row.TextSize = 13
			Row.TextXAlignment = Enum.TextXAlignment.Left
			Row.TextYAlignment = Enum.TextYAlignment.Center
			Row.LayoutOrder = order or 0
			Row.Parent = DataContainer
			
			DataLabels[key] = Row
			return Row
		end
		
		if Settings.Data then
			local order = 0
			for key, value in pairs(Settings.Data) do
				CreateDataRow(key, value, order)
				order = order + 1
			end
		end
		
		local function UpdatePanelSize()
			local contentSize = ListLayout.AbsoluteContentSize.Y
			InfoPanel.Size = UDim2.new(1, -20, 0, contentSize + 32)
		end
		
		ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdatePanelSize)
		UpdatePanelSize()
		
		local InfoPanelObject = {
			Frame = InfoPanel,
			Labels = DataLabels,
			
			UpdateValue = function(self, key, value)
				if DataLabels[key] then
					DataLabels[key].Text = key .. ": " .. tostring(value)
				end
			end,
			
			AddData = function(self, key, value)
				if not DataLabels[key] then
					local order = #DataContainer:GetChildren() - 1
					CreateDataRow(key, value, order)
					UpdatePanelSize()
				end
			end,
			
			RemoveData = function(self, key)
				if DataLabels[key] then
					DataLabels[key]:Destroy()
					DataLabels[key] = nil
					UpdatePanelSize()
				end
			end,
			
			ClearData = function(self)
				for key, label in pairs(DataLabels) do
					label:Destroy()
				end
				DataLabels = {}
				UpdatePanelSize()
			end,
			
			SetVisible = function(self, visible)
				InfoPanel.Visible = visible
			end,
		}
		
		return InfoPanelObject
	end

	function Options:AddToggleDropdown(Settings)
		local Container = Instance.new("Frame")
		Container.Name = Settings.Title
		Container.Size = UDim2.new(1, -20, 0, 45)
		Container.BackgroundTransparency = 1
		Container.Parent = Settings.Tab
		Container.Visible = true
		
		local ToggleElement = Clone(Components["Toggle"])
		local Title, Description = Options:GetLabels(ToggleElement)
		local Main = ToggleElement["Main"]
		local Circle = Main["Circle"]
		local Enabled = Settings.Enabled or false
		
		ToggleElement.Parent = Container
		ToggleElement.Size = UDim2.new(1, 0, 0, 45)
		ToggleElement.Position = UDim2.new(0, 0, 0, 0)
		ToggleElement.Visible = true
		
		-- Define Set function FIRST
		local Set = function(Value)
			Enabled = Value
			if Value then
				if Setup.ThemeMode == "Light" then
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) });
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
				else
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) });
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -16, 0.5, 0) });
				end
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables });
				local circleColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(0, 0, 0) or Theme.Primary
				Tween(Circle, .2, { BackgroundColor3 = circleColor, Position = UDim2.new(0, 3, 0.5, 0) });
			end
		end
		
		local DropdownFrame = Instance.new("Frame")
		DropdownFrame.Size = UDim2.new(0, 100, 0, 28)
		DropdownFrame.Position = UDim2.new(1, -160, 0.5, -14)
		DropdownFrame.BackgroundColor3 = Theme.Interactables
		DropdownFrame.BorderSizePixel = 0
		DropdownFrame.ZIndex = 3
		DropdownFrame.Parent = ToggleElement
		
		local DropCorner = Instance.new("UICorner")
		DropCorner.CornerRadius = UDim.new(0, 6)
		DropCorner.Parent = DropdownFrame
		
		local DropButton = Instance.new("TextButton")
		DropButton.Size = UDim2.new(1, 0, 1, 0)
		DropButton.BackgroundTransparency = 1
		DropButton.Text = ""
		DropButton.ZIndex = 4
		DropButton.Parent = DropdownFrame
		
		local DropText = Instance.new("TextLabel")
		DropText.Name = "DropText"
		DropText.Size = UDim2.new(1, -10, 1, 0)
		DropText.Position = UDim2.new(0, 5, 0, 0)
		DropText.BackgroundTransparency = 1
		DropText.Text = tostring(Settings.Default or "Select")
		DropText.TextColor3 = Theme.Title
		DropText.TextSize = 11
		DropText.Font = Enum.Font.Gotham
		DropText.TextXAlignment = Enum.TextXAlignment.Left
		DropText.TextTruncate = Enum.TextTruncate.AtEnd
		DropText.ZIndex = 5
		DropText.Parent = DropdownFrame
		
		-- Create settings gear icon (FIXED POSITION)
		local settingsIcon = Instance.new("TextButton")
		settingsIcon.Name = "SettingsIcon"
		settingsIcon.Size = UDim2.new(0, 12, 0, 12)
		settingsIcon.Position = UDim2.new(1, -14, 1, -14)
		settingsIcon.AnchorPoint = Vector2.new(0, 0)
		settingsIcon.BackgroundColor3 = Theme.Component
		settingsIcon.BorderSizePixel = 0
		settingsIcon.Text = "⚙"
		settingsIcon.TextColor3 = Theme.Description
		settingsIcon.TextSize = 9
		settingsIcon.Font = Enum.Font.GothamBold
		settingsIcon.ZIndex = 10
		settingsIcon.Parent = ToggleElement
		
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 3)
		iconCorner.Parent = settingsIcon
		
		-- Bind system variables (NOW Set is defined and accessible)
		local currentBind = nil
		local visualButton = nil
		local bindWindow, actionButton, bindButton = createBindSettingsWindow(
			Settings.Title,
			function(keyName)
				currentBind = keyName
				if keyName then
					local bindCallback = function()
						-- Toggle the state
						local newValue = not Enabled
						Set(newValue)
						if Settings.ToggleCallback then
							Settings.ToggleCallback(newValue)
						end
					end
					BindStorage[Settings.Title] = {
						key = keyName,
						callback = bindCallback
					}
				else
					BindStorage[Settings.Title] = nil
				end
			end,
			function()
				-- Toggle visual button
				if visualButton then
					visualButton:Destroy()
					visualButton = nil
					return "Create Button"
				else
					visualButton = createVisualButton(Settings.Title, function()
						-- Toggle the state
						local newValue = not Enabled
						Set(newValue)
						if Settings.ToggleCallback then
							Settings.ToggleCallback(newValue)
						end
					end)
					return "Delete Button"
				end
			end,
			"None",
			settingsIcon
		)
		
		-- Settings icon click handler (toggle bind window)
		settingsIcon.MouseButton1Click:Connect(function()
			bindWindow.Visible = not bindWindow.Visible
		end)
		
		local isExpanded = false
		local currentSelection = Settings.Default
		local DropdownList = nil
		local isAnimating = false
		
		local function createDropdownList()
			if DropdownList then return end
			
			DropdownList = Instance.new("ScrollingFrame")
			DropdownList.Name = "DropdownList"
			DropdownList.Size = UDim2.new(1, 0, 0, 0)
			DropdownList.Position = UDim2.new(0, 0, 0, 45)
			DropdownList.BackgroundColor3 = Theme.Secondary
			DropdownList.BorderSizePixel = 0
			DropdownList.ScrollBarThickness = 4
			DropdownList.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropdownList.Visible = false
			DropdownList.ZIndex = 10
			DropdownList.Parent = Container
			
			local ListCorner = Instance.new("UICorner")
			ListCorner.CornerRadius = UDim.new(0, 6)
			ListCorner.Parent = DropdownList
			
			local ListStroke = Instance.new("UIStroke")
			ListStroke.Color = Theme.Outline
			ListStroke.Thickness = 1
			ListStroke.Parent = DropdownList
			
			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 2)
			ListLayout.Parent = DropdownList
			
			local ListPadding = Instance.new("UIPadding")
			ListPadding.PaddingTop = UDim.new(0, 4)
			ListPadding.PaddingBottom = UDim.new(0, 4)
			ListPadding.PaddingLeft = UDim.new(0, 4)
			ListPadding.PaddingRight = UDim.new(0, 4)
			ListPadding.Parent = DropdownList
			
			for _, Option in ipairs(Settings.Options) do
				local OptionButton = Instance.new("TextButton")
				OptionButton.Size = UDim2.new(1, -8, 0, 28)
				OptionButton.BackgroundColor3 = Theme.Component
				OptionButton.BorderSizePixel = 0
				OptionButton.Text = ""
				OptionButton.AutoButtonColor = false
				OptionButton.ZIndex = 11
				OptionButton.Parent = DropdownList
				
				local OptCorner = Instance.new("UICorner")
				OptCorner.CornerRadius = UDim.new(0, 6)
				OptCorner.Parent = OptionButton
				
				local OptLabel = Instance.new("TextLabel")
				OptLabel.Size = UDim2.new(1, -10, 1, 0)
				OptLabel.Position = UDim2.new(0, 8, 0, 0)
				OptLabel.BackgroundTransparency = 1
				OptLabel.Text = Option
				OptLabel.TextColor3 = Theme.Title
				OptLabel.TextSize = 13
				OptLabel.Font = Enum.Font.Gotham
				OptLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptLabel.ZIndex = 12
				OptLabel.Parent = OptionButton
				
				if Option == currentSelection then
					OptionButton.BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode)
				end
				
				Animations:Component(OptionButton)
				
				Connect(OptionButton.MouseButton1Click, function()
					currentSelection = Option
					DropText.Text = Option
					
					for _, btn in pairs(DropdownList:GetChildren()) do
						if btn:IsA("TextButton") then
							Tween(btn, .2, { BackgroundColor3 = Theme.Component })
						end
					end
					
					Tween(OptionButton, .2, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) })
					
					if Settings.DropdownCallback then
						Settings.DropdownCallback(Option)
					end
					
					if not isAnimating then
						isAnimating = true
						isExpanded = false
						Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
						Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
						wait(.2)
						DropdownList.Visible = false
						isAnimating = false
					end
				end)
			end
			
			ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
			end)
		end
		
		local function toggleDropdown()
			if isAnimating then return end
			
			createDropdownList()
			
			if not isExpanded then
				isAnimating = true
				DropdownList.Visible = true
				isExpanded = true
				local contentHeight = math.min(120, DropdownList.CanvasSize.Y.Offset)
				Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, contentHeight) })
				Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45 + contentHeight) })
				wait(.2)
				isAnimating = false
			else
				isAnimating = true
				isExpanded = false
				Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
				Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
				wait(.2)
				if DropdownList then
					DropdownList.Visible = false
				end
				isAnimating = false
			end
		end
		
		Connect(DropButton.MouseButton1Click, toggleDropdown)
		
		local Set = function(Value)
			Enabled = Value
			
			if Value then
				if Setup.ThemeMode == "Light" then
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) })
				else
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -16, 0.5, 0) })
				end
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables })
				local circleColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(0, 0, 0) or Theme.Primary
				Tween(Circle, .2, { BackgroundColor3 = circleColor, Position = UDim2.new(0, 3, 0.5, 0) })
				
				if isExpanded and DropdownList and not isAnimating then
					isAnimating = true
					isExpanded = false
					Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
					Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
					wait(.2)
					if DropdownList then
						DropdownList.Visible = false
					end
					isAnimating = false
				end
			end
		end
		
		Connect(ToggleElement.MouseButton1Click, function()
			Enabled = not Enabled
			Set(Enabled)
			
			if Settings.ToggleCallback then
				Settings.ToggleCallback(Enabled)
			end
		end)
		
		Animations:Component(ToggleElement)
		Animations:Component(DropButton)
		
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		
		createDropdownList()
		
		Set(Enabled)
		
		-- Возвращаем методы для управления
		local methods = {
			SetValue = function(value)
				-- value должен быть таблицей {enabled = bool, option = string}
				if type(value) == "table" then
					if value.enabled ~= nil then
						Set(value.enabled)
						if Settings.ToggleCallback then
							Settings.ToggleCallback(value.enabled)
						end
					end
					if value.option then
						-- Проверяем что опция существует в списке Options
						local optionExists = false
						for _, opt in ipairs(Settings.Options) do
							if opt == value.option then
								optionExists = true
								break
							end
						end
						
						if optionExists then
							currentSelection = value.option
							DropText.Text = value.option
							if Settings.DropdownCallback then
								Settings.DropdownCallback(value.option)
							end
						end
					end
				end
			end,
			GetValue = function()
				return {
					enabled = Enabled,
					option = currentSelection
				}
			end
		}
		
		-- Автоматическая регистрация в глобальном реестре конфигов
        -- фикс заебал 6
		local registry = getgenv().ConfigRegistry or _G.ConfigRegistry
		if type(registry) == "table" and Settings.Title then
			local elementId = Settings.Title:gsub(" ", "_"):lower()
			registry[elementId] = {
				element = methods,
				type = "toggledropdown"
			}
		end
		
		return methods
	end

	function Options:AddToggleMultiSelect(Settings)
		local Container = Instance.new("Frame")
		Container.Name = Settings.Title
		Container.Size = UDim2.new(1, -20, 0, 45)
		Container.BackgroundTransparency = 1
		Container.Parent = Settings.Tab
		Container.Visible = true
		
		local ToggleElement = Clone(Components["Toggle"])
		local Title, Description = Options:GetLabels(ToggleElement)
		local Main = ToggleElement["Main"]
		local Circle = Main["Circle"]
		local Enabled = Settings.Enabled or false
		
		ToggleElement.Parent = Container
		ToggleElement.Size = UDim2.new(1, 0, 0, 45)
		ToggleElement.Position = UDim2.new(0, 0, 0, 0)
		ToggleElement.Visible = true
		
		-- Define Set function FIRST
		local Set = function(Value)
			Enabled = Value
			if Value then
				if Setup.ThemeMode == "Light" then
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) });
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
				else
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) });
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -16, 0.5, 0) });
				end
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables });
				local circleColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(0, 0, 0) or Theme.Primary
				Tween(Circle, .2, { BackgroundColor3 = circleColor, Position = UDim2.new(0, 3, 0.5, 0) });
			end
		end
		
		local DropdownFrame = Instance.new("Frame")
		DropdownFrame.Size = UDim2.new(0, 100, 0, 28)
		DropdownFrame.Position = UDim2.new(1, -160, 0.5, -14)
		DropdownFrame.BackgroundColor3 = Theme.Interactables
		DropdownFrame.BorderSizePixel = 0
		DropdownFrame.ZIndex = 3
		DropdownFrame.Parent = ToggleElement
		
		local DropCorner = Instance.new("UICorner")
		DropCorner.CornerRadius = UDim.new(0, 6)
		DropCorner.Parent = DropdownFrame
		
		local DropButton = Instance.new("TextButton")
		DropButton.Size = UDim2.new(1, 0, 1, 0)
		DropButton.BackgroundTransparency = 1
		DropButton.Text = ""
		DropButton.ZIndex = 4
		DropButton.Parent = DropdownFrame
		
		local DropText = Instance.new("TextLabel")
		DropText.Name = "DropText"
		DropText.Size = UDim2.new(1, -10, 1, 0)
		DropText.Position = UDim2.new(0, 5, 0, 0)
		DropText.BackgroundTransparency = 1
		DropText.Text = "None"
		DropText.TextColor3 = Theme.Title
		DropText.TextSize = 11
		DropText.Font = Enum.Font.Gotham
		DropText.TextXAlignment = Enum.TextXAlignment.Left
		DropText.TextTruncate = Enum.TextTruncate.AtEnd
		DropText.ZIndex = 5
		DropText.Parent = DropdownFrame
		
		-- Create settings gear icon (FIXED POSITION)
		local settingsIcon = Instance.new("TextButton")
		settingsIcon.Name = "SettingsIcon"
		settingsIcon.Size = UDim2.new(0, 12, 0, 12)
		settingsIcon.Position = UDim2.new(1, -14, 1, -14)
		settingsIcon.AnchorPoint = Vector2.new(0, 0)
		settingsIcon.BackgroundColor3 = Theme.Component
		settingsIcon.BorderSizePixel = 0
		settingsIcon.Text = "⚙"
		settingsIcon.TextColor3 = Theme.Description
		settingsIcon.TextSize = 9
		settingsIcon.Font = Enum.Font.GothamBold
		settingsIcon.ZIndex = 10
		settingsIcon.Parent = ToggleElement
		
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 3)
		iconCorner.Parent = settingsIcon
		
		-- Bind system variables (NOW Set is defined and accessible)
		local currentBind = nil
		local visualButton = nil
		local bindWindow, actionButton, bindButton = createBindSettingsWindow(
			Settings.Title,
			function(keyName)
				currentBind = keyName
				if keyName then
					local bindCallback = function()
						-- Toggle the state
						local newValue = not Enabled
						Set(newValue)
						if Settings.ToggleCallback then
							Settings.ToggleCallback(newValue)
						end
					end
					BindStorage[Settings.Title] = {
						key = keyName,
						callback = bindCallback
					}
				else
					BindStorage[Settings.Title] = nil
				end
			end,
			function()
				-- Toggle visual button
				if visualButton then
					visualButton:Destroy()
					visualButton = nil
					return "Create Button"
				else
					visualButton = createVisualButton(Settings.Title, function()
						-- Toggle the state
						local newValue = not Enabled
						Set(newValue)
						if Settings.ToggleCallback then
							Settings.ToggleCallback(newValue)
						end
					end)
					return "Delete Button"
				end
			end,
			"None",
			settingsIcon
		)
		
		-- Settings icon click handler (toggle bind window)
		settingsIcon.MouseButton1Click:Connect(function()
			bindWindow.Visible = not bindWindow.Visible
		end)
		
		local isExpanded = false
		local SelectedItems = {}
		local DropdownList = nil
		local isAnimating = false
		
		local function createDropdownList()
			if DropdownList then return end
			DropdownList = Instance.new("ScrollingFrame")
			DropdownList.Name = "DropdownList"
			DropdownList.Size = UDim2.new(1, 0, 0, 0)
			DropdownList.Position = UDim2.new(0, 0, 0, 45)
			DropdownList.BackgroundColor3 = Theme.Secondary
			DropdownList.BorderSizePixel = 0
			DropdownList.ScrollBarThickness = 4
			DropdownList.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropdownList.Visible = false
			DropdownList.ZIndex = 10
			DropdownList.Parent = Container
			
			local ListCorner = Instance.new("UICorner")
			ListCorner.CornerRadius = UDim.new(0, 6)
			ListCorner.Parent = DropdownList
			
			local ListStroke = Instance.new("UIStroke")
			ListStroke.Color = Theme.Outline
			ListStroke.Thickness = 1
			ListStroke.Parent = DropdownList
			
			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 2)
			ListLayout.Parent = DropdownList
			
			local ListPadding = Instance.new("UIPadding")
			ListPadding.PaddingTop = UDim.new(0, 4)
			ListPadding.PaddingBottom = UDim.new(0, 4)
			ListPadding.PaddingLeft = UDim.new(0, 4)
			ListPadding.PaddingRight = UDim.new(0, 4)
			ListPadding.Parent = DropdownList
			
			for _, Option in ipairs(Settings.Options) do
				local OptionButton = Instance.new("TextButton")
				OptionButton.Name = Option
				OptionButton.Size = UDim2.new(1, -8, 0, 28)
				OptionButton.BackgroundColor3 = Theme.Component
				OptionButton.BorderSizePixel = 0
				OptionButton.Text = ""
				OptionButton.AutoButtonColor = false
				OptionButton.ZIndex = 11
				OptionButton.Parent = DropdownList
				
				local OptCorner = Instance.new("UICorner")
				OptCorner.CornerRadius = UDim.new(0, 6)
				OptCorner.Parent = OptionButton
				
				local OptLabel = Instance.new("TextLabel")
				OptLabel.Size = UDim2.new(1, -35, 1, 0)
				OptLabel.Position = UDim2.new(0, 8, 0, 0)
				OptLabel.BackgroundTransparency = 1
				OptLabel.Text = Option
				OptLabel.TextColor3 = Theme.Title
				OptLabel.TextSize = 13
				OptLabel.Font = Enum.Font.Gotham
				OptLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptLabel.ZIndex = 12
				OptLabel.Parent = OptionButton
				
				local Checkmark = Instance.new("TextLabel")
				Checkmark.Name = "Checkmark"
				Checkmark.Size = UDim2.new(0, 16, 0, 16)
				Checkmark.Position = UDim2.new(1, -22, 0.5, -8)
				Checkmark.BackgroundColor3 = Theme.Interactables
				Checkmark.BorderSizePixel = 0
				Checkmark.Text = ""
				Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255) -- White checkmark
				Checkmark.TextSize = 11
				Checkmark.Font = Enum.Font.GothamBold
				Checkmark.ZIndex = 12
				Checkmark.Parent = OptionButton
				
				local CheckCorner = Instance.new("UICorner")
				CheckCorner.CornerRadius = UDim.new(0, 3)
				CheckCorner.Parent = Checkmark
				
				Animations:Component(OptionButton)
				
				Connect(OptionButton.MouseButton1Click, function()
					if SelectedItems[Option] then
						SelectedItems[Option] = nil
						Checkmark.Text = ""
						Checkmark.BackgroundColor3 = Theme.Interactables
						Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
						Tween(OptionButton, .2, { BackgroundColor3 = Theme.Component })
					else
						SelectedItems[Option] = true
						Checkmark.Text = "✓"
						Checkmark.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background when checked
						Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255) -- White checkmark
						Tween(OptionButton, .2, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) })
					end
					
					local DisplayText = ""
					local Count = 0
					local selectedList = {}
					for Key, _ in pairs(SelectedItems) do
						Count = Count + 1
						table.insert(selectedList, Key)
					end
					
					if Count == 1 then
						DisplayText = selectedList[1]
					elseif Count == 2 then
						DisplayText = selectedList[1] .. ", " .. selectedList[2]
					elseif Count > 2 then
						DisplayText = selectedList[1] .. " +" .. (Count - 1)
					end
					
					DropText.Text = (Count > 0 and DisplayText) or "None"
					
					if Settings.DropdownCallback then
						Settings.DropdownCallback(SelectedItems) -- Pass dictionary, not array
					end
				end)
			end
			
			ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
			end)
		end
		
		local function toggleDropdown()
			if isAnimating then return end
			
			createDropdownList()
			
			if not isExpanded then
				isAnimating = true
				DropdownList.Visible = true
				isExpanded = true
				local contentHeight = math.min(120, DropdownList.CanvasSize.Y.Offset)
				Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, contentHeight) })
				Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45 + contentHeight) })
				wait(.2)
				isAnimating = false
			else
				isAnimating = true
				isExpanded = false
				Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
				Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
				wait(.2)
				if DropdownList then
					DropdownList.Visible = false
				end
				isAnimating = false
			end
		end
		
		Connect(DropButton.MouseButton1Click, toggleDropdown)
		
		local Set = function(Value)
			Enabled = Value
			
			if Value then
				if Setup.ThemeMode == "Light" then
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) })
				else
					Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
					Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -16, 0.5, 0) })
				end
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables })
				local circleColor = (Setup.ThemeMode == "Light") and Color3.fromRGB(0, 0, 0) or Theme.Primary
				Tween(Circle, .2, { BackgroundColor3 = circleColor, Position = UDim2.new(0, 3, 0.5, 0) })
				
				if isExpanded and DropdownList and not isAnimating then
					isAnimating = true
					isExpanded = false
					Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
					Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
					wait(.2)
					if DropdownList then
						DropdownList.Visible = false
					end
					isAnimating = false
				end
			end
		end
		
		Connect(ToggleElement.MouseButton1Click, function()
			Enabled = not Enabled
			Set(Enabled)
			
			if Settings.ToggleCallback then
				Settings.ToggleCallback(Enabled)
			end
		end)
		
		Animations:Component(ToggleElement)
		Animations:Component(DropButton)
		
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		
		createDropdownList()
		
		Set(Enabled)
		
		-- Auto-registration для конфига
		do
			local registry = getgenv().ConfigRegistry or _G.ConfigRegistry
			if registry and Settings.Title then
				local elementId = Settings.Title:gsub(" ", "_"):lower()
				registry[elementId] = {
					element = {
						SetValue = function(value)
							if type(value) == "table" then
								-- Применяем enabled состояние
								if value.enabled ~= nil then
									Set(value.enabled)
									if Settings.ToggleCallback then
										Settings.ToggleCallback(value.enabled)
									end
								end
								
								-- Применяем selectedItems
								if value.selectedItems and type(value.selectedItems) == "table" then
									SelectedItems = {}
									for opt, sel in pairs(value.selectedItems) do
										if sel then
											SelectedItems[opt] = true
										end
									end
									
									-- Обновляем текст dropdown
									local cnt, lst = 0, {}
									for k, _ in pairs(SelectedItems) do
										cnt = cnt + 1
										table.insert(lst, k)
									end
									DropText.Text = (cnt == 1 and lst[1]) or (cnt == 2 and lst[1] .. ", " .. lst[2]) or (cnt > 2 and lst[1] .. " +" .. (cnt - 1)) or "None"
									
									-- Обновляем визуальные чекмарки в dropdown списке
									if DropdownList then
										for _, optButton in pairs(DropdownList:GetChildren()) do
											if optButton:IsA("TextButton") then
												-- Ищем Checkmark - это TextLabel с Size 16x16 справа
												local checkmark = nil
												for _, child in pairs(optButton:GetChildren()) do
													if child:IsA("TextLabel") and child.Size == UDim2.new(0, 16, 0, 16) then
														checkmark = child
														break
													end
												end
												
												if checkmark and SelectedItems[optButton.Name] then
													checkmark.Text = "✓"
													optButton.BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode)
												elseif checkmark then
													checkmark.Text = ""
													optButton.BackgroundColor3 = Theme.Component
												end
											end
										end
									end
									
									-- Вызываем callback с выбранными опциями
									if Settings.DropdownCallback then
										Settings.DropdownCallback(lst)
									end
								end
							end
						end,
						GetValue = function()
							return {enabled = Enabled, selectedItems = SelectedItems}
						end
					},
					type = "togglemultiselect"
				}
			end
		end
	end
    -- фикс ебаной дуры 9

	function Options:AddMultiSelect(Settings)
		local Container = Instance.new("Frame")
		Container.Name = Settings.Title
		Container.Size = UDim2.new(1, -20, 0, 45)
		Container.BackgroundTransparency = 1
		Container.Parent = Settings.Tab
		Container.Visible = true
		
		local MultiSelect = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(MultiSelect);
		local Text = MultiSelect["Main"].Options;
		local SelectedItems = {}
		local isExpanded = false
		local DropdownList = nil
		local cachedContentSize = 0
		
		MultiSelect.Parent = Container
		MultiSelect.Size = UDim2.new(1, 0, 0, 45)
		MultiSelect.Position = UDim2.new(0, 0, 0, 0)

		local function createDropdownList()
			if DropdownList then 
				return cachedContentSize
			end

			DropdownList = Instance.new("ScrollingFrame")
			DropdownList.Name = "DropdownList"
			DropdownList.Size = UDim2.new(1, 0, 0, 0)
			DropdownList.Position = UDim2.new(0, 0, 0, 45)
			DropdownList.BackgroundColor3 = Theme.Secondary
			DropdownList.BorderSizePixel = 0
			DropdownList.ScrollBarThickness = 6
			DropdownList.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropdownList.Visible = false
			DropdownList.ZIndex = 5
			DropdownList.Parent = Container

			local ListCorner = Instance.new("UICorner")
			ListCorner.CornerRadius = UDim.new(0, 8)
			ListCorner.Parent = DropdownList

			local ListStroke = Instance.new("UIStroke")
			ListStroke.Color = Theme.Outline
			ListStroke.Thickness = 1
			ListStroke.Parent = DropdownList

			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 2)
			ListLayout.Parent = DropdownList

			local ListPadding = Instance.new("UIPadding")
			ListPadding.PaddingTop = UDim.new(0, 4)
			ListPadding.PaddingBottom = UDim.new(0, 4)
			ListPadding.PaddingLeft = UDim.new(0, 4)
			ListPadding.PaddingRight = UDim.new(0, 4)
			ListPadding.Parent = DropdownList

			for Index, Option in pairs(Settings.Options) do
				local OptionButton = Instance.new("TextButton")
				OptionButton.Name = Option
				OptionButton.Size = UDim2.new(1, -8, 0, 28)
				OptionButton.BackgroundColor3 = Theme.Component
				OptionButton.BorderSizePixel = 0
				OptionButton.Text = ""
				OptionButton.AutoButtonColor = false
				OptionButton.ZIndex = 6
				OptionButton.Parent = DropdownList

				local OptionCorner = Instance.new("UICorner")
				OptionCorner.CornerRadius = UDim.new(0, 6)
				OptionCorner.Parent = OptionButton

				local OptionLabel = Instance.new("TextLabel")
				OptionLabel.Size = UDim2.new(1, -35, 1, 0)
				OptionLabel.Position = UDim2.new(0, 8, 0, 0)
				OptionLabel.BackgroundTransparency = 1
				OptionLabel.Text = Option
				OptionLabel.TextColor3 = Theme.Title
				OptionLabel.TextSize = 13
				OptionLabel.Font = Enum.Font.Gotham
				OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptionLabel.ZIndex = 7
				OptionLabel.Parent = OptionButton

				local Checkmark = Instance.new("TextLabel")
				Checkmark.Size = UDim2.new(0, 16, 0, 16)
				Checkmark.Position = UDim2.new(1, -22, 0.5, -8)
				Checkmark.BackgroundColor3 = Theme.Interactables
				Checkmark.BorderSizePixel = 0
				Checkmark.Text = ""
				Checkmark.TextColor3 = Color3.fromRGB(153, 155, 255)
				Checkmark.TextSize = 11
				Checkmark.Font = Enum.Font.GothamBold
				Checkmark.ZIndex = 7
				Checkmark.Parent = OptionButton

				local CheckCorner = Instance.new("UICorner")
				CheckCorner.CornerRadius = UDim.new(0, 3)
				CheckCorner.Parent = Checkmark

				if SelectedItems[Option] then
					Checkmark.Text = "✓"
					OptionButton.BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode)
				end

				Animations:Component(OptionButton)

				Connect(OptionButton.MouseButton1Click, function()
					if SelectedItems[Option] then
						SelectedItems[Option] = nil
						Checkmark.Text = ""
						Tween(OptionButton, .2, { BackgroundColor3 = Theme.Component })
					else
						SelectedItems[Option] = true
						Checkmark.Text = "✓"
						Tween(OptionButton, .2, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) })
					end

					local DisplayText = ""
					local Count = 0
					local selectedList = {}
					for Key, _ in pairs(SelectedItems) do
						Count = Count + 1
						table.insert(selectedList, Key)
					end
					
					if Count == 1 then
						DisplayText = selectedList[1]
					elseif Count == 2 then
						DisplayText = selectedList[1] .. ", " .. selectedList[2]
					elseif Count > 2 then
						DisplayText = selectedList[1] .. " +" .. (Count - 1)
					end
					
					Text.Text = (Count > 0 and DisplayText) or "None"

					Settings.Callback(selectedList)
				end)
			end

			Services.Run.Heartbeat:Wait()
			Services.Run.Heartbeat:Wait()
			local contentSize = ListLayout.AbsoluteContentSize.Y + 8
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, contentSize)
			cachedContentSize = contentSize
			
			return contentSize
		end

		local function toggleDropdown()
			if not isExpanded then
				local contentSize = createDropdownList()
				if contentSize and contentSize > 0 then
					DropdownList.Visible = true
					isExpanded = true
					local targetHeight = math.min(contentSize, 140)
					Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, targetHeight) })
					Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45 + targetHeight) })
				end
			else
				isExpanded = false
				Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
				Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
				wait(.2)
				if DropdownList then
					DropdownList.Visible = false
				end
			end
		end

		Connect(MultiSelect.MouseButton1Click, toggleDropdown)

		Animations:Component(MultiSelect);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Text, { Text = "None" });
		SetProperty(MultiSelect, {
			Name = Settings.Title,
			Visible = true,
		})
	end

	function Options:AddSingleSelect(Settings)
		local Container = Instance.new("Frame")
		Container.Name = Settings.Title
		Container.Size = UDim2.new(1, -20, 0, 45)
		Container.BackgroundTransparency = 1
		Container.Parent = Settings.Tab
		Container.Visible = true
		
		local SingleSelect = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(SingleSelect);
		local Text = SingleSelect["Main"].Options;
		local CurrentSelection = Settings.Default
		local isExpanded = false
		local DropdownList = nil
		local cachedContentSize = 0
		
		SingleSelect.Parent = Container
		SingleSelect.Size = UDim2.new(1, 0, 0, 45)
		SingleSelect.Position = UDim2.new(0, 0, 0, 0)

		if Settings.Default then
			Text.Text = Settings.Default
		end

		-- Объявляем toggleDropdown ЗАРАНЕЕ как переменную (forward declaration)
		local toggleDropdown
		
		local function createDropdownList()
			if DropdownList then
				return cachedContentSize
			end

			DropdownList = Instance.new("ScrollingFrame")
			DropdownList.Name = "DropdownList"
			DropdownList.Size = UDim2.new(1, 0, 0, 0)
			DropdownList.Position = UDim2.new(0, 0, 0, 45)
			DropdownList.BackgroundColor3 = Theme.Secondary
			DropdownList.BorderSizePixel = 0
			DropdownList.ScrollBarThickness = 6
			DropdownList.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropdownList.Visible = false
			DropdownList.ZIndex = 5
			DropdownList.Parent = Container

			local ListCorner = Instance.new("UICorner")
			ListCorner.CornerRadius = UDim.new(0, 8)
			ListCorner.Parent = DropdownList

			local ListStroke = Instance.new("UIStroke")
			ListStroke.Color = Theme.Outline
			ListStroke.Thickness = 1
			ListStroke.Parent = DropdownList

			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 2)
			ListLayout.Parent = DropdownList

			local ListPadding = Instance.new("UIPadding")
			ListPadding.PaddingTop = UDim.new(0, 4)
			ListPadding.PaddingBottom = UDim.new(0, 4)
			ListPadding.PaddingLeft = UDim.new(0, 4)
			ListPadding.PaddingRight = UDim.new(0, 4)
			ListPadding.Parent = DropdownList

			for Index, Option in ipairs(Settings.Options) do
				local OptionButton = Instance.new("TextButton")
				OptionButton.Name = Option
				OptionButton.Size = UDim2.new(1, -8, 0, 28)
				OptionButton.BackgroundColor3 = (CurrentSelection == Option) and Color(Theme.Component, 5, Setup.ThemeMode) or Theme.Component
				OptionButton.BorderSizePixel = 0
				OptionButton.Text = ""
				OptionButton.AutoButtonColor = false
				OptionButton.ZIndex = 6
				OptionButton.Parent = DropdownList

				local OptionCorner = Instance.new("UICorner")
				OptionCorner.CornerRadius = UDim.new(0, 6)
				OptionCorner.Parent = OptionButton

				local OptionLabel = Instance.new("TextLabel")
				OptionLabel.Size = UDim2.new(1, -20, 1, 0)
				OptionLabel.Position = UDim2.new(0, 8, 0, 0)
				OptionLabel.BackgroundTransparency = 1
				OptionLabel.Text = Option
				OptionLabel.TextColor3 = Theme.Title
				OptionLabel.TextSize = 13
				OptionLabel.Font = Enum.Font.Gotham
				OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptionLabel.ZIndex = 7
				OptionLabel.Parent = OptionButton

				Animations:Component(OptionButton)

				Connect(OptionButton.MouseButton1Click, function()
					CurrentSelection = Option
					Text.Text = Option
					
					if Settings.Callback then
						Settings.Callback(Option)
					end

					for _, OtherButton in pairs(DropdownList:GetChildren()) do
						if OtherButton:IsA("TextButton") and OtherButton ~= OptionButton then
							Tween(OtherButton, .2, { BackgroundColor3 = Theme.Component })
						end
					end

					Tween(OptionButton, .2, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) })

					wait(.15)
					
					if toggleDropdown then
						toggleDropdown()
					end
				end)
			end

			Services.Run.Heartbeat:Wait()
			Services.Run.Heartbeat:Wait()
			local contentSize = ListLayout.AbsoluteContentSize.Y + 8
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, contentSize)
			cachedContentSize = contentSize
			
			return contentSize
		end

		-- ПРИСВАИВАЕМ функцию переменной toggleDropdown (объявленной выше)
		toggleDropdown = function()
			if not isExpanded then
				local contentSize = createDropdownList()
				if contentSize and contentSize > 0 then
					DropdownList.Visible = true
					isExpanded = true
					local targetHeight = math.min(contentSize, 140)
					Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, targetHeight) })
					Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45 + targetHeight) })
				end
			else
				isExpanded = false
				Tween(DropdownList, .2, { Size = UDim2.new(1, 0, 0, 0) })
				Tween(Container, .2, { Size = UDim2.new(1, -20, 0, 45) })
				wait(.2)
				if DropdownList then
					DropdownList.Visible = false
				end
			end
		end

		Connect(SingleSelect.MouseButton1Click, toggleDropdown)

		Animations:Component(SingleSelect);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(SingleSelect, {
			Name = Settings.Title,
			Visible = true,
		})
		
		-- Возвращаем таблицу с методами для управления dropdown
		local methods = {
			Refresh = function(newOptions)
				-- Обновляем опции
				Settings.Options = newOptions or Settings.Options
				
				-- ПРИНУДИТЕЛЬНО закрываем dropdown
				isExpanded = false
				
				-- Полностью уничтожаем старый DropdownList со всеми кнопками
				if DropdownList then
					DropdownList:Destroy()
					DropdownList = nil
					cachedContentSize = 0
				end
				
				-- Принудительно возвращаем контейнер к нормальному размеру
				Container.Size = UDim2.new(1, -20, 0, 45)
				
				-- Обновляем текущий выбор если его нет в новых опциях
				local foundCurrent = false
				for _, option in ipairs(Settings.Options) do
					if option == CurrentSelection then
						foundCurrent = true
						break
					end
				end
				
				if not foundCurrent and #Settings.Options > 0 then
					CurrentSelection = Settings.Options[1]
					Text.Text = CurrentSelection
				elseif #Settings.Options == 0 then
					CurrentSelection = "No options"
					Text.Text = "No options"
				end
			end,
			
			SetValue = function(value)
				CurrentSelection = value
				Text.Text = value
				if Settings.Callback then
					Settings.Callback(value)
				end
			end,
			
			GetValue = function()
				return CurrentSelection
			end
		}
		
		-- Автоматическая регистрация в глобальном реестре конфигов
        -- фикс заебал 7
		local registry = getgenv().ConfigRegistry or _G.ConfigRegistry
		if type(registry) == "table" and Settings.Title then
			local elementId = Settings.Title:gsub(" ", "_"):lower()
			registry[elementId] = {
				element = methods,
				type = "singleselect"
			}
		end
		
		return methods
	end

	function Options:AddColorPicker(Settings)
		local ColorPicker = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(ColorPicker);
		local Main = ColorPicker["Main"];
		local CurrentColor = Settings.Default or Color3.fromRGB(255, 255, 255)
		local isOpen = false
		local PickerFrame = nil

		Destroy(Main:FindFirstChild("Circle"));
		SetProperty(Main, {
			BackgroundColor3 = CurrentColor,
			Size = UDim2.new(0, 40, 0, 20)
		});

		local function RGBToHSV(color)
			local r, g, b = color.R, color.G, color.B
			local max, min = math.max(r, g, b), math.min(r, g, b)
			local h, s, v = 0, 0, max
			local d = max - min
			s = max == 0 and 0 or d / max

			if max == min then
				h = 0
			else
				if max == r then
					h = (g - b) / d + (g < b and 6 or 0)
				elseif max == g then
					h = (b - r) / d + 2
				elseif max == b then
					h = (r - g) / d + 4
				end
				h = h / 6
			end

			return h, s, v
		end

		local function HSVToRGB(h, s, v)
			local r, g, b

			local i = math.floor(h * 6)
			local f = h * 6 - i
			local p = v * (1 - s)
			local q = v * (1 - f * s)
			local t = v * (1 - (1 - f) * s)

			i = i % 6

			if i == 0 then r, g, b = v, t, p
			elseif i == 1 then r, g, b = q, v, p
			elseif i == 2 then r, g, b = p, v, t
			elseif i == 3 then r, g, b = p, q, v
			elseif i == 4 then r, g, b = t, p, v
			elseif i == 5 then r, g, b = v, p, q
			end

			return Color3.fromRGB(r * 255, g * 255, b * 255)
		end

		Connect(ColorPicker.MouseButton1Click, function()
			if isOpen and PickerFrame then
				isOpen = false
				for i = #OpenPopups, 1, -1 do
					local popup = OpenPopups[i]
					if popup.Frame == PickerFrame then
						if popup.scrollConnection then
							popup.scrollConnection:Disconnect()
						end
						if popup.heartbeatConnection then
							popup.heartbeatConnection:Disconnect()
						end
						table.remove(OpenPopups, i)
						break
					end
				end
				if PickerFrame and PickerFrame.Parent then
					PickerFrame:Destroy()
				end
				PickerFrame = nil
				return
			end

			isOpen = true
			PickerFrame = Instance.new("CanvasGroup")
			local ColorCanvas = Instance.new("Frame")
			local HueBar = Instance.new("Frame")
			local HueGradient = Instance.new("UIGradient")
			local RGBFrame = Instance.new("Frame")
			local RInput, GInput, BInput

			local WindowFrame = Settings.Tab.Parent.Parent
			local ScrollFrame = Settings.Tab
			
			local function UpdatePosition()
				if not PickerFrame or not PickerFrame.Parent then return end
				
				local mainAbsolutePos = Main.AbsolutePosition
				local mainAbsoluteSize = Main.AbsoluteSize
				
				PickerFrame.Position = UDim2.new(0, mainAbsolutePos.X + mainAbsoluteSize.X + 5, 0, mainAbsolutePos.Y)
			end
			
			SetProperty(PickerFrame, {
				Name = "ColorPickerFrame",
				Size = UDim2.new(0, 200, 0, 180),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = Theme.Secondary,
				BorderSizePixel = 0,
				ZIndex = 999,
				GroupTransparency = 0,
				Parent = Screen
			})
			
			UpdatePosition()
			
			local scrollConnection = Connect(ScrollFrame:GetPropertyChangedSignal("CanvasPosition"), UpdatePosition)
			
			local heartbeatConnection = Connect(Services.Run.Heartbeat, UpdatePosition)
			
			local popupData = {
				Frame = PickerFrame,
				scrollConnection = scrollConnection,
				heartbeatConnection = heartbeatConnection,
				closeCallback = function()
					isOpen = false
					PickerFrame = nil
				end
			}
			table.insert(OpenPopups, popupData)

			local PickerStroke = Instance.new("UIStroke")
			PickerStroke.Color = Theme.Outline
			PickerStroke.Thickness = 2
			PickerStroke.Parent = PickerFrame

			local PickerCorner = Instance.new("UICorner")
			PickerCorner.CornerRadius = UDim.new(0, 6)
			PickerCorner.Parent = PickerFrame

			SetProperty(ColorCanvas, {
				Name = "ColorCanvas",
				Size = UDim2.new(0, 180, 0, 120),
				Position = UDim2.new(0, 10, 0, 10),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 1000,
				Parent = PickerFrame
			})

			local CanvasCorner = Instance.new("UICorner")
			CanvasCorner.CornerRadius = UDim.new(0, 4)
			CanvasCorner.Parent = ColorCanvas

			local BlackGradient = Instance.new("Frame")
			BlackGradient.Size = UDim2.new(1, 0, 1, 0)
			BlackGradient.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			BlackGradient.BorderSizePixel = 0
			BlackGradient.ZIndex = 1001
			BlackGradient.Parent = ColorCanvas

			local BlackGradientUI = Instance.new("UIGradient")
			BlackGradientUI.Rotation = 90
			BlackGradientUI.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			})
			BlackGradientUI.Parent = BlackGradient

			local WhiteGradient = Instance.new("Frame")
			WhiteGradient.Size = UDim2.new(1, 0, 1, 0)
			WhiteGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			WhiteGradient.BorderSizePixel = 0
			WhiteGradient.ZIndex = 1002
			WhiteGradient.Parent = BlackGradient

			local WhiteGradientUI = Instance.new("UIGradient")
			WhiteGradientUI.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
			WhiteGradientUI.Parent = WhiteGradient

			local CanvasCorner2 = Instance.new("UICorner")
			CanvasCorner2.CornerRadius = UDim.new(0, 4)
			CanvasCorner2.Parent = BlackGradient

			local CanvasCorner3 = Instance.new("UICorner")
			CanvasCorner3.CornerRadius = UDim.new(0, 4)
			CanvasCorner3.Parent = WhiteGradient

			SetProperty(HueBar, {
				Name = "HueBar",
				Size = UDim2.new(0, 180, 0, 15),
				Position = UDim2.new(0, 10, 0, 135),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 1000,
				Parent = PickerFrame
			})

			local HueCorner = Instance.new("UICorner")
			HueCorner.CornerRadius = UDim.new(0, 4)
			HueCorner.Parent = HueBar

			HueGradient.Rotation = 0
			HueGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			})
			HueGradient.Parent = HueBar

			SetProperty(RGBFrame, {
				Name = "RGBFrame",
				Size = UDim2.new(0, 180, 0, 20),
				Position = UDim2.new(0, 10, 0, 155),
				BackgroundTransparency = 1,
				ZIndex = 1000,
				Parent = PickerFrame
			})

			local function CreateRGBInput(position, label)
				local lbl = Instance.new("TextLabel")
				SetProperty(lbl, {
					Size = UDim2.new(0, 12, 0, 18),
					Position = UDim2.new(0, position, 0, 1),
					BackgroundTransparency = 1,
					Text = label,
					TextColor3 = Theme.Title,
					TextSize = 11,
					Font = Enum.Font.GothamMedium,
					ZIndex = 1001,
					Parent = RGBFrame
				})

				local input = Instance.new("TextBox")
				SetProperty(input, {
					Size = UDim2.new(0, 38, 0, 18),
					Position = UDim2.new(0, position + 14, 0, 1),
					BackgroundColor3 = Theme.Interactables,
					Text = "255",
					TextColor3 = Theme.Title,
					TextSize = 10,
					Font = Enum.Font.GothamMedium,
					ZIndex = 1001,
					Parent = RGBFrame
				})

				local inputCorner = Instance.new("UICorner")
				inputCorner.CornerRadius = UDim.new(0, 3)
				inputCorner.Parent = input

				return input
			end

			RInput = CreateRGBInput(0, "R:")
			GInput = CreateRGBInput(60, "G:")
			BInput = CreateRGBInput(120, "B:")

			local h, s, v = RGBToHSV(CurrentColor)
			local isDraggingCanvas = false
			local isDraggingHue = false
			local lastCallbackTime = 0
			local callbackDebounce = 0.1

			local function UpdateColor(newColor)
				CurrentColor = newColor
				Main.BackgroundColor3 = newColor

				RInput.Text = tostring(math.floor(newColor.R * 255))
				GInput.Text = tostring(math.floor(newColor.G * 255))
				BInput.Text = tostring(math.floor(newColor.B * 255))

				if Settings.Callback then
					local currentTime = tick()
					if currentTime - lastCallbackTime >= callbackDebounce then
						lastCallbackTime = currentTime
						Settings.Callback(newColor)
					end
				end
			end

			local function UpdateHue(input)
				local sizeX = HueBar.AbsoluteSize.X
				local posX = math.clamp(input.Position.X - HueBar.AbsolutePosition.X, 0, sizeX)
				h = posX / sizeX
				ColorCanvas.BackgroundColor3 = HSVToRGB(h, 1, 1)
				UpdateColor(HSVToRGB(h, s, v))
			end

			local function UpdateSV(input)
				local sizeX = ColorCanvas.AbsoluteSize.X
				local sizeY = ColorCanvas.AbsoluteSize.Y
				local posX = math.clamp(input.Position.X - ColorCanvas.AbsolutePosition.X, 0, sizeX)
				local posY = math.clamp(input.Position.Y - ColorCanvas.AbsolutePosition.Y, 0, sizeY)
				s = posX / sizeX
				v = 1 - (posY / sizeY)
				UpdateColor(HSVToRGB(h, s, v))
			end

			Connect(ColorCanvas.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isDraggingCanvas = true
					UpdateSV(input)
				end
			end)

			Connect(ColorCanvas.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isDraggingCanvas = false
					if Settings.Callback then
						Settings.Callback(CurrentColor)
					end
				end
			end)

			Connect(HueBar.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isDraggingHue = true
					UpdateHue(input)
				end
			end)

			Connect(HueBar.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isDraggingHue = false
					if Settings.Callback then
						Settings.Callback(CurrentColor)
					end
				end
			end)

			Connect(Services.Input.InputChanged, function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if isDraggingCanvas then
						UpdateSV(input)
					elseif isDraggingHue then
						UpdateHue(input)
					end
				end
			end)

			local function UpdateFromRGB()
				local r = math.clamp(tonumber(RInput.Text) or 0, 0, 255)
				local g = math.clamp(tonumber(GInput.Text) or 0, 0, 255)
				local b = math.clamp(tonumber(BInput.Text) or 0, 0, 255)
				local newColor = Color3.fromRGB(r, g, b)
				h, s, v = RGBToHSV(newColor)
				ColorCanvas.BackgroundColor3 = HSVToRGB(h, 1, 1)
				UpdateColor(newColor)
			end

			Connect(RInput.FocusLost, UpdateFromRGB)
			Connect(GInput.FocusLost, UpdateFromRGB)
			Connect(BInput.FocusLost, UpdateFromRGB)

			UpdateColor(CurrentColor)
			ColorCanvas.BackgroundColor3 = HSVToRGB(h, 1, 1)
		end)

		Animations:Component(ColorPicker);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(ColorPicker, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		
		-- Возвращаем методы для управления
		local methods = {
			SetValue = function(color)
				CurrentColor = color
				Main.BackgroundColor3 = color
				if Settings.Callback then
					Settings.Callback(color)
				end
			end,
			GetValue = function()
				return CurrentColor
			end
		}
		
		-- Автоматическая регистрация в глобальном реестре конфигов
        -- че за шлюха кодила фикс 8
		local registry = getgenv().ConfigRegistry or _G.ConfigRegistry
		if type(registry) == "table" and Settings.Title then
			local elementId = Settings.Title:gsub(" ", "_"):lower()
			-- Для ColorPicker сохраняем как таблицу {R, G, B}
			registry[elementId] = {
				element = {
					SetValue = function(value)
						if type(value) == "table" and value.R and value.G and value.B then
							local color = Color3.fromRGB(value.R * 255, value.G * 255, value.B * 255)
							methods.SetValue(color)
						end
					end,
					GetValue = function()
						local color = methods.GetValue()
						return {R = color.R, G = color.G, B = color.B}
					end
				},
				type = "colorpicker"
			}
		end
		
		return methods
	end

	function Options:AddParagraph(Settings) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,

			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,

			["Main"] = function(Label)
				if Label:IsA("Frame") then

					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						
						if Circle and not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,

			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,

			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},

		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,

			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,

			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme
		
		local titleBrightness = Theme.Title.R + Theme.Title.G + Theme.Title.B
		if titleBrightness > 1.5 then
			Setup.ThemeMode = "Dark"
		else
			Setup.ThemeMode = "Light"
		end

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow
		
		if Sidebar.Top.Buttons:FindFirstChild("TitleLabel") then
			Sidebar.Top.Buttons.TitleLabel.TextColor3 = Theme.Title
		end

		for Index, Descendant in next, Screen:GetDescendants() do
			if Descendant:IsA("TextLabel") then
				if Descendant.Name == "Title" or Descendant.Name == "Section" or Descendant.Name == "TitleLabel" then
					Descendant.TextColor3 = Theme.Title
				elseif Descendant.Name == "Description" then
					Descendant.TextColor3 = Theme.Description
				elseif Descendant.Name == "Options" or Descendant.Name == "Input" then
					Descendant.TextColor3 = Theme.Title
				elseif Descendant.Parent and Descendant.Parent.Name == "Main" and Descendant.Parent.Parent and Descendant.Parent.Parent:FindFirstChild("Value") then
					Descendant.TextColor3 = Theme.Title
				elseif Descendant.Parent and Descendant.Parent:FindFirstChild("List") then
					Descendant.TextColor3 = Theme.Tab
				elseif Descendant.Parent and Descendant.Parent:IsA("TextButton") and Descendant.Parent.Parent and Descendant.Parent.Parent:IsA("ScrollingFrame") then
					Descendant.TextColor3 = Theme.Title
				end
			elseif Descendant:IsA("TextButton") then
				-- Settings gear icon
				if Descendant.Name == "SettingsIcon" then
					Descendant.BackgroundColor3 = Theme.Component
					Descendant.TextColor3 = Theme.Description
				end
				
				if Descendant:FindFirstChild("Labels") then
					Descendant.BackgroundColor3 = Theme.Component
					local labels = Descendant:FindFirstChild("Labels")
					if labels then
						for _, label in pairs(labels:GetChildren()) do
							if label:IsA("TextLabel") then
								if label.Name == "Title" then
									label.TextColor3 = Theme.Title
								elseif label.Name == "Description" then
									label.TextColor3 = Theme.Description
								end
							end
						end
					end
				end
				if Descendant.Parent and Descendant.Parent:IsA("ScrollingFrame") and Descendant.Parent.Name == "DropdownList" then
					local label = Descendant:FindFirstChild("TextLabel")
					if label and label:IsA("TextLabel") then
						label.TextColor3 = Theme.Title
					end
					if Descendant.BackgroundColor3 ~= Color(Theme.Component, 5, Setup.ThemeMode) then
						Descendant.BackgroundColor3 = Theme.Component
					end
				end
				if Descendant.Parent and Descendant.Parent.Name == "Tab" then
					local titleLabel = Descendant:FindFirstChild("Title")
					if titleLabel and titleLabel:IsA("TextLabel") then
						titleLabel.TextColor3 = Theme.Title
					end
				end
			elseif Descendant:IsA("TextBox") then
				if Descendant.Name == "Input" then
					Descendant.TextColor3 = Theme.Title
					Descendant.BackgroundColor3 = Theme.Component
				end
			elseif Descendant:IsA("Frame") then
				if Descendant:FindFirstChild("DataContainer") and Descendant:FindFirstChild("Title") then
					Descendant.BackgroundColor3 = Theme.Component
				end
				
				if Descendant.Name == "Main" then
					local circle = Descendant:FindFirstChild("Circle")
					
					if not circle then
					elseif Descendant.Parent == Window then
						Descendant.BackgroundColor3 = Theme.Secondary
					else
						local parentHasValue = Descendant.Parent and Descendant.Parent:FindFirstChild("Value")
						if parentHasValue then
							local Toggle = Descendant.Parent.Value
							if Toggle and Toggle.Value ~= nil then
								if Toggle.Value then
									if Setup.ThemeMode == "Light" then
										Descendant.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
									else
										Descendant.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
									end
								else
									Descendant.BackgroundColor3 = Theme.Interactables
								end
								
								if Toggle.Value then
									if Setup.ThemeMode == "Light" then
										Tween(circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
									else
										Tween(circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
									end
								else
									if Setup.ThemeMode == "Light" then
										Tween(circle, .2, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
									else
										Tween(circle, .2, { BackgroundColor3 = Theme.Primary })
									end
								end
							end
						else
							Descendant.BackgroundColor3 = Theme.Interactables
						end
					end
				elseif Descendant.Name == "Slide" or Descendant.Name == "Amount" then
					Descendant.BackgroundColor3 = Theme.Interactables
				elseif Descendant.Name == "Underline" then
					Descendant.BackgroundColor3 = Theme.Outline
				elseif Descendant.Name == "Highlight" then
					if Setup.ThemeMode == "Light" then
						Descendant.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					else
						Descendant.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					end
					local sliderCircle = Descendant:FindFirstChild("Circle")
					if sliderCircle then
						if Setup.ThemeMode == "Light" then
							sliderCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
						else
							sliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						end
					end
				else
					if Descendant.Size == UDim2.new(0, 100, 0, 28) and Descendant.Parent and Descendant.Parent:FindFirstChild("Labels") then
						Descendant.BackgroundColor3 = Theme.Interactables
						local dropText = Descendant:FindFirstChild("DropText")
						if dropText and dropText:IsA("TextLabel") then
							dropText.TextColor3 = Theme.Title
						end
					end
				end
			elseif Descendant:IsA("ScrollingFrame") then
				if Descendant.Name == "DropdownList" then
					Descendant.BackgroundColor3 = Theme.Secondary
					Descendant.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
					-- Update checkboxes in multidropdown
					for _, child in pairs(Descendant:GetChildren()) do
						if child:IsA("TextButton") then
							child.BackgroundColor3 = Theme.Component
							-- Update labels and checkboxes
							for _, label in pairs(child:GetChildren()) do
								if label:IsA("TextLabel") and label.Name == "Checkmark" then
									-- If checkbox is checked, black background, otherwise use theme color
									if label.Text == "✓" then
										label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
									else
										label.BackgroundColor3 = Theme.Interactables
									end
									label.TextColor3 = Color3.fromRGB(255, 255, 255)
								elseif label:IsA("TextLabel") then
									label.TextColor3 = Theme.Title
								end
							end
						end
					end
				else
					Descendant.ScrollBarImageColor3 = Color3.fromRGB(25, 25, 25)
				end
			elseif Descendant:IsA("CanvasGroup") and Descendant.Name == "Notification" then
				Descendant.BackgroundColor3 = Theme.Primary
				if Descendant:FindFirstChild("UIStroke") then
					Descendant.UIStroke.Color = Theme.Outline
				end
			elseif Descendant:IsA("UIStroke") then
				if Descendant.Name == "Outline" or Descendant.Parent.Name == "DropdownList" then
					Descendant.Color = Theme.Outline
				end
			elseif Descendant:IsA("ImageLabel") then
				if Descendant.Image ~= "rbxassetid://6644618143" then
					Descendant.ImageColor3 = Theme.Icon
				end
			end
		end
		
		-- Update BindSettings windows
		for _, desc in pairs(Screen:GetDescendants()) do
			if desc:IsA("CanvasGroup") and desc.Name == "BindSettings" then
				desc.BackgroundColor3 = Theme.Secondary
				desc.GroupTransparency = Setup.Transparency or 0
				if desc:FindFirstChild("UIStroke") then
					desc.UIStroke.Color = Theme.Outline
				end
				-- Update elements inside bind window
				for _, child in pairs(desc:GetChildren()) do
					if child:IsA("TextBox") and child.Name == "BindInput" then
						child.BackgroundColor3 = Theme.Component
						child.TextColor3 = Theme.Title
					elseif child:IsA("TextButton") and child.Text:match("Button$") then
						child.BackgroundColor3 = Theme.Interactables
						child.TextColor3 = Theme.Title
					end
				end
			end
		end
		
		for Index, Descendant in next, Screen:GetDescendants() do
			local Name = Themes.Names[Descendant.Name]
			if Name then
				Name(Descendant)
			end
		end
	end

	--// Changing Settings

	function Options:SetSetting(Setting, Value)
		if Setting == "Size" then
			
			Window.Size = Value
			Setup.Size = Value
			
		elseif Setting == "Transparency" then
			
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				elseif Notification:IsA("CanvasGroup") and Notification.Name == "BindSettings" then
					Notification.GroupTransparency = Value
				end
			end
			
		elseif Setting == "Theme" and typeof(Value) == "table" then
			
			Options:SetTheme(Value)
			
		elseif Setting == "Keybind" then
			
			Setup.Keybind = Value
			
		else
			-- Setting doesn't exist or isn't available to change
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
