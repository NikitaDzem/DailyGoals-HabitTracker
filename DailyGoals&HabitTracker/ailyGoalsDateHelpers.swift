import Foundation

enum ailyGoalsDateHelpers {
    static var ailyGoalsCalendar: Calendar {
        var ailyGoalsCal = Calendar.current
        ailyGoalsCal.timeZone = .current
        return ailyGoalsCal
    }

    static func ailyGoalsStartOfDay(_ ailyGoalsDate: Date) -> Date {
        ailyGoalsCalendar.startOfDay(for: ailyGoalsDate)
    }

    static func ailyGoalsIsSameDay(_ ailyGoalsLhs: Date, _ ailyGoalsRhs: Date) -> Bool {
        ailyGoalsCalendar.isDate(ailyGoalsLhs, inSameDayAs: ailyGoalsRhs)
    }

    static func ailyGoalsIsToday(_ ailyGoalsDate: Date) -> Bool {
        ailyGoalsCalendar.isDateInToday(ailyGoalsDate)
    }

    static func ailyGoalsWeekdayIndex(_ ailyGoalsDate: Date) -> Int {
        ailyGoalsCalendar.component(.weekday, from: ailyGoalsDate)
    }

    static func ailyGoalsDaysInMonth(for ailyGoalsDate: Date) -> Int {
        ailyGoalsCalendar.range(of: .day, in: .month, for: ailyGoalsDate)?.count ?? 30
    }

    static func ailyGoalsFirstDayOfMonth(for ailyGoalsDate: Date) -> Date {
        let ailyGoalsComps = ailyGoalsCalendar.dateComponents([.year, .month], from: ailyGoalsDate)
        return ailyGoalsCalendar.date(from: ailyGoalsComps) ?? ailyGoalsDate
    }

    static func ailyGoalsAddMonths(_ ailyGoalsValue: Int, to ailyGoalsDate: Date) -> Date {
        ailyGoalsCalendar.date(byAdding: .month, value: ailyGoalsValue, to: ailyGoalsDate) ?? ailyGoalsDate
    }

    static func ailyGoalsAddDays(_ ailyGoalsValue: Int, to ailyGoalsDate: Date) -> Date {
        ailyGoalsCalendar.date(byAdding: .day, value: ailyGoalsValue, to: ailyGoalsDate) ?? ailyGoalsDate
    }

    static func ailyGoalsCombine(ailyGoalsDate: Date, ailyGoalsTime: Date) -> Date {
        let ailyGoalsDay = ailyGoalsCalendar.dateComponents([.year, .month, .day], from: ailyGoalsDate)
        let ailyGoalsClock = ailyGoalsCalendar.dateComponents([.hour, .minute], from: ailyGoalsTime)
        var ailyGoalsMerged = DateComponents()
        ailyGoalsMerged.year = ailyGoalsDay.year
        ailyGoalsMerged.month = ailyGoalsDay.month
        ailyGoalsMerged.day = ailyGoalsDay.day
        ailyGoalsMerged.hour = ailyGoalsClock.hour
        ailyGoalsMerged.minute = ailyGoalsClock.minute
        return ailyGoalsCalendar.date(from: ailyGoalsMerged) ?? ailyGoalsDate
    }

    static func ailyGoalsStartOfWeek(for ailyGoalsDate: Date, ailyGoalsFirstWeekday: Int) -> Date {
        var ailyGoalsCal = ailyGoalsCalendar
        ailyGoalsCal.firstWeekday = ailyGoalsFirstWeekday
        return ailyGoalsCal.dateInterval(of: .weekOfYear, for: ailyGoalsDate)?.start ?? ailyGoalsStartOfDay(ailyGoalsDate)
    }

    static let ailyGoalsDayMonthYear: DateFormatter = {
        let ailyGoalsFormatter = DateFormatter()
        ailyGoalsFormatter.dateStyle = .full
        ailyGoalsFormatter.timeStyle = .none
        return ailyGoalsFormatter
    }()

    static let ailyGoalsMonthYear: DateFormatter = {
        let ailyGoalsFormatter = DateFormatter()
        ailyGoalsFormatter.dateFormat = "MMMM yyyy"
        return ailyGoalsFormatter
    }()

    static let ailyGoalsShortTime: DateFormatter = {
        let ailyGoalsFormatter = DateFormatter()
        ailyGoalsFormatter.timeStyle = .short
        ailyGoalsFormatter.dateStyle = .none
        return ailyGoalsFormatter
    }()

    static let ailyGoalsMediumDate: DateFormatter = {
        let ailyGoalsFormatter = DateFormatter()
        ailyGoalsFormatter.dateStyle = .medium
        ailyGoalsFormatter.timeStyle = .none
        return ailyGoalsFormatter
    }()

    static let ailyGoalsDayKeyFormatter: DateFormatter = {
        let ailyGoalsFormatter = DateFormatter()
        ailyGoalsFormatter.calendar = Calendar(identifier: .gregorian)
        ailyGoalsFormatter.locale = Locale(identifier: "en_US_POSIX")
        ailyGoalsFormatter.timeZone = .current
        ailyGoalsFormatter.dateFormat = "yyyy-MM-dd"
        return ailyGoalsFormatter
    }()

    static func ailyGoalsDayKey(for ailyGoalsDate: Date) -> String {
        ailyGoalsDayKeyFormatter.string(from: ailyGoalsStartOfDay(ailyGoalsDate))
    }

    static func ailyGoalsGreeting(for ailyGoalsDate: Date = Date()) -> String {
        let ailyGoalsHour = ailyGoalsCalendar.component(.hour, from: ailyGoalsDate)
        if ailyGoalsHour < 12 {
            return "Good morning!"
        } else if ailyGoalsHour < 17 {
            return "Good afternoon!"
        } else {
            return "Good evening!"
        }
    }

    static func ailyGoalsMotivationalMessage() -> String {
        let ailyGoalsMessages = [
            "Make today count.",
            "Small steps build big results.",
            "Stay consistent and keep going.",
            "Focus on progress, not perfection.",
            "Your future self will thank you."
        ]
        let ailyGoalsIndex = abs(ailyGoalsDayKey(for: Date()).hashValue) % ailyGoalsMessages.count
        return ailyGoalsMessages[ailyGoalsIndex]
    }
}
