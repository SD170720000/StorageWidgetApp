import Foundation

enum DriveSortOption: String, CaseIterable, Identifiable, Codable {
    case name
    case percentUsed
    case freeSpace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name:
            return "Name"
        case .percentUsed:
            return "Percentage Used"
        case .freeSpace:
            return "Free Space"
        }
    }
}

struct StorageSettings: Codable, Equatable {
    var selectedDriveIDs: Set<String> = []
    var sortOption: DriveSortOption = .name
    var refreshInterval: TimeInterval = 60
}
