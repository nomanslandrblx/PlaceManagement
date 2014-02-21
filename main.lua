--testing testing 123

--script accepts both usernames and userids (in case you want to really make sure someone stays admin by checking their userid)

require('config')

--==========variables

local rbxutil = assert(LoadLibrary("RbxUtility"))
local persistentadmins = script:findFirstChild("padmins")
local persistentbanned = script:findFirstChild("pbanned")

--==========functions

function checkifadmin(player)
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
	for i,v in ipairs(adminids) do
		if v == player.userId then
			return true
		end
	end
end

function checkifbanned(player)
	--check usernames
	-- i'm commenting this out because I find ID checking more efficient [CS]
	--[[
	for i,v in ipairs(bannednames) do
		if string.lower(v) == string.lower(player.Name) then
			return true
		end
	end
	]]
	--check userids
	for i,v in ipairs(bannedids) do
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
if persistentbanned.Value then
	for i,v in ipairs(rbxutil.DecodeJSON(persistentadmins.Value)) do
		table.insert(adminids,v)
	end
end
if persistentbanned.Value then
	for i,v in ipairs(rbxutil.DecodeJSON(persistentbanned.Value)) do
		table.insert(bannedids,v)
	end
end

	
--==========ready

game:GetService("Players").PlayerAdded:connect(function(player)
	if autokick == true then
		if checkifbanned(player) then
			player:Kick() --see u
		end
	end
	if checkifadmin(player) then
		--insert admin things here
	end
end)

--[[ ======================================================================= ]]--
--[[ ==================================GUI================================== ]]--
--[[ ======================================================================= ]]--
