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



function ns:ShowUI()
    local frameName = "MainFrame"
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


    -- draw the tabs
    ns.tabs:ProcessTabSystem(mainFrame)

    -- show the frame
    ns.example.ui.frames.MainFrame = mainFrame
    if mainFrame:IsVisible() == false then
        ns.example.ui.frames.MainFrame:Show()
    end
end