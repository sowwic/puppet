import logging
from maya.OpenMayaMPx import MFnPlugin
from maya import cmds

from puppet.core.logger import PuppetLogger

logging.setLoggerClass(PuppetLogger)
LOGGER = logging.getLogger(__name__)


def initializePlugin(mobject):
    vendor = "Dmitrii Shevchenko"
    version = cmds.moduleInfo(moduleName="puppet", version=True)

    # Init core
    try:
        MFnPlugin(mobject, vendor, version)
    except Exception:
        LOGGER.exception("Failed to initialize puppet plugin")
        raise


def uninitializePlugin(mobject):
    try:
        MFnPlugin(mobject)

    except Exception:
        LOGGER.exception("Failed to fully uninitialize puppet plugin")
        raise
