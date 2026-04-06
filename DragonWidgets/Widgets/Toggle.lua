-------------------------------------------------------------------------------
-- Toggle.lua
-- Checkbox toggle with label and optional tooltip
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
local BOX_SIZE = 20
local WHITE_COLOR = WC.WHITE_COLOR
local DISABLED_COLOR = WC.DISABLED_COLOR
local WHITE8x8 = WC.WHITE8x8
local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local FRAME_HEIGHT = 24
local LABEL_OFFSET = 6

-------------------------------------------------------------------------------
-- Create the checkbox box frame
-------------------------------------------------------------------------------

local function CreateCheckBox(parent)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetSize(BOX_SIZE, BOX_SIZE)
    box:SetBackdrop({
        bgFile = WHITE8x8,
        edgeFile = WHITE8x8,
        edgeSize = 1,
    })
    box:SetBackdropColor(WC.WIDGET_BG[1], WC.WIDGET_BG[2], WC.WIDGET_BG[3], WC.WIDGET_BG[4])
    box:SetBackdropBorderColor(
        WC.SECTION_BORDER[1], WC.SECTION_BORDER[2], WC.SECTION_BORDER[3], WC.SECTION_BORDER[4]
    )

    -- Check mark
    local checkMark = box:CreateTexture(nil, "OVERLAY")
    checkMark:SetTexture(CHECK_TEXTURE)
    checkMark:SetPoint("CENTER", box, "CENTER", 0, 0)
    checkMark:SetSize(BOX_SIZE + 4, BOX_SIZE + 4)
    checkMark:Hide()

    box._checkMark = checkMark
    return box
end

-------------------------------------------------------------------------------
-- Update border color: gold tint when checked, default when unchecked
-------------------------------------------------------------------------------

local function UpdateCheckBorder(box, isChecked)
    if isChecked then
        box:SetBackdropBorderColor(WC.GOLD_COLOR[1], WC.GOLD_COLOR[2], WC.GOLD_COLOR[3], 0.5)
    else
        box:SetBackdropBorderColor(
            WC.SECTION_BORDER[1], WC.SECTION_BORDER[2],
            WC.SECTION_BORDER[3], WC.SECTION_BORDER[4]
        )
    end
end

-------------------------------------------------------------------------------
-- Factory: CreateToggle
-------------------------------------------------------------------------------

function ns.Widgets.CreateToggle(parent, opts)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(FRAME_HEIGHT)

    local checked = false
    local disabled = false

    -- Checkbox
    local box = CreateCheckBox(frame)
    box:SetPoint("LEFT", frame, "LEFT", 0, 0)

    -- Label
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT_PATH, FONT_SIZE, "")
    label:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
    label:SetPoint("LEFT", box, "RIGHT", LABEL_OFFSET, 0)
    label:SetText(opts.label or "")

    -- Tooltip
    frame._tooltipText = opts.tooltip

    -- Disable mouse on box so clicks pass through to the parent frame
    box:EnableMouse(false)

    -- Toggle logic (sole handler lives on frame)
    local function doToggle(_, button)
        if button ~= "LeftButton" then return end
        if disabled then return end
        checked = not checked
        box._checkMark:SetShown(checked)
        UpdateCheckBorder(box, checked)
        if opts.set then opts.set(checked) end
        ns.Fire("OnWidgetChanged", { widgetType = "Toggle", key = opts.key, value = checked })
        if opts.isAppearance then ns.Fire("OnAppearanceChanged", {}) end
    end

    -- Frame handles tooltip, hover highlight, and click
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        WC.ShowTooltip(self)
        if disabled then return end
        box:SetBackdropColor(
            WC.WIDGET_BG_HOVER[1], WC.WIDGET_BG_HOVER[2],
            WC.WIDGET_BG_HOVER[3], WC.WIDGET_BG_HOVER[4]
        )
    end)
    frame:SetScript("OnLeave", function()
        WC.HideTooltip()
        box:SetBackdropColor(WC.WIDGET_BG[1], WC.WIDGET_BG[2], WC.WIDGET_BG[3], WC.WIDGET_BG[4])
    end)
    frame:SetScript("OnMouseUp", doToggle)

    -- Initialize from opts.get
    if opts.get then
        checked = not not opts.get()
        box._checkMark:SetShown(checked)
        UpdateCheckBorder(box, checked)
    end

    -- Apply initial disabled state
    if opts.disabled then
        disabled = true
        label:SetTextColor(DISABLED_COLOR[1], DISABLED_COLOR[2], DISABLED_COLOR[3])
        box:SetAlpha(0.5)
    end

    -- Public API

    --- Returns the current checked state of the toggle.
    ---@return boolean checked Whether the toggle is currently checked
    function frame.GetValue(_)
        return checked
    end

    --- Sets the checked state without firing change events.
    ---@param _ any Self reference (unused, dot-style call)
    ---@param v boolean The new checked state (coerced to boolean)
    function frame.SetValue(_, v)
        checked = not not v
        box._checkMark:SetShown(checked)
        UpdateCheckBorder(box, checked)
    end

    --- Enables or disables the toggle widget.
    --- When disabled, the label is dimmed and clicks are ignored.
    ---@param _ any Self reference (unused, dot-style call)
    ---@param state boolean True to disable, false to enable
    function frame.SetDisabled(_, state)
        disabled = state
        box:SetBackdropColor(WC.WIDGET_BG[1], WC.WIDGET_BG[2], WC.WIDGET_BG[3], WC.WIDGET_BG[4])
        if disabled then
            label:SetTextColor(DISABLED_COLOR[1], DISABLED_COLOR[2], DISABLED_COLOR[3])
            box:SetAlpha(0.5)
        else
            label:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
            box:SetAlpha(1)
        end
    end

    --- Refreshes the visual state by re-reading from opts.get().
    --- No-op if opts.get was not provided at creation time.
    function frame.Refresh(_)
        if opts.get then
            checked = not not opts.get()
            box._checkMark:SetShown(checked)
            UpdateCheckBorder(box, checked)
        end
    end

    frame._box = box
    frame._label = label
    frame.order = opts.order

    return frame
end
