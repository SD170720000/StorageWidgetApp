#!/usr/bin/env bash
# Personalises the project with your own Apple Developer Team ID and bundle prefix.
# Run once after cloning: bash scripts/setup.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo ""
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}${BOLD}   StorageWidgetApp — First-Time Setup   ${NC}"
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You need a free Apple Developer account to build and sign the app."
echo "  • Sign in at: https://developer.apple.com"
echo "  • Find your Team ID at: https://developer.apple.com/account → Membership Details"
echo ""

# ── Inputs ────────────────────────────────────────────────────────────────────
read -rp "  Team ID        (e.g. ABC1234XYZ) : " TEAM_ID
read -rp "  Bundle prefix  (e.g. com.yourname): " BUNDLE_PREFIX
echo ""

[[ -z "${TEAM_ID}"       ]] && echo -e "${RED}Error: Team ID is required.${NC}"       && exit 1
[[ -z "${BUNDLE_PREFIX}" ]] && echo -e "${RED}Error: Bundle prefix is required.${NC}" && exit 1

# ── Originals ─────────────────────────────────────────────────────────────────
ORIG_TEAM="NQZ8B39KX3"
ORIG_PREFIX="com.subhudas"
ORIG_GROUP="group.com.subhudas.StorageWidget"
NEW_GROUP="group.${BUNDLE_PREFIX}.StorageWidget"

replace_in_file() {
    local from="$1" to="$2" file="$3"
    python3 -c "
import sys
orig, new, path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f: content = f.read()
with open(path, 'w') as f: f.write(content.replace(orig, new))
" "$from" "$to" "$file"
}

echo -e "${YELLOW}Applying changes…${NC}"

# project.pbxproj
replace_in_file "$ORIG_TEAM"   "$TEAM_ID"       "StorageWidgetApp.xcodeproj/project.pbxproj"
replace_in_file "$ORIG_PREFIX" "$BUNDLE_PREFIX" "StorageWidgetApp.xcodeproj/project.pbxproj"
echo -e "  ${GREEN}✓${NC} project.pbxproj"

# Entitlements
while IFS= read -r -d '' file; do
    replace_in_file "$ORIG_GROUP" "$NEW_GROUP" "$file"
    echo -e "  ${GREEN}✓${NC} $file"
done < <(find . -name "*.entitlements" -not -path "*/DerivedData/*" -print0)

# AppConstants.swift
replace_in_file "$ORIG_GROUP" "$NEW_GROUP" \
    "StorageWidgetApp/Utilities/AppConstants.swift" 2>/dev/null || \
replace_in_file "$ORIG_GROUP" "$NEW_GROUP" \
    "StorageWidgetApp/StorageWidgetApp/Utilities/AppConstants.swift"
echo -e "  ${GREEN}✓${NC} AppConstants.swift"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}Setup complete!${NC}"
echo ""
echo -e "  Team ID      → ${BOLD}${TEAM_ID}${NC}"
echo -e "  Bundle prefix → ${BOLD}${BUNDLE_PREFIX}${NC}"
echo -e "  App group    → ${BOLD}${NEW_GROUP}${NC}"
echo ""
echo -e "${YELLOW}${BOLD}Important:${NC} These changes are LOCAL only."
echo "  • Do NOT commit them — they contain your personal Team ID."
echo "  • To undo: ${BLUE}git restore .${NC}"
echo ""
echo "Next steps:"
echo "  1. Open StorageWidgetApp.xcodeproj in Xcode"
echo "  2. Xcode → Product → Run  (⌘R)"
echo "  3. Add the widget: right-click desktop → Edit Widgets → search "Storage""
echo ""
