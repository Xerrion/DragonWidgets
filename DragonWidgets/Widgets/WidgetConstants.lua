-------------------------------------------------------------------------------
-- WidgetConstants.lua
-- Shared constants and helpers for DragonWidgets
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ns = DragonWidgetsNS

local GameTooltip = GameTooltip
local ChatFontSmall = ChatFontSmall
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

-- Blizzard supplies a sans family with the correct glyphs for each locale.
local fontPath = ChatFontSmall and ChatFontSmall:GetFont() or STANDARD_TEXT_FONT

-------------------------------------------------------------------------------
-- Shared constants used across multiple widget files
-------------------------------------------------------------------------------

ns.WidgetConstants = {
    FONT_PATH = fontPath or "Fonts\\FRIZQT__.TTF",
    FONT_SIZE = 12,
    FONT_SIZE_SMALL = 11,
    FONT_SIZE_TITLE = 14,
    WHITE8x8 = "Interface\\Buttons\\WHITE8x8",
    WHITE_COLOR = { 0.91, 0.94, 0.97 },
    DISABLED_COLOR = { 0.40, 0.46, 0.53 },
    GRAY_COLOR = { 0.62, 0.68, 0.75 },
    EMPTY_ICON = "Interface\\PaperDoll\\UI-Backpack-EmptySlot",

    -- Opaque, layered surfaces keep text readable over the game world.
    PANEL_BG = { 0.035, 0.047, 0.065, 0.98 },
    PANEL_BORDER = { 0.22, 0.28, 0.35, 1 },
    TITLE_BG = { 0.065, 0.085, 0.115, 1 },
    SECTION_BG = { 0.065, 0.085, 0.11, 1 },
    SECTION_BORDER = { 0.16, 0.21, 0.27, 1 },
    HEADER_ACCENT = { 0.09, 0.12, 0.16, 1 },
    DROPDOWN_LIST_BG = { 0.08, 0.105, 0.14, 1 },
    WIDGET_BG = { 0.10, 0.13, 0.17, 1 },
    WIDGET_BG_HOVER = { 0.15, 0.19, 0.24, 1 },
    WIDGET_BG_PRESSED = { 0.07, 0.10, 0.14, 1 },
    INPUT_BG = { 0.055, 0.075, 0.10, 1 },
    CONTROL_BORDER = { 0.26, 0.32, 0.39, 1 },
    BORDER_HOVER = { 0.40, 0.52, 0.60, 1 },

    -- Accent denotes a selection, value, or focused control, not body text.
    ACCENT_COLOR = { 0.28, 0.83, 0.73, 1 },
    ACCENT_SOFT = { 0.28, 0.83, 0.73, 0.12 },
    DANGER_COLOR = { 0.95, 0.39, 0.43, 1 },
    SLIDER_TRACK = { 0.19, 0.24, 0.29, 1 },
    SLIDER_FILL = { 0.28, 0.83, 0.73, 1 },
    SLIDER_THUMB = { 0.87, 0.98, 0.95, 1 },
    SCROLLBAR_THUMB = { 0.33, 0.42, 0.50, 1 },

    -- Kept for consumers that use gold for their own semantic highlights.
    GOLD_COLOR = { 1, 0.82, 0 },
}

ns.WidgetConstants.TEXT_COLOR = ns.WidgetConstants.WHITE_COLOR

-------------------------------------------------------------------------------
-- Shared flat surface; callers retain ownership of size and interaction.
-------------------------------------------------------------------------------

function ns.WidgetConstants.ApplyBackdrop(frame, background, border)
    local texture = ns.WidgetConstants.WHITE8x8
    frame:SetBackdrop({ bgFile = texture, edgeFile = texture, edgeSize = 1 })
    frame:SetBackdropColor(background[1], background[2], background[3], background[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

-------------------------------------------------------------------------------
-- Shared tooltip handlers (used by Toggle, Button)
-------------------------------------------------------------------------------

function ns.WidgetConstants.ShowTooltip(frame)
    if not frame._tooltipText then return end
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    GameTooltip:SetText(frame._tooltipText, 1, 1, 1, 1, true)
    GameTooltip:Show()
end

function ns.WidgetConstants.HideTooltip()
    GameTooltip:Hide()
end
