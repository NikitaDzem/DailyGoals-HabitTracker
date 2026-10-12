import SwiftUI

struct ailyGoalsTodayView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsFilter: ailyGoalsTaskFilter = .ailyGoalsAll
    @State private var ailyGoalsShowTaskForm = false
    @State private var ailyGoalsShowHabitForm = false
    @State private var ailyGoalsShowGoalForm = false
    @State private var ailyGoalsEditingTask: ailyGoalsTaskItem?
    @State private var ailyGoalsTaskToDelete: ailyGoalsTaskItem?
    @State private var ailyGoalsDetailGoal: ailyGoalsGoalModel?
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ailyGoalsHeader
                    ailyGoalsProgressCard
                    ailyGoalsSnapshotRow
                    ailyGoalsQuickActions
                    ailyGoalsExploreRow
                    ailyGoalsTasksSection
                    ailyGoalsHabitsSection
                    ailyGoalsGoalsSection
                    ailyGoalsTipCard(
                        ailyGoalsEmoji: "🌟",
                        ailyGoalsTitle: "Daily spark",
                        ailyGoalsMessage: "Finish one small task before checking messages. Momentum loves a clean first win."
                    )
                }
                .padding(.horizontal, ailyGoalsAppTheme.ailyGoalsScreenPadding)
                .padding(.vertical, 12)
            }
            .background(
                LinearGradient(
                    colors: [Color(ailyGoalsHex: "F7F8FD"), Color(ailyGoalsHex: "F0EBFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $ailyGoalsShowTaskForm) {
                ailyGoalsTaskFormView(ailyGoalsViewModel: ailyGoalsViewModel)
            }
            .sheet(item: $ailyGoalsEditingTask) { ailyGoalsTask in
                ailyGoalsTaskFormView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsExisting: ailyGoalsTask)
            }
            .sheet(isPresented: $ailyGoalsShowHabitForm) {
                ailyGoalsHabitFormView(ailyGoalsViewModel: ailyGoalsViewModel)
            }
            .sheet(isPresented: $ailyGoalsShowGoalForm) {
                ailyGoalsGoalFormView(ailyGoalsViewModel: ailyGoalsViewModel)
            }
            .sheet(item: $ailyGoalsDetailGoal) { ailyGoalsGoal in
                ailyGoalsGoalDetailView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsGoalID: ailyGoalsGoal.id)
            }
            .confirmationDialog("Delete Task", isPresented: Binding(
                get: { ailyGoalsTaskToDelete != nil },
                set: { if !$0 { ailyGoalsTaskToDelete = nil } }
            ), titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let ailyGoalsTask = ailyGoalsTaskToDelete {
                        ailyGoalsViewModel.ailyGoalsDeleteTask(ailyGoalsTask.id)
                    }
                    ailyGoalsTaskToDelete = nil
                }
                Button("Cancel", role: .cancel) { ailyGoalsTaskToDelete = nil }
            }
        }
    }

    private var ailyGoalsHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(ailyGoalsDateHelpers.ailyGoalsGreeting()) ✨")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                if !ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsDisplayName.isEmpty {
                    Text("👋 \(ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsDisplayName)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                }
                Text("📅 \(ailyGoalsDateHelpers.ailyGoalsDayMonthYear.string(from: Date()))")
                    .font(.system(size: 14))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                Text("💫 \(ailyGoalsDateHelpers.ailyGoalsMotivationalMessage())")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    .padding(.top, 2)
            }
            Spacer()
            Button {
                ailyGoalsViewModel.ailyGoalsSelectedTab = 4
            } label: {
                Text("👤")
                    .font(.system(size: 34))
                    .padding(6)
                    .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Open profile")
        }
    }

    private var ailyGoalsProgressCard: some View {
        let ailyGoalsProgress = ailyGoalsViewModel.ailyGoalsTodayProgress()
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("🚀 Today's Progress")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text("\(ailyGoalsProgress.ailyGoalsCompleted) of \(ailyGoalsProgress.ailyGoalsTotal)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("⏳ \(ailyGoalsProgress.ailyGoalsRemaining) remaining · \(Int((ailyGoalsProgress.ailyGoalsPercent * 100).rounded()))% complete")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
            }
            Spacer(minLength: 8)
            ailyGoalsCircularProgress(ailyGoalsProgress: ailyGoalsProgress.ailyGoalsPercent)
                .frame(width: 76, height: 76)
        }
        .padding(20)
        .background(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: ailyGoalsAppTheme.ailyGoalsPrimaryPurple.opacity(0.28), radius: 14, x: 0, y: 8)
        .animation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion), value: ailyGoalsProgress.ailyGoalsPercent)
        .accessibilityElement(children: .combine)
    }

    private var ailyGoalsSnapshotRow: some View {
        let ailyGoalsHabitsDone = ailyGoalsViewModel.ailyGoalsHabitsScheduledToday.filter {
            ailyGoalsViewModel.ailyGoalsIsHabitCompleted($0, on: Date())
        }.count
        let ailyGoalsHabitsTotal = ailyGoalsViewModel.ailyGoalsHabitsScheduledToday.count
        let ailyGoalsOverdue = ailyGoalsViewModel.ailyGoalsOverdueTasks().count
        let ailyGoalsGoals = ailyGoalsViewModel.ailyGoalsActiveGoals.count
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ailyGoalsSnapshotTile(
                ailyGoalsEmoji: "🔥",
                ailyGoalsValue: "\(ailyGoalsHabitsDone)/\(ailyGoalsHabitsTotal)",
                ailyGoalsLabel: "Habits today",
                ailyGoalsTint: Color(ailyGoalsHex: "FFE8D6")
            )
            ailyGoalsSnapshotTile(
                ailyGoalsEmoji: "🎯",
                ailyGoalsValue: "\(ailyGoalsGoals)",
                ailyGoalsLabel: "Active goals",
                ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftBlue
            )
            ailyGoalsSnapshotTile(
                ailyGoalsEmoji: "⚠️",
                ailyGoalsValue: "\(ailyGoalsOverdue)",
                ailyGoalsLabel: "Overdue",
                ailyGoalsTint: Color(ailyGoalsHex: "FFE4EA")
            )
        }
    }

    private var ailyGoalsExploreRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ailyGoalsShortcutChip(ailyGoalsEmoji: "📅", ailyGoalsTitle: "Calendar") {
                    ailyGoalsViewModel.ailyGoalsSelectedTab = 1
                }
                ailyGoalsShortcutChip(ailyGoalsEmoji: "✨", ailyGoalsTitle: "Facts") {
                    ailyGoalsViewModel.ailyGoalsSelectedTab = 3
                }
                ailyGoalsShortcutChip(ailyGoalsEmoji: "🚀", ailyGoalsTitle: "Track") {
                    ailyGoalsViewModel.ailyGoalsSelectedTab = 2
                }
                ailyGoalsShortcutChip(ailyGoalsEmoji: "📊", ailyGoalsTitle: "Stats") {
                    ailyGoalsViewModel.ailyGoalsSelectedTab = 4
                }
            }
        }
    }

    private var ailyGoalsQuickActions: some View {
        HStack(spacing: 10) {
            ailyGoalsQuickAction(ailyGoalsTitle: "✅ Task", ailyGoalsSymbol: "plus") { ailyGoalsShowTaskForm = true }
            ailyGoalsQuickAction(ailyGoalsTitle: "🔁 Habit", ailyGoalsSymbol: "repeat") { ailyGoalsShowHabitForm = true }
            ailyGoalsQuickAction(ailyGoalsTitle: "🎯 Goal", ailyGoalsSymbol: "target") { ailyGoalsShowGoalForm = true }
        }
    }

    private func ailyGoalsQuickAction(ailyGoalsTitle: String, ailyGoalsSymbol: String, ailyGoalsAction: @escaping () -> Void) -> some View {
        Button(action: ailyGoalsAction) {
            VStack(spacing: 8) {
                Image(systemName: ailyGoalsSymbol)
                    .font(.system(size: 18, weight: .semibold))
                Text(ailyGoalsTitle)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ailyGoalsAppTheme.ailyGoalsSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(ailyGoalsAppTheme.ailyGoalsBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ailyGoalsScaleButtonStyle())
        .accessibilityLabel("Add \(ailyGoalsTitle)")
    }

    private var ailyGoalsTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("✅ Today's Tasks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                Spacer()
                NavigationLink {
                    ailyGoalsTasksListView(ailyGoalsViewModel: ailyGoalsViewModel)
                } label: {
                    Text("See All →")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ailyGoalsTaskFilter.allCases) { ailyGoalsItem in
                        ailyGoalsFilterChip(
                            ailyGoalsTitle: ailyGoalsItem.ailyGoalsTitle,
                            ailyGoalsIsSelected: ailyGoalsFilter == ailyGoalsItem
                        ) {
                            ailyGoalsFilter = ailyGoalsItem
                        }
                    }
                }
            }
            let ailyGoalsItems = ailyGoalsViewModel.ailyGoalsFilteredTasks(for: Date(), ailyGoalsFilter: ailyGoalsFilter)
            if ailyGoalsItems.isEmpty {
                ailyGoalsEmptyStateView(
                    ailyGoalsSymbol: "checkmark.circle",
                    ailyGoalsTitle: "No tasks yet",
                    ailyGoalsMessage: "Create your first task for today and start making progress.",
                    ailyGoalsButtonTitle: "Add Task"
                ) { ailyGoalsShowTaskForm = true }
            } else {
                ForEach(ailyGoalsItems) { ailyGoalsTask in
                    ailyGoalsTaskRowView(
                        ailyGoalsTask: ailyGoalsTask,
                        ailyGoalsOnToggle: {
                            withAnimation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion)) {
                                ailyGoalsViewModel.ailyGoalsToggleTaskCompletion(ailyGoalsTask.id)
                            }
                        },
                        ailyGoalsOnEdit: { ailyGoalsEditingTask = ailyGoalsTask },
                        ailyGoalsOnDelete: { ailyGoalsTaskToDelete = ailyGoalsTask }
                    )
                }
            }
        }
    }

    private var ailyGoalsHabitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ailyGoalsSectionHeader(ailyGoalsTitle: "🔁 Habits", ailyGoalsActionTitle: "See all") {
                ailyGoalsViewModel.ailyGoalsPreferredTrackSegment = .ailyGoalsHabits
                ailyGoalsViewModel.ailyGoalsSelectedTab = 2
            }
            let ailyGoalsHabits = Array(ailyGoalsViewModel.ailyGoalsHabitsScheduledToday.prefix(4))
            if ailyGoalsHabits.isEmpty {
                ailyGoalsEmptyStateView(
                    ailyGoalsSymbol: "repeat",
                    ailyGoalsTitle: "No habits today",
                    ailyGoalsMessage: "Add a habit scheduled for today to build your streak.",
                    ailyGoalsButtonTitle: "Add Habit"
                ) { ailyGoalsShowHabitForm = true }
            } else {
                ForEach(ailyGoalsHabits) { ailyGoalsHabit in
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
                }
            }
        }
    }

    private var ailyGoalsGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ailyGoalsSectionHeader(ailyGoalsTitle: "🎯 Goals", ailyGoalsActionTitle: "View all") {
                ailyGoalsViewModel.ailyGoalsPreferredTrackSegment = .ailyGoalsGoals
                ailyGoalsViewModel.ailyGoalsSelectedTab = 2
            }
            let ailyGoalsGoals = Array(ailyGoalsViewModel.ailyGoalsActiveGoals.prefix(3))
            if ailyGoalsGoals.isEmpty {
                ailyGoalsEmptyStateView(
                    ailyGoalsSymbol: "target",
                    ailyGoalsTitle: "No active goals",
                    ailyGoalsMessage: "Set a meaningful goal and track your progress.",
                    ailyGoalsButtonTitle: "Add Goal"
                ) { ailyGoalsShowGoalForm = true }
            } else {
                ForEach(ailyGoalsGoals) { ailyGoalsGoal in
                    ailyGoalsGoalCardView(ailyGoalsGoal: ailyGoalsGoal) {
                        ailyGoalsDetailGoal = ailyGoalsGoal
                    }
                }
            }
        }
    }
}
