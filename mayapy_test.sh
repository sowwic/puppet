#!/usr/bin/env bash

set -euo pipefail
# -----------------------------
# Configuration
# -----------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${MAYA_CI_ENV_FILE:-$ROOT_DIR/.env}"

if [[ -n "${MAYA_CI_ENV_FILE:-}" ]]; then
  ENV_FILE="$MAYA_CI_ENV_FILE"
elif [[ -f "$ROOT_DIR/.env" ]]; then
  ENV_FILE="$ROOT_DIR/.env"
else
  ENV_FILE="$HOME/.config/maya-ci.env"
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Maya test configuration was not found."
  echo "Expected one of:"
  echo "  $ROOT_DIR/.env"
  echo "  $HOME/.config/maya-ci.env"
  echo "Or set MAYA_CI_ENV_FILE to an explicit file path."
  exit 1
fi

# Load .env if exists (MAYAPY should be defined there)
set -a
source "$ENV_FILE"
set +a

if [ -z "${MAYAPY:-}" ]; then
  echo "MAYAPY not set. Define it in .env"
  exit 1
fi

echo "Using mayapy: $MAYAPY"
# -----------------------------
#  Build packages
# -----------------------------
BUILD_DIR="$ROOT_DIR/build/maya_pytest"
MODULE_ROOT="$BUILD_DIR/puppet_module"
MODULES_DIR="$BUILD_DIR/modules"
VERSION="$(tr -d '\r\n' <"$ROOT_DIR/VERSION")"

rm -rf "$BUILD_DIR"
mkdir -p "$MODULE_ROOT/python" "$MODULE_ROOT/plug-ins" "$MODULES_DIR"

echo "Installing puppet and test dependencies as a Maya module"
uv pip install \
  --python "$MAYAPY" \
  --target "$MODULE_ROOT/python" \
  --group maya-pytest \
  "$ROOT_DIR"

[ ! -d "$ROOT_DIR/src/plug-ins" ] ||
  cp -R "$ROOT_DIR/src/plug-ins/." "$MODULE_ROOT/plug-ins/"

printf '+ puppet %s %s\nPYTHONPATH *:=python' \
  "$VERSION" "$MODULE_ROOT" >"$MODULES_DIR/puppet.mod"

unset PYTHONPATH
export MAYA_MODULE_PATH="$MODULES_DIR${MAYA_MODULE_PATH:+:$MAYA_MODULE_PATH}"

"$MAYAPY" -c '
import sys
import maya.standalone

maya.standalone.initialize(name="python")
try:
    import maya.cmds
    import pytest
    import os

    puppet_module_path = maya.cmds.moduleInfo(path=True, moduleName="puppet")
    print(f"Running tests for puppet module at: {puppet_module_path})")
    raise SystemExit(pytest.main(["-vvv", *sys.argv[1:]]))
finally:
    maya.standalone.uninitialize()
' "$ROOT_DIR/tests" "$@"
