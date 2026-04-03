import SwiftUI

struct SessionDetailView: View {
    let session: GameSession

    var body: some View {
        List {
            Section("Summary") {
                StatRow(label: "Date", value: session.date.relativeDateString)
                StatRow(label: "Duration", value: session.duration.timerString)
                StatRow(label: "Mode", value: (GameMode(rawValue: session.gameMode) ?? .timed).displayName)
                StatRow(label: "Difficulty", value: (Difficulty(rawValue: session.difficulty) ?? .range1to100).displayName)
                StatRow(label: "Problems", value: "\(session.totalProblems)")
                StatRow(label: "Correct", value: "\(session.correctAnswers)")
                StatRow(label: "Skipped", value: "\(session.skippedCount)")
                StatRow(label: "Accuracy", value: session.accuracy.percentString)
                StatRow(label: "Tasks/Min", value: String(format: "%.1f", session.tasksPerMinute))
            }

            if !session.problemResults.isEmpty {
                Section("Problems") {
                    ForEach(session.problemResults) { result in
                        HStack {
                            Image(systemName: result.wasSkipped ? "forward.fill" : (result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"))
                                .foregroundStyle(result.wasSkipped ? .orange : (result.isCorrect ? .green : .red))
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.problemText)
                                    .font(.subheadline)
                                if result.wasSkipped {
                                    Text("Skipped - Answer: \(result.correctAnswer.cleanString)")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                } else if !result.isCorrect {
                                    Text("Your answer: \(result.userAnswer.map { $0.cleanString } ?? "?") - Correct: \(result.correctAnswer.cleanString)")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }

                            Spacer()

                            Text(String(format: "%.1fs", result.timeTaken))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Session Detail")
    }
}
