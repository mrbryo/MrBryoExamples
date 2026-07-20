--[[ ------------------------------------------------------------------------
	Title: 			Example.lua
	Author: 		mrbryo
	Create Date : 	07/11/2026
	Description: 	Just a way to view a frame with UI elements.
-----------------------------------------------------------------------------]]

local addonName, ns = ...

-- for all example code
ns.example = {
    objects = {},
    const = {
        template = "ExampleTemplateType",
        frameType = "ExampleFrameType",
        note = "ExampleNote",
        padding = 10,

        -- colors
        colors = {
            white = "|cffffffff",
            yellow = "|cffffff00",
            green = "|cff00ff00",
            blue = "|cff0000ff",
            purple = "|cffff00ff",
            red = "|cffff0000",
            orange = "|cffff7f00",
            gray = "|cff7f7f7f",
            label = "|cffffd100",
            ending = "|r",
        },
    },
    ui = {
        frames = {}
    }
}

-- properly get frame attribute to check for nil or attribute which doesn't exist
function ns:GetAttribute(uiobject, attribute)
    if uiobject == nil then
        return ns.L["NIL Object"]
    else
        local attrValue = uiobject:GetAttribute(attribute)
        if attrValue == nil then
            return ns.L["Missing Attribute"]
        else
            return attrValue
        end
    end
end

function ns:ExampleFrame(parentFrame, object)
    -- standard variables
    local padding = ns.example.const.padding

    -- content frame
    local groupFrame = CreateFrame("Frame", nil, parentFrame, "InsetFrameTemplate")
    groupFrame:SetFrameStrata("MEDIUM")
    local bg = groupFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(groupFrame)
    bg:SetColorTexture(0, 0, 0, 0.7) -- Black, 80% opaque

    -- get object attributes
    local frameType = ns:GetAttribute(object, ns.example.const.frameType)
    local frameTemplate = ns:GetAttribute(object, ns.example.const.template)

    -- add text about object
    local frameLabel = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    frameLabel:SetText(("%s%s%s %s"):format(ns.example.const.colors.white, "Frame Type:", ns.example.const.colors.ending, frameType))
    frameLabel:SetJustifyH("LEFT")
    frameLabel:SetWordWrap(true)
    frameLabel:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", padding, -padding)
    frameLabel:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", -padding, -padding)
    local templateLabel = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    templateLabel:SetText(("%s%s%s %s"):format(ns.example.const.colors.white, "Frame Template", ns.example.const.colors.ending, frameTemplate))
    templateLabel:SetJustifyH("LEFT")
    templateLabel:SetWordWrap(true)
    templateLabel:SetPoint("TOPLEFT", frameLabel, "BOTTOMLEFT", 0, -padding)
    templateLabel:SetPoint("TOPRIGHT", frameLabel, "BOTTOMRIGHT", 0, -padding)
    -- rowHeight = rowHeight + frameLabel:GetStringHeight() + templateLabel:GetStringHeight() + (padding * 2)

    -- set the top left corder to the previous object
    if object ~= nil then
        object:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", 0, -padding)
        object:SetPoint("TOPRIGHT", templateLabel, "BOTTOMRIGHT", 0, -padding)
    end
    -- rowHeight = rowHeight + object:GetHeight()

    -- set row height
    -- ns:Print(("Row Height: %.1f"):format(rowHeight))
    -- groupFrame:SetHeight(rowHeight)

    local note = object:GetAttribute(ns.example.const.note)
    if note ~= nil then
        local noteString = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        noteString:SetText(("%s%s%s %s"):format(ns.example.const.colors.white, "Note:", ns.example.const.colors.ending, note))
        noteString:SetJustifyH("LEFT")
        noteString:SetJustifyV("TOP")
        if object ~= nil then
            noteString:SetPoint("TOPLEFT", object, "BOTTOMLEFT", 0, -padding)
            noteString:SetPoint("TOPRIGHT", object, "BOTTOMRIGHT", 0, -padding)
            noteString:SetPoint("BOTTOMLEFT", groupFrame, "BOTTOMLEFT", 0, padding)
        else
            noteString:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", 0, -padding)
            noteString:SetPoint("TOPRIGHT", templateLabel, "BOTTOMRIGHT", 0, -padding)
            noteString:SetPoint("BOTTOMLEFT", groupFrame, "BOTTOMLEFT", 0, padding)
        end
    end

    -- return the frame
    return groupFrame
end

function ns:ShowUI()
    local frameName = "MainFrame"

    -- if the MainFrame is not nil then exit early as the UI is already built
    if ns.example.ui.frames.MainFrame ~= nil then return end

    -- only create if frame is nil
    local mainFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplate")
    frameWidth = 800
    frameHeight = 600
    mainFrame:SetSize(frameWidth, frameHeight)
    mainFrame:SetAttribute("ExampleFrameName", frameName)
    ns.framePosn:RestoreFramePosition(mainFrame, mainFrame:GetAttribute("ExampleFrameName"), frameWidth, frameHeight)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", function(thisframe)
        -- must be self; since this is a frame function
        thisframe:StopMovingOrSizing()
        -- save location and size
        ns.framePosn:StoreFramePosition(mainFrame, frameName)
    end)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetFrameLevel(1)

    -- instantiate the tabs
    ns.tabDropdown:SetupTabDropdowns(mainFrame)
    ns.tabButton:SetupTabButtons(mainFrame)

    -- draw the tabs
    ns.tabs:ProcessTabSystem(mainFrame)

    -- show the frame
    ns.example.ui.frames.MainFrame = mainFrame
    if mainFrame:IsVisible() == false then
        ns.example.ui.frames.MainFrame:Show()
    end
end