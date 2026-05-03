import Foundation
import SwiftData

enum GameState: Sendable {
    case countdown
    case playing
    case finished
}

enum FeedbackState: Sendable, Equatable {
    case none
    case correct
    case wrong(correctAnswer: String)
    case skipped(correctAnswer: String)
}

/// User-input state, supporting both the existing single-field numpad input
/// and the new two-field fraction input (numerator + denominator).
enum UserInputState: Equatable {
    case single(String)
    case fraction(numerator: String, denominator: String, active: FractionField)

    enum FractionField: Equatable {
        case numerator
        case denominator
    }
}

/// Drives the game screen: generates problems, tracks time/score, handles both game modes.
@Observable
class GameViewModel {

    var state: GameState = .countdown
    var countdownValue: Int = AppConstants.countdownSeconds
    var currentProblem: Problem?

    /// Rich input state. Use `userAnswer` for a flat display string.
    var userInput: UserInputState = .single("")

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
    private(set) var difficulty: Difficulty = .range1to10
    private(set) var gameMode: GameMode = .timed
    private(set) var timerDuration: Int = 90
    private(set) var taskCount: Int = 20
    private(set) var decimalsEnabled: Bool = false
    private(set) var negativesEnabled: Bool = false
    private(set) var showCorrectAnswerOnMistake: Bool = true
    private var soundEnabled: Bool = true
    private var hapticEnabled: Bool = true

    // MARK: - Internal
    private var generator = ProblemGenerator()
    private var difficultyEngine = DifficultyEngine()
    private var countdownTimer: Timer?
    private var gameTimer: Timer?
    private var problemStartTime: Date = .now

    // MARK: - Computed

    /// Display string for the user's current input. GameView uses this to render
    /// the typed answer (so changing the underlying state didn't require touching GameView).
    var userAnswer: String {
        switch userInput {
        case .single(let text):
            return text
        case .fraction(let num, let den, _):
            if num.isEmpty && den.isEmpty { return "" }
            if den.isEmpty { return num }
            if num.isEmpty { return "/\(den)" }
            return "\(num)/\(den)"
        }
    }

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
        showCorrectAnswerOnMistake = settings.showCorrectAnswerOnMistake
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
        if showCorrectAnswerOnMistake {
            if case .wrong = feedbackState { return }
            if case .skipped = feedbackState { return }
        }
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

        // Bail on unparseable single-mode input (preserves the original behavior
        // where typing only "-" doesn't submit anything).
        if case .single(let text) = userInput, !text.isEmpty, Double(text) == nil {
            return
        }

        let timeTaken = Date.now.timeIntervalSince(problemStartTime)
        let parsed = parseUserInput()
        let correct = problem.isCorrect(input: parsed.input)

        let result = ProblemResult(
            problemText: problem.text,
            correctAnswer: problem.correctAnswer,
            correctAnswerText: problem.displayAnswer,
            userAnswer: parsed.numeric,
            userAnswerText: parsed.display.isEmpty ? nil : parsed.display,
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
            feedbackState = .wrong(correctAnswer: problem.displayAnswer)
            if soundEnabled { SoundManager.shared.wrongSound() }
            if hapticEnabled { HapticManager.shared.wrong() }
        }

        if difficulty == .adaptive {
            difficultyEngine.recordResult(correct)
        }

        let feedbackDuration: TimeInterval
        if correct {
            feedbackDuration = 0.4
        } else {
            feedbackDuration = showCorrectAnswerOnMistake ? 1.2 : 0.4
        }

        if gameMode == .taskCount && totalAnswered >= taskCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDuration) { [weak self] in
                self?.endGame()
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDuration) { [weak self] in
            self?.advanceToNextProblem()
        }
    }

    /// Convert the current `userInput` state into the three values the rest of
    /// the pipeline needs: a `UserAnswerInput` for `Problem.isCorrect`, a Double?
    /// for stats, and a String for display in feedback / stats.
    private func parseUserInput() -> (input: UserAnswerInput, numeric: Double?, display: String) {
        switch userInput {
        case .single(let text):
            let cleanText = text.isEmpty ? "0" : text
            return (.single(cleanText), Double(cleanText), text)

        case .fraction(let num, let den, _):
            let display: String
            if num.isEmpty && den.isEmpty { display = "" }
            else if den.isEmpty { display = num }
            else if num.isEmpty { display = "/\(den)" }
            else { display = "\(num)/\(den)" }

            let numeric: Double?
            if den.isEmpty {
                numeric = Double(num)
            } else if let n = Double(num), let d = Double(den), d != 0 {
                numeric = n / d
            } else {
                numeric = nil
            }

            return (.fraction(numerator: num, denominator: den), numeric, display)
        }
    }

    func skipProblem() {
        guard state == .playing, let problem = currentProblem else { return }

        let timeTaken = Date.now.timeIntervalSince(problemStartTime)
        let result = ProblemResult(
            problemText: problem.text,
            correctAnswer: problem.correctAnswer,
            correctAnswerText: problem.displayAnswer,
            userAnswer: nil,
            userAnswerText: nil,
            isCorrect: false,
            wasSkipped: true,
            operation: problem.operation.rawValue,
            timeTaken: timeTaken
        )
        problemResults.append(result)
        totalAnswered += 1
        skippedCount += 1

        if hapticEnabled { HapticManager.shared.buttonTap() }

        guard showCorrectAnswerOnMistake else {
            if gameMode == .taskCount && totalAnswered >= taskCount {
                endGame()
                return
            }
            nextProblem()
            return
        }

        feedbackState = .skipped(correctAnswer: problem.displayAnswer)

        let feedbackDuration: TimeInterval = 1.2

        if gameMode == .taskCount && totalAnswered >= taskCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDuration) { [weak self] in
                self?.endGame()
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDuration) { [weak self] in
            self?.advanceToNextProblem()
        }
    }

    private func advanceToNextProblem() {
        guard state == .playing else { return }
        feedbackState = .none
        nextProblem()
    }

    private func nextProblem() {
        currentProblem = generator.generate(
            operations: operations,
            difficulty: difficulty,
            difficultyEngine: difficultyEngine,
            decimalsEnabled: decimalsEnabled,
            negativesEnabled: negativesEnabled
        )
        // Reset input state to match the new problem's input kind.
        if let kind = currentProblem?.inputKind {
            switch kind {
            case .singleField:
                userInput = .single("")
            case .twoFieldFraction:
                userInput = .fraction(numerator: "", denominator: "", active: .numerator)
            }
        } else {
            userInput = .single("")
        }
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
        switch userInput {
        case .single(var text):
            guard text.count < AppConstants.maxAnswerLength else { return }
            if digit == "." && text.contains(".") { return }
            if digit == "-" {
                if text.isEmpty {
                    text = "-"
                } else if text == "-" {
                    text = ""
                }
                userInput = .single(text)
                playButtonFeedback()
                return
            }
            text += digit
            userInput = .single(text)
            playButtonFeedback()

        case .fraction(var num, var den, let active):
            // No negative sign in fraction mode.
            if digit == "-" { return }
            switch active {
            case .numerator:
                guard num.count < AppConstants.maxAnswerLength else { return }
                if digit == "." && num.contains(".") { return }
                num += digit
            case .denominator:
                guard den.count < AppConstants.maxAnswerLength else { return }
                if digit == "." && den.contains(".") { return }
                den += digit
            }
            userInput = .fraction(numerator: num, denominator: den, active: active)
            playButtonFeedback()
        }
    }

    func deleteLastDigit() {
        switch userInput {
        case .single(var text):
            guard !text.isEmpty else { return }
            text.removeLast()
            userInput = .single(text)
        case .fraction(var num, var den, let active):
            switch active {
            case .numerator:
                guard !num.isEmpty else { return }
                num.removeLast()
            case .denominator:
                guard !den.isEmpty else { return }
                den.removeLast()
            }
            userInput = .fraction(numerator: num, denominator: den, active: active)
        }
        if hapticEnabled { HapticManager.shared.buttonTap() }
    }

    /// Switch the active field in two-field fraction input mode. No-op otherwise.
    func setActiveField(_ field: UserInputState.FractionField) {
        if case .fraction(let num, let den, _) = userInput {
            userInput = .fraction(numerator: num, denominator: den, active: field)
        }
    }

    private func playButtonFeedback() {
        if hapticEnabled { HapticManager.shared.buttonTap() }
        if soundEnabled { SoundManager.shared.buttonSound() }
    }
}
