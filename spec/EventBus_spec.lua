-------------------------------------------------------------------------------
-- EventBus_spec.lua
-- Tests for ns.On / ns.Fire event bus in DragonWidgets.lua
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("EventBus", function()
    local ns

    before_each(function()
        ns = mock.Reload()
    end)

    describe("ns.Fire", function()
        it("does not error when no listeners are registered", function()
            assert.has_no.errors(function()
                ns.Fire("SomeEvent", { foo = "bar" })
            end)
        end)

        it("passes empty table when payload is nil", function()
            local receivedPayload
            ns.On("TestEvent", function(payload)
                receivedPayload = payload
            end)

            ns.Fire("TestEvent")

            assert.is_table(receivedPayload)
            assert.are.same({}, receivedPayload)
        end)

        it("passes payload table correctly to all listeners", function()
            local receivedA, receivedB
            ns.On("TestEvent", function(payload)
                receivedA = payload
            end)
            ns.On("TestEvent", function(payload)
                receivedB = payload
            end)

            local sentPayload = { widgetType = "Toggle", key = "myKey", value = true }
            ns.Fire("TestEvent", sentPayload)

            assert.are.same(sentPayload, receivedA)
            assert.are.same(sentPayload, receivedB)
        end)
    end)

    describe("ns.On", function()
        it("registers a listener that fires on ns.Fire", function()
            local wasCalled = false
            ns.On("WidgetChanged", function()
                wasCalled = true
            end)

            ns.Fire("WidgetChanged", {})

            assert.is_true(wasCalled)
        end)

        it("supports multiple listeners on the same event", function()
            local callCount = 0
            ns.On("MultiEvent", function() callCount = callCount + 1 end)
            ns.On("MultiEvent", function() callCount = callCount + 1 end)
            ns.On("MultiEvent", function() callCount = callCount + 1 end)

            ns.Fire("MultiEvent", {})

            assert.are.equal(3, callCount)
        end)

        it("does not cross-fire between different events", function()
            local alphaFired = false
            local betaFired = false

            ns.On("Alpha", function() alphaFired = true end)
            ns.On("Beta", function() betaFired = true end)

            ns.Fire("Alpha", {})

            assert.is_true(alphaFired)
            assert.is_false(betaFired)
        end)
    end)
end)
