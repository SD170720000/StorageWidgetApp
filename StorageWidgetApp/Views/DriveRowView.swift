import SwiftUI

struct DriveRowView: View {
    let drive: DriveInfo
    let onEject: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            DriveIconView(drive: drive, size: 36)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(drive.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.80)

                    Spacer(minLength: 8)

                    Text("\(drive.percentUsed)%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(stateColor)

                    if drive.usageState != .normal {
                        Image(systemName: drive.usageState == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(drive.usageState == .critical ? .red : .orange)
                            .help(drive.usageState == .critical ? "Critical storage usage" : "High storage usage")
                    }

                    if drive.isEjectable || drive.isRemovable {
                        Button {
                            onEject?()
                        } label: {
                            Image(systemName: "eject.fill")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("Eject \(drive.name)")
                    }
                }

                StorageProgressBar(fraction: drive.usedFraction, state: drive.usageState)

                Text("\(drive.usedText) used  •  \(drive.freeText) free  •  \(drive.totalText) total")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 7)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var stateColor: Color {
        switch drive.usageState {
        case .critical: return .red
        case .warning:  return .orange
        case .normal:   return .primary
        }
    }
}
