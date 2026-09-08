#!/usr/bin/env bash

set -euo pipefail
# -----------------------------
# Configuration
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Load .env if exists (MAYAPY should be defined there)
set -a
[ -f "$SCRIPT_DIR/.env" ] && source "$SCRIPT_DIR/.env"
set +a

if [ -z "${MAYAPY:-}" ]; then
  echo "MAYAPY not set. Define it in .env"
  exit 1
fi

echo "Using mayapy: $MAYAPY"
# -----------------------------
#  Build packages
# -----------------------------
BUILD_DIR="$SCRIPT_DIR/build/maya_pytest"
MODULE_ROOT="$BUILD_DIR/puppet_module"
MODULES_DIR="$BUILD_DIR/modules"
VERSION="$(tr -d '\r\n' <"$SCRIPT_DIR/VERSION")"

rm -rf "$BUILD_DIR"
mkdir -p "$MODULE_ROOT/python" "$MODULE_ROOT/plug-ins" "$MODULES_DIR"

echo "Installing puppet and test dependencies as a Maya module"
uv pip install \
  --python "$MAYAPY" \
  --target "$MODULE_ROOT/python" \
  --group maya-pytest \
  "$SCRIPT_DIR"

[ ! -d "$SCRIPT_DIR/src/plug-ins" ] ||
  cp -R "$SCRIPT_DIR/src/plug-ins/." "$MODULE_ROOT/plug-ins/"

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
' "$SCRIPT_DIR/tests" "$@"
