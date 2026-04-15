-------------------------------------------------------------------------------
-- TextInput_spec.lua
-- Tests for ns.Widgets.CreateTextInput
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("TextInput", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("TextInput.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- GetValue
    ---------------------------------------------------------------------------

    describe("GetValue", function()
        it("returns empty string initially when no opts.get is provided", function()
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
            })

            assert.are.equal("", widget:GetValue())
        end)

        it("returns opts.get() value when provided", function()
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                get = function() return "hello world" end,
            })

            assert.are.equal("hello world", widget:GetValue())
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetValue
    ---------------------------------------------------------------------------

    describe("SetValue", function()
        it("sets value and GetValue returns it", function()
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
            })

            widget:SetValue("new text")

            assert.are.equal("new text", widget:GetValue())
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetDisabled
    ---------------------------------------------------------------------------

    describe("SetDisabled", function()
        it("when disabled, OnEnterPressed does not call opts.set", function()
            local setCalled = false
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                set = function() setCalled = true end,
            })

            widget:SetDisabled(true)
            widget._editBox:SetText("typed text")
            local onEnterPressed = widget._editBox._scripts["OnEnterPressed"]
            onEnterPressed(widget._editBox)

            assert.is_false(setCalled)
        end)

        it("when disabled, OnEnterPressed does not fire events", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
            })

            widget:SetDisabled(true)
            widget._editBox:SetText("typed text")
            local onEnterPressed = widget._editBox._scripts["OnEnterPressed"]
            onEnterPressed(widget._editBox)

            assert.is_false(eventFired)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Refresh
    ---------------------------------------------------------------------------

    describe("Refresh", function()
        it("re-reads from opts.get()", function()
            local externalValue = "initial"
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                get = function() return externalValue end,
            })

            assert.are.equal("initial", widget:GetValue())

            externalValue = "updated"
            widget:Refresh()

            assert.are.equal("updated", widget:GetValue())
        end)
    end)

    ---------------------------------------------------------------------------
    -- OnEnterPressed
    ---------------------------------------------------------------------------

    describe("OnEnterPressed", function()
        it("calls opts.set with text", function()
            local receivedValue
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                set = function(v) receivedValue = v end,
            })

            widget._editBox:SetText("submitted text")
            local onEnterPressed = widget._editBox._scripts["OnEnterPressed"]
            onEnterPressed(widget._editBox)

            assert.are.equal("submitted text", receivedValue)
        end)

        it("fires OnWidgetChanged with correct payload", function()
            local receivedPayload
            ns.On("OnWidgetChanged", function(payload)
                receivedPayload = payload
            end)

            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "myInputKey",
            })

            widget._editBox:SetText("test value")
            local onEnterPressed = widget._editBox._scripts["OnEnterPressed"]
            onEnterPressed(widget._editBox)

            assert.is_not_nil(receivedPayload)
            assert.are.equal("TextInput", receivedPayload.widgetType)
            assert.are.equal("myInputKey", receivedPayload.key)
            assert.are.equal("test value", receivedPayload.value)
        end)

        it("fires OnAppearanceChanged when isAppearance is true", function()
            local appearanceFired = false
            ns.On("OnAppearanceChanged", function()
                appearanceFired = true
            end)

            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                isAppearance = true,
            })

            widget._editBox:SetText("value")
            local onEnterPressed = widget._editBox._scripts["OnEnterPressed"]
            onEnterPressed(widget._editBox)

            assert.is_true(appearanceFired)
        end)

        it("clears focus after submit", function()
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
            })

            -- ClearFocus is a no-op stub; verify it does not error
            widget._editBox:SetText("value")
            local onEnterPressed = widget._editBox._scripts["OnEnterPressed"]

            assert.has_no.errors(function()
                onEnterPressed(widget._editBox)
            end)
        end)
    end)

    ---------------------------------------------------------------------------
    -- OnEscapePressed
    ---------------------------------------------------------------------------

    describe("OnEscapePressed", function()
        it("reverts to opts.get() value", function()
            local externalValue = "original"
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                get = function() return externalValue end,
            })

            widget._editBox:SetText("unsaved changes")
            local onEscapePressed = widget._editBox._scripts["OnEscapePressed"]
            onEscapePressed(widget._editBox)

            assert.are.equal("original", widget:GetValue())
        end)

        it("does not call opts.set", function()
            local setCalled = false
            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                get = function() return "stored" end,
                set = function() setCalled = true end,
            })

            widget._editBox:SetText("unsaved")
            local onEscapePressed = widget._editBox._scripts["OnEscapePressed"]
            onEscapePressed(widget._editBox)

            assert.is_false(setCalled)
        end)

        it("does not fire events", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local widget = ns.Widgets.CreateTextInput(parentFrame, {
                label = "Test Input",
                key = "testKey",
                get = function() return "stored" end,
            })

            widget._editBox:SetText("unsaved")
            local onEscapePressed = widget._editBox._scripts["OnEscapePressed"]
            onEscapePressed(widget._editBox)

            assert.is_false(eventFired)
        end)
    end)
end)
