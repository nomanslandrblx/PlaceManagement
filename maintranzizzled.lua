local PPM = {}

--[[
	==========table of contents==========
	
	1. variables
	
	2. admin commands
	
	3. datastore n' http functions
	
	4. command processin cunctions
	
	5. initial setup
	
	6. ready
	
	7. api (?)
]]

--==========variables

--import settings
local conf = require(script.config)
local adminids,bannedids,autokick,adminbffs,adminfriends,usedatastore = conf[1],conf[2],conf[3],conf[4],conf[5],conf[6]

--libraries
local rbxutil = assert(LoadLibrary("RbxUtility"))

--skillz
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()
local httpservice = game:GetService('HttpService')

--instances
local persistentadmins = script:findFirstChild("padmins")
local persistentbanned = script:findFirstChild("pbanned")

--constants
local numorigcommands
local creatorid = game.CreatorId
local runcommand = "!" --to bust a single argument, use dis symbol twice. ex: "!" -> "!!command"
local viewcommanddocumentation = "?" --use dis symbol twice ta view all available commands
local divider = " "
local tips = {
	"Be careful when rockin Jacked Models!",
	"Be prepared fo' exploiters!",
	"Assign Lua library functions ta local variablez ta improve script execution speeds!",
	"Is suttin' not hustlin like it should yo, but works fine up in solo mode, biatch? Try Start Player mode!",
	"Use Spawn() n' Delay() functions ta allow a script ta proceed while waitin fo' HTTP data if necessary!",
	"Remember ta add documentation fo' yo' code so itz easy as fuck  ta KNOW if you eva need ta go back n' fix thangs!",
	"Use ModuleScripts ta easily manage code dat appears up in nuff scripts!",
	"Usin enums ta chizzle propertizzles will help yo' code run fasta than rockin strings!",
	"Sometimes, itz mo' betta ta do extra work up front so itz easy as fuck  ta chizzle thangs later!"
}

--==========admin commands

--these is tha commands
--i included one just fo' reference n' stuff, you can either add commandz directly ta dis table or use tha module system ~oozle
local commandizzlez = {
	{"doexec",
		function(arg)
			assert(loadstring(arg))()
		end,
		"==========doexec by oozlebachr\n\ndoexec be a cold-ass lil core command dat can be used fo' reference or testing.\n\ndoexec runs a single argument all up in loadstring.\n\nex !!doexec print('wassup ghetto')"
	}
}

--save original gangsta command count
numorigcommandz = #commandizzlez

--load module commands
if script:findFirstChild("modules") then
	for i,v in ipairs(script.modules:GetChildren()) do
		--local module = require(v)
		--commands[module[1]] = module[2]
		--switchin ta nested tablez ta make room fo' documentation ~oozle
		table.insert(commandizzlez,require(v))
	end
end

--==========datastore n' http functions

function datastorewrite(module_, key, value)
	globaldatastore:WriteAsync('PPM_' .. module_ .. '_' .. key, value)
end

function datastoreget(module_, key)
	globaldatastore:GetAsync('PPM_' .. module_ .. '_' .. key)
end

--==========comomand processin functions

--check if value [value] exists up in table [t]
--if [short], shorten joints up in tha table ta tha length of tha provided value n' then check
--ex print(checkifintable(adminids,4353611)
function checkifintable(t,value,short)
	for i,v in ipairs(t) do
		if (short and string.sub(v,1,string.len(value)) == value) or v == value then
			return true
		end
	end
end

--remove value [value] from table [t]
--if [short], shorten joints up in tha table ta tha length of provided value n' then check
--ex removefromtable(adminids,4353611) print(checkifintable(adminids,4353611)
function removefromtable(t,value,short)
	for i,v in ipairs(t) do
		if (short and string.sub(v,1,string.len(value)) == value) or v == value then
			table.remove(t,i)
			return --only remove first result
		end
	end
end

--splits tha strang [str] by divider [div] n' returns a table of tha thangs up in dis biatch
--currently only supports single character dividers
--ex fo' i,v up in ipairs(split("enfys be a noob"," ")) do print(v) end
--maybe use dis fo' commandz (!kill enfys -> split returns !kill, enfys -> pass enfys as argument ta function kill) ~oozle
function split(str,div)
	local thangsindisbiatch = {}
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
	return thangsindisbiatch
end

--find tha given command [command] n' returns it
--ex findcommand("doprint")("wassup ghetto")
function findcommand(command)
	for i,v in ipairs(commandizzlez) do
		if v[1] == command then
			return v
		end
	end
end

--returns a random strang key which can be used ta authenticate external commands
--ex print(genrandomkey())
--external command system aint locked n loaded yet ~oozle
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

--main function ta run commands, processes tha strang [str]
--processing: check if command -> split -> find function -> concat arguments -> run function n' pass arguments
--ex processcommand("!doprint wassup ghetto")
--to use only one argument, use "!!"
--ex processcommand("!!doprint wassup ghetto")
--to view module documentation, use "?"
--ex processcommand("?doprint")
function processcommand(str,source)
	local header = string.sub(str,1,1)
	if header == runcommand then --check if itz straight-up a cold-ass lil command
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
			--switchin ta nested tablez ta make room fo' documentation
			if findcommand(command) then
				findcommand(command)[2](argument)
			else
				print([["]]..command..[[" aint a valid command]])
			end
			
		else --use multiple arguments
			
			--split strang tha fuck into its constituent items
			local shit = split(str,divider)		
			--find tha command
			command = items[1]
			command = string.sub(command,2,string.len(command))
			if findcommand(command) and findcommand(command)[2] then
				command = findcommand(command)[2]
				table.remove(items,1)
				--concatenate arguments tha fuck into "arg1, arg2, arg3, arg#" etc
				local arguments = ""
				for _,arg in ipairs(items) do
					arguments = arguments..[["]]..arg..[[",]]
				end
				--assemble tha parts
				local arguments = "("..string.sub(arguments,1,string.len(arguments)-1)..")"
				--loadstrin it
				--local func = assert(loadstring("command"..arguments))
				--switchin ta nested tablez ta make room fo' documentation
				local func = assert(loadstring("command"..arguments))
				--run it
				func()
			else
				print([["]]..string.sub(items[1],2,string.len(items[1]))..[[" aint a valid command]])
			end
			
		end
		
	elseif header == viewcommanddocumentation then --display info
		if string.sub(str,2,2) == viewcommanddocumentation then --display all commands
			local corecommandz = {}
			local modulecommandz = {}
			for i,v in ipairs(commandizzlez) do
				if i <= numorigcommandz then
					table.insert(corecommandz,v[1])
				else
					table.insert(modulecommandz,v[1])
				end
			end
			print("core commands:\n"..table.concat(corecommandz,", ").."\nmodule commands:\n"..table.concat(modulecommandz,", "))
		else --display info fo' given command
			local command = string.sub(str,2,string.len(str))
			if findcommand(command) then
				local doc = findcommand(command)[3]
				if doc then
					--well i guess just print fo' now
					print([[documentation fo' "]]..command..[[": ]].."\n\n"..doc)
				else
					print([["]]..command..[[" be a valid command but has no documentation]])
				end
			else
				print([["]]..command..[[" aint a valid command]])
			end
		end
	end
end

--==========initial setup

--set up persistent admin n' banned user tablez as jsons up in stringvalues if needed (for use up in pbs)
if not persistentadmins then
	persistentadmins = Instance.new("StringValue",script)
	persistentadmins.Name = "padmins"
end
if not persistentbanned then
	persistentbanned = Instance.new("StringValue",script)
	persistentbanned.Name = "pbanned"
end

--decode n' merge persistent admin n' banned user tablez (all joints should be userids)
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

--==========ready

game:GetService("Players").PlayerAdded:connect(function(playa)
	
	local id = playa.UserId
	
	--initial checks
	if checkifintable(bannedids,id) and autokick then --auto kick banned playas
		playa:Kick() --see u
	elseif (id == creatorid) or (player:IsBestFriendsWith(creatorid) and adminbffs) or (player:IsFriendsWith(creatorid) and adminfriends) then --auto add place baller, dopest playas, playas
		if not checkifintable(admins,id) then --stop redundancy
			table.insert(admins,id)
		end
	end
	
	--ready
	if checkifadmin(playa) then
		playa.Chatted:connect(processcommand,playa) --process all chat by admins
	end
	
end)

--for basement testing
local v = script:findFirstChild("runcommand")
if not v then
	v = Instance.new("StringValue",script)
	v.Name = "runcommand"
end
v.Changed:connect(function()
	processcommand(v.Value)
	v.Value = "ready"
end)

-- tip of tha day
print("Tip of tha Day, Provided By ProjectPlaceManage:\n"..tips[math.random(#tips)])

--==========api
--[[commented up cuz dis be available rockin findcommand("doexec")(source here) ~oozle
function eval(lua)
	assert(loadstring(lua)())
end
]]
--[[ ======================================================================= ]]--
--[[ ==================================GUI================================== ]]--
--[[ ======================================================================= ]]--