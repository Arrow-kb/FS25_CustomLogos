CL_FSBaseMission = {}

local modDirectory = g_currentModDirectory


function CL_FSBaseMission:onStartMission()

	g_overlayManager:addTextureConfigFile(modDirectory .. "gui/icons.xml", "custom_logos")

	g_gui:loadProfiles(modDirectory .. "gui/guiProfiles.xml")
	g_shopConfigScreen:setupCustomLogoButton()

	CustomLogoGizmoDialog.register()
	FileExplorerDialog.register()

	if not fileExists(g_currentModSettingsDirectory .. "arrowLogistics.dds") then copyFile(modDirectory .. "examples/arrowLogistics.dds", g_currentModSettingsDirectory .. "arrowLogistics.dds", true) end

end

FSBaseMission.onStartMission  = Utils.prependedFunction(FSBaseMission.onStartMission, CL_FSBaseMission.onStartMission)