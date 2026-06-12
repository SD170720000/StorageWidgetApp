import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StorageDashboardViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showsSettings = false

    var body: some View {
        ZStack {
            widgetBackground

            VStack(alignment: .leading, spacing: 16) {
                header

                if viewModel.visibleDrives.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.visibleDrives) { drive in
                                DriveRowView(drive: drive) {
                                    viewModel.eject(drive)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }

                footer
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
        .frame(minWidth: 380, idealWidth: 480, maxWidth: 640, minHeight: 280, idealHeight: 380, maxHeight: 580)
        .sheet(isPresented: $showsSettings) {
            SettingsView(viewModel: viewModel)
        }
    }

    private var widgetBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(colorScheme == .dark ? .black.opacity(0.22) : .white.opacity(0.28))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(colorScheme == .dark ? 0.14 : 0.30), lineWidth: 1)
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.38 : 0.16), radius: 18, y: 10)
            .padding(8)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            // Widget icon
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(nsColor: .systemBlue).opacity(0.85), Color(nsColor: .systemIndigo)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 28, height: 28)
            .shadow(color: Color(nsColor: .systemBlue).opacity(0.35), radius: 4, y: 2)

            Text("Storage")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            Spacer()

            Button {
                showsSettings = true
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .background(.primary.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
            .help("Storage settings")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "externaldrive.badge.questionmark")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(.secondary)
            Text("No mounted storage volumes found")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Refresh") { viewModel.refresh() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        HStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                Text(lastUpdatedText)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.refresh()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .font(.caption)
    }

    private var lastUpdatedText: String {
        guard let lastUpdated = viewModel.lastUpdated else {
            return "Not updated yet"
        }
        return "Updated \(lastUpdated.formatted(date: .omitted, time: .shortened))"
    }
}
