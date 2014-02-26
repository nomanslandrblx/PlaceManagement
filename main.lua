local PPM = {}

--==========variables

--import settings
local conf = require(script.config)
local adminids,bannedids,autokick,adminbffs,adminfriends,usedatastore = conf[1],conf[2],conf[3],conf[4],conf[5],conf[6]

--libraries
local rbxutil = assert(LoadLibrary("RbxUtility"))

--services
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()
local httpservice = game:GetService('HttpService')

--instances
local persistentadmins = script:findFirstChild("padmins")
local persistentbanned = script:findFirstChild("pbanned")

--constants
local creatorid = game.CreatorId
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

--==========admin commands

--these are the commands
--i included one just for reference and stuff, you can either add commands directly to this table or use the module system ~oozle
local commands = {
	{"doexec",
		function(arg)
			assert(loadstring(arg))()
		end,
		"==========doexec by oozlebachr\n\ndoexec is a core command that can be used for reference or testing.\n\ndoexec runs a single argument through loadstring.\n\nex !!doexec print('hello world')"
	}
}

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
			return true
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

--main function to run commands, processes the string [str]
--processing: check if command -> split -> find function -> concat arguments -> run function and pass arguments
--ex processcommand("!doprint hello world")
--to use only one argument, use "!!"
--ex processcommand("!!doprint hello world")
--to view module documentation, use "?"
--ex processcommand("?doprint")
function processcommand(str,source)
	local header = string.sub(str,1,1)
	if header == "!" then --check if it's actually a command
		if string.sub(str,2,2) == "!" then --only use one argument
			
			command = ""
			local stop
			for i=1,string.len(str) do
				local char = string.sub(str,i,i)
				if char ~= "!" then
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
	elseif header == "?" then --display info for given command
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
			if not checkifintable(admins,id) then --stop redundancy
				table.insert(admins,id)
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

	
--==========ready

game:GetService("Players").PlayerAdded:connect(function(player)
	
	local id = player.UserId
	
	--initial checks
	if checkifintable(bannedids,id) and autokick then --auto kick banned players
		player:Kick() --see u
	elseif (id == creatorid) or (player:IsBestFriendsWith(creatorid) and adminbffs) or (player:IsFriendsWith(creatorid) and adminfriends) then --auto add place owner, best friends, friends
		if not checkifintable(admins,id) then --stop redundancy
			table.insert(admins,id)
		end
	end
	
	--ready
	if checkifadmin(player) then
		player.Chatted:connect(processcommand,player) --process all chat by admins
	end
	
end)

--for studio testing
local v = script:findFirstChild("runcommand")
if not v then
	v = Instance.new("StringValue",script)
	v.Name = "runcommand"
end
v.Changed:connect(processcommand)

-- tip of the day
print("Tip of the Day, Provided By ProjectPlaceManage:\n"..tips[math.random(#tips)])

--==========api
function eval(lua)
	assert(loadstring(lua)())
end
--[[ ======================================================================= ]]--
--[[ ==================================GUI================================== ]]--
--[[ ======================================================================= ]]--
