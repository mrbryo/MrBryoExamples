--[[ ------------------------------------------------------------------------
	Title: 			Templates.lua
	Author: 		mrbryo
	Create Date: 	2026-Jul-17
	Description: 	Functions to convert blizzard template data to a structure based on type.
-----------------------------------------------------------------------------]]

local addonName, ns = ...

function ns.templates:RestructureData()
    local newformat = {}
    for templateId, data in pairs(ns.templates.blizzard) do
        if newformat[data.type] == nil then
            newformat[data.type] = {}
        end
        newformat[data.type][templateId] = {}

        -- copy data but not type
        for key, value in pairs(data) do
            if key ~= "type" then
                newformat[data.type][templateId][key] = value
            end
        end
    end
    MrBryoTemplateDB = {
        bytype = newformat,
        orig = ns.blizzardTemplates,
    }
end

function ns.templates:GetDistinctTypes()
    local newlist = {}
    for template, data in pairs(ns.templates.blizzard) do
        if newlist[data.type] == nil then
            table.insert(newlist, data.type)
        end
    end
end