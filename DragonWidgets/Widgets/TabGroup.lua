-------------------------------------------------------------------------------
-- TabGroup.lua
-- Horizontal tabs or sidebar navigation with lazy, scrollable settings pages
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ns = DragonWidgetsNS
local WC = ns.WidgetConstants

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local floor = math.floor
local sort = table.sort
local pairs, ipairs = pairs, ipairs

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local TAB_HEIGHT = 28
local TAB_MIN_WIDTH = 60
local TAB_PADDING = 16

-------------------------------------------------------------------------------
-- Style a tab button as active or inactive
-------------------------------------------------------------------------------

local function StyleTabActive(btn)
    btn._active = true
    btn._bg:SetColorTexture(
        WC.ACCENT_SOFT[1], WC.ACCENT_SOFT[2], WC.ACCENT_SOFT[3], WC.ACCENT_SOFT[4]
    )
    btn._text:SetTextColor(WC.ACCENT_COLOR[1], WC.ACCENT_COLOR[2], WC.ACCENT_COLOR[3])
    btn._bottomBorder:Hide()
    if btn._activeBar then btn._activeBar:Show() end
end

local function StyleTabInactive(btn)
    btn._active = false
    local bg = btn._hovered and WC.WIDGET_BG or WC.PANEL_BG
    local textColor = btn._hovered and WC.TEXT_COLOR or WC.GRAY_COLOR
    btn._bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
    btn._text:SetTextColor(textColor[1], textColor[2], textColor[3])
    btn._bottomBorder:Show()
    if btn._activeBar then btn._activeBar:Hide() end
end

-------------------------------------------------------------------------------
-- Create a single tab button
-------------------------------------------------------------------------------

local function CreateTabButton(parent, label, tabGroup, sidebar)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(sidebar and 34 or TAB_HEIGHT)

    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(WC.PANEL_BG[1], WC.PANEL_BG[2], WC.PANEL_BG[3], WC.PANEL_BG[4])
    btn._bg = bg

    -- Text
    local text = btn:CreateFontString(nil, "OVERLAY")
    text:SetFont(WC.FONT_PATH, WC.FONT_SIZE, "")
    text:SetJustifyH(sidebar and "LEFT" or "CENTER")
    text:SetWordWrap(false)
    text:SetText(label)
    text:SetTextColor(WC.GRAY_COLOR[1], WC.GRAY_COLOR[2], WC.GRAY_COLOR[3])
    btn._text = text

    -- Auto-width based on text
    local textWidth = text:GetStringWidth() or 40
    local width = math.max(TAB_MIN_WIDTH, textWidth + TAB_PADDING * 2)
    btn:SetWidth(width)
    text:SetPoint("LEFT", btn, "LEFT", 8, 0)
    text:SetPoint("RIGHT", btn, "RIGHT", -8, 0)

    -- Bottom border (separator for inactive tabs)
    local bottomBorder = btn:CreateTexture(nil, "ARTWORK")
    bottomBorder:SetHeight(1)
    bottomBorder:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
    bottomBorder:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
    bottomBorder:SetColorTexture(
        WC.SECTION_BORDER[1], WC.SECTION_BORDER[2],
        WC.SECTION_BORDER[3], WC.SECTION_BORDER[4]
    )
    btn._bottomBorder = bottomBorder

    -- Accent underline keeps selection visible independently of text color.
    local activeBar = btn:CreateTexture(nil, "ARTWORK")
    if sidebar then
        activeBar:SetWidth(2)
        activeBar:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, -5)
        activeBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 5)
    else
        activeBar:SetHeight(2)
        activeBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        activeBar:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
    end
    activeBar:SetColorTexture(WC.ACCENT_COLOR[1], WC.ACCENT_COLOR[2], WC.ACCENT_COLOR[3], 1)
    activeBar:Hide()
    btn._activeBar = activeBar

    btn:SetScript("OnEnter", function()
        btn._hovered = true
        if not btn._active then StyleTabInactive(btn) end
    end)
    btn:SetScript("OnLeave", function()
        btn._hovered = false
        if not btn._active then StyleTabInactive(btn) end
    end)
    btn:SetScript("OnHide", function()
        btn._hovered = false
        if not btn._active then StyleTabInactive(btn) end
    end)

    -- Click handler delegates to tabGroup
    btn:SetScript("OnClick", function()
        tabGroup:SelectTab(btn._tabId)
    end)

    return btn
end

-------------------------------------------------------------------------------
-- Factory: CreateTabGroup
-------------------------------------------------------------------------------

function ns.Widgets.CreateTabGroup(parent, tabs, opts)
    opts = opts or {}
    local sidebar = opts.navigation == "sidebar"
    local tabGroup = CreateFrame("Frame", nil, parent)

    -- Navigation across the top or down the left side
    local tabBar = CreateFrame("Frame", nil, tabGroup)
    tabBar:SetPoint("TOPLEFT", tabGroup, "TOPLEFT", 0, 0)
    if sidebar then
        tabBar:SetWidth(opts.sidebarWidth or 160)
        tabBar:SetPoint("BOTTOMLEFT", tabGroup, "BOTTOMLEFT", 0, 0)
    else
        tabBar:SetHeight(TAB_HEIGHT)
        tabBar:SetPoint("TOPRIGHT", tabGroup, "TOPRIGHT", 0, 0)
    end

    -- Content area beside navigation
    local contentArea = CreateFrame("Frame", nil, tabGroup)
    if sidebar then
        contentArea:SetPoint("TOPLEFT", tabBar, "TOPRIGHT", 12, 0)
    else
        contentArea:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, 0)
    end
    contentArea:SetPoint("BOTTOMRIGHT", tabGroup, "BOTTOMRIGHT", 0, 0)

    -- The title and preview stay outside the scrolling settings viewport.
    local contentTop = 1
    local pageTitle
    if sidebar then
        pageTitle = contentArea:CreateFontString(nil, "OVERLAY")
        pageTitle:SetFont(WC.FONT_PATH, WC.FONT_SIZE_TITLE, "")
        pageTitle:SetTextColor(WC.TEXT_COLOR[1], WC.TEXT_COLOR[2], WC.TEXT_COLOR[3])
        pageTitle:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 10, -8)
        pageTitle:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", -10, -8)
        pageTitle:SetJustifyH("LEFT")
        pageTitle:SetWordWrap(false)
        contentTop = 34
    end
    if opts.previewHeight then
        local previewHost = CreateFrame("Frame", nil, contentArea, "BackdropTemplate")
        previewHost:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 10, -contentTop)
        previewHost:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", -10, -contentTop)
        previewHost:SetHeight(opts.previewHeight)
        WC.ApplyBackdrop(previewHost, WC.INPUT_BG, WC.SECTION_BORDER)
        tabGroup.previewHost = previewHost
        contentTop = contentTop + opts.previewHeight + 12
    end

    -- Separator line below tab bar
    local separator = contentArea:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(1)
    separator:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
    separator:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", 0, 0)
    separator:SetColorTexture(
        WC.SECTION_BORDER[1], WC.SECTION_BORDER[2],
        WC.SECTION_BORDER[3], WC.SECTION_BORDER[4]
    )

    -- State
    local tabButtons = {}
    local contentFrames = {}
    local definitions = {}
    local selectedTab = nil
    tabGroup._tabButtons = tabButtons
    tabGroup._contentFrames = contentFrames

    -- Create tab buttons
    local xOffset = 0
    for i, tabDef in ipairs(tabs) do
        local btn = CreateTabButton(tabBar, tabDef.label, tabGroup, sidebar)
        definitions[tabDef.id] = tabDef
        btn._tabId = tabDef.id
        btn._baseWidth = btn:GetWidth()
        btn._tabOrder = i
        if sidebar then
            btn:SetPoint("TOPLEFT", tabBar, "TOPLEFT", 0, -(i - 1) * 38 - 4)
            btn:SetPoint("TOPRIGHT", tabBar, "TOPRIGHT", 0, -(i - 1) * 38 - 4)
        else
            btn:SetPoint("TOPLEFT", tabBar, "TOPLEFT", xOffset, 0)
            xOffset = xOffset + btn._baseWidth + 1
        end
        tabButtons[tabDef.id] = btn
    end

    -- Overflow handling: shrink tabs proportionally if total width exceeds bar
    local function ResizeTabs()
        local availableWidth = tabBar:GetWidth()
        if availableWidth <= 0 then return end

        -- Collect tabs and measure total base width
        local tabList = {}
        local totalWidth = 0
        for _, btn in pairs(tabButtons) do
            tabList[#tabList + 1] = btn
            totalWidth = totalWidth + btn._baseWidth
        end
        totalWidth = totalWidth + (#tabList - 1) * 1 -- 1px gaps

        sort(tabList, function(a, b) return a._tabOrder < b._tabOrder end)

        -- Scale only tab widths (gaps stay at 1px)
        local gapWidth = (#tabList - 1) * 1
        local scale = 1
        if totalWidth > availableWidth then
            scale = (availableWidth - gapWidth) / (totalWidth - gapWidth)
        end

        -- Preserve natural widths when they fit; only absorb overflow rounding.
        local xOff = 0
        for i, btn in ipairs(tabList) do
            local w
            if i == #tabList and scale < 1 then
                w = availableWidth - xOff
            else
                w = floor(btn._baseWidth * scale)
            end
            btn:SetWidth(w)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", tabBar, "TOPLEFT", xOff, 0)
            xOff = xOff + w + 1
        end
    end

    if not sidebar then tabBar:SetScript("OnSizeChanged", ResizeTabs) end

    function tabGroup:RefreshSelected()
        local definition = definitions[selectedTab]
        local content = contentFrames[selectedTab]
        if content and opts.settingsLayout then
            ns.LayoutConstants.RefreshSettingsLayout(content.scrollChild)
        end
        if definition and definition.refreshFunc then definition.refreshFunc() end
        if content then content:UpdateScrollRange() end
    end

    -- SelectTab: switch to a tab, lazy-create content on first visit
    function tabGroup.SelectTab(_, id)
        if selectedTab == id or not definitions[id] then return end

        -- Deselect previous
        if selectedTab and tabButtons[selectedTab] then
            StyleTabInactive(tabButtons[selectedTab])
            if contentFrames[selectedTab] then
                contentFrames[selectedTab]:Hide()
            end
        end

        selectedTab = id
        if pageTitle then pageTitle:SetText(definitions[id].label) end

        -- Activate new tab button
        if tabButtons[id] then
            StyleTabActive(tabButtons[id])
        end

        -- Lazy-create content frame on first visit
        if not contentFrames[id] then
            local scrollWrapper = ns.Widgets.CreateScrollFrame(contentArea)
            scrollWrapper:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, -contentTop)
            scrollWrapper:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", 0, 0)

            if opts.settingsLayout then ns.LayoutConstants.BeginSettingsLayout(scrollWrapper.scrollChild) end

            -- Find the tab definition and call its createFunc
            for _, tabDef in ipairs(tabs) do
                if tabDef.id == id and tabDef.createFunc then
                    tabDef.createFunc(scrollWrapper.scrollChild)
                    break
                end
            end

            if opts.settingsLayout then ns.LayoutConstants.EndSettingsLayout(scrollWrapper.scrollChild) end

            contentFrames[id] = scrollWrapper
        end

        -- Show the content
        contentFrames[id]:Show()
        tabGroup:RefreshSelected()
        if opts.onSelect then opts.onSelect(id) end
    end

    function tabGroup.GetSelectedTab(_)
        return selectedTab
    end

    if tabGroup.previewHost then
        tabGroup.previewHost:EnableMouseWheel(true)
        tabGroup.previewHost:SetScript("OnMouseWheel", function(_, delta)
            local content = contentFrames[selectedTab]
            if content then
                local bar = content._scrollBar
                bar:SetValue(bar:GetValue() - delta * 20)
            end
        end)
    end

    -- Auto-select first tab if available
    if tabs[1] then
        tabGroup:SelectTab(tabs[1].id)
    end

    return tabGroup
end
