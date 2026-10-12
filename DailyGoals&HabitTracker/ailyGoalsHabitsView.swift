import SwiftUI

struct ailyGoalsHabitsView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    var ailyGoalsEmbedded: Bool = false
    @State private var ailyGoalsShowForm = false
    @State private var ailyGoalsEditingHabit: ailyGoalsHabitModel?
    @State private var ailyGoalsHabitToDelete: ailyGoalsHabitModel?
    @State private var ailyGoalsSelectedHabit: ailyGoalsHabitModel?
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    var body: some View {
        Group {
            if ailyGoalsEmbedded {
                ailyGoalsContent
            } else {
                NavigationStack {
                    ailyGoalsContent
                        .navigationTitle("🔁 Habits")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    ailyGoalsShowForm = true
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .accessibilityLabel("Add Habit")
                            }
                        }
                }
            }
        }
    }

    private var ailyGoalsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if ailyGoalsEmbedded {
                    HStack {
                        Text("🔥 Keep your streaks alive")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                        Spacer()
                        Button {
                            ailyGoalsShowForm = true
                        } label: {
                            Label("Add", systemImage: "plus.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                } else {
                    Text("✨ Build consistency with habits that fit your schedule.")
                        .font(.system(size: 14))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                }
                if ailyGoalsViewModel.ailyGoalsActiveHabits.isEmpty {
                    ailyGoalsEmptyStateView(
                        ailyGoalsSymbol: "repeat",
                        ailyGoalsTitle: "No habits yet 🌱",
                        ailyGoalsMessage: "Create a habit to start tracking streaks and daily progress.",
                        ailyGoalsButtonTitle: "Add Habit"
                    ) { ailyGoalsShowForm = true }
                } else {
                    ForEach(ailyGoalsViewModel.ailyGoalsActiveHabits) { ailyGoalsHabit in
                        VStack(alignment: .leading, spacing: 10) {
                            ailyGoalsHabitRowView(
                                ailyGoalsHabit: ailyGoalsHabit,
                                ailyGoalsIsCompleted: ailyGoalsViewModel.ailyGoalsIsHabitCompleted(ailyGoalsHabit, on: Date()),
                                ailyGoalsProgress: ailyGoalsViewModel.ailyGoalsHabitProgress(ailyGoalsHabit, on: Date()),
                                ailyGoalsWeekDots: ailyGoalsViewModel.ailyGoalsWeekDots(for: ailyGoalsHabit),
                                ailyGoalsOnToggle: {
                                    withAnimation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion)) {
                                        ailyGoalsViewModel.ailyGoalsToggleHabitCompletion(ailyGoalsHabit.id)
                                    }
                                }
                            )
                            HStack(spacing: 16) {
                                Button {
                                    ailyGoalsSelectedHabit = ailyGoalsHabit
                                } label: {
                                    Label("History", systemImage: "calendar")
                                }
                                Button {
                                    ailyGoalsEditingHabit = ailyGoalsHabit
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button {
                                    ailyGoalsViewModel.ailyGoalsArchiveHabit(ailyGoalsHabit.id)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    ailyGoalsHabitToDelete = ailyGoalsHabit
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .accessibilityLabel("Delete habit")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
            .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
        }
        .background(Color.clear)
        .sheet(isPresented: $ailyGoalsShowForm) {
            ailyGoalsHabitFormView(ailyGoalsViewModel: ailyGoalsViewModel)
        }
        .sheet(item: $ailyGoalsEditingHabit) { ailyGoalsHabit in
            ailyGoalsHabitFormView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsExisting: ailyGoalsHabit)
        }
        .sheet(item: $ailyGoalsSelectedHabit) { ailyGoalsHabit in
            ailyGoalsHabitHistoryView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsHabit: ailyGoalsHabit)
        }
        .confirmationDialog("Delete Habit", isPresented: Binding(
            get: { ailyGoalsHabitToDelete != nil },
            set: { if !$0 { ailyGoalsHabitToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let ailyGoalsHabit = ailyGoalsHabitToDelete {
                    ailyGoalsViewModel.ailyGoalsDeleteHabit(ailyGoalsHabit.id)
                }
                ailyGoalsHabitToDelete = nil
            }
            Button("Cancel", role: .cancel) { ailyGoalsHabitToDelete = nil }
        }
    }
}

struct ailyGoalsHabitHistoryView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    let ailyGoalsHabit: ailyGoalsHabitModel
    @Environment(\.dismiss) private var ailyGoalsDismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("\(ailyGoalsHabit.ailyGoalsCurrentStreak) day streak", systemImage: "flame.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsWarning)
                        Spacer()
                        Text("Best \(ailyGoalsHabit.ailyGoalsBestStreak)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    }
                    .padding(14)
                    .ailyGoalsAppCard()

                    Text("📅 This week")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    ailyGoalsWeekDotsView(ailyGoalsDots: ailyGoalsViewModel.ailyGoalsWeekDots(for: ailyGoalsHabit))
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .ailyGoalsAppCard()

                    Text("🗓️ Last 28 days")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(0..<28, id: \.self) { ailyGoalsOffset in
                            let ailyGoalsDate = ailyGoalsDateHelpers.ailyGoalsAddDays(ailyGoalsOffset - 27, to: ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date()))
                            let ailyGoalsScheduled = ailyGoalsHabit.ailyGoalsIsScheduled(on: ailyGoalsDate)
                            let ailyGoalsCompleted = ailyGoalsViewModel.ailyGoalsIsHabitCompleted(ailyGoalsHabit, on: ailyGoalsDate)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(ailyGoalsCellColor(ailyGoalsScheduled: ailyGoalsScheduled, ailyGoalsCompleted: ailyGoalsCompleted))
                                .frame(height: 28)
                                .accessibilityLabel(ailyGoalsAccessibility(ailyGoalsDate: ailyGoalsDate, ailyGoalsScheduled: ailyGoalsScheduled, ailyGoalsCompleted: ailyGoalsCompleted))
                        }
                    }
                    .padding(12)
                    .ailyGoalsAppCard()
                    HStack(spacing: 12) {
                        ailyGoalsLegend(ailyGoalsColor: ailyGoalsAppTheme.ailyGoalsSuccess, ailyGoalsTitle: "Completed")
                        ailyGoalsLegend(ailyGoalsColor: ailyGoalsAppTheme.ailyGoalsSoftLavender, ailyGoalsTitle: "Missed")
                        ailyGoalsLegend(ailyGoalsColor: ailyGoalsAppTheme.ailyGoalsBorder, ailyGoalsTitle: "Off day")
                    }
                }
                .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
            }
            .background(ailyGoalsAppTheme.ailyGoalsBackground.ignoresSafeArea())
            .navigationTitle(ailyGoalsHabit.ailyGoalsName)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { ailyGoalsDismiss() }
                }
            }
        }
    }

    private func ailyGoalsCellColor(ailyGoalsScheduled: Bool, ailyGoalsCompleted: Bool) -> Color {
        if !ailyGoalsScheduled { return ailyGoalsAppTheme.ailyGoalsBorder.opacity(0.5) }
        if ailyGoalsCompleted { return ailyGoalsAppTheme.ailyGoalsSuccess }
        return ailyGoalsAppTheme.ailyGoalsSoftLavender
    }

    private func ailyGoalsAccessibility(ailyGoalsDate: Date, ailyGoalsScheduled: Bool, ailyGoalsCompleted: Bool) -> String {
        let ailyGoalsDay = ailyGoalsDateHelpers.ailyGoalsMediumDate.string(from: ailyGoalsDate)
        if !ailyGoalsScheduled { return "\(ailyGoalsDay), not scheduled" }
        return ailyGoalsCompleted ? "\(ailyGoalsDay), completed" : "\(ailyGoalsDay), missed"
    }

    private func ailyGoalsLegend(ailyGoalsColor: Color, ailyGoalsTitle: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3).fill(ailyGoalsColor).frame(width: 12, height: 12)
            Text(ailyGoalsTitle).font(.system(size: 12)).foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
        }
    }
}
