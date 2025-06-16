CL_ChangeVehicleConfigEvent = {}


function CL_ChangeVehicleConfigEvent:run(connection)

	if self.vehicle ~= nil then self.vehicle:setCustomLogoData(self.vehicleBuyData.customLogos) end

end

ChangeVehicleConfigEvent.run = Utils.prependedFunction(ChangeVehicleConfigEvent.run, CL_ChangeVehicleConfigEvent.run)