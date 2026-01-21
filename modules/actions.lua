-- actions.lua
-- Action Layer: Business logic and validation for user-facing commands

if not TSB then TSB = {} end

TSB.Actions = TSB.Actions or {}

-- SetDebugLevel(level)
-- Validates, normalizes and applies debug level
-- Input: string or number
-- Output: print confirmation or error
function TSB.Actions:SetDebugLevel(level)
    TSB:DebugVerbose("Actions:SetDebugLevel() called with input: %s (type: %s)", tostring(level), type(level))

    -- Normalize input: accept string or number
    if type(level) == "string" then
        local parsed = tonumber(level)
        if parsed == nil then
            TSB:DebugError("Invalid debug level: '%s' is not a number", level)
            TSB.Print("Error: Debug level must be a number (0-3)")
            return false
        end
        level = parsed
        TSB:DebugVerbose("Parsed string input to number: %d", level)
    end

    if type(level) ~= "number" then
        TSB:DebugError("Invalid debug level type: expected number, got %s", type(level))
        TSB.Print("Error: Debug level must be a number (0-3)")
        return false
    end

    local original = level
    -- Clamp to valid range
    if level < 0 then
        TSB:DebugVerbose("Clamping debug level from %d to 0", level)
        level = 0
    end
    if level > 3 then
        TSB:DebugVerbose("Clamping debug level from %d to 3", level)
        level = 3
    end

    -- Write via central DB layer
    TSB:SetDBValue("debug", "debugLevel", level)
    TSB:DebugVerbose("Debug level written to DB: %d", level)

    -- Confirmation
    local levelNames = { "off", "errors", "info", "verbose" }
    TSB:DebugInfo("Debug level changed to %d (%s)", level, levelNames[level + 1])
    TSB.Print("Debug level set to " .. level .. " (" .. levelNames[level + 1] .. ")")

    return true
end

-- ShowDebugLevel()
-- Reads and displays current debug level
function TSB.Actions:ShowDebugLevel()
    TSB:DebugVerbose("Actions:ShowDebugLevel() called")
    
    local level = TSB:GetDBValue("debug", "debugLevel") or 0
    TSB:DebugVerbose("Current debug level from DB: %d", level)
    
    local levelNames = { "off", "errors", "info", "verbose" }
    TSB:DebugInfo("Displaying debug level: %d (%s)", level, levelNames[level + 1])
    TSB.Print("Current debug level: " .. level .. " (" .. levelNames[level + 1] .. ")")
    
    return level
end
