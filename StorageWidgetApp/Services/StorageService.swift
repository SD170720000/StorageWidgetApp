import AppKit
import Darwin
import Foundation

protocol StorageServicing: Sendable {
    func mountedDrives() throws -> [DriveInfo]
    func eject(_ drive: DriveInfo) async throws
}

enum StorageServiceError: LocalizedError {
    case unableToLoadVolumes
    case ejectFailed(String)

    var errorDescription: String? {
        switch self {
        case .unableToLoadVolumes:
            return "Unable to read mounted storage volumes."
        case .ejectFailed(let name):
            return "Unable to eject \(name)."
        }
    }
}

final class StorageService: StorageServicing, @unchecked Sendable {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func mountedDrives() throws -> [DriveInfo] {
        let keys: Set<URLResourceKey> = [
            .volumeNameKey,
            .volumeIdentifierKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey,
            .volumeIsInternalKey,
            .volumeIsRemovableKey,
            .volumeIsEjectableKey,
            .volumeLocalizedFormatDescriptionKey
        ]

        guard let urls = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: Array(keys),
            options: [.skipHiddenVolumes]
        ) else {
            throw StorageServiceError.unableToLoadVolumes
        }

        return urls.compactMap { url in
            driveInfo(for: url, keys: keys)
        }
        .filter { $0.totalBytes > 0 }
        .filter { !isDiskImage(at: $0.mountPath) }
    }

    func eject(_ drive: DriveInfo) async throws {
        let url = URL(fileURLWithPath: drive.mountPath)
        do {
            try NSWorkspace.shared.unmountAndEjectDevice(at: url)
        } catch {
            throw StorageServiceError.ejectFailed(drive.name)
        }
    }

    private func driveInfo(for url: URL, keys: Set<URLResourceKey>) -> DriveInfo? {
        guard let values = try? url.resourceValues(forKeys: keys),
              let capacity = capacityInfo(for: url, values: values),
              capacity.totalBytes > 0 else {
            return nil
        }

        let totalBytes = capacity.totalBytes
        let freeBytes = max(capacity.freeBytes, 0)
        let usedBytes = max(totalBytes - freeBytes, 0)
        let trimmedName = values.volumeName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackName = url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent

        return DriveInfo(
            id: stableIdentifier(for: url, values: values),
            name: trimmedName?.isEmpty == false ? trimmedName! : fallbackName,
            mountPath: url.path,
            totalBytes: totalBytes,
            freeBytes: freeBytes,
            usedBytes: usedBytes,
            isInternal: values.volumeIsInternal ?? false,
            isRemovable: values.volumeIsRemovable ?? false,
            isEjectable: values.volumeIsEjectable ?? false,
            localizedFormat: values.volumeLocalizedFormatDescription ?? "Volume"
        )
    }

    private func capacityInfo(for url: URL, values: URLResourceValues) -> (totalBytes: Int64, freeBytes: Int64)? {
        let statCapacity = statFSCapacity(for: url)
        let resourceTotal = values.volumeTotalCapacity.map(Int64.init)
        let resourceFree = values.volumeAvailableCapacity.map(Int64.init)

        let totalBytes = resourceTotal ?? statCapacity?.totalBytes
        var freeBytes = resourceFree ?? statCapacity?.freeBytes

        // Some removable volumes return 0 through URLResourceValues even while statfs reports correctly.
        if let statCapacity, (freeBytes ?? 0) == 0, statCapacity.freeBytes > 0 {
            freeBytes = statCapacity.freeBytes
        }

        guard let totalBytes, let freeBytes else {
            return nil
        }

        return (totalBytes, freeBytes)
    }

    private func statFSCapacity(for url: URL) -> (totalBytes: Int64, freeBytes: Int64)? {
        var fileSystemStats = statfs()
        guard statfs(url.path, &fileSystemStats) == 0 else {
            return nil
        }

        let blockSize = Int64(fileSystemStats.f_bsize)
        let totalBytes = Int64(fileSystemStats.f_blocks) * blockSize
        let freeBytes = Int64(fileSystemStats.f_bavail) * blockSize

        guard totalBytes > 0 else {
            return nil
        }

        return (totalBytes, max(freeBytes, 0))
    }

    private func isDiskImage(at path: String) -> Bool {
        var stats = statfs()
        guard statfs(path, &stats) == 0 else { return false }
        // DMGs are always mounted read-only; the boot volume at "/" is never read-only this way
        let isReadOnly = (stats.f_flags & UInt32(bitPattern: MNT_RDONLY)) != 0
        return isReadOnly && path != "/"
    }

    private func stableIdentifier(for url: URL, values: URLResourceValues) -> String {
        if let identifier = values.volumeIdentifier {
            return String(describing: identifier)
        }

        return url.path
    }
}
