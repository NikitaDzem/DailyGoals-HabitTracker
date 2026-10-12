import Foundation

struct ailyGoalsUserPreferences: Codable, Equatable {
    var ailyGoalsDisplayName: String
    var ailyGoalsFirstWeekday: Int
    var ailyGoalsNotificationsEnabled: Bool
    var ailyGoalsHapticsEnabled: Bool
    var ailyGoalsHasCompletedOnboarding: Bool
    var ailyGoalsFollowsSystemAppearance: Bool

    init(
        ailyGoalsDisplayName: String = "",
        ailyGoalsFirstWeekday: Int = 2,
        ailyGoalsNotificationsEnabled: Bool = true,
        ailyGoalsHapticsEnabled: Bool = true,
        ailyGoalsHasCompletedOnboarding: Bool = false,
        ailyGoalsFollowsSystemAppearance: Bool = false
    ) {
        self.ailyGoalsDisplayName = ailyGoalsDisplayName
        self.ailyGoalsFirstWeekday = ailyGoalsFirstWeekday
        self.ailyGoalsNotificationsEnabled = ailyGoalsNotificationsEnabled
        self.ailyGoalsHapticsEnabled = ailyGoalsHapticsEnabled
        self.ailyGoalsHasCompletedOnboarding = ailyGoalsHasCompletedOnboarding
        self.ailyGoalsFollowsSystemAppearance = ailyGoalsFollowsSystemAppearance
    }
}

struct ailyGoalsAppPayload: Codable, Equatable {
    var ailyGoalsTasks: [ailyGoalsTaskItem]
    var ailyGoalsHabits: [ailyGoalsHabitModel]
    var ailyGoalsHabitCompletions: [ailyGoalsHabitCompletion]
    var ailyGoalsGoals: [ailyGoalsGoalModel]
    var ailyGoalsPreferences: ailyGoalsUserPreferences

    init(
        ailyGoalsTasks: [ailyGoalsTaskItem] = [],
        ailyGoalsHabits: [ailyGoalsHabitModel] = [],
        ailyGoalsHabitCompletions: [ailyGoalsHabitCompletion] = [],
        ailyGoalsGoals: [ailyGoalsGoalModel] = [],
        ailyGoalsPreferences: ailyGoalsUserPreferences = ailyGoalsUserPreferences()
    ) {
        self.ailyGoalsTasks = ailyGoalsTasks
        self.ailyGoalsHabits = ailyGoalsHabits
        self.ailyGoalsHabitCompletions = ailyGoalsHabitCompletions
        self.ailyGoalsGoals = ailyGoalsGoals
        self.ailyGoalsPreferences = ailyGoalsPreferences
    }
}
