-------------------------------------------------------------------------------
-- Header.lua
-- Sub-header with bright text and a subtle horizontal separator
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ns = DragonWidgetsNS
local WC = ns.WidgetConstants

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CreateFrame = CreateFrame

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local FONT_PATH = WC.FONT_PATH
local FONT_SIZE = WC.FONT_SIZE
local SEPARATOR_HEIGHT = 1
local FRAME_HEIGHT = 20

-------------------------------------------------------------------------------
-- Factory: CreateHeader
-------------------------------------------------------------------------------

function ns.Widgets.CreateHeader(parent, text)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(FRAME_HEIGHT)

    -- Bright text with left padding, vertically centered
    local fontString = frame:CreateFontString(nil, "OVERLAY")
    fontString:SetFont(FONT_PATH, FONT_SIZE, "")
    fontString:SetTextColor(WC.TEXT_COLOR[1], WC.TEXT_COLOR[2], WC.TEXT_COLOR[3])
    fontString:SetPoint("LEFT", frame, "LEFT", 4, 0)
    fontString:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    fontString:SetJustifyH("LEFT")
    fontString:SetWordWrap(false)
    fontString:SetText(text)

    -- Quiet separator below text
    local separator = frame:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(SEPARATOR_HEIGHT)
    separator:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    separator:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    separator:SetColorTexture(
        WC.SECTION_BORDER[1], WC.SECTION_BORDER[2], WC.SECTION_BORDER[3], WC.SECTION_BORDER[4]
    )

    frame._fontString = fontString
    frame._separator = separator

    return frame
end
