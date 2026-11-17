-------------------------------------------------------------------------------
-- LayoutConstants.lua
-- Shared layout constants and helpers for DragonWidgets consumer tab files
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ns = DragonWidgetsNS

local table_sort = table.sort
local pairs = pairs
local LibStub = LibStub
local min = math.min
local max = math.max
local floor = math.floor

-------------------------------------------------------------------------------
-- Layout constants shared across all tab files
-------------------------------------------------------------------------------

local LC = {
    PADDING_SIDE = 10,
    PADDING_TOP = -10,
    PADDING_BOTTOM = 20,
    SPACING_AFTER_HEADER = 8,
    SPACING_BETWEEN_WIDGETS = 6,
    SPACING_BETWEEN_SECTIONS = 16,
    SECTION_PADDING_TOP = 8,
    SECTION_PADDING_BOTTOM = 12,
    SECTION_PADDING_SIDE = 12,
    SUB_OPTION_INDENT = 16,
    SETTINGS_ROW_HEIGHT = 48,
    SETTINGS_COLUMN_GAP = 24,
    SETTINGS_TWO_COLUMN_WIDTH = 640,
}

-------------------------------------------------------------------------------
-- Settings layout collection. Anchors also support manually laid out panels.
-------------------------------------------------------------------------------

local ReflowSettingsLayout

local function RegisterWidget(widget, parent)
    local layout = parent._settingsLayout
    if not layout or not layout.collecting or layout.seen[widget] then return end
    layout.seen[widget] = true
    layout.widgets[#layout.widgets + 1] = widget
    widget:HookScript("OnSizeChanged", function(_, _, height)
        if layout.collecting or height == widget._layoutMeasuredHeight then return end
        local root = layout.root
        local rootLayout = root._settingsLayout
        if rootLayout and not rootLayout.collecting and not rootLayout.layingOut then
            ReflowSettingsLayout(root, root:GetWidth())
        end
    end)
end

function LC.BeginSettingsLayout(parent)
    if parent._settingsLayout then return parent._settingsLayout end
    local layout = { widgets = {}, seen = {}, collecting = true, root = parent }
    parent._settingsLayout = layout
    parent:HookScript("OnSizeChanged", function(_, width)
        if layout.collecting or layout.layingOut or width == layout.width then return end
        local root = layout.root
        local rootLayout = root._settingsLayout
        if rootLayout and not rootLayout.collecting and not rootLayout.layingOut then
            ReflowSettingsLayout(root, root:GetWidth())
        end
    end)
    return layout
end

function LC.GetCompactControlWidth(width)
    return max(80, min(260, floor(width * 0.48)))
end

-- Bounded two-line labels keep long translations inside their own cell.
function LC.PrepareCompactRow(frame, label, controlWidth)
    frame:SetHeight(LC.SETTINGS_ROW_HEIGHT)
    if label then
        label:ClearAllPoints()
        label:SetPoint("LEFT", frame, "LEFT", 0, 0)
        label:SetPoint("RIGHT", frame, "RIGHT", -(controlWidth + 14), 0)
        label:SetHeight(32)
        label:SetJustifyH("LEFT")
        label:SetJustifyV("MIDDLE")
        label:SetWordWrap(true)
    end
    if not frame._rowSeparator then
        local separator = frame:CreateTexture(nil, "BACKGROUND")
        separator:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        separator:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        separator:SetHeight(1)
        local color = ns.WidgetConstants.SECTION_BORDER
        separator:SetColorTexture(color[1], color[2], color[3], color[4])
        frame._rowSeparator = separator
    end
end

local function IsFullWidth(widget)
    return widget._layoutFullWidth or widget._layoutRole or not widget.SetCompactLayout
end

local function PlaceWidget(widget, parent, x, y, width)
    widget:ClearAllPoints()
    widget:SetWidth(width)
    if widget.SetCompactLayout and not widget._layoutRole then widget:SetCompactLayout(width) end
    local offset = widget.SetCompactLayout and max(0, (LC.SETTINGS_ROW_HEIGHT - widget:GetHeight()) / 2) or 0
    widget:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -(y + offset))
end

ReflowSettingsLayout = function(parent, width)
    local layout = parent._settingsLayout
    if not layout or layout.layingOut or width <= 0 then return parent:GetHeight() end
    layout.layingOut = true
    layout.collecting = false
    layout.width = width

    local inset = layout.ownerSection and 0 or LC.PADDING_SIDE
    local usableWidth = max(1, width - inset * 2)
    local paired = usableWidth >= LC.SETTINGS_TWO_COLUMN_WIDTH
    local cellWidth = paired and (usableWidth - LC.SETTINGS_COLUMN_GAP) / 2 or usableWidth
    local y = layout.ownerSection and 0 or -LC.PADDING_TOP
    local rowHeight = 0
    local column = 0

    for i = 1, #layout.widgets do
        local widget = layout.widgets[i]
        if IsFullWidth(widget) then
            if column > 0 then
                y = y + rowHeight
                column = 0
                rowHeight = 0
            end
            if widget._layoutRole == "section" and i > 1 then y = y + LC.SPACING_BETWEEN_SECTIONS end
            PlaceWidget(widget, parent, inset, y, usableWidth)
            if widget._layoutRole == "section" and widget.content._settingsLayout then
                local childLayout = widget.content._settingsLayout
                childLayout.root = layout.root
                local contentWidth = max(1, usableWidth - widget._layoutContentInset * 2)
                widget.content:SetWidth(contentWidth)
                local contentHeight = ReflowSettingsLayout(widget.content, contentWidth)
                widget:SetContentHeight(contentHeight)
            elseif widget._layoutRole == "description" then
                -- Width has resolved, so the description can measure wrapped text.
                widget:SetText(widget._fontString:GetText())
            end
            local height = widget.SetCompactLayout and max(LC.SETTINGS_ROW_HEIGHT, widget:GetHeight())
                or widget:GetHeight()
            y = y + height
            if widget._layoutRole == "heading" or widget._layoutRole == "description" then
                y = y + LC.SPACING_AFTER_HEADER
            end
        else
            PlaceWidget(widget, parent, inset + column * (cellWidth + LC.SETTINGS_COLUMN_GAP), y, cellWidth)
            rowHeight = max(rowHeight, LC.SETTINGS_ROW_HEIGHT, widget:GetHeight())
            column = column + 1
            if not paired or column == 2 then
                y = y + rowHeight
                column = 0
                rowHeight = 0
            end
        end
        widget._layoutMeasuredHeight = widget:GetHeight()
    end
    if column > 0 then y = y + rowHeight end
    local height = max(1, y + (layout.ownerSection and 0 or LC.PADDING_BOTTOM))
    layout.height = height
    if parent:GetHeight() ~= height then parent:SetHeight(height) end
    layout.layingOut = false
    return height
end

function LC.EndSettingsLayout(parent)
    local layout = parent._settingsLayout
    if not layout then return parent:GetHeight() end
    layout.collecting = false
    return ReflowSettingsLayout(parent, parent:GetWidth())
end

function LC.RefreshSettingsLayout(parent)
    local layout = parent._settingsLayout
    if not layout then return end
    for i = 1, #layout.widgets do
        local widget = layout.widgets[i]
        if widget._layoutRole == "section" and widget.content._settingsLayout then
            LC.RefreshSettingsLayout(widget.content)
        elseif widget.Refresh then
            widget:Refresh()
        end
    end
end

-------------------------------------------------------------------------------
-- Anchor a widget to the parent at the current yOffset
--
-- Sets TOPLEFT and TOPRIGHT anchors with PADDING_SIDE insets.
-- Returns the new yOffset (widget bottom edge).
-------------------------------------------------------------------------------

function LC.AnchorWidget(widget, parent, yOffset, xLeft, xRight)
    RegisterWidget(widget, parent)
    xLeft = xLeft or LC.PADDING_SIDE
    xRight = xRight or -LC.PADDING_SIDE
    widget:SetPoint("TOPLEFT", parent, "TOPLEFT", xLeft, yOffset)
    widget:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xRight, yOffset)
    return yOffset - widget:GetHeight()
end

-------------------------------------------------------------------------------
-- Anchor a Section card to the parent at the current yOffset
--
-- Sets TOPLEFT and TOPRIGHT anchors with PADDING_SIDE insets.
-- Returns the new yOffset (section bottom edge).
-------------------------------------------------------------------------------

function LC.AnchorSection(section, parent, yOffset)
    RegisterWidget(section, parent)
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", LC.PADDING_SIDE, yOffset)
    section:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -LC.PADDING_SIDE, yOffset)
    return yOffset - section:GetHeight()
end

-------------------------------------------------------------------------------
-- Notify consumers to re-apply their appearance settings via event bus
-------------------------------------------------------------------------------

function LC.NotifyAppearanceChange()
    ns.Fire("OnAppearanceChanged", {})
end

-------------------------------------------------------------------------------
-- Build a sorted values table from a LibSharedMedia media type
--
-- Returns a table of { value = key, text = key } suitable for Dropdown.
-------------------------------------------------------------------------------

local LSM

local function GetLSM()
    if not LSM then
        LSM = LibStub("LibSharedMedia-3.0", true)
    end
    return LSM
end

function LC.BuildLSMValues(mediaType)
    local lsm = GetLSM()
    if not lsm then return {} end
    local hash = lsm:HashTable(mediaType)
    local values = {}
    for key in pairs(hash) do
        values[#values + 1] = { value = key, text = key }
    end
    table_sort(values, function(a, b) return a.text < b.text end)
    return values
end

-------------------------------------------------------------------------------
-- Expose on namespace
-------------------------------------------------------------------------------

ns.LayoutConstants = LC
