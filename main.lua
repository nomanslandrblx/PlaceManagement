--script accepts both usernames and userids (in case you want to really make sure someone stays admin by checking their userid)
local adminnames = {"PlusReed", "Oozlebachr", "Enfys"}
local adminids = {13135356, 4353611, 36305601}

function checkifadmin(player)
	--check usernames
	for i,v in ipairs(admins) do
		if string.lower(v) == string.lower(player.Name) then
			return true
		end
	end
	--check userids
	for i,v in ipairs(adminids) do
		if v == player.userId then
			return true
		end
	end
end
	

game:GetService("Players").PlayerAdded:connect(function(player)
	if checkifadmin(player) then
		--insert admin things here
	end
end)
