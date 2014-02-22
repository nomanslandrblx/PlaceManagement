--[[ DATASTORE AND HTTPSERVICE ]]--
--[[ ENSURE IT'S MODULESCRIPT ]]--

local dshttp = {}

--[[ DATASTORE ]]--
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()
-- `Xmodule` is used instead of `module` as `module` is a Lua keyword
function dshttp.WritePPMCoreDS(Xmodule, key, value)
	globaldatastore:SetAsync('PPM_' .. Xmodule .. '_' .. key, value)
end

function dshttp.GetPPMCoreDS(Xmodule, key)
	return globaldatastore:GetAsync('PPM_' .. Xmodule .. '_' .. key)
end
	
--[[ HTTPSERVICE ]]--
local httpservice = game:GetService('HttpService')

function dshttp.GetHttpService()
	return httpservice
end


--[[ READY ]]--
return dshttp
