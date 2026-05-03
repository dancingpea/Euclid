import Foundation

/// Determines the active difficulty tier. For fixed tiers it just echoes the choice;
/// for adaptive mode it steps through `Difficulty.adaptiveLevels` based on recent accuracy.
class DifficultyEngine {
    private(set) var currentAdaptiveLevel: Difficulty = .range1to10
    private var recentResults: [Bool] = []
    private let windowSize = 10

    /// Resolve a (possibly adaptive) difficulty choice to a concrete fixed tier.
    /// Generators should always pass the resolved value to read both `operandRange`
    /// and `resultCap` consistently.
    func resolvedDifficulty(for difficulty: Difficulty) -> Difficulty {
        if difficulty == .adaptive {
            return currentAdaptiveLevel
        }
        return difficulty
    }

    /// Operand range for the (possibly adaptive) difficulty.
    func operandRange(for difficulty: Difficulty) -> (min: Int, max: Int) {
        resolvedDifficulty(for: difficulty).operandRange
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
        currentAdaptiveLevel = .range1to10
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
