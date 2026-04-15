-------------------------------------------------------------------------------
-- ColorPicker_spec.lua
-- Tests for ns.Widgets.CreateColorPicker
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("ColorPicker", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("ColorPicker.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- GetValue
    ---------------------------------------------------------------------------

    describe("GetValue", function()
        it("returns (1, 1, 1, 1) initially when no opts.get is provided", function()
            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
            })

            local r, g, b, a = widget:GetValue()

            assert.are.equal(1, r)
            assert.are.equal(1, g)
            assert.are.equal(1, b)
            assert.are.equal(1, a)
        end)

        it("returns opts.get() values when provided", function()
            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
                get = function() return 0.5, 0.3, 0.8, 0.9 end,
            })

            local r, g, b, a = widget:GetValue()

            assert.are.equal(0.5, r)
            assert.are.equal(0.3, g)
            assert.are.equal(0.8, b)
            assert.are.equal(0.9, a)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetValue
    ---------------------------------------------------------------------------

    describe("SetValue", function()
        it("GetValue returns updated r, g, b, a values", function()
            local storedR, storedG, storedB, storedA = 1, 1, 1, 1
            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
                get = function() return storedR, storedG, storedB, storedA end,
                set = function(r, g, b, a)
                    storedR, storedG, storedB, storedA = r, g, b, a
                end,
            })

            widget:SetValue(0.2, 0.4, 0.6, 0.8)

            local r, g, b, a = widget:GetValue()
            assert.are.equal(0.2, r)
            assert.are.equal(0.4, g)
            assert.are.equal(0.6, b)
            assert.are.equal(0.8, a)
        end)

        it("does NOT fire OnWidgetChanged", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
            })

            widget:SetValue(0.5, 0.5, 0.5, 1.0)

            assert.is_false(eventFired)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetDisabled
    ---------------------------------------------------------------------------

    describe("SetDisabled", function()
        it("can be called without error", function()
            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
            })

            assert.has_no.errors(function()
                widget:SetDisabled(true)
            end)

            assert.has_no.errors(function()
                widget:SetDisabled(false)
            end)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Refresh
    ---------------------------------------------------------------------------

    describe("Refresh", function()
        it("re-reads from opts.get()", function()
            local externalR, externalG, externalB, externalA = 1, 0, 0, 1
            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
                get = function() return externalR, externalG, externalB, externalA end,
            })

            local r, g, b, a = widget:GetValue()
            assert.are.equal(1, r)
            assert.are.equal(0, g)
            assert.are.equal(0, b)
            assert.are.equal(1, a)

            externalR, externalG, externalB, externalA = 0, 1, 0, 0.5

            widget:Refresh()

            r, g, b, a = widget:GetValue()
            assert.are.equal(0, r)
            assert.are.equal(1, g)
            assert.are.equal(0, b)
            assert.are.equal(0.5, a)
        end)
    end)

    ---------------------------------------------------------------------------
    -- swatchFunc callback
    ---------------------------------------------------------------------------

    describe("swatchFunc callback", function()
        local function triggerSwatchFunc(widget, r, g, b, a)
            ColorPickerFrame._r = r or 1   -- luacheck: ignore 113
            ColorPickerFrame._g = g or 1   -- luacheck: ignore 113
            ColorPickerFrame._b = b or 1   -- luacheck: ignore 113
            ColorPickerFrame._a = a or 1   -- luacheck: ignore 113
            local onMouseUp = widget._border._scripts["OnMouseUp"]
            if onMouseUp then onMouseUp(widget._border, "LeftButton") end
            if ColorPickerFrame._swatchFunc then   -- luacheck: ignore 113
                ColorPickerFrame._swatchFunc()     -- luacheck: ignore 113
            end
        end

        it("fires OnWidgetChanged with correct payload", function()
            local receivedPayload
            ns.On("OnWidgetChanged", function(payload)
                receivedPayload = payload
            end)

            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "myColorKey",
            })

            triggerSwatchFunc(widget, 0.2, 0.4, 0.6, 1.0)

            assert.is_not_nil(receivedPayload)
            assert.are.equal("ColorPicker", receivedPayload.widgetType)
            assert.are.equal("myColorKey", receivedPayload.key)
            assert.are.equal(0.2, receivedPayload.value.r)
            assert.are.equal(0.4, receivedPayload.value.g)
            assert.are.equal(0.6, receivedPayload.value.b)
            assert.are.equal(1.0, receivedPayload.value.a)
        end)

        it("fires OnAppearanceChanged when isAppearance is true", function()
            local appearanceFired = false
            ns.On("OnAppearanceChanged", function()
                appearanceFired = true
            end)

            local widget = ns.Widgets.CreateColorPicker(parentFrame, {
                label = "Test Color",
                key = "testKey",
                isAppearance = true,
            })

            triggerSwatchFunc(widget, 1, 1, 1, 1)

            assert.is_true(appearanceFired)
        end)
    end)
end)
