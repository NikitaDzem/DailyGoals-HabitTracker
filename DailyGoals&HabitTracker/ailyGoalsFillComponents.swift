import SwiftUI

struct ailyGoalsHeroBanner: View {
    let ailyGoalsEmoji: String
    let ailyGoalsTitle: String
    let ailyGoalsSubtitle: String
    var ailyGoalsColors: [Color] = [ailyGoalsAppTheme.ailyGoalsPrimaryPurple, ailyGoalsAppTheme.ailyGoalsAccentBlue]

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Text(ailyGoalsEmoji)
                .font(.system(size: 44))
                .frame(width: 64, height: 64)
                .background(Color.white.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            VStack(alignment: .leading, spacing: 6) {
                Text(ailyGoalsTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(ailyGoalsSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(colors: ailyGoalsColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: (ailyGoalsColors.first ?? .purple).opacity(0.28), radius: 12, y: 6)
    }
}

struct ailyGoalsSnapshotTile: View {
    let ailyGoalsEmoji: String
    let ailyGoalsValue: String
    let ailyGoalsLabel: String
    var ailyGoalsTint: Color = ailyGoalsAppTheme.ailyGoalsSoftLavender

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ailyGoalsEmoji)
                .font(.system(size: 22))
            Text(ailyGoalsValue)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(ailyGoalsLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(ailyGoalsTint)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ailyGoalsTipCard: View {
    let ailyGoalsEmoji: String
    let ailyGoalsTitle: String
    let ailyGoalsMessage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(ailyGoalsEmoji)
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 4) {
                Text(ailyGoalsTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                Text(ailyGoalsMessage)
                    .font(.system(size: 13))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [ailyGoalsAppTheme.ailyGoalsSoftLavender, ailyGoalsAppTheme.ailyGoalsSoftBlue],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ailyGoalsShortcutChip: View {
    let ailyGoalsEmoji: String
    let ailyGoalsTitle: String
    let ailyGoalsAction: () -> Void

    var body: some View {
        Button(action: ailyGoalsAction) {
            HStack(spacing: 8) {
                Text(ailyGoalsEmoji)
                Text(ailyGoalsTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(ailyGoalsAppTheme.ailyGoalsSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(ailyGoalsAppTheme.ailyGoalsBorder, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
        .buttonStyle(ailyGoalsScaleButtonStyle())
    }
}
