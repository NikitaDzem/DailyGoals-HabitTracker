import Foundation

enum ailyGoalsHabitCategory: String, Codable, CaseIterable, Identifiable {
    case ailyGoalsHealth
    case ailyGoalsFitness
    case ailyGoalsLearning
    case ailyGoalsMindfulness
    case ailyGoalsProductivity
    case ailyGoalsPersonal

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsHealth: return "Health"
        case .ailyGoalsFitness: return "Fitness"
        case .ailyGoalsLearning: return "Learning"
        case .ailyGoalsMindfulness: return "Mindfulness"
        case .ailyGoalsProductivity: return "Productivity"
        case .ailyGoalsPersonal: return "Personal"
        }
    }

    var ailyGoalsSymbolName: String {
        switch self {
        case .ailyGoalsHealth: return "heart.fill"
        case .ailyGoalsFitness: return "figure.run"
        case .ailyGoalsLearning: return "book.fill"
        case .ailyGoalsMindfulness: return "leaf.fill"
        case .ailyGoalsProductivity: return "bolt.fill"
        case .ailyGoalsPersonal: return "person.fill"
        }
    }
}

enum ailyGoalsHabitFrequency: String, Codable, CaseIterable, Identifiable {
    case ailyGoalsDaily
    case ailyGoalsWeekdays
    case ailyGoalsCustom

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsDaily: return "Daily"
        case .ailyGoalsWeekdays: return "Weekdays"
        case .ailyGoalsCustom: return "Custom"
        }
    }
}

struct ailyGoalsHabitCompletion: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var ailyGoalsHabitID: UUID
    var ailyGoalsDateKey: String
    var ailyGoalsCount: Int
    var ailyGoalsCompletedAt: Date

    init(
        id: UUID = UUID(),
        ailyGoalsHabitID: UUID,
        ailyGoalsDateKey: String,
        ailyGoalsCount: Int = 1,
        ailyGoalsCompletedAt: Date = Date()
    ) {
        self.id = id
        self.ailyGoalsHabitID = ailyGoalsHabitID
        self.ailyGoalsDateKey = ailyGoalsDateKey
        self.ailyGoalsCount = ailyGoalsCount
        self.ailyGoalsCompletedAt = ailyGoalsCompletedAt
    }
}

struct ailyGoalsHabitModel: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var ailyGoalsName: String
    var ailyGoalsDetail: String
    var ailyGoalsCategory: ailyGoalsHabitCategory
    var ailyGoalsSymbolName: String
    var ailyGoalsColorHex: String
    var ailyGoalsCreatedAt: Date
    var ailyGoalsIsArchived: Bool
    var ailyGoalsFrequency: ailyGoalsHabitFrequency
    var ailyGoalsSelectedWeekdays: [Int]
    var ailyGoalsDailyTarget: Int
    var ailyGoalsReminderEnabled: Bool
    var ailyGoalsReminderTime: Date?
    var ailyGoalsCurrentStreak: Int
    var ailyGoalsBestStreak: Int

    init(
        id: UUID = UUID(),
        ailyGoalsName: String,
        ailyGoalsDetail: String = "",
        ailyGoalsCategory: ailyGoalsHabitCategory = .ailyGoalsProductivity,
        ailyGoalsSymbolName: String? = nil,
        ailyGoalsColorHex: String = "7957F5",
        ailyGoalsCreatedAt: Date = Date(),
        ailyGoalsIsArchived: Bool = false,
        ailyGoalsFrequency: ailyGoalsHabitFrequency = .ailyGoalsDaily,
        ailyGoalsSelectedWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7],
        ailyGoalsDailyTarget: Int = 1,
        ailyGoalsReminderEnabled: Bool = false,
        ailyGoalsReminderTime: Date? = nil,
        ailyGoalsCurrentStreak: Int = 0,
        ailyGoalsBestStreak: Int = 0
    ) {
        self.id = id
        self.ailyGoalsName = ailyGoalsName
        self.ailyGoalsDetail = ailyGoalsDetail
        self.ailyGoalsCategory = ailyGoalsCategory
        self.ailyGoalsSymbolName = ailyGoalsSymbolName ?? ailyGoalsCategory.ailyGoalsSymbolName
        self.ailyGoalsColorHex = ailyGoalsColorHex
        self.ailyGoalsCreatedAt = ailyGoalsCreatedAt
        self.ailyGoalsIsArchived = ailyGoalsIsArchived
        self.ailyGoalsFrequency = ailyGoalsFrequency
        self.ailyGoalsSelectedWeekdays = ailyGoalsSelectedWeekdays
        self.ailyGoalsDailyTarget = max(1, ailyGoalsDailyTarget)
        self.ailyGoalsReminderEnabled = ailyGoalsReminderEnabled
        self.ailyGoalsReminderTime = ailyGoalsReminderTime
        self.ailyGoalsCurrentStreak = ailyGoalsCurrentStreak
        self.ailyGoalsBestStreak = ailyGoalsBestStreak
    }

    var ailyGoalsNotificationIdentifier: String {
        "ailyGoals-habit-\(id.uuidString)"
    }

    func ailyGoalsIsScheduled(on ailyGoalsDate: Date) -> Bool {
        let ailyGoalsWeekday = ailyGoalsDateHelpers.ailyGoalsWeekdayIndex(ailyGoalsDate)
        switch ailyGoalsFrequency {
        case .ailyGoalsDaily:
            return true
        case .ailyGoalsWeekdays:
            return ailyGoalsWeekday >= 2 && ailyGoalsWeekday <= 6
        case .ailyGoalsCustom:
            return ailyGoalsSelectedWeekdays.contains(ailyGoalsWeekday)
        }
    }

    func ailyGoalsEffectiveWeekdays() -> [Int] {
        switch ailyGoalsFrequency {
        case .ailyGoalsDaily:
            return [1, 2, 3, 4, 5, 6, 7]
        case .ailyGoalsWeekdays:
            return [2, 3, 4, 5, 6]
        case .ailyGoalsCustom:
            return ailyGoalsSelectedWeekdays.sorted()
        }
    }
}
