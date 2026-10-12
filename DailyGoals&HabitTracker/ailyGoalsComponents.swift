import SwiftUI

struct ailyGoalsPrimaryButton: View {
    let ailyGoalsTitle: String
    var ailyGoalsSystemImage: String? = nil
    let ailyGoalsAction: () -> Void

    var body: some View {
        Button(action: ailyGoalsAction) {
            HStack(spacing: 8) {
                if let ailyGoalsSystemImage {
                    Image(systemName: ailyGoalsSystemImage)
                }
                Text(ailyGoalsTitle)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(ailyGoalsScaleButtonStyle())
        .accessibilityLabel(ailyGoalsTitle)
    }
}

struct ailyGoalsSecondaryButton: View {
    let ailyGoalsTitle: String
    let ailyGoalsAction: () -> Void

    var body: some View {
        Button(action: ailyGoalsAction) {
            Text(ailyGoalsTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                .clipShape(Capsule())
        }
        .buttonStyle(ailyGoalsScaleButtonStyle())
    }
}

struct ailyGoalsScaleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !ailyGoalsReduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion), value: configuration.isPressed)
    }
}

struct ailyGoalsEmptyStateView: View {
    let ailyGoalsSymbol: String
    let ailyGoalsTitle: String
    let ailyGoalsMessage: String
    var ailyGoalsButtonTitle: String? = nil
    var ailyGoalsAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: ailyGoalsSymbol)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
                .frame(width: 72, height: 72)
                .background(ailyGoalsAppTheme.ailyGoalsSoftGradient)
                .clipShape(Circle())
            Text(ailyGoalsTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                .multilineTextAlignment(.center)
            Text(ailyGoalsMessage)
                .font(.system(size: 14))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                .multilineTextAlignment(.center)
            if let ailyGoalsButtonTitle, let ailyGoalsAction {
                ailyGoalsPrimaryButton(ailyGoalsTitle: ailyGoalsButtonTitle, ailyGoalsSystemImage: "plus", ailyGoalsAction: ailyGoalsAction)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .ailyGoalsAppCard()
    }
}

struct ailyGoalsSectionHeader: View {
    let ailyGoalsTitle: String
    var ailyGoalsActionTitle: String? = nil
    var ailyGoalsAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(ailyGoalsTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
            Spacer()
            if let ailyGoalsActionTitle, let ailyGoalsAction {
                Button(ailyGoalsActionTitle, action: ailyGoalsAction)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
            }
        }
    }
}

struct ailyGoalsFilterChip: View {
    let ailyGoalsTitle: String
    let ailyGoalsIsSelected: Bool
    let ailyGoalsAction: () -> Void

    var body: some View {
        Button(action: ailyGoalsAction) {
            Text(ailyGoalsTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ailyGoalsIsSelected ? .white : ailyGoalsAppTheme.ailyGoalsSecondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if ailyGoalsIsSelected {
                            Capsule().fill(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
                        } else {
                            Capsule().fill(ailyGoalsAppTheme.ailyGoalsSurface)
                        }
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(ailyGoalsIsSelected ? Color.clear : ailyGoalsAppTheme.ailyGoalsBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(ailyGoalsIsSelected ? .isSelected : [])
    }
}

struct ailyGoalsCircularProgress: View {
    let ailyGoalsProgress: Double
    var ailyGoalsLineWidth: CGFloat = 10
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: ailyGoalsLineWidth)
            Circle()
                .trim(from: 0, to: min(max(ailyGoalsProgress, 0), 1))
                .stroke(Color.white, style: StrokeStyle(lineWidth: ailyGoalsLineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion), value: ailyGoalsProgress)
            Text("\(Int((ailyGoalsProgress * 100).rounded()))%")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct ailyGoalsPriorityDot: View {
    let ailyGoalsPriority: ailyGoalsTaskPriority

    var ailyGoalsColor: Color {
        switch ailyGoalsPriority {
        case .ailyGoalsHigh: return ailyGoalsAppTheme.ailyGoalsDestructive
        case .ailyGoalsMedium: return ailyGoalsAppTheme.ailyGoalsWarning
        case .ailyGoalsLow: return ailyGoalsAppTheme.ailyGoalsSuccess
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flag.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(ailyGoalsColor)
            Text(ailyGoalsPriority.ailyGoalsTitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(ailyGoalsColor)
        }
        .accessibilityLabel("\(ailyGoalsPriority.ailyGoalsTitle) priority")
    }
}

struct ailyGoalsIconBadge: View {
    let ailyGoalsSymbol: String
    var ailyGoalsColor: Color = ailyGoalsAppTheme.ailyGoalsPrimaryPurple

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ailyGoalsColor.opacity(0.14))
                .frame(width: 44, height: 44)
            Image(systemName: ailyGoalsSymbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ailyGoalsColor)
        }
    }
}

struct ailyGoalsWeekDotsView: View {
    let ailyGoalsDots: [Bool?]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(Array(ailyGoalsDots.enumerated()), id: \.offset) { _, ailyGoalsValue in
                Circle()
                    .fill(ailyGoalsDotColor(ailyGoalsValue))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel("Weekly habit completion indicators")
    }

    private func ailyGoalsDotColor(_ ailyGoalsValue: Bool?) -> Color {
        guard let ailyGoalsValue else { return ailyGoalsAppTheme.ailyGoalsBorder }
        return ailyGoalsValue ? ailyGoalsAppTheme.ailyGoalsSuccess : ailyGoalsAppTheme.ailyGoalsSoftLavender
    }
}

struct ailyGoalsTaskRowView: View {
    let ailyGoalsTask: ailyGoalsTaskItem
    let ailyGoalsOnToggle: () -> Void
    let ailyGoalsOnEdit: () -> Void
    let ailyGoalsOnDelete: () -> Void
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Button(action: ailyGoalsOnToggle) {
                Image(systemName: ailyGoalsTask.ailyGoalsIsCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(ailyGoalsTask.ailyGoalsIsCompleted ? ailyGoalsAppTheme.ailyGoalsSuccess : ailyGoalsAppTheme.ailyGoalsMutedIcon)
                    .scaleEffect(ailyGoalsTask.ailyGoalsIsCompleted ? 1.05 : 1.0)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(ailyGoalsTask.ailyGoalsIsCompleted ? "Mark incomplete" : "Mark complete")

            VStack(alignment: .leading, spacing: 5) {
                Text(ailyGoalsTask.ailyGoalsTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    .strikethrough(ailyGoalsTask.ailyGoalsIsCompleted)
                    .opacity(ailyGoalsTask.ailyGoalsIsCompleted ? 0.55 : 1)
                HStack(spacing: 8) {
                    ailyGoalsPriorityDot(ailyGoalsPriority: ailyGoalsTask.ailyGoalsPriority)
                    if let ailyGoalsStart = ailyGoalsTask.ailyGoalsStartTime {
                        Label(ailyGoalsDateHelpers.ailyGoalsShortTime.string(from: ailyGoalsStart), systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                            .labelStyle(.titleAndIcon)
                    }
                    if let ailyGoalsCategory = ailyGoalsTask.ailyGoalsCategory {
                        Text(ailyGoalsCategory.ailyGoalsTitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                            .clipShape(Capsule())
                    }
                    if ailyGoalsTask.ailyGoalsIsOverdue {
                        Text("Overdue")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsDestructive)
                    }
                }
            }
            Spacer(minLength: 0)
            Menu {
                Button("Edit", systemImage: "pencil", action: ailyGoalsOnEdit)
                Button("Delete", systemImage: "trash", role: .destructive, action: ailyGoalsOnDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Task options")
        }
        .padding(14)
        .ailyGoalsAppCard()
        .animation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion), value: ailyGoalsTask.ailyGoalsIsCompleted)
    }
}

struct ailyGoalsHabitRowView: View {
    let ailyGoalsHabit: ailyGoalsHabitModel
    let ailyGoalsIsCompleted: Bool
    let ailyGoalsProgress: Double
    var ailyGoalsWeekDots: [Bool?] = []
    let ailyGoalsOnToggle: () -> Void
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    var body: some View {
        HStack(spacing: 12) {
            ailyGoalsIconBadge(
                ailyGoalsSymbol: ailyGoalsHabit.ailyGoalsSymbolName,
                ailyGoalsColor: Color(ailyGoalsHex: ailyGoalsHabit.ailyGoalsColorHex)
            )
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ailyGoalsHabit.ailyGoalsName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    Spacer(minLength: 0)
                    Label("\(ailyGoalsHabit.ailyGoalsCurrentStreak)", systemImage: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsWarning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ailyGoalsAppTheme.ailyGoalsWarning.opacity(0.12))
                        .clipShape(Capsule())
                        .accessibilityLabel("Current streak \(ailyGoalsHabit.ailyGoalsCurrentStreak) days")
                }
                Text("Best \(ailyGoalsHabit.ailyGoalsBestStreak) · \(ailyGoalsHabit.ailyGoalsCategory.ailyGoalsTitle)")
                    .font(.system(size: 12))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                if !ailyGoalsWeekDots.isEmpty {
                    ailyGoalsWeekDotsView(ailyGoalsDots: ailyGoalsWeekDots)
                }
                if ailyGoalsHabit.ailyGoalsDailyTarget > 1 {
                    ProgressView(value: ailyGoalsProgress)
                        .tint(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                }
            }
            Button(action: ailyGoalsOnToggle) {
                Image(systemName: ailyGoalsIsCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundColor(ailyGoalsIsCompleted ? ailyGoalsAppTheme.ailyGoalsSuccess : ailyGoalsAppTheme.ailyGoalsMutedIcon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(ailyGoalsIsCompleted ? "Habit completed" : "Mark habit complete")
        }
        .padding(14)
        .ailyGoalsAppCard()
        .animation(ailyGoalsAppTheme.ailyGoalsAnimation(ailyGoalsReduceMotion: ailyGoalsReduceMotion), value: ailyGoalsIsCompleted)
    }
}

struct ailyGoalsGoalCardView: View {
    let ailyGoalsGoal: ailyGoalsGoalModel
    var ailyGoalsOnTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { ailyGoalsOnTap?() }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label(ailyGoalsGoal.ailyGoalsCategory.ailyGoalsTitle, systemImage: ailyGoalsGoal.ailyGoalsCategory.ailyGoalsSymbolName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                    Spacer()
                    if let ailyGoalsDate = ailyGoalsGoal.ailyGoalsTargetDate {
                        Text(ailyGoalsDateHelpers.ailyGoalsMediumDate.string(from: ailyGoalsDate))
                            .font(.system(size: 12))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    }
                }
                Text(ailyGoalsGoal.ailyGoalsTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    .multilineTextAlignment(.leading)
                ProgressView(value: ailyGoalsGoal.ailyGoalsProgressFraction)
                    .tint(ailyGoalsAppTheme.ailyGoalsAccentBlue)
                HStack {
                    Text("\(ailyGoalsGoal.ailyGoalsProgressPercent)%")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    Spacer()
                    if !ailyGoalsGoal.ailyGoalsMilestones.isEmpty {
                        Text("\(ailyGoalsGoal.ailyGoalsCompletedMilestoneCount)/\(ailyGoalsGoal.ailyGoalsMilestones.count) milestones")
                            .font(.system(size: 12))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    } else if let ailyGoalsTarget = ailyGoalsGoal.ailyGoalsTargetValue {
                        Text("\(Int(ailyGoalsGoal.ailyGoalsCurrentValue))/\(Int(ailyGoalsTarget)) \(ailyGoalsGoal.ailyGoalsUnitLabel)")
                            .font(.system(size: 12))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    }
                }
            }
            .padding(16)
            .ailyGoalsAppCard()
        }
        .buttonStyle(.plain)
        .disabled(ailyGoalsOnTap == nil)
    }
}

struct ailyGoalsShareSheet: UIViewControllerRepresentable {
    let ailyGoalsItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: ailyGoalsItems, applicationActivities: nil)
    }

    func updateUIViewController(_ ailyGoalsController: UIActivityViewController, context: Context) {}
}
