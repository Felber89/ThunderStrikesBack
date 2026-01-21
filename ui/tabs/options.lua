-- ui/tabs/options.lua
-- Options tab content

if not TSB then TSB = {} end
TSB.UI_Options = TSB.UI_Options or {}

function TSB.UI_Options.CreateContent(parent)
  TSB:DebugVerbose("Creating Options tab content")
  
  -- Title
  local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -20)
  title:SetText("Options Tab")
  
  -- Placeholder text
  local placeholder = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  placeholder:SetPoint("CENTER", 0, 0)
  placeholder:SetText("Addon options and settings will be implemented here.\n\nPlaceholder for v0.1.0")
  placeholder:SetJustifyH("CENTER")
  
  TSB:DebugVerbose("Options tab content created")
end
