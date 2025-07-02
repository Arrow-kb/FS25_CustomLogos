CL_WorkshopScreen = {}


function CL_WorkshopScreen:setConfigurations(vehicleBuyData, vehicleId)

	if not vehicleBuyData:isValid() then return end

	local logos = {}
	local vehicle = NetworkUtil.getObject(vehicleId)

	for _, logo in pairs(g_shopConfigScreen.customLogos) do

		local x, y, z = getTranslation(logo.node)
		local sx, sy, sz = getScale(logo.node)
		local rx, ry, rz = getRotation(logo.node)

		local data = {
			["position"] = { x, y, z },
			["scale"] = { sx, sy, sz },
			["rotation"] = { rx, ry, rz },
			["filename"] = logo.filename,
			["parent"] = logo.parent
		}

		delete(logo.node)

		if logo.mirror ~= nil then
				
			data.mirror = {
				["x"] = logo.mirror.x,
				["y"] = logo.mirror.y,
				["z"] = logo.mirror.z,
				["rx"] = logo.mirror.rx,
				["ry"] = logo.mirror.ry,
				["rz"] = logo.mirror.rz
			}

			delete(logo.mirror.node)

		end

		table.insert(logos, data)

	end

	vehicle:setCustomLogoData(logos)

	g_shopConfigScreen.customLogos = {}
	g_shopConfigScreen.moveCLButton:setVisible(false)

end

WorkshopScreen.setConfigurations = Utils.prependedFunction(WorkshopScreen.setConfigurations, CL_WorkshopScreen.setConfigurations)