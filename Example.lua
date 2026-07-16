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


function ns.example:CreateDropdown(parent, itemOrder, items, initialValue, frameName, frameTemplate, onChange)
    -- create dropdown and set it up
    local dropdown = CreateFrame("DropdownButton", frameName, parent, frameTemplate)

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

--[[---------------------------------------------------------------------------
    Function:   CreateFilterDropdown
    Purpose:    Create a drop down with a listing of tags. User picks one to only show the toys associated to the tag in a scrollbox.
    Arguments:  scrollKey - unique identifier for the instantion of this list as it can be used more than once since we use this same setup in multiple places
                parentFrame - used to position the drop down
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
    local dropdown = ns.example:CreateDropdown(frame, itemOrder, items, "one", nil, frameTemplate, function(key)
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
    table.insert(ns.example.objects, frame)
end

function ns:ExampleFrame()
    -- standard variables
    local padding = ns.example.const.padding

    -- create main frame
    if ns.example.ui.frames.MainFrame == nil then
        local frameName = "MainFrame"
        local mainFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplate")
        frameWidth = 400
        frameHeight = 400
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

        -- create first example dropdown
        ExampleDropdownOne(mainFrame, "WowStyle1DropdownTemplate")
        ExampleDropdownOne(mainFrame, "WowStyle1ArrowDropdownTemplate")
        ExampleDropdownOne(mainFrame, "WowStyle1FilterDropdownTemplate")
        -- ExampleDropdownOne(mainFrame, "WowStyle1ThinDropdownTemplate")   -- Errors
        -- ExampleDropdownOne(mainFrame, "AddToChatButtonTemplate")         -- Causes an error; think it needs something else to complete whatever setup is needed.
        ExampleDropdownOne(mainFrame, "WowStyle2DropdownTemplate")
        ExampleDropdownOne(mainFrame, "WowStyle2IconButtonTemplate")
        ExampleDropdownOne(mainFrame, "UIPanelIconDropdownButtonTemplate")

        -- create empty frame for easier positioning
        local startFrame = CreateFrame("Frame", nil, mainFrame) --, "InsetFrameTemplate")
        startFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", padding, 0)
        startFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -padding, 0)
        startFrame:SetHeight(20)
        startFrame:SetFrameStrata(mainFrame:GetFrameStrata())

        -- loop over all objects and stack them all from top down in the frame; keep track of height
        local height = padding * 3
        local posFrame = startFrame
        for idx, object in ipairs(ns.example.objects) do
            -- show which index item is being loaded
            ns:Print(("Processing Object: %d (Type: %s)"):format(idx, object:GetAttribute(ns.example.const.frameType)))

            -- track row height
            local rowHeight = 0

            -- row frame
            local row = CreateFrame("Frame", nil, mainFrame, "InsetFrameTemplate")
            row:SetPoint("TOPLEFT", posFrame, "BOTTOMLEFT", 0, -padding)
            row:SetPoint("TOPRIGHT", posFrame, "BOTTOMRIGHT", 0, -padding)
            row:SetFrameStrata("MEDIUM")
            row:SetFrameLevel(10)
            row:SetHeight(100)
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(row)
            bg:SetColorTexture(0, 0, 0, 0.7) -- Black, 80% opaque

            -- add text about object
            local frameLabel = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            frameLabel:SetText(("%s%s%s %s"):format(ns.example.const.colors.white, "Frame Type:", ns.example.const.colors.ending, object:GetAttribute(ns.example.const.frameType)))
            frameLabel:SetJustifyH("LEFT")
            frameLabel:SetWordWrap(true)
            frameLabel:SetPoint("TOPLEFT", row, "TOPLEFT", padding, -padding)
            frameLabel:SetPoint("TOPRIGHT", row, "TOPRIGHT", -padding, -padding)
            local templateLabel = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
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
            row:SetHeight(rowHeight)

            -- set position frame to the current object
            posFrame = row

            -- update height
            -- current height + the objects height + padding used after the object
            height = height + rowHeight + padding
        end

        -- set frame height
        mainFrame:SetHeight(height)

        -- assign main frame to ns
        ns.example.ui.frames.MainFrame = mainFrame
    end

    -- show the frame
    ns.example.ui.frames.MainFrame:Show()
end

function ns:ShowUI()
    ns:ExampleFrame()
end