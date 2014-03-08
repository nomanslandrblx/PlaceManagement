--==========configuration

-- local adminnames = {"PlusReed", "Oozlebachr", "Enfys", "CoffeeScripter"}
local adminids = {13135356, 4353611, 36305601, 6110966, -1} -- -1 for testing
--local bannednames = {"NowDoTheHarlemShake"}
local bannedids = {38506985}
local bannedips = {}

local autokick = true -- can be used to write custom ban handlers [CS]

--automatically admin best friends or friends (if they aren't banned)
local adminbffs = true
local adminfriends = false

--[[
	==========table of contents==========
	
	-1. configuration
	
	0. table of contents	
	
	1. variables
	
	2. admin commands
	
	3. datastore and http functions
	
	4. command processing cunctions
	
	5. initial setup
	
	6. gui manager function
	
	7. ready
	
	8. api (?)
]]

--==========variables

--merged config because it was a little annoying to keep it separate
--local conf = require(script.config)
--local adminids,bannedids,autokick,adminbffs,adminfriends,usedatastore = conf[1],conf[2],conf[3],conf[4],conf[5],conf[6]

local PPM = {}

--libraries
local rbxutil = assert(LoadLibrary("RbxUtility"))

--services
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()
local httpservice = game:GetService('HttpService')
local players = game:GetService("Players")

--instances
local persistentadmins = script:findFirstChild("padmins")
local persistentbanned = script:findFirstChild("pbanned")
local guibase = script:findFirstChild("PlaceManagementGui")

--constants
local numorigcommands
local creatorid = game.CreatorId
local runcommand = "!" --to use a single argument, use this symbol twice. ex: "!" -> "!!command"
local viewcommanddocumentation = "?" --use this symbol twice to view all available commands
local divider = " "
local tips = {
	'Be careful when using Free Models!',
	'Be prepared for exploiters!',
	'Assign Lua library functions to local variables to improve script execution speeds!',
	'Is something not working like it should, but works fine in solo mode? Try Start Player mode!',
	'Use Spawn() and Delay() functions to allow a script to proceed while waiting for HTTP data if necessary!',
	"Remember to add documentation for your code so it's easy to understand if you ever need to go back and fix things!",
	'Use ModuleScripts to easily manage code that appears in many scripts!',
	'Using enums to change properties will help your code run faster than using strings!',
	"Sometimes, it's better to do extra work up front so it's easy to change things later!"
}

--logging
local logs = {}

--==========admin commands

--these are the commands
--i included one just for reference and stuff, you can either add commands directly to this table or use the module system ~oozle
local commands = {
	{"helloworld",
		function()
			print("hello world")
		end,
		"hello, world !!\n\nthank you for choosing placemanagement! :)\n\nthis is a placeholder command"
	}
	,
	{"doexec",
		function(arg)
			assert(loadstring(arg))()
		end,
		"==========doexec by oozlebachr\n\ndoexec is a core command that can be used for reference or testing.\n\ndoexec runs a single argument through loadstring.\n\nex !!doexec print('hello world')"
	}
	,
	{"givegui",
		function(player)
			local p = game.Players:findFirstChild(player)
			if p then
				setupgui(p)
			else
				print("player "..player.." not found")
			end
		end,
		"==========givegui by oozlebachr\n\ngive the place management frontend gui to a specified player"
	}
}

--save original command count
numorigcommands = #commands

--load module commands
if script:findFirstChild("modules") then
	for i,v in ipairs(script.modules:GetChildren()) do
		--local module = require(v)
		--commands[module[1]] = module[2]
		--switching to nested tables to make room for documentation ~oozle
		table.insert(commands,require(v))
	end
end

--==========datastore and http functions

function datastorewrite(module_, key, value)
	globaldatastore:WriteAsync('PPM_' .. module_ .. '_' .. key, value)
end

function datastoreget(module_, key)
	globaldatastore:GetAsync('PPM_' .. module_ .. '_' .. key)
end

--==========comomand processing functions

--check if value [value] exists in table [t]
--if [short], shorten values in the table to the length of the provided value and then check
--ex print(checkifintable(adminids,4353611)
function checkifintable(t,value,short)
	for i,v in ipairs(t) do
		if (short and string.sub(v,1,string.len(value)) == value) or v == value then
			return v
		end
	end
end

--remove value [value] from table [t]
--if [short], shorten values in the table to the length of provided value and then check
--ex removefromtable(adminids,4353611) print(checkifintable(adminids,4353611)
function removefromtable(t,value,short)
	for i,v in ipairs(t) do
		if (short and string.sub(v,1,string.len(value)) == value) or v == value then
			table.remove(t,i)
			return --only remove first result
		end
	end
end

--splits the string [str] by divider [div] and returns a table of the results
--currently only supports single character dividers
--ex for i,v in ipairs(split("enfys is a noob"," ")) do print(v) end
--maybe use this for commands (!kill enfys -> split returns !kill, enfys -> pass enfys as argument to function kill) ~oozle
function split(str,div)
	local results = {}
	local currentresult = ""
	for i=1,string.len(str) do
		local current = string.sub(str,i,i)
		if current:match(div) then
			table.insert(results,currentresult)
			currentresult = ""
		else
			currentresult = currentresult..current
		end
	end
	table.insert(results,currentresult)
	return results
end

--find the given command [command] and returns it
--ex findcommand("doprint")("hello world")
function findcommand(command)
	for i,v in ipairs(commands) do
		if v[1] == command then
			return v
		end
	end
end

--returns a random string key which can be used to authenticate external commands
--ex print(genrandomkey())
--external command system isn't ready yet ~oozle
local validchars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
function genrandomkey(segments,segmentlength)
	if not segments then
		segments = 6 --default 6
	end
	if not segmentlength then
		segmentlength = 3 --default 3
	end
	local key = {}
	for i=1,segments do
		local segment = ""
		for i=1,segmentlength do
			local char = math.random(1,string.len(validchars))
			segment = segment..string.sub(validchars,char,char)
		end
		table.insert(key,segment)
	end
	return table.concat(key,":")
end

--main function to run commands, processes the string [str] and prints the string [source]
--processing: check if command -> split -> find function -> concat arguments -> run function and pass arguments
--ex processcommand("!doprint hello world")
--to use only one argument, use "!!"
--ex processcommand("!!doprint hello world")
--to view module documentation, use "?"
--ex processcommand("?doprint")
function processcommand(str,source)
	local header = string.sub(str,1,1)
	if header == runcommand then --check if it's actually a command
		
		local logged = (source or "undefined source")..": "..str
		table.insert(logs,logged) --log the command
		print(logged) --print the command
		
		if string.sub(str,2,2) == runcommand then --only use one argument
			
			command = ""
			local stop
			for i=1,string.len(str) do
				local char = string.sub(str,i,i)
				if char ~= runcommand then
					if char == divider then
						break
					else
						command = command..char
					end
				end
				stop = i
			end
			local argument = string.sub(str,stop+2,string.len(str))
			--commands[command](argument)
			--switching to nested tables to make room for documentation
			if findcommand(command) then
				findcommand(command)[2](argument)
			else
				print([["]]..command..[[" is not a valid command]])
			end
			
		else --use multiple arguments
			
			--split string into its constituent items
			local items = split(str,divider)		
			--find the command
			command = items[1]
			command = string.sub(command,2,string.len(command))
			if findcommand(command) and findcommand(command)[2] then
				command = findcommand(command)[2]
				table.remove(items,1)
				--concatenate arguments into "arg1, arg2, arg3, arg#" etc
				local arguments = ""
				for _,arg in ipairs(items) do
					arguments = arguments..[["]]..arg..[[",]]
				end
				--assemble the parts
				local arguments = "("..string.sub(arguments,1,string.len(arguments)-1)..")"
				--loadstring it
				--local func = assert(loadstring("command"..arguments))
				--switching to nested tables to make room for documentation
				local func = assert(loadstring("command"..arguments))
				--run it
				func()
			else
				print([["]]..string.sub(items[1],2,string.len(items[1]))..[[" is not a valid command]])
			end
			
		end
		
	elseif header == viewcommanddocumentation then --display info
		
		if string.sub(str,2,2) == viewcommanddocumentation then --display all commands
	
			local corecommands = {}
			local modulecommands = {}
			for i,v in ipairs(commands) do
				if i <= numorigcommands then
					table.insert(corecommands,v[1])
				else
					table.insert(modulecommands,v[1])
				end
			end
			print("core commands:\n"..table.concat(corecommands,", ").."\nmodule commands:\n"..table.concat(modulecommands,", "))
		
		else --display info for given command
		
			local command = string.sub(str,2,string.len(str))
			if findcommand(command) then
				local doc = findcommand(command)[3]
				if doc then
					--well i guess just print for now
					print([[documentation for "]]..command..[[": ]].."\n\n"..doc)
				else
					print([["]]..command..[[" is a valid command but has no documentation]])
				end
			else
				print([["]]..command..[[" is not a valid command]])
			end
			
		end
	end
end

--==========initial setup

--set up persistent admin and banned user tables as jsons in stringvalues if needed (for use in pbs)
if not persistentadmins then
	persistentadmins = Instance.new("StringValue",script)
	persistentadmins.Name = "padmins"
end
if not persistentbanned then
	persistentbanned = Instance.new("StringValue",script)
	persistentbanned.Name = "pbanned"
end

--decode and merge persistent admin and banned user tables (all values should be userids)
pcall(function()
	if persistentadmins.Value then
		for _,id in ipairs(rbxutil.DecodeJSON(persistentadmins.Value)) do
			if not checkifintable(adminids,id) then --stop redundancy
				table.insert(adminids,id)
			end
		end
	end
	if persistentbanned.Value then
		for _,id in ipairs(rbxutil.DecodeJSON(persistentbanned.Value)) do
			if not checkifintable(bannedids,id) then --stop redundancy
				table.insert(admins,id)
			end
		end
	end
end)

--==========gui manager function

--function to set up and manage a gui for a given player
--gui autoconfigures itself and stuff. enjoy !! ~oozle :)
function setupgui()
	print("error:\nno gui base found\nneeds a copy of http://www.roblox.com/--item?id=148812527 present inside the script to use the management gui")
end
if guibase then
	setupgui = function(player)
		if player and not player.PlayerGui:findFirstChild("PlaceManagementGui") then
			Spawn(function()
				
				--variables
				local gui = guibase:clone()
				gui.Parent = player.PlayerGui
				gui = gui.Main --variable reusing yay :)
				local selectionframe = gui.SelectionArea.SelectionFrame
				local commandframe = selectionframe.CommandFrame
				local descriptionframe = gui.SelectionArea.DescriptionFrame
				
				local descriptionscroll = 0
				local descriptionscrollspeed = 10
				local descriptionscrollmax = 980-descriptionscrollspeed
				
				local commandscroll = 0
				local commandscrollspeed = 20
				local commandscrollmax = 20*(#commands-1)
				
				local resizing = false
				local minx = 200
				local miny = 150
				
				local commandmode = 1 --1 = !; 2 = !!
				local currentcommand = nil
				
				--new instances
				local commandbuttonbase = commandframe.CommandButton:clone()
				commandframe.CommandButton:Destroy()
				
				
				--==========precursor functions
				
				function updatecommandscrolling()
					if commandscroll < 0 then --too far up
						commandscroll = 0
					elseif commandscroll > commandscrollmax then --too far down
						commandscroll = commandscrollmax
					else
						commandframe.Position = UDim2.new(0,0,0,-commandscroll)
					end
				end
				
				function updatedescriptionscrolling()
					if descriptionscroll < 0 then --too far up
						descriptionscroll = 0
					elseif descriptionscroll > descriptionscrollmax then --too far down
						descriptionscroll = descriptionscrollmax
					else
						descriptionframe.Description.Position = UDim2.new(0,0,0,-descriptionscroll)
					end
				end
				
				function updatedescription()
					if currentcommand then
						local command = currentcommand[1]
						local doc = currentcommand[3]
						if doc then --display documentation
							descriptionframe.Description.Text = [[Documentation for "]]..command..[[": ]].."\n\n"..doc
						else
							descriptionframe.Description.Text = [["]]..command..[[" has no documentation. Sorry!]]
						end
						descriptionscroll = 0 --reset scrolling
						updatedescriptionscrolling()
					else
						descriptionframe.Description.Text = "No command selected.\n\nClick a command above to view documentation and/or use it!\n\nYou can scroll using the up and down arrows at the right."
					end
				end
				
				--==========set up gui
				
				--generate a button for each command
				for i,command in ipairs(commands) do
					local newbutton = commandbuttonbase:clone()
					newbutton.Parent = commandframe
					newbutton.Text = i.." "..command[1]
					newbutton.Position = UDim2.new(0,0,0,20*(i-1))
					if i%2 == 1 then --help distinguish between the buttons
						newbutton.BackgroundTransparency = newbutton.BackgroundTransparency - 0.1
					end
					newbutton.MouseButton1Down:connect(function()
						currentcommand = command
						for i,v in ipairs(commandframe:GetChildren()) do --make everything green
							v.BackgroundColor3 = BrickColor.new("Bright green").Color
						end
						newbutton.BackgroundColor3 = BrickColor.new("Br. yellowish green").Color --make this diff color
						updatedescription()
					end)
				end
				
				--display blank description
				updatedescription()
				
				--==========ready
				
				--connect to command scrolling
				selectionframe.ScrollDownButton.MouseButton1Down:connect(function()
					commandscroll = commandscroll + commandscrollspeed
					updatecommandscrolling()
				end)
				selectionframe.ScrollUpButton.MouseButton1Down:connect(function()
					commandscroll = commandscroll - commandscrollspeed
					updatecommandscrolling()
				end)
				
				--connect to description scrolling
				descriptionframe.ScrollDownButton.MouseButton1Down:connect(function()
					descriptionscroll = descriptionscroll + descriptionscrollspeed
					updatedescriptionscrolling()
				end)
				descriptionframe.ScrollUpButton.MouseButton1Down:connect(function()
					descriptionscroll = descriptionscroll - descriptionscrollspeed
					updatedescriptionscrolling()
				end)
				
				--connect to mode changing
				gui.CommandModeButton.MouseButton1Down:connect(function()
					commandmode = (commandmode%2)+1
					if commandmode == 1 then
						gui.CommandModeButton.Text = "Current input mode: [!] Multiple arguments separated by spaces (click to change)"
					else
						gui.CommandModeButton.Text = "Current input mode: [!!] Single argument (click to change)"
					end
				end)
				
				--connect to the input button and process the commands
				gui.InputButton.MouseButton1Down:connect(function()
					if currentcommand then
						local prefix = ""
						if commandmode == 1 then
							prefix = "!"
						else
							prefix = "!!"
						end
						print(prefix..currentcommand[1].." "..gui.InputField.Text)
						processcommand(prefix..currentcommand[1].." "..gui.InputField.Text,player.Name.."'s frontend gui")
					end
				end)
				
				--resizing
				gui.ResizeButton.MouseButton1Down:connect(function()
					resizing = true
				end)
				gui.ResizeButton.MouseLeave:connect(function()
					resizing = false
				end)
				gui.ResizeButton.MouseButton1Up:connect(function()
					resizing = false
				end)
				gui.ResizeButton.MouseMoved:connect(function(x,y)
					if resizing then
						
						--center mouse
						x = x+(gui.ResizeButton.AbsoluteSize.X/4)
						y = y+(gui.ResizeButton.AbsoluteSize.Y/4)
						
						--limit horizontal
						if gui.AbsoluteSize.X < minx then
							x = nil
						else
							x = x-gui.AbsolutePosition.X
						end
						
						--limit vertical
						if gui.AbsoluteSize.Y < miny then
							y = nil
						else
							y = y-gui.AbsolutePosition.Y
						end
						
						--resize
						gui.Size = UDim2.new(0,(x or gui.AbsoluteSize.X),0,(y or gui.AbsoluteSize.Y))
						
					end
				end)
				
				print("ready setting up gui for "..player.Name)			
				
			end)
		else
			print("player "..player.Name.." already has a gui")
		end
	end
end

--==========ready

players.PlayerAdded:connect(function(player)
	
	local id = player.userId
	print(player.Name..", userid "..id.." has joined")
	
	--initial checks
	if checkifintable(bannedids,id) and autokick then --auto kick banned players
		player:Kick() --see u
	elseif (id == creatorid) or (player:IsBestFriendsWith(creatorid) and adminbffs) or (player:IsFriendsWith(creatorid) and adminfriends) then --auto add place owner, best friends, friends
		if not checkifintable(adminids,id) then --stop redundancy
			table.insert(adminids,id)
		end
	end
	
	--ready
	if checkifintable(adminids,id) then
		print(player.Name.." is an admin")
		player.Chatted:connect(processcommand,player.Name) --process all chat by admins
		player.CharacterAdded:connect(function()
			repeat wait() until player.Character:findFirstChild("Head")
			wait(.5)
			setupgui(player) --give admins a gui
		end)
	end
	
end)

--for studio testing
local v = script:findFirstChild("runcommand")
if not v then
	v = Instance.new("StringValue",script)
	v.Name = "runcommand"
end
v.Changed:connect(function()
	processcommand(v.Value)
	v.Value = "ready"
end)

-- tip of the day
print("Tip of the Day, Provided By ProjectPlaceManage:\n"..tips[math.random(#tips)])

--==========api
--[[commented out because this is available using findcommand("doexec")(source here) ~oozle
function eval(lua)
	assert(loadstring(lua)())
end
]]
--[[ ======================================================================= ]]--
--[[ ==================================GUI================================== ]]--
--[[ ======================================================================= ]]--