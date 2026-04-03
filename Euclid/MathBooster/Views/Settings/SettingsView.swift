import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showTimePicker = false

    var body: some View {
        NavigationStack {
            Group {
                if let settings = viewModel.settings {
                    settingsList(settings: settings)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadSettings(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    private func settingsList(settings: UserSettings) -> some View {
        List {
            // MARK: - Operations
            Section("Operations") {
                ForEach(MathOperation.allCases) { op in
                    Button {
                        viewModel.toggleOperation(op)
                    } label: {
                        HStack {
                            Image(systemName: op.iconName)
                                .frame(width: 24)
                                .foregroundStyle(.indigo)
                            Text(op.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.isOperationEnabled(op) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                }
            }

            // MARK: - Difficulty
            Section("Difficulty") {
                ForEach(Difficulty.allCases) { diff in
                    Button {
                        viewModel.setDifficulty(diff)
                    } label: {
                        HStack {
                            Image(systemName: diff.iconName)
                                .frame(width: 24)
                                .foregroundStyle(.indigo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(diff.displayName)
                                    .foregroundStyle(.primary)
                                Text(diff.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if settings.difficultyLevel == diff {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                }
            }

            // MARK: - Game Mode
            Section("Game Mode") {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        viewModel.setGameMode(mode)
                    } label: {
                        HStack {
                            Image(systemName: mode.iconName)
                                .frame(width: 24)
                                .foregroundStyle(.indigo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.displayName)
                                    .foregroundStyle(.primary)
                                Text(mode.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if settings.gameModeValue == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                }

                // Timer presets (shown when timed mode selected)
                if settings.gameModeValue == .timed {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timer Duration")
                            .font(.subheadline.bold())
                        HStack(spacing: 8) {
                            ForEach(UserSettings.timerPresets, id: \.self) { preset in
                                Button {
                                    viewModel.setTimerDuration(preset)
                                } label: {
                                    Text(preset == 0 ? "Unlimited" : "\(preset)s")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            settings.timerDuration == preset ? Color.indigo : Color(.systemGray5),
                                            in: RoundedRectangle(cornerRadius: 8)
                                        )
                                        .foregroundStyle(settings.timerDuration == preset ? .white : .primary)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Task count presets (shown when task count mode selected)
                if settings.gameModeValue == .taskCount {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Problems")
                            .font(.subheadline.bold())
                        HStack(spacing: 8) {
                            ForEach(UserSettings.taskCountPresets, id: \.self) { preset in
                                Button {
                                    viewModel.setTaskCount(preset)
                                } label: {
                                    Text("\(preset)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            settings.taskCount == preset ? Color.indigo : Color(.systemGray5),
                                            in: RoundedRectangle(cornerRadius: 8)
                                        )
                                        .foregroundStyle(settings.taskCount == preset ? .white : .primary)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // MARK: - Number Options
            Section("Number Options") {
                Toggle(isOn: Binding(
                    get: { settings.decimalsEnabled },
                    set: { _ in viewModel.toggleDecimals() }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Allow Decimals")
                        Text("Answers may have up to 2 decimal places")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(isOn: Binding(
                    get: { settings.negativesEnabled },
                    set: { _ in viewModel.toggleNegatives() }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Allow Negatives")
                        Text("Problems may include negative numbers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: - Preferences
            Section("Preferences") {
                Toggle("Sound Effects", isOn: Binding(
                    get: { settings.soundEnabled },
                    set: { _ in viewModel.toggleSound() }
                ))

                Toggle("Haptic Feedback", isOn: Binding(
                    get: { settings.hapticEnabled },
                    set: { _ in viewModel.toggleHaptic() }
                ))
            }

            // MARK: - Notifications
            Section("Daily Reminder") {
                Toggle("Enable Reminder", isOn: Binding(
                    get: { settings.notificationsEnabled },
                    set: { _ in viewModel.toggleNotifications() }
                ))

                if settings.notificationsEnabled {
                    Button {
                        showTimePicker.toggle()
                    } label: {
                        HStack {
                            Text("Reminder Time")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(settings.notificationTimeString)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if showTimePicker {
                        DatePicker(
                            "Time",
                            selection: Binding(
                                get: {
                                    var comps = DateComponents()
                                    comps.hour = settings.notificationHour
                                    comps.minute = settings.notificationMinute
                                    return Calendar.current.date(from: comps) ?? .now
                                },
                                set: { date in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    viewModel.setNotificationTime(
                                        hour: comps.hour ?? 9,
                                        minute: comps.minute ?? 0
                                    )
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
                }
            }
        }
    }
}
