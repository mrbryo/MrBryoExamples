--[[ ------------------------------------------------------------------------
	Title: 			Dropdowns.lua
	Author: 		mrbryo
	Create Date : 	2026-Jul-17
	Description: 	All tab functions for the addon.
-----------------------------------------------------------------------------]]

-- TODO: for the translation of the name make sure to setup your language files appropriotly

local addonName, ns = ...

-- namespace for this tab
ns.tabDropdown = {}




--[[---------------------------------------------------------------------------
    Function:   CreateDropdown
    Purpose:    Create a drop down.
    Arguments:  parentFrame -   dropdown frame parent and placement assignment
                itemOrder -     list of item keys to show the items in a specific order
                items -         table of items
                initialValue -  initial selected value of the drop down
                frameName -     name of the drop down
                frameTemplate - what drop down template to use
                onChange -      function to execute on the drop downs OnChange event
-----------------------------------------------------------------------------]]
local function CreateDropdown(parentFrame, itemOrder, items, initialValue, frameName, frameTemplate, onChange)
    -- create dropdown and set it up
    local dropdown = CreateFrame("DropdownButton", frameName, parentFrame, frameTemplate)

    -- store dropdown state
    dropdown.selectedValue = initialValue or ""
    if items == nil then
        dropdown.selectedText = itemOrder[initialValue] or ""
        dropdown.items = itemOrder
    else
        dropdown.selectedText = items[initialValue] or ""
        dropdown.items = items
    end
    dropdown.itemOrder = itemOrder

    -- external function; change selected value
    local function SetSelectedValue(key)
        --@debug@
        -- print("(CreateDropdown) SetSelectedValue called with key:", key)
        --@end-debug@
        if dropdown.items[key] then
            dropdown.selectedValue = key
            dropdown.selectedText = dropdown.items[key] or ""
        elseif dropdown.items[key] == nil then
            dropdown.selectedValue = key
            dropdown.selectedText = key
        else
            dropdown.selectedValue = ""
            dropdown.selectedText = ""
        end
        if onChange then
            onChange(key)
        end
    end

    -- function to check if a value is selected
    local function IsSelectedValue(key)
        return dropdown.selectedValue == key
    end

    -- function to build the dropdown menu from the items parameter
    local function GeneratorFunction(dropdown, rootDescription)
        -- add buttons for each item
        -- for key, value in pairs(dropdown.items) do
        for key, value in pairs(dropdown.itemOrder) do
            local radioValue = dropdown.items[value]
            local radioKey = value
            if items == nil then
                radioValue = value
                radioKey = key
            end
            rootDescription:CreateRadio(radioValue, IsSelectedValue, SetSelectedValue, radioKey)
        end
    end

    -- setup the menu
    dropdown:SetupMenu(GeneratorFunction)

    -- external function; update function
    function dropdown:UpdateItems(newItemOrder, newItems, newValue)
        --@debug@
        -- print("(CreateDropdown) New Value:", newValue)
        --@end-debug@
        if newItems == nil then
            self.selectedText = newItemOrder[newValue] or ""
            self.items = newItemOrder
        else
            self.selectedText = newItems[newValue] or ""
            self.items = newItems
        end
        self.itemOrder = newItemOrder
        SetSelectedValue(newValue)
        dropdown:GenerateMenu()
    end

    -- external function; get selected value
    function dropdown:GetSelectedValue()
        return self.selectedValue
    end

    -- set initial value if provided
    if initialValue and dropdown.items[initialValue] then
        SetSelectedValue(initialValue)
    end

    -- return the created dropdown
    return dropdown
end

local function ExampleFrame(parentFrame, object)
    -- standard variables
    local padding = ns.example.const.padding

    -- track row height
    local rowHeight = 0

    -- row frame
    local groupFrame = CreateFrame("Frame", nil, parentFrame, "InsetFrameTemplate")
    -- groupFrame:SetPoint("TOPLEFT", posFrame, "BOTTOMLEFT", 0, -padding)
    -- groupFrame:SetPoint("TOPRIGHT", posFrame, "BOTTOMRIGHT", 0, -padding)
    groupFrame:SetFrameStrata("MEDIUM")
    groupFrame:SetFrameLevel(10)
    groupFrame:SetHeight(100)
    local bg = groupFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(groupFrame)
    bg:SetColorTexture(0, 0, 0, 0.7) -- Black, 80% opaque

    -- add text about object
    local frameLabel = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    frameLabel:SetText(("%s%s%s %s"):format(ns.example.const.colors.white, "Frame Type:", ns.example.const.colors.ending, object:GetAttribute(ns.example.const.frameType)))
    frameLabel:SetJustifyH("LEFT")
    frameLabel:SetWordWrap(true)
    frameLabel:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", padding, -padding)
    frameLabel:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", -padding, -padding)
    local templateLabel = groupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    templateLabel:SetText(("%s%s%s %s"):format(ns.example.const.colors.white, "Frame Template", ns.example.const.colors.ending, object:GetAttribute(ns.example.const.template)))
    templateLabel:SetJustifyH("LEFT")
    templateLabel:SetWordWrap(true)
    templateLabel:SetPoint("TOPLEFT", frameLabel, "BOTTOMLEFT", 0, -padding)
    templateLabel:SetPoint("TOPRIGHT", frameLabel, "BOTTOMRIGHT", 0, -padding)
    rowHeight = rowHeight + frameLabel:GetStringHeight() + templateLabel:GetStringHeight() + (padding * 2)

    -- set the top left corder to the previous object
    object:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", 0, -padding)
    object:SetPoint("TOPRIGHT", templateLabel, "BOTTOMRIGHT", 0, -padding)
    rowHeight = rowHeight + object:GetHeight()

    -- set row height
    -- ns:Print(("Row Height: %.1f"):format(rowHeight))
    groupFrame:SetHeight(rowHeight)

    -- return the frame
    return groupFrame
end

--[[---------------------------------------------------------------------------
    Function:   ExampleDropdownOne
    Purpose:    Create a frame with objects to show a drop down as an example.
    Arguments:  parentFrame -   frame to assign as parent and for positioning of new content
                frameTemplate - what drop down template to use
-----------------------------------------------------------------------------]]
local function ExampleDropdownOne(parentFrame, frameTemplate)
    -- standard variables
    local padding = ns.example.const.padding

    -- initialize drop down items with "none" option
    local items = {
        ["one"] = "One",
        ["two"] = "Two",
        ["three"] = "Three",
        ["four"] = "Four",
        ["five"] = "Five",
    }

    -- create content frame
    local frame = CreateFrame("Frame", nil, parentFrame)

    -- set initial tag order
    local itemOrder = { "one", "two", "three", "four", "five" }

    local dropdownLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownLabel:SetJustifyH("LEFT")
    dropdownLabel:SetText(ns.L["Number:"])

    -- create dropdown
    local dropdown = CreateDropdown(frame, itemOrder, items, "one", nil, frameTemplate, function(key)
        ns:Print(("Example - Dropdown w/ Style '%s' - Selected Key: %s"):format(frameTemplate, key))
    end)
    dropdown:SetWidth(200)

    -- position the label and the dropdown
    local dropdownOffset = (dropdown:GetHeight() - dropdownLabel:GetStringHeight()) / 2
    dropdownLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -dropdownOffset)
    dropdown:SetPoint("LEFT", dropdownLabel, "RIGHT", padding, 0)

    -- set frame size
    local width = dropdown:GetWidth() + dropdownLabel:GetWidth() + (padding * 2)
    local height = dropdown:GetHeight() + (padding * 2)
    frame:SetSize(width, height)

    -- set attributes
    frame:SetAttribute(ns.example.const.template, frameTemplate)
    frame:SetAttribute(ns.example.const.frameType, "DropdownButton")

    -- store the value long term
    -- table.insert(ns.tabDropdown.objects, frame)
    return frame
end

--[[---------------------------------------------------------------------------
    Function:   BuildContent
    Purpose:    Build the tab content. This function must be defined for each tab and used in the SetupTab function for OnLoad.
-----------------------------------------------------------------------------]]
local function BuildContent(tabKey)
    -- exit if parent is nil
    local parentFrame = ns.tabs:GetFrame(tabKey)
    if parentFrame == nil then return end

    -- standard variables
    local padding = ns.example.const.padding

    -- see if top level frame exists, if so skip content creation; only purpose to make it easier to determine if content is created or not
    if ns.tabDropdown.frame == nil then return end

    -- create top level frame
    ns.tabDropdown.frame = CreateFrame("Frame", nil, parentFrame)
    ns.tabDropdown.frame:SetAllPoints()

    -- WowStyle1DropdownTemplate
    local object1 = ExampleDropdownOne(ns.tabDropdown.frame, "WowStyle1DropdownTemplate")
    local row1col1 = ExampleFrame(ns.tabDropdown.frame, object1)
    row1col1:SetPoint("TOPLEFT", ns.tabDropdown.frame, "TOPLEFT", 0, 0)

    -- WowStyle1ArrowDropdownTemplate
    local object2 = ExampleDropdownOne(ns.tabDropdown.frame, "WowStyle1ArrowDropdownTemplate")
    local row1col2 = ExampleFrame(ns.tabDropdown.frame, object2)
    row1col2:SetPoint("TOPLEFT", row1col1, "TOPRIGHT", padding, 0)

    -- WowStyle1FilterDropdownTemplate
    local object3 = ExampleDropdownOne(ns.tabDropdown.frame, "WowStyle1FilterDropdownTemplate")
    local row2col1 = ExampleFrame(ns.tabDropdown.frame, object3)
    row2col1:SetPoint("TOPLEFT", row1col1, "BOTTOMLEFT", 0, -padding)

    -- ExampleDropdownOne(ns.tabDropdown.frame, "WowStyle1ThinDropdownTemplate")   -- Errors
    -- ExampleDropdownOne(ns.tabDropdown.frame, "AddToChatButtonTemplate")         -- Causes an error; think it needs something else to complete whatever setup is needed.

    -- WowStyle2DropdownTemplate
    local object4 = ExampleDropdownOne(ns.tabDropdown.frame, "WowStyle2DropdownTemplate")
    local row2col2 = ExampleFrame(ns.tabDropdown.frame, object4)
    row2col2:SetPoint("TOPLEFT", row1col2, "BOTTOMLEFT", 0, -padding)

    -- WowStyle2IconButtonTemplate
    local object5 = ExampleDropdownOne(ns.tabDropdown.frame, "WowStyle2IconButtonTemplate")
    local row3col1 = ExampleFrame(ns.tabDropdown.frame, object5)
    row3col1:SetPoint("TOPLEFT", row2col1, "BOTTOMLEFT", 0, -padding)

    -- UIPanelIconDropdownButtonTemplate
    local object6 = ExampleDropdownOne(ns.tabDropdown.frame, "UIPanelIconDropdownButtonTemplate")
    local row3col2 = ExampleFrame(ns.tabDropdown.frame, object6)
    row3col2:SetPoint("TOPLEFT", row2col2, "BOTTOMLEFT", 0, -padding)

    -- set frame height
    -- ns.tabDropdown.frame:SetHeight(height)
end

--[[---------------------------------------------------------------------------
    Function:   SetupTabDropdowns
    Purpose:    Setup the Dropdown tab. This 'SetupTab' function must be defined for each tab.
    Arguments:  parentFrame - dropdown frame parent and placement assignment
-----------------------------------------------------------------------------]]
function ns.tabDropdown:SetupTabDropdowns(parentFrame)
    -- define the tab
    ns.tabDropdown.key = "dropdowns"

    -- on load function
    local function OnLoad(itself)
        BuildContent(ns.tabDropdown.key)
    end

    -- register the tab
    ns.tabs:RegisterTab(parentFrame, ns.tabDropdown.key, ns.L["Dropdowns"], true, OnLoad)
end