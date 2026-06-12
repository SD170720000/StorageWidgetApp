import SwiftUI
import WidgetKit

@main
struct StorageWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StorageWidget()
    }
}

struct StorageWidget: Widget {
    let kind = "StorageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            StorageWidgetView(entry: entry)
        }
        .configurationDisplayName("Storage")
        .description("Monitor mounted drive capacity from the desktop.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
