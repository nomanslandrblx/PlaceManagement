--[[ ====================================================================== ]]--
--[[ ================================CONFIG================================ ]]--
--[[ ====================================================================== ]]--
--[[                         !MUST BE MODULESCRIPT!                         ]]--

-- local adminnames = {"PlusReed", "Oozlebachr", "Enfys", "CoffeeScripter"}
local adminids = {13135356, 4353611, 36305601, 6110966, -1} -- -1 for testing
--local bannednames = {"NowDoTheHarlemShake"}
local bannedids = {38506985}
local bannedips = {}

local autokick = true -- can be used to write custom ban handlers [CS]

--automatically admin best friends or friends (if they aren't banned)
local adminbffs = true
local adminfriends = false

return {adminids,bannedids,autokick,adminbffs,adminfriends}
