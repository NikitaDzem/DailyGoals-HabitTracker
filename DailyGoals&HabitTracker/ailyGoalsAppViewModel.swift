import Foundation
import SwiftUI
import Combine

enum ailyGoalsTaskFilter: String, CaseIterable, Identifiable {
    case ailyGoalsAll
    case ailyGoalsPending
    case ailyGoalsCompleted

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsAll: return "All"
        case .ailyGoalsPending: return "Pending"
        case .ailyGoalsCompleted: return "Completed"
        }
    }
}

enum ailyGoalsStatsRange: String, CaseIterable, Identifiable {
    case ailyGoalsSevenDays
    case ailyGoalsThirtyDays
    case ailyGoalsAllTime

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsSevenDays: return "7 Days"
        case .ailyGoalsThirtyDays: return "30 Days"
        case .ailyGoalsAllTime: return "All Time"
        }
    }
}

struct ailyGoalsDayStat: Identifiable {
    var id: String { ailyGoalsDateKey }
    var ailyGoalsDateKey: String
    var ailyGoalsDate: Date
    var ailyGoalsTasksCompleted: Int
    var ailyGoalsHabitsCompleted: Int
}

@MainActor
final class ailyGoalsAppViewModel: ObservableObject {
    @Published var ailyGoalsTasks: [ailyGoalsTaskItem] = []
    @Published var ailyGoalsHabits: [ailyGoalsHabitModel] = []
    @Published var ailyGoalsHabitCompletions: [ailyGoalsHabitCompletion] = []
    @Published var ailyGoalsGoals: [ailyGoalsGoalModel] = []
    @Published var ailyGoalsPreferences: ailyGoalsUserPreferences = ailyGoalsUserPreferences()
    @Published var ailyGoalsSelectedTab: Int = 0
    @Published var ailyGoalsPreferredTrackSegment: ailyGoalsTrackSegment = .ailyGoalsHabits
    @Published var ailyGoalsNotificationStatusText: String = "Not Determined"

    private let ailyGoalsPersistence = ailyGoalsPersistenceService.ailyGoalsShared
    private let ailyGoalsNotifications = ailyGoalsNotificationService.ailyGoalsShared

    init() {
        ailyGoalsLoad()
        ailyGoalsRefreshNotificationStatus()
    }

    func ailyGoalsLoad() {
        let ailyGoalsPayload = ailyGoalsPersistence.ailyGoalsLoadPayload()
        ailyGoalsTasks = ailyGoalsPayload.ailyGoalsTasks
        ailyGoalsHabits = ailyGoalsPayload.ailyGoalsHabits
        ailyGoalsHabitCompletions = ailyGoalsPayload.ailyGoalsHabitCompletions
        ailyGoalsGoals = ailyGoalsPayload.ailyGoalsGoals
        ailyGoalsPreferences = ailyGoalsPayload.ailyGoalsPreferences
        ailyGoalsRecalculateAllHabitStreaks()
    }

    func ailyGoalsPersist() {
        let ailyGoalsPayload = ailyGoalsAppPayload(
            ailyGoalsTasks: ailyGoalsTasks,
            ailyGoalsHabits: ailyGoalsHabits,
            ailyGoalsHabitCompletions: ailyGoalsHabitCompletions,
            ailyGoalsGoals: ailyGoalsGoals,
            ailyGoalsPreferences: ailyGoalsPreferences
        )
        ailyGoalsPersistence.ailyGoalsSavePayload(ailyGoalsPayload)
    }

    func ailyGoalsExportData() -> Data? {
        let ailyGoalsPayload = ailyGoalsAppPayload(
            ailyGoalsTasks: ailyGoalsTasks,
            ailyGoalsHabits: ailyGoalsHabits,
            ailyGoalsHabitCompletions: ailyGoalsHabitCompletions,
            ailyGoalsGoals: ailyGoalsGoals,
            ailyGoalsPreferences: ailyGoalsPreferences
        )
        return ailyGoalsPersistence.ailyGoalsExportJSON(from: ailyGoalsPayload)
    }

    func ailyGoalsResetAllData() {
        ailyGoalsNotifications.ailyGoalsCancelAll()
        ailyGoalsPersistence.ailyGoalsResetAll()
        ailyGoalsTasks = []
        ailyGoalsHabits = []
        ailyGoalsHabitCompletions = []
        ailyGoalsGoals = []
        ailyGoalsPreferences = ailyGoalsUserPreferences(ailyGoalsHasCompletedOnboarding: true)
        ailyGoalsPersist()
    }

    func ailyGoalsCompleteOnboarding() {
        ailyGoalsPreferences.ailyGoalsHasCompletedOnboarding = true
        ailyGoalsPersist()
    }

    func ailyGoalsUpdatePreferences(_ ailyGoalsValue: ailyGoalsUserPreferences) {
        ailyGoalsPreferences = ailyGoalsValue
        ailyGoalsPersist()
    }

    func ailyGoalsRefreshNotificationStatus() {
        ailyGoalsNotifications.ailyGoalsAuthorizationStatus { [weak self] ailyGoalsStatus in
            guard let ailyGoalsSelf = self else { return }
            switch ailyGoalsStatus {
            case .authorized, .provisional, .ephemeral:
                ailyGoalsSelf.ailyGoalsNotificationStatusText = "Allowed"
            case .denied:
                ailyGoalsSelf.ailyGoalsNotificationStatusText = "Denied"
            case .notDetermined:
                ailyGoalsSelf.ailyGoalsNotificationStatusText = "Not Determined"
            @unknown default:
                ailyGoalsSelf.ailyGoalsNotificationStatusText = "Unknown"
            }
        }
    }

    func ailyGoalsRequestNotificationPermission(ailyGoalsCompletion: ((Bool) -> Void)? = nil) {
        ailyGoalsNotifications.ailyGoalsRequestAuthorization { [weak self] ailyGoalsGranted in
            self?.ailyGoalsPreferences.ailyGoalsNotificationsEnabled = ailyGoalsGranted
            self?.ailyGoalsPersist()
            self?.ailyGoalsRefreshNotificationStatus()
            ailyGoalsCompletion?(ailyGoalsGranted)
        }
    }

    func ailyGoalsOpenSystemSettings() {
        guard let ailyGoalsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(ailyGoalsURL)
    }

    func ailyGoalsTasks(for ailyGoalsDate: Date) -> [ailyGoalsTaskItem] {
        ailyGoalsTasks
            .filter { ailyGoalsDateHelpers.ailyGoalsIsSameDay($0.ailyGoalsDueDate, ailyGoalsDate) }
            .sorted { ailyGoalsLhs, ailyGoalsRhs in
                if ailyGoalsLhs.ailyGoalsIsCompleted != ailyGoalsRhs.ailyGoalsIsCompleted {
                    return !ailyGoalsLhs.ailyGoalsIsCompleted && ailyGoalsRhs.ailyGoalsIsCompleted
                }
                if ailyGoalsLhs.ailyGoalsPriority.ailyGoalsSortOrder != ailyGoalsRhs.ailyGoalsPriority.ailyGoalsSortOrder {
                    return ailyGoalsLhs.ailyGoalsPriority.ailyGoalsSortOrder < ailyGoalsRhs.ailyGoalsPriority.ailyGoalsSortOrder
                }
                let ailyGoalsLeftTime = ailyGoalsLhs.ailyGoalsStartTime ?? .distantFuture
                let ailyGoalsRightTime = ailyGoalsRhs.ailyGoalsStartTime ?? .distantFuture
                return ailyGoalsLeftTime < ailyGoalsRightTime
            }
    }

    func ailyGoalsFilteredTasks(for ailyGoalsDate: Date, ailyGoalsFilter: ailyGoalsTaskFilter) -> [ailyGoalsTaskItem] {
        let ailyGoalsDayTasks = ailyGoalsTasks(for: ailyGoalsDate)
        switch ailyGoalsFilter {
        case .ailyGoalsAll:
            return ailyGoalsDayTasks
        case .ailyGoalsPending:
            return ailyGoalsDayTasks.filter { !$0.ailyGoalsIsCompleted }
        case .ailyGoalsCompleted:
            return ailyGoalsDayTasks.filter(\.ailyGoalsIsCompleted)
        }
    }

    func ailyGoalsTodayProgress() -> (ailyGoalsCompleted: Int, ailyGoalsTotal: Int, ailyGoalsRemaining: Int, ailyGoalsPercent: Double) {
        let ailyGoalsDayTasks = ailyGoalsTasks(for: Date())
        let ailyGoalsTotal = ailyGoalsDayTasks.count
        let ailyGoalsCompleted = ailyGoalsDayTasks.filter(\.ailyGoalsIsCompleted).count
        let ailyGoalsRemaining = max(ailyGoalsTotal - ailyGoalsCompleted, 0)
        let ailyGoalsPercent = ailyGoalsLogicHelpers.ailyGoalsTaskCompletionPercent(
            ailyGoalsCompleted: ailyGoalsCompleted,
            ailyGoalsTotal: ailyGoalsTotal
        )
        return (ailyGoalsCompleted, ailyGoalsTotal, ailyGoalsRemaining, ailyGoalsPercent)
    }

    var ailyGoalsHabitsScheduledToday: [ailyGoalsHabitModel] {
        ailyGoalsActiveHabits.filter { $0.ailyGoalsIsScheduled(on: Date()) }
    }

    func ailyGoalsUpcomingTasks() -> [ailyGoalsTaskItem] {
        let ailyGoalsToday = ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
        return ailyGoalsTasks
            .filter { !$0.ailyGoalsIsCompleted && ailyGoalsDateHelpers.ailyGoalsStartOfDay($0.ailyGoalsDueDate) > ailyGoalsToday }
            .sorted { $0.ailyGoalsDueDate < $1.ailyGoalsDueDate }
    }

    func ailyGoalsOverdueTasks() -> [ailyGoalsTaskItem] {
        ailyGoalsTasks
            .filter(\.ailyGoalsIsOverdue)
            .sorted { $0.ailyGoalsDueDate < $1.ailyGoalsDueDate }
    }

    func ailyGoalsCompletedTasks() -> [ailyGoalsTaskItem] {
        ailyGoalsTasks
            .filter(\.ailyGoalsIsCompleted)
            .sorted { $0.ailyGoalsUpdatedAt > $1.ailyGoalsUpdatedAt }
    }

    func ailyGoalsWeekDots(for ailyGoalsHabit: ailyGoalsHabitModel) -> [Bool?] {
        let ailyGoalsToday = ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
        return (0..<7).map { ailyGoalsOffset in
            let ailyGoalsDate = ailyGoalsDateHelpers.ailyGoalsAddDays(ailyGoalsOffset - 6, to: ailyGoalsToday)
            if !ailyGoalsHabit.ailyGoalsIsScheduled(on: ailyGoalsDate) {
                return nil
            }
            return ailyGoalsIsHabitCompleted(ailyGoalsHabit, on: ailyGoalsDate)
        }
    }

    func ailyGoalsUpsertTask(_ ailyGoalsTask: ailyGoalsTaskItem) {
        var ailyGoalsMutable = ailyGoalsTask
        ailyGoalsMutable.ailyGoalsUpdatedAt = Date()
        if let ailyGoalsIndex = ailyGoalsTasks.firstIndex(where: { $0.id == ailyGoalsMutable.id }) {
            ailyGoalsTasks[ailyGoalsIndex] = ailyGoalsMutable
        } else {
            ailyGoalsTasks.append(ailyGoalsMutable)
        }
        ailyGoalsPersist()
        ailyGoalsSyncTaskNotification(ailyGoalsMutable)
        ailyGoalsHapticService.ailyGoalsImpact(ailyGoalsEnabled: ailyGoalsPreferences.ailyGoalsHapticsEnabled)
    }

    func ailyGoalsToggleTaskCompletion(_ ailyGoalsTaskID: UUID) {
        guard let ailyGoalsIndex = ailyGoalsTasks.firstIndex(where: { $0.id == ailyGoalsTaskID }) else { return }
        ailyGoalsTasks[ailyGoalsIndex].ailyGoalsIsCompleted.toggle()
        ailyGoalsTasks[ailyGoalsIndex].ailyGoalsUpdatedAt = Date()
        let ailyGoalsTask = ailyGoalsTasks[ailyGoalsIndex]
        if let ailyGoalsGoalID = ailyGoalsTask.ailyGoalsLinkedGoalID,
           let ailyGoalsGoalIndex = ailyGoalsGoals.firstIndex(where: { $0.id == ailyGoalsGoalID }),
           ailyGoalsGoals[ailyGoalsGoalIndex].ailyGoalsTargetValue != nil {
            if ailyGoalsTask.ailyGoalsIsCompleted {
                ailyGoalsGoals[ailyGoalsGoalIndex].ailyGoalsCurrentValue += 1
            } else {
                ailyGoalsGoals[ailyGoalsGoalIndex].ailyGoalsCurrentValue = max(0, ailyGoalsGoals[ailyGoalsGoalIndex].ailyGoalsCurrentValue - 1)
            }
            ailyGoalsMaybeCompleteGoal(at: ailyGoalsGoalIndex)
        }
        ailyGoalsPersist()
        ailyGoalsSyncTaskNotification(ailyGoalsTask)
        ailyGoalsHapticService.ailyGoalsSuccess(ailyGoalsEnabled: ailyGoalsPreferences.ailyGoalsHapticsEnabled)
    }

    func ailyGoalsDeleteTask(_ ailyGoalsTaskID: UUID) {
        if let ailyGoalsTask = ailyGoalsTasks.first(where: { $0.id == ailyGoalsTaskID }) {
            ailyGoalsNotifications.ailyGoalsCancel(ailyGoalsIdentifier: ailyGoalsTask.ailyGoalsNotificationIdentifier)
        }
        ailyGoalsTasks.removeAll { $0.id == ailyGoalsTaskID }
        for ailyGoalsIndex in ailyGoalsGoals.indices {
            ailyGoalsGoals[ailyGoalsIndex].ailyGoalsLinkedTaskIDs.removeAll { $0 == ailyGoalsTaskID }
        }
        ailyGoalsPersist()
    }

    func ailyGoalsDatesWithTasks(in ailyGoalsMonth: Date) -> Set<String> {
        let ailyGoalsStart = ailyGoalsDateHelpers.ailyGoalsFirstDayOfMonth(for: ailyGoalsMonth)
        let ailyGoalsEnd = ailyGoalsDateHelpers.ailyGoalsAddMonths(1, to: ailyGoalsStart)
        var ailyGoalsKeys = Set<String>()
        for ailyGoalsTask in ailyGoalsTasks {
            if ailyGoalsTask.ailyGoalsDueDate >= ailyGoalsStart && ailyGoalsTask.ailyGoalsDueDate < ailyGoalsEnd {
                ailyGoalsKeys.insert(ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsTask.ailyGoalsDueDate))
            }
        }
        return ailyGoalsKeys
    }

    var ailyGoalsActiveHabits: [ailyGoalsHabitModel] {
        ailyGoalsHabits.filter { !$0.ailyGoalsIsArchived }.sorted { $0.ailyGoalsName < $1.ailyGoalsName }
    }

    func ailyGoalsCompletion(for ailyGoalsHabitID: UUID, on ailyGoalsDate: Date) -> ailyGoalsHabitCompletion? {
        let ailyGoalsKey = ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsDate)
        return ailyGoalsHabitCompletions.first {
            $0.ailyGoalsHabitID == ailyGoalsHabitID && $0.ailyGoalsDateKey == ailyGoalsKey
        }
    }

    func ailyGoalsIsHabitCompleted(_ ailyGoalsHabit: ailyGoalsHabitModel, on ailyGoalsDate: Date) -> Bool {
        guard let ailyGoalsCompletion = ailyGoalsCompletion(for: ailyGoalsHabit.id, on: ailyGoalsDate) else { return false }
        return ailyGoalsCompletion.ailyGoalsCount >= ailyGoalsHabit.ailyGoalsDailyTarget
    }

    func ailyGoalsHabitProgress(_ ailyGoalsHabit: ailyGoalsHabitModel, on ailyGoalsDate: Date) -> Double {
        let ailyGoalsCount = Double(ailyGoalsCompletion(for: ailyGoalsHabit.id, on: ailyGoalsDate)?.ailyGoalsCount ?? 0)
        return min(ailyGoalsCount / Double(max(ailyGoalsHabit.ailyGoalsDailyTarget, 1)), 1)
    }

    func ailyGoalsUpsertHabit(_ ailyGoalsHabit: ailyGoalsHabitModel) {
        let ailyGoalsMutable = ailyGoalsHabit
        if let ailyGoalsIndex = ailyGoalsHabits.firstIndex(where: { $0.id == ailyGoalsMutable.id }) {
            ailyGoalsHabits[ailyGoalsIndex] = ailyGoalsMutable
        } else {
            ailyGoalsHabits.append(ailyGoalsMutable)
        }
        ailyGoalsRecalculateStreak(for: ailyGoalsMutable.id)
        ailyGoalsPersist()
        ailyGoalsSyncHabitNotification(ailyGoalsMutable)
        ailyGoalsHapticService.ailyGoalsImpact(ailyGoalsEnabled: ailyGoalsPreferences.ailyGoalsHapticsEnabled)
    }

    func ailyGoalsToggleHabitCompletion(_ ailyGoalsHabitID: UUID, on ailyGoalsDate: Date = Date()) {
        guard let ailyGoalsHabit = ailyGoalsHabits.first(where: { $0.id == ailyGoalsHabitID }),
              ailyGoalsHabit.ailyGoalsIsScheduled(on: ailyGoalsDate) else { return }
        let ailyGoalsKey = ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsDate)
        if let ailyGoalsIndex = ailyGoalsHabitCompletions.firstIndex(where: {
            $0.ailyGoalsHabitID == ailyGoalsHabitID && $0.ailyGoalsDateKey == ailyGoalsKey
        }) {
            if ailyGoalsHabit.ailyGoalsDailyTarget <= 1 {
                ailyGoalsHabitCompletions.remove(at: ailyGoalsIndex)
            } else {
                let ailyGoalsNext = ailyGoalsHabitCompletions[ailyGoalsIndex].ailyGoalsCount + 1
                if ailyGoalsNext > ailyGoalsHabit.ailyGoalsDailyTarget {
                    ailyGoalsHabitCompletions.remove(at: ailyGoalsIndex)
                } else {
                    ailyGoalsHabitCompletions[ailyGoalsIndex].ailyGoalsCount = ailyGoalsNext
                    ailyGoalsHabitCompletions[ailyGoalsIndex].ailyGoalsCompletedAt = Date()
                }
            }
        } else {
            ailyGoalsHabitCompletions.append(
                ailyGoalsHabitCompletion(
                    ailyGoalsHabitID: ailyGoalsHabitID,
                    ailyGoalsDateKey: ailyGoalsKey,
                    ailyGoalsCount: 1
                )
            )
        }
        ailyGoalsRecalculateStreak(for: ailyGoalsHabitID)
        ailyGoalsPersist()
        ailyGoalsHapticService.ailyGoalsSuccess(ailyGoalsEnabled: ailyGoalsPreferences.ailyGoalsHapticsEnabled)
    }

    func ailyGoalsDeleteHabit(_ ailyGoalsHabitID: UUID) {
        if let ailyGoalsHabit = ailyGoalsHabits.first(where: { $0.id == ailyGoalsHabitID }) {
            ailyGoalsNotifications.ailyGoalsCancelHabitReminders(for: ailyGoalsHabit)
        }
        ailyGoalsHabits.removeAll { $0.id == ailyGoalsHabitID }
        ailyGoalsHabitCompletions.removeAll { $0.ailyGoalsHabitID == ailyGoalsHabitID }
        for ailyGoalsIndex in ailyGoalsGoals.indices {
            ailyGoalsGoals[ailyGoalsIndex].ailyGoalsLinkedHabitIDs.removeAll { $0 == ailyGoalsHabitID }
        }
        ailyGoalsPersist()
    }

    func ailyGoalsArchiveHabit(_ ailyGoalsHabitID: UUID) {
        guard let ailyGoalsIndex = ailyGoalsHabits.firstIndex(where: { $0.id == ailyGoalsHabitID }) else { return }
        ailyGoalsHabits[ailyGoalsIndex].ailyGoalsIsArchived = true
        ailyGoalsNotifications.ailyGoalsCancelHabitReminders(for: ailyGoalsHabits[ailyGoalsIndex])
        ailyGoalsPersist()
    }

    func ailyGoalsRecalculateAllHabitStreaks() {
        for ailyGoalsHabit in ailyGoalsHabits {
            ailyGoalsRecalculateStreak(for: ailyGoalsHabit.id)
        }
    }

    func ailyGoalsRecalculateStreak(for ailyGoalsHabitID: UUID) {
        guard let ailyGoalsIndex = ailyGoalsHabits.firstIndex(where: { $0.id == ailyGoalsHabitID }) else { return }
        let ailyGoalsHabit = ailyGoalsHabits[ailyGoalsIndex]
        let ailyGoalsKeys = Set(
            ailyGoalsHabitCompletions
                .filter { $0.ailyGoalsHabitID == ailyGoalsHabitID && $0.ailyGoalsCount >= ailyGoalsHabit.ailyGoalsDailyTarget }
                .map(\.ailyGoalsDateKey)
        )
        let ailyGoalsCurrent = ailyGoalsLogicHelpers.ailyGoalsCurrentStreak(
            ailyGoalsCompletedKeys: ailyGoalsKeys,
            ailyGoalsIsScheduled: { ailyGoalsHabit.ailyGoalsIsScheduled(on: $0) },
            ailyGoalsCreatedAt: ailyGoalsHabit.ailyGoalsCreatedAt
        )
        let ailyGoalsBest = ailyGoalsLogicHelpers.ailyGoalsBestStreak(
            ailyGoalsCompletedKeys: ailyGoalsKeys,
            ailyGoalsIsScheduled: { ailyGoalsHabit.ailyGoalsIsScheduled(on: $0) },
            ailyGoalsCreatedAt: ailyGoalsHabit.ailyGoalsCreatedAt
        )
        ailyGoalsHabits[ailyGoalsIndex].ailyGoalsCurrentStreak = ailyGoalsCurrent
        ailyGoalsHabits[ailyGoalsIndex].ailyGoalsBestStreak = max(ailyGoalsBest, ailyGoalsCurrent)
    }

    var ailyGoalsActiveGoals: [ailyGoalsGoalModel] {
        ailyGoalsGoals.filter { $0.ailyGoalsStatus == .ailyGoalsActive }
    }

    func ailyGoalsGoals(with ailyGoalsStatus: ailyGoalsGoalStatus) -> [ailyGoalsGoalModel] {
        ailyGoalsGoals.filter { $0.ailyGoalsStatus == ailyGoalsStatus }
    }

    func ailyGoalsUpsertGoal(_ ailyGoalsGoal: ailyGoalsGoalModel) {
        var ailyGoalsMutable = ailyGoalsGoal
        if ailyGoalsMutable.ailyGoalsProgressFraction >= 1, ailyGoalsMutable.ailyGoalsStatus == .ailyGoalsActive {
            ailyGoalsMutable.ailyGoalsStatus = .ailyGoalsCompleted
        }
        if let ailyGoalsIndex = ailyGoalsGoals.firstIndex(where: { $0.id == ailyGoalsMutable.id }) {
            ailyGoalsGoals[ailyGoalsIndex] = ailyGoalsMutable
        } else {
            ailyGoalsGoals.append(ailyGoalsMutable)
        }
        ailyGoalsPersist()
        ailyGoalsHapticService.ailyGoalsImpact(ailyGoalsEnabled: ailyGoalsPreferences.ailyGoalsHapticsEnabled)
    }

    func ailyGoalsDeleteGoal(_ ailyGoalsGoalID: UUID) {
        ailyGoalsGoals.removeAll { $0.id == ailyGoalsGoalID }
        for ailyGoalsIndex in ailyGoalsTasks.indices where ailyGoalsTasks[ailyGoalsIndex].ailyGoalsLinkedGoalID == ailyGoalsGoalID {
            ailyGoalsTasks[ailyGoalsIndex].ailyGoalsLinkedGoalID = nil
        }
        ailyGoalsPersist()
    }

    func ailyGoalsUpdateGoalProgress(_ ailyGoalsGoalID: UUID, ailyGoalsValue: Double) {
        guard let ailyGoalsIndex = ailyGoalsGoals.firstIndex(where: { $0.id == ailyGoalsGoalID }) else { return }
        ailyGoalsGoals[ailyGoalsIndex].ailyGoalsCurrentValue = max(0, ailyGoalsValue)
        ailyGoalsMaybeCompleteGoal(at: ailyGoalsIndex)
        ailyGoalsPersist()
    }

    func ailyGoalsToggleMilestone(_ ailyGoalsGoalID: UUID, ailyGoalsMilestoneID: UUID) {
        guard let ailyGoalsIndex = ailyGoalsGoals.firstIndex(where: { $0.id == ailyGoalsGoalID }),
              let ailyGoalsMilestoneIndex = ailyGoalsGoals[ailyGoalsIndex].ailyGoalsMilestones.firstIndex(where: { $0.id == ailyGoalsMilestoneID }) else { return }
        ailyGoalsGoals[ailyGoalsIndex].ailyGoalsMilestones[ailyGoalsMilestoneIndex].ailyGoalsIsCompleted.toggle()
        ailyGoalsMaybeCompleteGoal(at: ailyGoalsIndex)
        ailyGoalsPersist()
        ailyGoalsHapticService.ailyGoalsSuccess(ailyGoalsEnabled: ailyGoalsPreferences.ailyGoalsHapticsEnabled)
    }

    private func ailyGoalsMaybeCompleteGoal(at ailyGoalsIndex: Int) {
        if ailyGoalsGoals[ailyGoalsIndex].ailyGoalsProgressFraction >= 1 {
            ailyGoalsGoals[ailyGoalsIndex].ailyGoalsStatus = .ailyGoalsCompleted
        } else if ailyGoalsGoals[ailyGoalsIndex].ailyGoalsStatus == .ailyGoalsCompleted {
            ailyGoalsGoals[ailyGoalsIndex].ailyGoalsStatus = .ailyGoalsActive
        }
    }

    func ailyGoalsWeeklyHabitRate() -> Double {
        let ailyGoalsStart = ailyGoalsDateHelpers.ailyGoalsAddDays(-6, to: ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date()))
        var ailyGoalsExpected = 0
        var ailyGoalsDone = 0
        for ailyGoalsOffset in 0..<7 {
            let ailyGoalsDate = ailyGoalsDateHelpers.ailyGoalsAddDays(ailyGoalsOffset, to: ailyGoalsStart)
            for ailyGoalsHabit in ailyGoalsActiveHabits where ailyGoalsHabit.ailyGoalsIsScheduled(on: ailyGoalsDate) {
                ailyGoalsExpected += 1
                if ailyGoalsIsHabitCompleted(ailyGoalsHabit, on: ailyGoalsDate) {
                    ailyGoalsDone += 1
                }
            }
        }
        guard ailyGoalsExpected > 0 else { return 0 }
        return Double(ailyGoalsDone) / Double(ailyGoalsExpected)
    }

    func ailyGoalsTaskCompletionRate(ailyGoalsRange: ailyGoalsStatsRange) -> Double {
        let ailyGoalsRelevant = ailyGoalsTasks(in: ailyGoalsRange)
        guard !ailyGoalsRelevant.isEmpty else { return 0 }
        let ailyGoalsDone = ailyGoalsRelevant.filter(\.ailyGoalsIsCompleted).count
        return Double(ailyGoalsDone) / Double(ailyGoalsRelevant.count)
    }

    func ailyGoalsTasksCompletedCount(ailyGoalsRange: ailyGoalsStatsRange) -> Int {
        ailyGoalsTasks(in: ailyGoalsRange).filter(\.ailyGoalsIsCompleted).count
    }

    func ailyGoalsDayStats(ailyGoalsRange: ailyGoalsStatsRange) -> [ailyGoalsDayStat] {
        let ailyGoalsDays: Int
        switch ailyGoalsRange {
        case .ailyGoalsSevenDays: ailyGoalsDays = 7
        case .ailyGoalsThirtyDays: ailyGoalsDays = 30
        case .ailyGoalsAllTime: ailyGoalsDays = 30
        }
        var ailyGoalsResult: [ailyGoalsDayStat] = []
        let ailyGoalsToday = ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
        for ailyGoalsOffset in stride(from: ailyGoalsDays - 1, through: 0, by: -1) {
            let ailyGoalsDate = ailyGoalsDateHelpers.ailyGoalsAddDays(-ailyGoalsOffset, to: ailyGoalsToday)
            let ailyGoalsKey = ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsDate)
            let ailyGoalsTaskCount = ailyGoalsTasks.filter {
                $0.ailyGoalsIsCompleted && ailyGoalsDateHelpers.ailyGoalsIsSameDay($0.ailyGoalsUpdatedAt, ailyGoalsDate)
            }.count
            let ailyGoalsHabitCount = ailyGoalsHabitCompletions.filter { $0.ailyGoalsDateKey == ailyGoalsKey }.count
            ailyGoalsResult.append(
                ailyGoalsDayStat(
                    ailyGoalsDateKey: ailyGoalsKey,
                    ailyGoalsDate: ailyGoalsDate,
                    ailyGoalsTasksCompleted: ailyGoalsTaskCount,
                    ailyGoalsHabitsCompleted: ailyGoalsHabitCount
                )
            )
        }
        return ailyGoalsResult
    }

    private func ailyGoalsTasks(in ailyGoalsRange: ailyGoalsStatsRange) -> [ailyGoalsTaskItem] {
        switch ailyGoalsRange {
        case .ailyGoalsAllTime:
            return ailyGoalsTasks
        case .ailyGoalsSevenDays:
            let ailyGoalsStart = ailyGoalsDateHelpers.ailyGoalsAddDays(-6, to: ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date()))
            return ailyGoalsTasks.filter { $0.ailyGoalsDueDate >= ailyGoalsStart }
        case .ailyGoalsThirtyDays:
            let ailyGoalsStart = ailyGoalsDateHelpers.ailyGoalsAddDays(-29, to: ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date()))
            return ailyGoalsTasks.filter { $0.ailyGoalsDueDate >= ailyGoalsStart }
        }
    }

    private func ailyGoalsSyncTaskNotification(_ ailyGoalsTask: ailyGoalsTaskItem) {
        guard ailyGoalsPreferences.ailyGoalsNotificationsEnabled else {
            ailyGoalsNotifications.ailyGoalsCancel(ailyGoalsIdentifier: ailyGoalsTask.ailyGoalsNotificationIdentifier)
            return
        }
        ailyGoalsNotifications.ailyGoalsScheduleTaskReminder(for: ailyGoalsTask)
    }

    private func ailyGoalsSyncHabitNotification(_ ailyGoalsHabit: ailyGoalsHabitModel) {
        guard ailyGoalsPreferences.ailyGoalsNotificationsEnabled else {
            ailyGoalsNotifications.ailyGoalsCancelHabitReminders(for: ailyGoalsHabit)
            return
        }
        ailyGoalsNotifications.ailyGoalsScheduleHabitReminder(for: ailyGoalsHabit)
    }
}
