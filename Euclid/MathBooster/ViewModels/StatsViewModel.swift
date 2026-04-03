import Foundation
import SwiftData
import Observation

/// Aggregates GameSession data for the stats screen.
@Observable
class StatsViewModel {
    var sessions: [GameSession] = []

    func loadSessions(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<GameSession>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        sessions = (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Summary stats

    var totalSessions: Int { sessions.count }

    var totalProblemsAttempted: Int {
        sessions.reduce(0) { $0 + $1.totalProblems }
    }

    var totalCorrect: Int {
        sessions.reduce(0) { $0 + $1.correctAnswers }
    }

    var allTimeAccuracy: Double {
        sessions.allTimeAccuracy
    }

    var currentStreak: Int {
        sessions.currentStreak
    }

    var averageTasksPerDay: Double {
        sessions.averageTasksPerDay
    }

    var averageTasksPerMinute: Double {
        sessions.averageTasksPerMinute
    }

    // MARK: - Chart data

    /// Last 7 days of accuracy data for the chart.
    var weeklyAccuracy: [(date: Date, accuracy: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var result: [(date: Date, accuracy: Double)] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let total = daySessions.reduce(0) { $0 + $1.totalProblems }
            let correct = daySessions.reduce(0) { $0 + $1.correctAnswers }
            let acc = total > 0 ? Double(correct) / Double(total) : 0
            result.append((date: date, accuracy: acc))
        }
        return result
    }

    /// Breakdown by operation type.
    var operationBreakdown: [(operation: String, count: Int, accuracy: Double)] {
        var opData: [String: (total: Int, correct: Int)] = [:]

        for session in sessions {
            for result in session.problemResults {
                let key = result.operation
                var current = opData[key] ?? (total: 0, correct: 0)
                current.total += 1
                if result.isCorrect { current.correct += 1 }
                opData[key] = current
            }
        }

        return opData.map { key, value in
            let op = MathOperation(rawValue: key)?.displayName ?? key
            let acc = value.total > 0 ? Double(value.correct) / Double(value.total) : 0
            return (operation: op, count: value.total, accuracy: acc)
        }.sorted { $0.count > $1.count }
    }

    /// Recent sessions (last 10).
    var recentSessions: [GameSession] {
        Array(sessions.prefix(10))
    }
}
