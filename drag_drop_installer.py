# Modified from https://github.com/nxt-dev/nxt_editor/blob/release/nxt_editor/integration/maya/drag_into_maya.py

import os
import pathlib
import tomllib

from maya import cmds


ROOT_DIR = pathlib.Path(__file__).parent.absolute()
SRC_DIR = ROOT_DIR / "src"
PYPROJECT_PATH = ROOT_DIR / "pyproject.toml"
MODULE_FILE_NAME = "puppet.mod"
PLUGINS_DIR = SRC_DIR / "plug-ins"
VERSION_FILE = ROOT_DIR / "VERSION"
TEMPLATE_MODULE_FILE = ROOT_DIR / "resources" / MODULE_FILE_NAME


def get_version() -> str:
    """Get version string from VERSION file.

    Returns:
        str: Version string.
    """
    with PYPROJECT_PATH.open("rb") as toml_file:
        data = tomllib.load(toml_file)

    version = "0.0.0"
    try:
        version: str = data["project"]["version"]
    except KeyError:
        cmds.warning("Could not find [project].version in pyproject.toml")
    return version


def onMayaDroppedPythonFile(*args):
    """Maya callback for when a python file is dropped into the viewport.
    This will create a puppet.mod file in the maya modules directory
    with the correct paths to the puppet plugin and resources."""
    module_content = TEMPLATE_MODULE_FILE.read_text()

    # Fill in template file
    module_content = module_content.replace("<VERSION>", get_version())
    module_content = module_content.replace("<ROOT_PATH>", str(ROOT_DIR))
    module_content = module_content.replace("<SRC_PATH>", str(SRC_DIR))
    module_content = module_content.replace("<PLUGINS_PATH>", str(PLUGINS_DIR))

    # Try to find modules directory
    user_maya_dir = os.environ.get("MAYA_APP_DIR")
    user_mods_dir = os.path.join(user_maya_dir, "modules")

    # Confirm modules directory
    caption = "Select maya modules directory"
    result = cmds.fileDialog2(
        caption=caption, startingDirectory=user_mods_dir, fileMode=2
    )
    if not result[0]:
        cmds.warning("No directory selected, aborting puppet installation.")
        return

    destination_dir = pathlib.Path(result[0])
    destination_mod_path = destination_dir / MODULE_FILE_NAME
    destination_mod_path.write_text(module_content)
    cmds.warning(f"Placed puppet mod file at {destination_mod_path}")
    cmds.warning("Please restart Maya and enable puppet_plugin.py from plugin manager.")
