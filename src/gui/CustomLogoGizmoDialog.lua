CustomLogoGizmoDialog = {}


local modDirectory = g_currentModDirectory
local CustomLogoGizmoDialog_mt = Class(CustomLogoGizmoDialog, MessageDialog)


function CustomLogoGizmoDialog.register()

	local dialog = CustomLogoGizmoDialog.new()
	g_gui:loadGui(modDirectory .. "gui/CustomLogoGizmoDialog.xml", "CustomLogoGizmoDialog", dialog)
	CustomLogoGizmoDialog.INSTANCE = dialog

end


function CustomLogoGizmoDialog.show(node)

    if CustomLogoGizmoDialog.INSTANCE ~= nil then

        CustomLogoGizmoDialog.INSTANCE.node = node
        g_gui:showDialog("CustomLogoGizmoDialog")

    end

end


function CustomLogoGizmoDialog.new(target, customMt)

    local self = MessageDialog.new(target, customMt or CustomLogoGizmoDialog_mt)

    self.node = 0

    return self

end


function CustomLogoGizmoDialog.createFromExistingGui(gui, _)

    CustomLogoGizmoDialog.register()
    CustomLogoGizmoDialog.show(gui.node)

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

end


function CustomLogoGizmoDialog:onOpen()

    CustomLogoGizmoDialog:superClass().onOpen(self)

    local x, y, z = getTranslation(self.node)
    local sx, sy, sz = getScale(self.node)
    local rx, ry, rz = getRotation(self.node)

    local values = { ["x"] = x, ["y"] = y, ["z"] = z, ["sx"] = sx, ["sy"] = sy, ["sz"] = sz, ["rx"] = rx, ["ry"] = ry, ["rz"] = rz}

    for button, option in pairs(self.options) do

        local value = values[option.targetLiteral]
        local k = 1

        for j = -10, 10, 0.01 do

            if j >= value - 0.005 and j <= value + 0.005 then button:setState(k) end

            k = k + 1

        end

    end

end


function CustomLogoGizmoDialog:onClose()

    CustomLogoGizmoDialog:superClass().onClose(self)

end


function CustomLogoGizmoDialog:onClickOk()

    self:close()

end


function CustomLogoGizmoDialog:onClickOption(state, button)

    local option = self.options[button]

    local value = -10 + 0.01 * (state - 1)

    local x, y, z = option.getFunction(self.node)

    local values = table.pack(x, y, z)

    values[option.target] = value

    option.setFunction(self.node, unpack(values))

end