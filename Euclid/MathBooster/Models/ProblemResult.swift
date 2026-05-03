import Foundation

/// The result of a single problem within a game session. Codable so it can be
/// stored inside GameSession.
///
/// `correctAnswerText` and `userAnswerText` were added for the fraction overhaul
/// so that fraction answers ("3/4") can be displayed faithfully in stats. Both
/// are optional so existing stored sessions decode cleanly with `nil`.
struct ProblemResult: Codable, Identifiable {
    var id: UUID = UUID()
    let problemText: String

    /// Numeric value of the correct answer (back-compat with existing stats).
    let correctAnswer: Double

    /// Pre-formatted display string for the correct answer ("3/4", "0.75", "33.33%").
    let correctAnswerText: String?

    /// Numeric value of the user's answer, if parseable.
    let userAnswer: Double?

    /// What the user actually typed ("3/4", "0.75").
    let userAnswerText: String?

    let isCorrect: Bool
    let wasSkipped: Bool
    let operation: String          // MathOperation rawValue
    let timeTaken: TimeInterval    // seconds spent on this problem
}
