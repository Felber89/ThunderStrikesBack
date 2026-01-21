-- rateLimit.lua

if not TSB then TSB = {} end

TSB.Print("Loading module: rateLimit")

TSB.RegisterModule("RateLimit", {
  defaults = {
    rateLimit = {
      cooldownSec = 90,  -- fixed for now
      lastPostAt = 0,
    }
  }
})

TSB.RateLimit = TSB.RateLimit or {}

function TSB.RateLimit.CanPost()
  local rl = TSB:GetDBSection("rateLimit")
  local cd = tonumber(rl.cooldownSec) or 90
  local last = tonumber(rl.lastPostAt) or 0
  local now = time()

  local remaining = (last + cd) - now
  if remaining > 0 then
    TSB:DebugVerbose("Rate limit active, remaining: " .. remaining .. "s")
    return false, remaining
  end
  TSB:DebugVerbose("Rate limit check passed")
  return true, 0
end

function TSB.RateLimit.MarkPosted()
  local now = time()
  TSB:DebugVerbose("RateLimit.MarkPosted: timestamp = %d", now)
  TSB:SetDBValue("rateLimit", "lastPostAt", now)
  TSB:DebugInfo("RateLimit: cooldown started (90s)")
end
