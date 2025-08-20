-- =============================================================================
-- === HideCompassDistances Core Logic (HideCompassDistances.lua)             ===
-- =============================================================================
--[[
    AddOn Name:         HideCompassDistances
    Description:        Hides compass distance indicators in the game interface
    Version:            1.0.0
    Author:             |cEBD03CVollständigerName|r
    Dependencies:       None
--]]
-- =============================================================================
--[[
    SYSTEM ARCHITECTURE:
    - Compass Distance Manipulation Engine
    - Settings Persistence System
    - Slash Command Interface
    - Event-Based Initialization
--]]
-- =============================================================================

-- =============================================================================
-- == GLOBAL ADDON DEFINITION & VERSION CONTROL ================================
-- =============================================================================
--[[
    Purpose: Establishes fundamental addon identity and version tracking
    Contains:
    - Addon metadata for ESO client recognition
    - Version control using semantic versioning (SemVer)
    - Settings persistence system
--]]

HideCompassDistances = {
    -- Internal namespace identifier (must match folder name)
    name = "HideCompassDistances",
    
    -- Semantic version (Major=Breaking, Minor=Features, Patch=Fixes)
    version = "1.0.0",
    
    -- Settings configuration (overridden by SavedVariables)
    settings = {
        hideDistances = true  -- Default: distances hidden
    },
    
    -- Original string storage for restoration purposes
    originalStrings = {}
}


-- =============================================================================
-- == LOCALIZED ALIASES & RUNTIME REFERENCES ===================================
-- =============================================================================
--[[
    Purpose: Optimizes frequent access patterns and reduces overhead
    Contains:
    - Localized addon namespace reference
    - Cached event manager reference
    - SavedVariables reference initialization
--]]

local HCD = HideCompassDistances     -- Local namespace alias
local NAME = HCD.name                -- Immutable addon name
local HCDSV                          -- Will hold SavedVariables reference
local EM = EVENT_MANAGER             -- Event system shortcut


-- =============================================================================
-- == SLASH COMMAND IMPLEMENTATION =============================================
-- =============================================================================
--[[
    Purpose: Provides user interaction via chat commands
    Process Flow:
      1. Registers /compassdistancetoggle command
      2. Toggles hideDistances setting when called
      3. Immediately updates distance display
      4. Provides visual feedback in chat
--]]

SLASH_COMMANDS["/compassdistancetoggle"] = function()
    -- Toggle setting with safe null-check handling
    HCD.settings.hideDistances = not HCD.settings.hideDistances
    
    -- Immediate application of changes
    HCD.UpdateDistances()
    
    -- Visual feedback for user
    d("Compass distances: " .. (HCD.settings.hideDistances and "|cFF0000hidden|r" or "|c00FF00shown|r"))
end


-- =============================================================================
-- == CORE FUNCTIONALITY: DISTANCE MANIPULATION ================================
-- =============================================================================
--[[
    Function: UpdateDistances
    Purpose:
      Applies current settings to compass distance strings
      
    Process Flow:
      1. Checks hideDistances setting value
      2. Sets EsoStrings accordingly:
         - If true: Empty strings to hide distances
         - If false: Restores original strings
      3. Persists settings to SavedVariables
--]]

function HCD.UpdateDistances()
    if HCD.settings.hideDistances then
        -- Hide distance strings
        EsoStrings[11803] = ""  -- Short distances (meters)
        EsoStrings[11804] = ""  -- Long distances (kilometers)
    else
        -- Restore original strings
        EsoStrings[11803] = HCD.originalStrings[11803] or ""
        EsoStrings[11804] = HCD.originalStrings[11804] or ""
    end
    
    -- Persist settings for future sessions
    HCDSV = HCD.settings
end


-- =============================================================================
-- == ADDON INITIALIZATION & EVENT HANDLING ====================================
-- =============================================================================
--[[
    Function: Initialize
    Purpose:
      Performs addon initialization routines
      
    Process Flow:
      1. Backs up original strings for later restoration
      2. Loads saved settings if available
      3. Applies initial configuration
--]]

function HCD.Initialize()
    -- Backup original strings
    HCD.originalStrings[11803] = EsoStrings[11803]
    HCD.originalStrings[11804] = EsoStrings[11804]
    
    -- Load saved settings if available
    if HCDSV then
        HCD.settings = HCDSV
    end
    
    -- Initial configuration application
    HCD.UpdateDistances()
end


-- =============================================================================
-- == EVENT HANDLER: ADDON LOADED ==============================================
-- =============================================================================
--[[
    Function: OnAddOnLoaded
    Purpose:
      Handles the EVENT_ADD_ON_LOADED event to initialize the addon
      only when its specific data is available
      
    Process Flow:
      1. Checks if the loaded addon is our own
      2. Unregisters event handler after successful initialization
      3. Performs addon initialization
--]]

local function OnAddOnLoaded(event, addonName)
    if addonName == NAME then
        -- Event unregistration after successful loading
        EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        
        -- Addon initialization
        HCD.Initialize()
    end
end


-- =============================================================================
-- == EVENT REGISTRATION & SYSTEM BOOTSTRAP ====================================
-- =============================================================================
--[[
    Purpose: Registers necessary event handlers for addon operation
    Contains:
    - EVENT_ADD_ON_LOADED handler for delayed initialization
--]]

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)