import Foundation
import UserNotifications

protocol CapacityNotificationServicing {
    func requestAuthorization()
    func notifyIfNeeded(for drives: [DriveInfo])
}

final class CapacityNotificationService: CapacityNotificationServicing {
    private var notifiedDriveIDs = Set<String>()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notifyIfNeeded(for drives: [DriveInfo]) {
        for drive in drives where drive.usageState == .critical && !notifiedDriveIDs.contains(drive.id) {
            notifiedDriveIDs.insert(drive.id)
            sendNotification(for: drive)
        }

        let criticalIDs = Set(drives.filter { $0.usageState == .critical }.map(\.id))
        notifiedDriveIDs = notifiedDriveIDs.intersection(criticalIDs)
    }

    private func sendNotification(for drive: DriveInfo) {
        let content = UNMutableNotificationContent()
        content.title = "Storage Almost Full"
        content.body = "\(drive.name) is \(drive.percentUsed)% full. \(drive.freeText) remains available."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "critical-storage-\(drive.id)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
