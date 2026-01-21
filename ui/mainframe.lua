-- ui/mainframe.lua
-- Main window frame with tab system

if not TSB then TSB = {} end

TSB.RegisterModule("UI", {
  defaults = {
    ui = {
      windowShown = false,
      selectedTab = "Jokes"
    }
  },

  init = function()
    TSB:DebugInfo("Initializing UI module...")
    
    local mainFrame = nil
    local tabs = {}
    local tabButtons = {}
    local tabContents = {}
    
    -- Tab order
    local TAB_ORDER = {"Jokes", "Options"}
    
    -- Create main window frame
    local function CreateMainFrame()
      TSB:DebugVerbose("Creating main window frame")
      
      local f = CreateFrame("Frame", "TSB_MainFrame", UIParent, "BasicFrameTemplateWithInset")
      f:SetSize(600, 400)
      f:SetPoint("CENTER")
      f:SetMovable(true)
      f:EnableMouse(true)
      f:RegisterForDrag("LeftButton")
      f:SetScript("OnDragStart", f.StartMoving)
      f:SetScript("OnDragStop", f.StopMovingOrSizing)
      f:SetClampedToScreen(true)
      f:SetFrameStrata("DIALOG")
      
      -- Title
      f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      f.title:SetPoint("TOP", 0, -5)
      f.title:SetText("ThunderStrikesBack v0.1.0")
      
      -- Hide on ESC
      tinsert(UISpecialFrames, "TSB_MainFrame")
      
      f:Hide()
      
      TSB:DebugVerbose("Main window frame created")
      return f
    end
    
    -- Create tab button
    local function CreateTabButton(parent, tabName, index)
      local btn = CreateFrame("Button", "TSB_TabButton_" .. tabName, parent)
      btn:SetSize(120, 30)
      btn:SetPoint("TOPLEFT", 10 + (index - 1) * 125, -30)
      
      btn:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
      btn:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab")
      
      local ntex = btn:GetNormalTexture()
      ntex:SetTexCoord(0, 1, 0, 1)
      
      local dtex = btn:GetDisabledTexture()
      dtex:SetTexCoord(0, 1, 0, 1)
      
      btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      btn.text:SetPoint("CENTER", 0, -2)
      btn.text:SetText(tabName)
      
      btn.tabName = tabName
      
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
        else
          btn:Enable()
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
      
      TSB:DebugInfo("UI components built successfully")
    end
    
    -- Public API
    TSB.UI = TSB.UI or {}
    
    function TSB.UI:Open()
      if not mainFrame then
        TSB:DebugError("UI not initialized yet")
        return
      end
      
      TSB:DebugInfo("Opening main window")
      mainFrame:Show()
      TSB:SetDBValue("ui", "windowShown", true)
    end
    
    function TSB.UI:Close()
      if not mainFrame then
        TSB:DebugError("UI not initialized yet")
        return
      end
      
      TSB:DebugInfo("Closing main window")
      mainFrame:Hide()
      TSB:SetDBValue("ui", "windowShown", false)
    end
    
    function TSB.UI:Toggle()
      if not mainFrame then
        TSB:DebugError("UI not initialized yet")
        return
      end
      
      if mainFrame:IsShown() then
        self:Close()
      else
        self:Open()
      end
    end
    
    function TSB.UI:SelectTab(tabNameOrIndex)
      if not mainFrame then
        TSB:DebugError("UI not initialized yet")
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
    
    -- Initialize after all modules are loaded
    InitializeUI()
    
    TSB:DebugInfo("UI module initialized")
  end
})
