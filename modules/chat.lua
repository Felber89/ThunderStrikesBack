-- chat.lua

TSB.RegisterModule("Chat", {
  defaults = {
    chat = {
      allowInstance = true,  -- BG instance chat
      allowParty = false,    -- set true if you want party allowed by default
      allowRaid = false,     -- not used yet
    }
  },

  init = function()
    -- DEV ONLY: allow SAY when not in BG/party (solo testing)
    -- Set to false before release.
    TSB.Chat = TSB.Chat or {}
    TSB.Chat.DEV_ALLOW_SAY = true

    if TSB.Chat.DEV_ALLOW_SAY then
      TSB.Print("DEV MODE: SAY fallback enabled (solo testing). Disable before release.")
    end
  end
})

TSB.Chat = TSB.Chat or {}

local function InInstanceGroup()
  return IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
end

local function InParty()
  return IsInGroup() and not IsInRaid() and not InInstanceGroup()
end

local function InRaidGroup()
  return IsInRaid() and not InInstanceGroup()
end

function TSB.Chat.GetChannel()
  local policy = TSB:GetDBSection("chat")

  if InInstanceGroup() and policy.allowInstance then
    TSB:DebugVerbose("Chat channel: INSTANCE_CHAT")
    return "INSTANCE_CHAT"
  end

  if InParty() and policy.allowParty then
    TSB:DebugVerbose("Chat channel: PARTY")
    return "PARTY"
  end

  if InRaidGroup() and policy.allowRaid then
    TSB:DebugVerbose("Chat channel: RAID")
    return "RAID"
  end

  -- Dev fallback: only when SOLO (so you don't annoy groups by accident)
  if TSB.Chat.DEV_ALLOW_SAY and not IsInGroup() then
    TSB:DebugVerbose("Chat channel: SAY (dev mode)")
    return "SAY"
  end

  TSB:DebugVerbose("Chat channel: none (no valid channel available)")
  return nil
end

function TSB.Chat.Send(text)
  if type(text) ~= "string" or text == "" then
    TSB:DebugError("Chat.Send: empty message")
    TSB.Print("Internal error: tried to send an empty message.")
    return false
  end

  TSB:DebugVerbose("Chat.Send: attempting to post message (length: %d)", #text)

  -- Rate limit gate (global for jokes/predictions)
  if TSB.RateLimit and TSB.RateLimit.CanPost then
    local ok, remaining = TSB.RateLimit.CanPost()
    if not ok then
      TSB:DebugInfo("Chat.Send: rate limited (%ds remaining)", remaining)
      TSB.Print(("Rate limit active. Wait %ds."):format(remaining))
      return false
    end
  end

  local channel = TSB.Chat.GetChannel()
  if not channel then
    TSB:DebugError("Chat.Send: no valid channel available")
    TSB.Print("Posting blocked (allowed: BG instance chat" ..
      (TSB:GetDBValue("chat", "allowParty") and " + party" or "") .. ").")
    return false
  end

  TSB:DebugVerbose("Chat.Send: posting to %s", channel)
---@diagnostic disable-next-line: deprecated
  SendChatMessage(text, channel)
  TSB:DebugInfo("Chat.Send: message posted to %s", channel)

  if TSB.RateLimit and TSB.RateLimit.MarkPosted then
    TSB.RateLimit.MarkPosted()
  end

  return true
end
