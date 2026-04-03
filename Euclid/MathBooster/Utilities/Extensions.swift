import Foundation

// MARK: - Double

extension Double {
    /// Returns a clean string: "7" instead of "7.0", or "3.14" for decimals.
    var cleanString: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(format: "%.2f", self)
    }

    /// Returns a formatted percentage string like "85%".
    var percentString: String {
        String(format: "%.0f%%", self * 100)
    }
}

// MARK: - TimeInterval

extension TimeInterval {
    /// Formats seconds into "M:SS" for timer display.
    var timerString: String {
        let mins = Int(self) / 60
        let secs = Int(self) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Date

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var relativeDateString: String {
        if isToday { return "Today" }
        if isYesterday { return "Yesterday" }
        return shortDateString
    }
}

// MARK: - Array<GameSession>

extension Array where Element: GameSession {
    /// Calculates the current daily streak (consecutive days with at least one session).
    var currentStreak: Int {
        guard !isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedDates = self
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)

        // Remove duplicates (multiple sessions on same day)
        var uniqueDays: [Date] = []
        for date in sortedDates {
            if uniqueDays.last != date {
                uniqueDays.append(date)
            }
        }

        let today = calendar.startOfDay(for: .now)
        guard let latest = uniqueDays.first,
              calendar.isDate(latest, inSameDayAs: today) || calendar.isDate(latest, inSameDayAs: today.addingTimeInterval(-86400)) else {
            return 0
        }

        var streak = 1
        for i in 1..<uniqueDays.count {
            let expected = calendar.date(byAdding: .day, value: -1, to: uniqueDays[i - 1])!
            if calendar.isDate(uniqueDays[i], inSameDayAs: expected) {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

    /// All-time accuracy across all sessions.
    var allTimeAccuracy: Double {
        let totalCorrect = reduce(0) { $0 + $1.correctAnswers }
        let totalProblems = reduce(0) { $0 + $1.totalProblems }
        guard totalProblems > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalProblems)
    }

    /// Average tasks per day (based on days with at least one session).
    var averageTasksPerDay: Double {
        guard !isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(map { calendar.startOfDay(for: $0.date) })
        let totalTasks = reduce(0) { $0 + $1.totalProblems }
        return Double(totalTasks) / Double(uniqueDays.count)
    }

    /// Average tasks per minute across all sessions.
    var averageTasksPerMinute: Double {
        let totalTasks = reduce(0) { $0 + $1.totalProblems }
        let totalMinutes = reduce(0.0) { $0 + $1.duration } / 60.0
        guard totalMinutes > 0 else { return 0 }
        return Double(totalTasks) / totalMinutes
    }
}
