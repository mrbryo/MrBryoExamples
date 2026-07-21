--[[ ------------------------------------------------------------------------
	Title: 			Frames.lua
	Author: 		mrbryo
	Create Date : 	2026-Jul-21
	Description: 	Build the Frames tab.
-----------------------------------------------------------------------------]]

-- TODO: for the translation of the name make sure to setup your language files appropriotly

local addonName, ns = ...

-- namespace for this tab
ns.tabFrame = {
    key = "frames",
    scroll = {},
    objects = {},
    nilcount = 0,
}

local function ExampleFrameType(parentFrame, frameTemplate, width, height, backdrop)
    -- determine object key
    local objectKey = frameTemplate
    if objectKey == nil then
        ns.tabFrame.nilcount = ns.tabFrame.nilcount + 1
        objectKey = ("NIL%d"):format(ns.tabFrame.nilcount)
    end
    -- if the frame already exists don't rebuild it
    if ns.tabFrame.objects[objectKey] ~= nil then return ns.tabFrame.objects[objectKey].example end

    -- standard variables
    local padding = ns.example.const.padding

    -- create the frame to hold example
    local frame = CreateFrame("Frame", nil, parentFrame)

    -- set size
    if height == nil then height = 50 end
    frame:SetSize(100, height)

    -- local teststr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    -- teststr:SetText("Test")
    -- teststr:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)

    -- create the frame example
    local frameExample = CreateFrame("Frame", nil, frame, frameTemplate)
    frameExample:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    frameExample:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, padding)
    frameExample:SetHeight(height)

    -- set backdrop if property exists
    if backdrop ~= nil then
        frameExample:SetBackdrop(backdrop)
        frameExample:SetBackdropColor(0, 0, 0, 1)       -- black, fully opaque
        frameExample:SetBackdropBorderColor(1, 1, 1, 1) -- white border
    end

    -- set attributes
    frame:SetAttribute(ns.example.const.template, frameTemplate)
    frame:SetAttribute(ns.example.const.frameType, "Frame")
    frame:SetSize(frameExample:GetWidth(), frameExample:GetHeight())

    -- create the example frame with frame type example
    local example = ns:ExampleFrame(parentFrame, frame)
    example:SetWidth(width)

    -- keep local creation of object to prevent rebuild
    ns.tabFrame.objects[objectKey] = {
        frame = frame,
        frameExample = frameExample,
        example = example,
    }

    -- return it
    return example
end

local function CreateScroll(parentFrame)
    -- standard variables
    local padding = ns.example.const.padding

    -- make sure row heights is populated for this scroll list
    if ns.tabFrame.scroll.rowHeight == nil then
        ns.tabFrame.rowHeight = {}
    end

    -- local function to set row heights
    local function SetHeight(dataIndex, data)
        for _, rcd in ipairs(data) do
            ns:Print(("SetHeight - Rcd: %s"):format(tostring(rcd)))
        end
        local height = ns.tabFrame.rowHeight[data.rowNbr]
        if height == nil then
            height = 50
        end
        return height
    end

    -- local function to style each row based on style
    local function PopulateRow(frame, data)
        -- create frame for the row
        local row = CreateFrame("Frame", nil, frame)
        -- row:SetAllPoints(frame)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        row:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, padding)

        -- local teststr = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        -- teststr:SetText("Test")
        -- teststr:SetPoint("TOPLEFT", row, "TOPLEFT", padding, -padding)

        -- assign objects
        local previousObject = nil
        local maxHeight = 0
        local width = (row:GetWidth() - ((#data.cols - 1) * padding)) / #data.cols
        for colNbr, object in ipairs(data.cols) do
            -- create the example frame with example frame object in it
            local example = ExampleFrameType(row, object.template, width, object.height, object.backdrop)
            maxHeight = math.max(maxHeight, example:GetHeight())

            if previousObject == nil then
                example:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
                -- ns:Print(("(Frames.PopulateRow:Col 1:%d) Row: %d; Template: %s; Width: %d; Height: %d"):format(colNbr, data.rowNbr, tostring(object.template), width, maxHeight))
            else
                example:SetPoint("TOPLEFT", previousObject, "TOPRIGHT", padding, 0)
                -- ns:Print(("(Frames.PopulateRow:Col N:%d) Row: %d; Template: %s; Width: %d; Height: %d"):format(colNbr, data.rowNbr, tostring(object.template), width, maxHeight))
            end
            example:SetWidth(width)

            -- remember current example frame
            previousObject = example
        end

        -- set height
        frame:SetHeight(maxHeight + padding)

        -- store height
        ns.tabFrame.rowHeight[data.rowNbr] = maxHeight
    end

    -- 1. Create components
    local scrollBox = CreateFrame("Frame", nil, parentFrame, "WowScrollBoxList")
    scrollBox:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, 0)
    scrollBox:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -20, 5)

    local scrollBar = CreateFrame("EventFrame", nil, parentFrame, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 4, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 4, 0)

    -- 2. Configure view with fixed row height; for variable-height elements
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtentCalculator(SetHeight)

    -- 3. Element initializer (called when a row becomes visible); BackdropTemplate by itself is just a transparent frame with nothing until you set its backdrop
    local rowTemplate = "BackdropTemplate"
    view:SetElementInitializer(rowTemplate, PopulateRow)

    -- 4. Element resetter (cleanup when row scrolls out of view)
    view:SetElementResetter(PopulateRow)

    -- 5. Connect everything
    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

    -- 6. Auto-hide scrollbar when not needed
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar)

    --@debug@
    -- ns:Print("Created Scroll Box List for Toys")
    --@end-debug@

    -- return scrollBox
    ns.tabFrame.scrollview = view
    ns.tabFrame.scrollbox = scrollBox
end

local function PopulateData()
    -- create data provided for scrollbox
    if ns.tabFrame.dp == nil then
        -- instantiate the date provider
        ns.tabFrame.dp = CreateDataProvider()

        -- pass refreshed data into scroll box
        ns.tabFrame.scrollbox:SetDataProvider(ns.tabFrame.dp)
    end

    -- specify data
    local data = {
        {
            cols = {
                {
                    template = "BackdropTemplate",
                    backdrop = {
                        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        tile = true,
                        tileSize = 16,
                        edgeSize = 16,
                        insets = { left = 4, right = 4, top = 4, bottom = 4 },
                    }
                },
                { template = "ButtonFrameTemplate", height = 150 },
            },
            rowNbr = 1,
        },{
            cols = {
                { template = "DefaultPanelTemplate", height = 100 },
                { template = "DefaultPanelFlatTemplate", height = 100 },
            },
            rowNbr = 2,
        },{
            cols = {
                { template = "BasicFrameTemplate", height = 100 },
                { template = "BasicFrameTemplateWithInset", height = 100 },
            },
            rowNbr = 3,
        },{
            cols = {
                { template = "DialogBorderTemplate" },
                { template = "DialogBorderTranslucentTemplate", height = 150 },
            },
            rowNbr = 4,
        },{
            cols = {
                { template = "TranslucentFrameTemplate" },
                { template = "InsetFrameTemplate", height = 150 },
            },
            rowNbr = 5,
        },{
            cols = {
                { template = "InsetFrameTemplate3" },
                { template = "TooltipBorderedFrameTemplate", height = 150 },
            },
            rowNbr = 6,
        },{
            cols = {
                { template = "UIPanelDialogTemplate" },
                { template = "PortraitFrameTemplate", height = 150 },
            },
            rowNbr = 7,
        },{
            cols = {
                { template = "PortraitFrameFlatTemplate" },
                { template = nil },
            },
            rowNbr = 8,
        },
    }

    -- reset data provider
    ns.tabFrame.dp:Flush()

    -- insert sorted rows into the data provider
    for _, row in ipairs(data) do
        ns.tabFrame.dp:Insert(row)
    end

    -- update scroll extents
    ns.tabFrame.scrollview:RecalculateExtent(ns.tabFrame.scrollbox)
    ns.tabFrame.scrollbox:FullUpdate()
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
    if ns.tabFrame.groupFrame ~= nil then return end

    --@debug@
    ns:Print(("Tab Frames BuildContent Triggered"))
    --@end-debug@

    -- create top level frame
    groupFrame = CreateFrame("Frame", nil, parentFrame)
    groupFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", padding, -padding)
    groupFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -padding, padding)

    -- create the scroll
    CreateScroll(groupFrame)

    -- determine width and height and assign it to each frame
    -- local width = (parentFrame:GetWidth() - (padding * (cols + 1))) / cols
    -- local height = (parentFrame:GetHeight() - (padding * (rows + 1))) / rows
    -- for rowNbr, rowCols in pairs(frames) do
    --     for colNbr, _ in pairs(rowCols) do
    --         frames[rowNbr][colNbr]:SetSize(width, height)
    --     end
    -- end

    -- trigger data populate
    PopulateData()

    -- assign to namespace
    ns.tabFrame.groupFrame = groupFrame
end

--[[---------------------------------------------------------------------------
    Function:   SetupTabDropdowns
    Purpose:    Setup the Dropdown tab. This 'SetupTab' function must be defined for each tab.
    Arguments:  parentFrame - dropdown frame parent and placement assignment
-----------------------------------------------------------------------------]]
function ns.tabFrame:SetupTabFrames(parentFrame)
    -- on load function
    local function OnShow(itself)
        --@debug@
        ns:Print(("Tab Frames OnShow Triggered"))
        --@end-debug@
        BuildContent(ns.tabFrame.key)
    end

    -- register the tab
    ns.tabs:RegisterTab(parentFrame, ns.tabFrame.key, ns.L["Frames"], true, OnShow)
end