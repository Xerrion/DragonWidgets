-- DragonWidgets Luacheck configuration
std = "lua51"
max_line_length = 120
codes = true

exclude_files = {
    ".release/",
}

ignore = {
    "212/self",
    "211/_.*",  -- unused variables prefixed with underscore
    "213/_.*",  -- unused loop variables prefixed with underscore
}

read_globals = {
    -- Lua
    "table", "string", "math", "pairs", "ipairs", "type", "tostring", "tonumber",
    "pcall", "error", "print", "unpack", "select", "next",
    "rawget", "rawset", "setmetatable", "getmetatable",

    -- WoW API (shared across addon + spec)
    "CreateFrame",
    "UIParent",
    "GameTooltip",
    "LibStub",
}

-----------------------------------------------------------------------
-- DragonWidgets (addon source)
-----------------------------------------------------------------------
files["DragonWidgets/"] = {
    globals = {
        "DragonWidgetsNS",
        "ColorPickerFrame",
    },

    read_globals = {
        -- WoW API
        "UISpecialFrames",
        "ShowUIPanel",
        "PlaySound",
        "SOUNDKIT",
        "GetCursorInfo",
        "ClearCursor",
        "GetItemInfo",
        "C_Item",
        "C_Timer",
    },
}

-----------------------------------------------------------------------
-- Tests
-----------------------------------------------------------------------
files["spec/"] = {
    std = "+busted",
    globals = {
        -- WoW API mocks (set as globals in wow_mock.lua)
        "CreateFrame",
        "UIParent",
        "UISpecialFrames",
        "GameTooltip",
        "LibStub",
        "PlaySound",
        "SOUNDKIT",
        "DragonWidgetsNS",
        "ColorPickerFrame",
        "ShowUIPanel",
    },
}
