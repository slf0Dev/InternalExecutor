local TweenService = game:GetService("TweenService");
local Mouse = game.Players.LocalPlayer:GetMouse();
local PlayerGui = game.Players.LocalPlayer.PlayerGui;
local InputService = game:GetService("UserInputService");

local Repository = "https://raw.githubusercontent.com/slf0Dev/InternalExecutor/refs/heads/master/"

local Themes = loadstring(game:HttpGet(Repository.."Themes.lua"))()
local Highlighter = loadstring(game:HttpGet(Repository.."NewHighlighter/init.lua"))()
--local IDE = loadstring(readfile("InternalExecutor/Highlighter/IDE_STRIPPED.lua"))()


local UI = {
    Instances = {},
    Theme = Themes.LightDefault,
}

local function Observable(initialValue)
    local subscribers = {}
    local value = type(initialValue) == "table" and {} or initialValue
    local proxyCache = setmetatable({}, {__mode = "v"})
    local updateDepth = 0 


    local function createProxy(tbl, path)
        if type(tbl) ~= "table" then return tbl end
        if proxyCache[tbl] then return proxyCache[tbl] end

        local proxy = {}
        proxyCache[tbl] = proxy

        setmetatable(proxy, {
            __index = function(_, k)
                if k == "_isObservable" then return true end
                return createProxy(tbl[k], path.."."..k)
            end,
            __newindex = function(_, k, v)
                if updateDepth > 0 then
                    rawset(tbl, k, v)
                    return
                end

                local old = rawget(tbl, k)
                if old ~= v then
                    updateDepth = updateDepth + 1
                    
                    tbl[k] = createProxy(v, path.."."..k)
                    

                    for _, callback in ipairs(subscribers) do
                        task.spawn(callback, path.."."..k, v, old)
                    end
                    
                    updateDepth = updateDepth - 1
                end
            end
        })

        return proxy
    end


    if type(initialValue) == "table" then
        for k, v in pairs(initialValue) do
            value[k] = v
        end
    end
    value = createProxy(value, "")

    local public = value
    public.subscribe = function(callback)
        table.insert(subscribers, callback)
        return function()
            for i = #subscribers, 1, -1 do
                if subscribers[i] == callback then
                    table.remove(subscribers, i)
                end
            end
        end
    end

    public.set = function(newValue)
        updateDepth = updateDepth + 1
        

        for k in pairs(value) do
            if k ~= "subscribe" and k ~= "set" and k ~= "_isObservable" then
                value[k] = nil
            end
        end
        

        if type(newValue) == "table" then
            for k, v in pairs(newValue) do
                value[k] = v
            end
        end
        

        for _, callback in ipairs(subscribers) do
            task.spawn(callback, "", value, value)
        end
        
        updateDepth = updateDepth - 1
    end

    public.get = function() return value end

    return public
end


local HasProperty = function(instance, property) -- Currently not so reliable. Tests if instance has a certain property
	local successful = pcall(function()
		return instance[property]
	end)
	return successful and not instance:FindFirstChild(property) -- Fails if instance DOES have a child named a property, will fix soon
end


function Create(instance : string,properties : table)
	local Corner,Stroke
	local CreatedInstance = Instance.new(instance)
    local StrokeProperties
    local Stroke
	if instance == "TextButton" or instance == "ImageButton" then
		CreatedInstance.AutoButtonColor = false
    end
        
        if HasProperty(CreatedInstance,"BorderSizePixel") then
        CreatedInstance.BorderSizePixel = 0
    end

	for property,value in next,properties do
		if tostring(property) ~= "CornerRadius" and tostring(property) ~= "Stroke" and tostring(property) ~= "BoxShadow" and tostring(property) ~= "Pad" then
			CreatedInstance[property] = value
        elseif tostring(property) == "Pad" then
            local Padding = Instance.new("UIPadding",CreatedInstance)
            Padding.Name = "Padding"
            Padding.PaddingTop = UDim.new(0, value['Top'] or 0)
            Padding.PaddingBottom = UDim.new(0, value['Bottom'] or 0)
            Padding.PaddingLeft = UDim.new(0, value['Left'] or 0)
            Padding.PaddingRight = UDim.new(0, value['Right'] or 0)

		elseif tostring(property) == "Stroke" then
			StrokeProperties = {
				Color = value['Color'],
				Thickness = value['Thickness'],
				Transparency = value['Transparency'] or 0
			}
			Stroke = Instance.new("UIStroke",CreatedInstance)
			Stroke.Name = "Stroke"
			Stroke.Color = value["Color"] or Color3.fromRGB(255,255,255)
			Stroke.Thickness = value["Thickness"] or 1
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Stroke.Transparency = value["Transparency"] or 0
			Stroke.LineJoinMode = Enum.LineJoinMode.Round
            UI['Instances'][Stroke] = StrokeProperties

		elseif tostring(property) == "CornerRadius" then
			Corner = Instance.new("UICorner",CreatedInstance)
			Corner.Name = "Corner"
			Corner.CornerRadius = value
        elseif tostring(property) == "BoxShadow" then
            local BoxShadow = Instance.new("ImageLabel",CreatedInstance)
            BoxShadow.Size = UDim2.new(1,value['Size'][1],1,value['Size'][2])
            BoxShadow.AnchorPoint = Vector2.new(0.5,0.5)
            BoxShadow.Position = UDim2.new(0.5,value['Padding'][1],0.5,value['Padding'][2])
            BoxShadow.Image = "rbxassetid://1316045217"
            BoxShadow.BackgroundTransparency = 1
            BoxShadow.ImageTransparency = value['Transparency']
            BoxShadow.ScaleType = Enum.ScaleType.Slice
            BoxShadow.SliceCenter = Rect.new(10,10,118,118)
            BoxShadow.ImageColor3 = value['Color']
            BoxShadow.ZIndex = value['ZIndex'] or 1
            BoxShadow.Name = "Shadow"
            UI['Instances'][BoxShadow] = {ImageColor3 = value['Color']}
		end
	end
	UI['Instances'][CreatedInstance] = properties

	return CreatedInstance;
end

local function ApplyDragging(Window)
    local dragging
    local dragInput
    local dragStart
    local startPos
    local off = Vector3.new(0,0,0)
    local speed = 2.5
    local k = 0.04
    local windowSize

    local function update(input)
        local delta = input.Position - dragStart
        pcall(function()
            Window:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),"Out","Quad",0.05,true,nil)
        end)
        local position = Vector2.new(Mouse.X,Mouse.Y)
        local force = position - Window.AbsolutePosition
        local mag = force.Magnitude - 1
        force = force.Unit
        force *= 1 * k * mag
        local formula = speed * force --* delta
        --Tween(Window,0.3,{Rotation = formula.X},"Back")
    end
    
    local c = Window.InputBegan:Connect(function(input)
        if not UI.SliderActive then
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                windowSize = Window.AbsoluteSize
                dragStart = input.Position
                startPos = Window.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        --Tween(Window,0.3,{Rotation = 0},"Back")
                    end
                end)
            end
        end
    end)

    local b = Window.InputChanged:Connect(function(input)
        if not UI.SliderActive then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input

            end
        end
    end)

    local a = InputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Tween(instance, time, properties,EasingStyle,EasingDirection)
	local tw = TweenService:Create(instance, TweenInfo.new(time, EasingStyle and Enum.EasingStyle[EasingStyle] or Enum.EasingStyle.Quad,EasingDirection and Enum.EasingDirection[EasingDirection] or Enum.EasingDirection.Out), properties)
	task.delay(0, function()
		tw:Play()
	end)
	return tw
end


if game.CoreGui:FindFirstChild("ExecutorUI") then
    game.CoreGui.ExecutorUI:Destroy()
end

local Screengui = Create("ScreenGui", {
    Name = "ExecutorUI",
    ResetOnSpawn = false,
    DisplayOrder = 10,
    Parent = game.CoreGui,
    ScreenInsets = Enum.ScreenInsets.None
})



function UI.CreateWindow(parameters : table)
    local Window = Create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 650, 0, 450),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = UI.Theme.Background,
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, 10),
        Parent = Screengui,
        Pad = {
            Top = 16,
            Bottom = 16,
            Left = 16,
            Right = 16
        }
    })

    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Window,
    })

    local TitleText = Create("TextLabel", {
        Name = "TitleText",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = UI.Theme.Text,
        TextSize = 28,
        Text = parameters.Title,
        FontFace = UI.Theme.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar,
    })

    ApplyDragging(Window)

    return Window
end

-- ... (предыдущий код остается без изменений до функции UI.InitCodeEditor)

-- ... (предыдущий код остается без изменений до функции UI.InitCodeEditor)

function UI.InitCodeEditor(parameters : table)
    local Editor = {
        Tabs = {},
        ActiveTab = nil,
        TabContents = {}, -- Хранит содержимое вкладок
        TabCount = 0, -- Счетчик вкладок
    }
    local CodeEditor = Create("Frame", {
        Name = "CodeEditor",
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parameters.Parent,
        Pad = {
            Top = 8,
            Bottom = 8,
            Left = 0,
            Right = 0
        }
    })

    local TabsNavigation = Create("Frame", {
        Name = "TabsNavigation",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = CodeEditor,
        Pad = {
            Top = 0,
            Bottom = 0,
            Left = 16,
            Right = 16
        }
    })

    local TabsListLayout = Create("UIListLayout", {
        Name = "TabsListLayout",
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = TabsNavigation
    })

    local CodeTextBox = Create("Frame", {
        Name = "CodeTextBox",
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 16, 0, 48),
        BackgroundTransparency = 1,
        BackgroundColor3 = UI.Theme.SecondaryBackground,
        CornerRadius = UDim.new(0, 5),
        Parent = CodeEditor,
        FontFace = UI.Theme.Fonts.Regular,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 18
    })
    local InputBox = CodeTextBox

    CodeTextBox.highlight({
        textObject = CodeTextBox,
    })

    local function ensureDirectory()
        if not isfolder("OceriumExec") then
            makefolder("OceriumExec")
        end
    end


    local function getTabFilePath(tabName)
        return "OceriumExec/"..tabName
    end


    local function findExistingTabs()
        ensureDirectory()
        local tabs = {}
        local files = listfiles("OceriumExec")

        if files == nil or #files == 0 then
            return false
        end
        for _, filePath in pairs(files) do
            if typeof(tabs) ~= "table" then
                return false
            end
            local fileName = filePath:split([[\]])[2] -- Получаем имя файла без пути
            if fileName then
                tabs[fileName] = readfile(filePath)
            end
        end
        
        return tabs
    end
    local function SwapTab(tabName)
        Editor.ActiveTab = Editor.Tabs[tabName]
        InputBox.Text = Editor.TabContents[tabName] or ""
        Editor.UpdateTabs()
    end
    
    local function loadExistingTabs()
        local existingTabs = findExistingTabs()
        if existingTabs == false then
            return
        end
        for tabName, tabContent in next,existingTabs do
            Editor.TabContents[tabName] = tabContent
            Editor.AddTab(tabName)
        end
    end

    
    local function saveTabContent(tabName, content)
        ensureDirectory()
        Editor.TabContents[tabName] = content
        writefile(getTabFilePath(tabName), content or "")
        if content == "" then
            if isfile(getTabFilePath(tabName)) then
                delfile(getTabFilePath(tabName))
            end
        end
    end

    _G.Editor = {
        loadExistingTabs = loadExistingTabs,
        SwapTab = SwapTab,
        UpdateTabs = Editor.UpdateTabs,
        findExistingTabs = findExistingTabs,
        saveTabContent = saveTabContent,
        Editor = Editor
    }



    InputBox = CodeTextBox
    --[[CodeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if Editor.ActiveTab then
            saveTabContent(Editor.ActiveTab.Name, CodeTextBox.Text)
        end
    end)]]


    Editor.UpdateTabs = function()
        for _, tab in pairs(Editor.Tabs) do
            if tab.Name ~= Editor.ActiveTab.Name then
                Tween(tab.Instance, 0.2, {TextColor3 = UI.Theme.Text}, "Quad", "Out")
            end
        end

        if Editor.ActiveTab then
            Tween(Editor.ActiveTab.Instance, 0.2, {TextColor3 = UI.Theme.Accent}, "Quad", "Out")
        end
    end
    
    Editor.AddTab = function(tabName)
        if not tabName then
            Editor.TabCount = Editor.TabCount + 1
            tabName = "Tab"..Editor.TabCount
        else
            local num = tabName:match("Tab(%d+)")
            if num then
                num = tonumber(num)
                if num > Editor.TabCount then
                    Editor.TabCount = num
                end
            end
        end
        
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(0, 0, 1, -2),
            BackgroundTransparency = 1,
            BackgroundColor3 = UI.Theme.SecondaryBackground,
            TextColor3 = UI.Theme.Text,
            TextSize = 22,
            Text = tabName,
            FontFace = UI.Theme.Fonts.Regular,
            Parent = TabsNavigation,
            CornerRadius = UDim.new(0, 5),
        })
    
        TabButton.Size = UDim2.new(0, TabButton.TextBounds.X + 50, 1, -2)

        Editor.Tabs[tabName] = {
            Instance = TabButton,
            Name = tabName,
        }
    
        TabButton.MouseEnter:Connect(function()
            Tween(TabButton, 0.2, {BackgroundTransparency = 0.3}, "Quad", "Out")
        end)
    
        TabButton.MouseLeave:Connect(function()
            Tween(TabButton, 0.2, {BackgroundTransparency = 1}, "Quad", "Out")
        end)


        TabButton.MouseButton1Click:Connect(function()
            if Editor.ActiveTab then
                Editor.ActiveTab.BackgroundTransparency = 1
            end
            SwapTab(tabName)
        end)
        SwapTab(tabName)
        return Editor.Tabs[tabName]
    end

    local AddTabButton = Create("TextButton", {
        Name = "AddTabButton",
        Size = UDim2.new(0, 40, 0, 30),
        BackgroundTransparency = 0.7,
        BackgroundColor3 = UI.Theme.Accent,
        TextColor3 = UI.Theme.Text,
        TextSize = 20,
        Text = "+",
        FontFace = UI.Theme.Fonts.Bold,
        Parent = TabsNavigation,
        CornerRadius = UDim.new(0, 5),
        LayoutOrder = 1000
    })


    --Editor.AddTab()
    AddTabButton.MouseButton1Click:Connect(function()
        local newTab = Editor.AddTab()
        Editor.ActiveTab = newTab.Instance
        InputBox.Text = ""
        Editor.TabContents[newTab.Name] = ""
    end)

    if not findExistingTabs() then
        Editor.AddTab("Tab1")
    end
    loadExistingTabs()
    return CodeEditor
end

local Editor = UI.CreateWindow({
    Title = "Code"
})

UI.InitCodeEditor({
    Parent = Editor
})
