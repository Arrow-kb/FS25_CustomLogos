FileQueryManager = {}

local FileQueryManager_mt = Class(FileQueryManager)


function FileQueryManager.new()

	local self = setmetatable({}, FileQueryManager_mt)

	self.queries = {}

	return self

end


function FileQueryManager:sendQuery(filename, callback, target)

	table.insert(self.queries, {
		["filename"] = filename,
		["callback"] = callback,
		["target"] = target
	})

	g_client:getServerConnection():sendEvent(FileQueryEvent.new(filename))

end


function FileQueryManager:handleResponse(filename, response)

	local queriesToDelete = {}

	for i, query in pairs(self.queries) do

		if query.filename ~= filename then continue end

		query.callback(query.target, filename, response)

		table.insert(queriesToDelete, i)

	end

	for i = #queriesToDelete, 1, -1 do table.remove(self.queries, queriesToDelete[i]) end

end


g_fileQueryManager = FileQueryManager.new()