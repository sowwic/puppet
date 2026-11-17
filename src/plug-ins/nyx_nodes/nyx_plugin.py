import typing
import logging

from .resources import resources_rc  # noqa: F401
from nyx.api.v1 import NyxPluginManager, NyxPlugin


LOGGER = logging.getLogger(__name__)


@NyxPluginManager.register_plugin()
class PuppetNyxPlugin(NyxPlugin):
    """Built-in plugin providing the core nodes and node components."""

    QML_MODULE_NAME = "PuppetMaya"

    @classmethod
    def get_type_id(cls) -> str:
        """str: plugin id."""
        return "PuppetMaya"

    @classmethod
    def get_palette_name(cls) -> str:
        """str: name of the palette section."""
        return "Puppet (Maya)"

    @classmethod
    def initialize(cls) -> typing.Self:
        """Create the plugin and list its nodes and components.

        Returns:
            typing.Self: initialized plugin.
        """
        plugin = cls()
        plugin.contents.node_components = []
        plugin.contents.nodes = []
        plugin.contents.util_objects = []
        plugin.contents.graphics_objects = []

        return plugin
