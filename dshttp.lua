local PPM.DataStore = {}
local PPM.HttpServ = {}

--DataStore
local globaldatastore = game:GetService('DataStoreService'):GetGlobalDataStore()

function PPM.DataStore.Write(module_, key, value)
	globaldatastore:WriteAsync('PPM_' .. module_ .. '_' .. key, value)
end

function PPM.DataStore.Write(module_, key)
	globaldatastore:GetAsync('PPM_' .. module_ .. '_' .. key)
end

-- HttpService
local httpserv = game:GetService('HttpService')

function PPM.HttpServ.GetServ()
	return httpserv
end

return PPM.DataStore, PPM.HttpServ