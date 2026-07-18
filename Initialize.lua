--[[ ------------------------------------------------------------------------
	Title: 			Initialize.lua
	Author: 		mrbryo
	Create Date : 	07/12/2026
	Description: 	All initialization code like db setup and slash commands.
-----------------------------------------------------------------------------]]

local addonName, ns = ...

-- namespace for this library
ns.player = {}

--[[---------------------------------------------------------------------------
    Example:    Setup Database Defaults
    Purpose:    Show where to store the database defaults prior to creating the database.
                Can be any table structure in LUA.
-----------------------------------------------------------------------------]]
ns.defaults = {
    profile = {
        default = {
            mytab = "none"
        }
    },
    global = {},
    char = {
        profile = "default",
    },
    spec = {}
}

--[[---------------------------------------------------------------------------
	Function:   Print
	Purpose:    Standard print function for the addon.
    URL:        https://www.better-addons.com/getting-started/#myfirstaddonlua
-----------------------------------------------------------------------------]]
function ns:Print(msg)
	if msg then
		print(("%s%s:|r %s"):format("|cffffd100", ns.L["Example Addon"], tostring(msg)))
	end
end

--[[---------------------------------------------------------------------------
    Note:       Not exactly as shown on Better Addon's. I like to seperate out functionality into local functions. 
                Easier for me to read. Before the database can be initialized the player information must be
                established. I setup basic profile, global and character data structures.
                I'll reference in other comments BA which stands for Better Addon's website.
    URL:        https://www.better-addons.com/starter-template/#initlua-namespace-events-slash-commands
-----------------------------------------------------------------------------]]

--[[---------------------------------------------------------------------------
    Function:   GetKeyPlayerServerSpec
    Purpose:    Get a formatted value with player, server and current spec names.
-----------------------------------------------------------------------------]]
local function SetKeyPlayerServerSpec()
    -- verify variable is setup
    if ns.player.currentPlayerServerSpec == nil then
        ns.player.currentPlayerServerSpec = ""
    end

    -- get player and server name
    local unitName, unitServer = UnitFullName("player")

    -- get characters current spec number
    local specializationIndex = C_SpecializationInfo.GetSpecialization()

    --@debug@
    print("Current spec index: " .. tostring(specializationIndex))
    --@end-debug@

    -- is spec data loaded?
    local isSpecializationDataInitialized = C_SpecializationInfo.IsInitialized()

    --@debug@
    ns:Print(("Is Spec Data Initialized? %s"):format(tostring(isSpecializationDataInitialized)))
    --@end-debug@

    -- get the name of the current spec number
    local specId, specName, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(specializationIndex)

    --@debug@
    print("Current spec name: " .. tostring(specName))
    --@end-debug@

    -- finally return the special key
    if specName == nil then
        ns.player.currentPlayerServerSpec = nil
    else
        ns.player.currentPlayerServerSpec = ("%s-%s-%s"):format(unitName, unitServer, specName) or nil
        ns.player.currentPlayerServerSpecNoHyphens = ("%s%s%s"):format(unitName, unitServer, specName) or nil
    end
end

--[[---------------------------------------------------------------------------
    Function:   GetKeyPlayerServer
    Purpose:    Get a formatted value with player and server name.
-----------------------------------------------------------------------------]]
local function SetKeyPlayerServer()
    -- verify variable's are setup
    if ns.player.currentPlayerServer == nil then
        ns.player.currentPlayerServer = ""
    end
    if ns.player.currentPlayerServerWithSpace == nil then
        ns.player.currentPlayerServerWithSpace = ""
    end

    -- get player and server name
    local unitName, unitServer = UnitFullName("player")

    --@debug@
    -- ns:Print(("Unit Name: %s; Server: %s"):format(tostring(unitName), tostring(unitServer)))
    --@end-debug@

    -- set values
    ns.player.currentPlayerServer = ("%s-%s"):format(unitName, unitServer)
    ns.player.currentPlayerServerWithSpace = ("%s - %s"):format(unitName, unitServer)
end

--[[---------------------------------------------------------------------------
    Function:   GetProfileID
    Purpose:    Get the player's current selected profile.
-----------------------------------------------------------------------------]]
function ns.player:GetProfileID()
    return ns.db.char[ns.player.currentPlayerServer].profile
end

--[[---------------------------------------------------------------------------
    Function:   UpdatePlayer
    Purpose:    Run all the functions to update player info.
-----------------------------------------------------------------------------]]
local function UpdatePlayer()
    SetKeyPlayerServer()
    SetKeyPlayerServerSpec()
end

--[[---------------------------------------------------------------------------
    Example:    Setup Event Handler
    Purpose:    Show developers how to add event handling to the addon.

    First, it initializes a frame specific for handling events.
    Next, it sets up the OnEvent script to process all handlers which are added by using RegisterEvent.
    Finally, it makes the RegisterEvent function globally available to the addon through the namespace.
    
    Note: It is NOT in a local function call or in an event. This will be created once the game loads the addon before events get triggered.
-----------------------------------------------------------------------------]]
local eventFrame = CreateFrame("Frame")
local eventHandlers = {}
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handler = eventHandlers[event]
    if handler then handler(self, event, ...) end
end)
local function RegisterEvent(event, handler)
    eventHandlers[event] = handler
    eventFrame:RegisterEvent(event)
end
ns.RegisterEvent = RegisterEvent

--[[---------------------------------------------------------------------------
    Example:    Setup Database Access
    Function:   SetupDatabase_AddonLoaded
    Purpose:    Show developers how to setup the database. 
                In the TOC file you specify the database variable name with Metadata property SaveVariables.

    First, it initializes the database for first use of the addon.
    Next, it adds the default db structure and values if any exist for the global and default profile structures.
    Finally, it assigns ns.db to the database for shorter db variable name access to ease development.
-----------------------------------------------------------------------------]]
local function SetupDatabase_AddonLoaded()
    -- skip database setup if already initialized
    if MrBryoExamplesDB == nil then
        MrBryoExamplesDB = MrBryoExamplesDB or {}
    end
    ns.db = MrBryoExamplesDB

    -- load global defaults
    if ns.db.global == nil then ns.db.global = {} end
    for key, value in pairs(ns.defaults.global) do
        if ns.db.global[key] == nil then ns.db.global[key] = value end
    end

    -- load profile defaults
    if ns.db.profile == nil then ns.db.profile = {} end
    for key, value in pairs(ns.defaults.profile) do
        if ns.db.profile[key] == nil then ns.db.profile[key] = value end
    end
end

--[[---------------------------------------------------------------------------
    Example:    Setup Database Access
    Function:   SetupDatabase_PlayerLogin
    Purpose:    Show developers how to setup the database. 
                In the TOC file you specify the database variable name with Metadata property SaveVariables.

    First, SetupDatabase_AddonLoaded must be called prior otherwise this step will exit early.
    Second, it adds the default db structure and values if any exist for the character and character specialization structures.
-----------------------------------------------------------------------------]]
local function SetupDatabase_PlayerLogin()
    -- database must be setup during ADDON_LOADED first
    if ns.db == nil then return end

    -- load player server defaults
    if ns.db.char == nil then ns.db.char = {} end
    if ns.db.char[ns.player.currentPlayerServer] == nil then ns.db.char[ns.player.currentPlayerServer] = {} end
    for key, value in pairs(ns.defaults.char) do
        if ns.db.char[ns.player.currentPlayerServer][key] == nil then ns.db.char[ns.player.currentPlayerServer][key] = value end
    end

    -- setup player server spec for who is currently logged in
    if ns.db.spec == nil then ns.db.spec = {} end
    if ns.player.currentPlayerServerSpec ~= nil then
        if ns.db.spec[ns.player.currentPlayerServerSpec] == nil then ns.db.spec[ns.player.currentPlayerServerSpec] = {} end
        for key, value in pairs(ns.defaults.spec) do
            if ns.db.spec[ns.player.currentPlayerServerSpec][key] == nil then ns.db.spec[ns.player.currentPlayerServerSpec][key] = value end
        end
    end
end

--[[---------------------------------------------------------------------------
    Example:    Setup Slash Commands
    Function:   SeetupSlashCommands
    Purpose:    Show developers how to add slash commands to their addon.
-----------------------------------------------------------------------------]]
local function SetupSlashCommands()
	-- define the slash commands and global name
    local slashDetails = {
        name = "MRBRYOEXAMPLES",
        cmds = {
            "/examples",
            "/mbx"
        }
    }

    -- register all commands
    for slashIdx, slashCommand in ipairs(slashDetails.cmds) do
        _G["SLASH_" .. slashDetails.name .. tostring(slashIdx)] = slashCommand
    end

    -- function to execute when slash commands used
    SlashCmdList[slashDetails.name] = function(msg)
        local command, rest = msg:match("^(%S*)%s*(.-)$")
        command = command:lower()

        if command == "config" then
            ns:Print("Opening config...not implemented yet!")
        elseif command == "reset" then
            ns:Print("Settings reset to defaults.")
        elseif command == "dbclear" then
            MrBryoExamplesDB = {}
            ns:Print("Database Cleared - Do a reload so the Addon initializes the DB again.")
        elseif command == "" then
            ns:ShowUI()
        else
            ns:Print("Unknown command: " .. command)
            ns:Print("Usage:")
            ns:Print("  /examples config - Opens the Configuration in the Warcraft Settings Menu...not implemented yet!")
            ns:Print("  /examples reset  - Resets configuration...not implemented yet!")
            ns:Print("  /examples        - Open the main UI.")
            ns:Print("Alternate slash command is: /mbx")
        end
    end
end

--[[---------------------------------------------------------------------------
    Example:    Addon Initialization with ADDON_LOADED event.
    Purpose:    Show developers how to add slash commands to their addon.
-----------------------------------------------------------------------------]]
RegisterEvent("ADDON_LOADED", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end

    -- First, unregister the ADDON_LOADED so it only happens at character logon or reload.
    eventFrame:UnregisterEvent("ADDON_LOADED")

    -- Next, setup the database and slash commands.
    SetupDatabase_AddonLoaded()
    SetupSlashCommands()
end)

--[[--------------------------------------------------------------------------
	Event:	    PLAYER_LOGIN
	Purpose:	Start features once the world is ready. Also occurs on reload.
-----------------------------------------------------------------------------]]
RegisterEvent("PLAYER_LOGIN", function(self, event, ...)
	-- get event parameters
	local isInitialLogin, isReload = ...

	--@debug@
	ns:Print(("Player Login - isInitialLogin: %s, isReload: %s"):format(event, tostring(isInitialLogin) and ns.L["Yes"] or ns.L["No"], tostring(isReload) and ns.L["Yes"] or ns.L["No"]))
	--@end-debug@

    -- Next, initialize player variables. This is something I do, not from BA.
    UpdatePlayer()

	-- Next, run db initializer where player name, server and spec is needed.
	SetupDatabase_PlayerLogin()
end)