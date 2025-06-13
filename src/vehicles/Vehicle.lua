CL_Vehicle = {}


local modDirectory = g_currentModDirectory


function Vehicle:setCustomLogoData(data)

	local node = loadI3DFile(modDirectory .. "i3d/emptyPlane.i3d")

	link(self.rootNode or getChildAt(self.i3dNode, 0), node)
	setTranslation(node, unpack(data.position))
	setScale(node, unpack(data.scale))
	setRotation(node, unpack(data.rotation))
	setVisibility(node, true)

	local shape = getChildAt(node, 0)
	local materialId = getMaterial(shape, 0)

	setMaterialDiffuseMapFromFile(materialId, data.filename, false, true, true)

	data.node = node

	self.customLogo = data

end


function CL_Vehicle:saveToXMLFile(xmlFile, key)

	if self.customLogo == nil then return end

	xmlFile:setString(key .. ".customLogo#filename", self.customLogo.filename)
	xmlFile:setVector(key .. ".customLogo#position", self.customLogo.position)
	xmlFile:setVector(key .. ".customLogo#scale", self.customLogo.scale)
	xmlFile:setVector(key .. ".customLogo#rotation", self.customLogo.rotation)

end

Vehicle.saveToXMLFile = Utils.appendedFunction(Vehicle.saveToXMLFile, CL_Vehicle.saveToXMLFile)


function CL_Vehicle:loadFinished()

	if self.savegame == nil then return end

	self:addAsyncTask(function()

		local xmlFile = self.savegame.xmlFile
		local key = self.savegame.key

		if xmlFile:hasProperty(key .. ".customLogo") then

			local data = {
				["filename"] = xmlFile:getString(key .. ".customLogo#filename"),
				["position"] = xmlFile:getVector(key .. ".customLogo#position"),
				["scale"] = xmlFile:getVector(key .. ".customLogo#scale"),
				["rotation"] = xmlFile:getVector(key .. ".customLogo#rotation")
			}

			self:setCustomLogoData(data)

		end

	end, "Vehicle - Custom Logo loaded")

end

Vehicle.loadFinished = Utils.prependedFunction(Vehicle.loadFinished, CL_Vehicle.loadFinished)


function CL_Vehicle:delete()

	if self.customLogo ~= nil and self.customLogo.node ~= nil then
		delete(self.customLogo.node)
		self.customLogo = nil
	end

end

Vehicle.delete = Utils.prependedFunction(Vehicle.delete, CL_Vehicle.delete)