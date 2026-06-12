import Foundation

final class SettingsStore {

    private var settingsURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier)?
            .appendingPathComponent("settings.json")
    }

    func load() -> StorageSettings {
        guard let url = settingsURL,
              let data = try? Data(contentsOf: url),
              let settings = try? JSONDecoder().decode(StorageSettings.self, from: data) else {
            return StorageSettings()
        }
        return settings
    }

    func save(_ settings: StorageSettings) {
        guard let url = settingsURL,
              let data = try? JSONEncoder().encode(settings) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
