CL_ShopConfigScreen = {}

local modDirectory = g_currentModDirectory
local modSettingsDirectoryPath = string.split(g_currentModSettingsDirectory, "/")
local baseDirectory = ""

for i = 1, #modSettingsDirectoryPath - 5 do

	baseDirectory = baseDirectory .. (i == 1 and "" or "/") .. modSettingsDirectoryPath[i]

end


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

		if #name >= 4 and CL_ShopConfigScreen.SUPPORTED_EXTENSIONS[string.sub(name, #name - 3)] then table.insert(parent.files, name) end

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

    self.buttonsPanel:invalidateLayout()

end


function CL_ShopConfigScreen:setStoreItem(storeItem, vehicle, saleItem, basePrice, configurations)

	self.files = { { ["folders"] = {}, ["files"] = {}, ["name"] = baseDirectory, ["path"] = baseDirectory } }

	getFilesRecursively(baseDirectory, self.files[1])

end

ShopConfigScreen.setStoreItem = Utils.appendedFunction(ShopConfigScreen.setStoreItem, CL_ShopConfigScreen.setStoreItem)


function ShopConfigScreen:onClickCustomLogo()

	if self.customLogoNode ~= nil then
		delete(self.customLogoNode)
		self.customLogoNode = nil
	end

	FileExplorerDialog.show(self.files, baseDirectory, self.onCustomLogoCallback, self)

end


function ShopConfigScreen:onClickMoveCustomLogo()

	CustomLogoGizmoDialog.show(self.customLogoNode)

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

	self.customLogoNode = node
	self.customLogoFilename = path

	self.moveCLButton:setVisible(true)
	self.buttonsPanel:invalidateLayout()

end


function CL_ShopConfigScreen:updateButtons()

	self.moveCLButton:setVisible(self.customLogoNode ~= nil)

end

ShopConfigScreen.updateButtons = Utils.prependedFunction(ShopConfigScreen.updateButtons, CL_ShopConfigScreen.updateButtons)


function CL_ShopConfigScreen:onClose()

	if self.customLogoNode ~= nil then delete(self.customLogoNode) end

	self.customLogoNode = nil

end

ShopConfigScreen.onClose = Utils.prependedFunction(ShopConfigScreen.onClose, CL_ShopConfigScreen.onClose)