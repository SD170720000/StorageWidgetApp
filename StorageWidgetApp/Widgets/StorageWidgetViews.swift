import SwiftUI
import WidgetKit

struct StorageWidgetView: View {
    let entry: StorageWidgetEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: metrics.headerSpacing) {
                HStack(alignment: .center) {
                    Text("Storage")
                        .font(.system(size: metrics.titleSize, weight: .semibold))
                        .lineLimit(1)

                    Spacer()

                    if family != .systemSmall {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary.opacity(0.72))
                            .frame(width: 30, height: 30)
                            .background(.white.opacity(colorScheme == .dark ? 0.10 : 0.22), in: Circle())
                    }
                }

                if entry.drives.isEmpty {
                    Spacer()
                    Label("No drives", systemImage: "externaldrive.badge.questionmark")
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    VStack(spacing: metrics.rowSpacing) {
                        ForEach(displayedDrives) { drive in
                            WidgetDriveRow(drive: drive, metrics: metrics)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(metrics.contentInsets)
        }
        .containerBackground(for: .widget) {
            LiquidWidgetBackground()
        }
    }

    private var displayedDrives: [DriveInfo] {
        switch family {
        case .systemSmall:
            return Array(entry.drives.prefix(1))
        case .systemMedium:
            return Array(entry.drives.prefix(2))
        default:
            return entry.drives
        }
    }

    private var metrics: WidgetLayoutMetrics {
        WidgetLayoutMetrics(family: family)
    }
}

private struct WidgetDriveRow: View {
    let drive: DriveInfo
    let metrics: WidgetLayoutMetrics
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: metrics.iconTextSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: metrics.iconCornerRadius, style: .continuous)
                    .fill(.white.opacity(colorScheme == .dark ? 0.09 : 0.20))
                    .overlay {
                        RoundedRectangle(cornerRadius: metrics.iconCornerRadius, style: .continuous)
                            .stroke(.white.opacity(colorScheme == .dark ? 0.10 : 0.26), lineWidth: 1)
                    }

                Image(systemName: drive.kind.symbolName)
                    .font(.system(size: metrics.iconSymbolSize, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)
            }
            .frame(width: metrics.iconBoxSize, height: metrics.iconBoxSize)

            VStack(alignment: .leading, spacing: metrics.rowInnerSpacing) {
                HStack {
                    Text(drive.name)
                        .font(.system(size: metrics.driveNameSize, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.80)

                    Spacer()

                    Text("\(drive.percentUsed)%")
                        .font(.system(size: metrics.percentSize, weight: .semibold).monospacedDigit())
                        .foregroundStyle(stateColor)
                }

                WidgetProgressBar(fraction: drive.usedFraction, state: drive.usageState, height: metrics.progressHeight)

                if metrics.showsCapacityLine {
                    Text("(\(drive.percentUsed)%)  \(drive.freeText) of \(drive.totalText) free")
                        .font(.system(size: metrics.captionSize, weight: .regular).monospacedDigit())
                        .foregroundStyle(.secondary.opacity(0.90))
                        .lineLimit(1)
                        .minimumScaleFactor(0.80)
                }
            }
        }
    }

    private var iconColor: Color {
        switch drive.usageState {
        case .critical: return .red
        case .warning: return .orange
        case .normal: return .primary.opacity(0.78)
        }
    }

    private var stateColor: Color {
        switch drive.usageState {
        case .critical: return .red
        case .warning: return .orange
        case .normal: return .primary
        }
    }
}

private struct WidgetProgressBar: View {
    let fraction: Double
    let state: UsageState
    let height: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(.white.opacity(colorScheme == .dark ? 0.13 : 0.26))
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(.white.opacity(colorScheme == .dark ? 0.07 : 0.24), lineWidth: 0.75)
                    }

                Capsule(style: .continuous)
                    .fill(fillGradient)
                    .frame(width: max(proxy.size.width * fraction, fraction > 0 ? 6 : 0))
                    .shadow(color: fillColor.opacity(0.26), radius: 5, x: 0, y: 1)
            }
        }
        .frame(height: height)
    }

    private var fillColor: Color {
        switch state {
        case .critical: return .red
        case .warning: return .orange
        case .normal: return .primary.opacity(0.82)
        }
    }

    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [
                fillColor.opacity(colorScheme == .dark ? 0.95 : 0.78),
                fillColor.opacity(colorScheme == .dark ? 0.72 : 0.58)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

private struct LiquidWidgetBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Rectangle()
                .fill(baseTint)

            LinearGradient(
                colors: [
                    .white.opacity(colorScheme == .dark ? 0.16 : 0.42),
                    .white.opacity(0.04),
                    .black.opacity(colorScheme == .dark ? 0.18 : 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ContainerRelativeShape()
                .strokeBorder(.white.opacity(colorScheme == .dark ? 0.16 : 0.38), lineWidth: 1)
        }
    }

    private var baseTint: Color {
        colorScheme == .dark ? .black.opacity(0.18) : .white.opacity(0.32)
    }
}

private struct WidgetLayoutMetrics {
    let contentInsets: EdgeInsets
    let headerSpacing: CGFloat
    let rowSpacing: CGFloat
    let rowInnerSpacing: CGFloat
    let iconTextSpacing: CGFloat
    let iconBoxSize: CGFloat
    let iconSymbolSize: CGFloat
    let iconCornerRadius: CGFloat
    let titleSize: CGFloat
    let driveNameSize: CGFloat
    let percentSize: CGFloat
    let captionSize: CGFloat
    let progressHeight: CGFloat
    let showsCapacityLine: Bool

    init(family: WidgetFamily) {
        switch family {
        case .systemSmall:
            contentInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            headerSpacing = 10
            rowSpacing = 0
            rowInnerSpacing = 5
            iconTextSpacing = 8
            iconBoxSize = 32
            iconSymbolSize = 18
            iconCornerRadius = 9
            titleSize = 17
            driveNameSize = 13
            percentSize = 12
            captionSize = 10
            progressHeight = 6
            showsCapacityLine = false
        case .systemMedium:
            contentInsets = EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18)
            headerSpacing = 12
            rowSpacing = 12
            rowInnerSpacing = 5
            iconTextSpacing = 10
            iconBoxSize = 36
            iconSymbolSize = 21
            iconCornerRadius = 10
            titleSize = 18
            driveNameSize = 14
            percentSize = 13
            captionSize = 11
            progressHeight = 7
            showsCapacityLine = true
        default:
            contentInsets = EdgeInsets(top: 26, leading: 26, bottom: 26, trailing: 26)
            headerSpacing = 22
            rowSpacing = 20
            rowInnerSpacing = 8
            iconTextSpacing = 18
            iconBoxSize = 54
            iconSymbolSize = 32
            iconCornerRadius = 16
            titleSize = 28
            driveNameSize = 20
            percentSize = 18
            captionSize = 12
            progressHeight = 9
            showsCapacityLine = true
        }
    }
}
