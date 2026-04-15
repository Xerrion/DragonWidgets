<div align="center">

# Dragon Widgets

*A shared event-driven widget library for Dragon\* addon options panels.*

[![Latest Release](https://img.shields.io/github/v/release/Xerrion/DragonWidgets?style=for-the-badge)](https://github.com/Xerrion/DragonWidgets/releases/latest)
[![License](https://img.shields.io/github/license/Xerrion/DragonWidgets?style=for-the-badge)](LICENSE)
[![WoW Versions](https://img.shields.io/badge/WoW-Retail%20%7C%20MoP%20Classic%20%7C%20Cata%20Classic%20%7C%20TBC%20Anniversary-blue?style=for-the-badge&logo=battledotnet)](https://worldofwarcraft.blizzard.com/)
[![Lint](https://img.shields.io/github/actions/workflow/status/Xerrion/DragonWidgets/lint.yml?style=for-the-badge&label=luacheck)](https://github.com/Xerrion/DragonWidgets/actions)

</div>

DragonWidgets is a pure widget library providing reusable UI components for the Dragon\* family of WoW addons. It is embedded as a git submodule into each consumer addon's `_Options` LoadOnDemand companion.

## 🧩 Widgets

| Widget | Description |
|:-------|:------------|
| Panel | BackdropTemplate container frame with title bar and close button |
| ScrollFrame | ScrollFrame with child and scrollbar slider for scrollable content areas |
| TabGroup | Horizontal tab bar with lazy content creation and scroll frames |
| Header | Sub-header with gold text and subtle horizontal separator |
| Description | Word-wrapped gray description text block |
| Section | Card panel container that groups related settings with a header |
| Toggle | Checkbox toggle with label and optional tooltip |
| Slider | Horizontal slider with label, min/max labels, and editable value display |
| Dropdown | Custom dropdown selector with scrollable list (no UIDropDownMenu) |
| ColorPicker | Color swatch that opens the WoW ColorPickerFrame (Retail + Classic) |
| TextInput | Single-line text input with label and bordered edit box |
| Button | Styled action button with tooltip support |
| ItemSlot | Drag-and-drop item slot with quality border and tooltip |
| ItemList | Grid of ItemSlot widgets with drag-and-drop add and right-click remove |

### Supporting Modules

| Module | Description |
|:-------|:------------|
| WidgetConstants | Shared colors, fonts, textures, and helpers used by all widgets |
| LayoutConstants | Spacing constants and helpers used by consumer `_Options` tab files |

## 🎮 Supported Versions

| Version         | Interface              |
|:----------------|:-----------------------|
| Retail          | 110207, 120001, 120000 |
| MoP Classic     | 50503                  |
| Cataclysm Classic | 40402                |
| TBC Anniversary | 20505                  |

## 📦 Embedding

DragonWidgets is not a standalone addon - it is embedded into consumer `_Options` addons as a git submodule.

### 1. Add as a git submodule

```bash
git submodule add https://github.com/Xerrion/DragonWidgets <AddonName>_Options/Libs/DragonWidgets
```

### 2. Add a `.pkgmeta` external

```yaml
externals:
  <AddonName>_Options/Libs/DragonWidgets:
    url: https://github.com/Xerrion/DragonWidgets
```

### 3. List all widget files in your `_Options.toc`

DragonWidgets has no XML manifest. Every `.lua` file must be listed explicitly:

```toc
Libs\DragonWidgets\DragonWidgets\DragonWidgets.lua
Libs\DragonWidgets\DragonWidgets\LayoutConstants.lua
Libs\DragonWidgets\DragonWidgets\Widgets\WidgetConstants.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Panel.lua
Libs\DragonWidgets\DragonWidgets\Widgets\ScrollFrame.lua
Libs\DragonWidgets\DragonWidgets\Widgets\TabGroup.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Header.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Description.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Section.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Toggle.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Slider.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Dropdown.lua
Libs\DragonWidgets\DragonWidgets\Widgets\ColorPicker.lua
Libs\DragonWidgets\DragonWidgets\Widgets\TextInput.lua
Libs\DragonWidgets\DragonWidgets\Widgets\Button.lua
Libs\DragonWidgets\DragonWidgets\Widgets\ItemSlot.lua
Libs\DragonWidgets\DragonWidgets\Widgets\ItemList.lua
```

### 4. Update `.luacheckrc`

Add `DragonWidgetsNS` to `read_globals` so luacheck recognizes the library global:

```lua
read_globals = {
    "DragonWidgetsNS",
}
```

### 5. Access the namespace

```lua
local ns = DragonWidgetsNS
local WC = ns.WidgetConstants
```

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/Xerrion/DragonWidgets). Run `luacheck .` before submitting to ensure all linting passes.

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](https://github.com/Xerrion/DragonWidgets/blob/master/LICENSE) file for details.

Made with ❤️ by [Xerrion](https://github.com/Xerrion)
