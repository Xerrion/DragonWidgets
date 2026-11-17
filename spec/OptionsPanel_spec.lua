local mock = require("spec.wow_mock")

describe("options panel lifecycle", function()
    local ns

    before_each(function()
        ns = mock.Reload()
        assert(loadfile("DragonWidgets/LayoutConstants.lua"))()
        mock.LoadWidget("Panel.lua")
        mock.LoadWidget("Section.lua")
        mock.LoadWidget("ScrollFrame.lua")
        mock.LoadWidget("TabGroup.lua")
        mock.LoadWidget("Toggle.lua")
        mock.LoadWidget("Slider.lua")
        UIParent:SetSize(1920, 1080)
    end)

    local function CreatePanel(options)
        options = options or {}
        local stats = { created = {}, refreshed = {}, previews = {}, hides = 0 }
        local config = {
            name = "DragonWidgetsOptionsLifecycleTest",
            title = "Settings",
            navigation = options.navigation,
            settingsLayout = options.settingsLayout,
            width = options.width,
            height = options.height,
            tabs = {},
        }
        for _, id in ipairs({ "z", "a", "m" }) do
            config.tabs[#config.tabs + 1] = {
                id = id,
                label = "Page " .. id,
                createFunc = function(content)
                    stats.created[id] = (stats.created[id] or 0) + 1
                    content:SetHeight(120)
                    if options.createFunc then options.createFunc(content, id) end
                end,
                refreshFunc = function()
                    stats.refreshed[id] = (stats.refreshed[id] or 0) + 1
                end,
            }
        end
        if options.preview then
            config.preview = {
                height = 170,
                createFunc = function(host)
                    stats.host = host
                    return {
                        Refresh = function(_, tabId) stats.previews[#stats.previews + 1] = tabId end,
                        OnHide = function() stats.hides = stats.hides + 1 end,
                    }
                end,
            }
        end
        return ns.CreateOptionsPanel(config), stats
    end

    local function DrawPending(host)
        local callback = host._scripts.OnUpdate
        assert.is_function(callback)
        callback(host, 1 / 60)
    end

    it("opens the shared sidebar and compact layout by default", function()
        local result, stats = CreatePanel()
        local group = result.tabGroup
        assert.are.equal(1080, result.panel:GetWidth())
        assert.are.equal(720, result.panel:GetHeight())
        assert.are.equal(34, group._tabButtons.z:GetHeight())
        assert.are.equal(-40, group._points[1].y)
        assert.are.equal("z", group:GetSelectedTab())
        assert.are.same({ z = 1 }, stats.created)
        assert.is_nil(group.previewHost)
        assert.is_not_nil(group._contentFrames.z.scrollChild._settingsLayout)
        assert.is_false(result.panel:IsShown())

        UIParent:SetSize(1024, 700)
        result.Open()
        assert.are.equal(992, result.panel:GetWidth())
        assert.are.equal(668, result.panel:GetHeight())
    end)

    it("keeps the legacy size with explicit horizontal navigation", function()
        local result = CreatePanel({ navigation = "horizontal" })
        local group = result.tabGroup
        assert.are.equal(800, result.panel:GetWidth())
        assert.are.equal(600, result.panel:GetHeight())
        assert.are.equal(28, group._tabButtons.z:GetHeight())
        assert.are.equal(-32, group._points[1].y)
        assert.is_not_nil(group._contentFrames.z.scrollChild._settingsLayout)
    end)

    it("preserves manual page layout when settings collection is explicitly disabled", function()
        local result = CreatePanel({ settingsLayout = false })
        local group = result.tabGroup
        local content = group._contentFrames.z.scrollChild
        assert.are.equal(34, group._tabButtons.z:GetHeight())
        assert.is_nil(content._settingsLayout)
        assert.are.equal(120, content:GetHeight())
    end)

    it("keeps sidebar declaration order and creates each page only on its first visit", function()
        local result, stats = CreatePanel({ navigation = "sidebar", settingsLayout = true })
        local group = result.tabGroup
        local buttons = group._tabButtons
        assert.are.equal(-4, buttons.z._points[1].y)
        assert.are.equal(-42, buttons.a._points[1].y)
        assert.are.equal(-80, buttons.m._points[1].y)
        assert.are.equal(34, buttons.z:GetHeight())
        assert.is_not_nil(group._contentFrames.z.scrollChild._settingsLayout)

        group:SelectTab("a")
        group:SelectTab("a")
        group:SelectTab("missing")
        assert.are.equal("a", group:GetSelectedTab())
        assert.is_false(group._contentFrames.z:IsShown())
        assert.is_true(group._contentFrames.a:IsShown())
        assert.is_false(buttons.z._activeBar:IsShown())
        assert.is_true(buttons.a._activeBar:IsShown())
        group:SelectTab("z")
        assert.are.same({ z = 1, a = 1 }, stats.created)
        assert.are.same({ z = 2, a = 1 }, stats.refreshed)
    end)

    it("lazily builds ordered section cards and reflows and refreshes their controls", function()
        local enabled = false
        local toggle, slider
        local result = ns.CreateOptionsPanel({
            name = "DragonWidgetsSectionCardsTest",
            tabs = {
                { id = "general", label = "General" },
                {
                    id = "appearance",
                    label = "Appearance",
                    sections = {
                        {
                            title = "Display",
                            createFunc = function(content)
                                toggle = ns.Widgets.CreateToggle(content, { get = function() return enabled end })
                                slider = ns.Widgets.CreateSlider(content, {})
                                return { toggle, slider }
                            end,
                        },
                        {
                            title = "Behavior",
                            createFunc = function(content)
                                return { ns.Widgets.CreateToggle(content, {}) }
                            end,
                        },
                    },
                },
            },
        })
        assert.is_nil(toggle)
        result.tabGroup:SelectTab("appearance")
        local page = result.tabGroup._contentFrames.appearance.scrollChild
        page:SetWidth(900)
        local sections = page._settingsLayout.widgets
        local first, second = sections[1], sections[2]
        assert.are.equal(2, #sections)
        assert.are.equal("Display", first._headerLabel:GetText())
        assert.are.equal("Behavior", second._headerLabel:GetText())
        assert.are.equal(first.content, toggle._parent)
        assert.are.equal(first.content, slider._parent)
        assert.are.equal(toggle, first.content._settingsLayout.widgets[1])
        assert.are.equal(slider, first.content._settingsLayout.widgets[2])
        assert.are.equal(toggle._points[1].y, slider._points[1].y)
        assert.is_true(toggle._points[1].x < slider._points[1].x)

        local wideHeight = page:GetHeight()
        page:SetWidth(620)
        assert.are.equal(toggle._points[1].x, slider._points[1].x)
        assert.is_true(toggle._points[1].y > slider._points[1].y)
        assert.is_true(page:GetHeight() > wideHeight)

        assert.is_false(toggle:GetValue())
        enabled = true
        result.RefreshVisibleWidgets()
        assert.is_true(toggle:GetValue())
        result.tabGroup:SelectTab("general")
        result.tabGroup:SelectTab("appearance")
        assert.are.equal(first, page._settingsLayout.widgets[1])
        assert.are.equal(toggle, first.content._settingsLayout.widgets[1])
    end)

    it("stacks declarative section cards with manual anchors when collection is disabled", function()
        local function CreateControls(content)
            return { ns.Widgets.CreateToggle(content, {}), ns.Widgets.CreateToggle(content, {}) }
        end
        local result = ns.CreateOptionsPanel({
            name = "DragonWidgetsManualSectionCardsTest",
            settingsLayout = false,
            tabs = {
                {
                    id = "general",
                    label = "General",
                    sections = {
                        { title = "Display", createFunc = CreateControls },
                        { title = "Behavior", createFunc = CreateControls },
                    },
                },
            },
        })
        local page = result.tabGroup._contentFrames.general.scrollChild
        local first, second = page._children[1], page._children[2]
        local firstControl, secondControl = first.content._children[1], first.content._children[2]
        assert.is_nil(page._settingsLayout)
        assert.is_nil(first.content._settingsLayout)
        assert.are.equal(first.content, firstControl._points[1].relativeTo)
        assert.are.equal(first.content, secondControl._points[1].relativeTo)
        assert.is_true(firstControl._points[1].y - firstControl:GetHeight() > secondControl._points[1].y)
        assert.is_true(first.content:GetHeight() > -secondControl._points[1].y + secondControl:GetHeight())
        assert.is_true(first._points[1].y - first:GetHeight() > second._points[1].y)
        assert.is_true(page:GetHeight() > -second._points[1].y + second:GetHeight())
    end)

    it("keeps the preview outside every page's scroll content", function()
        local result = CreatePanel({ navigation = "sidebar", preview = true })
        local group = result.tabGroup
        local host = group.previewHost
        local first = group._contentFrames.z
        assert.are.equal(first._parent, host._parent)
        assert.are_not.equal(first.scrollChild, host._parent)
        assert.are.equal(-34, host._points[1].y)
        assert.are.equal(-216, first._points[1].y)

        group:SelectTab("a")
        assert.are.equal(group._contentFrames.a._parent, host._parent)
        assert.are.equal(host, group.previewHost)
        assert.are.equal(170, host:GetHeight())
    end)

    it("coalesces show, value, appearance and tab changes into one draw of the latest tab", function()
        local result, stats = CreatePanel({ navigation = "sidebar", preview = true })
        result.Open()
        local queued = stats.host._scripts.OnUpdate
        assert.is_function(queued)
        assert.are.equal(0, #stats.previews)
        ns.Fire("OnWidgetChanged", { key = "scale", value = 1.2 })
        ns.Fire("OnAppearanceChanged", {})
        result.tabGroup:SelectTab("a")
        assert.are.equal(queued, stats.host._scripts.OnUpdate)
        DrawPending(stats.host)
        assert.are.same({ "a" }, stats.previews)
        assert.is_nil(stats.host._scripts.OnUpdate)

        ns.Fire("OnWidgetChanged", { key = "width", value = 320 })
        ns.Fire("OnAppearanceChanged", {})
        DrawPending(stats.host)
        assert.are.same({ "a", "a" }, stats.previews)
        assert.is_nil(stats.host._scripts.OnUpdate)
    end)

    it("does not schedule or render hidden previews for events, resizing or tab changes", function()
        local result, stats = CreatePanel({ navigation = "sidebar", preview = true })
        ns.Fire("OnWidgetChanged", {})
        ns.Fire("OnAppearanceChanged", {})
        stats.host:SetWidth(700)
        result.tabGroup:SelectTab("a")
        result.RefreshPreview()
        assert.are.equal(0, #stats.previews)
        assert.is_nil(stats.host._scripts.OnUpdate)
    end)

    it("cancels pending work on hide, runs cleanup and redraws once after reopening", function()
        local result, stats = CreatePanel({ navigation = "sidebar", preview = true })
        result.Open()
        assert.is_function(stats.host._scripts.OnUpdate)
        result.Close()
        assert.is_nil(stats.host._scripts.OnUpdate)
        assert.are.equal(1, stats.hides)
        assert.are.equal(0, #stats.previews)

        ns.Fire("OnAppearanceChanged", {})
        assert.is_nil(stats.host._scripts.OnUpdate)
        result.Open()
        DrawPending(stats.host)
        assert.are.same({ "z" }, stats.previews)
        assert.are.same({ z = 1 }, stats.created)
        result.panel:Hide() -- Escape/close button hides the frame directly.
        assert.are.equal(2, stats.hides)
        assert.is_nil(stats.host._scripts.OnUpdate)
    end)

    it("refreshes only selected page getters after profile changes without writes or change events", function()
        local values = { z = { enabled = false, scale = 20 }, a = { enabled = true, scale = 30 } }
        local controls, writes, events = {}, 0, 0
        local LC = ns.LayoutConstants
        ns.On("OnWidgetChanged", function() events = events + 1 end)
        ns.On("OnAppearanceChanged", function() events = events + 1 end)
        local result, stats = CreatePanel({
            navigation = "sidebar",
            settingsLayout = true,
            preview = true,
            createFunc = function(content, id)
                local function Write() writes = writes + 1 end
                local toggle = ns.Widgets.CreateToggle(content, {
                    get = function() return values[id].enabled end, set = Write, isAppearance = true,
                })
                local slider = ns.Widgets.CreateSlider(content, {
                    get = function() return values[id].scale end, set = Write, isAppearance = true,
                })
                controls[id] = { toggle = toggle, slider = slider }
                LC.AnchorWidget(toggle, content, -10)
                LC.AnchorWidget(slider, content, -40)
            end,
        })
        result.Open()
        result.tabGroup:SelectTab("a")
        DrawPending(stats.host)
        values.z = { enabled = true, scale = 80 }
        values.a = { enabled = false, scale = 65 }
        result.RefreshVisibleWidgets()
        assert.is_false(controls.a.toggle:GetValue())
        assert.are.equal(65, controls.a.slider:GetValue())
        assert.is_false(controls.z.toggle:GetValue())
        assert.are.equal(20, controls.z.slider:GetValue())
        assert.are.equal(0, writes)
        assert.are.equal(0, events)
        DrawPending(stats.host)

        result.tabGroup:SelectTab("z")
        assert.is_true(controls.z.toggle:GetValue())
        assert.are.equal(80, controls.z.slider:GetValue())
        assert.are.equal(0, writes)
        assert.are.equal(0, events)
    end)

    it("fits sidebar panels to the available UI dimensions when opened", function()
        UIParent:SetSize(1024, 768)
        local result = CreatePanel({ navigation = "sidebar", width = 1200, height = 900 })
        result.Open()
        assert.are.equal(992, result.panel:GetWidth())
        assert.are.equal(736, result.panel:GetHeight())
        result.Close()
        UIParent:SetSize(1920, 1080)
        result.Open()
        assert.are.equal(1200, result.panel:GetWidth())
        assert.are.equal(900, result.panel:GetHeight())
    end)
end)
