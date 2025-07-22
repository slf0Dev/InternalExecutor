local SyntaxHighlighter = {}

-- Цвета для разных типов токенов
local colors = {
    keyword = Color3.fromRGB(86, 156, 214),
    string = Color3.fromRGB(206, 145, 120),
    number = Color3.fromRGB(181, 206, 168),
    comment = Color3.fromRGB(106, 153, 85),
    builtin = Color3.fromRGB(78, 201, 176),
    normal = Color3.fromRGB(220, 220, 220),
    operator = Color3.fromRGB(212, 212, 212),
}

-- Ключевые слова Lua
local keywords = {
    ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
    ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
    ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
    ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
    ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
    ["while"] = true
}

-- Встроенные функции Roblox/Lua и их сигнатуры
local builtins = {
    wait = {signature = "wait([seconds: number])"},
    print = {signature = "print(...)"},
    require = {signature = "require(module: ModuleScript)"},
    spawn = {signature = "spawn(function)"},
    tick = {signature = "tick() → number"},
    typeof = {signature = "typeof(value) → string"},
    ["Vector3.new"] = {signature = "Vector3.new(x: number, y: number, z: number) → Vector3"},
    ["CFrame.new"] = {signature = "CFrame.new(x: number, y: number, z: number) → CFrame"},
    ["Instance.new"] = {signature = "Instance.new(className: string) → Instance"},
    game = {signature = "game: DataModel"},
    workspace = {signature = "workspace: Workspace"},
    script = {signature = "script: Instance"}
}

-- Roblox классы и их методы
local robloxClasses = {
    Part = {
        methods = {
            "Clone()", "Destroy()", "FindFirstAncestor()", "GetChildren()",
            "GetDescendants()", "GetMass()", "GetPivot()", "IsA()"
        }
    },
    Instance = {
        methods = {
            "Clone()", "Destroy()", "FindFirstAncestor()", "FindFirstChild()",
            "GetChildren()", "GetDescendants()", "IsA()"
        }
    }
}

-- Операторы
local operators = {
    ["+"] = true, ["-"] = true, ["*"] = true, ["/"] = true, ["%"] = true,
    ["^"] = true, ["#"] = true, ["=="] = true, ["~="] = true, ["<="] = true,
    [">="] = true, ["<"] = true, [">"] = true, ["="] = true, [";"] = true,
    [":"] = true, [","] = true, ["."] = true, [".."] = true, ["..."] = true
}

-- Создаем список для автодополнения
local autocompleteList = {}
for k in pairs(keywords) do table.insert(autocompleteList, k) end
for k in pairs(builtins) do table.insert(autocompleteList, k) end
for className, data in pairs(robloxClasses) do
    table.insert(autocompleteList, className)
    for _, method in ipairs(data.methods) do
        table.insert(autocompleteList, className .. ":" .. method)
    end
end
table.sort(autocompleteList)

-- Определяет тип токена
local function getTokenType(token)
    if keywords[token] then
        return "keyword"
    elseif builtins[token] or robloxClasses[token] then
        return "builtin"
    elseif operators[token] then
        return "operator"
    elseif tonumber(token) then
        return "number"
    elseif token:match("^[\"'].*[\"']$") then
        return "string"
    elseif token:match("^%-%-") then
        return "comment"
    end
    return "normal"
end

-- Optimized highlight function that processes only visible lines
function SyntaxHighlighter.highlight(textBox)
    -- Don't process if text is too large
    if #textBox.Text > 100000 then
        warn("Text too large for syntax highlighting")
        return
    end

    local text = textBox.Text
    local textLines = string.split(text, "\n")
    local richText = table.create(#textLines)

    for i, line in ipairs(textLines) do
        -- Process each line separately to prevent memory issues
        local lineText = ""

        -- Handle full-line comments first
        if line:match("^%-%-") then
            lineText = string.format('<font color="#%s">%s</font>', colors.comment:ToHex(), line)
            table.insert(richText, lineText)
            continue
        end

        -- Tokenize the line
        local tokens = {}
        local inString = false
        local stringChar = nil
        local currentToken = ""

        for j = 1, #line do
            local char = line:sub(j, j)

            -- String handling
            if (char == '"' or char == "'") and not inString then
                inString = true
                stringChar = char
                currentToken ..= char
            elseif inString and char == stringChar and line:sub(j-1, j-1) ~= "\" then
                inString = false
                currentToken ..= char
                table.insert(tokens, {text = currentToken, type = "string"})
                currentToken = ""
            elseif inString then
                currentToken ..= char
            else
                -- Handle operators and whitespace
                if char:match("%s") then
                    if #currentToken > 0 then
                        table.insert(tokens, {text = currentToken, type = getTokenType(currentToken)})
                        currentToken = ""
                    end
                    table.insert(tokens, {text = char, type = "whitespace"})
                elseif operators[char] or char:match("[%{%}%[%]%(%)]") then
                    if #currentToken > 0 then
                        table.insert(tokens, {text = currentToken, type = getTokenType(currentToken)})
                        currentToken = ""
                    end
                    table.insert(tokens, {text = char, type = "operator"})
                else
                    currentToken ..= char
                end
            end
        end

        if #currentToken > 0 then
            table.insert(tokens, {text = currentToken, type = getTokenType(currentToken)})
        end

        -- Build the highlighted line
        for _, token in ipairs(tokens) do
            if token.type == "whitespace" then
                lineText ..= token.text
            else
                lineText ..= string.format('<font color="#%s">%s</font>', colors[token.type]:ToHex(), token.text)
            end
        end

        table.insert(richText, lineText)
    end

    -- Apply the highlighted text in a way that preserves cursor position
    local cursorPos = textBox.CursorPosition
    local selectionStart = textBox.SelectionStart

    -- Join with newlines and remove the trailing one
    local finalText = table.concat(richText, "\n")

    -- Only update if the text has actually changed
    if textBox.Text ~= finalText then
        textBox.Hg.Text = finalText
        textBox.CursorPosition = cursorPos
        textBox.SelectionStart = selectionStart
    end
end

local function getCurrentWord(textBox)
    local text = textBox.Text
    local cursorPos = textBox.CursorPosition

    -- Находим начало слова
    local start = cursorPos
    while start > 1 and text:sub(start-1, start-1):match("[%w_:]") do
        start = start - 1
    end

    -- Находим конец слова
    local finish = cursorPos
    while finish < #text and text:sub(finish+1, finish+1):match("[%w_:]") do
        finish = finish + 1
    end

    local word = text:sub(start, finish)
    return word, start, finish
end

-- Функция для показа автодополнения
local function showAutocomplete(textBox, suggestions, selectedIndex)
    local word, start, finish = getCurrentWord(textBox)

    -- Создаем или обновляем GUI для автодополнения
    if not textBox.AutocompleteFrame then
        local frame = Instance.new("Frame")
        frame.Name = "AutocompleteFrame"
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        frame.BorderSizePixel = 0
        frame.ZIndex = 10
        frame.AutomaticSize = Enum.AutomaticSize.Y

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Parent = frame

        textBox.AutocompleteFrame = frame
        frame.Parent = textBox.Parent
    end

    -- Очищаем старые варианты
    for _, child in ipairs(textBox.AutocompleteFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Добавляем новые варианты
    for i, suggestion in ipairs(suggestions) do
        local button = Instance.new("TextButton")
        button.Text = suggestion
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = i == selectedIndex and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(45, 45, 45)
        button.BorderSizePixel = 0
        button.AutomaticSize = Enum.AutomaticSize.Y
        button.Size = UDim2.new(1, 0, 0, 30)
        button.ZIndex = 11
        button.Parent = textBox.AutocompleteFrame

        button.MouseButton1Click:Connect(function()
            local text = textBox.Text
            textBox.Text = text:sub(1, start-1) .. suggestion .. text:sub(finish+1)
            textBox.CursorPosition = start + #suggestion
            textBox.AutocompleteFrame.Visible = false
        end)
    end

    -- Позиционируем фрейм
    local absolutePosition = textBox.AbsolutePosition
    local absoluteSize = textBox.AbsoluteSize
    local lineHeight = textBox.TextBounds.Y / #string.split(textBox.Text, "\n")

    local line = 1
    local column = 1
    local currentPos = 0
    for i = 1, textBox.CursorPosition-1 do
        if textBox.Text:sub(i, i) == "\n" then
            line = line + 1
            column = 1
        else
            column = column + 1
        end
    end

    textBox.AutocompleteFrame.Position = UDim2.new(
        0, absolutePosition.X + (column-1) * 10, -- Примерная ширина символа
        0, absolutePosition.Y + (line-1) * lineHeight + lineHeight
    )

    textBox.AutocompleteFrame.Visible = true
end

-- Функция для автодополнения
local function updateAutocomplete(textBox)
    local word = getCurrentWord(textBox)
    if #word == 0 then
        if textBox.AutocompleteFrame then
            textBox.AutocompleteFrame.Visible = false
        end
        return
    end

    -- Ищем совпадения
    local suggestions = {}
    for _, item in ipairs(autocompleteList) do
        if item:lower():find(word:lower(), 1, true) == 1 then
            table.insert(suggestions, item)
        end
    end

    if #suggestions > 0 then
        showAutocomplete(textBox, suggestions, 1)
    elseif textBox.AutocompleteFrame then
        textBox.AutocompleteFrame.Visible = false
    end
end

-- Modified connect function with optimizations
function SyntaxHighlighter.connect(textBox)
    local debounce = false
    local lastText = ""

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if debounce then return end
        if textBox.Text == lastText then return end

        debounce = true

        -- Only highlight if text isn't too large
        if #textBox.Text < 100000 then
            local success = pcall(function()
                SyntaxHighlighter.highlight(textBox)
            end)

            if not success then
                warn("Syntax highlighting failed")
            end
        end

        lastText = textBox.Text
        debounce = false
    end)
    
    -- Автодополнение
    textBox.Focused:Connect(function()
        updateAutocomplete(textBox)
    end)

    textBox.FocusLost:Connect(function()
        if textBox.AutocompleteFrame then
            textBox.AutocompleteFrame.Visible = false
        end
    end)

    textBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        updateAutocomplete(textBox)
    end)

    -- Обработка клавиш для автодополнения
    local userInputService = game:GetService("UserInputService")

    local function handleInput(input)
        if not textBox:IsFocused() then return end
        if not textBox.AutocompleteFrame or not textBox.AutocompleteFrame.Visible then return end

        if input.KeyCode == Enum.KeyCode.Tab then
            -- Принимаем первое предложение
            local firstButton = textBox.AutocompleteFrame:FindFirstChildOfClass("TextButton")
            if firstButton then
                local word, start, finish = getCurrentWord(textBox)
                local text = textBox.Text
                textBox.Text = text:sub(1, start-1) .. firstButton.Text .. text:sub(finish+1)
                textBox.CursorPosition = start + #firstButton.Text
                textBox.AutocompleteFrame.Visible = false
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            -- Перемещаем выделение вниз
            local buttons = {}
            for _, child in ipairs(textBox.AutocompleteFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    table.insert(buttons, child)
                end
            end

            for i, button in ipairs(buttons) do
                if button.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
                    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    local nextIndex = (i % #buttons) + 1
                    buttons[nextIndex].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    break
                end
            end
        elseif input.KeyCode == Enum.KeyCode.Up then
            -- Перемещаем выделение вверх
            local buttons = {}
            for _, child in ipairs(textBox.AutocompleteFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    table.insert(buttons, child)
                end
            end

            for i, button in ipairs(buttons) do
                if button.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
                    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    local prevIndex = ((i - 2) % #buttons) + 1
                    buttons[prevIndex].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    break
                end
            end
        end
    end

    userInputService.InputBegan:Connect(handleInput)

end

return SyntaxHighlighter