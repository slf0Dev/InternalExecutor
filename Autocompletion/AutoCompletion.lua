local CodeAutocomplete = {}
local UserInputService = game:GetService("UserInputService")

function CodeAutocomplete.init(languageModule)
	local tokens = {}

	-- Собираем токены из всех категорий
	for category, items in pairs(languageModule) do
		if category == "keyword" or category == "builtin" then
			for name, completion in pairs(items) do
				tokens[name] = completion
			end
		elseif category == "libraries" then
			for libName, lib in pairs(items) do
				-- Добавляем саму библиотеку
				if type(lib) == "table" then
					tokens[libName] = libName

					-- Добавляем методы библиотеки
					for methodName, methodCompletion in pairs(lib) do
						if type(methodName) == "string" then
							tokens[libName.."."..methodName] = methodCompletion
						end
					end
				elseif type(lib) == "string" then
					tokens[libName] = lib
				end
			end
		end
	end

	function CodeAutocomplete.getSuggestions(prefix)
		local suggestions = {}
		prefix = prefix:lower()

		for token, completion in pairs(tokens) do
			if token:lower():find(prefix, 1, true) == 1 then
				table.insert(suggestions, {
					Text = token,
					Completion = completion
				})
			end
		end

		table.sort(suggestions, function(a, b) return a.Text < b.Text end)
		return suggestions
	end

	function CodeAutocomplete.setupTextBox(textBox, suggestionsFrame, suggestionTemplate)
		local currentSelection = 0
		local lastSuggestions = {}
		local lastPrefix = ""
		local ToReturn = {}
		-- Очистка предложений
		local function clearSuggestions()
			for _, child in ipairs(suggestionsFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
		end

		-- Обновление выделения
		local function updateSelection()
			local children = suggestionsFrame:GetChildren()
			for i, child in ipairs(children) do
				if child:IsA("TextButton") then
					-- Сбрасываем цвет всех кнопок
					child.BackgroundTransparency = 1
				end
			end

			-- Находим нужную кнопку по индексу currentSelection
			local selectedBtn = nil
			local btnIndex = 0
			for _, child in ipairs(children) do
				if child:IsA("TextButton") then
					btnIndex = btnIndex + 1
					if btnIndex == currentSelection then
						selectedBtn = child
						break
					end
				end
			end

			-- Применяем стиль к выбранной кнопке
			if selectedBtn then
				selectedBtn.BackgroundTransparency = 0.6      -- Белый текст
			end
		end

		-- Применение выбранного предложения
		local function applySuggestion()
			if currentSelection > 0 and currentSelection <= #lastSuggestions then
				local suggestion = lastSuggestions[currentSelection]
				local cursorPos = textBox.CursorPosition
				local text = textBox.Text

				-- Находим границы слова (игнорируя \n)
				local startPos = cursorPos
				while startPos > 1 and text:sub(startPos-1, startPos-1):match("[%w_%.]") do
					startPos = startPos - 1
				end

				local endPos = cursorPos
				while endPos <= #text and text:sub(endPos, endPos):match("[%w_%.]") do
					endPos = endPos + 1
				end

				-- Если курсор между строк, корректируем startPos
				if startPos > 1 and text:sub(startPos-1, startPos-1) == "\n" then
					startPos = cursorPos
					while startPos <= #text and not text:sub(startPos, startPos):match("[%w_%.]") do
						startPos = startPos + 1
					end
				end

				-- Остальная логика замены (как в предыдущем исправлении)
				local lastDotPos = nil
				for i = cursorPos, 1, -1 do
					if text:sub(i, i) == "." then
						lastDotPos = i
						break
					end
				end

				local completion = suggestion.Completion
				local replaceStart, replaceEnd

				if lastDotPos and suggestion.Text:find("%.") then
					replaceStart = lastDotPos + 1
					replaceEnd = endPos - 1
					local methodPart = suggestion.Text:match("%.(.+)$")
					if methodPart then
						completion = completion:match("%.(.+)$") or completion
						completion = completion:gsub("^%(", ""):gsub("^%)", "")
					end
				else
					replaceStart = startPos
					replaceEnd = endPos - 1
				end
				
				task.wait()
				textBox.Text = text:sub(1, replaceStart - 1) .. completion .. text:sub(replaceEnd + 1)

				-- Курсор после вставки
				local placeholderPos = completion:find("|")
				if placeholderPos then
					textBox.Text = textBox.Text:gsub("|", "")
					textBox.CursorPosition = replaceStart + placeholderPos - 1
				else
					textBox.CursorPosition = replaceStart + #completion
				end
			end
			suggestionsFrame.Visible = false
		end
		
		-- Обработчик изменений текста
		ToReturn.ChangeDetected = function()
			local cursorPos = textBox.CursorPosition
			local text = textBox.Text

			-- Находим текущее слово (игнорируя переносы строк)
			local startPos = cursorPos
			while startPos > 1 and text:sub(startPos-1, startPos-1):match("[%w_%.]") do
				startPos = startPos - 1
			end

			local endPos = cursorPos
			while endPos <= #text and text:sub(endPos, endPos):match("[%w_%.]") do
				endPos = endPos + 1
			end

			-- Если курсор между строк, проверяем текущую строку
			if startPos > 1 and text:sub(startPos-1, startPos-1) == "\n" then
				-- Ищем начало слова после переноса строки
				startPos = cursorPos
				while startPos <= #text and not text:sub(startPos, startPos):match("[%w_%.]") do
					startPos = startPos + 1
				end
			end

			local prefix = text:sub(startPos, endPos - 1)

			if #prefix > 0 and prefix ~= lastPrefix then
				lastPrefix = prefix
				lastSuggestions = CodeAutocomplete.getSuggestions(prefix)
				clearSuggestions()

				for i, suggestion in ipairs(lastSuggestions) do
					if i > 8 then break end -- Ограничиваем количество предложений

					local btn = suggestionTemplate:Clone()
					btn.Text = suggestion.Text
					btn.Visible = true
					btn.Parent = suggestionsFrame

					btn.MouseButton1Click:Connect(function()
						currentSelection = i
						applySuggestion()
					end)
				end

				suggestionsFrame.Visible = #lastSuggestions > 0
				currentSelection = math.min(math.max(1, currentSelection), #lastSuggestions)
				task.defer(function()
					updateSelection()
				end)
			elseif #prefix == 0 then
				clearSuggestions()
				suggestionsFrame.Visible = false
			end
		end

		-- Обработчик клавиш
		local function handleInput(input, gameProcessed)
			if not suggestionsFrame.Visible then return end
			
			local children = suggestionsFrame:GetChildren()
			local btnCount = 0
			for _, child in ipairs(children) do
				if child:IsA("TextButton") then
					btnCount = btnCount + 1
				end
			end
			
			if input.KeyCode == Enum.KeyCode.Tab then
				applySuggestion()
			elseif input.KeyCode == Enum.KeyCode.Up then
				currentSelection = currentSelection > 1 and currentSelection - 1 or btnCount
				updateSelection()
			elseif input.KeyCode == Enum.KeyCode.Down then
				currentSelection = currentSelection < btnCount and currentSelection + 1 or 1
				updateSelection()
			elseif input.KeyCode == Enum.KeyCode.Return then
				applySuggestion()
			elseif input.KeyCode == Enum.KeyCode.Escape then
				suggestionsFrame.Visible = false
			end
		end
		UserInputService.InputBegan:Connect(handleInput)

		textBox.Focused:Connect(function()
			if #textBox.Text > 0 then
				-- Триггерим обновление предложений при фокусе
				--textBox.Text = textBox.Text
			end
		end)

		textBox.FocusLost:Connect(function()
			suggestionsFrame.Visible = false
		end)
		return ToReturn
	end

	return CodeAutocomplete
end

return CodeAutocomplete
