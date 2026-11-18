# Contributing to DragonWidgets

Contributions are welcome. Open an issue or pull request on [GitHub](https://github.com/Xerrion/DragonWidgets). Agent-specific guidelines live in [AGENTS.md](AGENTS.md).

---

## Setup

DragonWidgets is a Lua 5.1 library with no submodules of its own. It is embedded as a git submodule into consumer `_Options` addons (see the [README](README.md)).

The repo's `.mise.toml` pins Lua 5.1 and defines the common tasks:

```bash
luacheck .          # lint (also: mise run lint)
busted --verbose    # tests (also: mise run test)
```

---

## Workflow

- Open or pick an issue first, and link it from your PR.
- Name branches `type/<issue>-short-desc`, for example `fix/12-slider-label`.
- PR titles must be conventional commits (`feat:`, `fix(scope):`, `chore:` ...) and reference the issue number. Squash merges use the PR title as the commit message, and release-please derives versions from it.
- Run `luacheck .` and `busted --verbose` before submitting, and test in-game.

---

## AI-Assisted Contributions

AI tools are fine to use. These rules apply when you do:

1. **Review everything.** You must review, understand, and be able to explain every line you submit. Do not submit unreviewed agent output.
2. **Run the checks.** Run `luacheck .` and `busted --verbose`, and test in-game. Never claim a check passed without running it.
3. **Do not invent WoW API behaviour.** Verify against [warcraft.wiki.gg](https://warcraft.wiki.gg) and Blizzard's FrameXML source.
4. **No spam.** Do not file bulk or drive-by AI-generated issues or PRs. Keep each PR to one scoped change, linked to an issue.
5. **You own the licensing.** Do not paste code of unknown origin.
6. **Agents follow [AGENTS.md](AGENTS.md).** They never push to `master`, never merge release-please PRs (`chore(master): release X.Y.Z`; the owner merges those), and do not touch secrets or workflow permissions without explicit approval.

Maintainers may close unreviewed AI-assisted PRs without review.
