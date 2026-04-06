-------------------------------------------------------------------------------
-- Toggle_spec.lua
-- Tests for ns.Widgets.CreateToggle
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Toggle", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Toggle.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    -------------------------------------------------------------------------------
    -- GetValue
    -------------------------------------------------------------------------------

    describe("GetValue", function()
        it("returns false initially when no opts.get is provided", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            assert.is_false(toggle:GetValue())
        end)

        it("returns true when initialized with opts.get returning true", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
                get = function() return true end,
            })

            assert.is_true(toggle:GetValue())
        end)
    end)

    -------------------------------------------------------------------------------
    -- SetValue
    -------------------------------------------------------------------------------

    describe("SetValue", function()
        it("sets checked state to true", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            toggle:SetValue(true)

            assert.is_true(toggle:GetValue())
        end)

        it("sets checked state to false", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
                get = function() return true end,
            })

            toggle:SetValue(false)

            assert.is_false(toggle:GetValue())
        end)

        it("coerces truthy value (1) to true", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            toggle:SetValue(1)

            assert.is_true(toggle:GetValue())
        end)

        it("does NOT call opts.set", function()
            local setCalled = false
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
                set = function() setCalled = true end,
            })

            toggle:SetValue(true)

            assert.is_false(setCalled)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Click behavior (OnMouseUp)
    -------------------------------------------------------------------------------

    describe("clicking", function()
        it("toggles state from false to true on LeftButton", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_true(toggle:GetValue())
        end)

        it("does NOT toggle state on RightButton", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "RightButton")

            assert.is_false(toggle:GetValue())
        end)

        it("calls opts.set with new value on click", function()
            local receivedValue
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
                set = function(v) receivedValue = v end,
            })

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_true(receivedValue)
        end)

        it("fires OnWidgetChanged event with correct payload", function()
            local receivedPayload
            ns.On("OnWidgetChanged", function(payload)
                receivedPayload = payload
            end)

            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "myToggleKey",
            })

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_not_nil(receivedPayload)
            assert.are.equal("Toggle", receivedPayload.widgetType)
            assert.are.equal("myToggleKey", receivedPayload.key)
            assert.is_true(receivedPayload.value)
        end)

        it("fires OnAppearanceChanged when opts.isAppearance is true", function()
            local appearanceFired = false
            ns.On("OnAppearanceChanged", function()
                appearanceFired = true
            end)

            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
                isAppearance = true,
            })

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_true(appearanceFired)
        end)

        it("does NOT fire OnAppearanceChanged when opts.isAppearance is nil", function()
            local appearanceFired = false
            ns.On("OnAppearanceChanged", function()
                appearanceFired = true
            end)

            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_false(appearanceFired)
        end)
    end)

    -------------------------------------------------------------------------------
    -- SetDisabled
    -------------------------------------------------------------------------------

    describe("SetDisabled", function()
        it("prevents clicking from changing state when disabled", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            toggle:SetDisabled(true)

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_false(toggle:GetValue())
        end)

        it("re-enables clicking after SetDisabled(false)", function()
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
            })

            toggle:SetDisabled(true)
            toggle:SetDisabled(false)

            local onMouseUp = toggle._scripts["OnMouseUp"]
            onMouseUp(toggle, "LeftButton")

            assert.is_true(toggle:GetValue())
        end)
    end)

    -------------------------------------------------------------------------------
    -- Refresh
    -------------------------------------------------------------------------------

    describe("Refresh", function()
        it("re-reads from opts.get", function()
            local externalValue = false
            local toggle = ns.Widgets.CreateToggle(parentFrame, {
                label = "Test Toggle",
                key = "testKey",
                get = function() return externalValue end,
            })

            assert.is_false(toggle:GetValue())

            externalValue = true
            toggle:Refresh()

            assert.is_true(toggle:GetValue())
        end)
    end)
end)
