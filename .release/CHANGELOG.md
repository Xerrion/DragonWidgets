# Changelog

## 0.4.1 (2026-11-18)

<!-- Release notes generated using configuration in .github/release.yml at master -->

## What's Changed
### ⚙️ Other Changes
* ci: register DragonWidgets package workflow by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/18
* ci: run lint on pull_request instead of pull_request_target by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/19
* docs: drop AI disclosure requirement by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/20
* chore: use GitHub-generated release notes to credit contributors by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/21
* ci: add PR labeler and unify release note categories by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/23
* ci: use pull_request triggers and update action versions by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/24
* ci: run the PR labeler on pull_request_target for fork PRs by @Xerrion in https://github.com/Xerrion/DragonWidgets/pull/25


**Full Changelog**: https://github.com/Xerrion/DragonWidgets/compare/0.4.0...0.4.1

## [0.4.0](https://github.com/Xerrion/DragonWidgets/compare/0.3.0...0.4.0) (2026-11-17)


### Features

* standardize Dragon addon options defaults ([#16](https://github.com/Xerrion/DragonWidgets/issues/16)) ([3538362](https://github.com/Xerrion/DragonWidgets/commit/35383621b43806f4b5231be2e41c2f979933fba1))

## [0.3.0](https://github.com/Xerrion/DragonWidgets/compare/0.2.0...0.3.0) (2026-11-17)


### Features

* add sidebar settings layout and pinned preview hosts ([#13](https://github.com/Xerrion/DragonWidgets/issues/13)) ([fc3b240](https://github.com/Xerrion/DragonWidgets/commit/fc3b240d02b5fd23d9aad3f50ba7a350a8e21dcb))


### Bug Fixes

* honor declared options page order ([#15](https://github.com/Xerrion/DragonWidgets/issues/15)) ([2387e87](https://github.com/Xerrion/DragonWidgets/commit/2387e87717049fa0808b82967aae044b553bbb97))

## [0.2.0](https://github.com/Xerrion/DragonWidgets/compare/0.1.0...0.2.0) (2026-11-17)


### Features

* add busted test infrastructure with EventBus and Toggle tests ([#4](https://github.com/Xerrion/DragonWidgets/issues/4)) ([#7](https://github.com/Xerrion/DragonWidgets/issues/7)) ([228597e](https://github.com/Xerrion/DragonWidgets/commit/228597e9a060943f3e3ecfcba80940a3e1f6ecf6))
* initial DragonWidgets shared widget library ([607159d](https://github.com/Xerrion/DragonWidgets/commit/607159d82ee628d005af542220212b4cce0af716))
* modernize widget appearance and interaction states ([#12](https://github.com/Xerrion/DragonWidgets/issues/12)) ([2767f8c](https://github.com/Xerrion/DragonWidgets/commit/2767f8c075bb6486ec43efee7cb20a3b522f0663))


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
