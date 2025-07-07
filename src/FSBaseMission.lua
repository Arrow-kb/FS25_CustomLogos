CL_FSBaseMission = {}

local modDirectory = g_currentModDirectory
local modSettingsDirectory = g_currentModSettingsDirectory


function CL_FSBaseMission:onStartMission()

	g_overlayManager:addTextureConfigFile(modDirectory .. "gui/icons.xml", "custom_logos")
	g_overlayManager:addTextureConfigFile(modDirectory .. "gui/gui_elements.xml", "cl_gui_elements")

	g_gui:loadProfiles(modDirectory .. "gui/guiProfiles.xml")
	g_shopConfigScreen:setupCustomLogoButton()

	CustomLogoGizmoDialog.register()
	FileExplorerDialog.register()

	if not fileExists(modSettingsDirectory .. "arrowLogistics.dds") then copyFile(modDirectory .. "examples/arrowLogistics.dds", modSettingsDirectory .. "arrowLogistics.dds", true) end

end

FSBaseMission.onStartMission  = Utils.prependedFunction(FSBaseMission.onStartMission, CL_FSBaseMission.onStartMission)