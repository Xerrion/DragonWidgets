-------------------------------------------------------------------------------
-- Header_spec.lua
-- Tests for ns.Widgets.CreateHeader
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

describe("Header", function()
    local ns
    local parentFrame

    before_each(function()
        ns = mock.Reload()
        mock.LoadWidget("Header.lua")
        parentFrame = CreateFrame("Frame") -- luacheck: ignore 113
    end)

    ---------------------------------------------------------------------------
    -- Widget creation
    ---------------------------------------------------------------------------

    describe("creation", function()
        it("returns a frame", function()
            local frame = ns.Widgets.CreateHeader(parentFrame, "Header Text")

            assert.is_not_nil(frame)
            assert.is_not_nil(frame.SetHeight)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Font string text
    ---------------------------------------------------------------------------

    describe("font string", function()
        it("text matches the constructor argument", function()
            local frame = ns.Widgets.CreateHeader(parentFrame, "My Header")

            assert.are.equal("My Header", frame._fontString:GetText())
        end)
    end)
end)
