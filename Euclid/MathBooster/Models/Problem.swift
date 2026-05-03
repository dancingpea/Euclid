import Foundation

/// A single math problem presented to the user during a game session.
struct Problem: Identifiable {
    let id = UUID()
    let text: String
    let operation: MathOperation

    /// Which input UI this problem expects (single numpad vs. two-field fraction).
    let inputKind: InputKind

    /// What constitutes a correct answer.
    let answer: AnswerSpec

    /// Numeric value of the answer — kept for stats/storage backward compatibility.
    /// For fraction answers, this is `numerator / denominator` as a Double.
    let correctAnswer: Double

    /// Pre-formatted display string used in feedback banners ("3/4", "0.75", "33.33%").
    let displayAnswer: String

    // Legacy placeholder hints — only used when `inputKind == .singleField`.
    let expectedDigitCount: Int
    let hasDecimals: Bool
    let isNegative: Bool

    // MARK: - Input kind

    enum InputKind: Equatable {
        /// One numeric input (the existing numpad behavior).
        case singleField

        /// Stacked numerator + denominator. `allowEmptyDenominator` is true for the
        /// fraction-calculation mode where the user may instead type a single
        /// decimal/percentage value into the numerator and leave the denominator empty.
        case twoFieldFraction(allowEmptyDenominator: Bool)
    }

    // MARK: - Answer spec

    enum AnswerSpec {
        /// Numeric answer; correct if `|user - value| < tolerance`.
        case number(value: Double, tolerance: Double)

        /// Fraction answer; correct only if the user's input is exactly equivalent
        /// AND in lowest terms (gcd(numerator, denominator) == 1).
        case fraction(numerator: Int, denominator: Int)

        /// Either an exactly-equivalent simplified fraction, OR a decimal/percentage
        /// value within tolerance of the canonical decimal value. When the user fills
        /// only the numerator field, it's interpreted as either a decimal or a
        /// percentage and the closer interpretation wins.
        case fractionOrEquivalent(numerator: Int, denominator: Int)
    }

    // MARK: - Correctness

    /// Tolerance for the decimal interpretation in `.fractionOrEquivalent`.
    private static let decimalTolerance = 0.01
    /// Tolerance for the percent interpretation in `.fractionOrEquivalent`.
    private static let percentTolerance = 0.5

    func isCorrect(input: UserAnswerInput) -> Bool {
        switch (answer, input) {

        case let (.number(value, tol), .single(text)):
            guard let user = Double(text) else { return false }
            return abs(user - value) < tol

        case (.number, .fraction):
            // Single-field problems don't accept fraction input.
            return false

        case let (.fraction(n, d), .fraction(userNumStr, userDenStr)):
            guard let userNum = Int(userNumStr),
                  let userDen = Int(userDenStr),
                  userDen != 0 else { return false }
            // Must be in lowest terms.
            guard Self.gcd(abs(userNum), abs(userDen)) == 1 else { return false }
            // Must be exactly equivalent: n × userDen == userNum × d.
            return n * userDen == userNum * d

        case (.fraction, .single):
            // Fraction-only problems require both fields to be filled.
            return false

        case let (.fractionOrEquivalent(n, d), .fraction(userNumStr, userDenStr)):
            // If the denominator field is empty, treat the numerator as decimal/percent.
            if userDenStr.isEmpty {
                return Self.matchesAsDecimalOrPercent(userText: userNumStr,
                                                     numerator: n,
                                                     denominator: d)
            }
            // Otherwise validate as a fraction (must be simplified, exactly equivalent).
            guard let userNum = Int(userNumStr),
                  let userDen = Int(userDenStr),
                  userDen != 0 else { return false }
            guard Self.gcd(abs(userNum), abs(userDen)) == 1 else { return false }
            return n * userDen == userNum * d

        case let (.fractionOrEquivalent(n, d), .single(text)):
            return Self.matchesAsDecimalOrPercent(userText: text,
                                                 numerator: n,
                                                 denominator: d)
        }
    }

    private static func matchesAsDecimalOrPercent(userText: String,
                                                  numerator: Int,
                                                  denominator: Int) -> Bool {
        guard let user = Double(userText) else { return false }
        let canonical = Double(numerator) / Double(denominator)
        // Try both interpretations: decimal and percentage.
        return abs(user - canonical) < decimalTolerance
            || abs(user - canonical * 100) < percentTolerance
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = abs(a), y = abs(b)
        while y != 0 { (x, y) = (y, x % y) }
        return x
    }

    // MARK: - Placeholder

    /// Returns a placeholder string showing the expected format. Only meaningful when
    /// `inputKind == .singleField`; fraction-input problems render their own UI in
    /// `AnswerInputView` and this returns an empty string.
    var answerPlaceholder: String {
        if case .twoFieldFraction = inputKind { return "" }

        var parts: [String] = []
        if isNegative { parts.append("-") }
        let digitSlots = max(1, expectedDigitCount)
        parts.append(Array(repeating: "_", count: digitSlots).joined(separator: " "))
        if hasDecimals {
            parts.append(".")
            parts.append("_ _")
        }
        return parts.joined(separator: " ")
    }
}

/// What the user has typed into the input UI, normalized for `Problem.isCorrect`.
enum UserAnswerInput {
    case single(String)
    case fraction(numerator: String, denominator: String)
}
