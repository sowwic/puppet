import logging
from importlib.metadata import version, PackageNotFoundError

LOGGER = logging.getLogger(__name__)

try:
    __version__ = version("puppet")
except PackageNotFoundError:
    LOGGER.error("Could not find package version for 'puppet'. Defaulting to 0.0.0")
    __version__ = "0.0.0"
