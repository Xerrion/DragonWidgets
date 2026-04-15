-------------------------------------------------------------------------------
-- Description_spec.lua
-- Tests for ns.Widgets.CreateDescription
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Description", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Description.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- Widget creation
    ---------------------------------------------------------------------------

    describe("creation", function()
        it("returns a frame", function()
            local frame = ns.Widgets.CreateDescription(parentFrame, "some text")

            assert.is_not_nil(frame)
            assert.is_not_nil(frame.SetHeight)
        end)
    end)

    ---------------------------------------------------------------------------
    -- SetText
    ---------------------------------------------------------------------------

    describe("SetText", function()
        it("updates the internal font string text", function()
            local frame = ns.Widgets.CreateDescription(parentFrame, "original text")

            assert.are.equal("original text", frame._fontString:GetText())

            frame:SetText("new text")

            assert.are.equal("new text", frame._fontString:GetText())
        end)
    end)
end)
