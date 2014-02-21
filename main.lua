--testing testing 123

--script only accepts userids

local conf = require('config')

--==========variables

local adminids,bannedids,autokick,adminbffs,adminfriends = conf[1],conf[2],conf[3],conf[4],conf[5]
local rbxutil = assert(LoadLibrary("RbxUtility"))
local persistentadmins = script:findFirstChild("padmins")
local persistentbanned = script:findFirstChild("pbanned")
local creatorid = game.CreatorId

--==========functions

function checkifintable(t,player)
	--check usernames
	-- i'm commenting this out because I find ID checking more efficient [CS]
	--[[
	for i,v in ipairs(admins) do
		if string.lower(v) == string.lower(player.Name) then
			return true
		end
	end
	]]
	--check userids
	for i,v in ipairs(t) do
		if v == player.userId then
			return true
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

--============api
function eval(lua)
	loadstring(x)()
end
--[[ ======================================================================= ]]--
--[[ ==================================GUI================================== ]]--
--[[ ======================================================================= ]]--
