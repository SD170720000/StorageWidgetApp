import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: StorageDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private let secondsOptions: [Int] = Array(stride(from: 10, through: 200, by: 10))

    var body: some View {
        NavigationStack {
            ZStack {
                liquidBackground
                    .ignoresSafeArea()

                Form {
                    Section("Visible Drives") {
                        if viewModel.allDrives.isEmpty {
                            Text("No mounted drives detected.")
                                .foregroundStyle(.secondary)
                                .listRowBackground(liquidRowBackground)
                        } else {
                            ForEach(viewModel.allDrives) { drive in
                                Toggle(isOn: binding(for: drive)) {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(Color(nsColor: .systemBlue).opacity(0.15))
                                            Image(systemName: drive.kind.symbolName)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(Color(nsColor: .systemBlue))
                                        }
                                        .frame(width: 26, height: 26)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(drive.name)
                                                .font(.system(size: 13, weight: .medium))
                                            Text(drive.mountPath)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .listRowBackground(liquidRowBackground)
                            }
                        }
                    }

                    Section("Sorting") {
                        Picker("Sort by", selection: $viewModel.settings.sortOption) {
                            ForEach(DriveSortOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .listRowBackground(liquidRowBackground)
                    }

                    Section("Refresh") {
                        Picker("Interval", selection: $viewModel.settings.refreshInterval) {
                            ForEach(secondsOptions, id: \.self) { secs in
                                Text("\(secs) sec").tag(TimeInterval(secs))
                            }
                        }
                        .listRowBackground(liquidRowBackground)

                        Button {
                            viewModel.refresh()
                        } label: {
                            Label("Refresh Now", systemImage: "arrow.clockwise")
                        }
                        .listRowBackground(liquidRowBackground)
                    }
                }
                .scrollContentBackground(.hidden)
                .formStyle(.grouped)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
                .frame(width: 400)
                .frame(minHeight: 360, maxHeight: 520)
            }
        }
    }

    private var liquidBackground: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            LinearGradient(
                colors: [
                    .white.opacity(colorScheme == .dark ? 0.07 : 0.28),
                    .clear,
                    .black.opacity(colorScheme == .dark ? 0.10 : 0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var liquidRowBackground: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(colorScheme == .dark ? .white.opacity(0.04) : .white.opacity(0.45))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(.white.opacity(colorScheme == .dark ? 0.10 : 0.30), lineWidth: 0.5)
                    }
            }
    }

    private func binding(for drive: DriveInfo) -> Binding<Bool> {
        Binding {
            viewModel.isDriveVisible(drive)
        } set: { newValue in
            viewModel.setDrive(drive, isVisible: newValue)
        }
    }
}
