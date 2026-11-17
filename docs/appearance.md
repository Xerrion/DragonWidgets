# Appearance refresh

Make settings easy to scan, make editable controls recognizable, and make their current state clear over a busy game world. The design uses opaque charcoal surfaces, neutral text, and a single teal accent for values, selections, and keyboard focus. The palette is a design choice, not a platform requirement.

## Assumptions and evidence

| Assumption | Classification | Decision and evidence |
| --- | --- | --- |
| Consumers depend on widget geometry and exposed child frames. | Fundamental | Preserve outer sizes, layout constants, `.content`, and fields such as `._editBox`. DragonLoot's Profiles tab anchors a button to that edit box; both consumer addons advance their layouts using `GetHeight()`. |
| Value changes and event payloads are part of the library contract. | Fundamental | Keep callbacks, events, slider rounding/clamping, and programmatic setter semantics. In particular, Dropdown, ColorPicker, and ItemList setters still invoke consumer setters where they did before. |
| The toggle's decorative child must pass clicks through. | Fundamental | Preserve `box:EnableMouse(false)`. Commit `a3bc2cf` fixed a real click-interception bug. |
| Every heading should be gold and outlined. | Inherited | Use clear, unoutlined text and surface contrast for hierarchy. Keep `GOLD_COLOR` available for consumers using it independently. |
| Action and close buttons need Blizzard's textured templates. | Inherited | Use the same existing `BackdropTemplate` primitive as the other controls. Bind the action button's font string with native `SetFontString` so `SetText` and `GetText` continue to work. |
| A slim slider needs a smaller mouse target. | Inherited | Draw a 4-pixel track inside the existing 17-pixel slider. The scrollbar also retains its original 14-pixel mouse target. |
| A hardcoded Roman font is suitable for every locale. | Inherited | Read the font family from `ChatFontSmall`, which maps to client-specific glyph families. Fall back to `STANDARD_TEXT_FONT`, then the previous font path if unavailable. |
| Mock rendering predicts exact in-game text metrics and texture rasterization. | Unknown | Tests establish interactions and state transitions only. In-game rendering still needs visual inspection on supported clients and UI scales. |

## Deliberate changes

- Panels and sections have distinct dark surfaces and quiet one-pixel borders. Section headings no longer use outlines.
- Selected tabs have both a teal underline and a tinted surface. Dropdown selections have a narrow marker as well as a text-color change. An open dropdown keeps its focus border when the pointer leaves and opens four pixels below its button.
- Buttons share hover, pressed, and disabled styles. Inputs retain their focus border when the pointer leaves. Disabling an input clears keyboard focus, and hiding controls resets transient hover/pressed states.
- Titles, section headings, and tab labels stay on one line within their available width, avoiding overlap with adjacent controls. Long labels can truncate.
- Tabs keep their natural widths when they fit. The last tab only absorbs rounding space while shrinking an overflowing row; previously it stretched across all unused space even without overflow.
- Color swatches have an inset checkerboard so opacity is visible. Empty item slots use a simple plus mark; populated slots retain item artwork and quality colors.

No files were added to the runtime load order, no new assets or libraries are required, and the consumer TOCs do not need changes. Existing picker compatibility paths, dropdown outside-click handling, media previews, item-loading retries, and lazy tab creation remain in place.

## Verification

Run `busted` and `luacheck .` from the repository root. The interaction regressions cover native button text binding, press/leave/disable transitions, focus behavior, checkbox click-through, silent programmatic updates, and dropdown selection event counts. The mock now records enough visual state to verify these transitions. Its pre-existing missing texture methods and button text collision were repaired; the color-picker test now opens the picker before simulating a chosen color.

For an in-game check, open DragonLoot and DragonToast options at several UI scales. Check long/localized titles, narrow tabs, slider drag and typed entry, Enter/Escape, disabled controls, dropdown scrolling and outside-click dismissal, translucent colors, and item quality borders. Confirm panel dragging and closing still work. This refresh has not been run inside a WoW client.

The font and button APIs were checked against extracted Blizzard sources: [shared font inheritance](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_Fonts_Shared/Shared/Fonts.xml), [Retail font families](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_Fonts_Shared/Mainline/Fonts.xml), [Classic font families](https://github.com/Gethe/wow-ui-source/blob/classic_anniversary/Interface/AddOns/Blizzard_Fonts_Shared/Classic/Fonts.xml), and [native button text API](https://github.com/Gethe/wow-ui-source/blob/classic_anniversary/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleButtonAPIDocumentation.lua). Current Retail and Classic source branches were inspected; historical Cata rendering remains part of the in-game verification gap.
