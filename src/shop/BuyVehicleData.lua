CL_BuyVehicleData = {}


function CL_BuyVehicleData:setStoreItem(storeItem)

	if #g_shopConfigScreen.customLogos == 0 then return end

	local logos = {}

	for _, logo in pairs(g_shopConfigScreen.customLogos) do

		local x, y, z = getTranslation(logo.node)
		local sx, sy, sz = getScale(logo.node)
		local rx, ry, rz = getRotation(logo.node)

		local data = {
			["position"] = { x, y, z },
			["scale"] = { sx, sy, sz },
			["rotation"] = { rx, ry, rz },
			["filename"] = logo.filename
		}

		if logo.mirror ~= nil then
				
			data.mirror = {
				["x"] = logo.mirror.x,
				["y"] = logo.mirror.y,
				["z"] = logo.mirror.z,
				["rx"] = logo.mirror.rx,
				["ry"] = logo.mirror.ry,
				["rz"] = logo.mirror.rz
			}

		end

		table.insert(logos, data)

	end

	self.customLogos = logos

end

BuyVehicleData.setStoreItem = Utils.appendedFunction(BuyVehicleData.setStoreItem, CL_BuyVehicleData.setStoreItem)


function CL_BuyVehicleData:onBought(vehicles, state, target)

	if state == VehicleLoadingState.OK and self.customLogos ~= nil then

		vehicles[1]:setCustomLogoData(self.customLogos)

	end

end

BuyVehicleData.onBought = Utils.prependedFunction(BuyVehicleData.onBought, CL_BuyVehicleData.onBought)


function CL_BuyVehicleData:readStream(streamId, connection)

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

		local logo = {
			["filename"] = g_currentModSettingsDirectory .. filename,
			["position"] = { x, y, z },
			["scale"] = { sx, sy, sz },
			["rotation"] = { rx, ry, rz }
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

	self.customLogos = logos

end

BuyVehicleData.readStream = Utils.appendedFunction(BuyVehicleData.readStream, CL_BuyVehicleData.readStream)


function CL_BuyVehicleData:writeStream(streamId, connection)

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

BuyVehicleData.writeStream = Utils.appendedFunction(BuyVehicleData.writeStream, CL_BuyVehicleData.writeStream)