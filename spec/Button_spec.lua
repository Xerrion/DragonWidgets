-------------------------------------------------------------------------------
-- Button_spec.lua
-- Tests for ns.Widgets.CreateButton
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Button", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Button.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- Creation
    ---------------------------------------------------------------------------

    describe("creation", function()
        it("creates without error", function()
            assert.has_no.errors(function()
                ns.Widgets.CreateButton(parentFrame, {
                    text = "Click Me",
                    key = "testKey",
                })
            end)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetDisabled
    ---------------------------------------------------------------------------

    describe("SetDisabled", function()
        it("can be called without error", function()
            local btn = ns.Widgets.CreateButton(parentFrame, {
                text = "Click Me",
                key = "testKey",
            })

            assert.has_no.errors(function()
                btn:SetDisabled(true)
            end)

            assert.has_no.errors(function()
                btn:SetDisabled(false)
            end)
        end)
    end)

    ---------------------------------------------------------------------------
    -- OnClick
    ---------------------------------------------------------------------------

    describe("OnClick", function()
        it("fires OnWidgetChanged with correct payload", function()
            local receivedPayload
            ns.On("OnWidgetChanged", function(payload)
                receivedPayload = payload
            end)

            local btn = ns.Widgets.CreateButton(parentFrame, {
                text = "Click Me",
                key = "myButtonKey",
            })

            local onClick = btn._scripts["OnClick"]
            onClick(btn)

            assert.is_not_nil(receivedPayload)
            assert.are.equal("Button", receivedPayload.widgetType)
            assert.are.equal("myButtonKey", receivedPayload.key)
        end)

        it("calls opts.onClick callback", function()
            local clickCalled = false
            local btn = ns.Widgets.CreateButton(parentFrame, {
                text = "Click Me",
                key = "testKey",
                onClick = function() clickCalled = true end,
            })

            local onClick = btn._scripts["OnClick"]
            onClick(btn)

            assert.is_true(clickCalled)
        end)

        it("does not fire OnWidgetChanged when disabled", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local btn = ns.Widgets.CreateButton(parentFrame, {
                text = "Click Me",
                key = "testKey",
            })

            btn:SetDisabled(true)
            local onClick = btn._scripts["OnClick"]
            onClick(btn)

            assert.is_false(eventFired)
        end)

        it("does not call opts.onClick when disabled", function()
            local clickCalled = false
            local btn = ns.Widgets.CreateButton(parentFrame, {
                text = "Click Me",
                key = "testKey",
                onClick = function() clickCalled = true end,
            })

            btn:SetDisabled(true)
            local onClick = btn._scripts["OnClick"]
            onClick(btn)

            assert.is_false(clickCalled)
        end)
    end)
end)
