CL_ShopConfigScreen = {}

local modDirectory = g_currentModDirectory
local modSettingsDirectory = g_currentModSettingsDirectory
local modSettingsDirectoryPath = string.split(modSettingsDirectory, "/")
local baseDirectory = ""

for i = 1, #modSettingsDirectoryPath - 5 do

	baseDirectory = baseDirectory .. (i == 1 and "" or "/") .. modSettingsDirectoryPath[i]

end

if g_server == nil or g_server.netIsRunning then baseDirectory = modSettingsDirectory end
createFolder(modSettingsDirectory)


CL_ShopConfigScreen.SUPPORTED_EXTENSIONS = {
	[".png"] = true,
	[".jpg"] = true,
	[".dds"] = true
}


local function getFilesRecursively(path, parent)

	local files = Files.new(path).files

	for _, file in pairs(files) do

		if file.isDirectory then
		
			table.insert(parent.folders, { ["folders"] = {}, ["files"] = {}, ["name"] = file.filename, ["path"] = file.path })
			getFilesRecursively(file.path, parent.folders[#parent.folders])
			continue

		end

		local name = file.filename

		if #name >= 4 and CL_ShopConfigScreen.SUPPORTED_EXTENSIONS[string.sub(name, #name - 3)] then table.insert(parent.files, { ["name"] = name, ["valid"] = true }) end

	end

end


local function validateFilesRecursively(files, manager)

	for _, folder in pairs(files.folders) do

		validateFilesRecursively(folder, manager)

	end

	for _, file in pairs(files.files) do

		manager:sendQuery(file.name, function(target, filename, response) file.valid = response end, self)

	end

end


function ShopConfigScreen:setupCustomLogoButton()

	local button = self.buyButton:clone(self.buttonsPanel)

    button:applyProfile("clButtonMenuExtra2")
    button:setText(g_i18n:getText("cl_customLogo"))
    button.onClickCallback = self.onClickCustomLogo

	self.moveCLButton = self.buyButton:clone(self.buttonsPanel)

    self.moveCLButton:applyProfile("buttonMenuSwitch")
    self.moveCLButton:setText(g_i18n:getText("cl_moveLogo"))
    self.moveCLButton.onClickCallback = self.onClickMoveCustomLogo
	self.moveCLButton:setVisible(false)

	self.customLogos = {}

    self.buttonsPanel:invalidateLayout()

end


function CL_ShopConfigScreen:setStoreItem(storeItem, vehicle, saleItem, basePrice, configurations)

	self.files = { { ["folders"] = {}, ["files"] = {}, ["name"] = baseDirectory, ["path"] = baseDirectory } }

	getFilesRecursively(baseDirectory, self.files[1])

	if g_server == nil then validateFilesRecursively(self.files[1], g_fileQueryManager) end

	self.customLogos = {}

end

ShopConfigScreen.setStoreItem = Utils.appendedFunction(ShopConfigScreen.setStoreItem, CL_ShopConfigScreen.setStoreItem)


function CL_ShopConfigScreen:onVehiclesLoaded(vehicles, state)

	local logos = table.clone(self.customLogos)

	self.customLogos = {}

	if state ~= VehicleLoadingState.OK then return end

	local rootNode = vehicles[1].rootNode

	if #logos > 0 then

		for _, logo in pairs(logos) do

			link(rootNode, logo.node)

			if logo.mirror ~= nil then link(rootNode, logo.mirror.node) end

		end

	elseif self.vehicle ~= nil and self.vehicle.customLogos ~= nil then

		for _, logo in pairs(self.vehicle.customLogos) do

			local node = clone(logo.node, false)
			
			local parent = rootNode
			local parentPath = string.split(logo.parent, "|")

			for pathIndex = 2, #parentPath do

				parent = getChildAt(parent, tonumber(parentPath[pathIndex]))

			end

			link(parent, node)

			local previewLogo = {
				["node"] = node,
				["filename"] = logo.filename,
				["parent"] = logo.parent
			}

			if logo.mirror ~= nil then

				local mirrorNode = clone(logo.mirror.node, false)
				link(parent, mirrorNode)

				previewLogo.mirror = {
					["node"] = mirrorNode,
					["x"] = logo.mirror.x,
					["y"] = logo.mirror.y,
					["z"] = logo.mirror.z,
					["rx"] = logo.mirror.rx,
					["ry"] = logo.mirror.ry,
					["rz"] = logo.mirror.rz
				}

			end

			table.insert(logos, previewLogo)

		end

	end

	self.customLogos = logos
	self.moveCLButton:setVisible(#self.customLogos > 0)

end

ShopConfigScreen.onVehiclesLoaded = Utils.appendedFunction(ShopConfigScreen.onVehiclesLoaded, CL_ShopConfigScreen.onVehiclesLoaded)


function ShopConfigScreen:onClickCustomLogo()

	FileExplorerDialog.show(self.files, baseDirectory, self.onCustomLogoCallback, self)

end


function ShopConfigScreen:onClickMoveCustomLogo()

	CustomLogoGizmoDialog.show(self.customLogos, self.previewVehicles[1].rootNode)

end


function ShopConfigScreen:onCustomLogoCallback(path)

	local node = loadI3DFile(modDirectory .. "i3d/emptyPlane.i3d")

	local vehicle = self.previewVehicles[1]

	link(vehicle.rootNode, node)
	setTranslation(node, 0, 5, 0)
	setVisibility(node, true)

	local shape = getChildAt(node, 0)
	local materialId = getMaterial(shape, 0)

	setMaterialDiffuseMapFromFile(materialId, path, false, true, true)

	table.insert(self.customLogos, {
		["node"] = node,
		["filename"] = path,
		["parent"] = "0|"
	})

	self.moveCLButton:setVisible(true)
	self.buttonsPanel:invalidateLayout()

end


function CL_ShopConfigScreen:updateButtons()

	self.moveCLButton:setVisible(#self.customLogos > 0)

end

ShopConfigScreen.updateButtons = Utils.prependedFunction(ShopConfigScreen.updateButtons, CL_ShopConfigScreen.updateButtons)


function CL_ShopConfigScreen:onClose()

	for _, logo in pairs(self.customLogos) do

		delete(logo.node)

		if logo.mirror ~= nil then delete(logo.mirror.node) end

	end

	self.customLogos = {}

end

ShopConfigScreen.onClose = Utils.prependedFunction(ShopConfigScreen.onClose, CL_ShopConfigScreen.onClose)