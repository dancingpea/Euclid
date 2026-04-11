import SwiftUI

struct TipsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lightbulb.max.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.yellow)

                        Text("Mental Math Tips")
                            .font(.title.bold())

                        Text("Techniques to sharpen your skills, from beginner tricks to competition methods.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)

                    // Categories
                    ForEach(TipsData.categories) { category in
                        CategorySection(category: category)
                    }

                    // Credit footer
                    VStack(spacing: 8) {
                        Text(TipsData.creditText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Link(destination: TipsData.creditURL) {
                            HStack(spacing: 4) {
                                Text("Visit the blog")
                                    .font(.caption.bold())
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                            .foregroundStyle(.indigo)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

// MARK: - Category Section

private struct CategorySection: View {
    let category: TipCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(.indigo)
                Text(category.name)
                    .font(.title3.bold())
            }
            .padding(.horizontal)

            // Tip cards
            ForEach(category.tips) { tip in
                NavigationLink {
                    TipDetailView(tip: tip, categoryName: category.name)
                } label: {
                    TipCard(tip: tip)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Tip Card

private struct TipCard: View {
    let tip: Tip

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(tip.level.rawValue)
                    .font(.caption)
                    .foregroundStyle(levelColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(levelColor.opacity(0.12), in: Capsule())
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    private var levelColor: Color {
        switch tip.level {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

#Preview {
    TipsView()
}
