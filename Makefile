# Common targets come from sowwic/makefiles, fetched into .make/ (commit it). `make update-make` fetches them again.
APP_NAME = puppet
PACKAGE_NAME = puppet
RELEASE_BRANCH ?= main
DEVELOP_BRANCH ?= develop
PYTEST_CMD = ./mayapy_test.sh
PYTEST_PDB_CMD = ./mayapy_test.sh --pdb
BUILD_PREREQS = qrc

MAKEFILES_REF ?= v1
MAKEFILES_URL ?= https://raw.githubusercontent.com/sowwic/makefiles/$(MAKEFILES_REF)
MAKEFILES_MODULES = general/python general/repo dcc/maya general/qt

.make/%.mk:
	@mkdir -p $(dir $@)
	@curl -fsSL $(MAKEFILES_URL)/$*.mk -o $@
include $(MAKEFILES_MODULES:%=.make/%.mk)

NYX_RESOURCES_DIR = src/plug-ins/nyx/resources

.PHONY: qrc-nyx
qrc-nyx: ## Generate Python resources of the Nyx node plugin
	$(call banner, Generating Nyx plugin QRC resources...)
	@uv run pyside6-rcc $(NYX_RESOURCES_DIR)/resources.qrc -o $(NYX_RESOURCES_DIR)/resources_rc.py

qrc: qrc-nyx
