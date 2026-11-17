-------------------------------------------------------------------------------
-- Panel.lua
-- BackdropTemplate container frame with title bar and close button
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ns = DragonWidgetsNS
local WC = ns.WidgetConstants

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local UIParent = UIParent

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local TITLE_BAR_HEIGHT = 28

-------------------------------------------------------------------------------
-- Title bar creation
-------------------------------------------------------------------------------

local function CreateTitleBar(parent)
    local titleBar = CreateFrame("Frame", nil, parent)
    titleBar:SetHeight(TITLE_BAR_HEIGHT)
    titleBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

    local background = titleBar:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", titleBar, "TOPLEFT", 1, -1)
    background:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", -1, 0)
    background:SetColorTexture(WC.TITLE_BG[1], WC.TITLE_BG[2], WC.TITLE_BG[3], WC.TITLE_BG[4])

    local separator = titleBar:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(1)
    separator:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 1, 0)
    separator:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", -1, 0)
    separator:SetColorTexture(
        WC.SECTION_BORDER[1], WC.SECTION_BORDER[2], WC.SECTION_BORDER[3], WC.SECTION_BORDER[4]
    )

    local accent = titleBar:CreateTexture(nil, "ARTWORK")
    accent:SetSize(2, 12)
    accent:SetPoint("LEFT", titleBar, "LEFT", 1, 0)
    accent:SetColorTexture(WC.ACCENT_COLOR[1], WC.ACCENT_COLOR[2], WC.ACCENT_COLOR[3], 1)

    -- Title text (default empty; consumers call panel:SetTitle())
    titleBar.text = titleBar:CreateFontString(nil, "OVERLAY")
    titleBar.text:SetFont(WC.FONT_PATH, WC.FONT_SIZE_TITLE, "")
    titleBar.text:SetPoint("LEFT", titleBar, "LEFT", 12, 0)
    titleBar.text:SetPoint("RIGHT", titleBar, "RIGHT", -36, 0)
    titleBar.text:SetJustifyH("LEFT")
    titleBar.text:SetWordWrap(false)
    titleBar.text:SetText("")
    titleBar.text:SetTextColor(WC.TEXT_COLOR[1], WC.TEXT_COLOR[2], WC.TEXT_COLOR[3])

    -- Make title bar the drag handle
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        parent:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        parent:StopMovingOrSizing()
    end)

    return titleBar
end

-------------------------------------------------------------------------------
-- Close button creation
-------------------------------------------------------------------------------

local function CreateCloseButton(titleBar, parent)
    local closeBtn = CreateFrame("Button", nil, titleBar, "BackdropTemplate")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -4, -2)
    WC.ApplyBackdrop(closeBtn, WC.TITLE_BG, WC.TITLE_BG)

    local label = closeBtn:CreateFontString(nil, "OVERLAY")
    label:SetFont(WC.FONT_PATH, WC.FONT_SIZE_TITLE, "")
    label:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    label:SetText("x")
    label:SetTextColor(WC.GRAY_COLOR[1], WC.GRAY_COLOR[2], WC.GRAY_COLOR[3])

    local hovered = false
    local function UpdateStyle(pressed)
        local bg = pressed and WC.WIDGET_BG_PRESSED or (hovered and WC.WIDGET_BG_HOVER or WC.TITLE_BG)
        local color = hovered and WC.DANGER_COLOR or WC.GRAY_COLOR
        closeBtn:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
        closeBtn:SetBackdropBorderColor(bg[1], bg[2], bg[3], bg[4])
        label:SetTextColor(color[1], color[2], color[3])
        label:ClearAllPoints()
        label:SetPoint("CENTER", closeBtn, "CENTER", 0, pressed and -1 or 0)
    end

    closeBtn:SetScript("OnEnter", function()
        hovered = true
        UpdateStyle(false)
    end)
    closeBtn:SetScript("OnLeave", function()
        hovered = false
        UpdateStyle(false)
    end)
    closeBtn:SetScript("OnMouseDown", function()
        UpdateStyle(true)
    end)
    closeBtn:SetScript("OnMouseUp", function()
        UpdateStyle(false)
    end)
    closeBtn:SetScript("OnHide", function()
        hovered = false
        UpdateStyle(false)
    end)
    closeBtn:SetScript("OnClick", function()
        parent:Hide()
    end)

    return closeBtn
end

-------------------------------------------------------------------------------
-- Factory: CreatePanel
-------------------------------------------------------------------------------

function ns.Widgets.CreatePanel(name, width, height)
    local panel = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    panel:SetSize(width, height)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(100)
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:Hide()

    -- Backdrop
    WC.ApplyBackdrop(panel, WC.PANEL_BG, WC.PANEL_BORDER)

    -- Title bar (also serves as drag handle)
    panel.titleBar = CreateTitleBar(panel)

    -- Close button
    panel.closeBtn = CreateCloseButton(panel.titleBar, panel)

    -- Public API: SetTitle
    function panel:SetTitle(text)
        self.titleBar.text:SetText(text or "")
    end

    return panel
end
