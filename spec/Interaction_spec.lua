-------------------------------------------------------------------------------
-- Interaction_spec.lua
-- Regression coverage for state transitions in the custom-styled controls
-------------------------------------------------------------------------------

local mock = require("spec.wow_mock")

local function trigger(frame, event, ...)
    local handler = frame._scripts[event]
    assert.is_function(handler)
    handler(frame, ...)
end

describe("Styled control interactions", function()
    local ns, parent

    before_each(function()
        ns = mock.Reload()
        for _, widget in ipairs({ "Button", "Toggle", "Slider", "TextInput", "ScrollFrame", "Dropdown" }) do
            mock.LoadWidget(widget .. ".lua")
        end
        parent = CreateFrame("Frame")
    end)

    it("keeps native button text methods connected to the visible label", function()
        local button = ns.Widgets.CreateButton(parent, { text = "Preview" })
        assert.are.equal("Preview", button:GetText())
        assert.are.equal("Preview", button:GetFontString():GetText())

        button:SetText("Stop preview")

        assert.are.equal("Stop preview", button:GetText())
        assert.are.equal("Stop preview", button._text:GetText())
    end)

    it("clears a button's pressed and hover appearance when the pointer leaves", function()
        local button = ns.Widgets.CreateButton(parent, { text = "Preview" })
        local normalBorder = button._backdropBorderColor
        trigger(button, "OnEnter")
        assert.are_not.same(normalBorder, button._backdropBorderColor)
        trigger(button, "OnMouseDown", "LeftButton")
        assert.are.equal(-1, button._text._points[1][5])

        trigger(button, "OnLeave")

        assert.are.same(normalBorder, button._backdropBorderColor)
        assert.are.equal(0, button._text._points[1][5])
    end)

    it("does not restore a pressed button appearance after disabling and enabling", function()
        local button = ns.Widgets.CreateButton(parent, { text = "Preview" })
        local normalBorder = button._backdropBorderColor
        trigger(button, "OnEnter")
        trigger(button, "OnMouseDown", "LeftButton")

        button:SetDisabled(true)
        trigger(button, "OnEnter")
        trigger(button, "OnMouseDown", "LeftButton")

        assert.are.same(normalBorder, button._backdropBorderColor)
        assert.are.equal(0, button._text._points[1][5])
        button:SetDisabled(false)
        assert.are.same(normalBorder, button._backdropBorderColor)
    end)

    for _, kind in ipairs({ "TextInput", "Slider" }) do
        it("keeps " .. kind .. " focus visible after pointer leave without changing its value", function()
            local eventCount = 0
            ns.On("OnWidgetChanged", function() eventCount = eventCount + 1 end)
            local widget = ns.Widgets["Create" .. kind](parent, { label = "Value" })
            local editor = widget._editBox
            local initialValue = widget:GetValue()
            local normalBorder = editor._backdropBorderColor

            trigger(editor, "OnEnter")
            local hoverBorder = editor._backdropBorderColor
            editor:SetFocus()
            local focusBorder = editor._backdropBorderColor
            assert.are_not.same(hoverBorder, focusBorder)
            trigger(editor, "OnLeave")

            assert.are.same(focusBorder, editor._backdropBorderColor)
            editor:ClearFocus()
            assert.are.same(normalBorder, editor._backdropBorderColor)
            assert.are.equal(initialValue, widget:GetValue())
            assert.are.equal(0, eventCount)
        end)

        it("clears " .. kind .. " focus when disabled and refuses focus until enabled", function()
            local widget = ns.Widgets["Create" .. kind](parent, { label = "Value" })
            local editor = widget._editBox
            local normalBorder = editor._backdropBorderColor
            editor:SetFocus()
            trigger(editor, "OnEnter")

            widget:SetDisabled(true)
            assert.is_false(editor:HasFocus())
            trigger(editor, "OnEnter")
            editor:SetFocus()
            assert.is_false(editor:HasFocus())
            assert.are.same(normalBorder, editor._backdropBorderColor)

            widget:SetDisabled(false)
            assert.are.same(normalBorder, editor._backdropBorderColor)
            editor:SetFocus()
            assert.is_true(editor:HasFocus())
        end)
    end

    it("preserves checkbox click-through and synchronizes its mark on silent updates", function()
        local storedValue = false
        local eventCount = 0
        ns.On("OnWidgetChanged", function() eventCount = eventCount + 1 end)
        local toggle = ns.Widgets.CreateToggle(parent, {
            label = "Enabled",
            get = function() return storedValue end,
            set = function(value) storedValue = value end,
        })
        assert.is_false(toggle._box._mouseEnabled)
        assert.is_true(toggle._mouseEnabled)
        trigger(toggle, "OnMouseUp", "LeftButton")
        assert.is_true(toggle._box._checkMark:IsShown())
        assert.are.equal(1, eventCount)

        toggle:SetValue(false)
        assert.is_false(toggle._box._checkMark:IsShown())
        toggle:Refresh()
        assert.is_true(toggle._box._checkMark:IsShown())
        assert.are.equal(1, eventCount)
    end)

    it("opens and closes dropdowns without changing values, and emits once on selection", function()
        local storedValue = 1
        local eventCount = 0
        ns.On("OnWidgetChanged", function() eventCount = eventCount + 1 end)
        local dropdown = ns.Widgets.CreateDropdown(parent, {
            values = { { text = "One", value = 1 }, { text = "Two", value = 2 } },
            get = function() return storedValue end,
            set = function(value) storedValue = value end,
        })
        local normalBorder = dropdown._button._backdropBorderColor
        trigger(dropdown._button, "OnEnter")
        trigger(dropdown._button, "OnClick")
        local openBorder = dropdown._button._backdropBorderColor
        assert.are_not.same(normalBorder, openBorder)
        trigger(dropdown._button, "OnLeave")
        assert.are.same(openBorder, dropdown._button._backdropBorderColor)
        assert.is_true(dropdown._listFrame:IsShown())
        assert.is_true(dropdown._itemButtons[1]._selected:IsShown())
        assert.is_false(dropdown._itemButtons[2]._selected:IsShown())
        trigger(dropdown._button, "OnClick")
        assert.is_false(dropdown._listFrame:IsShown())
        assert.are.equal(0, eventCount)
        assert.are.equal(1, dropdown:GetValue())

        trigger(dropdown._button, "OnEnter")
        trigger(dropdown._button, "OnClick")
        trigger(dropdown, "OnHide")
        assert.is_false(dropdown._listFrame:IsShown())
        assert.are.same(normalBorder, dropdown._button._backdropBorderColor)
        assert.are.equal(0, eventCount)

        trigger(dropdown._button, "OnClick")
        trigger(dropdown._itemButtons[2], "OnClick")
        assert.are.equal(2, dropdown:GetValue())
        assert.are.equal("Two", dropdown._selectedText:GetText())
        assert.is_false(dropdown._listFrame:IsShown())
        assert.are.equal(1, eventCount)

        trigger(dropdown._button, "OnClick")
        assert.is_false(dropdown._itemButtons[1]._selected:IsShown())
        assert.is_true(dropdown._itemButtons[2]._selected:IsShown())
        dropdown:SetDisabled(true)
        assert.is_false(dropdown._listFrame:IsShown())
        trigger(dropdown._button, "OnClick")
        assert.is_false(dropdown._listFrame:IsShown())
        assert.are.equal(1, eventCount)
    end)
end)
