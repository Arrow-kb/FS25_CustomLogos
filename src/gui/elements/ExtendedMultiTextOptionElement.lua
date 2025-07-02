ExtendedMultiTextOptionElement = {}

ExtendedMultiTextOptionElement_mt = Class(ExtendedMultiTextOptionElement, MultiTextOptionElement)

Gui.registerGuiElement("ExtendedMultiTextOption", ExtendedMultiTextOptionElement)
Gui.registerGuiElementProcFunction("ExtendedMultiTextOption", Gui.assignPlaySampleCallback)


function ExtendedMultiTextOptionElement.new(target, customMt)

	local self = MultiTextOptionElement.new(target, customMt or ExtendedMultiTextOptionElement_mt)
	return self

end


function ExtendedMultiTextOptionElement:loadProfile(profile, applyProfile)

	ExtendedMultiTextOptionElement:superClass().loadProfile(self, profile, applyProfile)

    self.defaultProfileButtonFirst = profile:getValue("defaultProfileButtonFirst", self.defaultProfileButtonFirst)
    self.defaultProfileButtonLast = profile:getValue("defaultProfileButtonLast", self.defaultProfileButtonLast)

end


function ExtendedMultiTextOptionElement:copyAttributes(src)

	ExtendedMultiTextOptionElement:superClass().copyAttributes(self, src)

	self.defaultProfileButtonFirst = src.defaultProfileButtonFirst
	self.defaultProfileButtonLast = src.defaultProfileButtonLast

end


function ExtendedMultiTextOptionElement:addDefaultElements()

	ExtendedMultiTextOptionElement:superClass().addDefaultElements(self)

	if not self.autoAddDefaultElements then return end

	if self:getDescendantByName("farLeft") == nil then
        local baseElement = ButtonElement.new(self)
        baseElement.name = "farLeft"
        self:addElement(baseElement)
        baseElement:applyProfile(self.defaultProfileButtonFirst)
    end

	if self:getDescendantByName("farRight") == nil then
        local baseElement = ButtonElement.new(self)
        baseElement.name = "farRight"
        self:addElement(baseElement)
        baseElement:applyProfile(self.defaultProfileButtonLast)
    end

end


function ExtendedMultiTextOptionElement:setElementsByName()

    ExtendedMultiTextOptionElement:superClass().setElementsByName(self)

    for _, element in pairs(self.elements) do

        if element.name == "farLeft" then

            if self.farLeftButtonElement ~= nil and self.farLeftButtonElement ~= element then self.farLeftButtonElement:delete() end

            self.farLeftButtonElement = element
            element.target = self
            element:setHandleFocus(false)
            element:setCallback("onClickCallback", "onFarLeftButtonClicked")
            element:setDisabled(self.disabled)
            element:setVisible(not self.hideLeftRightButtons)
            
        elseif element.name == "farRight" then

            if self.farRightButtonElement ~= nil and self.farRightButtonElement ~= element then self.farRightButtonElement:delete() end

            self.farRightButtonElement = element
            element.target = self
            element:setHandleFocus(false)
            element:setCallback("onClickCallback", "onFarRightButtonClicked")
            element:setDisabled(self.disabled)
            element:setVisible(not self.hideLeftRightButtons)

        end

    end

end


function ExtendedMultiTextOptionElement:onFarLeftButtonClicked()

    if self.texts == nil then return end

    self:setState(1)

end


function ExtendedMultiTextOptionElement:onFarRightButtonClicked()

    if self.texts == nil then return end

    self:setState(#self.texts)

end


function ExtendedMultiTextOptionElement:mouseEvent(posX, posY, isDown, isUp, button, eventUsed)

    eventUsed = ExtendedMultiTextOptionElement:superClass().mouseEvent(self, posX, posY, isDown, isUp, button, eventUsed)

    if not self:getIsActive() then return eventUsed end

    local isInElement = GuiUtils.checkOverlayOverlap(posX, posY, self.absPosition[1], self.absPosition[2], self.absSize[1], self.absSize[2], nil)

    if isInElement and isDown then

        local leftButton = self.farLeftButtonElement
        local isFarLeftButtonPressed = not self.hideLeftRightButtons and GuiUtils.checkOverlayOverlap(posX, posY, leftButton.absPosition[1], leftButton.absPosition[2], leftButton.size[1], leftButton.size[2], leftButton.hotspot)

        if isFarLeftButtonPressed then

            self:onFarLeftButtonClicked()
            eventUsed = true

        else

            local rightButton = self.farRightButtonElement
            local isFarRightButtonPressed = not self.hideLeftRightButtons and GuiUtils.checkOverlayOverlap(posX, posY, rightButton.absPosition[1], rightButton.absPosition[2], rightButton.size[1], rightButton.size[2], rightButton.hotspot)

            if isFarRightButtonPressed then

                self:onFarRightButtonClicked()
                eventUsed = true

            end

        end

    end

    return eventUsed

end