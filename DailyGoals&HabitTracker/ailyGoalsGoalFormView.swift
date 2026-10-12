import SwiftUI

struct ailyGoalsGoalFormView: View {
    @Environment(\.dismiss) private var ailyGoalsDismiss
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    var ailyGoalsExisting: ailyGoalsGoalModel? = nil

    @State private var ailyGoalsTitle: String = ""
    @State private var ailyGoalsDetail: String = ""
    @State private var ailyGoalsCategory: ailyGoalsGoalCategory = .ailyGoalsPersonal
    @State private var ailyGoalsHasDeadline: Bool = false
    @State private var ailyGoalsTargetDate: Date = Date()
    @State private var ailyGoalsIsMeasurable: Bool = true
    @State private var ailyGoalsCurrentValue: Double = 0
    @State private var ailyGoalsTargetValue: Double = 10
    @State private var ailyGoalsUnitLabel: String = ""
    @State private var ailyGoalsMilestoneText: String = ""
    @State private var ailyGoalsMilestones: [ailyGoalsGoalMilestone] = []
    @State private var ailyGoalsValidationMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Goal name", text: $ailyGoalsTitle)
                    TextField("Description", text: $ailyGoalsDetail, axis: .vertical)
                        .lineLimit(2...5)
                    Picker("Category", selection: $ailyGoalsCategory) {
                        ForEach(ailyGoalsGoalCategory.allCases) { ailyGoalsItem in
                            Text(ailyGoalsItem.ailyGoalsTitle).tag(ailyGoalsItem)
                        }
                    }
                }
                Section("Deadline") {
                    Toggle("Set deadline", isOn: $ailyGoalsHasDeadline)
                    if ailyGoalsHasDeadline {
                        DatePicker("Target date", selection: $ailyGoalsTargetDate, displayedComponents: .date)
                    }
                }
                Section("Progress") {
                    Toggle("Measurable target", isOn: $ailyGoalsIsMeasurable)
                    if ailyGoalsIsMeasurable {
                        HStack {
                            Text("Current")
                            Spacer()
                            TextField("0", value: $ailyGoalsCurrentValue, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        HStack {
                            Text("Target")
                            Spacer()
                            TextField("10", value: $ailyGoalsTargetValue, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        TextField("Unit (books, hours...)", text: $ailyGoalsUnitLabel)
                    }
                }
                Section("Milestones") {
                    HStack {
                        TextField("Add milestone", text: $ailyGoalsMilestoneText)
                        Button("Add") {
                            let ailyGoalsTrimmed = ailyGoalsMilestoneText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !ailyGoalsTrimmed.isEmpty else { return }
                            ailyGoalsMilestones.append(ailyGoalsGoalMilestone(ailyGoalsTitle: ailyGoalsTrimmed))
                            ailyGoalsMilestoneText = ""
                        }
                    }
                    ForEach(ailyGoalsMilestones) { ailyGoalsItem in
                        Text(ailyGoalsItem.ailyGoalsTitle)
                    }
                    .onDelete { ailyGoalsOffsets in
                        ailyGoalsMilestones.remove(atOffsets: ailyGoalsOffsets)
                    }
                }
                if !ailyGoalsValidationMessage.isEmpty {
                    Section {
                        Text(ailyGoalsValidationMessage)
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsDestructive)
                    }
                }
            }
            .navigationTitle(ailyGoalsExisting == nil ? "New Goal" : "Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { ailyGoalsDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { ailyGoalsSave() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: ailyGoalsPopulate)
        }
    }

    private func ailyGoalsPopulate() {
        guard let ailyGoalsExisting else { return }
        ailyGoalsTitle = ailyGoalsExisting.ailyGoalsTitle
        ailyGoalsDetail = ailyGoalsExisting.ailyGoalsDetail
        ailyGoalsCategory = ailyGoalsExisting.ailyGoalsCategory
        ailyGoalsHasDeadline = ailyGoalsExisting.ailyGoalsTargetDate != nil
        ailyGoalsTargetDate = ailyGoalsExisting.ailyGoalsTargetDate ?? Date()
        ailyGoalsIsMeasurable = ailyGoalsExisting.ailyGoalsTargetValue != nil
        ailyGoalsCurrentValue = ailyGoalsExisting.ailyGoalsCurrentValue
        ailyGoalsTargetValue = ailyGoalsExisting.ailyGoalsTargetValue ?? 10
        ailyGoalsUnitLabel = ailyGoalsExisting.ailyGoalsUnitLabel
        ailyGoalsMilestones = ailyGoalsExisting.ailyGoalsMilestones
    }

    private func ailyGoalsSave() {
        let ailyGoalsTrimmed = ailyGoalsTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ailyGoalsTrimmed.isEmpty else {
            ailyGoalsValidationMessage = "Goal name is required."
            return
        }
        if ailyGoalsIsMeasurable && ailyGoalsTargetValue <= 0 {
            ailyGoalsValidationMessage = "Target must be greater than zero."
            return
        }
        if !ailyGoalsIsMeasurable && ailyGoalsMilestones.isEmpty {
            ailyGoalsValidationMessage = "Add milestones or enable a measurable target."
            return
        }
        let ailyGoalsGoal = ailyGoalsGoalModel(
            id: ailyGoalsExisting?.id ?? UUID(),
            ailyGoalsTitle: ailyGoalsTrimmed,
            ailyGoalsDetail: ailyGoalsDetail.trimmingCharacters(in: .whitespacesAndNewlines),
            ailyGoalsCategory: ailyGoalsCategory,
            ailyGoalsCreatedAt: ailyGoalsExisting?.ailyGoalsCreatedAt ?? Date(),
            ailyGoalsTargetDate: ailyGoalsHasDeadline ? ailyGoalsTargetDate : nil,
            ailyGoalsStatus: ailyGoalsExisting?.ailyGoalsStatus ?? .ailyGoalsActive,
            ailyGoalsCurrentValue: ailyGoalsIsMeasurable ? ailyGoalsCurrentValue : Double(ailyGoalsMilestones.filter(\.ailyGoalsIsCompleted).count),
            ailyGoalsTargetValue: ailyGoalsIsMeasurable ? ailyGoalsTargetValue : nil,
            ailyGoalsUnitLabel: ailyGoalsUnitLabel,
            ailyGoalsMilestones: ailyGoalsMilestones,
            ailyGoalsLinkedTaskIDs: ailyGoalsExisting?.ailyGoalsLinkedTaskIDs ?? [],
            ailyGoalsLinkedHabitIDs: ailyGoalsExisting?.ailyGoalsLinkedHabitIDs ?? []
        )
        ailyGoalsViewModel.ailyGoalsUpsertGoal(ailyGoalsGoal)
        ailyGoalsDismiss()
    }
}
