--[[
	these are extra modulescripts which can be loaded into the main script as commands
	
	here's what the setup should look like:
	
	+main.lua
	-+model/accoutrement/whatever named "modules"
	--+examplemodule.lua
	--+examplemodule2.lua
	--+examplemodule3.lua

	modules should return a table of two items, item one being the command and item two being the function, like this:
	
	return{"command",function(arguments) pcall(function() end)
]]