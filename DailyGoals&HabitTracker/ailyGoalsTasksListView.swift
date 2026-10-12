import SwiftUI

enum ailyGoalsTaskListScope: String, CaseIterable, Identifiable {
    case ailyGoalsToday
    case ailyGoalsUpcoming
    case ailyGoalsOverdue
    case ailyGoalsCompleted
    case ailyGoalsPriority
    case ailyGoalsCategory

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsToday: return "Today"
        case .ailyGoalsUpcoming: return "Upcoming"
        case .ailyGoalsOverdue: return "Overdue"
        case .ailyGoalsCompleted: return "Completed"
        case .ailyGoalsPriority: return "Priority"
        case .ailyGoalsCategory: return "Category"
        }
    }
}

struct ailyGoalsTasksListView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsScope: ailyGoalsTaskListScope = .ailyGoalsToday
    @State private var ailyGoalsShowTaskForm = false
    @State private var ailyGoalsEditingTask: ailyGoalsTaskItem?
    @State private var ailyGoalsTaskToDelete: ailyGoalsTaskItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ailyGoalsTaskListScope.allCases) { ailyGoalsItem in
                            ailyGoalsFilterChip(
                                ailyGoalsTitle: ailyGoalsItem.ailyGoalsTitle,
                                ailyGoalsIsSelected: ailyGoalsScope == ailyGoalsItem
                            ) {
                                ailyGoalsScope = ailyGoalsItem
                            }
                        }
                    }
                }
                let ailyGoalsItems = ailyGoalsResolvedTasks()
                if ailyGoalsItems.isEmpty {
                    ailyGoalsEmptyStateView(
                        ailyGoalsSymbol: "checkmark.circle",
                        ailyGoalsTitle: "No tasks here",
                        ailyGoalsMessage: "Nothing matches \(ailyGoalsScope.ailyGoalsTitle.lowercased()). Add a task to get started.",
                        ailyGoalsButtonTitle: "Add Task"
                    ) { ailyGoalsShowTaskForm = true }
                } else {
                    ForEach(ailyGoalsItems) { ailyGoalsTask in
                        ailyGoalsTaskRowView(
                            ailyGoalsTask: ailyGoalsTask,
                            ailyGoalsOnToggle: { ailyGoalsViewModel.ailyGoalsToggleTaskCompletion(ailyGoalsTask.id) },
                            ailyGoalsOnEdit: { ailyGoalsEditingTask = ailyGoalsTask },
                            ailyGoalsOnDelete: { ailyGoalsTaskToDelete = ailyGoalsTask }
                        )
                    }
                }
            }
            .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
        }
        .background(ailyGoalsAppTheme.ailyGoalsBackground.ignoresSafeArea())
        .navigationTitle("All Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    ailyGoalsShowTaskForm = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Task")
            }
        }
        .sheet(isPresented: $ailyGoalsShowTaskForm) {
            ailyGoalsTaskFormView(ailyGoalsViewModel: ailyGoalsViewModel)
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

    private func ailyGoalsResolvedTasks() -> [ailyGoalsTaskItem] {
        switch ailyGoalsScope {
        case .ailyGoalsToday:
            return ailyGoalsViewModel.ailyGoalsTasks(for: Date())
        case .ailyGoalsUpcoming:
            return ailyGoalsViewModel.ailyGoalsUpcomingTasks()
        case .ailyGoalsOverdue:
            return ailyGoalsViewModel.ailyGoalsOverdueTasks()
        case .ailyGoalsCompleted:
            return ailyGoalsViewModel.ailyGoalsCompletedTasks()
        case .ailyGoalsPriority:
            return ailyGoalsViewModel.ailyGoalsTasks
                .filter { !$0.ailyGoalsIsCompleted }
                .sorted {
                    if $0.ailyGoalsPriority.ailyGoalsSortOrder != $1.ailyGoalsPriority.ailyGoalsSortOrder {
                        return $0.ailyGoalsPriority.ailyGoalsSortOrder < $1.ailyGoalsPriority.ailyGoalsSortOrder
                    }
                    return $0.ailyGoalsDueDate < $1.ailyGoalsDueDate
                }
        case .ailyGoalsCategory:
            return ailyGoalsViewModel.ailyGoalsTasks
                .filter { !$0.ailyGoalsIsCompleted }
                .sorted {
                    let ailyGoalsLeft = $0.ailyGoalsCategory?.ailyGoalsTitle ?? "ZZZ"
                    let ailyGoalsRight = $1.ailyGoalsCategory?.ailyGoalsTitle ?? "ZZZ"
                    if ailyGoalsLeft != ailyGoalsRight {
                        return ailyGoalsLeft < ailyGoalsRight
                    }
                    return $0.ailyGoalsDueDate < $1.ailyGoalsDueDate
                }
        }
    }
}
