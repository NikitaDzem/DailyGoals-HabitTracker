import SwiftUI

struct ailyGoalsHabitFormView: View {
    @Environment(\.dismiss) private var ailyGoalsDismiss
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    var ailyGoalsExisting: ailyGoalsHabitModel? = nil

    @State private var ailyGoalsName: String = ""
    @State private var ailyGoalsDetail: String = ""
    @State private var ailyGoalsCategory: ailyGoalsHabitCategory = .ailyGoalsProductivity
    @State private var ailyGoalsFrequency: ailyGoalsHabitFrequency = .ailyGoalsDaily
    @State private var ailyGoalsSelectedWeekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    @State private var ailyGoalsDailyTarget: Int = 1
    @State private var ailyGoalsReminderEnabled: Bool = false
    @State private var ailyGoalsReminderTime: Date = Date()
    @State private var ailyGoalsColorHex: String = "7957F5"
    @State private var ailyGoalsValidationMessage: String = ""
    @State private var ailyGoalsShowPermissionExplainer: Bool = false

    private let ailyGoalsWeekdayLabels = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"), (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]
    private let ailyGoalsColors = ["7957F5", "A66BFA", "4388F5", "2DBE6C", "F5A524", "E5484D"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Habit name", text: $ailyGoalsName)
                    TextField("Description", text: $ailyGoalsDetail, axis: .vertical)
                        .lineLimit(2...5)
                    Picker("Category", selection: $ailyGoalsCategory) {
                        ForEach(ailyGoalsHabitCategory.allCases) { ailyGoalsItem in
                            Text(ailyGoalsItem.ailyGoalsTitle).tag(ailyGoalsItem)
                        }
                    }
                }
                Section("Schedule") {
                    Picker("Frequency", selection: $ailyGoalsFrequency) {
                        ForEach(ailyGoalsHabitFrequency.allCases) { ailyGoalsItem in
                            Text(ailyGoalsItem.ailyGoalsTitle).tag(ailyGoalsItem)
                        }
                    }
                    if ailyGoalsFrequency == .ailyGoalsCustom {
                        ailyGoalsFlexibleWeekdayPicker
                    }
                    Stepper("Daily target: \(ailyGoalsDailyTarget)", value: $ailyGoalsDailyTarget, in: 1...20)
                }
                Section("Appearance") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(ailyGoalsColors, id: \.self) { ailyGoalsHex in
                                Circle()
                                    .fill(Color(ailyGoalsHex: ailyGoalsHex))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: ailyGoalsColorHex == ailyGoalsHex ? 3 : 0)
                                    )
                                    .onTapGesture { ailyGoalsColorHex = ailyGoalsHex }
                            }
                        }
                    }
                }
                Section("Reminder") {
                    Toggle("Remind me", isOn: $ailyGoalsReminderEnabled)
                    if ailyGoalsReminderEnabled {
                        DatePicker("Time", selection: $ailyGoalsReminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                if !ailyGoalsValidationMessage.isEmpty {
                    Section {
                        Text(ailyGoalsValidationMessage)
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsDestructive)
                    }
                }
            }
            .navigationTitle(ailyGoalsExisting == nil ? "New Habit" : "Edit Habit")
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
            .alert("Enable Reminders", isPresented: $ailyGoalsShowPermissionExplainer) {
                Button("Not Now", role: .cancel) { ailyGoalsFinishSave(ailyGoalsSchedule: false) }
                Button("Allow") {
                    ailyGoalsViewModel.ailyGoalsRequestNotificationPermission { _ in
                        ailyGoalsFinishSave(ailyGoalsSchedule: true)
                    }
                }
            } message: {
                Text("Habit reminders help you stay consistent. Permission can be changed later in Settings.")
            }
        }
    }

    private var ailyGoalsFlexibleWeekdayPicker: some View {
        HStack {
            ForEach(ailyGoalsWeekdayLabels, id: \.0) { ailyGoalsItem in
                let ailyGoalsSelected = ailyGoalsSelectedWeekdays.contains(ailyGoalsItem.0)
                Button(ailyGoalsItem.1) {
                    if ailyGoalsSelected {
                        ailyGoalsSelectedWeekdays.remove(ailyGoalsItem.0)
                    } else {
                        ailyGoalsSelectedWeekdays.insert(ailyGoalsItem.0)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(ailyGoalsSelected ? ailyGoalsAppTheme.ailyGoalsPrimaryPurple : ailyGoalsAppTheme.ailyGoalsSoftLavender)
                .foregroundColor(ailyGoalsSelected ? .white : ailyGoalsAppTheme.ailyGoalsPrimaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private func ailyGoalsPopulate() {
        guard let ailyGoalsExisting else { return }
        ailyGoalsName = ailyGoalsExisting.ailyGoalsName
        ailyGoalsDetail = ailyGoalsExisting.ailyGoalsDetail
        ailyGoalsCategory = ailyGoalsExisting.ailyGoalsCategory
        ailyGoalsFrequency = ailyGoalsExisting.ailyGoalsFrequency
        ailyGoalsSelectedWeekdays = Set(ailyGoalsExisting.ailyGoalsSelectedWeekdays)
        ailyGoalsDailyTarget = ailyGoalsExisting.ailyGoalsDailyTarget
        ailyGoalsReminderEnabled = ailyGoalsExisting.ailyGoalsReminderEnabled
        ailyGoalsReminderTime = ailyGoalsExisting.ailyGoalsReminderTime ?? Date()
        ailyGoalsColorHex = ailyGoalsExisting.ailyGoalsColorHex
    }

    private func ailyGoalsSave() {
        let ailyGoalsTrimmed = ailyGoalsName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ailyGoalsTrimmed.isEmpty else {
            ailyGoalsValidationMessage = "Habit name is required."
            return
        }
        if ailyGoalsFrequency == .ailyGoalsCustom && ailyGoalsSelectedWeekdays.isEmpty {
            ailyGoalsValidationMessage = "Select at least one weekday."
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
        let ailyGoalsHabit = ailyGoalsHabitModel(
            id: ailyGoalsExisting?.id ?? UUID(),
            ailyGoalsName: ailyGoalsName.trimmingCharacters(in: .whitespacesAndNewlines),
            ailyGoalsDetail: ailyGoalsDetail.trimmingCharacters(in: .whitespacesAndNewlines),
            ailyGoalsCategory: ailyGoalsCategory,
            ailyGoalsSymbolName: ailyGoalsCategory.ailyGoalsSymbolName,
            ailyGoalsColorHex: ailyGoalsColorHex,
            ailyGoalsCreatedAt: ailyGoalsExisting?.ailyGoalsCreatedAt ?? Date(),
            ailyGoalsIsArchived: ailyGoalsExisting?.ailyGoalsIsArchived ?? false,
            ailyGoalsFrequency: ailyGoalsFrequency,
            ailyGoalsSelectedWeekdays: Array(ailyGoalsSelectedWeekdays).sorted(),
            ailyGoalsDailyTarget: ailyGoalsDailyTarget,
            ailyGoalsReminderEnabled: ailyGoalsReminderEnabled && ailyGoalsSchedule,
            ailyGoalsReminderTime: ailyGoalsReminderEnabled ? ailyGoalsReminderTime : nil,
            ailyGoalsCurrentStreak: ailyGoalsExisting?.ailyGoalsCurrentStreak ?? 0,
            ailyGoalsBestStreak: ailyGoalsExisting?.ailyGoalsBestStreak ?? 0
        )
        ailyGoalsViewModel.ailyGoalsUpsertHabit(ailyGoalsHabit)
        ailyGoalsDismiss()
    }
}
