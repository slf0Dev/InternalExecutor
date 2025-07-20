
local dependencies = {
    "Highlighter/types.lua",
    "Highlighter/theme.lua",
    "Highlighter/utility.lua",
}

local Repository = "https://raw.githubusercontent.com/slf0Dev/InternalExecutor/refs/heads/master/"

local root = Instance.new("ModuleScript")
root.Name = "Highlighter"

for i,v in next, dependencies do
    local name = v:split("/")[2]
    local Dependency = Instance.new("ModuleScript")
    Dependency.Source = game:HttpGet(Repository..v)
    Dependency.Name = name:split(".")[1]
    Dependency.Parent = root
end

local lexer = Instance.new("ModuleScript")
lexer.Name = "lexer"
lexer.Source = game:HttpGet(Repository.."Highlighter/lexer.lua")
lexer.Parent = root


local language = Instance.new("ModuleScript")
language.Name = "language"
language.Source = game:HttpGet(Repository.."Highlighter/language.lua")
language.Parent = lexer

root.Parent = workspace
root.Source = game:HttpGet(Repository.."Highlighter/init.lua")


local hightlighter = require(root)