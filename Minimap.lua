local addonName, ns = ...

--[[---------------------------------------------------------------------------
    Setup Minimap Button - Note: minimap buttons are no longer on the actual minimap, there is a new button just under the calendar which opens a menu showing all the addons conigured minimap entries which is created with the three following functions
-----------------------------------------------------------------------------]]
-- TODO: Add further examples here to show what can be done. Essentially we can use MenuUtil as a starting point.
function MrBryoExamplesAddon_OnClick(name, mouseButton)
    ns:ShowUI()
end

function MrBryoExamplesAddon_OnEnter(name, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
    GameTooltip:SetText("MrBryo's Examples Addon", 1, 1, 1)
    GameTooltip:AddLine("Click to Open Main UI", 1, 1, 1)
    GameTooltip:Show()
end

function MrBryoExamplesAddon_OnLeave(name, menuButtonFrame)
    GameTooltip:Hide()
end