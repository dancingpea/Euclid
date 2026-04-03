import Foundation
import SwiftData

/// A completed game session, persisted with SwiftData.
@Model
class GameSession {
    var date: Date
    var duration: TimeInterval
    var totalProblems: Int
    var correctAnswers: Int
    var skippedCount: Int
    var operations: [String]        // MathOperation rawValues
    var difficulty: String           // Difficulty rawValue
    var gameMode: String             // GameMode rawValue
    var problemResultsData: Data?    // JSON-encoded [ProblemResult]

    // MARK: - Computed helpers

    var accuracy: Double {
        guard totalProblems > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalProblems)
    }

    var wrongAnswers: Int {
        totalProblems - correctAnswers - skippedCount
    }

    var problemResults: [ProblemResult] {
        get {
            guard let data = problemResultsData else { return [] }
            return (try? JSONDecoder().decode([ProblemResult].self, from: data)) ?? []
        }
        set {
            problemResultsData = try? JSONEncoder().encode(newValue)
        }
    }

    var tasksPerMinute: Double {
        guard duration > 0 else { return 0 }
        return Double(totalProblems) / (duration / 60.0)
    }

    init(
        date: Date = .now,
        duration: TimeInterval = 0,
        totalProblems: Int = 0,
        correctAnswers: Int = 0,
        skippedCount: Int = 0,
        operations: [String] = [],
        difficulty: String = Difficulty.range1to100.rawValue,
        gameMode: String = GameMode.timed.rawValue,
        problemResultsData: Data? = nil
    ) {
        self.date = date
        self.duration = duration
        self.totalProblems = totalProblems
        self.correctAnswers = correctAnswers
        self.skippedCount = skippedCount
        self.operations = operations
        self.difficulty = difficulty
        self.gameMode = gameMode
        self.problemResultsData = problemResultsData
    }
}
