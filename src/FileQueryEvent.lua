FileQueryEvent = {}

local FileQueryEvent_mt = Class(FileQueryEvent, Event)
local modSettingsDirectory = g_currentModSettingsDirectory
InitEventClass(FileQueryEvent, "FileQueryEvent")


function FileQueryEvent.emptyNew()
    local self = Event.new(FileQueryEvent_mt)
    return self
end


function FileQueryEvent.new(filename, response)

    local self = FileQueryEvent.emptyNew()

    self.filename = filename
    self.response = response

    return self

end


function FileQueryEvent:readStream(streamId, connection)

    local isResponse = streamReadBool(streamId)
    self.filename = streamReadString(streamId)

    if isResponse then self.response = streamReadBool(streamId) end

    self:run(connection)

end


function FileQueryEvent:writeStream(streamId, connection)

    local isResponse = self.response ~= nil

    streamWriteBool(streamId, isResponse)
    streamWriteString(streamId, self.filename)
        
    if isResponse then streamWriteBool(streamId, self.response) end

end


function FileQueryEvent:run(connection)

    if self.response ~= nil then

        g_fileQueryManager:handleResponse(self.filename, self.response)

    else

        local found = fileExists(modSettingsDirectory .. self.filename)

        connection:sendEvent(FileQueryEvent.new(self.filename, found))

    end

end