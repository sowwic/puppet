# Modified from https://github.com/nxt-dev/nxt_editor/blob/release/nxt_editor/integration/maya/drag_into_maya.py

import os
from maya import cmds
import pathlib

MODULE_FILE_NAME = "puppet.mod"
ROOT_DIR = pathlib.Path(__file__).parent.absolute()
SRC_DIR = ROOT_DIR / "src"
VERSION_FILE = ROOT_DIR / "VERSION"
TEMPLATE_MODULE_FILE = ROOT_DIR / "resources" / MODULE_FILE_NAME


def get_version() -> str:
    """Get version string from VERSION file.

    Returns:
        str: Version string.
    """
    version = "0.0.0"
    try:
        with VERSION_FILE.open() as version_file:
            version = version_file.read().strip()
    except FileNotFoundError:
        cmds.warning(f"VERSION file not found at {VERSION_FILE}")
    return version


def onMayaDroppedPythonFile(*args):
    """Maya callback for when a python file is dropped into the viewport.
    This will create a puppet.mod file in the maya modules directory
    with the correct paths to the puppet plugin and resources."""
    module_content = TEMPLATE_MODULE_FILE.read_text()

    # Fill in template file
    module_content = module_content.replace("<ROOT_PATH>", str(ROOT_DIR))
    module_content = module_content.replace("<SRC_PATH>", str(SRC_DIR))
    module_content = module_content.replace("<VERSION>", get_version())

    # Try to find modules directory
    module_paths = os.getenv("MAYA_MODULE_PATH")
    prime_module_path = pathlib.Path(module_paths.rsplit(":")[0])
    prime_module_path.mkdir(parents=True, exist_ok=True)

    # Confirm modules directory
    caption = "Select maya modules directory"
    result = cmds.fileDialog2(
        caption=caption, startingDirectory=prime_module_path.as_posix(), fileMode=2
    )
    if not result[0]:
        cmds.warning("No directory selected, aborting puppet installation.")
        return

    destination_dir = pathlib.Path(result[0])
    destination_mod_path = destination_dir / MODULE_FILE_NAME
    destination_mod_path.write_text(module_content)
    cmds.warning(f"Placed puppet mod file at {destination_mod_path}")
    cmds.warning("Please restart Maya and enable puppet_plugin.py from plugin manager.")
