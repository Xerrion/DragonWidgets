-------------------------------------------------------------------------------
-- Button.lua
-- Styled action button with tooltip support
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
local DEFAULT_WIDTH = 120
local BUTTON_HEIGHT = 24
local DISABLED_COLOR = WC.DISABLED_COLOR
local WHITE_COLOR = WC.WHITE_COLOR

-------------------------------------------------------------------------------
-- Keep normal, hover and pressed states consistent on every client
-------------------------------------------------------------------------------

local function UpdateStyle(btn)
    local bg = WC.WIDGET_BG
    local border = WC.CONTROL_BORDER
    if not btn._disabled then
        if btn._pressed then
            bg = WC.WIDGET_BG_PRESSED
            border = WC.ACCENT_COLOR
        elseif btn._hovered then
            bg = WC.WIDGET_BG_HOVER
            border = WC.BORDER_HOVER
        end
    end
    btn:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    btn:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
    btn._text:ClearAllPoints()
    local offset = btn._pressed and not btn._disabled and -1 or 0
    btn._text:SetPoint("LEFT", btn, "LEFT", 8, offset)
    btn._text:SetPoint("RIGHT", btn, "RIGHT", -8, offset)
end

-------------------------------------------------------------------------------
-- Factory: CreateButton
-------------------------------------------------------------------------------

function ns.Widgets.CreateButton(parent, opts)
    local width = opts.width or DEFAULT_WIDTH
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, BUTTON_HEIGHT)
    WC.ApplyBackdrop(btn, WC.WIDGET_BG, WC.CONTROL_BORDER)

    local text = btn:CreateFontString(nil, "OVERLAY")
    text:SetFont(FONT_PATH, FONT_SIZE, "")
    text:SetJustifyH("CENTER")
    text:SetWordWrap(false)
    text:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
    btn:SetFontString(text)
    btn._text = text

    btn:SetText(opts.text or "")
    btn._tooltipText = opts.tooltip
    btn._disabled = false
    UpdateStyle(btn)

    -- Click handler
    btn:SetScript("OnClick", function(self)
        if self._disabled then return end
        if opts.onClick then opts.onClick() end
        ns.Fire("OnWidgetChanged", { widgetType = "Button", key = opts.key, value = true })
    end)

    btn:SetScript("OnEnter", function(self)
        self._hovered = true
        UpdateStyle(self)
        WC.ShowTooltip(self)
    end)
    btn:SetScript("OnLeave", function(self)
        self._hovered = false
        self._pressed = false
        UpdateStyle(self)
        WC.HideTooltip()
    end)
    btn:SetScript("OnMouseDown", function(self)
        if self._disabled then return end
        self._pressed = true
        UpdateStyle(self)
    end)
    btn:SetScript("OnMouseUp", function(self)
        self._pressed = false
        UpdateStyle(self)
    end)
    btn:SetScript("OnHide", function(self)
        self._hovered = false
        self._pressed = false
        UpdateStyle(self)
    end)

    -- SetDisabled
    function btn:SetDisabled(state)
        self._disabled = state
        self._pressed = false
        self._hovered = false
        UpdateStyle(self)
        if state then
            self:SetAlpha(0.5)
            self._text:SetTextColor(DISABLED_COLOR[1], DISABLED_COLOR[2], DISABLED_COLOR[3])
        else
            self:SetAlpha(1)
            self._text:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
        end
    end

    btn.order = opts.order

    return btn
end
