import Foundation
import SwiftData

enum GameState: Sendable {
    case countdown
    case playing
    case finished
}

enum FeedbackState: Sendable {
    case none
    case correct
    case wrong
}

/// Drives the game screen: generates problems, tracks time/score, handles both game modes.
@Observable
class GameViewModel {

    var state: GameState = .countdown
    var countdownValue: Int = AppConstants.countdownSeconds
    var currentProblem: Problem?
    var userAnswer: String = ""
    var score: Int = 0
    var totalAnswered: Int = 0
    var correctCount: Int = 0
    var skippedCount: Int = 0
    var timeRemaining: TimeInterval = 0
    var elapsedTime: TimeInterval = 0
    var problemResults: [ProblemResult] = []
    var feedbackState: FeedbackState = .none
    var isNewBestScore: Bool = false
    var isNewBestAccuracy: Bool = false

    // MARK: - Settings (copied at game start)
    private(set) var operations: [MathOperation] = []
    private(set) var difficulty: Difficulty = .range1to100
    private(set) var gameMode: GameMode = .timed
    private(set) var timerDuration: Int = 90
    private(set) var taskCount: Int = 20
    private(set) var decimalsEnabled: Bool = false
    private(set) var negativesEnabled: Bool = false
    private var soundEnabled: Bool = true
    private var hapticEnabled: Bool = true

    // MARK: - Internal
    private var generator = ProblemGenerator()
    private var difficultyEngine = DifficultyEngine()
    private var countdownTimer: Timer?
    private var gameTimer: Timer?
    private var problemStartTime: Date = .now

    // MARK: - Computed

    var accuracy: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(correctCount) / Double(totalAnswered)
    }

    var progress: Double {
        switch gameMode {
        case .timed:
            guard timerDuration > 0 else { return 0 }
            return max(0, timeRemaining / Double(timerDuration))
        case .taskCount:
            guard taskCount > 0 else { return 0 }
            return min(1.0, Double(totalAnswered) / Double(taskCount))
        }
    }

    var isUnlimitedTimer: Bool {
        gameMode == .timed && timerDuration == 0
    }

    // MARK: - Setup

    func configure(with settings: UserSettings) {
        operations = settings.operations
        difficulty = settings.difficultyLevel
        gameMode = settings.gameModeValue
        timerDuration = settings.timerDuration
        taskCount = settings.taskCount
        decimalsEnabled = settings.decimalsEnabled
        negativesEnabled = settings.negativesEnabled
        soundEnabled = settings.soundEnabled
        hapticEnabled = settings.hapticEnabled
        timeRemaining = Double(timerDuration)
        difficultyEngine.reset()
    }

    // MARK: - Game flow

    func startCountdown() {
        state = .countdown
        countdownValue = AppConstants.countdownSeconds

        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.countdownValue -= 1
            if self.hapticEnabled { HapticManager.shared.tick() }
            if self.soundEnabled { SoundManager.shared.countdownTickSound() }
            if self.countdownValue <= 0 {
                timer.invalidate()
                self.countdownTimer = nil
                self.startGame()
            }
        }
    }

    private func startGame() {
        state = .playing
        elapsedTime = 0
        if soundEnabled { SoundManager.shared.gameStartSound() }
        if hapticEnabled { HapticManager.shared.gameEvent() }
        nextProblem()
        startGameTimer()
    }

    private func startGameTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.tickGame()
        }
    }

    private func tickGame() {
        guard state == .playing else { return }
        elapsedTime += 0.1
        if gameMode == .timed && timerDuration > 0 {
            timeRemaining = max(0, Double(timerDuration) - elapsedTime)
            if timeRemaining <= 0 {
                endGame()
            }
        } else if gameMode == .timed {
            timeRemaining = elapsedTime
        }
    }

    func submitAnswer(settings: UserSettings) {
        guard state == .playing, let problem = currentProblem else { return }

        let timeTaken = Date.now.timeIntervalSince(problemStartTime)

        // Parse answer — treat empty as 0
        let cleanAnswer = userAnswer.isEmpty ? "0" : userAnswer
        guard let answer = Double(cleanAnswer) else { return }

        let correct = problem.isCorrect(userAnswer: answer)

        let result = ProblemResult(
            problemText: problem.text,
            correctAnswer: problem.correctAnswer,
            userAnswer: answer,
            isCorrect: correct,
            wasSkipped: false,
            operation: problem.operation.rawValue,
            timeTaken: timeTaken
        )
        problemResults.append(result)
        totalAnswered += 1

        if correct {
            correctCount += 1
            score += scoreForProblem(timeTaken: timeTaken)
            feedbackState = .correct
            if soundEnabled { SoundManager.shared.correctSound() }
            if hapticEnabled { HapticManager.shared.correct() }
        } else {
            feedbackState = .wrong
            if soundEnabled { SoundManager.shared.wrongSound() }
            if hapticEnabled { HapticManager.shared.wrong() }
        }

        if difficulty == .adaptive {
            difficultyEngine.recordResult(correct)
        }

        // Check if task count mode is done
        if gameMode == .taskCount && totalAnswered >= taskCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.endGame()
            }
            return
        }

        // Next problem after brief feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.advanceToNextProblem()
        }
    }

    func skipProblem() {
        guard state == .playing, let problem = currentProblem else { return }

        let timeTaken = Date.now.timeIntervalSince(problemStartTime)
        let result = ProblemResult(
            problemText: problem.text,
            correctAnswer: problem.correctAnswer,
            userAnswer: nil,
            isCorrect: false,
            wasSkipped: true,
            operation: problem.operation.rawValue,
            timeTaken: timeTaken
        )
        problemResults.append(result)
        totalAnswered += 1
        skippedCount += 1

        if hapticEnabled { HapticManager.shared.buttonTap() }

        if gameMode == .taskCount && totalAnswered >= taskCount {
            endGame()
            return
        }

        nextProblem()
    }

    private func advanceToNextProblem() {
        guard state == .playing else { return }
        feedbackState = .none
        nextProblem()
    }

    private func nextProblem() {
        userAnswer = ""
        currentProblem = generator.generate(
            operations: operations,
            difficulty: difficulty,
            difficultyEngine: difficultyEngine,
            decimalsEnabled: decimalsEnabled,
            negativesEnabled: negativesEnabled
        )
        problemStartTime = .now
    }

    func endGame() {
        guard state == .playing else { return }
        state = .finished
        gameTimer?.invalidate()
        gameTimer = nil
        if soundEnabled { SoundManager.shared.gameEndSound() }
        if hapticEnabled { HapticManager.shared.gameEvent() }
    }

    /// Save the completed session to SwiftData and check for personal bests.
    func saveSession(modelContext: ModelContext, settings: UserSettings) {
        let session = GameSession(
            date: .now,
            duration: elapsedTime,
            totalProblems: totalAnswered,
            correctAnswers: correctCount,
            skippedCount: skippedCount,
            operations: operations.map(\.rawValue),
            difficulty: difficulty.rawValue,
            gameMode: gameMode.rawValue
        )
        session.problemResults = problemResults
        modelContext.insert(session)

        if score > settings.bestScore {
            settings.bestScore = score
            isNewBestScore = true
        }
        if totalAnswered > 0 && accuracy > settings.bestAccuracy {
            settings.bestAccuracy = accuracy
            isNewBestAccuracy = true
        }

        try? modelContext.save()
    }

    // MARK: - Scoring

    private func scoreForProblem(timeTaken: TimeInterval) -> Int {
        let base = 10
        let speedBonus = max(0, Int((5.0 - timeTaken) * 2))
        return base + speedBonus
    }

    // MARK: - Input

    func appendDigit(_ digit: String) {
        guard userAnswer.count < AppConstants.maxAnswerLength else { return }
        if digit == "." && userAnswer.contains(".") { return }
        if digit == "-" {
            if userAnswer.isEmpty {
                userAnswer = "-"
            } else if userAnswer == "-" {
                userAnswer = ""
            }
            return
        }
        userAnswer += digit
        if hapticEnabled { HapticManager.shared.buttonTap() }
        if soundEnabled { SoundManager.shared.buttonSound() }
    }

    func deleteLastDigit() {
        guard !userAnswer.isEmpty else { return }
        userAnswer.removeLast()
        if hapticEnabled { HapticManager.shared.buttonTap() }
    }
}
