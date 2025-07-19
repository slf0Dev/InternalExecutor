local TweenService = game:GetService("TweenService");
local Mouse = game.Players.LocalPlayer:GetMouse();
local PlayerGui = game.Players.LocalPlayer.PlayerGui;
local InputService = game:GetService("UserInputService");


local UI = {
    Instances = {},
    Theme = {
        Primary = Color3.fromRGB(100, 150, 255),  -- Голубой
        Secondary = Color3.fromRGB(255, 120, 200),  -- Розовый
        Success = Color3.fromRGB(120, 255, 150),  -- Зелёный
        Danger = Color3.fromRGB(255, 100, 100),  -- Красный
        Warning = Color3.fromRGB(255, 180, 100),  -- Оранжевый
        Dark = Color3.fromRGB(40, 40, 50),  -- Тёмный
        Light = Color3.fromRGB(240, 240, 250),  -- Светлый
        Background = Color3.fromRGB(25, 25, 35),  -- Фон
        Card = Color3.fromRGB(35, 35, 45),  -- Карточки
        Text = Color3.fromRGB(240, 240, 250),  -- Основной текст
        SubText = Color3.fromRGB(180, 180, 190),  -- Второстепенный текст

        Font = Font.fromId(12187377099)
    },
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
		if tostring(property) ~= "CornerRadius" and tostring(property) ~= "Stroke" and tostring(property) ~= "BoxShadow" then
			CreatedInstance[property] = value
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



function UI.CreateWindow()
    local Window = Create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 650, 0, 450),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = Screengui
    })

    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
        Parent = Window,
    })

    local TitleText = Create("TextLabel", {
        Name = "TitleText",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        FontFace = UI.Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar,
    })

    ApplyDragging(Window)

    return Window
end

UI.CreateWindow()