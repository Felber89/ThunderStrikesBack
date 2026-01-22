-- debug.lua

if not TSB._modules then TSB._modules = {} end

-- Note: We log after stub functions exist
TSB.RegisterModule("Debug", {
  defaults = {
    debug = {
      debugLevel = 0,  -- 0 = off, 1 = errors, 2 = info, 3 = verbose
    }
  }
})

local PREFIX_ERROR = "|cffff0000[TSB:ERROR]|r "
local PREFIX_INFO = "|cffff8800[TSB:INFO]|r "
local PREFIX_VERBOSE = "|cffff8800[TSB:VERBOSE]|r "

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

    local prefix
    if level == 1 then
        prefix = PREFIX_ERROR
    elseif level == 2 then
        prefix = PREFIX_INFO
    else
        prefix = PREFIX_VERBOSE
    end

    print(prefix .. formatted)
end

-- Convenience wrappers (optional, but nice)
---@diagnostic disable-next-line: duplicate-set-field
function TSB:DebugError(message, ...)
    self:Debug(1, message, ...)
end

---@diagnostic disable-next-line: duplicate-set-field
function TSB:DebugInfo(message, ...)
    self:Debug(2, message, ...)
end

---@diagnostic disable-next-line: duplicate-set-field
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
    TSB.Print("Commands:")
    TSB.Print("/tsb debug            - show debug level")
    TSB.Print("/tsb debug 0..3       - set debug level (0=off)")
end
