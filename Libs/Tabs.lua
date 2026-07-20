--[[ ------------------------------------------------------------------------
	Title: 			Tabs.lua
	Author: 		mrbryo
	Create Date : 	2026-Jul-17
	Description: 	All tab functions for the addon.
-----------------------------------------------------------------------------]]

local addonName, ns = ...

ns.tabs = {
    order = {},
    name = {},
    -- onload = {},
    buttons = {},
    buttonIndex = {},
    frames = {},
    -- TODO: Developer must set one of the tabs as the default tab; but only set one, the last one registered with a true default value will be the default tab
    defaultTab = ""
}

function ns.tabs:SetDefault(key)
    ns.tabs.defaultTab = key
end

function ns.tabs:GetDefault()
    return ns.tabs.defaultTab
end

function ns.tabs:RegisterTab(parentFrame, tabKey, name, default, OnLoad)
    -- check if nil
    if tabKey == nil then
        self:Print((ns.L["Error: tabKey (%s) provided to CreateTabContentFrame is invalid."]):format(tostring(tabKey)))
        return false
    end

    -- insert key to set its order
    table.insert(ns.tabs.order, tabKey)

    -- add name
    ns.tabs.name[tabKey] = name

    -- default set
    if default == true then
        ns.tabs:SetDefault(tabKey)
    end

    -- add the function to trigger for onload
    -- ns.tabs.onload[tabKey] = OnLoad

    -- check if content frame exists, if not create it
    if ns.tabs.frames[tabKey] == nil then
        -- create the frame
        local frame = CreateFrame("Frame", nil, parentFrame) --, "InsetFrameTemplate")
        frame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -20)
        -- 2 points of Y movement aligns the main frame to the tab content frame...due to the graphical edge I think.
        frame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", 0, 2)
        -- hide it
        frame:Hide()
        -- set onshow to build the UI
        frame:SetScript("OnShow", OnLoad)
        -- assign to namespace
        ns.tabs.frames[tabKey] = frame
    end
end

local function TabShow(key)
    if ns.tabs.frames[key] ~= nil then
        ns.tabs.frames[key]:Show()
        --@debug@
        ns:Print(("Tab Shown: %s"):format(key))
        --@end-debug@
    else
        --@debug@
        ns:Print(("Tab Not Shown: %s"):format(key))
        --@end-debug@
    end
end

local function TabHide(key)
    if ns.tabs.frames[key] ~= nil then
        ns.tabs.frames[key]:Hide()
        --@debug@
        ns:Print(("Tab Hidden: %s"):format(key))
        --@end-debug@
    else
        --@debug@
        ns:Print(("Tab Not Hidden: %s"):format(key))
        --@end-debug@
    end
end

--[[---------------------------------------------------------------------------
    Function:   ShowTabContent
    Purpose:    Show the content for the selected tab.
-----------------------------------------------------------------------------]]
function ns.tabs:ShowTabContent(tabKey)
    -- get current tab to hide
    local currentTab = ns.tabs:GetTab()

    -- hide the tab if it isn't already set as the current tab
    if currentTab ~= tabKey then
        TabHide(currentTab)
    end

    -- set the tab
    ns.tabs:SetTab(tabKey)

    -- switch to the selected tab
    TabShow(tabKey)
end

--[[---------------------------------------------------------------------------
    Function:   ProcessTabSystem
    Purpose:    Create a tab system at the bottom of the main frame.
-----------------------------------------------------------------------------]]
function ns.tabs:ProcessTabSystem(parentFrame)
    -- check to see if tab system already exists; if not create the main frame to hold the tabs
    if ns.tabs.tabframe == nil then
        -- create a frame to hold the tabs
        ns.tabs.tabframe = CreateFrame("Frame", nil, parentFrame)

        -- position tabs at the bottom of the frame like Collections Journal
        ns.tabs.tabframe:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 10, -5)
        ns.tabs.tabframe:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -10, -5)
        ns.tabs.tabframe:SetHeight(30)
    end

    -- keep track of tab count
    local tabCount = 0

    -- track previous tab key
    local prevTabKey = nil

    -- create tab buttons using PanelTabButtonTemplate
    for tabIndex, tabKey in ipairs(ns.tabs.order) do
        -- if tabButtonID doesn't exist create it
        if ns.tabs.buttons[tabKey] == nil then
            -- use PanelTabButtonTemplate for authentic Collections UI styling
            ns.tabs.buttons[tabKey] = CreateFrame("Button", nil, ns.tabs.tabframe, "PanelTabButtonTemplate")
            ns.tabs.buttons[tabKey]:SetID(tabIndex)
            ns.tabs.buttons[tabKey]:SetText(ns.tabs.name[tabKey])
            ns.tabs.buttonIndex[tabKey] = tabIndex

            -- use PanelTemplates functions for proper tab behavior
            PanelTemplates_TabResize(ns.tabs.buttons[tabKey], 0)

            -- set the buttons OnClick event
            ns.tabs.buttons[tabKey]:SetScript("OnClick", function(btn)
                --@debug@
                -- ns:Print(("Tab Clicked: %s (ID: %d)"):format(tabname, self:GetID()))
                --@end-debug@
                -- use PanelTemplates to handle tab selection properly
                PanelTemplates_SetTab(ns.tabs.tabframe, btn:GetID())

                -- create the content for the tab
                ns.tabs:ShowTabContent(tabKey)
            end)
        end

        --@debug@
        ns:Print(("(tabs:ProcessTabSystem) Tab Index: %d, Tab Key: %s, Prev Tab Key: %s"):format(tabIndex, tabKey, tostring(prevTabKey)))
        --@end-debug@

        -- position tabs horizontally with proper spacing for Collections style
        if tabIndex == 1 then
            ns.tabs.buttons[tabKey]:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 11, 2)
        else
            ns.tabs.buttons[tabKey]:SetPoint("LEFT", ns.tabs.buttons[prevTabKey], "RIGHT", 0, 0)
        end

        -- count the tabs
        tabCount = tabCount + 1

        -- update previous tag key
        prevTabKey = tabKey
    end

    -- Set up the tab frame with PanelTemplates
    PanelTemplates_SetNumTabs(ns.tabs.tabframe, tabCount)

    -- set the proper tab to be selected based on the user's last selection
    local tabIndex = ns.tabs.buttonIndex[ns.tabs:GetTab()]
    PanelTemplates_SetTab(ns.tabs.tabframe, tabIndex)

    -- show the tab content
    ns.tabs:ShowTabContent(ns.tabs:GetTab())
end

--[[---------------------------------------------------------------------------
    Function:   GetTab
    Purpose:    Get the current selected tab in the options.
-----------------------------------------------------------------------------]]
function ns.tabs:GetTab()
    local tabValue = ns.db.profile[ns.player:GetProfileID()].mytab

    if tabValue == nil then
        ns.tabs:SetTab(ns.tabs.defaultTab)
        tabValue = ns.tabs.defaultTab
    end

    --@debug@
    -- ns:Print("(GetTab) ID: " .. tostring(tabValue) .. " for " .. tostring(ns.player.currentPlayerServer))
    --@end-debug@
    return tabValue
end

--[[---------------------------------------------------------------------------
    Function:   SetTab
    Purpose:    Set the current selected tab in the options.
-----------------------------------------------------------------------------]]
function ns.tabs:SetTab(key)
    --@debug@
    -- ns:Print("(SetTab) Setting tab to: " .. tostring(key) .. " for " .. tostring(ns.player.currentPlayerServer))
    --@end-debug@

    -- update the current tab
    ns.db.profile[ns.player:GetProfileID()].mytab = key
end

--[[---------------------------------------------------------------------------
    Function:   GetFrame
    Purpose:    Return the frame for the tab.
-----------------------------------------------------------------------------]]
function ns.tabs:GetFrame(tabKey)
    -- get the frame
    local frame = ns.tabs.frames[tabKey]

    -- check for nil and report error
    if frame == nil then
        ns:Print((ns.L["Error: Tab Frame for key '%s' is not Initialized! Reload your game (/reload) and if it happens again please open a ticket."]):format(tabKey))
    end

    -- not nil if gets to here so return it
    return frame
end

--[[---------------------------------------------------------------------------
    Function:   CreateTabContentFrame
    Purpose:    Create a standard content frame for a tab.
    Arguments:  tabKey - unique key for the tab (e.g., "about", "introduction", "tagmaint", "toymaint", "developer")
-----------------------------------------------------------------------------]]
-- function ns.tabs:CreateTabContentFrame(tabKey, parentFrame)
--     --@debug@
--     -- ns:Print(("(CreateTabContentFrame) Called with tabKey: %s"):format(tostring(tabKey)))
--     --@end-debug@

--     -- check if nil
--     if tabKey == nil then
--         self:Print((ns.L["Error: tabKey (%s) provided to CreateTabContentFrame is invalid."]):format(tostring(tabKey)))
--         return false
--     end

--     -- check if content frame exists, if not create it
--     if ns.tabs.frames[tabKey] == nil then
--         -- create the frame
--         ns.tabs.frames[tabKey] = CreateFrame("Frame", nil, parentFrame) --, "InsetFrameTemplate")
--         ns.tabs.frames[tabKey]:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -20)
--         -- 2 points of Y movement aligns the main frame to the tab content frame...due to the graphical edge I think.
--         ns.tabs.frames[tabKey]:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", 0, 2)
--     end
-- end