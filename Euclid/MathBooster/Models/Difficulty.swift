import Foundation

/// Difficulty levels based on operand ranges.
enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case range1to100
    case range100to1000
    case range1000to10000
    case adaptive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .range1to100:      return "1 - 100"
        case .range100to1000:   return "100 - 1,000"
        case .range1000to10000: return "1,000 - 10,000"
        case .adaptive:         return "Adaptive"
        }
    }

    var description: String {
        switch self {
        case .range1to100:      return "Numbers between 1 and 100"
        case .range100to1000:   return "Numbers between 100 and 1,000"
        case .range1000to10000: return "Numbers between 1,000 and 10,000"
        case .adaptive:         return "Starts easy, gets harder as you improve"
        }
    }

    var iconName: String {
        switch self {
        case .range1to100:      return "1.circle"
        case .range100to1000:   return "2.circle"
        case .range1000to10000: return "3.circle"
        case .adaptive:         return "brain"
        }
    }

    /// The operand range for this difficulty.
    var operandRange: (min: Int, max: Int) {
        switch self {
        case .range1to100:      return (1, 100)
        case .range100to1000:   return (100, 1000)
        case .range1000to10000: return (1000, 10000)
        case .adaptive:         return (1, 100) // starting range
        }
    }

    /// The ordered list of fixed difficulties for adaptive stepping.
    static var adaptiveLevels: [Difficulty] {
        [.range1to100, .range100to1000, .range1000to10000]
    }
}
