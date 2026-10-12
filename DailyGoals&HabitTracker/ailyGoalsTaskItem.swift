import Foundation

enum ailyGoalsTaskPriority: String, Codable, CaseIterable, Identifiable {
    case ailyGoalsLow
    case ailyGoalsMedium
    case ailyGoalsHigh

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsLow: return "Low"
        case .ailyGoalsMedium: return "Medium"
        case .ailyGoalsHigh: return "High"
        }
    }

    var ailyGoalsSortOrder: Int {
        switch self {
        case .ailyGoalsHigh: return 0
        case .ailyGoalsMedium: return 1
        case .ailyGoalsLow: return 2
        }
    }
}

enum ailyGoalsTaskCategory: String, Codable, CaseIterable, Identifiable {
    case ailyGoalsWork
    case ailyGoalsPersonal
    case ailyGoalsHealth
    case ailyGoalsLearning
    case ailyGoalsErrands
    case ailyGoalsOther

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsWork: return "Work"
        case .ailyGoalsPersonal: return "Personal"
        case .ailyGoalsHealth: return "Health"
        case .ailyGoalsLearning: return "Learning"
        case .ailyGoalsErrands: return "Errands"
        case .ailyGoalsOther: return "Other"
        }
    }

    var ailyGoalsSymbolName: String {
        switch self {
        case .ailyGoalsWork: return "briefcase.fill"
        case .ailyGoalsPersonal: return "house.fill"
        case .ailyGoalsHealth: return "heart.fill"
        case .ailyGoalsLearning: return "book.fill"
        case .ailyGoalsErrands: return "cart.fill"
        case .ailyGoalsOther: return "tag.fill"
        }
    }
}

struct ailyGoalsTaskItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var ailyGoalsTitle: String
    var ailyGoalsDetail: String
    var ailyGoalsDueDate: Date
    var ailyGoalsStartTime: Date?
    var ailyGoalsEndTime: Date?
    var ailyGoalsIsCompleted: Bool
    var ailyGoalsPriority: ailyGoalsTaskPriority
    var ailyGoalsCategory: ailyGoalsTaskCategory?
    var ailyGoalsTags: [String]
    var ailyGoalsCreatedAt: Date
    var ailyGoalsUpdatedAt: Date
    var ailyGoalsReminderDate: Date?
    var ailyGoalsLinkedGoalID: UUID?

    init(
        id: UUID = UUID(),
        ailyGoalsTitle: String,
        ailyGoalsDetail: String = "",
        ailyGoalsDueDate: Date = Date(),
        ailyGoalsStartTime: Date? = nil,
        ailyGoalsEndTime: Date? = nil,
        ailyGoalsIsCompleted: Bool = false,
        ailyGoalsPriority: ailyGoalsTaskPriority = .ailyGoalsMedium,
        ailyGoalsCategory: ailyGoalsTaskCategory? = nil,
        ailyGoalsTags: [String] = [],
        ailyGoalsCreatedAt: Date = Date(),
        ailyGoalsUpdatedAt: Date = Date(),
        ailyGoalsReminderDate: Date? = nil,
        ailyGoalsLinkedGoalID: UUID? = nil
    ) {
        self.id = id
        self.ailyGoalsTitle = ailyGoalsTitle
        self.ailyGoalsDetail = ailyGoalsDetail
        self.ailyGoalsDueDate = ailyGoalsDateHelpers.ailyGoalsStartOfDay(ailyGoalsDueDate)
        self.ailyGoalsStartTime = ailyGoalsStartTime
        self.ailyGoalsEndTime = ailyGoalsEndTime
        self.ailyGoalsIsCompleted = ailyGoalsIsCompleted
        self.ailyGoalsPriority = ailyGoalsPriority
        self.ailyGoalsCategory = ailyGoalsCategory
        self.ailyGoalsTags = ailyGoalsTags
        self.ailyGoalsCreatedAt = ailyGoalsCreatedAt
        self.ailyGoalsUpdatedAt = ailyGoalsUpdatedAt
        self.ailyGoalsReminderDate = ailyGoalsReminderDate
        self.ailyGoalsLinkedGoalID = ailyGoalsLinkedGoalID
    }

    var ailyGoalsIsOverdue: Bool {
        !ailyGoalsIsCompleted && ailyGoalsDateHelpers.ailyGoalsStartOfDay(ailyGoalsDueDate) < ailyGoalsDateHelpers.ailyGoalsStartOfDay(Date())
    }

    var ailyGoalsNotificationIdentifier: String {
        "ailyGoals-task-\(id.uuidString)"
    }
}
