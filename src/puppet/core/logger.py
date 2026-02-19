import logging
import sys

from .constants import LOG_FILE_PATH


class PuppetLogger(logging.Logger):
    """Logger for nyx application."""

    FILE_LEVEL = logging.WARNING
    STD_OUT_FORMAT = "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
    FILE_FORMAT = "%(asctime)s [%(levelname)s] %(message)s"
    STD_HANDLER = True
    FILE_HANDLER = True

    def __init__(self, name, level=logging.INFO):
        """Initialize the HazbinLogger instance.

        Args:
            name (str): Name of the logger.
            level (int, optional): Logging level. Defaults to logging.INFO.
        """
        super().__init__(name, level)
        self.init_handlers()

    def init_handlers(self):
        """Initialize logging handlers."""
        if self.hasHandlers():
            return

        if self.STD_HANDLER:
            stream_handler = logging.StreamHandler(sys.stdout)
            stream_handler.setFormatter(logging.Formatter(self.STD_OUT_FORMAT))
            self.addHandler(stream_handler)

        if self.FILE_HANDLER:
            file_handler = logging.FileHandler(str(LOG_FILE_PATH))
            file_handler.setLevel(self.FILE_LEVEL)
            file_handler.setFormatter(logging.Formatter(self.FILE_FORMAT))
            self.addHandler(file_handler)
