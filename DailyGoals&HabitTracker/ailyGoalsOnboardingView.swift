import SwiftUI

struct ailyGoalsOnboardingPage: Identifiable {
    let id = UUID()
    let ailyGoalsEmoji: String
    let ailyGoalsTitle: String
    let ailyGoalsMessage: String
    let ailyGoalsAccent: [Color]
}

struct ailyGoalsOnboardingView: View {
    @Binding var ailyGoalsHasCompletedOnboarding: Bool
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsPage = 0
    @State private var ailyGoalsFloat = false
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    private let ailyGoalsPages = [
        ailyGoalsOnboardingPage(
            ailyGoalsEmoji: "✅",
            ailyGoalsTitle: "Plan Your Day",
            ailyGoalsMessage: "Organize tasks and priorities so every morning starts with clarity and calm focus.",
            ailyGoalsAccent: [Color(ailyGoalsHex: "7657F6"), Color(ailyGoalsHex: "4389F7")]
        ),
        ailyGoalsOnboardingPage(
            ailyGoalsEmoji: "🔥",
            ailyGoalsTitle: "Build Better Habits",
            ailyGoalsMessage: "Create routines that stick, grow your streaks, and turn small actions into lasting wins.",
            ailyGoalsAccent: [Color(ailyGoalsHex: "F2A94A"), Color(ailyGoalsHex: "E45E70")]
        ),
        ailyGoalsOnboardingPage(
            ailyGoalsEmoji: "🎯",
            ailyGoalsTitle: "Reach Your Goals",
            ailyGoalsMessage: "Track milestones, see progress unfold, and celebrate every goal you complete.",
            ailyGoalsAccent: [Color(ailyGoalsHex: "20B486"), Color(ailyGoalsHex: "4389F7")]
        )
    ]

    var body: some View {
        ZStack {
            ailyGoalsBackground

            VStack(spacing: 0) {
                HStack {
                    Text("Daily Goals")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                    Spacer()
                    Button("Skip") {
                        ailyGoalsFinish()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                TabView(selection: $ailyGoalsPage) {
                    ForEach(Array(ailyGoalsPages.enumerated()), id: \.offset) { ailyGoalsIndex, ailyGoalsItem in
                        ailyGoalsPageContent(ailyGoalsItem)
                            .tag(ailyGoalsIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: ailyGoalsPage)

                ailyGoalsPageDots
                    .padding(.bottom, 22)

                if ailyGoalsPage < ailyGoalsPages.count - 1 {
                    ailyGoalsPrimaryButton(ailyGoalsTitle: "Continue", ailyGoalsSystemImage: "arrow.right") {
                        withAnimation(.easeInOut(duration: 0.28)) {
                            ailyGoalsPage += 1
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    ailyGoalsPrimaryButton(ailyGoalsTitle: "Get Started", ailyGoalsSystemImage: "sparkles") {
                        ailyGoalsFinish()
                    }
                    .padding(.horizontal, 24)
                }

                Text("Offline · Private · On your device")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsMutedIcon)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
            }
        }
        .onAppear {
            guard !ailyGoalsReduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                ailyGoalsFloat = true
            }
        }
        .onChange(of: ailyGoalsPage) { _ in
            ailyGoalsFloat = false
            guard !ailyGoalsReduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                ailyGoalsFloat = true
            }
        }
    }

    private var ailyGoalsBackground: some View {
        ZStack {
            ailyGoalsAppTheme.ailyGoalsBackground
            Circle()
                .fill(ailyGoalsAppTheme.ailyGoalsSoftLavender.opacity(0.9))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: -120, y: -260)
            Circle()
                .fill(ailyGoalsAppTheme.ailyGoalsSoftBlue.opacity(0.85))
                .frame(width: 260, height: 260)
                .blur(radius: 45)
                .offset(x: 130, y: 280)
        }
        .ignoresSafeArea()
    }

    private func ailyGoalsPageContent(_ ailyGoalsItem: ailyGoalsOnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: ailyGoalsItem.ailyGoalsAccent.map { $0.opacity(0.22) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 210, height: 210)

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: ailyGoalsItem.ailyGoalsAccent,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 176, height: 176)
                    .opacity(0.45)

                Text(ailyGoalsItem.ailyGoalsEmoji)
                    .font(.system(size: 78))
                    .offset(y: ailyGoalsFloat ? -8 : 8)
                    .shadow(color: ailyGoalsItem.ailyGoalsAccent.first?.opacity(0.28) ?? .clear, radius: 16, y: 8)
            }

            VStack(spacing: 14) {
                Text(ailyGoalsItem.ailyGoalsTitle)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                    .multilineTextAlignment(.center)

                Text(ailyGoalsItem.ailyGoalsMessage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 28)
            }

            Spacer(minLength: 12)
        }
    }

    private var ailyGoalsPageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<ailyGoalsPages.count, id: \.self) { ailyGoalsIndex in
                Capsule()
                    .fill(
                        ailyGoalsIndex == ailyGoalsPage
                        ? ailyGoalsAppTheme.ailyGoalsPrimaryPurple
                        : ailyGoalsAppTheme.ailyGoalsBorder
                    )
                    .frame(
                        width: ailyGoalsIndex == ailyGoalsPage ? 22 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: ailyGoalsPage)
            }
        }
    }

    private func ailyGoalsFinish() {
        ailyGoalsViewModel.ailyGoalsCompleteOnboarding()
        withAnimation(.easeInOut(duration: 0.35)) {
            ailyGoalsHasCompletedOnboarding = true
        }
    }
}

#Preview {
    ailyGoalsOnboardingView(
        ailyGoalsHasCompletedOnboarding: .constant(false),
        ailyGoalsViewModel: ailyGoalsAppViewModel()
    )
}
