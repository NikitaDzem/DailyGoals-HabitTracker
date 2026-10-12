import Foundation

enum ailyGoalsLogicHelpers {
    static func ailyGoalsGoalProgressFraction(
        ailyGoalsCurrentValue: Double,
        ailyGoalsTargetValue: Double?,
        ailyGoalsMilestones: [ailyGoalsGoalMilestone],
        ailyGoalsIsCompletedStatus: Bool
    ) -> Double {
        if let ailyGoalsTarget = ailyGoalsTargetValue, ailyGoalsTarget > 0 {
            return min(max(ailyGoalsCurrentValue / ailyGoalsTarget, 0), 1)
        }
        if !ailyGoalsMilestones.isEmpty {
            let ailyGoalsDone = Double(ailyGoalsMilestones.filter(\.ailyGoalsIsCompleted).count)
            return ailyGoalsDone / Double(ailyGoalsMilestones.count)
        }
        return ailyGoalsIsCompletedStatus ? 1 : 0
    }

    static func ailyGoalsCurrentStreak(
        ailyGoalsCompletedKeys: Set<String>,
        ailyGoalsIsScheduled: (Date) -> Bool,
        ailyGoalsCreatedAt: Date,
        ailyGoalsReferenceDate: Date = Date()
    ) -> Int {
        var ailyGoalsCurrent = 0
        var ailyGoalsCursor = ailyGoalsDateHelpers.ailyGoalsStartOfDay(ailyGoalsReferenceDate)
        let ailyGoalsCreated = ailyGoalsDateHelpers.ailyGoalsStartOfDay(ailyGoalsCreatedAt)
        if !ailyGoalsIsScheduled(ailyGoalsCursor) || !ailyGoalsCompletedKeys.contains(ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsCursor)) {
            ailyGoalsCursor = ailyGoalsDateHelpers.ailyGoalsAddDays(-1, to: ailyGoalsCursor)
        }
        var ailyGoalsGuard = 0
        while ailyGoalsGuard < 500 {
            ailyGoalsGuard += 1
            if ailyGoalsCursor < ailyGoalsCreated {
                break
            }
            if !ailyGoalsIsScheduled(ailyGoalsCursor) {
                ailyGoalsCursor = ailyGoalsDateHelpers.ailyGoalsAddDays(-1, to: ailyGoalsCursor)
                continue
            }
            let ailyGoalsKey = ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsCursor)
            if ailyGoalsCompletedKeys.contains(ailyGoalsKey) {
                ailyGoalsCurrent += 1
                ailyGoalsCursor = ailyGoalsDateHelpers.ailyGoalsAddDays(-1, to: ailyGoalsCursor)
            } else {
                break
            }
        }
        return ailyGoalsCurrent
    }

    static func ailyGoalsBestStreak(
        ailyGoalsCompletedKeys: Set<String>,
        ailyGoalsIsScheduled: (Date) -> Bool,
        ailyGoalsCreatedAt: Date,
        ailyGoalsReferenceDate: Date = Date()
    ) -> Int {
        var ailyGoalsBest = 0
        var ailyGoalsRun = 0
        var ailyGoalsScan = ailyGoalsDateHelpers.ailyGoalsStartOfDay(ailyGoalsCreatedAt)
        let ailyGoalsToday = ailyGoalsDateHelpers.ailyGoalsStartOfDay(ailyGoalsReferenceDate)
        while ailyGoalsScan <= ailyGoalsToday {
            if ailyGoalsIsScheduled(ailyGoalsScan) {
                let ailyGoalsKey = ailyGoalsDateHelpers.ailyGoalsDayKey(for: ailyGoalsScan)
                if ailyGoalsCompletedKeys.contains(ailyGoalsKey) {
                    ailyGoalsRun += 1
                    ailyGoalsBest = max(ailyGoalsBest, ailyGoalsRun)
                } else {
                    ailyGoalsRun = 0
                }
            }
            ailyGoalsScan = ailyGoalsDateHelpers.ailyGoalsAddDays(1, to: ailyGoalsScan)
        }
        return ailyGoalsBest
    }

    static func ailyGoalsTaskCompletionPercent(ailyGoalsCompleted: Int, ailyGoalsTotal: Int) -> Double {
        guard ailyGoalsTotal > 0 else { return 0 }
        return Double(ailyGoalsCompleted) / Double(ailyGoalsTotal)
    }
}
