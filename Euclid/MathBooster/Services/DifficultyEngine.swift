import Foundation

/// Determines operand ranges based on the current difficulty level.
/// For adaptive mode, steps through the 3 fixed tiers based on recent accuracy.
class DifficultyEngine {
    private(set) var currentAdaptiveLevel: Difficulty = .range1to100
    private var recentResults: [Bool] = []
    private let windowSize = 10

    /// The operand range for the given difficulty.
    func operandRange(for difficulty: Difficulty) -> (min: Int, max: Int) {
        if difficulty == .adaptive {
            return currentAdaptiveLevel.operandRange
        }
        return difficulty.operandRange
    }

    /// Feed a result (correct/wrong) to update adaptive difficulty.
    func recordResult(_ correct: Bool) {
        recentResults.append(correct)
        if recentResults.count > windowSize {
            recentResults.removeFirst()
        }
        updateAdaptiveLevel()
    }

    /// Reset adaptive state for a new game.
    func reset() {
        recentResults = []
        currentAdaptiveLevel = .range1to100
    }

    // MARK: - Private

    private func updateAdaptiveLevel() {
        guard recentResults.count >= windowSize else { return }

        let accuracy = Double(recentResults.filter { $0 }.count) / Double(recentResults.count)
        let levels = Difficulty.adaptiveLevels
        guard let currentIndex = levels.firstIndex(of: currentAdaptiveLevel) else { return }

        if accuracy > 0.85 && currentIndex < levels.count - 1 {
            currentAdaptiveLevel = levels[currentIndex + 1]
            recentResults = []
        } else if accuracy < 0.50 && currentIndex > 0 {
            currentAdaptiveLevel = levels[currentIndex - 1]
            recentResults = []
        }
    }
}
