import WidgetKit

struct StorageWidgetEntry: TimelineEntry {
    let date: Date
    let drives: [DriveInfo]
    let family: WidgetFamily
}
