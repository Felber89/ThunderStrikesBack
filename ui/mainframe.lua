-- ui/mainframe.lua
-- Main window frame with tab system

TSB.RegisterModule("UI", {
  defaults = {
    ui = {
      windowShown = false, -- Always default to closed
      selectedTab = "Jokes"
    }
  }
})

local mainFrame = nil
local tabButtons = {}
local tabContents = {}
-- Tab order
local TAB_ORDER = { "Jokes", "Options" }

-- Create main window frame
local function CreateMainFrame()
  TSB:DebugVerbose("Creating main window frame")

  -- If frame already exists from previous session, destroy it
  if _G["TSB_MainFrame"] then
    TSB:DebugVerbose("Destroying existing frame from previous session")
    _G["TSB_MainFrame"]:Hide()
    _G["TSB_MainFrame"] = nil
  end

  local f = CreateFrame("Frame", "TSB_MainFrame", UIParent, "BasicFrameTemplateWithInset")
  f:SetSize(750, 550)   -- Larger default size
  f:SetPoint("CENTER")
  f:SetMovable(true)
  f:SetResizable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")

  -- Improved drag handling for better responsiveness
  f:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
  end)

  f:SetClampedToScreen(true)
  f:SetFrameStrata("DIALOG")

  -- Add resize button (bottom-right)
  local resizer = CreateFrame("Button", nil, f)
  resizer:SetSize(16, 16)
  resizer:SetPoint("BOTTOMRIGHT", -5, 5)
  resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

  resizer:SetScript("OnMouseDown", function()
    f:StartSizing("BOTTOMRIGHT")
  end)
  resizer:SetScript("OnMouseUp", function()
    f:StopMovingOrSizing()
  end)

  -- Title
  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  f.title:SetPoint("TOP", 0, -5)
  f.title:SetText("ThunderStrikesBack v0.1.0")

  -- Update DB when window is closed
  f:SetScript("OnHide", function()
    TSB:SetDBValue("ui", "windowShown", false)
  end)

  -- Hide on ESC
  tinsert(UISpecialFrames, "TSB_MainFrame")

  -- Start hidden
  f:Hide()

  TSB:DebugVerbose("Main window frame created")
  return f
end

-- Create tab button
local function CreateTabButton(parent, tabName, index)
  local btn = CreateFrame("Button", "TSB_TabButton_" .. tabName, parent)
  btn:SetSize(120, 28)
  btn:SetPoint("TOPLEFT", 10 + (index - 1) * 125, -30)

  -- Background texture (colored box)
  btn.bg = btn:CreateTexture(nil, "BACKGROUND")
  btn.bg:SetAllPoints()
  btn.bg:SetColorTexture(0.2, 0.4, 0.8, 1)   -- Blue background

  -- Highlight texture
  btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
  btn.highlight:SetAllPoints()
  btn.highlight:SetColorTexture(0.3, 0.5, 0.9, 0.5)   -- Lighter blue on hover

  -- Border
  btn.border = btn:CreateTexture(nil, "OVERLAY")
  btn.border:SetAllPoints()
  btn.border:SetColorTexture(0, 0, 0, 0)   -- No border by default

  -- Text
  btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  btn.text:SetPoint("CENTER", 0, 0)
  btn.text:SetText(tabName)
  btn.text:SetTextColor(1, 1, 1, 1)   -- White text

  btn.tabName = tabName

  -- Update appearance based on state
  btn.UpdateState = function(self, isActive)
    if isActive then
      -- Active tab: darker blue, white text
      self.bg:SetColorTexture(0.15, 0.3, 0.6, 1)
      self.text:SetTextColor(1, 1, 1, 1)
    else
      -- Inactive tab: lighter blue, slightly dimmed text
      self.bg:SetColorTexture(0.2, 0.4, 0.8, 0.8)
      self.text:SetTextColor(0.9, 0.9, 0.9, 1)
    end
  end

  btn:SetScript("OnClick", function()
    TSB.UI:SelectTab(tabName)
  end)

  return btn
end

-- Create tab content frame
local function CreateTabContent(parent, tabName)
  local content = CreateFrame("Frame", "TSB_TabContent_" .. tabName, parent)
  content:SetPoint("TOPLEFT", 10, -70)
  content:SetPoint("BOTTOMRIGHT", -10, 10)
  content:Hide()

  return content
end

-- Switch to a specific tab
local function SwitchTab(tabName)
  TSB:DebugVerbose("Switching to tab: %s", tabName)

  -- Validate tab name
  local validTab = false
  for _, name in ipairs(TAB_ORDER) do
    if name == tabName then
      validTab = true
      break
    end
  end

  if not validTab then
    TSB:DebugError("Invalid tab name: %s", tabName)
    return
  end

  -- Update button states
  for name, btn in pairs(tabButtons) do
    if name == tabName then
      btn:Disable()
      btn:UpdateState(true)   -- Active state
    else
      btn:Enable()
      btn:UpdateState(false)   -- Inactive state
    end
  end

  -- Show/hide content
  for name, content in pairs(tabContents) do
    if name == tabName then
      content:Show()
    else
      content:Hide()
    end
  end

  -- Save to DB
  TSB:SetDBValue("ui", "selectedTab", tabName)

  TSB:DebugVerbose("Tab switched to: %s", tabName)
end

-- Initialize UI
local function InitializeUI()
  TSB:DebugInfo("Building UI components...")

  -- Create main frame
  mainFrame = CreateMainFrame()

  -- Create tabs
  for i, tabName in ipairs(TAB_ORDER) do
    TSB:DebugVerbose("Creating tab: %s", tabName)

    -- Create tab button
    tabButtons[tabName] = CreateTabButton(mainFrame, tabName, i)

    -- Create tab content
    tabContents[tabName] = CreateTabContent(mainFrame, tabName)

    -- Call module-specific content creation
    if tabName == "Jokes" and TSB.UI_Jokes then
      TSB.UI_Jokes.CreateContent(tabContents[tabName])
    elseif tabName == "Options" and TSB.UI_Options then
      TSB.UI_Options.CreateContent(tabContents[tabName])
    else
      TSB:DebugVerbose("No content handler found for tab: %s", tabName)
    end
  end

  -- Restore last selected tab
  local lastTab = TSB:GetDBValue("ui", "selectedTab") or "Jokes"
  SwitchTab(lastTab)

  -- Frame is created hidden by default (CreateMainFrame sets f:Hide())
  -- No need to explicitly hide again here

  TSB:DebugInfo("UI components built successfully")
end

-- Public API
TSB.UI = TSB.UI or {}
local isInitialized = false

-- Lazy initialization: Create frame only when first needed
local function EnsureInitialized()
  if not isInitialized then
    TSB:DebugInfo("Lazy initializing UI on first access...")
    InitializeUI()
    isInitialized = true
    TSB:DebugInfo("UI module initialized (mainFrame=%s)", tostring(mainFrame))
  end
end

function TSB.UI:Open()
  EnsureInitialized()

  if not mainFrame then
    TSB:DebugError("mainFrame is nil after initialization")
    return
  end

  TSB:DebugInfo("Opening main window")
  mainFrame:Show()
  TSB:SetDBValue("ui", "windowShown", true)
end

function TSB.UI:Close()
  -- Don't create frame just to close it
  if not isInitialized or not mainFrame then
    TSB:DebugVerbose("Close called but UI not initialized - nothing to do")
    return
  end

  TSB:DebugInfo("Closing main window")
  mainFrame:Hide()
  TSB:SetDBValue("ui", "windowShown", false)
end

function TSB.UI:Toggle()
  EnsureInitialized()

  if not mainFrame then
    TSB:DebugError("mainFrame is nil after initialization")
    return
  end

  if mainFrame:IsShown() then
    self:Close()
  else
    self:Open()
  end
end

function TSB.UI:SelectTab(tabNameOrIndex)
  EnsureInitialized()

  if not mainFrame then
    TSB:DebugError("mainFrame is nil after initialization")
    return
  end

  local tabName = tabNameOrIndex

  -- Handle index
  if type(tabNameOrIndex) == "number" then
    tabName = TAB_ORDER[tabNameOrIndex]
    if not tabName then
      TSB:DebugError("Invalid tab index: %d", tabNameOrIndex)
      return
    end
  end

  SwitchTab(tabName)
end
