CustomLogoGizmoDialog = {}


local modDirectory = g_currentModDirectory
local CustomLogoGizmoDialog_mt = Class(CustomLogoGizmoDialog, MessageDialog)


function CustomLogoGizmoDialog.register()

	local dialog = CustomLogoGizmoDialog.new()
	g_gui:loadGui(modDirectory .. "gui/CustomLogoGizmoDialog.xml", "CustomLogoGizmoDialog", dialog)
	CustomLogoGizmoDialog.INSTANCE = dialog

end


function CustomLogoGizmoDialog.show(logos, vehicle)

    if CustomLogoGizmoDialog.INSTANCE ~= nil then

        CustomLogoGizmoDialog.INSTANCE.logos = logos or {}
        CustomLogoGizmoDialog.INSTANCE.vehicle = vehicle
        g_gui:showDialog("CustomLogoGizmoDialog")

    end

end


function CustomLogoGizmoDialog.new(target, customMt)

    local self = MessageDialog.new(target, customMt or CustomLogoGizmoDialog_mt)

    self.logos = {}

    return self

end


function CustomLogoGizmoDialog.createFromExistingGui(gui, _)

    CustomLogoGizmoDialog.register()
    CustomLogoGizmoDialog.show(gui.logos)

end


function CustomLogoGizmoDialog:onGuiSetupFinished()

	CustomLogoGizmoDialog:superClass().onGuiSetupFinished(self)

    local texts = {}

    for i = -10, 10, 0.01 do
        table.insert(texts, string.format("%.2f", i))
    end

    for _, element in pairs(self.scrollingLayout.elements) do if element.typeName == "MultiTextOption" then element:setTexts(texts) end end

    self.options = {
        [self.optionX] = { ["getFunction"] = getTranslation, ["setFunction"] = setTranslation, ["target"] = 1, ["targetLiteral"] = "x" },
        [self.optionY] = { ["getFunction"] = getTranslation, ["setFunction"] = setTranslation, ["target"] = 2, ["targetLiteral"] = "y" },
        [self.optionZ] = { ["getFunction"] = getTranslation, ["setFunction"] = setTranslation, ["target"] = 3, ["targetLiteral"] = "z" },
        [self.optionSX] = { ["getFunction"] = getScale, ["setFunction"] = setScale, ["target"] = 1, ["targetLiteral"] = "sx" },
        [self.optionSY] = { ["getFunction"] = getScale, ["setFunction"] = setScale, ["target"] = 2, ["targetLiteral"] = "sy" },
        [self.optionSZ] = { ["getFunction"] = getScale, ["setFunction"] = setScale, ["target"] = 3, ["targetLiteral"] = "sz" },
        [self.optionRX] = { ["getFunction"] = getRotation, ["setFunction"] = setRotation, ["target"] = 1, ["targetLiteral"] = "rx" },
        [self.optionRY] = { ["getFunction"] = getRotation, ["setFunction"] = setRotation, ["target"] = 2, ["targetLiteral"] = "ry" },
        [self.optionRZ] = { ["getFunction"] = getRotation, ["setFunction"] = setRotation, ["target"] = 3, ["targetLiteral"] = "rz" }
    }

    self.mirrorOptions = {
        [self.optionMirrorX] = { ["getFunction"] = getTranslation, ["setFunction"] = setTranslation, ["target"] = 1, ["targetLiteral"] = "x" },
        [self.optionMirrorY] = { ["getFunction"] = getTranslation, ["setFunction"] = setTranslation, ["target"] = 2, ["targetLiteral"] = "y" },
        [self.optionMirrorZ] = { ["getFunction"] = getTranslation, ["setFunction"] = setTranslation, ["target"] = 3, ["targetLiteral"] = "z" },
        [self.optionMirrorRX] = { ["getFunction"] = getRotation, ["setFunction"] = setRotation, ["target"] = 1, ["targetLiteral"] = "rx" },
        [self.optionMirrorRY] = { ["getFunction"] = getRotation, ["setFunction"] = setRotation, ["target"] = 2, ["targetLiteral"] = "ry" },
        [self.optionMirrorRZ] = { ["getFunction"] = getRotation, ["setFunction"] = setRotation, ["target"] = 3, ["targetLiteral"] = "rz" }
    }

end


local function getNodesRecursively(parent, nodes, parentIsRoot)

    local numChildren = getNumOfChildren(parent.node)

    for i = 0, numChildren - 1 do

        local node = getChildAt(parent.node, i)
        local child = { ["node"] = node, ["name"] = getName(node), ["path"] = parent.path .. (parentIsRoot and "" or "|") .. i }

        table.insert(nodes, child)

        getNodesRecursively(child, nodes, false)

    end

    return true

end


function CustomLogoGizmoDialog:onOpen()

    CustomLogoGizmoDialog:superClass().onOpen(self)

    self.index = 1
    self.nodes = {}

    local logos = self.logos

    local texts = {}

    for _, logo in pairs(logos) do

        local name = string.sub(logo.filename, string.findLast(logo.filename, "/") + 1)
        table.insert(texts, name)

    end

    if self.vehicle ~= nil then

        self.nodes = { { ["node"] = self.vehicle, ["name"] = getName(self.vehicle), ["path"] = "0|" } }

        local success = getNodesRecursively(self.nodes[1], self.nodes, true)
        local names = {}

        for i = #self.nodes, 1, -1 do

            local name = self.nodes[i].name
            local node = self.nodes[i].node

            if string.contains(name, ".wav") or string.contains(name, ".gls") then
                table.remove(self.nodes, i)
                continue
            end

            for _, logo in pairs(logos) do
                if logo.node == node then
                    table.remove(self.nodes, i)
                    break
                end
            end

        end

        table.sort(self.nodes, function(a, b) return a.name < b.name end)

        for _, node in pairs(self.nodes) do table.insert(names, node.name) end

        self.linkOption:setTexts(names)

    end

    self.indexOption:setTexts(texts)
    self.indexOption:setState(1)

    self:onClickIndex(1)

end


function CustomLogoGizmoDialog:onClickOk()

    self:close()

end


function CustomLogoGizmoDialog:onClickLink(state)

    local logo = self.logos[self.index]
    local node = self.nodes[state].node

    link(node, logo.node)
    logo.parent = self.nodes[state].path

end


function CustomLogoGizmoDialog:onClickOption(state, button)

    local option = self.options[button]
    local logo = self.logos[self.index]

    local value = -10 + 0.01 * (state - 1)

    local x, y, z = option.getFunction(logo.node)

    local values = table.pack(x, y, z)

    values[option.target] = value

    option.setFunction(logo.node, unpack(values))

    if logo.mirror ~= nil then

        for _, mirrorOption in pairs(self.mirrorOptions) do

            if mirrorOption.getFunction ~= option.getFunction then continue end

            values[mirrorOption.target] = values[mirrorOption.target] * (logo.mirror[mirrorOption.targetLiteral] and -1 or 1)

        end

        option.setFunction(logo.mirror.node, unpack(values))

    end

end


function CustomLogoGizmoDialog:onClickIndex(index)

    self.index = index

    local logo = self.logos[index]

    self.linkOption:setState(1)

    for i, node in pairs(self.nodes) do

        if node.path == logo.parent then
            self.linkOption:setState(i)
            break
        end

    end

    local x, y, z = getTranslation(logo.node)
    local sx, sy, sz = getScale(logo.node)
    local rx, ry, rz = getRotation(logo.node)

    local values = { ["x"] = x, ["y"] = y, ["z"] = z, ["sx"] = sx, ["sy"] = sy, ["sz"] = sz, ["rx"] = rx, ["ry"] = ry, ["rz"] = rz}

    for button, option in pairs(self.options) do

        local value = values[option.targetLiteral]
        local k = 1

        for j = -10, 10, 0.01 do

            if j >= value - 0.005 and j <= value + 0.005 then button:setState(k) end

            k = k + 1

        end

    end

    self.mirrorButton:setState(logo.mirror == nil and 1 or 2)

    for button, option in pairs(self.mirrorOptions) do

        button:setDisabled(logo.mirror == nil)
        button:setState((logo.mirror == nil or not logo.mirror[option.targetLiteral]) and 1 or 2)

    end

end


function CustomLogoGizmoDialog:onClickMirror(state)

    local logo = self.logos[self.index]

    for button, _ in pairs(self.mirrorOptions) do

        button:setDisabled(state == 1)
        button:setState(1)

    end

    if state == 1 then

        if logo.mirror ~= nil then delete(logo.mirror.node) end

        logo.mirror = nil
        return

    end

    local node = clone(logo.node, true)

    logo.mirror = {
        ["node"] = node,
        ["x"] = false,
        ["y"] = false,
        ["z"] = false,
        ["rx"] = false,
        ["ry"] = false,
        ["rz"] = false
    }

end


function CustomLogoGizmoDialog:onClickMirrorOption(state, button)

    local logo = self.logos[self.index]

    if logo.mirror == nil then return end

    local option = self.mirrorOptions[button]
    logo.mirror[option.targetLiteral] = not logo.mirror[option.targetLiteral]

    local x, y, z = option.getFunction(logo.node)
    local values = table.pack(x, y, z)

    for _, b in pairs(self.mirrorOptions) do

        if b.getFunction ~= option.getFunction then continue end

        if b.getFunction == getRotation then

            if not logo.mirror[b.targetLiteral] then continue end

            values[b.target] = math.pi + values[b.target]

            continue

        end

        values[b.target] = values[b.target] * (logo.mirror[b.targetLiteral] and -1 or 1)

    end

    option.setFunction(logo.mirror.node, unpack(values))

end


function CustomLogoGizmoDialog:onClickDelete()

    local logo = self.logos[self.index]

    delete(logo.node)

    if logo.mirror ~= nil then delete(logo.mirror.node) end

    table.remove(self.logos, self.index)

    if #self.logos == 0 then
        self:close()
        g_shopConfigScreen.moveCLButton:setVisible(false)
        return
    end

    local texts = {}

    for _, logo in pairs(self.logos) do

        local name = string.sub(logo.filename, string.findLast(logo.filename, "/") + 1)
        table.insert(texts, name)

    end

    self.indexOption:setTexts(texts)

    local index = math.max(self.index - 1, 1)
    self:onClickIndex(index)
    self.indexOption:setState(index)

end