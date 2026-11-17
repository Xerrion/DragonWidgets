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
local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local FRAME_HEIGHT = 24
local LABEL_OFFSET = 6

-------------------------------------------------------------------------------
-- Create the checkbox box frame
-------------------------------------------------------------------------------

local function CreateCheckBox(parent)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetSize(BOX_SIZE, BOX_SIZE)
    WC.ApplyBackdrop(box, WC.INPUT_BG, WC.CONTROL_BORDER)

    -- Check mark
    local checkMark = box:CreateTexture(nil, "OVERLAY")
    checkMark:SetTexture(CHECK_TEXTURE)
    checkMark:SetPoint("CENTER", box, "CENTER", 0, 0)
    checkMark:SetSize(BOX_SIZE, BOX_SIZE)
    checkMark:SetVertexColor(WC.ACCENT_COLOR[1], WC.ACCENT_COLOR[2], WC.ACCENT_COLOR[3], 1)
    checkMark:Hide()

    box._checkMark = checkMark
    return box
end

-------------------------------------------------------------------------------
-- Use fill and a visible mark to distinguish selection from hover
-------------------------------------------------------------------------------

local function UpdateCheckStyle(box, isChecked, isHovered, isDisabled)
    local bg = WC.INPUT_BG
    local border = WC.CONTROL_BORDER
    if isChecked then
        bg = WC.ACCENT_SOFT
        border = WC.ACCENT_COLOR
        if isHovered and not isDisabled then border = WC.SLIDER_THUMB end
    elseif isHovered and not isDisabled then
        bg = WC.WIDGET_BG_HOVER
        border = WC.BORDER_HOVER
    end
    box:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    box:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

-------------------------------------------------------------------------------
-- Factory: CreateToggle
-------------------------------------------------------------------------------

function ns.Widgets.CreateToggle(parent, opts)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(FRAME_HEIGHT)

    local checked = false
    local disabled = false
    local hovered = false

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
        UpdateCheckStyle(box, checked, hovered, disabled)
        if opts.set then opts.set(checked) end
        ns.Fire("OnWidgetChanged", { widgetType = "Toggle", key = opts.key, value = checked })
        if opts.isAppearance then ns.Fire("OnAppearanceChanged", {}) end
    end

    -- Frame handles tooltip, hover highlight, and click
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        WC.ShowTooltip(self)
        hovered = true
        UpdateCheckStyle(box, checked, hovered, disabled)
    end)
    frame:SetScript("OnLeave", function()
        WC.HideTooltip()
        hovered = false
        UpdateCheckStyle(box, checked, hovered, disabled)
    end)
    frame:SetScript("OnMouseUp", doToggle)
    frame:SetScript("OnHide", function()
        hovered = false
        UpdateCheckStyle(box, checked, hovered, disabled)
    end)

    -- Initialize from opts.get
    if opts.get then
        checked = not not opts.get()
        box._checkMark:SetShown(checked)
        UpdateCheckStyle(box, checked, hovered, disabled)
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
        UpdateCheckStyle(box, checked, hovered, disabled)
    end

    --- Enables or disables the toggle widget.
    --- When disabled, the label is dimmed and clicks are ignored.
    ---@param _ any Self reference (unused, dot-style call)
    ---@param state boolean True to disable, false to enable
    function frame.SetDisabled(_, state)
        disabled = state
        hovered = false
        UpdateCheckStyle(box, checked, hovered, disabled)
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
            UpdateCheckStyle(box, checked, hovered, disabled)
        end
    end

    frame._box = box
    frame._label = label
    frame.order = opts.order

    return frame
end
