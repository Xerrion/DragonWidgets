# Dragon addon options layout

`DragonWidgetsNS.CreateOptionsPanel` supplies the shared layout for Dragon addon settings. It opens a 1080 × 720 panel with sidebar navigation and responsive settings rows. Declare each group as a section to use the same bordered cards as DragonLoot and DragonToast. A panel can also provide a pinned preview.

## Assumptions and contracts

| Assumption | Class | Evidence and decision |
| --- | --- | --- |
| Settings must keep their values, ranges, callbacks and profile behaviour. | Fundamental | The existing tab declarations and display modules define those contracts. Layout collects their existing controls rather than replacing their settings logic. |
| Preview samples must not become real loot or notifications. | Fundamental | Live entry points can write history, use toast pools, start lifecycle timers, or update saved positions. Previews use separate parented frames and the existing render functions. |
| Each setting needs an entire row, with its label above it. | Inherited | Most controls only need a short label and one value. Compact rows put labels on the left and controls on the right, with two cells when space permits. |
| Navigation and preview should scroll away with settings. | Inherited | EllesmereUI separates its content header from its scroll frame. DragonWidgets likewise keeps navigation and the preview outside the scrolling settings area. |
| Custom widget anchors work with compact layout. | Conditional | Compact layout reflows widgets registered with its layout collector. Tabs that need to position all widgets themselves can use `settingsLayout = false`. |
| Mock frame dimensions reproduce all client fonts and UI scales. | Unknown | Tests verify anchors, resizing, event flow and isolation. Real-client text fitting and rendering still require an in-game check. |

## Consumer API

### Create a settings panel

Load the embedded DragonWidgets files before the options code. Declare the tab's `sections` array in card order. Each section's `createFunc(content)` builds widgets parented to `content` and returns them in display order. DragonWidgets creates the card, positions its controls and sizes it for the current page width.

```lua
local DW = DragonWidgetsNS
local W = DW.Widgets
local showNotifications = true

local panel = DW.CreateOptionsPanel({
    name = "ExampleOptionsFrame",
    title = "Example Options",
    tabs = {
        {
            id = "general",
            label = "General",
            sections = {
                {
                    title = "Notifications",
                    createFunc = function(content)
                        return {
                            W.CreateToggle(content, {
                                label = "Show notifications",
                                get = function() return showNotifications end,
                                set = function(value) showNotifications = value end,
                            }),
                        }
                    end,
                },
            },
        },
    },
})

panel.Open()
```

The sidebar panel fits the available screen space when opened. Set `width` and `height` to request a different size. Set `navigation = "horizontal"` for horizontal tab navigation, which defaults to 800 × 600. Set `settingsLayout = false` to disable compact reflow. Declared sections then stack their controls vertically, and custom tab builders can position widgets manually.

For custom tabs, supply a tab-level `createFunc(parent)`. When a tab supplies both `sections` and `createFunc`, DragonWidgets builds the page from `sections`. DragonLoot and DragonToast use custom tab builders with `W.CreateSection(parent, title)` for each group. Create the controls under `section.content` and register them using `LayoutConstants.AnchorWidget`. Set each card's content height with `section:SetContentHeight(height)` and place it using `LayoutConstants.AnchorSection`.

### Add a pinned preview

Pass `preview = { createFunc = createPreview }` to add a preview above the settings scroll area. The default height is 170 logical pixels. Set `preview.height` to override it. The factory receives the preview host and returns a controller with `Refresh(tabId)` and optional `OnHide()` methods.

The preview host is a sibling of the scrolling settings wrappers. Refresh requests from opening, changing tabs, resizing, and widget/appearance events coalesce into one next-frame redraw. Hidden panels do not redraw previews. Closing through the public API, close button or Escape clears pending work and calls the optional cleanup method. Preview selectors can update their local state in a normal DragonWidgets button callback. The button's change event schedules the redraw.

`panel.RefreshVisibleWidgets()` silently re-reads the selected page's collected controls, invokes its optional `refreshFunc`, and requests a preview refresh. Consumers call it after profile changes and presets. Other pages refresh when selected. Conditional enabled states remain the consumer's responsibility through `refreshFunc`.

## Layout rules

Pages honor their numeric `order` value, with lower values first. Equal values retain declaration order. Pages without a numeric order follow the ordered pages in their original order. Navigation, initial selection and lazy content creation use the same private ordered copy.

Each page builds its content on the first visit. With compact layout enabled, the panel collects widgets during construction so they can reflow and refresh. For declared sections the panel registers the cards and returned widgets. For custom tabs, the anchor helpers register controls in call order. Sections collect their own children recursively. Calling the same anchor helper twice registers the control once.

Place paired fields, headings and dependent controls together within their group. Consumers arrange each page from layout and content to appearance and behaviour, with test or destructive actions at the end.

- At least 640 logical pixels of usable content width gives two equal cells, separated by 24 pixels. Narrower content uses one cell.
- Compact controls use 48-pixel rows. Labels can wrap within two lines. Inputs retain their original interaction behaviour.
- Section cards, headings, descriptions and controls without `SetCompactLayout` span the full width. Set `widget._layoutFullWidth = true` before returning or anchoring a control to give it a full row.
- Section heights and scroll ranges follow the reflowed children. Width and content-height changes trigger reflow without polling.
- Consumer previews can fit the whole sample or clip it at its configured scale. Captions identify reduced or clipped previews. Apply clipping to the preview host.

Load the addon's preview implementation after its options bootstrap and before panel creation.

## Verification

Run `busted` and `luacheck .` in DragonWidgets. Layout tests cover declaration order, narrow/wide reflow, nested sections, full-width content, silent refresh, stable collection and legacy geometry. Options-panel tests cover lazy navigation, pinned preview ownership, coalesced refresh, hidden-state cleanup and profile refresh. Consumer tests exercise isolated rendering and profile wiring.

In game, run `/reload`, open each addon, and check Display/Appearance and Profiles. Change a size, font, colour and profile. Confirm that the preview updates and no live notification, loot roll or history entry is created. Scroll with the pointer over both settings and the preview, then close and reopen with Escape and the close button. Check narrower UI scales and long translations.
