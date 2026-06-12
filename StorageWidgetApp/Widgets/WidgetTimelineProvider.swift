import WidgetKit

struct WidgetTimelineProvider: TimelineProvider {
    private let storageService = StorageService()
    private let settingsStore = SettingsStore()

    func placeholder(in context: Context) -> StorageWidgetEntry {
        StorageWidgetEntry(date: Date(), drives: sampleDrives, family: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (StorageWidgetEntry) -> Void) {
        completion(StorageWidgetEntry(date: Date(), drives: loadDrives(for: context.family), family: context.family))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StorageWidgetEntry>) -> Void) {
        let settings = settingsStore.load()
        let now = Date()
        let entry = StorageWidgetEntry(date: now, drives: loadDrives(for: context.family), family: context.family)
        let interval = min(
            max(settings.refreshInterval, AppConstants.minimumRefreshInterval),
            AppConstants.maximumRefreshInterval
        )
        completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(interval))))
    }

    private func loadDrives(for family: WidgetFamily) -> [DriveInfo] {
        let settings = settingsStore.load()
        let drives = (try? storageService.mountedDrives()) ?? []
        let filtered = settings.selectedDriveIDs.isEmpty ? drives : drives.filter { settings.selectedDriveIDs.contains($0.id) }
        let sorted = sort(filtered, by: settings.sortOption)

        switch family {
        case .systemSmall:
            return Array(sorted.prefix(1))
        case .systemMedium:
            return Array(sorted.prefix(2))
        default:
            return sorted
        }
    }

    private func sort(_ drives: [DriveInfo], by option: DriveSortOption) -> [DriveInfo] {
        switch option {
        case .name:
            return drives.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .percentUsed:
            return drives.sorted { $0.percentUsed > $1.percentUsed }
        case .freeSpace:
            return drives.sorted { $0.freeBytes < $1.freeBytes }
        }
    }

    private var sampleDrives: [DriveInfo] {
        [
            DriveInfo(
                id: "sample-internal",
                name: "Macintosh HD",
                mountPath: "/",
                totalBytes: 494_400_000_000,
                freeBytes: 147_200_000_000,
                usedBytes: 347_200_000_000,
                isInternal: true,
                isRemovable: false,
                isEjectable: false,
                localizedFormat: "APFS"
            )
        ]
    }
}
