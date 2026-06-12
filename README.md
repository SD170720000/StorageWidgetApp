# StorageWidgetApp

A macOS desktop widget that shows real-time storage usage for all your mounted drives — internal, external, and USB — right on your desktop.

Built with SwiftUI + WidgetKit. Supports small, medium, and large widget sizes.

---

## Download

**[⬇ Download StorageWidgetApp-v1.0.0.dmg](https://github.com/SD170720000/StorageWidgetApp/releases/download/v1.0.0/StorageWidgetApp-v1.0.0.dmg)**

> macOS 15 Sequoia or later required.

---

## Features

- Live storage usage for every mounted volume
- Colour-coded progress bars (normal / warning / critical)
- Small, medium, and large widget sizes
- Configurable refresh interval (10 – 200 seconds)
- Eject removable drives from the app
- Dark and light mode with Liquid glass UI
- Hot-plug support (auto-detects drives as you plug/unplug)
- Notifications when a drive exceeds 95% capacity

---

## Install — Pre-built download

1. **[Download the DMG](https://github.com/SD170720000/StorageWidgetApp/releases/download/v1.0.0/StorageWidgetApp-v1.0.0.dmg)**
2. Open the DMG and drag `StorageWidgetApp.app` → **Applications**
3. Open **Terminal** and run this once to clear the macOS quarantine flag:
   ```bash
   xattr -cr /Applications/StorageWidgetApp.app
   ```
4. Open the app from Launchpad or Spotlight
5. Right-click your desktop → **Edit Widgets** → search **"Storage"** → drag to desktop

> **Limitation:** The pre-built version uses default widget settings (all drives,
> alphabetical order, 60 s refresh). To unlock full settings sync between the app
> and widget, build from source below.

---

## Build from Source

Full functionality including persistent settings sync between the app and widget.

### Prerequisites

| Tool | Version | Notes |
|---|---|---|
| macOS | 15.0+ | Sequoia or later |
| Xcode | 16.0+ | Free on the Mac App Store |
| Apple ID | Free or paid | Needed for code signing |

### 1 · Clone

```bash
git clone https://github.com/<your-username>/StorageWidgetApp.git
cd StorageWidgetApp
```

### 2 · Find your Team ID

1. Sign in at [developer.apple.com](https://developer.apple.com)
2. Go to **Account → Membership Details**
3. Copy the **Team ID** (10-character string like `ABC1234XYZ`)

> A **free** Apple ID works — no paid $99/year account needed to build and run on your own Mac.

### 3 · Run setup

```bash
bash scripts/setup.sh
```

Enter your Team ID and a bundle prefix (e.g. `com.yourname`) when prompted.
The script patches the project file, entitlements, and `AppConstants.swift` in place.

> **These changes are local only — do not commit them.**
> To revert at any time: `git restore .`

### 4 · Build & run

```bash
open StorageWidgetApp.xcodeproj   # then hit ⌘R in Xcode
# or
make build
```

### 5 · Add the widget

1. Right-click your macOS desktop → **Edit Widgets**
2. Search **"Storage"**
3. Drag the size you want onto the desktop

---

## Create a distributable DMG

After running `setup.sh` with your own Team ID, you can package a shareable DMG:

```bash
make dmg
# → dist/StorageWidgetApp-<version>.dmg
```

Recipients install with:
```bash
xattr -cr /Applications/StorageWidgetApp.app
```

---

## Release a new version (maintainers)

Tag a version and push — GitHub Actions builds the app, packages it as a ZIP,
and publishes a GitHub Release automatically:

```bash
git tag v1.0.0
git push origin v1.0.0
```

---

## Project structure

```
StorageWidgetApp/
├── StorageWidgetApp/
│   ├── Models/           DriveInfo, StorageSettings
│   ├── Services/         StorageService, SettingsStore, CapacityNotificationService
│   ├── ViewModels/       StorageDashboardViewModel
│   ├── Views/            ContentView, SettingsView, DriveRowView …
│   ├── Widgets/          StorageWidgetViews, WidgetTimelineProvider …
│   └── Utilities/        AppConstants
├── scripts/
│   ├── setup.sh          ← personalise Team ID + bundle prefix (run once)
│   └── make_dmg.sh       ← build a distributable DMG
├── .github/workflows/
│   ├── ci.yml            ← build check on every push / PR
│   └── release.yml       ← publish GitHub Release on version tag
└── Makefile              ← make setup / build / dmg / clean
```

---

## Contributing

1. Fork the repo and clone it
2. Run `bash scripts/setup.sh` with your own Team ID
3. Make your changes on a feature branch
4. Before opening a PR, revert the personalised files:
   ```bash
   git restore StorageWidgetApp.xcodeproj \
               StorageWidgetApp/StorageWidgetApp/Utilities/AppConstants.swift \
               "StorageWidgetApp/StorageWidgetApp/Resources/StorageWidgetApp.entitlements" \
               "StorageWidgetApp/StorageWidgetApp/Widgets/StorageWidgetExtension.entitlements"
   ```
5. Open a pull request

---

## Requirements

- macOS 15.0 Sequoia or later
- Apple Silicon or Intel Mac

---

## License

MIT — see [LICENSE](LICENSE).
