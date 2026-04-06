# DragonWidgets - Agent Guidelines

Project-specific guidelines for DragonWidgets. See the parent `../AGENTS.md` for general WoW addon development rules.

DragonWidgets is a shared event-driven widget library for Dragon* addon options panels. It is embedded as a git submodule into `DragonLoot_Options` and `DragonToast_Options` - it is not a standalone addon in production. Its own TOC only matters during local standalone development.

**GitHub**: https://github.com/Xerrion/DragonWidgets

---

## Target Versions

Retail, MoP Classic, TBC Anniversary, Cata Classic - all versions. No version-specific code in this library; it must work everywhere.

---

## Architecture

DragonWidgets is a pure widget library. No Ace3, no SavedVariables, no slash commands. One global: `DragonWidgetsNS`. Use the `wow-addon` agent for WoW API research before implementation when API correctness is uncertain.

### File Map

| File                          | Purpose                                          |
| ----------------------------- | ------------------------------------------------ |
| `DragonWidgets.lua`             | Bootstrap: `DragonWidgetsNS` global, event bus, `CreateOptionsPanel` factory |
| `LayoutConstants.lua`           | Spacing constants used by consumer `_Options` tabs |
| `Widgets/WidgetConstants.lua`   | Shared colors, fonts, textures used by all widgets |
| `Widgets/Toggle.lua`            | Checkbox toggle with label and optional tooltip  |
| `Widgets/Slider.lua`            | Numeric slider with label, fill bar, and tooltip |
| `Widgets/Dropdown.lua`          | Dropdown menu with label and tooltip             |
| `Widgets/ColorPicker.lua`       | Color swatch that opens the system color picker  |
| `Widgets/Button.lua`            | Clickable button with label                      |
| `Widgets/Header.lua`            | Section header label                             |
| `Widgets/Description.lua`       | Multi-line description text block                |
| `Widgets/Panel.lua`             | Options panel frame                              |
| `Widgets/Section.lua`           | Collapsible section container                    |
| `Widgets/ScrollFrame.lua`       | Scrollable content frame                         |
| `Widgets/TabGroup.lua`          | Tab group for switching between option pages     |
| `Widgets/ItemList.lua`          | List widget for item entries                     |
| `Widgets/ItemSlot.lua`          | Single item slot widget                          |
| `Widgets/TextInput.lua`         | Text input field                                 |

### Namespace Pattern

DragonWidgets uses a single global namespace table (not the `local ADDON_NAME, ns = ...` pattern, since this is a library):

```lua
local ns = DragonWidgetsNS
local WC = ns.WidgetConstants
```

### Event Bus

All widgets fire events via `ns.Fire(event, payload)`. Consumers subscribe with `ns.On(event, fn)`.

| Event              | Fired by             | Payload                                      |
| ------------------ | -------------------- | -------------------------------------------- |
| `OnWidgetChanged`    | All value widgets    | `{ widgetType, key, value }`                   |
| `OnAppearanceChanged`| Any widget with `opts.isAppearance = true`; also LayoutConstants | `{}`                                         |
| `OnPanelOpened`      | Panel factory        | `{}`                                          |
| `OnPanelClosed`      | Panel factory        | `{}`                                          |

### Widget API Contract

All widgets return a `frame` with a public API:

| Method            | Implemented by | Description                          |
| ----------------- | -------------- | ------------------------------------ |
| `frame:GetValue()`  | Toggle, Slider, ColorPicker, Dropdown, TextInput, ItemList | Returns current value |
| `frame:SetValue(v)` | Toggle, Slider, ColorPicker, Dropdown, TextInput, ItemList | Sets value without firing event |
| `frame:SetDisabled(bool)` | Toggle, Slider, ColorPicker, Dropdown, TextInput, ItemList | Enable/disable the widget |
| `frame:Refresh()`   | Toggle, Slider, ColorPicker, Dropdown, TextInput, ItemList | Re-reads from `opts.get()` |

---

## Deployment Model

DragonWidgets is **never loaded via its own TOC in production**. Consumer `_Options` addons list every DragonWidgets `.lua` file path explicitly in their TOC. The `DragonWidgets.toc` is only active during local standalone development.

```
# DragonLoot_Options.toc (example)
Libs\DragonWidgets\DragonWidgets\DragonWidgets.lua
Libs\DragonWidgets\DragonWidgets\LayoutConstants.lua
Libs\DragonWidgets\DragonWidgets\Widgets\WidgetConstants.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Toggle.lua
...
```

When adding a new widget file, it must be added to every consumer TOC that needs it.

---

## GitHub Projects

- **DragonWidgets - Bugs**: project #8 (`C-Bug` issues)
- **DragonWidgets - Feature Requests**: project #9 (`C-Feature` issues)

---

## Known Gotchas

1. **Child Frame mouse interception** - Child `Frame` widgets intercept mouse events from their parent. If a visual element is a `Frame` (not a texture), it must either have its own `OnMouseUp` handler or call `EnableMouse(false)` to pass clicks through to the parent.
2. **FontString cannot receive mouse events** - Labels are `FontString` regions; they cannot register click scripts. Click areas must be covered by the parent `Frame`.
3. **No Ace3** - Do not add Ace3 or any external library. No hard library dependencies. LibSharedMedia-3.0 is soft-loaded (`LibStub("LibSharedMedia-3.0", true)`) and only used for media-type dropdowns; absent LSM falls back to empty lists.
4. **Consumer TOC maintenance** - Adding a new `.lua` file requires updating every consumer `_Options` TOC manually.
5. **`DragonWidgetsNS` is the only global** - Never introduce additional globals.
