-------------------------------------------------------------------------------
-- Section_spec.lua
-- Tests for ns.Widgets.CreateSection
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Section", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Section.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- Widget creation
    ---------------------------------------------------------------------------

    describe("creation", function()
        it("returns a frame", function()
            local frame = ns.Widgets.CreateSection(parentFrame, "Section Header")

            assert.is_not_nil(frame)
            assert.is_not_nil(frame.SetHeight)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Content property
    ---------------------------------------------------------------------------

    describe("content", function()
        it("exists and is a frame", function()
            local frame = ns.Widgets.CreateSection(parentFrame, "Section Header")

            assert.is_not_nil(frame.content)
            assert.is_not_nil(frame.content.SetHeight)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetContentHeight
    ---------------------------------------------------------------------------

    describe("SetContentHeight", function()
        it("can be called without error", function()
            local frame = ns.Widgets.CreateSection(parentFrame, "Section Header")

            assert.has_no.errors(function()
                frame:SetContentHeight(100)
            end)
        end)
    end)
end)
