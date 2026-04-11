import SwiftUI

struct TipDetailView: View {
    let tip: Tip
    let categoryName: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoryName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(tip.title)
                        .font(.title.bold())

                    Text(tip.level.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(levelColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(levelColor.opacity(0.12), in: Capsule())
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Explanation
                Text(tip.explanation)
                    .font(.body)
                    .lineSpacing(4)
                    .padding(.horizontal)

                // Examples
                if !tip.examples.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(tip.examples.count == 1 ? "Example" : "Examples")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(Array(tip.examples.enumerated()), id: \.offset) { _, example in
                            ExampleCard(example: example)
                        }
                    }
                }

                Spacer(minLength: 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var levelColor: Color {
        switch tip.level {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Example Card

private struct ExampleCard: View {
    let example: TipExample

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Problem
            Text(example.problem)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.indigo)

            // Steps
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(example.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 20, alignment: .trailing)

                        Text(step)
                            .font(.subheadline)
                    }
                }
            }

            // Result
            HStack(spacing: 6) {
                Image(systemName: "equal.circle.fill")
                    .foregroundStyle(.green)
                Text(example.result)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        TipDetailView(
            tip: TipsData.categories[2].tips[4],
            categoryName: "Multiplication"
        )
    }
}
