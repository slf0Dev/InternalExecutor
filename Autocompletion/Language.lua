local language = {

	keyword = {
		["and"] = "and ",
		["break"] = "break",
		["continue"] = "continue",
		["do"] = "do\n\t|\nend",
		["else"] = "else\n\t|",
		["elseif"] = "elseif | then\n\t|",
		["end"] = "end",
		["export"] = "export |",
		["false"] = "false",
		["for"] = "for i, v in ipairs() do\n\t|\nend",
		["function"] = "function name()\n\t|\nend",
		["if"] = "if | then\n\t|\nend",
		["in"] = "in ",
		["local"] = "local |",
		["nil"] = "nil",
		["not"] = "not ",
		["or"] = "or ",
		["repeat"] = "repeat\n\t|\nuntil |",
		["return"] = "return |",
		["self"] = "self",
		["then"] = "then\n\t|",
		["true"] = "true",
		["type"] = "type ",
		["typeof"] = "typeof ",
		["until"] = "until ",
		["while"] = "while | do\n\t|\nend",
	},

	builtin = {
		-- Luau Functions
		["assert"] = "assert(|)",
		["error"] = "error(|)",
		["getfenv"] = "getfenv(|)",
		["getmetatable"] = "getmetatable(|)",
		["ipairs"] = "ipairs(|)",
		["loadstring"] = "loadstring(|)",
		["newproxy"] = "newproxy(|)",
		["next"] = "next(|)",
		["pairs"] = "pairs(|)",
		["pcall"] = "pcall(|)",
		["print"] = "print(|)",
		["rawequal"] = "rawequal(|)",
		["rawget"] = "rawget(|)",
		["rawlen"] = "rawlen(|)",
		["rawset"] = "rawset(|)",
		["select"] = "select(|)",
		["setfenv"] = "setfenv(|)",
		["setmetatable"] = "setmetatable(|)",
		["tonumber"] = "tonumber(|)",
		["tostring"] = "tostring(|)",
		["unpack"] = "unpack(|)",
		["xpcall"] = "xpcall(|)",
		-- Luau Functions (Deprecated)
		["collectgarbage"] = "collectgarbage(|)",
		-- Luau Variables
		["_G"] = "_G",
		["_VERSION"] = "_VERSION",
		-- Luau Tables
		["bit32"] = "bit32",
		["buffer"] = "buffer",
		["coroutine"] = "coroutine",
		["debug"] = "debug",
		["math"] = "math",
		["os"] = "os",
		["string"] = "string",
		["table"] = "table",
		["utf8"] = "utf8",
		["vector"] = "vector",
		-- Roblox Functions
		["DebuggerManager"] = "DebuggerManager",
		["delay"] = "delay(|)",
		["gcinfo"] = "gcinfo()",
		["PluginManager"] = "PluginManager",
		["require"] = "require(|)",
		["settings"] = "settings",
		["spawn"] = "spawn(|)",
		["tick"] = "tick()",
		["time"] = "time()",
		["UserSettings"] = "UserSettings",
		["wait"] = "wait(|)",
		["warn"] = "warn(|)",
		-- Roblox Functions (Deprecated)
		["Delay"] = "Delay(|)",
		["ElapsedTime"] = "ElapsedTime()",
		["elapsedTime"] = "elapsedTime()",
		["printidentity"] = "printidentity()",
		["Spawn"] = "Spawn(|)",
		["Stats"] = "Stats",
		["stats"] = "stats",
		["Version"] = "Version",
		["version"] = "version",
		["Wait"] = "Wait(|)",
		["ypcall"] = "ypcall(|)",
		-- Roblox Variables
		["game"] = "game",
		["plugin"] = "plugin",
		["script"] = "script",
		["shared"] = "shared",
		["workspace"] = "workspace",
		-- Roblox Variables (Deprecated)
		["Game"] = "Game",
		["Workspace"] = "Workspace",
		-- Roblox Tables
		["Axes"] = "Axes",
		["BrickColor"] = "BrickColor",
		["CatalogSearchParams"] = "CatalogSearchParams",
		["CFrame"] = "CFrame",
		["Color3"] = "Color3",
		["ColorSequence"] = "ColorSequence",
		["ColorSequenceKeypoint"] = "ColorSequenceKeypoint",
		["DateTime"] = "DateTime",
		["DockWidgetPluginGuiInfo"] = "DockWidgetPluginGuiInfo",
		["Enum"] = "Enum",
		["Faces"] = "Faces",
		["FloatCurveKey"] = "FloatCurveKey",
		["Font"] = "Font",
		["Instance"] = "Instance",
		["NumberRange"] = "NumberRange",
		["NumberSequence"] = "NumberSequence",
		["NumberSequenceKeypoint"] = "NumberSequenceKeypoint",
		["OverlapParams"] = "OverlapParams",
		["PathWaypoint"] = "PathWaypoint",
		["PhysicalProperties"] = "PhysicalProperties",
		["Random"] = "Random",
		["Ray"] = "Ray",
		["RaycastParams"] = "RaycastParams",
		["Rect"] = "Rect",
		["Region3"] = "Region3",
		["Region3int16"] = "Region3int16",
		["RotationCurveKey"] = "RotationCurveKey",
		["SharedTable"] = "SharedTable",
		["task"] = "task",
		["TweenInfo"] = "TweenInfo",
		["UDim"] = "UDim",
		["UDim2"] = "UDim2",
		["Vector2"] = "Vector2",
		["Vector2int16"] = "Vector2int16",
		["Vector3"] = "Vector3",
		["Vector3int16"] = "Vector3int16",
	},

	libraries = {
		-- Luau Libraries
		bit32 = {
			arshift = "bit32.arshift(|)",
			band = "bit32.band(|)",
			bnot = "bit32.bnot(|)",
			bor = "bit32.bor(|)",
			btest = "bit32.btest(|)",
			bxor = "bit32.bxor(|)",
			countlz = "bit32.countlz(|)",
			countrz = "bit32.countrz(|)",
			extract = "bit32.extract(|)",
			lrotate = "bit32.lrotate(|)",
			lshift = "bit32.lshift(|)",
			replace = "bit32.replace(|)",
			rrotate = "bit32.rrotate(|)",
			rshift = "bit32.rshift(|)",
		},

		buffer = {
			copy = "buffer.copy(|)",
			create = "buffer.create(|)",
			fill = "buffer.fill(|)",
			fromstring = "buffer.fromstring(|)",
			len = "buffer.len(|)",
			readf32 = "buffer.readf32(|)",
			readf64 = "buffer.readf64(|)",
			readi8 = "buffer.readi8(|)",
			readi16 = "buffer.readi16(|)",
			readi32 = "buffer.readi32(|)",
			readu16 = "buffer.readu16(|)",
			readu32 = "buffer.readu32(|)",
			readu8 = "buffer.readu8(|)",
			readstring = "buffer.readstring(|)",
			tostring = "buffer.tostring(|)",
			writef32 = "buffer.writef32(|)",
			writef64 = "buffer.writef64(|)",
			writei16 = "buffer.writei16(|)",
			writei32 = "buffer.writei32(|)",
			writei8 = "buffer.writei8(|)",
			writestring = "buffer.writestring(|)",
			writeu16 = "buffer.writeu16(|)",
			writeu32 = "buffer.writeu32(|)",
			writeu8 = "buffer.writeu8(|)",
		},

		coroutine = {
			close = "coroutine.close(|)",
			create = "coroutine.create(|)",
			isyieldable = "coroutine.isyieldable()",
			resume = "coroutine.resume(|)",
			running = "coroutine.running()",
			status = "coroutine.status(|)",
			wrap = "coroutine.wrap(|)",
			yield = "coroutine.yield(|)",
		},

		debug = {
			dumpheap = "debug.dumpheap()",
			getmemorycategory = "debug.getmemorycategory(|)",
			info = "debug.info(|)",
			loadmodule = "debug.loadmodule(|)",
			profilebegin = "debug.profilebegin(|)",
			profileend = "debug.profileend()",
			resetmemorycategory = "debug.resetmemorycategory(|)",
			setmemorycategory = "debug.setmemorycategory(|)",
			traceback = "debug.traceback(|)",
		},

		math = {
			abs = "math.abs(|)",
			acos = "math.acos(|)",
			asin = "math.asin(|)",
			atan2 = "math.atan2(|)",
			atan = "math.atan(|)",
			ceil = "math.ceil(|)",
			clamp = "math.clamp(|)",
			cos = "math.cos(|)",
			cosh = "math.cosh(|)",
			deg = "math.deg(|)",
			exp = "math.exp(|)",
			floor = "math.floor(|)",
			fmod = "math.fmod(|)",
			frexp = "math.frexp(|)",
			ldexp = "math.ldexp(|)",
			log10 = "math.log10(|)",
			log = "math.log(|)",
			max = "math.max(|)",
			min = "math.min(|)",
			modf = "math.modf(|)",
			noise = "math.noise(|)",
			pow = "math.pow(|)",
			rad = "math.rad(|)",
			random = "math.random()",
			randomseed = "math.randomseed(|)",
			round = "math.round(|)",
			sign = "math.sign(|)",
			sin = "math.sin(|)",
			sinh = "math.sinh(|)",
			sqrt = "math.sqrt(|)",
			tan = "math.tan(|)",
			tanh = "math.tanh(|)",
			huge = "math.huge",
			pi = "math.pi",
		},

		os = {
			clock = "os.clock()",
			date = "os.date()",
			difftime = "os.difftime(|)",
			time = "os.time()",
		},

		string = {
			byte = "string.byte(|)",
			char = "string.char(|)",
			find = "string.find(|)",
			format = "string.format(|)",
			gmatch = "string.gmatch(|)",
			gsub = "string.gsub(|)",
			len = "string.len(|)",
			lower = "string.lower(|)",
			match = "string.match(|)",
			pack = "string.pack(|)",
			packsize = "string.packsize(|)",
			rep = "string.rep(|)",
			reverse = "string.reverse(|)",
			split = "string.split(|)",
			sub = "string.sub(|)",
			unpack = "string.unpack(|)",
			upper = "string.upper(|)",
		},

		table = {
			clear = "table.clear(|)",
			clone = "table.clone(|)",
			concat = "table.concat(|)",
			create = "table.create(|)",
			find = "table.find(|)",
			foreach = "table.foreach(|)",
			foreachi = "table.foreachi(|)",
			freeze = "table.freeze(|)",
			getn = "table.getn(|)",
			insert = "table.insert(|)",
			isfrozen = "table.isfrozen(|)",
			maxn = "table.maxn(|)",
			move = "table.move(|)",
			pack = "table.pack(|)",
			remove = "table.remove(|)",
			sort = "table.sort(|)",
			unpack = "table.unpack(|)",
		},

		utf8 = {
			char = "utf8.char(|)",
			codepoint = "utf8.codepoint(|)",
			codes = "utf8.codes(|)",
			graphemes = "utf8.graphemes(|)",
			len = "utf8.len(|)",
			nfcnormalize = "utf8.nfcnormalize(|)",
			nfdnormalize = "utf8.nfdnormalize(|)",
			offset = "utf8.offset(|)",
			charpattern = "utf8.charpattern",
		},

		vector = {
			abs = "vector.abs(|)",
			angle = "vector.angle(|)",
			ceil = "vector.ceil(|)",
			clamp = "vector.clamp(|)",
			create = "vector.create(|)",
			cross = "vector.cross(|)",
			dot = "vector.dot(|)",
			floor = "vector.floor(|)",
			magnitude = "vector.magnitude(|)",
			max = "vector.max(|)",
			min = "vector.min(|)",
			normalize = "vector.normalize(|)",
			sign = "vector.sign(|)",
			one = "vector.one",
			zero = "vector.zero",
		},

		-- Roblox Libraries
		Axes = {
			new = "Axes.new(|)",
		},

		BrickColor = {
			Black = "BrickColor.Black()",
			Blue = "BrickColor.Blue()",
			DarkGray = "BrickColor.DarkGray()",
			Gray = "BrickColor.Gray()",
			Green = "BrickColor.Green()",
			new = "BrickColor.new(|)",
			New = "BrickColor.New(|)",
			palette = "BrickColor.palette(|)",
			Random = "BrickColor.Random()",
			random = "BrickColor.random()",
			Red = "BrickColor.Red()",
			White = "BrickColor.White()",
			Yellow = "BrickColor.Yellow()",
		},

		CatalogSearchParams = {
			new = "CatalogSearchParams.new()",
		},

		CFrame = {
			Angles = "CFrame.Angles(|)",
			fromAxisAngle = "CFrame.fromAxisAngle(|)",
			fromEulerAngles = "CFrame.fromEulerAngles(|)",
			fromEulerAnglesXYZ = "CFrame.fromEulerAnglesXYZ(|)",
			fromEulerAnglesYXZ = "CFrame.fromEulerAnglesYXZ(|)",
			fromMatrix = "CFrame.fromMatrix(|)",
			fromOrientation = "CFrame.fromOrientation(|)",
			lookAt = "CFrame.lookAt(|)",
			new = "CFrame.new(|)",
			identity = "CFrame.identity",
		},

		Color3 = {
			fromHex = "Color3.fromHex(|)",
			fromHSV = "Color3.fromHSV(|)",
			fromRGB = "Color3.fromRGB(|)",
			new = "Color3.new(|)",
			toHSV = "Color3.toHSV(|)",
		},

		ColorSequence = {
			new = "ColorSequence.new(|)",
		},

		ColorSequenceKeypoint = {
			new = "ColorSequenceKeypoint.new(|)",
		},

		DateTime = {
			fromIsoDate = "DateTime.fromIsoDate(|)",
			fromLocalTime = "DateTime.fromLocalTime(|)",
			fromUniversalTime = "DateTime.fromUniversalTime(|)",
			fromUnixTimestamp = "DateTime.fromUnixTimestamp(|)",
			fromUnixTimestampMillis = "DateTime.fromUnixTimestampMillis(|)",
			now = "DateTime.now()",
		},

		DockWidgetPluginGuiInfo = {
			new = "DockWidgetPluginGuiInfo.new(|)",
		},

		Enum = {},

		Faces = {
			new = "Faces.new(|)",
		},

		FloatCurveKey = {
			new = "FloatCurveKey.new(|)",
		},

		Font = {
			fromEnum = "Font.fromEnum(|)",
			fromId = "Font.fromId(|)",
			fromName = "Font.fromName(|)",
			new = "Font.new(|)",
		},

		Instance = {
			new = "Instance.new(|)",
		},

		NumberRange = {
			new = "NumberRange.new(|)",
		},

		NumberSequence = {
			new = "NumberSequence.new(|)",
		},

		NumberSequenceKeypoint = {
			new = "NumberSequenceKeypoint.new(|)",
		},

		OverlapParams = {
			new = "OverlapParams.new()",
		},

		PathWaypoint = {
			new = "PathWaypoint.new(|)",
		},

		PhysicalProperties = {
			new = "PhysicalProperties.new(|)",
		},

		Random = {
			new = "Random.new(|)",
		},

		Ray = {
			new = "Ray.new(|)",
		},

		RaycastParams = {
			new = "RaycastParams.new()",
		},

		Rect = {
			new = "Rect.new(|)",
		},

		Region3 = {
			new = "Region3.new(|)",
		},

		Region3int16 = {
			new = "Region3int16.new(|)",
		},

		RotationCurveKey = {
			new = "RotationCurveKey.new(|)",
		},

		SharedTable = {
			clear = "SharedTable.clear(|)",
			clone = "SharedTable.clone(|)",
			cloneAndFreeze = "SharedTable.cloneAndFreeze(|)",
			increment = "SharedTable.increment(|)",
			isFrozen = "SharedTable.isFrozen(|)",
			new = "SharedTable.new()",
			size = "SharedTable.size(|)",
			update = "SharedTable.update(|)",
		},

		task = {
			cancel = "task.cancel(|)",
			defer = "task.defer(|)",
			delay = "task.delay(|)",
			desynchronize = "task.desynchronize()",
			spawn = "task.spawn(|)",
			synchronize = "task.synchronize()",
			wait = "task.wait()",
		},

		TweenInfo = {
			new = "TweenInfo.new(|)",
		},

		UDim = {
			new = "UDim.new(|)",
		},

		UDim2 = {
			fromOffset = "UDim2.fromOffset(|)",
			fromScale = "UDim2.fromScale(|)",
			new = "UDim2.new(|)",
		},

		Vector2 = {
			new = "Vector2.new(|)",
			one = "Vector2.one",
			xAxis = "Vector2.xAxis",
			yAxis = "Vector2.yAxis",
			zero = "Vector2.zero",
		},

		Vector2int16 = {
			new = "Vector2int16.new(|)",
		},

		Vector3 = {
			fromAxis = "Vector3.fromAxis(|)",
			FromAxis = "Vector3.FromAxis(|)",
			fromNormalId = "Vector3.fromNormalId(|)",
			FromNormalId = "Vector3.FromNormalId(|)",
			new = "Vector3.new(|)",
			one = "Vector3.one",
			xAxis = "Vector3.xAxis",
			yAxis = "Vector3.yAxis",
			zAxis = "Vector3.zAxis",
			zero = "Vector3.zero",
		},

		Vector3int16 = {
			new = "Vector3int16.new(|)",
		},
	},
}

local enumLibraryTable = language.libraries.Enum
for _, enum in ipairs(Enum:GetEnums()) do
	enumLibraryTable[tostring(enum)] = "Enum." .. tostring(enum)
end

return language
