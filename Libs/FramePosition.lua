--[[ ------------------------------------------------------------------------
	Title: 			FramePosition.lua
	Author: 		mrbryo
	Create Date : 	07/12/2026
	Description: 	Standard way to handle top level frame positioning.
                    Call this library before db initalization so the defaults is updated with what is necessary for these functions.
-----------------------------------------------------------------------------]]

local addonName, ns = ...

-- namespace for this library
ns.framePosn = {}

-- exist this file if the defaults structure doesn't exist
if ns.defaults == nil then return end

-- load defaults
if ns.defaults.profile.default.ui == nil then ns.defaults.profile.default.ui = {} end
if ns.defaults.profile.default.ui.positions == nil then ns.defaults.profile.default.ui.positions = {} end

--[[---------------------------------------------------------------------------
    Function:   GetFramePosition
    Purpose:    Retrieve the position of a frame from the profile database.
    Parameters: frameName - the name of the frame
-----------------------------------------------------------------------------]]
function ns.framePosn:GetFramePosition(frameName)
    -- retrieve position data
    local profile = ns.player:GetProfileID()
    return ns.db.profile[profile].ui.positions[frameName]
end

--[[---------------------------------------------------------------------------
    Function:   GetFrameSize
    Purpose:    Retrieve the size of a frame from the profile database.
    Parameters: frameName - the name of the frame
-----------------------------------------------------------------------------]]
function ns.framePosn:GetFrameSize(frameName)
    local profile = ns.player:GetProfileID()
    local frameSize = ns.db.profile[profile].ui.size[frameName]
    if frameSize == nil then
        frameSize = {
            width = 300,
            height = 300
        }
    end
    return frameSize
end

--[[---------------------------------------------------------------------------
    Function:   SetFramePosition
    Purpose:    Store the position of a frame in the profile database.
    Parameters: frameName - the name of the frame
                point - the point on the frame being set (e.g., "TOPLEFT")
                relativePoint - the point on the relative frame (e.g., "BOTTOMRIGHT")
                xOfs - the x offset from the relative point
                yOfs - the y offset from the relative point
-----------------------------------------------------------------------------]]
function ns.framePosn:SetFramePosition(frameName, point, relativePoint, xOfs, yOfs)
    -- store position data
    local profile = ns.player:GetProfileID()
    ns.db.profile[profile].ui.positions[frameName] = {
        point = point,
        relativePoint = relativePoint,
        xOffset = xOfs,
        yOffset = yOfs
    }

    -- return true since storage was successful
    return true
end

--[[---------------------------------------------------------------------------
    Function:   StoreFramePosition
    Purpose:    Store the current frame position in the character database.
    Arguments:  frame - the frame whose position to store
                frameName - necessary if frame has no global name
-----------------------------------------------------------------------------]]
function ns.framePosn:StoreFramePosition(frame, frameName)
    -- Get current position
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

    -- get frame name if not provided
    if frameName == nil then
        frameName = frame:GetName()
    end

    -- skip storage if still nil
    if frameName == nil then
        ns:Print(ns.L["Error: Frame has no name, cannot store position."])
        return
    end

    -- store position data in the character database
    local isSuccess = ns.framePosn:SetFramePosition(frameName, point, relativePoint, xOfs, yOfs)

    --@debug@
    -- if self.gets:GetDevMode() == true then
    --     self:Print(("Frame position stored: %s %s %.1f %.1f"):format(point, relativePoint, xOfs, yOfs))
    -- end
    --@end-debug@

    return isSuccess
end

--[[---------------------------------------------------------------------------
    Function:   RestoreFramePosition
    Purpose:    Restore the frame position from stored data or center if bounds are invalid.
    Arguments:  frame - the frame to position
                frameName - necessary if frame has no global name
                frameWidth - width of the frame
                frameHeight - height of the frame
-----------------------------------------------------------------------------]]
function ns.framePosn:RestoreFramePosition(frame, frameName, frameWidth, frameHeight)
    -- get frame name if not provided
    if frameName == nil then
        frameName = frame:GetName()
    end

    -- get stored position data
    local storedPosition = ns.framePosn:GetFramePosition(frameName)
    ns:Print(("Stored Position for %s: %s"):format(frameName, storedPosition and ("point=%s, relativePoint=%s, xOffset=%.1f, yOffset=%.1f"):format(storedPosition.point, storedPosition.relativePoint, storedPosition.xOffset, storedPosition.yOffset) or "nil"))

    -- default to center position
    local point = "CENTER"
    local relativePoint = "CENTER"
    local xOffset = 0
    local yOffset = 0

    -- if we have stored position data, validate it's within bounds
    if storedPosition and storedPosition.point and storedPosition.xOffset and storedPosition.yOffset then
        local testX = storedPosition.xOffset
        local testY = storedPosition.yOffset

        -- get UIParent dimensions for bounds checking
        local screenWidth = UIParent:GetWidth()
        local screenHeight = UIParent:GetHeight()

        -- calculate frame boundaries
        local halfWidth = frameWidth / 2
        local halfHeight = frameHeight / 2

        -- check if frame would be completely within UIParent bounds
        local withinBounds = true

        -- for CENTER positioning, check if frame stays within screen
        if storedPosition.point == "CENTER" then
            if (testX - halfWidth < -screenWidth/2) or (testX + halfWidth > screenWidth/2) or
               (testY - halfHeight < -screenHeight/2) or (testY + halfHeight > screenHeight/2) then
                withinBounds = false
            end

        -- for other anchor points, do more specific bounds checking
        elseif storedPosition.point == "TOPLEFT" then
            if testX < 0 or testY > 0 or 
               (testX + frameWidth > screenWidth) or (testY - frameHeight < -screenHeight) then
                withinBounds = false
            end
        elseif storedPosition.point == "BOTTOMRIGHT" then
            if testX > 0 or testY < 0 or
               (testX - frameWidth < -screenWidth) or (testY + frameHeight > screenHeight) then
                withinBounds = false
            end
        end

        -- use stored position if within bounds
        if withinBounds == true then
            point = storedPosition.point
            relativePoint = storedPosition.relativePoint
            xOffset = testX
            yOffset = testY
        end
    end

    -- Set the frame position
    frame:SetPoint(point, frame:GetParent(), relativePoint, xOffset, yOffset)
    return true
end