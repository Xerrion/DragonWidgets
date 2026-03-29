-------------------------------------------------------------------------------
-- DragonWidgets.lua
-- Global namespace bootstrap, event bus, and CreateOptionsPanel factory
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ipairs = ipairs
local table_insert = table.insert

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
--     width     = number (optional),-- default 800
--     height    = number (optional),-- default 600
--     tabs      = table,            -- array of tab definitions
-- }
--
-- Returns { panel, tabGroup, Open(), Close(), Toggle(), RefreshVisibleWidgets() }
-------------------------------------------------------------------------------

function ns.CreateOptionsPanel(config)
    local panel = ns.Widgets.CreatePanel(config.name, config.width or 800, config.height or 600)
    panel:SetTitle(config.title or "")

    local tabGroup = ns.Widgets.CreateTabGroup(panel, config.tabs)
    tabGroup:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -32)
    tabGroup:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 8)

    table_insert(UISpecialFrames, config.name)

    local result = {}
    result.panel = panel
    result.tabGroup = tabGroup

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

    function result.RefreshVisibleWidgets()
        local selectedId = tabGroup:GetSelectedTab()
        if not selectedId then return end
        for _, tabDef in ipairs(config.tabs) do
            if tabDef.id == selectedId and tabDef.refreshFunc then
                tabDef.refreshFunc()
                break
            end
        end
    end

    return result
end
