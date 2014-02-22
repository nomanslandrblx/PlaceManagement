--[[ DATASTORE AND HTTPSERVICE ]]--
--[[ ENSURE IT'S MODULESCRIPT ]]--

--[[ DATASTORE ]]--
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()

function WriteDataStore(key, value)
	globaldatastore:SetAsync(key, value)
end

function GetDataStore(key)
	return globaldatastore:GetAsync(key)
end

--[[ HTTPSERVICE ]]--
local httpservice = game:GetService('HttpService')

function GetHttpService()
	return httpservice
end