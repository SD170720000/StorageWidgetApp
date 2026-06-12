import SwiftUI

struct StorageProgressBar: View {
    let fraction: Double
    var state: UsageState = .normal

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(.white.opacity(0.18))

                Capsule(style: .continuous)
                    .fill(progressStyle)
                    .frame(width: max(proxy.size.width * fraction, fraction > 0 ? 8 : 0))
                    .shadow(color: progressColor.opacity(0.28), radius: 5, y: 1)
            }
        }
        .frame(height: 10)
        .accessibilityLabel("Storage used")
        .accessibilityValue(fraction.formatted(.percent.precision(.fractionLength(0))))
    }

    private var progressStyle: LinearGradient {
        LinearGradient(colors: [.white.opacity(0.92), progressColor.opacity(0.95)], startPoint: .leading, endPoint: .trailing)
    }

    private var progressColor: Color {
        switch state {
        case .critical:
            return .red
        case .warning:
            return .orange
        default:
            return .white
        }
    }
}
