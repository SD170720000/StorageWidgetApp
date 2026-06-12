SCHEME  := StorageWidgetApp
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "dev")

.DEFAULT_GOAL := help

# ── Targets ───────────────────────────────────────────────────────────────────

.PHONY: help setup build dmg clean

help:
	@echo ""
	@echo "  StorageWidgetApp — available commands"
	@echo ""
	@echo "  make setup    Personalise the project with your Team ID & bundle prefix"
	@echo "  make build    Debug build (fast iteration)"
	@echo "  make dmg      Release build → creates dist/StorageWidgetApp-<version>.dmg"
	@echo "  make clean    Clean Xcode build artefacts"
	@echo ""

setup:
	@bash scripts/setup.sh

build:
	xcodebuild clean build -scheme $(SCHEME) -configuration Debug

dmg:
	@mkdir -p dist
	@bash scripts/make_dmg.sh $(VERSION)

clean:
	xcodebuild clean -scheme $(SCHEME) -configuration Debug
	xcodebuild clean -scheme $(SCHEME) -configuration Release
	rm -rf dist/
