local mock = require("spec.wow_mock")

describe("options panel lifecycle", function()
    local ns

    before_each(function()
        ns = mock.Reload()
        assert(loadfile("DragonWidgets/LayoutConstants.lua"))()
        mock.LoadWidget("Panel.lua")
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

    it("retains horizontal navigation and uncollected content by default", function()
        local result, stats = CreatePanel()
        local group = result.tabGroup
        local tabBar = group._children[1]
        assert.are.equal(800, result.panel:GetWidth())
        assert.are.equal(600, result.panel:GetHeight())
        assert.are.equal(28, tabBar:GetHeight())
        assert.are.equal("z", group:GetSelectedTab())
        assert.are.same({ z = 1 }, stats.created)
        assert.is_nil(group.previewHost)
        assert.is_nil(group._contentFrames.z.scrollChild._settingsLayout)
        assert.is_false(result.panel:IsShown())
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
