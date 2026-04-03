import Foundation

/// A single math problem presented to the user during a game session.
struct Problem: Identifiable {
    let id = UUID()
    let text: String
    let correctAnswer: Double
    let operation: MathOperation
    let expectedDigitCount: Int      // number of digits in the integer part
    let hasDecimals: Bool            // whether the answer has decimals
    let isNegative: Bool             // whether the answer is negative

    /// Checks the user's answer, allowing a small tolerance for decimals.
    func isCorrect(userAnswer: Double) -> Bool {
        abs(correctAnswer - userAnswer) < 0.01
    }

    /// Returns a placeholder string showing the expected format.
    /// e.g. "_ _ _" or "- _ _ . _ _"
    var answerPlaceholder: String {
        var parts: [String] = []

        if isNegative {
            parts.append("-")
        }

        let digitSlots = max(1, expectedDigitCount)
        parts.append(Array(repeating: "_", count: digitSlots).joined(separator: " "))

        if hasDecimals {
            parts.append(".")
            parts.append("_ _")
        }

        return parts.joined(separator: " ")
    }
}
