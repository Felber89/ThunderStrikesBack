-- minimap.lua

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

TSB.RegisterModule("Minimap", {
  defaults = {
    minimap = { hide = false }
  },

  init = function()
    if not LDB or not LDBIcon then
      TSB.Print("Minimap disabled: missing LibDataBroker-1.1 and/or LibDBIcon-1.0.")
      return
    end

    -- Dropdown frames (WoW built-in UIDropDownMenu)
    local actionMenuFrame = CreateFrame("Frame", "TSB_ActionMenu", UIParent, "UIDropDownMenuTemplate")
    local optionsMenuFrame = CreateFrame("Frame", "TSB_OptionsMenu", UIParent, "UIDropDownMenuTemplate")

    local function PostRandomJoke()
      if TSB.Jokes and TSB.Jokes.PostRandom then
        TSB.Jokes.PostRandom()
      else
        TSB.Print("Jokes not implemented yet.")
      end
    end

    local function PostPrediction()
      if TSB.Predict and TSB.Predict.Post then
        TSB.Predict.Post()
      else
        TSB.Print("Predictions not implemented yet.")
      end
    end

    local function SetMinimapHidden(hidden)
      TSB:DebugVerbose("Minimap.SetHidden: %s", hidden and "true" or "false")
      TSB:SetDBValue("minimap", "hide", hidden and true or false)
      if TSB:GetDBValue("minimap", "hide") then
        TSB:DebugInfo("Minimap: hiding icon")
        LDBIcon:Hide("ThunderStrikesBack")
      else
        TSB:DebugInfo("Minimap: showing icon")
        LDBIcon:Show("ThunderStrikesBack")
      end
    end

    local function ShowActionMenu()
      TSB:DebugVerbose("Minimap: showing action menu")
      if not EasyMenu then
        TSB:DebugError("Minimap.ShowActionMenu: EasyMenu not available")
        TSB.Print("Dropdown menu not available (EasyMenu missing).")
        return
      end

      local menu = {
        { text = "ThunderStrikesBack", isTitle = true, notCheckable = true },

        { text = "Post Random Joke", notCheckable = true, func = PostRandomJoke },
        { text = "Post Prediction",  notCheckable = true, func = PostPrediction },

        { text = "Close", notCheckable = true, func = function() CloseDropDownMenus() end },
      }

      EasyMenu(menu, actionMenuFrame, "cursor", 0, 0, "MENU")
    end

    local function ShowOptionsMenu()
      TSB:DebugVerbose("Minimap: right-click - opening UI with Options tab")
      
      -- Open main UI window with Options tab
      if TSB.UI then
        TSB.UI:Open()
        TSB.UI:SelectTab("Options")
      else
        TSB:DebugError("Minimap: TSB.UI not available")
        TSB.Print("UI not available yet.")
      end
    end

    -- Create LDB object for LibDBIcon
    local minimapButton = LDB:NewDataObject("ThunderStrikesBack", {
      type = "data source",
      text = "ThunderStrikesBack",
      icon = "Interface/AddOns/ThunderStrikesBack/textures/icon.tga",

      OnClick = function(_, button)
        if button == "LeftButton" then
          ShowActionMenu()
        elseif button == "RightButton" then
          ShowOptionsMenu()
        end
      end,

      OnTooltipShow = function(tooltip)
        tooltip:AddLine("ThunderStrikesBack")
        tooltip:AddDoubleLine("Left Click",  "Actions",  0.82, 0.59, 0, 1, 1, 1)
        tooltip:AddDoubleLine("Right Click", "Options",  0.82, 0.59, 0, 1, 1, 1)
        tooltip:Show()
      end
    })

    -- Register with LibDBIcon
    LDBIcon:Register("ThunderStrikesBack", minimapButton, TSB:GetDBSection("minimap"))

    -- Apply visibility
    if TSB:GetDBValue("minimap", "hide") then
      TSB:DebugInfo("Minimap: initial state - hidden")
      LDBIcon:Hide("ThunderStrikesBack")
    else
      TSB:DebugInfo("Minimap: initial state - visible")
      LDBIcon:Show("ThunderStrikesBack")
    end
  end
})
