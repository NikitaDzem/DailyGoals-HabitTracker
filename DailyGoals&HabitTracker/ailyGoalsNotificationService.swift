import Foundation
import UserNotifications

final class ailyGoalsNotificationService {
    static let ailyGoalsShared = ailyGoalsNotificationService()

    private let ailyGoalsCenter = UNUserNotificationCenter.current()

    private init() {}

    func ailyGoalsAuthorizationStatus(ailyGoalsCompletion: @escaping (UNAuthorizationStatus) -> Void) {
        ailyGoalsCenter.getNotificationSettings { ailyGoalsSettings in
            DispatchQueue.main.async {
                ailyGoalsCompletion(ailyGoalsSettings.authorizationStatus)
            }
        }
    }

    func ailyGoalsRequestAuthorization(ailyGoalsCompletion: @escaping (Bool) -> Void) {
        ailyGoalsCenter.requestAuthorization(options: [.alert, .sound, .badge]) { ailyGoalsGranted, _ in
            DispatchQueue.main.async {
                ailyGoalsCompletion(ailyGoalsGranted)
            }
        }
    }

    func ailyGoalsCancel(ailyGoalsIdentifier: String) {
        ailyGoalsCenter.removePendingNotificationRequests(withIdentifiers: [ailyGoalsIdentifier])
    }

    func ailyGoalsCancelAll() {
        ailyGoalsCenter.removeAllPendingNotificationRequests()
    }

    func ailyGoalsScheduleTaskReminder(for ailyGoalsTask: ailyGoalsTaskItem, ailyGoalsCompletion: ((Bool) -> Void)? = nil) {
        ailyGoalsCancel(ailyGoalsIdentifier: ailyGoalsTask.ailyGoalsNotificationIdentifier)
        guard !ailyGoalsTask.ailyGoalsIsCompleted,
              let ailyGoalsReminder = ailyGoalsTask.ailyGoalsReminderDate,
              ailyGoalsReminder > Date() else {
            ailyGoalsCompletion?(false)
            return
        }
        let ailyGoalsContent = UNMutableNotificationContent()
        ailyGoalsContent.title = "Task Reminder"
        ailyGoalsContent.body = ailyGoalsTask.ailyGoalsTitle
        ailyGoalsContent.sound = .default
        let ailyGoalsComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: ailyGoalsReminder
        )
        let ailyGoalsTrigger = UNCalendarNotificationTrigger(dateMatching: ailyGoalsComponents, repeats: false)
        let ailyGoalsRequest = UNNotificationRequest(
            identifier: ailyGoalsTask.ailyGoalsNotificationIdentifier,
            content: ailyGoalsContent,
            trigger: ailyGoalsTrigger
        )
        ailyGoalsCenter.add(ailyGoalsRequest) { ailyGoalsError in
            DispatchQueue.main.async {
                ailyGoalsCompletion?(ailyGoalsError == nil)
            }
        }
    }

    func ailyGoalsScheduleHabitReminder(for ailyGoalsHabit: ailyGoalsHabitModel, ailyGoalsCompletion: ((Bool) -> Void)? = nil) {
        ailyGoalsCancelHabitReminders(for: ailyGoalsHabit)
        guard !ailyGoalsHabit.ailyGoalsIsArchived,
              ailyGoalsHabit.ailyGoalsReminderEnabled,
              let ailyGoalsTime = ailyGoalsHabit.ailyGoalsReminderTime else {
            ailyGoalsCompletion?(false)
            return
        }
        let ailyGoalsContent = UNMutableNotificationContent()
        ailyGoalsContent.title = "Habit Reminder"
        ailyGoalsContent.body = ailyGoalsHabit.ailyGoalsName
        ailyGoalsContent.sound = .default
        let ailyGoalsClock = Calendar.current.dateComponents([.hour, .minute], from: ailyGoalsTime)
        let ailyGoalsWeekdays = ailyGoalsHabit.ailyGoalsEffectiveWeekdays()
        guard !ailyGoalsWeekdays.isEmpty else {
            ailyGoalsCompletion?(false)
            return
        }
        let ailyGoalsGroup = DispatchGroup()
        var ailyGoalsDidSucceed = false
        for ailyGoalsWeekday in ailyGoalsWeekdays {
            ailyGoalsGroup.enter()
            var ailyGoalsComponents = DateComponents()
            ailyGoalsComponents.weekday = ailyGoalsWeekday
            ailyGoalsComponents.hour = ailyGoalsClock.hour
            ailyGoalsComponents.minute = ailyGoalsClock.minute
            let ailyGoalsTrigger = UNCalendarNotificationTrigger(dateMatching: ailyGoalsComponents, repeats: true)
            let ailyGoalsIdentifier = "\(ailyGoalsHabit.ailyGoalsNotificationIdentifier)-\(ailyGoalsWeekday)"
            let ailyGoalsRequest = UNNotificationRequest(
                identifier: ailyGoalsIdentifier,
                content: ailyGoalsContent,
                trigger: ailyGoalsTrigger
            )
            ailyGoalsCenter.add(ailyGoalsRequest) { ailyGoalsError in
                if ailyGoalsError == nil {
                    ailyGoalsDidSucceed = true
                }
                ailyGoalsGroup.leave()
            }
        }
        ailyGoalsGroup.notify(queue: .main) {
            ailyGoalsCompletion?(ailyGoalsDidSucceed)
        }
    }

    func ailyGoalsCancelHabitReminders(for ailyGoalsHabit: ailyGoalsHabitModel) {
        ailyGoalsCancel(ailyGoalsIdentifier: ailyGoalsHabit.ailyGoalsNotificationIdentifier)
        for ailyGoalsWeekday in 1...7 {
            ailyGoalsCancel(ailyGoalsIdentifier: "\(ailyGoalsHabit.ailyGoalsNotificationIdentifier)-\(ailyGoalsWeekday)")
        }
    }
}
