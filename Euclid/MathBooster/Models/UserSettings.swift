import Foundation
import SwiftData

/// Singleton user preferences, persisted with SwiftData.
@Model
class UserSettings {
    // Operations
    var enabledOperations: [String]

    // Difficulty
    var difficulty: String

    // Game mode
    var gameMode: String               // GameMode rawValue
    var timerDuration: Int             // seconds for timed mode
    var taskCount: Int                 // number of problems for task count mode

    // Toggles
    var decimalsEnabled: Bool          // allow 2-decimal answers
    var negativesEnabled: Bool         // allow negative operands
    var soundEnabled: Bool
    var hapticEnabled: Bool

    // Notifications
    var notificationsEnabled: Bool
    var notificationHour: Int
    var notificationMinute: Int

    // Personal bests
    var bestScore: Int
    var bestAccuracy: Double

    // MARK: - Convenience accessors

    var operations: [MathOperation] {
        get { enabledOperations.compactMap { MathOperation(rawValue: $0) } }
        set { enabledOperations = newValue.map(\.rawValue) }
    }

    var difficultyLevel: Difficulty {
        get { Difficulty(rawValue: difficulty) ?? .range1to100 }
        set { difficulty = newValue.rawValue }
    }

    var gameModeValue: GameMode {
        get { GameMode(rawValue: gameMode) ?? .timed }
        set { gameMode = newValue.rawValue }
    }

    var timerDisplayName: String {
        if timerDuration == 0 { return "Unlimited" }
        let mins = timerDuration / 60
        let secs = timerDuration % 60
        if mins > 0 && secs > 0 { return "\(mins)m \(secs)s" }
        if mins > 0 { return "\(mins)m" }
        return "\(timerDuration)s"
    }

    var notificationTimeString: String {
        String(format: "%02d:%02d", notificationHour, notificationMinute)
    }

    init(
        enabledOperations: [String] = MathOperation.defaults.map(\.rawValue),
        difficulty: String = Difficulty.range1to100.rawValue,
        gameMode: String = GameMode.timed.rawValue,
        timerDuration: Int = 90,
        taskCount: Int = 20,
        decimalsEnabled: Bool = false,
        negativesEnabled: Bool = false,
        soundEnabled: Bool = true,
        hapticEnabled: Bool = true,
        notificationsEnabled: Bool = false,
        notificationHour: Int = 9,
        notificationMinute: Int = 0,
        bestScore: Int = 0,
        bestAccuracy: Double = 0
    ) {
        self.enabledOperations = enabledOperations
        self.difficulty = difficulty
        self.gameMode = gameMode
        self.timerDuration = timerDuration
        self.taskCount = taskCount
        self.decimalsEnabled = decimalsEnabled
        self.negativesEnabled = negativesEnabled
        self.soundEnabled = soundEnabled
        self.hapticEnabled = hapticEnabled
        self.notificationsEnabled = notificationsEnabled
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.bestScore = bestScore
        self.bestAccuracy = bestAccuracy
    }

    /// Preset timer options for timed mode.
    static let timerPresets: [Int] = [45, 90, 180, 0]

    /// Preset task count options.
    static let taskCountPresets: [Int] = [10, 20, 50, 100]
}
