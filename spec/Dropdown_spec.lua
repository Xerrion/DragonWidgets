-------------------------------------------------------------------------------
-- Dropdown_spec.lua
-- Tests for ns.Widgets.CreateDropdown
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Dropdown", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        -- Dropdown depends on ScrollFrame internally (CreateScrollFrame call)
        mock.LoadWidget("ScrollFrame.lua")
        mock.LoadWidget("Dropdown.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- GetValue
    ---------------------------------------------------------------------------

    describe("GetValue", function()
        it("returns nil initially when no opts.get is provided", function()
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "One", value = 1 } },
            })

            assert.is_nil(dropdown:GetValue())
        end)

        it("returns opts.get() value when provided", function()
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "One", value = 1 }, { text = "Two", value = 2 } },
                get = function() return 2 end,
            })

            assert.are.equal(2, dropdown:GetValue())
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetValue
    ---------------------------------------------------------------------------

    describe("SetValue", function()
        it("stores value and GetValue returns new value", function()
            local storedValue = nil
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "One", value = 1 }, { text = "Two", value = 2 } },
                get = function() return storedValue end,
                set = function(v) storedValue = v end,
            })

            dropdown:SetValue(2)

            assert.are.equal(2, dropdown:GetValue())
        end)

        it("does not fire OnWidgetChanged event", function()
            local eventFired = false
            ns.On("OnWidgetChanged", function()
                eventFired = true
            end)

            local storedValue = nil
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "A", value = "a" } },
                get = function() return storedValue end,
                set = function(v) storedValue = v end,
            })

            dropdown:SetValue("a")

            assert.is_false(eventFired)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetDisabled
    ---------------------------------------------------------------------------

    describe("SetDisabled", function()
        it("can be called with true without error", function()
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "One", value = 1 } },
            })

            assert.has_no.errors(function()
                dropdown:SetDisabled(true)
            end)
        end)

        it("can be called with false without error", function()
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "One", value = 1 } },
            })

            dropdown:SetDisabled(true)

            assert.has_no.errors(function()
                dropdown:SetDisabled(false)
            end)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Refresh
    ---------------------------------------------------------------------------

    describe("Refresh", function()
        it("re-reads from opts.get()", function()
            local externalValue = 1
            local dropdown = ns.Widgets.CreateDropdown(parentFrame, {
                label = "Test Dropdown",
                key = "testKey",
                values = { { text = "One", value = 1 }, { text = "Two", value = 2 } },
                get = function() return externalValue end,
            })

            assert.are.equal(1, dropdown:GetValue())

            externalValue = 2
            dropdown:Refresh()

            assert.are.equal(2, dropdown:GetValue())
        end)
    end)
end)
