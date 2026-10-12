import SwiftUI

enum ailyGoalsAppTheme {
    static let ailyGoalsBackground = Color(ailyGoalsHex: "F7F8FD")
    static let ailyGoalsSurface = Color(ailyGoalsHex: "FFFFFF")
    static let ailyGoalsPrimaryPurple = Color(ailyGoalsHex: "7657F6")
    static let ailyGoalsDeepPurple = Color(ailyGoalsHex: "6042E8")
    static let ailyGoalsSecondaryPurple = Color(ailyGoalsHex: "6042E8")
    static let ailyGoalsAccentBlue = Color(ailyGoalsHex: "4389F7")
    static let ailyGoalsSoftLavender = Color(ailyGoalsHex: "F0EBFF")
    static let ailyGoalsSoftBlue = Color(ailyGoalsHex: "EAF1FF")
    static let ailyGoalsPrimaryText = Color(ailyGoalsHex: "202137")
    static let ailyGoalsSecondaryText = Color(ailyGoalsHex: "777B91")
    static let ailyGoalsSuccess = Color(ailyGoalsHex: "20B486")
    static let ailyGoalsWarning = Color(ailyGoalsHex: "F2A94A")
    static let ailyGoalsDestructive = Color(ailyGoalsHex: "E45E70")
    static let ailyGoalsBorder = Color(ailyGoalsHex: "E6E8F0")
    static let ailyGoalsMutedIcon = Color(ailyGoalsHex: "9A9BAD")
    static let ailyGoalsCardRadius: CGFloat = 22
    static let ailyGoalsScreenPadding: CGFloat = 20
    static let ailyGoalsSpacing: CGFloat = 8
    static let ailyGoalsCardShadow = Color.black.opacity(0.05)

    static let ailyGoalsPrimaryGradient = LinearGradient(
        colors: [ailyGoalsPrimaryPurple, ailyGoalsAccentBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ailyGoalsSoftGradient = LinearGradient(
        colors: [ailyGoalsSoftLavender, ailyGoalsSoftBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func ailyGoalsAnimation(ailyGoalsReduceMotion: Bool) -> Animation? {
        ailyGoalsReduceMotion ? nil : .easeInOut(duration: 0.28)
    }
}

extension Color {
    init(ailyGoalsHex ailyGoalsValue: String) {
        let ailyGoalsCleaned = ailyGoalsValue.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var ailyGoalsInt: UInt64 = 0
        Scanner(string: ailyGoalsCleaned).scanHexInt64(&ailyGoalsInt)
        let ailyGoalsA: UInt64
        let ailyGoalsR: UInt64
        let ailyGoalsG: UInt64
        let ailyGoalsB: UInt64
        switch ailyGoalsCleaned.count {
        case 3:
            ailyGoalsA = 255
            ailyGoalsR = (ailyGoalsInt >> 8) * 17
            ailyGoalsG = (ailyGoalsInt >> 4 & 0xF) * 17
            ailyGoalsB = (ailyGoalsInt & 0xF) * 17
        case 6:
            ailyGoalsA = 255
            ailyGoalsR = ailyGoalsInt >> 16
            ailyGoalsG = ailyGoalsInt >> 8 & 0xFF
            ailyGoalsB = ailyGoalsInt & 0xFF
        case 8:
            ailyGoalsA = ailyGoalsInt >> 24
            ailyGoalsR = ailyGoalsInt >> 16 & 0xFF
            ailyGoalsG = ailyGoalsInt >> 8 & 0xFF
            ailyGoalsB = ailyGoalsInt & 0xFF
        default:
            ailyGoalsA = 255
            ailyGoalsR = 0
            ailyGoalsG = 0
            ailyGoalsB = 0
        }
        self.init(
            .sRGB,
            red: Double(ailyGoalsR) / 255,
            green: Double(ailyGoalsG) / 255,
            blue: Double(ailyGoalsB) / 255,
            opacity: Double(ailyGoalsA) / 255
        )
    }
}

struct ailyGoalsCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ailyGoalsAppTheme.ailyGoalsSurface)
            .clipShape(RoundedRectangle(cornerRadius: ailyGoalsAppTheme.ailyGoalsCardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ailyGoalsAppTheme.ailyGoalsCardRadius, style: .continuous)
                    .stroke(ailyGoalsAppTheme.ailyGoalsBorder.opacity(0.65), lineWidth: 1)
            )
            .shadow(color: ailyGoalsAppTheme.ailyGoalsCardShadow, radius: 12, x: 0, y: 4)
    }
}

extension View {
    func ailyGoalsAppCard() -> some View {
        modifier(ailyGoalsCardStyle())
    }
}
