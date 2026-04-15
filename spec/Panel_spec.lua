-------------------------------------------------------------------------------
-- Panel_spec.lua
-- Tests for ns.Widgets.CreatePanel
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Panel", function()
    local ns

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Panel.lua")
    end)

    ---------------------------------------------------------------------------
    -- Widget creation
    ---------------------------------------------------------------------------

    describe("creation", function()
        it("returns a frame", function()
            local panel = ns.Widgets.CreatePanel("TestPanel", 800, 600)

            assert.is_not_nil(panel)
            assert.is_not_nil(panel.SetHeight)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetTitle
    ---------------------------------------------------------------------------

    describe("SetTitle", function()
        it("updates the title text", function()
            local panel = ns.Widgets.CreatePanel("TestPanel", 800, 600)
            panel:SetTitle("My Panel Title")
            assert.are.equal("My Panel Title", panel.titleBar.text._text)
        end)
    end)
end)
