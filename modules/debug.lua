-- debug.lua

if not TSB then TSB = {} end
if not TSB._modules then TSB._modules = {} end

TSB.Print("Loading module: debug")

-- Note: We log after stub functions exist
TSB.RegisterModule("Debug", {
  defaults = {
    debug = {
      debugLevel = 0,  -- 0 = off, 1 = errors, 2 = info, 3 = verbose
    }
  }
})

local PREFIX = "|cffff8800[TSB]|r "

local function ToString(v)
    if v == nil then return "nil" end
    return tostring(v)
end

-- Public API:
-- TSB:Debug(level, message, ...)
-- Levels: 1 error, 2 info, 3 verbose
function TSB:Debug(level, message, ...)
    local dl = self:GetDBValue("debug", "debugLevel") or 0
    if dl < (level or 2) then return end

    message = message or ""
    local ok, formatted = pcall(string.format, message, ...)
    if not ok then
        -- Fallback if formatting fails (wrong % args etc.)
        formatted = message .. " " .. ToString(...)
    end

    print(PREFIX .. formatted)
end

-- Convenience wrappers (optional, but nice)
function TSB:DebugError(message, ...)
    self:Debug(1, message, ...)
end

function TSB:DebugInfo(message, ...)
    self:Debug(2, message, ...)
end

function TSB:DebugVerbose(message, ...)
    self:Debug(3, message, ...)
end

-- Set/get debug level (delegates to Actions layer)
function TSB:SetDebugLevel(level)
    TSB.Actions:SetDebugLevel(level)
end

function TSB:GetDebugLevel()
    return self:GetDBValue("debug", "debugLevel") or 0
end

-- Slash command:
-- /tsb debug
-- /tsb debug 0..3
SLASH_TSB1 = "/tsb"
SlashCmdList["TSB"] = function(msg)
    msg = msg or ""
    msg = msg:lower()

    local cmd, arg = msg:match("^(%S+)%s*(.-)%s*$")
    if cmd == "debug" then
        if arg == nil or arg == "" then
            TSB.Actions:ShowDebugLevel()
        else
            TSB.Actions:SetDebugLevel(arg)
        end
        return
    end

    -- Help text (keep it short)
    print(PREFIX .. "Commands:")
    print(PREFIX .. "/tsb debug            - show debug level")
    print(PREFIX .. "/tsb debug 0..3       - set debug level (0=off)")
end
