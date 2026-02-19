from maya import cmds


def test_initialize_plugin():
    """Test if the plugin can be loaded successfully."""
    from puppet.core.constants import PLUGIN_NAME

    # Load plugin
    cmds.loadPlugin(PLUGIN_NAME)
    # Check if plugin is loaded
    assert cmds.pluginInfo(PLUGIN_NAME, query=True, loaded=True)


def test_uninitialize_plugin():
    """Test if the plugin can be unloaded successfully."""
    from puppet.core.constants import PLUGIN_NAME

    if not cmds.pluginInfo(PLUGIN_NAME, query=True, loaded=True):
        cmds.loadPlugin(PLUGIN_NAME)
    # Unload plugin
    cmds.unloadPlugin(PLUGIN_NAME)
    # Check if plugin is unloaded
    assert not cmds.pluginInfo(PLUGIN_NAME, query=True, loaded=True)
