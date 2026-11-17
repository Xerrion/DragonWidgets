-------------------------------------------------------------------------------
-- DragonWidgets.lua
-- Global namespace bootstrap, event bus, and CreateOptionsPanel factory
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ipairs = ipairs
local table_insert = table.insert
local math_min = math.min
local math_max = math.max
local UIParent = UIParent

-------------------------------------------------------------------------------
-- Global namespace
-------------------------------------------------------------------------------

DragonWidgetsNS = {}
local ns = DragonWidgetsNS

ns.Widgets = {}

-------------------------------------------------------------------------------
-- Event bus
-------------------------------------------------------------------------------

local _listeners = {}

function ns.On(event, fn)
    _listeners[event] = _listeners[event] or {}
    _listeners[event][#_listeners[event] + 1] = fn
end

function ns.Fire(event, payload)
    if not _listeners[event] then return end
    for _, fn in ipairs(_listeners[event]) do
        fn(payload or {})
    end
end

-------------------------------------------------------------------------------
-- CreateOptionsPanel factory
--
-- config = {
--     name      = string,           -- global frame name
--     title     = string (optional),-- title bar text
--     width     = number (optional),-- default 1080 (800 with horizontal navigation)
--     height    = number (optional),-- default 720 (600 with horizontal navigation)
--     tabs      = table,            -- array of tabs with sections or a custom createFunc
--     navigation = "sidebar",      -- default; use "horizontal" for tabs across the top
--     settingsLayout = boolean,    -- default true; false keeps manual settings geometry
--     preview = { height, createFunc }, -- optional fixed preview host; createFunc
--                                      -- returns a controller with Refresh(tabId)
--                                      -- and optional OnHide() cleanup
-- }
--
-- Returns { panel, tabGroup, Open(), Close(), Toggle(), RefreshVisibleWidgets() }
-------------------------------------------------------------------------------

function ns.CreateOptionsPanel(config)
    local navigation = config.navigation or "sidebar"
    local sidebar = navigation == "sidebar"
    local width = config.width or (sidebar and 1080 or 800)
    local height = config.height or (sidebar and 720 or 600)
    local panel = ns.Widgets.CreatePanel(config.name, width, height)
    panel:SetTitle(config.title or "")

    local tabGroup
    local previewController
    local previewPending = false

    local function FlushPreview(host)
        host:SetScript("OnUpdate", nil)
        previewPending = false
        if panel:IsShown() and previewController then
            previewController:Refresh(tabGroup:GetSelectedTab())
        end
    end

    -- Sliders can emit both value and appearance events in one frame. Draw once,
    -- after anchors resolve, and do no preview work while the panel is hidden.
    local function RefreshPreview()
        if not previewController or not panel:IsShown() or previewPending then return end
        previewPending = true
        tabGroup.previewHost:SetScript("OnUpdate", FlushPreview)
    end

    tabGroup = ns.Widgets.CreateTabGroup(panel, config.tabs, {
        navigation = navigation,
        settingsLayout = config.settingsLayout ~= false,
        previewHeight = config.preview and (config.preview.height or 170),
        onSelect = RefreshPreview,
    })
    tabGroup:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, sidebar and -40 or -32)
    tabGroup:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 8)

    if config.preview then
        previewController = config.preview.createFunc(tabGroup.previewHost)
        tabGroup.previewHost:HookScript("OnSizeChanged", RefreshPreview)
        ns.On("OnWidgetChanged", RefreshPreview)
        ns.On("OnAppearanceChanged", RefreshPreview)
    end

    table_insert(UISpecialFrames, config.name)

    local result = {}
    result.panel = panel
    result.tabGroup = tabGroup
    result.preview = previewController
    result.RefreshPreview = RefreshPreview

    function result.RefreshVisibleWidgets()
        tabGroup:RefreshSelected()
        RefreshPreview()
    end

    panel:HookScript("OnShow", function()
        if sidebar then
            local screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()
            if screenWidth > 0 and screenHeight > 0 then
                panel:SetSize(
                    math_min(width, math_max(1, screenWidth - 32)),
                    math_min(height, math_max(1, screenHeight - 32))
                )
            end
        end
        result.RefreshVisibleWidgets()
    end)
    panel:HookScript("OnHide", function()
        if tabGroup.previewHost then tabGroup.previewHost:SetScript("OnUpdate", nil) end
        previewPending = false
        if previewController and previewController.OnHide then previewController:OnHide() end
    end)

    function result.Open()
        panel:Show()
        ns.Fire("OnPanelOpened", {})
    end

    function result.Close()
        panel:Hide()
        ns.Fire("OnPanelClosed", {})
    end

    function result.Toggle()
        if panel:IsShown() then
            result.Close()
        else
            result.Open()
        end
    end

    return result
end
