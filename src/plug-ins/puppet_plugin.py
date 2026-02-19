import logging
from maya.OpenMayaMPx import MFnPlugin

from puppet.core.logger import PuppetLogger
from puppet.version import __version__

logging.setLoggerClass(PuppetLogger)

LOGGER = logging.getLogger(__name__)


def initializePlugin(mobject):
    vendor = "Dmitrii Shevchenko"

    # Init core
    try:
        MFnPlugin(mobject, vendor, __version__)
    except Exception:
        LOGGER.exception("Failed to initialize puppet plugin")
        raise


def uninitializePlugin(mobject):
    try:
        MFnPlugin(mobject)

    except Exception:
        LOGGER.exception("Failed to fully uninitialize puppet plugin")
        raise
