import Foundation

/// The result of a single problem within a game session. Codable so it can be stored inside GameSession.
struct ProblemResult: Codable, Identifiable {
    var id: UUID = UUID()
    let problemText: String
    let correctAnswer: Double
    let userAnswer: Double?
    let isCorrect: Bool
    let wasSkipped: Bool
    let operation: String          // MathOperation rawValue
    let timeTaken: TimeInterval    // seconds spent on this problem
}
