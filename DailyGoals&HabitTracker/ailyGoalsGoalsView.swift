import SwiftUI

struct ailyGoalsGoalsView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    var ailyGoalsEmbedded: Bool = false
    @State private var ailyGoalsStatus: ailyGoalsGoalStatus = .ailyGoalsActive
    @State private var ailyGoalsShowForm = false
    @State private var ailyGoalsEditingGoal: ailyGoalsGoalModel?
    @State private var ailyGoalsDetailGoal: ailyGoalsGoalModel?
    @State private var ailyGoalsGoalToDelete: ailyGoalsGoalModel?

    var body: some View {
        Group {
            if ailyGoalsEmbedded {
                ailyGoalsContent
            } else {
                NavigationStack {
                    ailyGoalsContent
                        .navigationTitle("🎯 Goals")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button { ailyGoalsShowForm = true } label: { Image(systemName: "plus") }
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
                        Text("🌟 Chase meaningful progress")
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
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ailyGoalsGoalStatus.allCases) { ailyGoalsItem in
                            ailyGoalsFilterChip(
                                ailyGoalsTitle: ailyGoalsChipTitle(ailyGoalsItem),
                                ailyGoalsIsSelected: ailyGoalsStatus == ailyGoalsItem
                            ) { ailyGoalsStatus = ailyGoalsItem }
                        }
                    }
                }
                let ailyGoalsItems = ailyGoalsViewModel.ailyGoalsGoals(with: ailyGoalsStatus)
                if ailyGoalsItems.isEmpty {
                    ailyGoalsEmptyStateView(
                        ailyGoalsSymbol: "target",
                        ailyGoalsTitle: "No \(ailyGoalsStatus.ailyGoalsTitle.lowercased()) goals 🎯",
                        ailyGoalsMessage: "Define a long-term objective and track measurable progress.",
                        ailyGoalsButtonTitle: ailyGoalsStatus == .ailyGoalsActive ? "Add Goal" : nil,
                        ailyGoalsAction: ailyGoalsStatus == .ailyGoalsActive ? { ailyGoalsShowForm = true } : nil
                    )
                } else {
                    ForEach(ailyGoalsItems) { ailyGoalsGoal in
                        ailyGoalsGoalCardView(ailyGoalsGoal: ailyGoalsGoal) {
                            ailyGoalsDetailGoal = ailyGoalsGoal
                        }
                        .contextMenu {
                            Button("Edit") { ailyGoalsEditingGoal = ailyGoalsGoal }
                            if ailyGoalsGoal.ailyGoalsStatus != .ailyGoalsArchived {
                                Button("Archive") {
                                    var ailyGoalsMutable = ailyGoalsGoal
                                    ailyGoalsMutable.ailyGoalsStatus = .ailyGoalsArchived
                                    ailyGoalsViewModel.ailyGoalsUpsertGoal(ailyGoalsMutable)
                                }
                            }
                            Button("Delete", role: .destructive) { ailyGoalsGoalToDelete = ailyGoalsGoal }
                        }
                    }
                }
            }
            .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
        }
        .background(Color.clear)
        .sheet(isPresented: $ailyGoalsShowForm) {
            ailyGoalsGoalFormView(ailyGoalsViewModel: ailyGoalsViewModel)
        }
        .sheet(item: $ailyGoalsEditingGoal) { ailyGoalsGoal in
            ailyGoalsGoalFormView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsExisting: ailyGoalsGoal)
        }
        .sheet(item: $ailyGoalsDetailGoal) { ailyGoalsGoal in
            ailyGoalsGoalDetailView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsGoalID: ailyGoalsGoal.id)
        }
        .confirmationDialog("Delete Goal", isPresented: Binding(
            get: { ailyGoalsGoalToDelete != nil },
            set: { if !$0 { ailyGoalsGoalToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let ailyGoalsGoal = ailyGoalsGoalToDelete {
                    ailyGoalsViewModel.ailyGoalsDeleteGoal(ailyGoalsGoal.id)
                }
                ailyGoalsGoalToDelete = nil
            }
            Button("Cancel", role: .cancel) { ailyGoalsGoalToDelete = nil }
        }
    }

    private func ailyGoalsChipTitle(_ ailyGoalsItem: ailyGoalsGoalStatus) -> String {
        switch ailyGoalsItem {
        case .ailyGoalsActive: return "⚡ Active"
        case .ailyGoalsCompleted: return "✅ Done"
        case .ailyGoalsArchived: return "📦 Archived"
        }
    }
}

struct ailyGoalsGoalDetailView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    let ailyGoalsGoalID: UUID
    @Environment(\.dismiss) private var ailyGoalsDismiss
    @State private var ailyGoalsProgressDraft: Double = 0

    private var ailyGoalsGoal: ailyGoalsGoalModel? {
        ailyGoalsViewModel.ailyGoalsGoals.first { $0.id == ailyGoalsGoalID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let ailyGoalsGoal {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ailyGoalsGoalCardView(ailyGoalsGoal: ailyGoalsGoal)
                            if ailyGoalsGoal.ailyGoalsTargetValue != nil {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("📈 Update progress")
                                        .font(.system(size: 16, weight: .semibold))
                                    HStack {
                                        TextField("Value", value: $ailyGoalsProgressDraft, format: .number)
                                            .keyboardType(.decimalPad)
                                            .padding(12)
                                            .background(ailyGoalsAppTheme.ailyGoalsSurface)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        Button("Save") {
                                            ailyGoalsViewModel.ailyGoalsUpdateGoalProgress(ailyGoalsGoal.id, ailyGoalsValue: ailyGoalsProgressDraft)
                                        }
                                        .fontWeight(.semibold)
                                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                                    }
                                }
                                .padding(16)
                                .ailyGoalsAppCard()
                                .onAppear { ailyGoalsProgressDraft = ailyGoalsGoal.ailyGoalsCurrentValue }
                            }
                            if !ailyGoalsGoal.ailyGoalsMilestones.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("🏁 Milestones")
                                        .font(.system(size: 16, weight: .semibold))
                                    ForEach(ailyGoalsGoal.ailyGoalsMilestones) { ailyGoalsMilestone in
                                        Button {
                                            ailyGoalsViewModel.ailyGoalsToggleMilestone(ailyGoalsGoal.id, ailyGoalsMilestoneID: ailyGoalsMilestone.id)
                                        } label: {
                                            HStack {
                                                Image(systemName: ailyGoalsMilestone.ailyGoalsIsCompleted ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(ailyGoalsMilestone.ailyGoalsIsCompleted ? ailyGoalsAppTheme.ailyGoalsSuccess : ailyGoalsAppTheme.ailyGoalsMutedIcon)
                                                Text(ailyGoalsMilestone.ailyGoalsTitle)
                                                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                                                    .strikethrough(ailyGoalsMilestone.ailyGoalsIsCompleted)
                                                Spacer()
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(16)
                                .ailyGoalsAppCard()
                            }
                        }
                        .padding(16)
                    }
                } else {
                    Text("Goal not found")
                }
            }
            .background(ailyGoalsAppTheme.ailyGoalsBackground.ignoresSafeArea())
            .navigationTitle("Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { ailyGoalsDismiss() }
                }
            }
        }
    }
}
