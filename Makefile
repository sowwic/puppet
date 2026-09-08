SHELL := /bin/bash

PACKAGE_NAME = puppet
VERSION := $(shell tr -d '\r\n' < "VERSION")

ROOT_DIR := $(CURDIR)
BUILD_DIR = build
TEST_OUTPUT_DIR = .test_output

# Dist Variables
DIST_DIR = $(ROOT_DIR)/dist
DIST_MAYA_MODULE_DIR = $(DIST_DIR)/puppet_module
DIST_PYTHON_DIR = $(DIST_MAYA_MODULE_DIR)/python
DIST_PLUGINS_DIR = $(DIST_MAYA_MODULE_DIR)/plug-ins
DIST_MODULE_ROOT := $(DIST_DIR)/puppet_module
DIST_MODULE_FILE := $(DIST_DIR)/puppet.mod

SOURCE_DIR = $(ROOT_DIR)/src
SOURCE_PLUGINS_DIR = $(SOURCE_DIR)/plug-ins
SOURCES_RESOURCES_DIR = $(SOURCE_DIR)/$(PACKAGE_NAME)/resources
SOURCE_RESOURCES_QRC = $(SOURCES_RESOURCES_DIR)/resources.qrc
SOURCE_RESOURCES_PY = $(SOURCES_RESOURCES_DIR)/resources_rc.py


# Colors
BLUE := \033[34m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
MAGENTA := \033[35m
CYAN := \033[36m
RESET := \033[0m

# Banner helper
define banner
	@printf "$(CYAN)==>$(RESET) $(1)\n"
endef

.PHONY: help clean lint format pytest pytest-pdb mkdocs check build qrc

help:
	@echo "Available make targets:"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS=":.*?##"}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""

clean: ## Remove build artifacts, cache, and temporary files
	$(call banner, Cleaning project...)
	@rm -rf .pytest_cache
	@rm -rf .ruff_cache
	@rm -rf __pycache__
	@rm -rf .coverage
	@rm -rf src/**/__pycache__
	@rm -rf tests/**/__pycache__
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)
	@rm -rf $(TEST_OUTPUT_DIR)
	@printf "$(GREEN)Clean up complete.$(RESET)\n"

lint: ## Run Ruff linter on source and tests
	$(call banner, Running Ruff linter...)
	@uv run ruff check src tests || true

lint-fix: ## Run Ruff linter and fix fixable issues
		$(call banner, Running Ruff linter with fixes)
	@uv run ruff check --fix src tests || true

format: ## Format source and tests with Ruff
	$(call banner, Running Ruff formatter...)
	@uv run ruff format src tests

pytest: ## Run tests using mayapy_test
	$(call banner, Running pytest...)
	@uv run ./mayapy_test.sh tests

pytest-pdb: ## Run tests with pdb and clean output
	$(call banner, Cleaning pytest output dir...)
	@rm -rf $(TEST_OUTPUT_DIR)
	$(call banner, Running pytest with pdb...)
	@uv run ./mayapy_test.sh --pdb tests

mkdocs: ## Start MkDocs documentation server
	$(call banner, Building MkDocs documentation...)
	@uv run mkdocs serve

check: lint pytest ## Run lint and tests

build: qrc ## Build project package
	$(call banner, Building $(PACKAGE_NAME)...)
	@uv build

qrc: ## Generate QRC resources
	$(call banner, Generating QRC resources...)
	@pyside6-rcc $(SOURCE_RESOURCES_QRC) -o $(SOURCE_RESOURCES_PY)
	@printf "$(GREEN)QRC generation complete.$(RESET)\n"

.PHONY: venv
venv:  ## Recreate .venv using the Maya Python version
	@set -a; . ./.env; set +a; \
	: "$${MAYAPY:?Set MAYAPY in .env}"; \
	version="$$( "$$MAYAPY" -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' )"; \
	printf '%s\n' "$$version" > .python-version; \
	unset VIRTUAL_ENV; \
	uv venv --clear

.PHONY: venv-shell
dev: venv  ## Create venv and enter it
	@. .venv/bin/activate && exec $$SHELL

.PHONY: build
dist: build  ## Generate dist/maya_module/puppet.mod
	@rm -rf $(DIST_MAYA_MODULE_DIR)
	@mkdir -p $(DIST_PYTHON_DIR) $(DIST_PLUGINS_DIR)
	@uv pip install --target $(DIST_PYTHON_DIR) dist/puppet-*.whl
	@cp -R $(SOURCE_PLUGINS_DIR) $(DIST_PLUGINS_DIR)

MODULE_TEMPLATE := templates/puppet.mod

.PHONY: maya-module-file
maya-module-file: ## Generate dist/puppet.mod
	@mkdir -p "$(DIST_DIR)"
	@sed \
		-e 's|@VERSION@|$(VERSION)|g' \
		-e 's|@MODULE_ROOT@|$(DIST_MODULE_ROOT)|g' \
		"$(MODULE_TEMPLATE)" > "$(DIST_MODULE_FILE)"

.PHONY: install-module
install-module:  maya-module-file  ## Copy puppet.mod to Maya's module directory
	@set -eu; \
	set -a; . ./.env; set +a; \
	: "$${MAYA_MODULE_PATH:?Set MAYA_MODULE_PATH in .env}"; \
	module_path="$${MAYA_MODULE_PATH%%:*}"; \
	mkdir -p "$$module_path"; \
	cp "$(DIST_MODULE_FILE)" "$$module_path/puppet.mod"; \
	printf 'Installed puppet.mod in %s\n' "$$module_path"

.PHONY: install
install: dist install-module  ## Build and install puppet module

.PHONY: uninstall
uninstall: ## Remove puppet.mod from Maya's module directory
	@set -eu; \
	set -a; . ./.env; set +a; \
	: "$${MAYA_MODULE_PATH:?Set MAYA_MODULE_PATH in .env}"; \
	module_path="$${MAYA_MODULE_PATH%%:*}"; \
	rm -f "$$module_path/puppet.mod"; \
	printf 'Removed puppet.mod from %s\n' "$$module_path"  ## Build package and install maya module
