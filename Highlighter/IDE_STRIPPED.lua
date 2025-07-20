local IDEModule = {}

local TS = game:GetService("TextService")
local RS = game:GetService("RunService")
local Highlighter = loadstring(script:WaitForChild("HighlighterModule").Source)()

-- Weird Luau VM optimizations
local ipairs	= ipairs
local pairs		= pairs

function IDEModule.new(ParentFrame)

	local IDE = {Content = ""; OnCanvasSizeChanged = Instance.new "BindableEvent"}

	local TextSize = 16

	local Theme = settings().Studio.Theme

	local Scroller = Instance.new("ScrollingFrame")

	Scroller.Name						= "IDE"
	Scroller.BackgroundColor3			= Color3.fromRGB(34, 34, 34)
	Scroller.Size						= UDim2.new(1,0,1,0)
	Scroller.BorderSizePixel			= 0
	Scroller.BottomImage				= Scroller.MidImage
	Scroller.TopImage					= Scroller.MidImage
	Scroller.ScrollBarImageColor3		= Theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar):Lerp(Color3.new(1,1,1),0.2)
	Scroller.ScrollBarThickness			= math.ceil(TextSize*0.75)
	Scroller.VerticalScrollBarInset		= Enum.ScrollBarInset.ScrollBar
	Scroller.HorizontalScrollBarInset	= Enum.ScrollBarInset.ScrollBar
	Scroller.CanvasSize                 = UDim2.new(0, 0, 0, 0)

	Scroller:GetPropertyChangedSignal("CanvasSize"):Connect(function()
		IDE.OnCanvasSizeChanged:Fire(Scroller.CanvasSize, Scroller.AbsoluteWindowSize)
	end)

	local Input = Instance.new("TextBox")

	Input.Name						= "Input"
	Input.BackgroundColor3			= Color3.fromRGB(27, 27, 27)
	Input.Size						= UDim2.new(1,-TextSize*3,1,0)
	Input.Position					= UDim2.new(0,TextSize*3,0,0)
	Input.MultiLine					= true
	Input.ClearTextOnFocus			= false
	Input.TextSize					= TextSize
	Input.Text						= ""
	Input.BorderSizePixel			= 0
	Input.Font						= Enum.Font.Code
	Input.TextColor3				= Theme:GetColor(Enum.StudioStyleGuideColor.ScriptText):Lerp(Scroller.BackgroundColor3, 0.3)
	Input.TextXAlignment			= Enum.TextXAlignment.Left
	Input.TextYAlignment			= Enum.TextYAlignment.Top
	Input.Active					= false

	Input.Parent = Scroller

	local Lines = Instance.new("Frame")

	Lines.Name						= "Lines"
	Lines.BackgroundTransparency	= 0.9
	Lines.BackgroundColor3			= Color3.new()
	Lines.Size						= UDim2.new(0,TextSize*2.5,1,0)
	Lines.BorderSizePixel			= 0

	local LinesLayout = Instance.new("UIListLayout")

	LinesLayout.SortOrder		= Enum.SortOrder.LayoutOrder

	LinesLayout.Parent = Lines

	local LineMarker = Instance.new("TextButton")

	LineMarker.Name						= "Line_1"
	LineMarker.BackgroundTransparency	= 1
	LineMarker.LayoutOrder				= 1
	LineMarker.TextSize					= TextSize
	LineMarker.Font						= Enum.Font.Code
	LineMarker.TextColor3				= Theme:GetColor(Enum.StudioStyleGuideColor.ScriptText)
	LineMarker.TextXAlignment			= Enum.TextXAlignment.Right
	LineMarker.Size						= UDim2.new(1,0,0,TextSize)
	LineMarker.Text						= "1 "

	LineMarker.MouseButton1Click:Connect(function()
		local Lines = string.split(Input.Text,"\n")

		Input.SelectionStart = 0
		Input.CursorPosition = #Lines[1]+1
	end)

	LineMarker.Parent = Lines

	Lines.Parent = Scroller

	-- fix for scrolling in a textbox
	-- unfortunately it has to deselect the text box to work
	-- roblox pls
	Input.InputChanged:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
			Input:ReleaseFocus()
		end
	end)

	local PreviousLength = 0
	Input:GetPropertyChangedSignal("Text"):Connect(function()

		RS.Heartbeat:Wait() -- Let the changes process first.

		-- This disgusting mess normalizes the text to not be such a b*tch with control chars and broken tabs
		local Text = string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(Input.Text,"\0",""), "\a", ""), "\b", ""), "\v", ""), "\f", ""), "\r", "")
		local Text,TabChange = string.gsub(Text,"\t", "    ")
		local TotalLines = #string.split(Text, "\n")

		-- Handle retaining tab depth
		if #Text-PreviousLength == 1 then
			local AddedChar = string.sub(Text, Input.CursorPosition-1, Input.CursorPosition-1)
			if AddedChar == "\n" then
				local TextLines		= string.split(string.sub(Text,1,Input.CursorPosition-1), "\n")
				local PreviousLine	= TextLines[#TextLines-1] or ""
				local TabDepth		= string.match(PreviousLine, "^[\t ]+") or ""

				Input.Text = string.sub(Text,1,Input.CursorPosition-1)..TabDepth..string.sub(Text,Input.CursorPosition)

				Input.CursorPosition = Input.CursorPosition+#TabDepth
			end
		else
			Input.Text = Text
		end

		Input.CursorPosition = Input.CursorPosition+(TabChange*3)

		-- Handle line markers on the side
		local MarkedLines = Lines:GetChildren()

		if #MarkedLines-1<TotalLines then
			for i=#MarkedLines,TotalLines do
				local NewLineMarker = LineMarker:Clone()
				NewLineMarker.Name			= "Line_"..i
				NewLineMarker.LayoutOrder	= i
				NewLineMarker.Text			= tostring(i).." "

				NewLineMarker.MouseButton1Click:Connect(function()
					local Lines = string.split(Input.Text,"\n")

					local start = 0
					for l=1,i-1 do
						start = start+1+#Lines[l]
					end

					Input.SelectionStart = start
					Input.CursorPosition = start+#Lines[i]+1
				end)

				NewLineMarker.Parent = Lines	
			end
		elseif #MarkedLines-1>TotalLines then
			for i=TotalLines+2,#MarkedLines do
				MarkedLines[i]:Destroy()	
			end
		end

		-- Handle autosizing the scrollingframe
		local TextBounds = TS:GetTextSize(Text,TextSize,Input.Font, Vector2.new(99999,99999))
		Scroller.CanvasSize = UDim2.new(
			0,TextBounds.X+Input.Position.X.Offset+TextSize,
			0,TextBounds.Y+Scroller.AbsoluteWindowSize.Y-TextSize
		)

		PreviousLength = #Text
		IDE.Content = Input.Text

		Highlighter:Highlight(Input)
	end)

	Scroller.Parent = ParentFrame


	settings().Studio.ThemeChanged:Connect(function()
		Theme = settings().Studio.Theme

		Highlighter:ReloadColors(Input)

		Scroller.BackgroundColor3		= Theme:GetColor(Enum.StudioStyleGuideColor.ScriptBackground)
		Scroller.ScrollBarImageColor3	= Theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar):Lerp(Color3.new(1,1,1),0.2)
		Input.TextColor3				= Theme:GetColor(Enum.StudioStyleGuideColor.ScriptPreprocessor):Lerp(Scroller.BackgroundColor3, 0.3)

		local TextColor = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptText)
		for _,LineMarker in pairs(Lines:GetChildren()) do
			if LineMarker:IsA("TextLabel") then
				LineMarker.TextColor3 = TextColor
			end
		end
	end)

	function IDE:SetContent(Content)
		Highlighter:ClearCache(Input)
		Input.Text = type(Content) == "string" and string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(Content,"\t", "    "), "\0",""), "\a", ""), "\b", ""), "\v", ""), "\f", ""), "\r", "") or Input.Text
	end

	function IDE:ReleaseFocus()
		Input:ReleaseFocus()
	end

	return IDE
end


return IDEModule
