-- DragonWidgets Luacheck configuration
std = "lua51"
max_line_length = 120

globals = {
    "DragonWidgetsNS",
    "ColorPickerFrame",
}

read_globals = {
    -- WoW API
    "CreateFrame",
    "UIParent",
    "UISpecialFrames",
    "GameTooltip",
    "ShowUIPanel",
    "PlaySound",
    "SOUNDKIT",
    "GetCursorInfo",
    "ClearCursor",
    "GetItemInfo",
    "C_Item",
    "C_Timer",
    "LibStub",
    "table",
    "math",
    "string",
    "pairs",
    "ipairs",
    "type",
    "tostring",
    "tonumber",
    "pcall",
    "error",
    "print",
    "unpack",
    "select",
    "next",
    "rawget",
    "rawset",
    "setmetatable",
    "getmetatable",
}
