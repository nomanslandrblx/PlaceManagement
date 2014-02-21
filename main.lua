local conf = require('config')

--==========variables

local adminids,bannedids,autokick,adminbffs,adminfriends = conf[1],conf[2],conf[3],conf[4],conf[5]
local rbxutil = assert(LoadLibrary("RbxUtility"))
local persistentadmins = script:findFirstChild("padmins")
local persistentbanned = script:findFirstChild("pbanned")
local creatorid = game.CreatorId

--==========functions

--check if value [value] exists in table [t]
--ex print(checkifintable(adminids,4353611)
function checkifintable(t,value)
	for i,v in ipairs(t) do
		if v == value then
			return true
		end
	end
end

--remove value [value] from table [t]
--if [short], shorten values in the table to the provided value and then check
--ex removefromtable(adminids,4353611) print(checkifintable(adminids,4353611)
function removefromtable(t,value,short)
	for i,v in ipairs(t) do
		if (short and string.sub(v,string.len(value)) == value) or v == value then
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


--==========initial setup

--set up persistent admin and banned user tables as jsons in stringvalues if needed (for use in pbs)
if not persistentadmins then
	persistentadmins = Instance.new("StringValue",script)
	persistentadmins.Name = "padmins"
end
if not persistentbanned then
	persistentbanned = Instance.new("StringValue",script)
	persistentbanned.Name = "padmins"
end

--decode and merge persistent admin and banned user tables (all values should be userids)
if persistenadmins.Value then
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

	
--==========ready

game:GetService("Players").PlayerAdded:connect(function(player)
	
	local id = player.UserId
	
	--initial checks
	if checkifintable(bannedids,id) and autokick then --auto kick banned players
		player:Kick() --see u
	elseif (id == creatorid) or (player:IsBestFriendsWith(creatorid) and adminbffs) or (player:IsFriendsWith(creatorid) and adminfriends) --auto add place owner, best friends, friends
		if not checkifintable(admins,id) then --stop redundancy
			table.insert(admins,id)
		end
	end
	
	--ready
	if checkifadmin(player) then
		--insert admin things here
	end
end)

--==========api
function eval(lua)
	assert(loadstring(x))()
end
--[[ ======================================================================= ]]--
--[[ ==================================GUI================================== ]]--
--[[ ======================================================================= ]]--
