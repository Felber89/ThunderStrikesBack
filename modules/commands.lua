-- commands.lua
-- Chat command handler for /tsb

local function ShowHelp()
  TSB.Print("Commands:")
  TSB.Print("/tsb options          - open UI on Options tab")
  TSB.Print("/tsb debug            - show debug level")
  TSB.Print("/tsb debug 0..3       - set debug level (0=off)")
end

SLASH_TSB1 = "/tsb"
SlashCmdList["TSB"] = function(msg)
  msg = msg or ""
  msg = strtrim(msg:lower())
  
  -- Empty command = show help
  if msg == "" then
    ShowHelp()
    return
  end

  local cmd, arg = msg:match("^(%S+)%s*(.-)%s*$")
  
  -- /tsb debug [level]
  if cmd == "debug" then
    if arg == nil or arg == "" then
      TSB.Actions:ShowDebugLevel()
    else
      TSB.Actions:SetDebugLevel(arg)
    end
    return
  end
  
  -- /tsb options (also accepts: option, general)
  if cmd == "options" or cmd == "option" or cmd == "general" then
    TSB.Actions:OpenUIWithTab("Options")
    return
  end

  -- Unknown command = show help
  ShowHelp()
end
