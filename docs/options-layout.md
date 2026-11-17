# Compact options and pinned previews

The goal is to make related settings easy to compare and show their effect without closing the options window. DragonLoot and DragonToast opt into a sidebar, a fixed preview area, and paired settings rows. The structure is informed by the installed EllesmereUI settings, while all controls and preview rendering remain owned by the Dragon addons.

## Assumptions and contracts

| Assumption | Class | Evidence and decision |
| --- | --- | --- |
| Settings must keep their values, ranges, callbacks and profile behaviour. | Fundamental | The existing tab declarations and display modules define those contracts. Layout collects their existing controls rather than replacing their settings logic. |
| Preview samples must not become real loot or notifications. | Fundamental | Live entry points can write history, use toast pools, start lifecycle timers, or update saved positions. Previews use separate parented frames and the existing render functions. |
| Each setting needs an entire row, with its label above it. | Inherited | Most controls only need a short label and one value. Compact rows put labels on the left and controls on the right, with two cells when space permits. |
| Navigation and preview should scroll away with settings. | Inherited | EllesmereUI separates its content header from its scroll frame. DragonWidgets likewise keeps navigation and the preview outside the scrolling settings area. |
| Every existing consumer can adopt the new geometry without changes. | Unknown | Some tabs anchor actions directly to other controls. The layout remains opt-in; the two consumer addons explicitly register those actions with the layout collector. |
| Mock frame dimensions reproduce all client fonts and UI scales. | Unknown | Tests verify anchors, resizing, event flow and isolation. Real-client text fitting and rendering still require an in-game check. |

The widget value API, lazy tab creation, declared control grouping, tooltips, dropdown and colour-picker behaviour remain contracts. The deliberate changes are navigation position, page ordering, window size, compact control placement, responsive pairing and preview visibility. The legacy horizontal tab layout and widget geometry remain the default for other consumers.

## Consumer API

```lua
local panel = DW.CreateOptionsPanel({
    name = "ExampleOptionsFrame",
    title = "Example Options",
    width = 1080,
    height = 720,
    navigation = "sidebar",
    settingsLayout = true,
    preview = {
        height = 170,
        createFunc = function(host)
            return {
                Refresh = function(self, selectedTabId) end,
                OnHide = function(self) end, -- optional cleanup
            }
        end,
    },
    tabs = tabs,
})
```

The preview host is a sibling of the scrolling settings wrappers. Refresh requests from opening, changing tabs, resizing, and widget/appearance events coalesce into one next-frame redraw. Hidden panels do not redraw previews. Closing through the public API, close button or Escape clears pending work and calls the optional cleanup method. Preview selectors can update their local state in a normal DragonWidgets button callback; that button's change event schedules the redraw.

`panel.RefreshVisibleWidgets()` silently re-reads the selected page's collected controls, invokes its optional `refreshFunc`, and requests a preview refresh. Consumers call it after profile changes and presets. Other pages refresh when selected. Conditional enabled states remain the consumer's responsibility through `refreshFunc`.

## Layout rules

Pages honor their numeric `order` value, with lower values first. Equal values retain declaration order; pages without a numeric order follow the ordered pages in their original order. Navigation, initial selection and lazy content creation use the same private ordered copy. Caller arrays and tab definitions are not modified. Previously, `order` was ignored and page positions depended on TOC file order.

The panel begins and ends layout collection around each lazy `createFunc`. Existing `LayoutConstants.AnchorWidget` and `AnchorSection` calls register controls in declaration order. Sections collect their own children recursively. Calling the same anchor helper twice does not duplicate a control.

Controls stay in their declared semantic groups. Their order is not sorted globally: paired fields, headings and dependent controls must remain together. Consumers arrange each page from layout and content to appearance and behaviour, with test or destructive actions at the end.

- At least 640 logical pixels of usable content width gives two equal cells, separated by 24 pixels. Narrower content uses one cell.
- Compact controls use 48-pixel rows. Labels can wrap within two lines. Inputs retain their original interaction behaviour.
- Section cards, headings, descriptions and controls without `SetCompactLayout` span the full width. Set `widget._layoutFullWidth = true` before anchoring to request a full row explicitly.
- Section heights and scroll ranges follow the reflowed children. Width and content-height changes trigger reflow without polling.
- Consumer previews can fit the whole sample or clip it at its configured scale. Captions identify reduced or clipped previews; clipping belongs to the preview host, never the live display.

No new DragonWidgets runtime files or dependencies are required. Consumer `Preview.lua` files must be loaded after their options bootstrap and before panel creation.

## Verification

Run `busted` and `luacheck .` in DragonWidgets. Layout tests cover declaration order, narrow/wide reflow, nested sections, full-width content, silent refresh, stable collection and legacy geometry. Options-panel tests cover lazy navigation, pinned preview ownership, coalesced refresh, hidden-state cleanup and profile refresh. Consumer tests exercise isolated rendering and profile wiring.

In game, `/reload`, open each addon, and check Display/Appearance plus Profiles. Change a size, font, colour and profile; confirm the preview updates and no live notification, loot roll or history entry is created. Scroll with the pointer over both settings and the preview, then close/reopen with Escape and the close button. Check narrower UI scales and long translations. Runtime screenshot verification is not available from the current desktop-driver connection.
