--[[---------------------------------------------------------------------------
    Localization for Example Addon
    Language: English (US)
-----------------------------------------------------------------------------]]

local addonName, ns = ...

local L = setmetatable({}, {
    __index = function(self, key)
        return key  -- fallback: return the key itself
    end,
})
ns.L = L

-- following line is replaced when packaged through curseforge using their localization tool
--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="concat", handle-unlocalized="english")@

--@do-not-package@ 
--[[ leaving all for development purposes, export from curseforge ]]



--@end-do-not-package@