-------------------------------------------------------------------------------
-- TextInput.lua
-- Single-line text input with label and bordered edit box
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
local LABEL_FONT_SIZE = WC.FONT_SIZE
local INPUT_FONT_SIZE = WC.FONT_SIZE
local WHITE_COLOR = WC.WHITE_COLOR
local DISABLED_COLOR = WC.DISABLED_COLOR
local DEFAULT_WIDTH = 200
local INPUT_HEIGHT = 22
local FRAME_HEIGHT = 40
local LABEL_GAP = 2

-------------------------------------------------------------------------------
-- Factory: CreateTextInput
-------------------------------------------------------------------------------

function ns.Widgets.CreateTextInput(parent, opts)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(FRAME_HEIGHT)

    local disabled = false
    local hovered = false
    local focused = false
    local inputWidth = opts.width or DEFAULT_WIDTH

    -- Label at top
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT_PATH, LABEL_FONT_SIZE, "")
    label:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    label:SetText(opts.label or "")

    -- EditBox below label
    local editBox = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
    editBox:SetSize(inputWidth, INPUT_HEIGHT)
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -LABEL_GAP)
    WC.ApplyBackdrop(editBox, WC.INPUT_BG, WC.CONTROL_BORDER)
    editBox:SetFont(FONT_PATH, INPUT_FONT_SIZE, "")
    editBox:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
    editBox:SetTextInsets(7, 7, 0, 0)
    editBox:SetAutoFocus(false)

    if opts.maxLength then
        editBox:SetMaxLetters(opts.maxLength)
    end

    local function UpdateBorder()
        local border = WC.CONTROL_BORDER
        if not disabled then
            if focused then
                border = WC.ACCENT_COLOR
            elseif hovered then
                border = WC.BORDER_HOVER
            end
        end
        editBox:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
    end

    editBox:SetScript("OnEnter", function()
        hovered = true
        UpdateBorder()
    end)
    editBox:SetScript("OnLeave", function()
        hovered = false
        UpdateBorder()
    end)

    -- OnEnterPressed: commit value
    editBox:SetScript("OnEnterPressed", function(self)
        if disabled then return end
        local text = self:GetText()
        if opts.set then opts.set(text) end
        ns.Fire("OnWidgetChanged", { widgetType = "TextInput", key = opts.key, value = text })
        if opts.isAppearance then ns.Fire("OnAppearanceChanged", {}) end
        self:ClearFocus()
    end)

    -- OnEscapePressed: revert to stored value
    editBox:SetScript("OnEscapePressed", function(self)
        if opts.get then
            self:SetText(opts.get() or "")
        end
        self:ClearFocus()
    end)

    -- Suppress tab key
    editBox:SetScript("OnTabPressed", function(self)
        self:ClearFocus()
    end)

    -- Focus remains visible after the pointer leaves the input.
    editBox:SetScript("OnEditFocusGained", function(self)
        if disabled then
            self:ClearFocus()
            return
        end
        focused = true
        UpdateBorder()
    end)
    editBox:SetScript("OnEditFocusLost", function()
        focused = false
        UpdateBorder()
    end)
    editBox:SetScript("OnHide", function()
        hovered = false
        focused = false
        UpdateBorder()
    end)

    -- Initialize from opts.get
    if opts.get then
        editBox:SetText(opts.get() or "")
    end

    -- Public API
    function frame.GetValue(_)
        return editBox:GetText()
    end

    function frame.SetValue(_, v)
        editBox:SetText(v or "")
    end

    function frame.SetDisabled(_, state)
        disabled = state
        hovered = false
        if disabled then
            focused = false
            editBox:ClearFocus()
        end
        UpdateBorder()
        if disabled then
            label:SetTextColor(DISABLED_COLOR[1], DISABLED_COLOR[2], DISABLED_COLOR[3])
            editBox:SetAlpha(0.5)
        else
            label:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
            editBox:SetAlpha(1)
        end
    end

    function frame.Refresh(_)
        if opts.get then
            editBox:SetText(opts.get() or "")
        end
    end

    frame._editBox = editBox
    frame._label = label
    frame.order = opts.order

    return frame
end
