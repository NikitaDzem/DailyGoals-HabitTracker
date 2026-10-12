import Foundation

enum ailyGoalsGoalCategory: String, Codable, CaseIterable, Identifiable {
    case ailyGoalsHealth
    case ailyGoalsCareer
    case ailyGoalsLearning
    case ailyGoalsFinance
    case ailyGoalsPersonal
    case ailyGoalsOther

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsHealth: return "Health"
        case .ailyGoalsCareer: return "Career"
        case .ailyGoalsLearning: return "Learning"
        case .ailyGoalsFinance: return "Finance"
        case .ailyGoalsPersonal: return "Personal"
        case .ailyGoalsOther: return "Other"
        }
    }

    var ailyGoalsSymbolName: String {
        switch self {
        case .ailyGoalsHealth: return "heart.fill"
        case .ailyGoalsCareer: return "briefcase.fill"
        case .ailyGoalsLearning: return "graduationcap.fill"
        case .ailyGoalsFinance: return "dollarsign.circle.fill"
        case .ailyGoalsPersonal: return "star.fill"
        case .ailyGoalsOther: return "flag.fill"
        }
    }
}

enum ailyGoalsGoalStatus: String, Codable, CaseIterable, Identifiable {
    case ailyGoalsActive
    case ailyGoalsCompleted
    case ailyGoalsArchived

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsActive: return "Active"
        case .ailyGoalsCompleted: return "Completed"
        case .ailyGoalsArchived: return "Archived"
        }
    }
}

struct ailyGoalsGoalMilestone: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var ailyGoalsTitle: String
    var ailyGoalsIsCompleted: Bool

    init(id: UUID = UUID(), ailyGoalsTitle: String, ailyGoalsIsCompleted: Bool = false) {
        self.id = id
        self.ailyGoalsTitle = ailyGoalsTitle
        self.ailyGoalsIsCompleted = ailyGoalsIsCompleted
    }
}

struct ailyGoalsGoalModel: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var ailyGoalsTitle: String
    var ailyGoalsDetail: String
    var ailyGoalsCategory: ailyGoalsGoalCategory
    var ailyGoalsCreatedAt: Date
    var ailyGoalsTargetDate: Date?
    var ailyGoalsStatus: ailyGoalsGoalStatus
    var ailyGoalsCurrentValue: Double
    var ailyGoalsTargetValue: Double?
    var ailyGoalsUnitLabel: String
    var ailyGoalsMilestones: [ailyGoalsGoalMilestone]
    var ailyGoalsLinkedTaskIDs: [UUID]
    var ailyGoalsLinkedHabitIDs: [UUID]

    init(
        id: UUID = UUID(),
        ailyGoalsTitle: String,
        ailyGoalsDetail: String = "",
        ailyGoalsCategory: ailyGoalsGoalCategory = .ailyGoalsPersonal,
        ailyGoalsCreatedAt: Date = Date(),
        ailyGoalsTargetDate: Date? = nil,
        ailyGoalsStatus: ailyGoalsGoalStatus = .ailyGoalsActive,
        ailyGoalsCurrentValue: Double = 0,
        ailyGoalsTargetValue: Double? = nil,
        ailyGoalsUnitLabel: String = "",
        ailyGoalsMilestones: [ailyGoalsGoalMilestone] = [],
        ailyGoalsLinkedTaskIDs: [UUID] = [],
        ailyGoalsLinkedHabitIDs: [UUID] = []
    ) {
        self.id = id
        self.ailyGoalsTitle = ailyGoalsTitle
        self.ailyGoalsDetail = ailyGoalsDetail
        self.ailyGoalsCategory = ailyGoalsCategory
        self.ailyGoalsCreatedAt = ailyGoalsCreatedAt
        self.ailyGoalsTargetDate = ailyGoalsTargetDate
        self.ailyGoalsStatus = ailyGoalsStatus
        self.ailyGoalsCurrentValue = ailyGoalsCurrentValue
        self.ailyGoalsTargetValue = ailyGoalsTargetValue
        self.ailyGoalsUnitLabel = ailyGoalsUnitLabel
        self.ailyGoalsMilestones = ailyGoalsMilestones
        self.ailyGoalsLinkedTaskIDs = ailyGoalsLinkedTaskIDs
        self.ailyGoalsLinkedHabitIDs = ailyGoalsLinkedHabitIDs
    }

    var ailyGoalsProgressFraction: Double {
        ailyGoalsLogicHelpers.ailyGoalsGoalProgressFraction(
            ailyGoalsCurrentValue: ailyGoalsCurrentValue,
            ailyGoalsTargetValue: ailyGoalsTargetValue,
            ailyGoalsMilestones: ailyGoalsMilestones,
            ailyGoalsIsCompletedStatus: ailyGoalsStatus == .ailyGoalsCompleted
        )
    }

    var ailyGoalsProgressPercent: Int {
        Int((ailyGoalsProgressFraction * 100).rounded())
    }

    var ailyGoalsCompletedMilestoneCount: Int {
        ailyGoalsMilestones.filter(\.ailyGoalsIsCompleted).count
    }
}
