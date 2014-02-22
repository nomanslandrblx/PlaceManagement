--[[ DATASTORE AND HTTPSERVICE ]]--
--[[ ENSURE IT'S MODULESCRIPT ]]--

--[[ DATASTORE ]]--
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()
-- `Xmodule` is used instead of `module` as `module` is a Lua keyword
function WritePPMCoreDS(Xmodule, key, value)
	globaldatastore:SetAsync('PPM_' .. Xmodule .. '_' .. key, value)
end

function GetPPMCoreDS(Xmodule, key)
	return globaldatastore:GetAsync('PPM_' .. Xmodule .. '_' .. key)
end
	
--[[ HTTPSERVICE ]]--
local httpservice = game:GetService('HttpService')

function GetHttpService()
	return httpservice
end
