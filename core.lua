-- core.lua

TSB          = TSB or {}
TSB.name     = "ThunderStrikesBack"
TSB.prefix   = "|cff0070ddTSB|r"

TSB._modules = TSB._modules or {} -- array for modules

function TSB.Print(msg)
    if msg == nil then return end
    print(("%s %s"):format(TSB.prefix, tostring(msg)))
end

-- Stub implementations (will be overridden by modules/debug.lua)
---@diagnostic disable-next-line: duplicate-set-field
function TSB:DebugError(message, ...)
    -- Stub: does nothing until debug module loads
end

---@diagnostic disable-next-line: duplicate-set-field
function TSB:DebugInfo(message, ...)
    -- Stub: does nothing until debug module loads
end

---@diagnostic disable-next-line: duplicate-set-field
function TSB:DebugVerbose(message, ...)
    -- Stub: does nothing until debug module loads
end

-- DB Access Layer: Centralized read/write of SavedVariables
-- Avoids direct TSB_DB access from modules
function TSB:GetDBValue(module, key)
    if not TSB_DB or not TSB_DB[module] then return nil end
    return TSB_DB[module][key]
end

function TSB:SetDBValue(module, key, value)
    if not TSB_DB then TSB_DB = {} end
    if not TSB_DB[module] then TSB_DB[module] = {} end
    TSB_DB[module][key] = value
end

function TSB:GetDBSection(module)
    if not TSB_DB or not TSB_DB[module] then return {} end
    return TSB_DB[module]
end

function TSB.RegisterModule(name, spec)
    if type(name) ~= "string" then
        error("TSB.RegisterModule: name must be a string")
    end
    if type(spec) ~= "table" then
        error("TSB.RegisterModule: spec must be a table")
    end

    -- optional sanity checks
    if spec.defaults ~= nil and type(spec.defaults) ~= "table" then
        error(("TSB.RegisterModule(%s): defaults must be a table"):format(name))
    end
    if spec.init ~= nil and type(spec.init) ~= "function" then
        error(("TSB.RegisterModule(%s): init must be a function"):format(name))
    end

    TSB:DebugVerbose("RegisterModule: %s", name)
    TSB._modules[name] = spec
end

local function DeepApplyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            DeepApplyDefaults(dst[k], v)
        else
            if dst[k] == nil then dst[k] = v end
        end
    end
end

local function InitDB()
    TSB_DB = TSB_DB or {}
    TSB:DebugInfo("Initializing database...")
    for name, module in pairs(TSB._modules) do
        if module.defaults then
            TSB:DebugVerbose("Merging defaults for module: " .. name)
            DeepApplyDefaults(TSB_DB, module.defaults)
        end
    end
end

local function InitModules()
    TSB:DebugInfo("Starting module initialization...")
    for name, module in pairs(TSB._modules) do
        if module.init then
            TSB:DebugVerbose("Initializing module: " .. name)
            local ok, err = pcall(module.init)
            if not ok then
                TSB:DebugError("Init error in module '" .. name .. "': " .. tostring(err))
            else
                TSB:DebugInfo("Module initialized: " .. name)
            end
        else
            TSB:DebugVerbose("Module registered but no init: " .. name)
        end
    end
    TSB:DebugInfo("Module initialization complete")
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    InitDB()
    InitModules()
    TSB.Print("Loaded. Type /tsb for commands.")
end)
