import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "chart.bar",
                        description: Text("Complete a training session to see your stats here.")
                    )
                } else {
                    statsList
                }
            }
            .navigationTitle("Stats")
            .onAppear {
                viewModel.loadSessions(modelContext: modelContext)
            }
        }
    }

    private var statsList: some View {
        List {
            // MARK: - Overview
            Section("Overview") {
                StatRow(label: "Total Sessions", value: "\(viewModel.totalSessions)")
                StatRow(label: "Problems Attempted", value: "\(viewModel.totalProblemsAttempted)")
                StatRow(label: "All-Time Accuracy", value: viewModel.allTimeAccuracy.percentString)
                StatRow(label: "Current Streak", value: "\(viewModel.currentStreak) days")
                StatRow(label: "Avg Tasks/Day", value: String(format: "%.1f", viewModel.averageTasksPerDay))
                StatRow(label: "Avg Tasks/Min", value: String(format: "%.1f", viewModel.averageTasksPerMinute))
            }

            // MARK: - Weekly accuracy chart
            Section("Weekly Accuracy") {
                Chart(viewModel.weeklyAccuracy, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Accuracy", item.accuracy * 100)
                    )
                    .foregroundStyle(.indigo.gradient)
                    .cornerRadius(4)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)%")
                            }
                        }
                    }
                }
                .frame(height: 180)
                .padding(.vertical, 8)
            }

            // MARK: - Operation breakdown
            if !viewModel.operationBreakdown.isEmpty {
                Section("By Operation") {
                    ForEach(viewModel.operationBreakdown, id: \.operation) { item in
                        HStack {
                            Text(item.operation)
                            Spacer()
                            Text("\(item.count) problems")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.accuracy.percentString)
                                .font(.subheadline.bold())
                                .foregroundStyle(item.accuracy >= 0.7 ? .green : (item.accuracy >= 0.4 ? .orange : .red))
                        }
                    }
                }
            }

            // MARK: - Recent sessions
            Section("Recent Sessions") {
                ForEach(viewModel.recentSessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.date.relativeDateString)
                                    .font(.subheadline.bold())
                                Text("\(session.totalProblems) problems - \(session.duration.timerString)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(session.accuracy.percentString)
                                .font(.subheadline.bold())
                                .foregroundStyle(session.accuracy >= 0.7 ? .green : .orange)
                        }
                    }
                }
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(.indigo)
        }
    }
}
