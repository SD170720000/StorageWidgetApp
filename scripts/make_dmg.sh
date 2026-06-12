#!/usr/bin/env bash
# Builds a Release .app and packages it into a drag-to-install DMG.
# Usage: bash scripts/make_dmg.sh [version]
set -euo pipefail

APP_NAME="StorageWidgetApp"
VERSION="${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "dev")}"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
BUILD_DIR="/tmp/${APP_NAME}-build"
STAGING="/tmp/${APP_NAME}-dmg-staging"
OUTPUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/dist"

echo "▶  Building ${APP_NAME} ${VERSION} (Release)…"

xcodebuild clean build \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=YES \
    CODE_SIGNING_ALLOWED=YES \
    DEVELOPMENT_TEAM="" \
    | xcpretty 2>/dev/null || cat   # fall back to raw output if xcpretty missing

APP_PATH="${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app"

if [[ ! -d "$APP_PATH" ]]; then
    echo "Error: app not found at $APP_PATH" >&2
    exit 1
fi

echo "▶  Staging DMG contents…"
rm -rf "$STAGING"
mkdir -p "$STAGING"
cp -r "$APP_PATH" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

echo "▶  Creating DMG…"
mkdir -p "$OUTPUT_DIR"
rm -f "${OUTPUT_DIR}/${DMG_NAME}"

hdiutil create \
    -volname "${APP_NAME} ${VERSION}" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "${OUTPUT_DIR}/${DMG_NAME}"

rm -rf "$STAGING" "$BUILD_DIR"

echo ""
echo "✓  Done → dist/${DMG_NAME}"
echo ""
echo "To install on another Mac:"
echo "  1. Open ${DMG_NAME}"
echo "  2. Drag StorageWidgetApp.app → Applications"
echo "  3. Run once in Terminal: xattr -cr /Applications/StorageWidgetApp.app"
echo "  4. Open the app"
