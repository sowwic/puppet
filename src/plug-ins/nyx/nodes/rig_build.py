import typing

from nyx.api.v1 import CoreNodeComponents, CoreDatatypes
from nyx.api.v1.std_nodes import RemoteActionNode


class PuppetRigBuildNode(RemoteActionNode):
    DEFAULT_NAME = "puppet_rig_build"
    DEFAULT_TIMEOUT = 30.0

    @classmethod
    def get_type_id(cls) -> str:
        """str: node type id."""
        return "puppet:rig_build"

    @classmethod
    def get_type_display_name(cls) -> str:
        """str: name shown in the UI."""
        return "Puppet Rig"

    @classmethod
    def get_type_icon(cls) -> str:
        """str: resource path of the type icon."""
        return ":/puppet_maya/icons/tpose"

    @classmethod
    def get_description(cls) -> str:
        """str: what the node type does, shown in the palette."""
        return "Starts new puppet rig build."

    @classmethod
    def get_tags(cls) -> set[str]:
        """set[str]: node tags."""
        return {"bridge", "puppet", "maya"}

    def build_args(self) -> dict[str, typing.Any]:
        """Get the variables the code sees. Override in subclasses.

        Returns:
            dict[str, Any]: JSON serializable values by name.
        """
        args = super().build_args()
        args["rig_type"] = self.rig_type_cpnt.pull_value()
        args["rig_name"] = self.rig_name_cpnt.pull_value()
        return args

    def setup(self) -> None:
        """Add the flow, the script, its arguments and the response."""
        super().setup()
        self.script_cpnt.writable = False
        self.script_cpnt.is_editable = True
        self.script_cpnt.push_value("puppet.api.v1:build_rig")

        # Rig Type
        self.rig_type_cpnt = self.components_model.create_component(
            CoreNodeComponents.VALUE
        )
        self.rig_type_cpnt.name = "rig_type"
        self.rig_type_cpnt.description = "Rig Type"
        self.rig_type_cpnt.is_editable = True
        self.rig_type_cpnt.writable = True
        self.rig_type_cpnt.readable = True
        self.rig_type_cpnt.set_datatype(CoreDatatypes.STRING)

        self.rig_name_cpnt = self.components_model.create_component(
            CoreNodeComponents.VALUE
        )

        # Rig name
        self.rig_name_cpnt.name = "rig_name"
        self.rig_name_cpnt.description = "Rig Name"
        self.rig_name_cpnt.is_editable = True
        self.rig_name_cpnt.writable = True
        self.rig_name_cpnt.readable = True
        self.rig_name_cpnt.set_datatype(CoreDatatypes.STRING)

        self.components_model.add_component(self.rig_type_cpnt, at_row=2)
        self.components_model.add_component(self.rig_name_cpnt, at_row=3)
