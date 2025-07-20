--[=[

	Highlighter Module
	by boatbomber
	
	Handles Lua syntax highlighting on Roblox text objects
	
	-----------------------
	
	NOTICE: NOT DISTRIBUTED FREELY!
	YOU MUST OBTAIN WRITTEN PERMISSION FROM BOATBOMBER IN ORDER TO USE THIS MODULE IN ANY WORKS.
	ANYONE CAUGHT USING THIS WITHOUT PERMISSION WILL BE PROSECUTED TO THE FULLEST EXTENT OF THE LAW.
	
	-----------------------
	
	
	API:
	
	Module:Highlight(TextObject)
	
		Syntax highlights the text of the TextObject.
		Can be called multiple times, and it will reuse the TextLabels from previous highlights.
	
	Module:ContinuousHighlight(TextObject)
		
		Calls Module:Highlight(TextObject) whenever TextObject.Text is changed.
		Literally just a wrapper for the sake of cleanliness in your code.
	
	Module:ReloadColors(TextObject)
		
		Recolors the highlights in that TextObject to match the currently set colors.
		
	Module:ClearCache(TextObject)
	
		Clears data saved on that TextObject, and removes all highlighting.
	
--]=]
local Repository = "https://raw.githubusercontent.com/slf0Dev/InternalExecutor/refs/heads/master/"

local Player	= game:GetService("Players").LocalPlayer

local RS		= game:GetService("RunService")

local Lexer			= loadstring(game:HttpGet(Repository.. "Highlighter/lexer.lua"))()
local ObjectPool	= loadstring(game:HttpGet(Repository.. "Highlighter/ObjectPool.lua"))()

local ipairs	= ipairs

	
local TokenTemplate = Instance.new("TextLabel")
	TokenTemplate.Name = "Token"
	TokenTemplate.BackgroundTransparency = 1
	TokenTemplate.Font = Enum.Font.Code
	TokenTemplate.TextColor3 = Color3.new(1,1,1)
	TokenTemplate.TextXAlignment = Enum.TextXAlignment.Left
	TokenTemplate.TextYAlignment = Enum.TextYAlignment.Top

local TokenPool = ObjectPool.new(TokenTemplate,50)

local Theme = settings().Studio.Theme
local ScriptColors = {
	Number = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptNumber);
	String = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptString);
	Comment = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptComment);
	Text = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptText);
	Keyword = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptKeyword);
	Builtin = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptBuiltInFunction);
	Operator = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptOperator);
	Background = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptBackground);
}

local Module = {	
	Busy			= {};
	LastLex			= {};
	
	TokenToColor	= {
		['number']		= ScriptColors.Number;
		['string']		= ScriptColors.String;
		['comment']		= ScriptColors.Comment;
		['iden']		= ScriptColors.Text;
		['keyword']		= ScriptColors.Keyword;
		['builtin']		= ScriptColors.Builtin;
		['operator']	= ScriptColors.Operator;
	};
	
	ColorToToken	= {
		[tostring(ScriptColors.Number)]		= 'number';
		[tostring(ScriptColors.String)]		= 'string';
		[tostring(ScriptColors.Comment)]	= 'comment';
		[tostring(ScriptColors.Text)]		= 'iden';
		[tostring(ScriptColors.Keyword)]	= 'keyword';
		[tostring(ScriptColors.Builtin)]	= 'builtin';
		[tostring(ScriptColors.Operator)]	= 'operator';
	};
}

local Libraries = {
	math = {
		abs = true;		acos = true;	asin = true;	atan = true;
		atan2 = true;	ceil = true;	clamp = true;	cos = true;
		cosh = true;	deg = true;		exp = true;		floor = true;
		fmod = true;	frexp = true;	ldexp = true;	log = true;
		log10 = true;	max = true;		min = true;		modf = true;
		noise = true;	pow = true;		rad = true;		random = true;
		sinh = true;	sqrt = true;	tan = true;		tanh = true;
		sign = true;	sin = true;		randomseed = true;
		
		huge = true;	pi = true;
	};
	
	string = {
		byte = true;	char = true;	find = true;	format = true;
		gmatch = true;	gsub = true;	len = true;		lower = true;
		match = true;	rep = true;		reverse = true;	split = true;
		sub = true;		upper = true;
	};
	
	table = {
		concat = true;	foreach = true;	foreachi = true;getn = true;
		insert = true;	remove = true;	remove = true;	sort = true;
		pack = true;	unpack = true;	move = true;	create = true;
		find = true;
	};
	
	debug = {
		profilebegin = true;	profileend = true;	traceback = true
	};
	
	os = {
		time = true;	date = true;	difftime = true;
	};
	
	coroutine = {
		create = true;	isyieldable = true;	resume = true;	running = true;
		status = true;	wrap = true;	yield = true;
	};
}

function Module:Highlight(TextObject)
	
	-- If this TextObject is already being highlighted, the LastLex data is incomplete and
	-- we may end up doing duplicate work or worse, so we give them up to 50 Heartbeats to complete.
	-- Note that it'll almost certainly never be more than a couple beats, but we're cautious.
	if self.Busy[TextObject] then
		for i=1,50 do
			RS.Heartbeat:Wait()
			if not self.Busy[TextObject] then
				break
			end
		end
	end
	
	self.Busy[TextObject] = true
	
	--print("---------------") -- Divides debug prints so that we can tell what happened when
	
	-- Gather data for the TextObject
	local Source		= TextObject.Text
	local TextSize		= TextObject.TextSize
	local TextSizeX		= math.ceil(TextSize*0.5)
	local LineHeight	= TextSize*TextObject.LineHeight
	
	-- Init counters and indexes
	local CurrentLabel	= 0
	local CurrentLine	= 1
	local CurrentDepth	= 0
	local CurrentLex	= 0
	local ChangeFound	= false
	
	-- Find prior highlight data or create if none exists
	local LastLex = self.LastLex[TextObject]
	if LastLex == nil then
		self.LastLex[TextObject] = {}
		LastLex = self.LastLex[TextObject]
	end
	
	-- Iterate through the tokenized source text
	for token,src in Lexer.scan(Source) do
		--print(token,'"'..src..'"')
		CurrentLex = CurrentLex+1
		
		local TokenLines = string.split(src,"\n")		
		if (not ChangeFound) and (LastLex[CurrentLex]) and (LastLex[CurrentLex][1] == token and LastLex[CurrentLex][2] == src) then
			--print("   unchanged",CurrentLex)
			
			-- This token is the same as the last time we highlighted- therefore the label needs no update,
			-- but we do need to update our internal counters and indexes
			
			if string.find(src, "%S") then
				-- This token has text that would have used 1 or more labels, so update our
				-- label index so that we update the correct label when we do find the changes
				for i,LineSrc in ipairs(TokenLines) do
					if string.find(LineSrc,"%S") then
						CurrentLabel = CurrentLabel + 1
					end
				end
			end
			
			if #TokenLines>1 then
				-- There are multiple lines in this token, so update our position indexes
				CurrentLine = CurrentLine+#TokenLines-1
				CurrentDepth = 0
			end
			
			-- Push our depth to the length of the token's final line
			CurrentDepth = CurrentDepth+ #TokenLines[#TokenLines]
			
		else
			--print("   changed",CurrentLex,token)
			
			-- This token has either been changed or is after the changed token, so
			-- the label at this index needs to be updated
			
			-- Mark that the change has been found so further labels are updated
			ChangeFound = true
			-- Update our dictionary so it'll have up-to-date info for next time
			LastLex[CurrentLex] = {token,src}
			
			-- Iterate through the lines in this token and render appropriately
			for i,LineSrc in ipairs(TokenLines) do
				
				-- Update our position to the next line if this a new line
				if i>1 then
					CurrentLine = CurrentLine + 1
					CurrentDepth = 0
				end
				
				-- To avoid rendering any blank labels (which is wasteful) we check for non-whitespace first
				if string.find(LineSrc,"%S") then
					
					CurrentLabel = CurrentLabel + 1
					
					--print("  Rendering",CurrentLabel)
					
					-- Our tokenizer doesn't have backwards propagation so "math.random" doesn't highlight "random"
					-- and math.Random will highlight Random because Random.new() stuff. Therefore, we do our checks
					-- for these things in the highlighter scope. Note that at this point in the logic flow, changing
					-- our `token` value only changes the rendered color and no actual stored values are altered.
					
					if CurrentLex>2 then -- If we're not at least 3 tokens deep, there's no way we have math.X here
						local BackLex = CurrentLex-1
						
						-- Find previous non-whitespace token
						while LastLex[BackLex] and LastLex[BackLex][1] == "space" do
							BackLex = BackLex-1
						end
						
						-- If the previous tokens were `LIB.`				
						if LastLex[BackLex] and LastLex[BackLex][2] == "." then
							local LibraryChildren = Libraries[LastLex[BackLex-1] and LastLex[BackLex-1][2]]
							if LibraryChildren then
								-- This can't be a builtin without space
								if token == "builtin" and BackLex==CurrentLex-1 then
									token = "iden"
								elseif token == "iden" then
									if LibraryChildren[src] then
										token = "builtin"
									end
								end
							end
						end
						
					end
					
					
					local TokenGui = TextObject:FindFirstChild(CurrentLabel) or TokenPool:Get()
						TokenGui.Name			= CurrentLabel
						TokenGui.LayoutOrder	= CurrentLabel
						TokenGui.Text			= LineSrc
						TokenGui.TextSize		= TextSize
						TokenGui.Size			= UDim2.new(0,TextSizeX*#LineSrc,0,TextSize)
						TokenGui.Position		= UDim2.new(0,CurrentDepth*TextSizeX,0,LineHeight*(CurrentLine-1))
						
						local Color = self.TokenToColor[token] or self.TokenToColor.operator
						if TokenGui.TextColor3 ~= Color then
							TokenGui.TextColor3	= Color
						end
					
					TokenGui.Parent = TextObject
				end
				
				-- Push the depth by the length of what we've just processed
				CurrentDepth = CurrentDepth + #LineSrc
			end
			
		end
		
	end
	
	-- Clear unused old tokens
	for i = CurrentLex+1, #LastLex do
		LastLex[i] = nil
	end
	
	-- Clear unused old labels
	for _,t in ipairs(TextObject:GetChildren()) do
		if t.LayoutOrder>CurrentLabel then
			TokenPool:Return(t)
		end
	end
	
	
	self.Busy[TextObject] = nil
end

function Module:ContinuousHighlight(TextObject)
	
	--Initial
	Module:Highlight(TextObject)
	
	-- Dynamic
	TextObject:GetPropertyChangedSignal("Text"):Connect(function()
		Module:Highlight(TextObject)
	end)
	
end

function Module:ClearCache(TextObject)
	
	-- This function is mostly used for debugging, but also used when you're
	-- setting your TextObject to a new content and want a clean slate for it
	
	if self.Busy[TextObject] then
		for i=1,50 do
			RS.Heartbeat:Wait()
			if not self.Busy[TextObject] then
				break
			end
		end
	end
	
	self.Busy[TextObject] = true
	
	self.LastLex[TextObject] = {}
	-- Clear old tokens
	for _,t in ipairs(TextObject:GetChildren()) do
		TokenPool:Return(t)
	end
	
	self.Busy[TextObject] = false
end

function Module:ReloadColors(TextObject)
	
	Theme = settings().Studio.Theme
	ScriptColors = {
		Number = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptNumber);
		String = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptString);
		Comment = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptComment);
		Text = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptText);
		Keyword = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptKeyword);
		Builtin = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptBuiltInFunction);
		Operator = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptOperator);
		Background = Theme:GetColor(Enum.StudioStyleGuideColor.ScriptBackground);
	}
	
	Module.TokenToColor	= {
		['number']		= ScriptColors.Number;
		['string']		= ScriptColors.String;
		['comment']		= ScriptColors.Comment;
		['iden']		= ScriptColors.Text;
		['keyword']		= ScriptColors.Keyword;
		['builtin']		= ScriptColors.Builtin;
		['operator']	= ScriptColors.Operator;
	};
	Module.ColorToToken	= {
		[tostring(ScriptColors.Number)]		= 'number';
		[tostring(ScriptColors.String)]		= 'string';
		[tostring(ScriptColors.Comment)]	= 'comment';
		[tostring(ScriptColors.Text)]		= 'iden';
		[tostring(ScriptColors.Keyword)]	= 'keyword';
		[tostring(ScriptColors.Builtin)]	= 'builtin';
		[tostring(ScriptColors.Operator)]	= 'operator';
	};
	
	TextObject.BackgroundColor3 = ScriptColors.Background
	
	for i,c in ipairs(TextObject:GetChildren()) do
		c.TextColor3 = Module.TokenToColor[Module.ColorToToken[tostring(c.TextColor3)]] or Module.TokenToColor.iden
	end
	
end

return Module