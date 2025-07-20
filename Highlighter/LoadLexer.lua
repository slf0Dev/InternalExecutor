local dependencies = {
	"Highlighter/lexer/init.lua",
	"Highlighter/init.lua",
}
local Repository = "https://raw.githubusercontent.com/slf0Dev/InternalExecutor/refs/heads/master/"

local root = Instance.new("ModuleScript")
root.Name = "Highlighter"

for i,v in next, dependencies do
	local Dependency = Instance.new("ModuleScript")
	Dependency.Source = game:HttpGet(Repository..v)
	Dependency.Parent = root
end

root.Source = game:HttpGet(Repository.."Highlighter/init.lua")

return root