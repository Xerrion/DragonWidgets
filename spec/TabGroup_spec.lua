local mock = require("spec.wow_mock")

describe("TabGroup layout", function()
    local group, tabBar, buttons, created

    before_each(function()
        local ns = mock.Reload()
        mock.LoadWidget("ScrollFrame.lua")
        mock.LoadWidget("TabGroup.lua")
        created = {}
        local tabs = {}
        -- Deliberately not alphabetic: layout follows the supplied order.
        for _, id in ipairs({ "z", "a", "m" }) do
            tabs[#tabs + 1] = {
                id = id,
                label = id,
                createFunc = function() created[id] = (created[id] or 0) + 1 end,
            }
        end
        group = ns.Widgets.CreateTabGroup(CreateFrame("Frame"), tabs)
        tabBar = group._children[1]
        buttons = tabBar._children
    end)

    local function resize(tabBarFrame, width)
        tabBarFrame:SetWidth(width)
        tabBarFrame._scripts.OnSizeChanged(tabBarFrame)
    end

    it("keeps fitting tabs at their natural width in declaration order", function()
        local widths = { buttons[1]:GetWidth(), buttons[2]:GetWidth(), buttons[3]:GetWidth() }
        resize(tabBar, 500)

        for i, id in ipairs({ "z", "a", "m" }) do
            assert.are.equal(id, buttons[i]._text:GetText())
            assert.are.equal(widths[i], buttons[i]:GetWidth())
        end
        assert.are.equal(0, buttons[1]._points[1].x)
        assert.are.equal(widths[1] + 1, buttons[2]._points[1].x)
        assert.are.equal(widths[1] + widths[2] + 2, buttons[3]._points[1].x)
    end)

    it("fits overflowing tabs exactly by assigning rounding remainder to the last tab", function()
        resize(tabBar, 100)

        assert.are.equal(32, buttons[1]:GetWidth())
        assert.are.equal(32, buttons[2]:GetWidth())
        assert.are.equal(34, buttons[3]:GetWidth())
        assert.are.equal(0, buttons[1]._points[1].x)
        assert.are.equal(33, buttons[2]._points[1].x)
        assert.are.equal(66, buttons[3]._points[1].x)
        assert.are.equal(100, buttons[3]._points[1].x + buttons[3]:GetWidth())

        resize(tabBar, 500)
        assert.are.equal(60, buttons[3]:GetWidth())
    end)

    it("creates content only on the first visit and retains the selected tab during resize", function()
        assert.are.same({ z = 1 }, created)
        assert.are.equal("z", group:GetSelectedTab())

        group:SelectTab("a")
        group:SelectTab("a")
        resize(tabBar, 100)
        assert.are.equal("a", group:GetSelectedTab())
        group:SelectTab("z")

        assert.are.same({ z = 1, a = 1 }, created)
        assert.is_true(buttons[1]._activeBar:IsShown())
        assert.is_false(buttons[2]._activeBar:IsShown())
    end)
end)

describe("TabGroup declared page order", function()
    for _, navigation in ipairs({ "tabs", "sidebar" }) do
        it("uses stable order for " .. navigation .. " without mutating consumer definitions", function()
            local ns = mock.Reload()
            mock.LoadWidget("ScrollFrame.lua")
            mock.LoadWidget("TabGroup.lua")
            local created, selected = {}, {}
            local tabs = {}
            local declarations = {
                { "extra", nil }, { "last", 30 }, { "first", 10 },
                { "same", 10 }, { "extra2", nil },
            }
            for _, entry in ipairs(declarations) do
                local id = entry[1]
                tabs[#tabs + 1] = {
                    id = id, label = id, order = entry[2],
                    createFunc = function() created[id] = (created[id] or 0) + 1 end,
                }
            end
            local originals = { unpack(tabs) }
            local group = ns.Widgets.CreateTabGroup(CreateFrame("Frame"), tabs, {
                navigation = navigation,
                onSelect = function(id) selected[#selected + 1] = id end,
            })

            local expected = { "first", "same", "last", "extra", "extra2" }
            for i, id in ipairs(expected) do
                assert.are.equal(id, group._children[1]._children[i]._tabId)
                assert.are.equal(i, group._tabButtons[id]._tabOrder)
            end
            for i, entry in ipairs(declarations) do
                assert.are.equal(originals[i], tabs[i])
                assert.are.equal(entry[1], tabs[i].id)
                assert.are.equal(entry[2], tabs[i].order)
            end
            assert.are.equal("first", group:GetSelectedTab())
            assert.are.same({ first = 1 }, created)

            group:SelectTab("last")
            group:SelectTab("first")
            assert.are.same({ first = 1, last = 1 }, created)
            assert.are.same({ "first", "last", "first" }, selected)
        end)
    end
end)
