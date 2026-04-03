import Foundation
import SwiftData
import Observation

/// Reads and writes UserSettings, providing bindings for the settings UI.
@Observable
class SettingsViewModel {
    var settings: UserSettings?

    func loadSettings(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        if let existing = results.first {
            settings = existing
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            settings = newSettings
        }
    }

    // MARK: - Operations

    func isOperationEnabled(_ op: MathOperation) -> Bool {
        settings?.operations.contains(op) ?? false
    }

    func toggleOperation(_ op: MathOperation) {
        guard let settings else { return }
        if settings.operations.contains(op) {
            // Don't allow disabling all operations
            if settings.operations.count > 1 {
                settings.operations.removeAll { $0 == op }
            }
        } else {
            settings.operations.append(op)
        }
    }

    // MARK: - Difficulty

    func setDifficulty(_ diff: Difficulty) {
        settings?.difficultyLevel = diff
    }

    // MARK: - Game mode

    func setGameMode(_ mode: GameMode) {
        settings?.gameModeValue = mode
    }

    func setTimerDuration(_ seconds: Int) {
        settings?.timerDuration = seconds
    }

    func setTaskCount(_ count: Int) {
        settings?.taskCount = count
    }

    // MARK: - Toggles

    func toggleDecimals() {
        guard let settings else { return }
        settings.decimalsEnabled.toggle()
    }

    func toggleNegatives() {
        guard let settings else { return }
        settings.negativesEnabled.toggle()
    }

    func toggleSound() {
        guard let settings else { return }
        settings.soundEnabled.toggle()
    }

    func toggleHaptic() {
        guard let settings else { return }
        settings.hapticEnabled.toggle()
    }

    // MARK: - Notifications

    func toggleNotifications() {
        guard let settings else { return }
        if !settings.notificationsEnabled {
            NotificationManager.shared.requestPermission { granted in
                settings.notificationsEnabled = granted
                if granted {
                    NotificationManager.shared.scheduleDailyReminder(
                        hour: settings.notificationHour,
                        minute: settings.notificationMinute
                    )
                }
            }
        } else {
            settings.notificationsEnabled = false
            NotificationManager.shared.cancelReminder()
        }
    }

    func setNotificationTime(hour: Int, minute: Int) {
        guard let settings else { return }
        settings.notificationHour = hour
        settings.notificationMinute = minute
        if settings.notificationsEnabled {
            NotificationManager.shared.scheduleDailyReminder(hour: hour, minute: minute)
        }
    }
}
