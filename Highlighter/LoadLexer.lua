
local dependencies = {
    "Highlighter/ObjectPool.lua",
    "Highlighter/lexer.lua",
}

local Repository = "https://raw.githubusercontent.com/slf0Dev/InternalExecutor/refs/heads/master/"

local root = Instance.new("ModuleScript")
root.Parent = workspace
root.Name = "IDE_Stripped"

local main = Instance.new("ModuleScript")
main.Name = "HighlighterModule"
main.Parent = root

for i,v in next, dependencies do
    local name = v:split("/")[2]
    local Dependency = Instance.new("ModuleScript")
    Dependency.Source = game:HttpGet(Repository..v)
    Dependency.Name = name:split(".")[1]
    Dependency.Parent = main
end

main.Parent = root
main.Source = game:HttpGet(Repository.."Highlighter/HighlighterModule.lua")

root.Source = game:HttpGet(Repository.."Highlighter/IDE_STRIPPED.lua")

task.wait(0.1)

local Highlighter = loadstring(root.Source)()
print('success')
