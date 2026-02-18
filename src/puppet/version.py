from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("puppet")
except PackageNotFoundError:
    __version__ = "0.0.0"
