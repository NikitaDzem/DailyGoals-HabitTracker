import UIKit

enum ailyGoalsHapticService {
    static func ailyGoalsImpact(ailyGoalsEnabled: Bool) {
        guard ailyGoalsEnabled else { return }
        let ailyGoalsGenerator = UIImpactFeedbackGenerator(style: .light)
        ailyGoalsGenerator.impactOccurred()
    }

    static func ailyGoalsSuccess(ailyGoalsEnabled: Bool) {
        guard ailyGoalsEnabled else { return }
        let ailyGoalsGenerator = UINotificationFeedbackGenerator()
        ailyGoalsGenerator.notificationOccurred(.success)
    }
}
