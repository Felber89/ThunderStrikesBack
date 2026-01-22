-- ui/tabs/jokes.lua
-- Jokes tab content

TSB.UI_Jokes = TSB.UI_Jokes or {}

function TSB.UI_Jokes.CreateContent(parent)
  TSB:DebugVerbose("Creating Jokes tab content")
  
  -- Title
  local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -20)
  title:SetText("Jokes Tab")
  
  -- Placeholder text
  local placeholder = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  placeholder:SetPoint("CENTER", 0, 0)
  placeholder:SetText("Joke posting functionality will be implemented here.\n\nPlaceholder for v0.1.0")
  placeholder:SetJustifyH("CENTER")
  
  TSB:DebugVerbose("Jokes tab content created")
end
