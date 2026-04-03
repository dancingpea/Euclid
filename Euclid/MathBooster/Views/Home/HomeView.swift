import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameSession.date, order: .reverse) private var sessions: [GameSession]
    @State private var settings: UserSettings?
    @State private var showGame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // App title
                VStack(spacing: 4) {
                    Text("Euclid")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Mental Math Training")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Quick stats
                if !sessions.isEmpty {
                    HStack(spacing: 20) {
                        StatBubble(
                            title: "Streak",
                            value: "\(sessions.currentStreak)",
                            icon: "flame.fill",
                            color: .orange
                        )
                        StatBubble(
                            title: "Accuracy",
                            value: sessions.allTimeAccuracy.percentString,
                            icon: "target",
                            color: .green
                        )
                        StatBubble(
                            title: "Sessions",
                            value: "\(sessions.count)",
                            icon: "number",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                }

                // Personal bests
                if let settings, (settings.bestScore > 0 || settings.bestAccuracy > 0) {
                    VStack(spacing: 8) {
                        Text("Personal Bests")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 16) {
                            if settings.bestScore > 0 {
                                Label("\(settings.bestScore) pts", systemImage: "trophy.fill")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.yellow)
                            }
                            if settings.bestAccuracy > 0 {
                                Label(settings.bestAccuracy.percentString, systemImage: "star.fill")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                // Start button — only enabled when settings are loaded
                Button {
                    if settings != nil {
                        showGame = true
                    }
                } label: {
                    Text("Start Training")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
                .padding(.horizontal, 32)
                .opacity(settings == nil ? 0.5 : 1.0)

                // Quick play
                Button {
                    if settings != nil {
                        showGame = true
                    }
                } label: {
                    Text("Quick Play")
                        .font(.subheadline)
                        .foregroundStyle(.indigo)
                }
                .padding(.bottom, 24)
            }
            .fullScreenCover(isPresented: $showGame) {
                if let settings {
                    GameView(settings: settings)
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        if let existing = results.first {
            settings = existing
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            settings = newSettings
        }
    }
}

// MARK: - Stat Bubble

struct StatBubble: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
