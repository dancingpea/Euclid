import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GameViewModel()
    let settings: UserSettings

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch viewModel.state {
            case .countdown:
                countdownView
            case .playing:
                gamePlayView
            case .finished:
                GameResultView(viewModel: viewModel, settings: settings) {
                    dismiss()
                }
            }
        }
        .onAppear {
            viewModel.configure(with: settings)
            viewModel.startCountdown()
        }
    }

    // MARK: - Countdown

    private var countdownView: some View {
        VStack {
            Spacer()
            Text("\(viewModel.countdownValue)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.indigo)
                .scaleEffect(viewModel.countdownValue > 0 ? 1.0 : 0.5)
                .animation(.easeOut(duration: 0.3), value: viewModel.countdownValue)
            Text("Get Ready!")
                .font(.title2)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Game play

    @State private var showEndConfirmation = false

    private var gamePlayView: some View {
        VStack(spacing: 16) {
            // Top bar: timer/progress + end/skip
            HStack {
                // End session button
                Button {
                    showEndConfirmation = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .alert("End Session?", isPresented: $showEndConfirmation) {
                    Button("Keep Going", role: .cancel) { }
                    Button("End", role: .destructive) {
                        viewModel.endGame()
                    }
                } message: {
                    Text("Your progress so far will be saved.")
                }

                Spacer()

                // Timer or task count
                if viewModel.gameMode == .timed {
                    if viewModel.isUnlimitedTimer {
                        Label(viewModel.elapsedTime.timerString, systemImage: "timer")
                            .font(.headline.monospacedDigit())
                    } else {
                        Label(viewModel.timeRemaining.timerString, systemImage: "timer")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(viewModel.timeRemaining < 10 ? .red : .primary)
                    }
                } else {
                    Text("\(viewModel.totalAnswered)/\(settings.taskCount)")
                        .font(.headline.monospacedDigit())
                }

                Spacer()

                Text("Score: \(viewModel.score)")
                    .font(.headline.monospacedDigit())

                Spacer()

                Button("Skip") {
                    viewModel.skipProblem()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Progress bar
            ProgressView(value: viewModel.progress)
                .tint(.indigo)
                .padding(.horizontal)

            Spacer()

            // Problem display
            if let problem = viewModel.currentProblem {
                VStack(spacing: 12) {
                    Text(problem.text)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    // Answer format preview
                    Text(problem.answerPlaceholder)
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.tertiary)
                }
                .padding()

                // User answer display
                Text(viewModel.userAnswer.isEmpty ? "?" : viewModel.userAnswer)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(feedbackColor)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.feedbackState)
                    .frame(height: 60)
            }

            Spacer()

            // Number pad
            AnswerInputView(viewModel: viewModel, settings: settings)
        }
        .padding(.vertical)
    }

    private var feedbackColor: Color {
        switch viewModel.feedbackState {
        case .none: return .primary
        case .correct: return .green
        case .wrong: return .red
        }
    }

}
