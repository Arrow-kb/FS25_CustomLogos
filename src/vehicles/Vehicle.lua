CL_Vehicle = {}


local modDirectory = g_currentModDirectory


function Vehicle:setCustomLogoData(logos)

	local indexesToRemove = {}

	if logos == nil and self.customLogos ~= nil then

		for _, logo in pairs(self.customLogos) do

			delete(logo.node)
			if logo.mirror ~= nil then delete(logo.mirror.node) end

		end

		self.customLogos = nil
		return

	end

	if self.customLogos ~= nil then

		for _, logo in pairs(self.customLogos) do

			delete(logo.node)
			if logo.mirror ~= nil then delete(logo.mirror.node) end

		end

	end

	for i, logo in pairs(logos) do

		if not fileExists(logo.filename) then table.insert(indexesToRemove, i) end

		local node = loadI3DFile(modDirectory .. "i3d/emptyPlane.i3d")

		local rootNode = self.rootNode or getChildAt(self.i3dNode, 0)

		local parent = rootNode
		local parentPath = string.split(logo.parent, "|")

		for pathIndex = 2, #parentPath do

			parent = getChildAt(parent, tonumber(parentPath[pathIndex]))

		end

		link(parent, node)
		setTranslation(node, unpack(logo.position))
		setScale(node, unpack(logo.scale))
		setRotation(node, unpack(logo.rotation))
		setVisibility(node, true)

		local shape = getChildAt(node, 0)
		local materialId = getMaterial(shape, 0)

		setMaterialDiffuseMapFromFile(materialId, logo.filename, false, true, true)

		if logo.mirror ~= nil then

			local mirrorNode = clone(node, true)

			local x, y, z = unpack(logo.position)
			local rx, ry, rz = unpack(logo.rotation)

			x = x * (logo.mirror.x and -1 or 1)
			y = y * (logo.mirror.y and -1 or 1)
			z = z * (logo.mirror.z and -1 or 1)

			if logo.mirror.rx then rx = rx + math.pi end
			if logo.mirror.ry then ry = ry + math.pi end
			if logo.mirror.rz then rz = rz + math.pi end

			setTranslation(mirrorNode, x, y, z)
			setRotation(mirrorNode, rx, ry, rz)

			logo.mirror.node = mirrorNode

		end

		logo.node = node

	end

	for i = #indexesToRemove, 1, -1 do table.remove(logos, indexesToRemove[i]) end

	self.customLogos = logos

end


function CL_Vehicle:saveToXMLFile(xmlFile, key)

	if self.customLogos == nil then return end

	for i = 1, #self.customLogos do

		local logo = self.customLogos[i]
		local logoKey = key .. ".customLogos.logo(" .. (i - 1) .. ")"

		xmlFile:setString(logoKey .. "#filename", logo.filename)
		xmlFile:setVector(logoKey .. "#position", logo.position)
		xmlFile:setVector(logoKey .. "#scale", logo.scale)
		xmlFile:setVector(logoKey .. "#rotation", logo.rotation)
		xmlFile:setString(logoKey .. "#parent", logo.parent or "0|")

		if logo.mirror ~= nil then

			xmlFile:setBool(logoKey .. ".mirror#x", logo.mirror.x)
			xmlFile:setBool(logoKey .. ".mirror#y", logo.mirror.y)
			xmlFile:setBool(logoKey .. ".mirror#z", logo.mirror.z)
			xmlFile:setBool(logoKey .. ".mirror#rx", logo.mirror.rx)
			xmlFile:setBool(logoKey .. ".mirror#ry", logo.mirror.ry)
			xmlFile:setBool(logoKey .. ".mirror#rz", logo.mirror.rz)

		end

	end

end

Vehicle.saveToXMLFile = Utils.appendedFunction(Vehicle.saveToXMLFile, CL_Vehicle.saveToXMLFile)


function CL_Vehicle:loadFinished()

	if self.savegame == nil then return end

	self:addAsyncTask(function()

		local xmlFile = self.savegame.xmlFile
		local key = self.savegame.key

		if xmlFile:hasProperty(key .. ".customLogos") then

			local logos = {}

			xmlFile:iterate(key .. ".customLogos.logo", function(_, logoKey)
			
				local logo = {
					["filename"] = xmlFile:getString(logoKey .. "#filename"),
					["position"] = xmlFile:getVector(logoKey .. "#position"),
					["scale"] = xmlFile:getVector(logoKey .. "#scale"),
					["rotation"] = xmlFile:getVector(logoKey .. "#rotation"),
					["parent"] = xmlFile:getString(logoKey .. "#parent", "0|")
				}

				if xmlFile:hasProperty(logoKey .. ".mirror") then

					logo.mirror = {
						["x"] = xmlFile:getBool(logoKey .. ".mirror#x", false),
						["y"] = xmlFile:getBool(logoKey .. ".mirror#y", false),
						["z"] = xmlFile:getBool(logoKey .. ".mirror#z", false),
						["rx"] = xmlFile:getBool(logoKey .. ".mirror#rx", false),
						["ry"] = xmlFile:getBool(logoKey .. ".mirror#ry", false),
						["rz"] = xmlFile:getBool(logoKey .. ".mirror#rz", false)
					}

				end

				table.insert(logos, logo)
			
			end)

			self:setCustomLogoData(logos)

		end

	end, "Vehicle - Custom Logo loaded")

end

Vehicle.loadFinished = Utils.prependedFunction(Vehicle.loadFinished, CL_Vehicle.loadFinished)


function CL_Vehicle:postReadStream(streamId, connection)

	local numLogos = streamReadUInt8(streamId)

	local logos = {}

	for i = 1, numLogos do

		local filename = streamReadString(streamId)
		
		local x = streamReadFloat32(streamId)
		local y = streamReadFloat32(streamId)
		local z = streamReadFloat32(streamId)
		
		local sx = streamReadFloat32(streamId)
		local sy = streamReadFloat32(streamId)
		local sz = streamReadFloat32(streamId)
		
		local rx = streamReadFloat32(streamId)
		local ry = streamReadFloat32(streamId)
		local rz = streamReadFloat32(streamId)

		local parent = streamReadString(streamId)

		local logo = {
			["filename"] = g_currentModSettingsDirectory .. filename,
			["position"] = { x, y, z },
			["scale"] = { sx, sy, sz },
			["rotation"] = { rx, ry, rz },
			["parent"] = parent
		}

		local isMirrored = streamReadBool(streamId)

		if isMirrored then

			local mirrorX = streamReadBool(streamId)
			local mirrorY = streamReadBool(streamId)
			local mirrorZ = streamReadBool(streamId)

			local mirrorRX = streamReadBool(streamId)
			local mirrorRY = streamReadBool(streamId)
			local mirrorRZ = streamReadBool(streamId)

			logo.mirror = {
				["x"] = mirrorX,
				["y"] = mirrorY,
				["z"] = mirrorZ,
				["rx"] = mirrorRX,
				["ry"] = mirrorRY,
				["rz"] = mirrorRZ
			}

		end

		table.insert(logos, logo)

	end

	if #logos > 0 then self:setCustomLogoData(logos) end

end

Vehicle.postReadStream = Utils.appendedFunction(Vehicle.postReadStream, CL_Vehicle.postReadStream)


function CL_Vehicle:postWriteStream(streamId, connection)

	streamWriteUInt8(streamId, self.customLogos == nil and 0 or #self.customLogos)

	if self.customLogos ~= nil then

		for _, logo in pairs(self.customLogos) do

			streamWriteString(streamId, string.sub(logo.filename, string.findLast(logo.filename, "/") + 1))

			streamWriteFloat32(streamId, logo.position[1])
			streamWriteFloat32(streamId, logo.position[2])
			streamWriteFloat32(streamId, logo.position[3])

			streamWriteFloat32(streamId, logo.scale[1])
			streamWriteFloat32(streamId, logo.scale[2])
			streamWriteFloat32(streamId, logo.scale[3])

			streamWriteFloat32(streamId, logo.rotation[1])
			streamWriteFloat32(streamId, logo.rotation[2])
			streamWriteFloat32(streamId, logo.rotation[3])

			streamWriteString(streamId, logo.parent or "0|")

			streamWriteBool(streamId, logo.mirror ~= nil)

			if logo.mirror ~= nil then

				streamWriteBool(streamId, logo.mirror.x or false)
				streamWriteBool(streamId, logo.mirror.y or false)
				streamWriteBool(streamId, logo.mirror.z or false)

				streamWriteBool(streamId, logo.mirror.rx or false)
				streamWriteBool(streamId, logo.mirror.ry or false)
				streamWriteBool(streamId, logo.mirror.rz or false)

			end

		end

	end

end

Vehicle.postWriteStream = Utils.appendedFunction(Vehicle.postWriteStream, CL_Vehicle.postWriteStream)


function CL_Vehicle:delete()

	if self.customLogos ~= nil then

		for _, logo in pairs(self.customLogos) do
			delete(logo.node)
			if logo.mirror ~= nil then delete(logo.mirror.node) end
		end

		self.customLogos = nil

	end

end

Vehicle.delete = Utils.prependedFunction(Vehicle.delete, CL_Vehicle.delete)