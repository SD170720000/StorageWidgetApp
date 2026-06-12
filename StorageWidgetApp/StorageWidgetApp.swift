import SwiftUI

@main
struct StorageWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 380, idealWidth: 430, maxWidth: 520,
                       minHeight: 420, idealHeight: 560, maxHeight: 760)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
