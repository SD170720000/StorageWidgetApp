import Foundation

/// A platform-neutral description of a mounted storage volume.
/// This model is shared by the app and the WidgetKit extension.
struct DriveInfo: Identifiable, Codable, Hashable {
    enum DriveKind: String, Codable {
        case internalDisk
        case externalDisk
        case removableDisk

        var symbolName: String {
            switch self {
            case .internalDisk:
                return "internaldrive.fill"
            case .externalDisk:
                return "externaldrive.fill"
            case .removableDisk:
                return "externaldrive.badge.checkmark"
            }
        }
    }

    let id: String
    let name: String
    let mountPath: String
    let totalBytes: Int64
    let freeBytes: Int64
    let usedBytes: Int64
    let isInternal: Bool
    let isRemovable: Bool
    let isEjectable: Bool
    let localizedFormat: String

    var url: URL {
        URL(fileURLWithPath: mountPath)
    }

    var kind: DriveKind {
        if isInternal { return .internalDisk }
        if isRemovable || isEjectable { return .removableDisk }
        return .externalDisk
    }

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return min(max(Double(usedBytes) / Double(totalBytes), 0), 1)
    }

    var percentUsed: Int {
        Int((usedFraction * 100).rounded())
    }

    var usageState: UsageState {
        switch percentUsed {
        case 95...:
            return .critical
        case 85...:
            return .warning
        default:
            return .normal
        }
    }

    var usedText: String {
        ByteCountFormatter.storageString(fromByteCount: usedBytes)
    }

    var freeText: String {
        ByteCountFormatter.storageString(fromByteCount: freeBytes)
    }

    var totalText: String {
        ByteCountFormatter.storageString(fromByteCount: totalBytes)
    }
}

enum UsageState: String, Codable {
    case normal
    case warning
    case critical
}

extension ByteCountFormatter {
    static func storageString(fromByteCount byteCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB, .useTB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: byteCount)
    }
}
