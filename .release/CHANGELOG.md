# Changelog

## [0.2.0](https://github.com/Xerrion/DragonWidgets/compare/0.1.0...0.2.0) (2026-04-17)


### Features

* add busted test infrastructure with EventBus and Toggle tests ([#4](https://github.com/Xerrion/DragonWidgets/issues/4)) ([#7](https://github.com/Xerrion/DragonWidgets/issues/7)) ([228597e](https://github.com/Xerrion/DragonWidgets/commit/228597e9a060943f3e3ecfcba80940a3e1f6ecf6))
* initial DragonWidgets shared widget library ([607159d](https://github.com/Xerrion/DragonWidgets/commit/607159d82ee628d005af542220212b4cce0af716))


### Bug Fixes

* remove LoadOnDemand directive from DragonWidgets.toc ([#1](https://github.com/Xerrion/DragonWidgets/issues/1)) ([bb3c9aa](https://github.com/Xerrion/DragonWidgets/commit/bb3c9aa21a71afcf34c7c8c22610b45c65fba927))
* toggle checkbox box area not clickable ([#2](https://github.com/Xerrion/DragonWidgets/issues/2)) ([#6](https://github.com/Xerrion/DragonWidgets/issues/6)) ([a3bc2cf](https://github.com/Xerrion/DragonWidgets/commit/a3bc2cff8acfa00b43e2617ea5fedd870585958b))


### Testing

* expand widget test coverage to all testable widgets ([#9](https://github.com/Xerrion/DragonWidgets/issues/9)) ([#10](https://github.com/Xerrion/DragonWidgets/issues/10)) ([2356895](https://github.com/Xerrion/DragonWidgets/commit/2356895ded5457f12a6279f68da8610e4ef96d15))

## 0.1.0 (Initial release)

- Initial extraction of shared widget library from DragonLoot_Options and DragonToast_Options
- Event-driven architecture with `On`/`Fire` event bus
- `CreateOptionsPanel` factory
- Full widget set: Panel, ScrollFrame, TabGroup, Header, Description, Section, Toggle, Slider, Dropdown, ColorPicker, TextInput, Button, ItemSlot, ItemList
