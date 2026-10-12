import SwiftUI

struct ailyGoalsTaskFormView: View {
    @Environment(\.dismiss) private var ailyGoalsDismiss
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel

    var ailyGoalsExisting: ailyGoalsTaskItem? = nil
    var ailyGoalsInitialDate: Date = Date()

    @State private var ailyGoalsTitle: String = ""
    @State private var ailyGoalsDetail: String = ""
    @State private var ailyGoalsDueDate: Date = Date()
    @State private var ailyGoalsHasTime: Bool = false
    @State private var ailyGoalsStartTime: Date = Date()
    @State private var ailyGoalsHasEndTime: Bool = false
    @State private var ailyGoalsEndTime: Date = Date()
    @State private var ailyGoalsPriority: ailyGoalsTaskPriority = .ailyGoalsMedium
    @State private var ailyGoalsCategory: ailyGoalsTaskCategory? = .ailyGoalsPersonal
    @State private var ailyGoalsReminderEnabled: Bool = false
    @State private var ailyGoalsReminderDate: Date = Date()
    @State private var ailyGoalsValidationMessage: String = ""
    @State private var ailyGoalsShowPermissionExplainer: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $ailyGoalsTitle)
                    TextField("Description", text: $ailyGoalsDetail, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Schedule") {
                    DatePicker("Date", selection: $ailyGoalsDueDate, displayedComponents: .date)
                    Toggle("Include time", isOn: $ailyGoalsHasTime)
                    if ailyGoalsHasTime {
                        DatePicker("Start time", selection: $ailyGoalsStartTime, displayedComponents: .hourAndMinute)
                        Toggle("End time", isOn: $ailyGoalsHasEndTime)
                        if ailyGoalsHasEndTime {
                            DatePicker("End time", selection: $ailyGoalsEndTime, displayedComponents: .hourAndMinute)
                        }
                    }
                }
                Section("Organization") {
                    Picker("Priority", selection: $ailyGoalsPriority) {
                        ForEach(ailyGoalsTaskPriority.allCases) { ailyGoalsItem in
                            Text(ailyGoalsItem.ailyGoalsTitle).tag(ailyGoalsItem)
                        }
                    }
                    Picker("Category", selection: $ailyGoalsCategory) {
                        Text("None").tag(Optional<ailyGoalsTaskCategory>.none)
                        ForEach(ailyGoalsTaskCategory.allCases) { ailyGoalsItem in
                            Text(ailyGoalsItem.ailyGoalsTitle).tag(Optional(ailyGoalsItem))
                        }
                    }
                }
                Section("Reminder") {
                    Toggle("Remind me", isOn: $ailyGoalsReminderEnabled)
                    if ailyGoalsReminderEnabled {
                        DatePicker("Reminder time", selection: $ailyGoalsReminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                if !ailyGoalsValidationMessage.isEmpty {
                    Section {
                        Text(ailyGoalsValidationMessage)
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsDestructive)
                            .font(.system(size: 13))
                    }
                }
            }
            .navigationTitle(ailyGoalsExisting == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { ailyGoalsDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { ailyGoalsSave() }
                        .fontWeight(.semibold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .onAppear(perform: ailyGoalsPopulate)
            .alert("Enable Reminders", isPresented: $ailyGoalsShowPermissionExplainer) {
                Button("Not Now", role: .cancel) { ailyGoalsFinishSave(ailyGoalsSchedule: false) }
                Button("Allow") {
                    ailyGoalsViewModel.ailyGoalsRequestNotificationPermission { _ in
                        ailyGoalsFinishSave(ailyGoalsSchedule: true)
                    }
                }
            } message: {
                Text("Reminders help you stay on track with tasks and habits. You can change this anytime in Settings.")
            }
        }
    }

    private func ailyGoalsPopulate() {
        if let ailyGoalsExisting {
            ailyGoalsTitle = ailyGoalsExisting.ailyGoalsTitle
            ailyGoalsDetail = ailyGoalsExisting.ailyGoalsDetail
            ailyGoalsDueDate = ailyGoalsExisting.ailyGoalsDueDate
            ailyGoalsHasTime = ailyGoalsExisting.ailyGoalsStartTime != nil
            ailyGoalsStartTime = ailyGoalsExisting.ailyGoalsStartTime ?? Date()
            ailyGoalsHasEndTime = ailyGoalsExisting.ailyGoalsEndTime != nil
            ailyGoalsEndTime = ailyGoalsExisting.ailyGoalsEndTime ?? Date()
            ailyGoalsPriority = ailyGoalsExisting.ailyGoalsPriority
            ailyGoalsCategory = ailyGoalsExisting.ailyGoalsCategory
            ailyGoalsReminderEnabled = ailyGoalsExisting.ailyGoalsReminderDate != nil
            ailyGoalsReminderDate = ailyGoalsExisting.ailyGoalsReminderDate ?? Date()
        } else {
            ailyGoalsDueDate = ailyGoalsInitialDate
            ailyGoalsReminderDate = ailyGoalsDateHelpers.ailyGoalsCombine(ailyGoalsDate: ailyGoalsInitialDate, ailyGoalsTime: Date())
        }
    }

    private func ailyGoalsSave() {
        let ailyGoalsTrimmed = ailyGoalsTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ailyGoalsTrimmed.isEmpty else {
            ailyGoalsValidationMessage = "Title is required."
            return
        }
        if ailyGoalsHasTime && ailyGoalsHasEndTime {
            let ailyGoalsStart = ailyGoalsDateHelpers.ailyGoalsCombine(ailyGoalsDate: ailyGoalsDueDate, ailyGoalsTime: ailyGoalsStartTime)
            let ailyGoalsEnd = ailyGoalsDateHelpers.ailyGoalsCombine(ailyGoalsDate: ailyGoalsDueDate, ailyGoalsTime: ailyGoalsEndTime)
            if ailyGoalsEnd <= ailyGoalsStart {
                ailyGoalsValidationMessage = "End time must be after start time."
                return
            }
        }
        if ailyGoalsReminderEnabled && ailyGoalsReminderDate <= Date() {
            ailyGoalsValidationMessage = "Reminder must be in the future."
            return
        }
        ailyGoalsValidationMessage = ""
        if ailyGoalsReminderEnabled && ailyGoalsViewModel.ailyGoalsNotificationStatusText == "Not Determined" {
            ailyGoalsShowPermissionExplainer = true
            return
        }
        ailyGoalsFinishSave(ailyGoalsSchedule: true)
    }

    private func ailyGoalsFinishSave(ailyGoalsSchedule: Bool) {
        let ailyGoalsTask = ailyGoalsTaskItem(
            id: ailyGoalsExisting?.id ?? UUID(),
            ailyGoalsTitle: ailyGoalsTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            ailyGoalsDetail: ailyGoalsDetail.trimmingCharacters(in: .whitespacesAndNewlines),
            ailyGoalsDueDate: ailyGoalsDueDate,
            ailyGoalsStartTime: ailyGoalsHasTime ? ailyGoalsStartTime : nil,
            ailyGoalsEndTime: (ailyGoalsHasTime && ailyGoalsHasEndTime) ? ailyGoalsEndTime : nil,
            ailyGoalsIsCompleted: ailyGoalsExisting?.ailyGoalsIsCompleted ?? false,
            ailyGoalsPriority: ailyGoalsPriority,
            ailyGoalsCategory: ailyGoalsCategory,
            ailyGoalsTags: ailyGoalsExisting?.ailyGoalsTags ?? [],
            ailyGoalsCreatedAt: ailyGoalsExisting?.ailyGoalsCreatedAt ?? Date(),
            ailyGoalsUpdatedAt: Date(),
            ailyGoalsReminderDate: (ailyGoalsReminderEnabled && ailyGoalsSchedule) ? ailyGoalsReminderDate : nil,
            ailyGoalsLinkedGoalID: ailyGoalsExisting?.ailyGoalsLinkedGoalID
        )
        ailyGoalsViewModel.ailyGoalsUpsertTask(ailyGoalsTask)
        ailyGoalsDismiss()
    }
}
