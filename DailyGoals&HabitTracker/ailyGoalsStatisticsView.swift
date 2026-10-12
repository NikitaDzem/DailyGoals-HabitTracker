import SwiftUI
import Charts

struct ailyGoalsStatisticsView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsRange: ailyGoalsStatsRange = .ailyGoalsSevenDays

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ailyGoalsStatsRange.allCases) { ailyGoalsItem in
                            ailyGoalsFilterChip(
                                ailyGoalsTitle: ailyGoalsItem.ailyGoalsTitle,
                                ailyGoalsIsSelected: ailyGoalsRange == ailyGoalsItem
                            ) { ailyGoalsRange = ailyGoalsItem }
                        }
                    }
                }

                let ailyGoalsTaskRate = ailyGoalsViewModel.ailyGoalsTaskCompletionRate(ailyGoalsRange: ailyGoalsRange)
                let ailyGoalsHabitRate = ailyGoalsViewModel.ailyGoalsWeeklyHabitRate()
                let ailyGoalsHasTasks = !ailyGoalsViewModel.ailyGoalsTasks.isEmpty
                let ailyGoalsHasHabits = !ailyGoalsViewModel.ailyGoalsActiveHabits.isEmpty
                let ailyGoalsBest = ailyGoalsViewModel.ailyGoalsActiveHabits.map(\.ailyGoalsBestStreak).max() ?? 0
                let ailyGoalsCurrent = ailyGoalsViewModel.ailyGoalsActiveHabits.map(\.ailyGoalsCurrentStreak).max() ?? 0
                let ailyGoalsActiveGoals = ailyGoalsViewModel.ailyGoalsActiveGoals.count
                let ailyGoalsCompletedGoals = ailyGoalsViewModel.ailyGoalsGoals.filter { $0.ailyGoalsStatus == .ailyGoalsCompleted }.count

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ailyGoalsStatCard(
                        ailyGoalsTitle: "Tasks completed",
                        ailyGoalsValue: "\(ailyGoalsViewModel.ailyGoalsTasksCompletedCount(ailyGoalsRange: ailyGoalsRange))",
                        ailyGoalsSymbol: "checkmark.circle"
                    )
                    ailyGoalsStatCard(
                        ailyGoalsTitle: "Task rate",
                        ailyGoalsValue: ailyGoalsHasTasks ? "\(Int((ailyGoalsTaskRate * 100).rounded()))%" : "—",
                        ailyGoalsSymbol: "chart.pie"
                    )
                    ailyGoalsStatCard(
                        ailyGoalsTitle: "Habit rate",
                        ailyGoalsValue: ailyGoalsHasHabits ? "\(Int((ailyGoalsHabitRate * 100).rounded()))%" : "—",
                        ailyGoalsSymbol: "repeat"
                    )
                    ailyGoalsStatCard(
                        ailyGoalsTitle: "Active goals",
                        ailyGoalsValue: "\(ailyGoalsActiveGoals)",
                        ailyGoalsSymbol: "target"
                    )
                    ailyGoalsStatCard(
                        ailyGoalsTitle: "Completed goals",
                        ailyGoalsValue: "\(ailyGoalsCompletedGoals)",
                        ailyGoalsSymbol: "flag.checkered"
                    )
                    ailyGoalsStatCard(
                        ailyGoalsTitle: "Streak",
                        ailyGoalsValue: ailyGoalsHasHabits ? "\(ailyGoalsCurrent)/\(ailyGoalsBest)" : "—",
                        ailyGoalsSymbol: "flame"
                    )
                }

                let ailyGoalsStats = ailyGoalsViewModel.ailyGoalsDayStats(ailyGoalsRange: ailyGoalsRange)
                let ailyGoalsHasTaskData = ailyGoalsStats.contains { $0.ailyGoalsTasksCompleted > 0 }
                let ailyGoalsHasHabitData = ailyGoalsStats.contains { $0.ailyGoalsHabitsCompleted > 0 }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Task completion")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    if ailyGoalsHasTaskData {
                        Chart(ailyGoalsStats) { ailyGoalsItem in
                            BarMark(
                                x: .value("Day", ailyGoalsItem.ailyGoalsDate, unit: .day),
                                y: .value("Tasks", ailyGoalsItem.ailyGoalsTasksCompleted)
                            )
                            .foregroundStyle(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                        }
                        .frame(height: 180)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.narrow))
                            }
                        }
                    } else {
                        Text("No completed tasks in this period yet.")
                            .font(.system(size: 14))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(16)
                .ailyGoalsAppCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Habit consistency")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    if ailyGoalsHasHabitData {
                        Chart(ailyGoalsStats) { ailyGoalsItem in
                            LineMark(
                                x: .value("Day", ailyGoalsItem.ailyGoalsDate, unit: .day),
                                y: .value("Habits", ailyGoalsItem.ailyGoalsHabitsCompleted)
                            )
                            .foregroundStyle(ailyGoalsAppTheme.ailyGoalsAccentBlue)
                            .interpolationMethod(.catmullRom)
                            AreaMark(
                                x: .value("Day", ailyGoalsItem.ailyGoalsDate, unit: .day),
                                y: .value("Habits", ailyGoalsItem.ailyGoalsHabitsCompleted)
                            )
                            .foregroundStyle(ailyGoalsAppTheme.ailyGoalsAccentBlue.opacity(0.15))
                        }
                        .frame(height: 180)
                    } else {
                        Text("Complete habits to reveal consistency trends.")
                            .font(.system(size: 14))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(16)
                .ailyGoalsAppCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Goal progress overview")
                        .font(.system(size: 18, weight: .semibold))
                    if ailyGoalsViewModel.ailyGoalsGoals.isEmpty {
                        Text("No goals yet. Create a goal to track long-term progress.")
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    } else {
                        ForEach(ailyGoalsViewModel.ailyGoalsGoals.prefix(5)) { ailyGoalsGoal in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(ailyGoalsGoal.ailyGoalsTitle)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                                    Spacer()
                                    Text("\(ailyGoalsGoal.ailyGoalsProgressPercent)%")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                                }
                                ProgressView(value: ailyGoalsGoal.ailyGoalsProgressFraction)
                                    .tint(ailyGoalsAppTheme.ailyGoalsAccentBlue)
                            }
                        }
                    }
                }
                .padding(16)
                .ailyGoalsAppCard()
            }
            .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
        }
        .background(ailyGoalsAppTheme.ailyGoalsBackground.ignoresSafeArea())
        .navigationTitle("Statistics")
    }

    private func ailyGoalsStatCard(ailyGoalsTitle: String, ailyGoalsValue: String, ailyGoalsSymbol: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: ailyGoalsSymbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                .frame(width: 28, height: 28)
                .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(ailyGoalsTitle)
                .font(.system(size: 12))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
            Text(ailyGoalsValue)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ailyGoalsAppCard()
    }
}
