--[[ DATASTORE AND HTTPSERVICE ]]--
--[[ ENSURE IT'S MODULESCRIPT ]]--

--[[ DATASTORE ]]--
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()

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

function GetPlayerIP()
	return httpservice:GetAsync('http://codersbasement.net/ip.php')
end
