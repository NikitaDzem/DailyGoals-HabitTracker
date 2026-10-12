import SwiftUI

enum ailyGoalsTrackSegment: String, CaseIterable, Identifiable {
    case ailyGoalsHabits
    case ailyGoalsGoals

    var id: String { rawValue }

    var ailyGoalsTitle: String {
        switch self {
        case .ailyGoalsHabits: return "🔁 Habits"
        case .ailyGoalsGoals: return "🎯 Goals"
        }
    }
}

struct ailyGoalsTrackView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsSegment: ailyGoalsTrackSegment = .ailyGoalsHabits

    private var ailyGoalsBestStreak: Int {
        ailyGoalsViewModel.ailyGoalsActiveHabits.map(\.ailyGoalsBestStreak).max() ?? 0
    }

    private var ailyGoalsCurrentStreak: Int {
        ailyGoalsViewModel.ailyGoalsActiveHabits.map(\.ailyGoalsCurrentStreak).max() ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    ailyGoalsHeroBanner(
                        ailyGoalsEmoji: "🚀",
                        ailyGoalsTitle: "Track everything",
                        ailyGoalsSubtitle: "Habits build identity. Goals set the destination. Switch tabs below.",
                        ailyGoalsColors: [Color(ailyGoalsHex: "6042E8"), Color(ailyGoalsHex: "4389F7")]
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "🔁",
                            ailyGoalsValue: "\(ailyGoalsViewModel.ailyGoalsActiveHabits.count)",
                            ailyGoalsLabel: "Active habits",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftLavender
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "🔥",
                            ailyGoalsValue: "\(ailyGoalsCurrentStreak)",
                            ailyGoalsLabel: "Best current",
                            ailyGoalsTint: Color(ailyGoalsHex: "FFE8D6")
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "🎯",
                            ailyGoalsValue: "\(ailyGoalsViewModel.ailyGoalsActiveGoals.count)",
                            ailyGoalsLabel: "Active goals",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftBlue
                        )
                    }

                    Text("🏆 Record streak: \(ailyGoalsBestStreak) days")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                        .clipShape(Capsule())

                    Picker("Segment", selection: $ailyGoalsSegment) {
                        ForEach(ailyGoalsTrackSegment.allCases) { ailyGoalsItem in
                            Text(ailyGoalsItem.ailyGoalsTitle).tag(ailyGoalsItem)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, ailyGoalsAppTheme.ailyGoalsScreenPadding)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .onAppear {
                    ailyGoalsSegment = ailyGoalsViewModel.ailyGoalsPreferredTrackSegment
                }
                .onChange(of: ailyGoalsViewModel.ailyGoalsPreferredTrackSegment) { ailyGoalsValue in
                    ailyGoalsSegment = ailyGoalsValue
                }

                Group {
                    if ailyGoalsSegment == .ailyGoalsHabits {
                        ailyGoalsHabitsView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsEmbedded: true)
                    } else {
                        ailyGoalsGoalsView(ailyGoalsViewModel: ailyGoalsViewModel, ailyGoalsEmbedded: true)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(ailyGoalsHex: "F7F8FD"), Color(ailyGoalsHex: "EAF1FF"), Color(ailyGoalsHex: "FFF6FB")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
    }
}
