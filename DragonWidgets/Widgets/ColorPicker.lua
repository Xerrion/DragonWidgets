-------------------------------------------------------------------------------
-- ColorPicker.lua
-- Color swatch that opens the WoW ColorPickerFrame (Retail + Classic)
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ns = DragonWidgetsNS
local WC = ns.WidgetConstants

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local ShowUIPanel = ShowUIPanel

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local FONT_PATH = WC.FONT_PATH
local FONT_SIZE = WC.FONT_SIZE
local SWATCH_SIZE = 24
local WHITE8x8 = WC.WHITE8x8
local WHITE_COLOR = WC.WHITE_COLOR
local DISABLED_COLOR = WC.DISABLED_COLOR
local BORDER_COLOR = WC.CONTROL_BORDER
local FRAME_HEIGHT = 24
local LABEL_OFFSET = 8

-------------------------------------------------------------------------------
-- Update the swatch texture color
-------------------------------------------------------------------------------

local function UpdateSwatch(swatch, r, g, b, a)
    swatch:SetColorTexture(r or 1, g or 1, b or 1, a or 1)
end

-------------------------------------------------------------------------------
-- Open ColorPickerFrame with Retail API (10.2.5+)
-------------------------------------------------------------------------------

local function OpenRetailPicker(r, g, b, a, hasAlpha, swatchFunc, cancelFunc, opacityFunc)
    local info = {}
    info.r = r
    info.g = g
    info.b = b
    info.hasOpacity = hasAlpha
    info.opacity = hasAlpha and (1 - (a or 1)) or nil
    info.swatchFunc = swatchFunc
    info.cancelFunc = cancelFunc
    if hasAlpha then
        info.opacityFunc = opacityFunc
    end
    ColorPickerFrame:SetupColorPickerAndShow(info)
end

-------------------------------------------------------------------------------
-- Open ColorPickerFrame with Classic API
-------------------------------------------------------------------------------

local function OpenClassicPicker(r, g, b, a, hasAlpha, swatchFunc, cancelFunc, opacityFunc)
    ColorPickerFrame.hasOpacity = hasAlpha
    ColorPickerFrame.opacity = hasAlpha and (1 - (a or 1)) or nil
    ColorPickerFrame.previousValues = { r, g, b, a }
    ColorPickerFrame.func = swatchFunc
    ColorPickerFrame.cancelFunc = cancelFunc
    if hasAlpha then
        ColorPickerFrame.opacityFunc = opacityFunc
    else
        ColorPickerFrame.opacityFunc = nil
    end
    ColorPickerFrame:SetColorRGB(r, g, b)
    ShowUIPanel(ColorPickerFrame)
end

-------------------------------------------------------------------------------
-- Build the callback functions for the color picker
-------------------------------------------------------------------------------

local function BuildCallbacks(opts, swatch, prevColor)
    local swatchFunc = function()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        local newA = 1
        if opts.hasAlpha then
            newA = 1 - (ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha()
                or ColorPickerFrame.opacity or 0)
        end
        UpdateSwatch(swatch, newR, newG, newB, newA)
        if opts.set then opts.set(newR, newG, newB, newA) end
        ns.Fire("OnWidgetChanged", {
            widgetType = "ColorPicker", key = opts.key,
            value = { r = newR, g = newG, b = newB, a = newA },
        })
        if opts.isAppearance then ns.Fire("OnAppearanceChanged", {}) end
    end

    local cancelFunc = function(_prev)
        local pR, pG, pB, pA = prevColor[1], prevColor[2], prevColor[3], prevColor[4]
        UpdateSwatch(swatch, pR, pG, pB, pA or 1)
        if opts.set then opts.set(pR, pG, pB, pA or 1) end
    end

    local opacityFunc = function()
        local oR, oG, oB = ColorPickerFrame:GetColorRGB()
        local oA = 1 - (ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha()
            or ColorPickerFrame.opacity or 0)
        UpdateSwatch(swatch, oR, oG, oB, oA)
        if opts.set then opts.set(oR, oG, oB, oA) end
        ns.Fire("OnWidgetChanged", {
            widgetType = "ColorPicker", key = opts.key,
            value = { r = oR, g = oG, b = oB, a = oA },
        })
        if opts.isAppearance then ns.Fire("OnAppearanceChanged", {}) end
    end

    return swatchFunc, cancelFunc, opacityFunc
end

-------------------------------------------------------------------------------
-- Factory: CreateColorPicker
-------------------------------------------------------------------------------

function ns.Widgets.CreateColorPicker(parent, opts)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(FRAME_HEIGHT)

    local disabled = false

    -- Label
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT_PATH, FONT_SIZE, "")
    label:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
    label:SetPoint("LEFT", frame, "LEFT", 0, 0)
    label:SetText(opts.label or "")

    -- Border around swatch
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetSize(SWATCH_SIZE + 2, SWATCH_SIZE + 2)
    border:SetPoint("LEFT", label, "RIGHT", LABEL_OFFSET, 0)
    border:SetBackdrop({ bgFile = WHITE8x8, edgeFile = WHITE8x8, edgeSize = 1 })
    border:SetBackdropColor(WC.INPUT_BG[1], WC.INPUT_BG[2], WC.INPUT_BG[3], 1)
    border:SetBackdropBorderColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4])

    -- Checkerboard makes translucent colors legible independently of the panel.
    local cellSize = (SWATCH_SIZE - 4) / 4
    for row = 0, 3 do
        for col = 0, 3 do
            local cell = border:CreateTexture(nil, "BACKGROUND", nil, 1)
            local shade = (row + col) % 2 == 0 and 0.24 or 0.44
            cell:SetSize(cellSize, cellSize)
            cell:SetPoint("TOPLEFT", border, "TOPLEFT", 3 + col * cellSize, -3 - row * cellSize)
            cell:SetColorTexture(shade, shade, shade, 1)
        end
    end

    -- Inset color swatch texture
    local swatch = border:CreateTexture(nil, "ARTWORK")
    swatch:SetPoint("TOPLEFT", border, "TOPLEFT", 3, -3)
    swatch:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -3, 3)

    border:SetScript("OnEnter", function()
        if disabled then return end
        border:SetBackdropBorderColor(WC.ACCENT_COLOR[1], WC.ACCENT_COLOR[2], WC.ACCENT_COLOR[3], 1)
    end)
    border:SetScript("OnLeave", function()
        border:SetBackdropBorderColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4])
    end)

    -- Initialize swatch color
    local initR, initG, initB, initA = 1, 1, 1, 1
    if opts.get then
        initR, initG, initB, initA = opts.get()
        initA = initA or 1
    end
    UpdateSwatch(swatch, initR, initG, initB, initA)

    -- Click to open picker
    border:EnableMouse(true)
    border:SetScript("OnMouseUp", function()
        if disabled then return end

        local r, g, b, a = 1, 1, 1, 1
        if opts.get then
            r, g, b, a = opts.get()
            a = a or 1
        end

        local prevColor = { r, g, b, a }
        local swatchFunc, cancelFunc, opacityFunc = BuildCallbacks(opts, swatch, prevColor)

        if ColorPickerFrame.SetupColorPickerAndShow then
            OpenRetailPicker(r, g, b, a, opts.hasAlpha, swatchFunc, cancelFunc, opacityFunc)
        else
            OpenClassicPicker(r, g, b, a, opts.hasAlpha, swatchFunc, cancelFunc, opacityFunc)
        end
    end)

    -- Public API
    function frame.GetValue(_)
        if opts.get then return opts.get() end
        return initR, initG, initB, initA
    end

    function frame.SetValue(_, r, g, b, a)
        a = a or 1
        UpdateSwatch(swatch, r, g, b, a)
        if opts.set then opts.set(r, g, b, a) end
    end

    function frame.SetDisabled(_, state)
        disabled = state
        border:SetBackdropBorderColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4])
        if disabled then
            label:SetTextColor(DISABLED_COLOR[1], DISABLED_COLOR[2], DISABLED_COLOR[3])
            border:SetAlpha(0.5)
        else
            label:SetTextColor(WHITE_COLOR[1], WHITE_COLOR[2], WHITE_COLOR[3])
            border:SetAlpha(1)
        end
    end

    function frame.Refresh(_)
        if not opts.get then return end
        local r, g, b, a = opts.get()
        UpdateSwatch(swatch, r, g, b, a or 1)
    end

    frame._label = label
    frame._swatch = swatch
    frame._border = border
    frame.order = opts.order

    return frame
end
