--[[ ------------------------------------------------------------------------
	Title: 			Dropdowns.lua
	Author: 		mrbryo
	Create Date : 	2026-Jul-17
	Description: 	All tab functions for the addon.
-----------------------------------------------------------------------------]]

-- TODO: for the translation of the name make sure to setup your language files appropriotly

local addonName, ns = ...

-- namespace for this tab
ns.tabButton = {
    -- define the tab key
    key = "buttons",
}

--[[---------------------------------------------------------------------------
    Function:   CreateSButton
    Purpose:    Create a button and content for example usage.
    Arguments:  parentFrame     - parent frame to attach this frame to
                name            - name for the button; nil is fine
                text            - button text/label
                width           - width of the button; nil is fine, it will use the text width
                onClick         - Callback function when the button is clicked
    Returns:    The created Button and frame.
-----------------------------------------------------------------------------]]
local function CreateButton(parentFrame, buttonName, text, width, template, onClick)
    -- create frame
    local frame = CreateFrame("Frame", nil, parentFrame)

    -- create the button
    frame.mybutton = CreateFrame("Button", buttonName, frame, template)

    -- update text
    if text ~= nil then
        frame.mybutton:SetText(text)
    end

    -- update the on click script
    frame.mybutton:SetScript("OnClick", onClick)

    -- determine width
    if width == nil then
        local textWidth = frame.mybutton:GetFontString():GetStringWidth()
        width = textWidth + 20  -- Add some padding
    end
    frame.mybutton:SetSize(width, 22)
    frame.mybutton:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

    -- set attributes
    frame:SetAttribute(ns.example.const.template, template)
    frame:SetAttribute(ns.example.const.frameType, "Button")
    frame:SetHeight(frame.mybutton:GetHeight())

    --@debug@
    -- ns:Print(("Button Width: %d, Height: %d"):format(frame.mybutton:GetWidth(), frame.mybutton:GetHeight()))
    --@end-debug@

    -- finally return the button
    return frame
end

local function BuildContent(tabKey)
    -- exit if parent is nil
    local parentFrame = ns.tabs:GetFrame(tabKey)
    if parentFrame == nil then return end

    -- standard variables
    local padding = ns.example.const.padding
    local rows = 4
    local cols = 2

    -- local functions
    local function ButtonOnClick(itself)
        local templateName = ns:GetAttribute(itself:GetParent(), ns.example.const.template)
        ns:Print(("Button for Template '%s' Clicked"):format(templateName))
    end

    -- see if top level frame exists, if so skip content creation; only purpose to make it easier to determine if content is created or not
    if ns.tabButton.groupFrame ~= nil then return end

    --@debug@
    ns:Print(("Tab Button BuildContent Triggered"))
    --@end-debug@

    -- create top level frame
    groupFrame = CreateFrame("Frame", nil, parentFrame)
    groupFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", padding, -padding)
    groupFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -padding, padding)

    -- define all the buttons
    local object1 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "GameMenuButtonTemplate", ButtonOnClick)
    local object2 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "UIPanelButtonTemplate", ButtonOnClick)
    -- UIButtonTemplate is invisible but causes no errors...
    local object3 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "UIPanelSquareButton", ButtonOnClick)
    --[[
        UIGoldBorderButtonTemplate produces an error:
        2x LUA_WARNING: Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.xml:872 Unknown: Couldn't find relative frame: $parentDetails
    ]]
    -- local object4 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "UIGoldBorderButtonTemplate", ButtonOnClick)
    local object4 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "UIPanelInfoButton", ButtonOnClick)
    local object5 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "SharedButtonTemplate", ButtonOnClick)
    local object6 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "SharedButtonExtraSmallTemplate", ButtonOnClick)
    local object7 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "InsecureActionButtonTemplate", ButtonOnClick)
    object7.mybutton:SetAttribute("type", "spell")
    object7.mybutton:SetAttribute("spell", "1231411")
    object7.mybutton:SetAttribute("unit", "player")
    object7.mybutton:SetAttribute("useOnKeyDown", false)
    object7.mybutton:RegisterForClicks("AnyUp")
    object7.mybutton:SetSize(32, 32)
    -- SecureActionButtonTemplate; I get error: Action[SetPoint] failed because[Cannot anchor protected frames to regions]: attempted from: Frame:SetPoint.
    -- local object8 = CreateButton(groupFrame, nil, ns.L["Button"], nil, "SecureActionButtonTemplate", ButtonOnClick)
    local object8 = nil

    -- build table
    local frames = {
        -- rows
        [1] = {
            -- columns
            [1] = ns:ExampleFrame(groupFrame, object1),
            [2] = ns:ExampleFrame(groupFrame, object2),
        },
        [2] = {
            [1] = ns:ExampleFrame(groupFrame, object3),
            [2] = ns:ExampleFrame(groupFrame, object4),
        },
        [3] = {
            [1] = ns:ExampleFrame(groupFrame, object5),
            [2] = ns:ExampleFrame(groupFrame, object6),
        },
        [4] = {
            [1] = ns:ExampleFrame(groupFrame, object7),
            [2] = ns:ExampleFrame(groupFrame, object8),
        }
    }

    -- position frames
    frames[1][1]:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 0, 0)
    frames[1][2]:SetPoint("TOPLEFT", frames[1][1], "TOPRIGHT", padding, 0)
    frames[2][1]:SetPoint("TOPLEFT", frames[1][1], "BOTTOMLEFT", 0, -padding)
    frames[2][2]:SetPoint("TOPLEFT", frames[1][2], "BOTTOMLEFT", 0, -padding)
    frames[3][1]:SetPoint("TOPLEFT", frames[2][1], "BOTTOMLEFT", 0, -padding)
    frames[3][2]:SetPoint("TOPLEFT", frames[2][2], "BOTTOMLEFT", 0, -padding)
    frames[4][1]:SetPoint("TOPLEFT", frames[3][1], "BOTTOMLEFT", 0, -padding)
    frames[4][2]:SetPoint("TOPLEFT", frames[3][2], "BOTTOMLEFT", 0, -padding)

    -- determine width and height and assign it to each frame
    local width = (parentFrame:GetWidth() - (padding * (cols + 1))) / cols
    local height = (parentFrame:GetHeight() - (padding * (rows + 1))) / rows
    for rowNbr, rowCols in pairs(frames) do
        for colNbr, _ in pairs(rowCols) do
            frames[rowNbr][colNbr]:SetSize(width, height)
        end
    end

    -- assign to namespace
    ns.tabButton.groupFrame = groupFrame
end


--[[---------------------------------------------------------------------------
    Function:   SetupTabDropdowns
    Purpose:    Setup the Dropdown tab. This 'SetupTab' function must be defined for each tab.
    Arguments:  parentFrame - dropdown frame parent and placement assignment
-----------------------------------------------------------------------------]]
function ns.tabButton:SetupTabButtons(parentFrame)
    -- on load function
    local function OnShow(itself)
        --@debug@
        ns:Print(("Tab Button OnShow Triggered"))
        --@end-debug@
        BuildContent(ns.tabButton.key)
    end

    -- register the tab
    ns.tabs:RegisterTab(parentFrame, ns.tabButton.key, ns.L["Buttons"], true, OnShow)
end