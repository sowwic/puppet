from puppet.version import __version__


def test_version():
    assert __version__ == "0.0.1"
    import maya.cmds

    maya.cmds.polySphere()
