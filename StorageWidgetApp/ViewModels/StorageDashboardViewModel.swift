import AppKit
import Combine
import Foundation
import SwiftUI

@MainActor
final class StorageDashboardViewModel: ObservableObject {
    @Published private(set) var allDrives: [DriveInfo] = []
    @Published private(set) var visibleDrives: [DriveInfo] = []
    @Published private(set) var lastUpdated: Date?
    @Published var settings: StorageSettings {
        didSet {
            settingsStore.save(settings)
            applySettings()
            restartTimer()
        }
    }
    @Published var errorMessage: String?

    private let storageService: StorageServicing
    private let settingsStore: SettingsStore
    private let notificationService: CapacityNotificationServicing
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: AnyCancellable?

    init(
        storageService: StorageServicing = StorageService(),
        settingsStore: SettingsStore = SettingsStore(),
        notificationService: CapacityNotificationServicing = CapacityNotificationService()
    ) {
        self.storageService = storageService
        self.settingsStore = settingsStore
        self.notificationService = notificationService
        self.settings = settingsStore.load()

        notificationService.requestAuthorization()
        observeVolumeChanges()
        restartTimer()
        refresh()
    }

    func refresh() {
        do {
            let drives = try storageService.mountedDrives()
            withAnimation(.snappy(duration: 0.35)) {
                allDrives = drives
                lastUpdated = Date()
                errorMessage = nil
                applySettings()
            }
            notificationService.notifyIfNeeded(for: drives)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setDrive(_ drive: DriveInfo, isVisible: Bool) {
        if isVisible {
            settings.selectedDriveIDs.insert(drive.id)
        } else {
            settings.selectedDriveIDs.remove(drive.id)
        }
    }

    func isDriveVisible(_ drive: DriveInfo) -> Bool {
        settings.selectedDriveIDs.isEmpty || settings.selectedDriveIDs.contains(drive.id)
    }

    func eject(_ drive: DriveInfo) {
        Task {
            do {
                try await storageService.eject(drive)
                refresh()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func applySettings() {
        let selected = settings.selectedDriveIDs
        let filtered = selected.isEmpty ? allDrives : allDrives.filter { selected.contains($0.id) }

        visibleDrives = sort(filtered, by: settings.sortOption)
    }

    private func sort(_ drives: [DriveInfo], by option: DriveSortOption) -> [DriveInfo] {
        switch option {
        case .name:
            return drives.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .percentUsed:
            return drives.sorted { $0.percentUsed > $1.percentUsed }
        case .freeSpace:
            return drives.sorted { $0.freeBytes < $1.freeBytes }
        }
    }

    private func observeVolumeChanges() {
        [
            NSWorkspace.didMountNotification,
            NSWorkspace.didUnmountNotification,
            NSWorkspace.didRenameVolumeNotification
        ].forEach { name in
            NSWorkspace.shared.notificationCenter.publisher(for: name)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.refresh() }
                .store(in: &cancellables)
        }
    }

    private func restartTimer() {
        refreshTimer?.cancel()
        let interval = min(
            max(settings.refreshInterval, AppConstants.minimumRefreshInterval),
            AppConstants.maximumRefreshInterval
        )

        refreshTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refresh() }
    }
}
