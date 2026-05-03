import Foundation

/// Difficulty levels combine an operand range with a hard cap on the absolute value of the answer.
/// The generator samples operands in `operandRange` and rejects any candidate whose
/// `abs(answer)` exceeds `resultCap`, so a tier always honors what its name promises.
enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case range1to10
    case range1to100
    case range1to1000
    case adaptive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .range1to10:   return "Easy"
        case .range1to100:  return "Medium"
        case .range1to1000: return "Hard"
        case .adaptive:     return "Adaptive"
        }
    }

    var description: String {
        switch self {
        case .range1to10:   return "Single-digit operations (1–10)"
        case .range1to100:  return "Two-digit operations (1–100)"
        case .range1to1000: return "Three-digit operations (1–1,000)"
        case .adaptive:     return "Starts easy, gets harder as you improve"
        }
    }

    var iconName: String {
        switch self {
        case .range1to10:   return "1.circle"
        case .range1to100:  return "2.circle"
        case .range1to1000: return "3.circle"
        case .adaptive:     return "brain"
        }
    }

    /// Operand range used when sampling the operands of a problem.
    var operandRange: (min: Int, max: Int) {
        switch self {
        case .range1to10:   return (1, 10)
        case .range1to100:  return (1, 100)
        case .range1to1000: return (1, 1000)
        case .adaptive:     return (1, 10) // starting range; engine swaps in the active tier
        }
    }

    /// Hard cap on `abs(answer)`. Generators reject any candidate that exceeds this.
    /// Subtraction and fraction are operand- or denominator-bounded instead, so this cap
    /// is largely informational for those operations.
    var resultCap: Int {
        switch self {
        case .range1to10:   return 100
        case .range1to100:  return 1000
        case .range1to1000: return 99999
        case .adaptive:     return 100 // starting cap; engine swaps in the active tier
        }
    }

    /// The ordered list of fixed difficulties for adaptive stepping.
    static var adaptiveLevels: [Difficulty] {
        [.range1to10, .range1to100, .range1to1000]
    }
}
