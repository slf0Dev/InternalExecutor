local DEFAULT_TOKEN_COLORS = {
    ["background"] = Color3.fromRGB(230, 230, 230),       -- Белый фон
    ["iden"] = Color3.fromRGB(50, 50, 70),                -- Основной текст (идентификаторы)
    ["keyword"] = Color3.fromRGB(133, 35, 125),           -- Ключевые слова (фиолетовый)
    ["builtin"] = Color3.fromRGB(0, 112, 201),            -- Встроенные функции (синий)
    ["string"] = Color3.fromRGB(46, 147, 68),             -- Строки (зелёный)
    ["number"] = Color3.fromRGB(255, 89, 46),             -- Числа (оранжево-красный)
    ["comment"] = Color3.fromRGB(127, 144, 148),          -- Комментарии (серо-голубой)
    ["operator"] = Color3.fromRGB(230, 162, 60),          -- Операторы (золотисто-жёлтый)
    ["custom"] = Color3.fromRGB(87, 130, 202),            -- Пользовательские элементы (индиго)
}


local function GetModule(Path : string)
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/slf0Dev/InternalExecutor/refs/heads/master/" .. Path))()
end

local EditorThemes = GetModule("Themes.lua")

DEFAULT_TOKEN_COLORS = EditorThemes.DarkDefault.TokenColors

local types = GetModule("NewHighlighter/types.lua")

local Theme = {
	tokenColors = {},
	tokenRichTextFormatter = {},
}

function Theme.setColors(tokenColors: types.TokenColors)
	assert(type(tokenColors) == "table", "Theme.updateColors expects a table")

	for tokenName, color in tokenColors do
		Theme.tokenColors[tokenName] = color
	end
end

function Theme.getColoredRichText(color: Color3, text: string): string
	return '<font color="#' .. color:ToHex() .. '">' .. text .. "</font>"
end

function Theme.getColor(tokenName: types.TokenName): Color3
	return Theme.tokenColors[tokenName]
end

function Theme.matchStudioSettings(refreshCallback: () -> ()): boolean
	local success = pcall(function()
		-- When not used in a Studio plugin, this will error
		-- and the pcall will just silently return
		local studio = settings().Studio
		local studioTheme = studio.Theme

		local function getTokens()
			return {
				["background"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBackground),
				["iden"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptText),
				["keyword"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptKeyword),
				["builtin"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBuiltInFunction),
				["string"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptString),
				["number"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptNumber),
				["comment"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptComment),
				["operator"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptOperator),
				["custom"] = studioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBool),
			}
		end

		Theme.setColors(getTokens())
		studio.ThemeChanged:Connect(function()
			studioTheme = studio.Theme
			Theme.setColors(getTokens())
            refreshCallback()
		end)
	end)
	return success
end

-- Initialize
Theme.setColors(DEFAULT_TOKEN_COLORS)

return Theme
