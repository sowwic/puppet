import pathlib
from maya import cmds

PUPPET_MODULE_PATH = pathlib.Path(cmds.moduleInfo(path=True, moduleName="puppet"))  # ty: ignore
LOG_FILE_PATH = PUPPET_MODULE_PATH / "puppet.log"
PLUGIN_NAME = "puppet_plugin"
