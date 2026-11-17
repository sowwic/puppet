# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Puppet is a component-based rigging system for Maya. It ships as a Maya module (plug-in + Python package) generated from the `sowwic/copier-maya-plugin` template (answers in `.copier-answers.yml`). Pull in template changes with `copier update --trust` on a clean git tree, so keep edits to template-owned files (Makefile, workflows, `mayapy_test.sh`, `pyproject.toml` scaffolding) minimal to avoid conflicts.

## Commands

Everything goes through `make` (`make help` lists targets). Python tooling runs through `uv`.

```sh
make check                 # ruff lint + tests
make lint / lint-fix / format
make pytest                # tests inside mayapy (not plain pytest)
make pytest-pdb
make qrc                   # pyside6-rcc: resources.qrc -> resources_rc.py (also run by `make build`)
make install / uninstall   # build the Maya module and copy/remove puppet.mod in MAYA_MODULE_PATH
make venv                  # recreate .venv with the Python version of mayapy
make dispatch-pytest       # run the tests workflow on the current branch (self-hosted Maya runner)
make release VERSION=x.y.z # see README "Releasing"
```

Single test: `./mayapy_test.sh tests/test_plugin.py::test_initialize_plugin` (extra args go to pytest).

Tests need `MAYAPY` (and `MAYA_MODULE_PATH` for install) from `.env` in the repo root, else `~/.config/maya-ci.env`, or an explicit `MAYA_CI_ENV_FILE=<path>`. A `.env` that exists but has an empty `MAYAPY` takes precedence over the home file and fails.

## Architecture

- **Makefile is thin**: it sets variables and includes shared modules from `sowwic/makefiles`, fetched into `.make/` (committed). Do not edit `.make/*.mk`; change the upstream repo and run `make update-make`. Project-specific targets go below the `include`, or use double-colon rules (`check::`, `clean::`).
- **GitHub workflows are thin callers** of reusable workflows in `sowwic/gh-workflows@v1`. Tests run on a self-hosted macOS runner with Maya 2026.
- **`mayapy_test.sh`** builds a temporary Maya module in `build/maya_pytest/` (installs the package and the `maya-pytest` dependency group into it with `uv pip --target`, copies `src/plug-ins/`, writes a `.mod`), then starts `maya.standalone` and runs pytest. Tests therefore exercise the installed layout, not `src/` directly, and coverage paths point into `build/`.
- **Module layout**: `src/puppet/` is the package, `src/plug-ins/puppet_plugin.py` the plug-in (loaded by name in `tests/test_plugin.py`), `templates/puppet.mod` the module file with `@VERSION@` / `@MODULE_ROOT@` placeholders substituted by `make`.
- **Maya-dependent imports**: `puppet.core.constants` calls `cmds.moduleInfo(moduleName="puppet")` at import time to find the module root (log file location), so `puppet.core.*` can only be imported inside Maya/mayapy with the module on `MAYA_MODULE_PATH`. `puppet.core.logger.PuppetLogger` is installed by the plug-in via `logging.setLoggerClass`.
- **Version** lives in the `VERSION` file (read by `puppet/version.py` and the Makefile).
- **Nyx plugins**: Nyx needs Python 3.14 and runs plugins in its own process (not Maya); it discovers `nyx_plugin.py` files in `plugin_paths` / `NYX_PLUGIN_PATH`. Never import plugin modules from the Maya-side package or tests (mayapy is 3.11). The editor finds `nyx` (`from nyx.api.v1 import ...`) through `PYTHONPATH` in `.env`, exported by direnv (`dotenv` in `.envrc`), since nyx can't be a dependency of this 3.11 project.
- **Qt**: `resources_rc.py` is generated, excluded from ruff, and is a dev-only PySide6 dependency (Maya provides PySide6 at runtime).

## Conventions

- Ruff, line length 89, rules `E`, `F`, `UP`.
- Google-style docstrings (`Args:`, `Returns:`, `Raises:`).
- Prefer flexibility: when a subclass or plugin needs to run code at a point inside a base class's sequence (before or after a step), add an overridable hook (`pre_*` / `post_*`, a no-op in the base class) rather than changing constructor arguments, reordering the subclass `__init__` around `super().__init__`, or copying the base sequence.
- `develop` is the default and PR branch; `main` is the release branch. Dependabot targets `develop`. `VERSION` is the version source (`make update-version` syncs `pyproject.toml`). Record user-visible changes in `CHANGELOG.rst`.
- Before writing a test helper or fixture, check `tests/conftest.py` and reuse what is there.

## Development

- If the current branch is `develop`, ask the user for the GitHub issue number before starting work. Use related branch
- Do not commit unless asked to.
- Do not update CHANGELOG unless asked to
- Do not push extra created worktrees to remote. Once work in them is done - patch it back into feature branch and delete extra worktree created.
- When a task done in a worktree is finished, do this without being asked: exit the worktree (`ExitWorktree` keep), cherry-pick its commit(s) onto the feature branch in the main checkout, then remove the worktree and its branch. Git can't reach the main checkout from inside the worktree session.

## Qt Notes

### QWidgets

New QWidgets should follow the following architecture unless it causes issues.

Methods:

- `_create_actions` - creates actions and configures them
- `_create_widgets` - creates child widgets and configures them
- `_create_layouts` - creates layouts, populates them with widgets
- `_create_connections` - creates signal-slot connections
- Above methods are run in `__init__`

## Verifying UI work cheaply

- Check state, not pixels, by default: over MCP `execute_python`, read attributes (`ops.getAttr`), widget state (find widgets by class and read text, checked state, enabled, items) and command results. Assert the numbers.
- Take a screenshot (`captureView`, or a widget grab) only where the visual result is the point: viewport drawing, layout, styling, icons. One capture at the end of a check, not one per step.

## Token hygiene

- Find symbols with the LSP tool if possible before grepping; then Read with offset/limit.
