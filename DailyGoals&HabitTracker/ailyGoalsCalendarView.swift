import SwiftUI

struct ailyGoalsCalendarView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsDisplayedMonth = ailyGoalsDateHelpers.ailyGoalsFirstDayOfMonth(for: Date())
    @State private var ailyGoalsSelectedDate = ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
    @State private var ailyGoalsShowTaskForm = false
    @State private var ailyGoalsEditingTask: ailyGoalsTaskItem?
    @State private var ailyGoalsTaskToDelete: ailyGoalsTaskItem?

    private var ailyGoalsWeekdaySymbols: [String] {
        var ailyGoalsCal = Calendar.current
        ailyGoalsCal.firstWeekday = ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsFirstWeekday
        let ailyGoalsSymbols = ailyGoalsCal.shortWeekdaySymbols
        let ailyGoalsFirst = ailyGoalsCal.firstWeekday - 1
        return Array(ailyGoalsSymbols[ailyGoalsFirst...] + ailyGoalsSymbols[..<ailyGoalsFirst])
    }

    private var ailyGoalsMonthTaskCount: Int {
        let ailyGoalsStart = ailyGoalsDateHelpers.ailyGoalsFirstDayOfMonth(for: ailyGoalsDisplayedMonth)
        let ailyGoalsEnd = ailyGoalsDateHelpers.ailyGoalsAddMonths(1, to: ailyGoalsStart)
        return ailyGoalsViewModel.ailyGoalsTasks.filter {
            $0.ailyGoalsDueDate >= ailyGoalsStart && $0.ailyGoalsDueDate < ailyGoalsEnd
        }.count
    }

    private var ailyGoalsBusyDaysCount: Int {
        ailyGoalsViewModel.ailyGoalsDatesWithTasks(in: ailyGoalsDisplayedMonth).count
    }

    private var ailyGoalsSelectedTasks: [ailyGoalsTaskItem] {
        ailyGoalsViewModel.ailyGoalsTasks(for: ailyGoalsSelectedDate)
    }

    private var ailyGoalsSelectedCompleted: Int {
        ailyGoalsSelectedTasks.filter(\.ailyGoalsIsCompleted).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ailyGoalsHeroBanner(
                        ailyGoalsEmoji: "📅",
                        ailyGoalsTitle: "Plan your month",
                        ailyGoalsSubtitle: "Dots mark busy days. Tap a date to open its agenda and add tasks fast.",
                        ailyGoalsColors: [Color(ailyGoalsHex: "7657F6"), Color(ailyGoalsHex: "4389F7")]
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "📝",
                            ailyGoalsValue: "\(ailyGoalsMonthTaskCount)",
                            ailyGoalsLabel: "Tasks this month",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftLavender
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "💜",
                            ailyGoalsValue: "\(ailyGoalsBusyDaysCount)",
                            ailyGoalsLabel: "Busy days",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftBlue
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "✅",
                            ailyGoalsValue: "\(ailyGoalsSelectedCompleted)/\(ailyGoalsSelectedTasks.count)",
                            ailyGoalsLabel: "Selected day",
                            ailyGoalsTint: Color(ailyGoalsHex: "E8FFF5")
                        )
                    }

                    ailyGoalsMonthHeader
                    ailyGoalsWeekdayRow
                    ailyGoalsMonthGrid

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("📋 Agenda")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                            Spacer()
                            Text(ailyGoalsDateHelpers.ailyGoalsMediumDate.string(from: ailyGoalsSelectedDate))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                                .clipShape(Capsule())
                        }
                        HStack(spacing: 10) {
                            ailyGoalsShortcutChip(ailyGoalsEmoji: "➕", ailyGoalsTitle: "Add task") {
                                ailyGoalsShowTaskForm = true
                            }
                            ailyGoalsShortcutChip(ailyGoalsEmoji: "🎯", ailyGoalsTitle: "Today") {
                                ailyGoalsSelectedDate = ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
                                ailyGoalsDisplayedMonth = ailyGoalsDateHelpers.ailyGoalsFirstDayOfMonth(for: Date())
                            }
                            ailyGoalsShortcutChip(ailyGoalsEmoji: "🔥", ailyGoalsTitle: "Track") {
                                ailyGoalsViewModel.ailyGoalsSelectedTab = 2
                            }
                        }

                        if ailyGoalsSelectedTasks.isEmpty {
                            ailyGoalsEmptyStateView(
                                ailyGoalsSymbol: "calendar",
                                ailyGoalsTitle: "Free day 🌤️",
                                ailyGoalsMessage: "No tasks yet for this date. Add one and keep your plan colorful.",
                                ailyGoalsButtonTitle: "Add Task"
                            ) { ailyGoalsShowTaskForm = true }
                        } else {
                            ForEach(ailyGoalsSelectedTasks) { ailyGoalsTask in
                                ailyGoalsTaskRowView(
                                    ailyGoalsTask: ailyGoalsTask,
                                    ailyGoalsOnToggle: { ailyGoalsViewModel.ailyGoalsToggleTaskCompletion(ailyGoalsTask.id) },
                                    ailyGoalsOnEdit: { ailyGoalsEditingTask = ailyGoalsTask },
                                    ailyGoalsOnDelete: { ailyGoalsTaskToDelete = ailyGoalsTask }
                                )
                            }
                        }
                    }

                    ailyGoalsTipCard(
                        ailyGoalsEmoji: "💡",
                        ailyGoalsTitle: "Calendar tip",
                        ailyGoalsMessage: "Plan one high-priority task for tomorrow before ending today. Future-you will thank you."
                    )
                }
                .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
            }
            .background(
                LinearGradient(
                    colors: [Color(ailyGoalsHex: "F7F8FD"), Color(ailyGoalsHex: "EAF1FF"), Color(ailyGoalsHex: "F0EBFF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("📅 Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        ailyGoalsSelectedDate = ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
                        ailyGoalsDisplayedMonth = ailyGoalsDateHelpers.ailyGoalsFirstDayOfMonth(for: Date())
                    }
                }
            }
            .sheet(isPresented: $ailyGoalsShowTaskForm) {
                ailyGoalsTaskFormView(
                    ailyGoalsViewModel: ailyGoalsViewModel,
                    ailyGoalsInitialDate: ailyGoalsSelectedDate
                )
            }
            .sheet(item: $ailyGoalsEditingTask) { ailyGoalsTask in
                ailyGoalsTaskFormView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsExisting: ailyGoalsTask)
            }
            .confirmationDialog("Delete Task", isPresented: Binding(
                get: { ailyGoalsTaskToDelete != nil },
                set: { if !$0 { ailyGoalsTaskToDelete = nil } }
            )) {
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

    private var ailyGoalsMonthHeader: some View {
        HStack {
            Button {
                ailyGoalsDisplayedMonth = ailyGoalsDateHelpers.ailyGoalsAddMonths(-1, to: ailyGoalsDisplayedMonth)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
            }
            Spacer()
            VStack(spacing: 2) {
                Text(ailyGoalsDateHelpers.ailyGoalsMonthYear.string(from: ailyGoalsDisplayedMonth))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                Text("🗓️ Swipe months with arrows")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
            }
            Spacer()
            Button {
                ailyGoalsDisplayedMonth = ailyGoalsDateHelpers.ailyGoalsAddMonths(1, to: ailyGoalsDisplayedMonth)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
            }
        }
        .padding(14)
        .ailyGoalsAppCard()
    }

    private var ailyGoalsWeekdayRow: some View {
        HStack {
            ForEach(ailyGoalsWeekdaySymbols, id: \.self) { ailyGoalsSymbol in
                Text(ailyGoalsSymbol.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple.opacity(0.75))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }

    private var ailyGoalsMonthGrid: some View {
        let ailyGoalsDays = ailyGoalsBuildDays()
        let ailyGoalsMarked = ailyGoalsViewModel.ailyGoalsDatesWithTasks(in: ailyGoalsDisplayedMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
            ForEach(ailyGoalsDays, id: \.self) { ailyGoalsDay in
                if let ailyGoalsDay {
                    let ailyGoalsIsSelected = ailyGoalsDateHelpers.ailyGoalsIsSameDay(ailyGoalsDay, ailyGoalsSelectedDate)
                    let ailyGoalsIsToday = ailyGoalsDateHelpers.ailyGoalsIsToday(ailyGoalsDay)
                    let ailyGoalsHasTasks = ailyGoalsMarked.contains(ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsDay))
                    Button {
                        ailyGoalsSelectedDate = ailyGoalsDay
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(Calendar.current.component(.day, from: ailyGoalsDay))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(ailyGoalsIsSelected ? .white : ailyGoalsAppTheme.ailyGoalsPrimaryText)
                                .frame(width: 36, height: 36)
                                .background(
                                    Group {
                                        if ailyGoalsIsSelected {
                                            Circle().fill(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
                                        } else if ailyGoalsIsToday {
                                            Circle().fill(ailyGoalsAppTheme.ailyGoalsSoftBlue)
                                        } else if ailyGoalsHasTasks {
                                            Circle().fill(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                                        } else {
                                            Circle().fill(Color.clear)
                                        }
                                    }
                                )
                            Circle()
                                .fill(ailyGoalsHasTasks ? ailyGoalsAppTheme.ailyGoalsSecondaryPurple : Color.clear)
                                .frame(width: 5, height: 5)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ailyGoalsDateHelpers.ailyGoalsMediumDate.string(from: ailyGoalsDay))
                    .accessibilityAddTraits(ailyGoalsIsSelected ? .isSelected : [])
                } else {
                    Color.clear.frame(height: 48)
                }
            }
        }
        .padding(14)
        .ailyGoalsAppCard()
    }

    private func ailyGoalsBuildDays() -> [Date?] {
        let ailyGoalsFirst = ailyGoalsDateHelpers.ailyGoalsFirstDayOfMonth(for: ailyGoalsDisplayedMonth)
        var ailyGoalsCal = Calendar.current
        ailyGoalsCal.firstWeekday = ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsFirstWeekday
        let ailyGoalsWeekday = ailyGoalsCal.component(.weekday, from: ailyGoalsFirst)
        let ailyGoalsLeading = (ailyGoalsWeekday - ailyGoalsCal.firstWeekday + 7) % 7
        let ailyGoalsCount = ailyGoalsDateHelpers.ailyGoalsDaysInMonth(for: ailyGoalsDisplayedMonth)
        var ailyGoalsDays: [Date?] = Array(repeating: nil, count: ailyGoalsLeading)
        for ailyGoalsDay in 0..<ailyGoalsCount {
            ailyGoalsDays.append(ailyGoalsDateHelpers.ailyGoalsAddDays(ailyGoalsDay, to: ailyGoalsFirst))
        }
        while ailyGoalsDays.count % 7 != 0 {
            ailyGoalsDays.append(nil)
        }
        return ailyGoalsDays
    }
}
