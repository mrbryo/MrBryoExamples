--[[ ------------------------------------------------------------------------
	Title: 			Dropdowns.lua
	Author: 		mrbryo
	Create Date : 	2026-Jul-17
	Description: 	All tab functions for the addon.
-----------------------------------------------------------------------------]]

-- TODO: for the translation of the name make sure to setup your language files appropriotly

local addonName, ns = ...

-- namespace for this tab
ns.tabDropdown = {
    key = "dropdowns"
}

-- local function CreateGenericDropdown(parentFrame, itemOrder, items, initialValue, frameName, frameTemplate, onChange)
--     local frame = CreateFrame("Frame", nil, parentFrame, frameTemplate)

--     ns:Print("Dropdown Parent Key: " .. tostring(frame.Dropdown:GetParentKey()))

--     -- local dropdown = nil
--     -- for i, childx in ipairs({frame:GetChildren()}) do
--     --     -- ns:Print(("(A) Child %d - Object Type: %s - Parent Key: %s - Children: %s"):format(i, tostring(childx:GetObjectType()), tostring(childx:GetParentKey()), tostring(childx:GetNumChildren())))
--     --     for y, childy in ipairs({childx:GetChildren()}) do
--     --         -- ns:Print(("(B) Child %d - Object Type: %s - Parent Key: %s - Children: %s"):format(y, tostring(childy:GetObjectType()), tostring(childy:GetParentKey()), tostring(childy:GetNumChildren())))
--     --         if childy:GetParentKey() == "Dropdown" then
--     --             dropdown = childy
--     --         end
--     --         -- for j, childj in ipairs({childy:GetChildren()}) do
--     --         --     ns:Print(("(C) Child %d - Object Type: %s - Parent Key: %s - Children: %s"):format(j, tostring(childj:GetObjectType()), tostring(childj:GetParentKey()), tostring(childj:GetNumChildren())))
--     --         -- end
--     --     end
--     -- end

--     if frame.Dropdown == nil then
--         ns:Print("Dropdown Not Found!")
--     else
--         ns:Print("Dropdown Found!")

--         -- store dropdown state
--         frame.Dropdown.selectedValue = initialValue or ""
--         if items == nil then
--             frame.Dropdown.selectedText = itemOrder[initialValue] or ""
--             frame.Dropdown.items = itemOrder
--         else
--             frame.Dropdown.selectedText = items[initialValue] or ""
--             frame.Dropdown.items = items
--         end
--         frame.Dropdown.itemOrder = itemOrder

--         -- external function; change selected value
--         local function SetSelectedValue(key)
--             --@debug@
--             -- print("(CreateDropdown) SetSelectedValue called with key:", key)
--             --@end-debug@
--             if frame.Dropdown.items[key] then
--                 frame.Dropdown.selectedValue = key
--                 frame.Dropdown.selectedText = frame.Dropdown.items[key] or ""
--             elseif frame.Dropdown.items[key] == nil then
--                 frame.Dropdown.selectedValue = key
--                 frame.Dropdown.selectedText = key
--             else
--                 frame.Dropdown.selectedValue = ""
--                 frame.Dropdown.selectedText = ""
--             end
--             if onChange then
--                 onChange(key)
--             end
--         end

--         -- function to check if a value is selected
--         local function IsSelectedValue(key)
--             return frame.Dropdown.selectedValue == key
--         end

--         -- function to build the dropdown menu from the items parameter
--         local function GeneratorFunction(dropdown, rootDescription)
--             -- add buttons for each item
--             -- for key, value in pairs(dropdown.items) do
--             for key, value in pairs(dropdown.itemOrder) do
--                 local radioValue = dropdown.items[value]
--                 local radioKey = value
--                 if items == nil then
--                     radioValue = value
--                     radioKey = key
--                 end
--                 rootDescription:CreateRadio(radioValue, IsSelectedValue, SetSelectedValue, radioKey)
--             end
--         end

--         -- setup the menu
--         frame.Dropdown:SetupMenu(GeneratorFunction)

--         -- external function; update function
--         function frame.Dropdown:UpdateItems(newItemOrder, newItems, newValue)
--             --@debug@
--             -- print("(CreateDropdown) New Value:", newValue)
--             --@end-debug@
--             if newItems == nil then
--                 self.selectedText = newItemOrder[newValue] or ""
--                 self.items = newItemOrder
--             else
--                 self.selectedText = newItems[newValue] or ""
--                 self.items = newItems
--             end
--             self.itemOrder = newItemOrder
--             SetSelectedValue(newValue)
--             frame.Dropdown:GenerateMenu()
--         end

--         -- external function; get selected value
--         function frame.Dropdown:GetSelectedValue()
--             return self.selectedValue
--         end

--         -- set initial value if provided
--         if initialValue and frame.Dropdown.items[initialValue] then
--             SetSelectedValue(initialValue)
--         end
--     end

--     return frame
-- end

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
    local dropdown = nil
    local frame = nil
    if frameTemplate == "SettingsDropdownWithButtonsTemplate" then
        frame = CreateFrame("Frame", nil, parentFrame, frameTemplate)
        dropdown = frame.Dropdown
    else
        dropdown = CreateFrame("DropdownButton", frameName, parentFrame, frameTemplate)
    end

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
    if frameTemplate == "SettingsDropdownWithButtonsTemplate" then
        return frame
    else
        return dropdown
    end
end

--[[
Not working. Need further research in how blizzard implement's this drop down.
]]
-- local function ExampleAdvancedDropdown(parentFrame)
--     -- define the template
--     local frameTemplate = "SettingsAdvancedDropdownTemplate"

--     -- create the dropdown
--     local dropdown = CreateFrame("Frame", nil, parentFrame, frameTemplate)

--     -- set initial size
--     dropdown:SetSize(200, 30)

--     -- instantiate data
--     local items = {
--         { value = "one", text = "One" },
--         { value = "two", text = "Two" },
--         { value = "three", text = "Three" },
--         { value = "four", text = "Four" },
--         { value = "five", text = "Five" }
--     }

--     -- set the items in the dropdown
--     dropdown:SetItems(items)

--     -- set initial value
--     dropdown:SetSelectedValue("one")

--     -- hook on change
--     dropdown:SetScript("OnValueChanged", function(itself, value)
--         ns:Print(("Example - Dropdown w/ Style '%s' - Selected Key: %s"):format(frameTemplate, value))
--     end)
-- end

-- local function ExampleDropdownWithButtons(parentFrame, frameTemplate)
--     -- standard variables
--     local padding = ns.example.const.padding
--     local dropdownWithSteppers = false
--     local frame = nil

--     -- initialize drop down items with "none" option
--     local items = {
--         ["one"] = "One",
--         ["two"] = "Two",
--         ["three"] = "Three",
--         ["four"] = "Four",
--         ["five"] = "Five",
--     }

--     -- set initial tag order
--     local itemOrder = { "one", "two", "three", "four", "five" }

--     -- local functions
--     local function Decrement(itself)

--     end
--     local function Increment(itself)

--     end

--     -- create content frame
--     frame = CreateFrame("Frame", nil, parentFrame)

--     -- create label
--     local dropdownLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
--     dropdownLabel:SetJustifyH("LEFT")
--     dropdownLabel:SetText(ns.L["Number:"])
--     dropdownLabel:SetPoint("LEFT", frame, "LEFT", 0, 0)

--     -- create dropdown parent frame to position the buttons and dropdown easier
--     local dropdownFrame = CreateFrame("Frame", nil, frame)

--     -- create dropdown
--     local dropdown = CreateDropdown(dropdownFrame, itemOrder, items, "one", nil, frameTemplate, function(key)
--         ns:Print(("Example - Dropdown w/ Style '%s' - Selected Key: %s"):format(frameTemplate, key))
--     end)

--     -- set dropdown frame height and position
--     local newHeight = dropdown:GetHeight()
--     dropdownFrame:SetHeight(newHeight)
--     dropdownFrame:SetPoint("LEFT", dropdownLabel, "RIGHT", padding, 0)
--     dropdownFrame:SetPoint("RIGHT", frame, "RIGHT", -padding, 0)

--     -- decrement button
--     local btnLeft = CreateFrame("Button", nil, dropdownFrame, "")
--     btnLeft:SetNormalAtlas("common-dropdown-icon-back")
--     btnLeft:SetDisabledAtlas("common-dropdown-icon-back-disabled")
--     -- if btnLeft.Icon == nil then
--     --     ns:Print(("Button Left Icon is NIL"))
--     -- else
--     --     ns:Print(("Button Left Icon Name: %s"):format(tostring(btnLeft.Icon)))
--     -- end
--     btnLeft:SetScript("OnClick", Decrement)
--     btnLeft:SetPoint("TOPLEFT", dropdownFrame, "TOPLEFT", 0, 0)

--     -- position dropdown
--     dropdown:SetPoint("TOPLEFT", btnLeft, "TOPRIGHT", padding, 0)

--     -- increment button
--     local btnRight = CreateFrame("Button", nil, dropdownFrame, "WowStyle2IconButtonTemplate")
--     btnRight:SetNormalAtlas("common-dropdown-icon-next")
--     btnRight:SetDisabledAtlas("common-dropdown-icon-next-disabled")
--     btnRight:SetScript("OnClick", Increment)
--     btnRight:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", padding, 0)
--     -- btnRight:SetPoint("BOTTOMRIGHT", dropdownFrame, "BOTTOMRIGHT", 0, 0)

--     -- set width of dropdown frame
--     local newWidth = btnLeft:GetWidth() + btnRight:GetWidth() + dropdown:GetWidth() + (padding * 2)
--     ns:Print(("Dropdown Height: %d, Width: %d"):format(newHeight, newWidth))
--     dropdownFrame:SetWidth(newWidth)

--     -- update frame size
--     frame:SetSize(newWidth + padding + dropdownLabel:GetWidth(), newHeight)

--     -- set attributes
--     frame:SetAttribute(ns.example.const.template, frameTemplate)
--     frame:SetAttribute(ns.example.const.frameType, "DropdownButton")
--     frame:SetAttribute(ns.example.const.note, "Attempt to copy Blizzard template DropdownWithSteppersTemplate.")

--     -- return top level frame
--     return frame
-- end

--[[---------------------------------------------------------------------------
    Function:   ExampleDropdownOne
    Purpose:    Create a frame with objects to show a drop down as an example.
    Arguments:  parentFrame -   frame to assign as parent and for positioning of new content
                frameTemplate - what drop down template to use
-----------------------------------------------------------------------------]]
local function ExampleDropdownOne(parentFrame, frameTemplate)
    -- standard variables
    local padding = ns.example.const.padding
    local dropdownWithSteppers = false
    local frame = nil

    -- local functions
    local function OnClick(key)
        ns:Print(("Example - Dropdown w/ Style '%s' - Selected Key: %s"):format(frameTemplate, key))
    end

    -- initialize drop down items with "none" option
    local items = {
        ["one"] = "One",
        ["two"] = "Two",
        ["three"] = "Three",
        ["four"] = "Four",
        ["five"] = "Five",
    }

    -- create content frame
    frame = CreateFrame("Frame", nil, parentFrame)

    -- set initial tag order
    local itemOrder = { "one", "two", "three", "four", "five" }

    -- create label
    local dropdownLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownLabel:SetJustifyH("LEFT")
    dropdownLabel:SetText(ns.L["Number:"])

    -- create dropdown
    local dropdown = CreateDropdown(frame, itemOrder, items, "one", nil, frameTemplate, OnClick)

    -- have to check for nil now that dropdown is instantiated as nil in the CreateDropdown function; it should never be nil though unless blizzard changes something about their templates
    if dropdown ~= nil then
        -- position the label and the dropdown
        local dropdownOffset = (dropdown:GetHeight() - dropdownLabel:GetStringHeight()) / 2
        dropdownLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -dropdownOffset)
        dropdown:SetPoint("LEFT", dropdownLabel, "RIGHT", padding, 0)

        -- set frame size
        local width = dropdown:GetWidth() + dropdownLabel:GetWidth() + (padding * 2)
        local height = dropdown:GetHeight() -- + (padding * 2)
        frame:SetSize(width, height)
    end

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
    local rows = 3
    local cols = 2

    -- see if top level frame exists, if so skip content creation; only purpose to make it easier to determine if content is created or not
    if ns.tabDropdown.groupFrame ~= nil then return end

    --@debug@
    ns:Print(("Tab Dropdown BuildContent Triggered"))
    --@end-debug@

    -- create top level frame
    groupFrame = CreateFrame("Frame", nil, parentFrame)
    groupFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", padding, -padding)
    groupFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -padding, padding)

    -- create dropdowns
    local object1 = ExampleDropdownOne(groupFrame, "WowStyle1DropdownTemplate")
    local object2 = ExampleDropdownOne(groupFrame, "WowStyle1ArrowDropdownTemplate")
    local object3 = ExampleDropdownOne(groupFrame, "WowStyle1FilterDropdownTemplate")
    local object4 = ExampleDropdownOne(groupFrame, "WowStyle2DropdownTemplate")
    --[[ 
        Can't call directly in LUA, the template seems to require a dropdown as part of the frame when its created: DropdownWithSteppersTemplate
        So, I will have to custom build it until I can figure it out. Close enough!
        Can't seem to figure out how to recreate the side buttons. Revisit later...
    ]]
    -- local object5 = ExampleDropdownWithButtons(groupFrame, "WowStyle2DropdownTemplate")
    -- I don't think WowStyle2IconButtonTemplate is meant to be used by itself...it was meant for the DropdownWithSteppersTemplate.
    -- local object5 = ExampleDropdownOne(groupFrame, "WowStyle2IconButtonTemplate")

    -- attempting Metal2DropdownWithSteppersAndLabelTemplate which inherits from DropdownWithSteppersTemplate
    local object5 = ExampleDropdownOne(groupFrame, "SettingsDropdownWithButtonsTemplate")
    object5:SetAttribute(ns.example.const.note, "Yes, it is working mostly except the increment and decrement buttons are not updating correctly.")

    -- object5.Dropdown:SetPoint(nil, nil, nil, 0, 0)
    local object6 = ExampleDropdownOne(groupFrame, "UIPanelIconDropdownButtonTemplate")

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
    }

    -- position frames
    frames[1][1]:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 0, 0)
    frames[1][2]:SetPoint("TOPLEFT", frames[1][1], "TOPRIGHT", padding, 0)
    frames[2][1]:SetPoint("TOPLEFT", frames[1][1], "BOTTOMLEFT", 0, -padding)
    frames[2][2]:SetPoint("TOPLEFT", frames[1][2], "BOTTOMLEFT", 0, -padding)
    frames[3][1]:SetPoint("TOPLEFT", frames[2][1], "BOTTOMLEFT", 0, -padding)
    frames[3][2]:SetPoint("TOPLEFT", frames[2][2], "BOTTOMLEFT", 0, -padding)

    -- determine width and height and assign it to each frame
    local width = (parentFrame:GetWidth() - (padding * (cols + 1))) / cols
    local height = (parentFrame:GetHeight() - (padding * (rows + 1))) / rows
    for rowNbr, rowCols in pairs(frames) do
        for colNbr, _ in pairs(rowCols) do
            frames[rowNbr][colNbr]:SetSize(width, height)
        end
    end

    -- local row1col1 = ExampleFrame(contentFrame, object1)
    -- row1col1:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, 0)
    -- local row1col2 = ExampleFrame(contentFrame, object2)
    -- row1col2:SetPoint("TOPLEFT", row1col1, "TOPRIGHT", padding, 0)
    -- local row2col1 = ExampleFrame(contentFrame, object3)
    -- row2col1:SetPoint("TOPLEFT", row1col1, "BOTTOMLEFT", 0, -padding)

    -- ExampleDropdownOne(contentFrame, "WowStyle1ThinDropdownTemplate")   -- Errors
    -- ExampleDropdownOne(contentFrame, "AddToChatButtonTemplate")         -- Causes an error; think it needs something else to complete whatever setup is needed.

    -- local row2col2 = ExampleFrame(contentFrame, object4)
    -- row2col2:SetPoint("TOPLEFT", row1col2, "BOTTOMLEFT", 0, -padding)
    -- local row3col1 = ExampleFrame(contentFrame, object5)
    -- row3col1:SetPoint("TOPLEFT", row2col1, "BOTTOMLEFT", 0, -padding)
    -- local row3col2 = ExampleFrame(contentFrame, object6)
    -- row3col2:SetPoint("TOPLEFT", row2col2, "BOTTOMLEFT", 0, -padding)

    -- assign to namespace
    ns.tabDropdown.groupFrame = groupFrame
end

--[[---------------------------------------------------------------------------
    Function:   SetupTabDropdowns
    Purpose:    Setup the Dropdown tab. This 'SetupTab' function must be defined for each tab.
    Arguments:  parentFrame - dropdown frame parent and placement assignment
-----------------------------------------------------------------------------]]
function ns.tabDropdown:SetupTabDropdowns(parentFrame)
    -- on load function
    local function OnShow(itself)
        --@debug@
        ns:Print(("Tab Dropdown OnShow Triggered"))
        --@end-debug@
        BuildContent(ns.tabDropdown.key)
    end

    -- register the tab
    ns.tabs:RegisterTab(parentFrame, ns.tabDropdown.key, ns.L["Dropdowns"], true, OnShow)
end