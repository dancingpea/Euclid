import Foundation

/// The two game modes available.
enum GameMode: String, CaseIterable, Codable, Identifiable {
    case timed          // play until the timer runs out
    case taskCount      // play a fixed number of problems

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .timed:     return "Timed"
        case .taskCount: return "Number of Tasks"
        }
    }

    var iconName: String {
        switch self {
        case .timed:     return "timer"
        case .taskCount: return "number.circle"
        }
    }

    var description: String {
        switch self {
        case .timed:     return "Solve as many as you can before time runs out"
        case .taskCount: return "Solve a fixed number of problems"
        }
    }
}
