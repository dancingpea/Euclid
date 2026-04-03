import SwiftUI
import SwiftData

struct GameResultView: View {
    @Environment(\.modelContext) private var modelContext
    let viewModel: GameViewModel
    let settings: UserSettings
    let onDismiss: () -> Void

    @State private var hasSaved = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Session Complete!")
                    .font(.title.bold())
                    .padding(.top, 32)

                // Score
                VStack(spacing: 8) {
                    Text("\(viewModel.score)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                    Text("points")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Personal best badges
                if viewModel.isNewBestScore {
                    Label("New Best Score!", systemImage: "trophy.fill")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                        .padding(8)
                        .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                }
                if viewModel.isNewBestAccuracy {
                    Label("New Best Accuracy!", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                        .padding(8)
                        .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                }

                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ResultStat(label: "Problems", value: "\(viewModel.totalAnswered)")
                    ResultStat(label: "Correct", value: "\(viewModel.correctCount)")
                    ResultStat(label: "Accuracy", value: viewModel.accuracy.percentString)
                    ResultStat(label: "Skipped", value: "\(viewModel.skippedCount)")
                    ResultStat(label: "Time", value: viewModel.elapsedTime.timerString)
                    ResultStat(label: "Tasks/min", value: String(format: "%.1f", viewModel.totalAnswered > 0 ? Double(viewModel.totalAnswered) / (viewModel.elapsedTime / 60.0) : 0))
                }
                .padding(.horizontal)

                // Problem breakdown
                if !viewModel.problemResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Problem Breakdown")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(viewModel.problemResults) { result in
                            HStack {
                                Image(systemName: result.wasSkipped ? "forward.fill" : (result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"))
                                    .foregroundStyle(result.wasSkipped ? .orange : (result.isCorrect ? .green : .red))

                                Text(result.problemText)
                                    .font(.subheadline)

                                Spacer()

                                if result.wasSkipped {
                                    Text("Skipped")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                } else {
                                    Text(result.isCorrect ? result.correctAnswer.cleanString : "\(result.userAnswer.map { $0.cleanString } ?? "?") (was \(result.correctAnswer.cleanString))")
                                        .font(.caption)
                                        .foregroundStyle(result.isCorrect ? .green : .red)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Done button
                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.indigo, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            if !hasSaved {
                viewModel.saveSession(modelContext: modelContext, settings: settings)
                hasSaved = true
            }
        }
    }
}

struct ResultStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
