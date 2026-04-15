-------------------------------------------------------------------------------
-- Slider_spec.lua
-- Tests for ns.Widgets.CreateSlider
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Slider", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Slider.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- GetValue
    ---------------------------------------------------------------------------

    describe("GetValue", function()
        it("returns opts.min initially when no opts.get is provided", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 5,
                max = 100,
            })

            assert.are.equal(5, slider:GetValue())
        end)

        it("returns opts.get() value when provided", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                get = function() return 42 end,
            })

            assert.are.equal(42, slider:GetValue())
        end)

        it("returns opts.min when opts.get is not provided", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 10,
                max = 50,
            })

            assert.are.equal(10, slider:GetValue())
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetValue
    ---------------------------------------------------------------------------

    describe("SetValue", function()
        it("clamps to max", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
            })

            slider:SetValue(200)

            assert.are.equal(100, slider:GetValue())
        end)

        it("clamps to min", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 10,
                max = 100,
            })

            slider:SetValue(-5)

            assert.are.equal(10, slider:GetValue())
        end)

        it("rounds to step", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                step = 5,
            })

            slider:SetValue(17)

            assert.are.equal(15, slider:GetValue())
        end)

        it("does NOT call opts.set", function()
            local setCalled = false
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                set = function() setCalled = true end,
            })

            slider:SetValue(50)

            assert.is_false(setCalled)
        end)

        it("does NOT fire events", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
            })

            slider:SetValue(50)

            assert.is_false(eventFired)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetDisabled
    ---------------------------------------------------------------------------

    describe("SetDisabled", function()
        it("dims state without error", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
            })

            assert.has_no.errors(function()
                slider:SetDisabled(true)
            end)
        end)

        it("re-enables without error", function()
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
            })

            slider:SetDisabled(true)

            assert.has_no.errors(function()
                slider:SetDisabled(false)
            end)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Refresh
    ---------------------------------------------------------------------------

    describe("Refresh", function()
        it("re-reads from opts.get()", function()
            local externalValue = 20
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                get = function() return externalValue end,
            })

            assert.are.equal(20, slider:GetValue())

            externalValue = 75
            slider:Refresh()

            assert.are.equal(75, slider:GetValue())
        end)
    end)

    ---------------------------------------------------------------------------
    -- OnValueChanged (slider script)
    ---------------------------------------------------------------------------

    describe("OnValueChanged", function()
        it("fires OnWidgetChanged with correct payload", function()
            local receivedPayload
            ns.On("OnWidgetChanged", function(payload)
                receivedPayload = payload
            end)

            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "mySliderKey",
                min = 0,
                max = 100,
                step = 1,
            })

            local onValueChanged = slider._slider._scripts["OnValueChanged"]
            onValueChanged(slider._slider, 42)

            assert.is_not_nil(receivedPayload)
            assert.are.equal("Slider", receivedPayload.widgetType)
            assert.are.equal("mySliderKey", receivedPayload.key)
            assert.are.equal(42, receivedPayload.value)
        end)

        it("fires OnAppearanceChanged when isAppearance is true", function()
            local appearanceFired = false
            ns.On("OnAppearanceChanged", function()
                appearanceFired = true
            end)

            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                isAppearance = true,
            })

            local onValueChanged = slider._slider._scripts["OnValueChanged"]
            onValueChanged(slider._slider, 50)

            assert.is_true(appearanceFired)
        end)

        it("does NOT fire OnAppearanceChanged when isAppearance is nil", function()
            local appearanceFired = false
            ns.On("OnAppearanceChanged", function()
                appearanceFired = true
            end)

            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
            })

            local onValueChanged = slider._slider._scripts["OnValueChanged"]
            onValueChanged(slider._slider, 50)

            assert.is_false(appearanceFired)
        end)
    end)

    ---------------------------------------------------------------------------
    -- EditBox OnEnterPressed
    ---------------------------------------------------------------------------

    describe("EditBox OnEnterPressed", function()
        it("parses typed value, clamps, calls opts.set, fires OnWidgetChanged", function()
            local receivedSetValue
            local receivedPayload
            ns.On("OnWidgetChanged", function(payload)
                receivedPayload = payload
            end)

            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "mySliderKey",
                min = 0,
                max = 100,
                step = 1,
                set = function(v) receivedSetValue = v end,
            })

            slider._editBox:SetText("75")
            local onEnterPressed = slider._editBox._scripts["OnEnterPressed"]
            onEnterPressed(slider._editBox)

            assert.are.equal(75, receivedSetValue)
            assert.is_not_nil(receivedPayload)
            assert.are.equal("Slider", receivedPayload.widgetType)
            assert.are.equal("mySliderKey", receivedPayload.key)
            assert.are.equal(75, receivedPayload.value)
        end)

        it("clamps typed value to max", function()
            local receivedSetValue
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                step = 1,
                set = function(v) receivedSetValue = v end,
            })

            slider._editBox:SetText("999")
            local onEnterPressed = slider._editBox._scripts["OnEnterPressed"]
            onEnterPressed(slider._editBox)

            assert.are.equal(100, receivedSetValue)
        end)

        it("ignores non-numeric input and does not call opts.set", function()
            local setCalled = false
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                set = function() setCalled = true end,
            })

            slider._editBox:SetText("abc")
            local onEnterPressed = slider._editBox._scripts["OnEnterPressed"]
            onEnterPressed(slider._editBox)

            assert.is_false(setCalled)
        end)

        it("handles percent format by stripping % and dividing by 100", function()
            local receivedSetValue
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 1,
                step = 0.01,
                isPercent = true,
                set = function(v) receivedSetValue = v end,
            })

            slider._editBox:SetText("75%")
            local onEnterPressed = slider._editBox._scripts["OnEnterPressed"]
            onEnterPressed(slider._editBox)

            assert.are.equal(0.75, receivedSetValue)
        end)
    end)

    ---------------------------------------------------------------------------
    -- EditBox OnEscapePressed
    ---------------------------------------------------------------------------

    describe("EditBox OnEscapePressed", function()
        it("does not call opts.set", function()
            local setCalled = false
            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
                set = function() setCalled = true end,
            })

            local onEscapePressed = slider._editBox._scripts["OnEscapePressed"]
            onEscapePressed(slider._editBox)

            assert.is_false(setCalled)
        end)

        it("does not fire events", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local slider = ns.Widgets.CreateSlider(parentFrame, {
                label = "Test Slider",
                key = "testKey",
                min = 0,
                max = 100,
            })

            local onEscapePressed = slider._editBox._scripts["OnEscapePressed"]
            onEscapePressed(slider._editBox)

            assert.is_false(eventFired)
        end)
    end)
end)
