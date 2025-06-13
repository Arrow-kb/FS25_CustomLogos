CL_BuyVehicleData = {}


function CL_BuyVehicleData:onBought(vehicles, state, target)

	if state == VehicleLoadingState.OK and g_shopConfigScreen.customLogoNode ~= nil then

		local x, y, z = getTranslation(g_shopConfigScreen.customLogoNode)
		local sx, sy, sz = getScale(g_shopConfigScreen.customLogoNode)
		local rx, ry, rz = getRotation(g_shopConfigScreen.customLogoNode)

		local data = {
			["position"] = { x, y, z },
			["scale"] = { sx, sy, sz },
			["rotation"] = { rx, ry, rz },
			["filename"] = g_shopConfigScreen.customLogoFilename
		}

		vehicles[1]:setCustomLogoData(data)

		delete(g_shopConfigScreen.customLogoNode)
		g_shopConfigScreen.customLogoNode = nil
		g_shopConfigScreen.moveCLButton:setVisible(false)

	end

end

BuyVehicleData.onBought = Utils.prependedFunction(BuyVehicleData.onBought, CL_BuyVehicleData.onBought)