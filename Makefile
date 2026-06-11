# AV Vault OS - Build Makefile

.PHONY: help build build-local setup clean validate install-deps

help:
	@echo "AV Vault OS Build System"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build              - Build locally (requires Ubuntu/Linux)"
	@echo "  setup              - Set up build environment"
	@echo "  install-deps       - Install build dependencies"
	@echo "  validate           - Validate build configuration"
	@echo "  clean              - Clean build artifacts"
	@echo "  help               - Show this help message"
	@echo ""
	@echo "GitHub Actions builds automatically on push to main"

build: setup
	@echo "Starting AV Vault OS build..."
	@chmod +x build/build-locally.sh
	@./build/build-locally.sh

setup: install-deps validate
	@echo "Build environment ready"

install-deps:
	@echo "Installing build dependencies..."
	@command -v git >/dev/null 2>&1 || { echo "git required"; exit 1; }
	@command -v wget >/dev/null 2>&1 || { echo "wget required"; exit 1; }
	@echo "Core dependencies found"

validate:
	@echo "Validating configuration..."
	@[ -d "branding/rootfs" ] || { echo "branding/rootfs missing"; exit 1; }
	@[ -f "build/config/armbian-config.sh" ] || { echo "build config missing"; exit 1; }
	@echo "Configuration valid"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build dist/*.img.xz
	@echo "Clean complete"

.DEFAULT_GOAL := help
