# Puppet

![Tests](https://github.com/sowwic/puppet/actions/workflows/unit_tests.yml/badge.svg)
![Code Quality](https://github.com/sowwic/puppet/actions/workflows/code_quality.yml/badge.svg)

Description

## Development

```sh
uv sync            # install the project and dev dependencies
make check         # lint + tests
make help          # list all targets
```

### Maya

Tests run inside `mayapy` (`./mayapy_test.sh`, used by `make pytest`). Create a `.env` file
(git-ignored) in the project root, or `~/.config/maya-ci.env`:

```sh
MAYAPY=/Applications/Autodesk/maya2026/Maya.app/Contents/bin/mayapy
MAYA_MODULE_PATH=~/Library/Preferences/Autodesk/maya/modules
```

Set `python_version` to the Python version bundled with your Maya (`make venv` recreates
`.venv` with it). CI runs on a self-hosted runner; trigger it with `make dispatch-pytest`.
`make install` builds and installs the Maya module.

### Qt resources

`make qrc` compiles `src/puppet/resources/resources.qrc` into `resources_rc.py` (`make build` and
`make install` do it first). Import it once before using the resources, e.g.
`import puppet.resources.resources_rc`. Maya provides PySide6, which is only a
development dependency here.

## Releasing

1. Add a `v<version>` entry to `CHANGELOG.rst`, update `VERSION` (`make update-version`) and commit on `main`.
2. `make release VERSION=<version>` tags, pushes (triggering the GitHub release workflow) and back-merges into `develop`.
