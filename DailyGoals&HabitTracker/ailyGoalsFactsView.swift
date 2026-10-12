import SwiftUI

struct ailyGoalsFactItem: Identifiable {
    let id: Int
    let ailyGoalsEmoji: String
    let ailyGoalsTitle: String
    let ailyGoalsSubtitle: String
    let ailyGoalsBody: String
    let ailyGoalsGradient: [Color]
}

enum ailyGoalsFactsCatalog {
    static let ailyGoalsItems: [ailyGoalsFactItem] = [
        ailyGoalsFactItem(
            id: 1,
            ailyGoalsEmoji: "🧠",
            ailyGoalsTitle: "Tiny Wins Rewire Your Brain",
            ailyGoalsSubtitle: "Science of progress",
            ailyGoalsBody: "Each completed task releases a small dose of dopamine. That chemical reward teaches your brain to repeat productive actions. Start with a two-minute win — make the bed, open the notebook, or write one sentence — and momentum grows naturally. Consistency beats intensity when you are building identity as someone who finishes what they start.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "7657F6"), Color(ailyGoalsHex: "4389F7")]
        ),
        ailyGoalsFactItem(
            id: 2,
            ailyGoalsEmoji: "🔥",
            ailyGoalsTitle: "Streaks Protect Motivation",
            ailyGoalsSubtitle: "Habit science",
            ailyGoalsBody: "A visible streak creates loss aversion: people work harder to avoid breaking a chain than to gain a new reward. That is why habit trackers feel powerful. If you miss a day, restart immediately — the goal is never perfection, it is never missing twice. Protect the chain with a minimum viable version of the habit on busy days.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "F2A94A"), Color(ailyGoalsHex: "E45E70")]
        ),
        ailyGoalsFactItem(
            id: 3,
            ailyGoalsEmoji: "☀️",
            ailyGoalsTitle: "Mornings Shape the Day",
            ailyGoalsSubtitle: "Energy & focus",
            ailyGoalsBody: "Your prefrontal cortex — the focus and decision center — is freshest earlier for many people. Planning three priorities before noon reduces decision fatigue later. Pair a short planning ritual with water, light, and movement to wake both body and attention. A clear morning agenda turns chaos into a checklist.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "F2A94A"), Color(ailyGoalsHex: "7657F6")]
        ),
        ailyGoalsFactItem(
            id: 4,
            ailyGoalsEmoji: "🎯",
            ailyGoalsTitle: "Goals Need Finish Lines",
            ailyGoalsSubtitle: "Clarity beats hope",
            ailyGoalsBody: "Vague goals like “get healthier” rarely stick. Measurable targets — 12 books, 20 workouts, 30 study hours — give your brain a finish line. Break the target into milestones so progress stays visible every week. Celebrate each milestone; celebration is fuel, not distraction.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "20B486"), Color(ailyGoalsHex: "4389F7")]
        ),
        ailyGoalsFactItem(
            id: 5,
            ailyGoalsEmoji: "🧘",
            ailyGoalsTitle: "Rest Is Productive",
            ailyGoalsSubtitle: "Recovery matters",
            ailyGoalsBody: "Deep focus needs recovery. Short breaks every 50–90 minutes restore attention and creativity. Sleep consolidates learning and emotional regulation. Treat rest like a scheduled task: walks, stretching, or quiet minutes without screens. Burnout is not a badge of honor — it is lost progress.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "20B486"), Color(ailyGoalsHex: "7657F6")]
        ),
        ailyGoalsFactItem(
            id: 6,
            ailyGoalsEmoji: "📱",
            ailyGoalsTitle: "Notifications Steal Focus",
            ailyGoalsSubtitle: "Attention economy",
            ailyGoalsBody: "Every ping pulls working memory offline. Batch checks and use reminders only for what truly matters. In this app, reminders exist to support your plan — not to interrupt every few minutes. Silence nonessential alerts during deep work blocks and watch how much calmer your day becomes.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "4389F7"), Color(ailyGoalsHex: "6042E8")]
        ),
        ailyGoalsFactItem(
            id: 7,
            ailyGoalsEmoji: "✍️",
            ailyGoalsTitle: "Writing Clarifies Thinking",
            ailyGoalsSubtitle: "Capture & decide",
            ailyGoalsBody: "Externalizing thoughts into tasks and notes reduces mental load. Your brain is for having ideas, not storing endless open loops. Capture quickly, then organize once. A messy inbox of ideas is fine — a messy day of unmarked priorities is not. Clarity on paper becomes calm in action.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "A66BFA"), Color(ailyGoalsHex: "4389F7")]
        ),
        ailyGoalsFactItem(
            id: 8,
            ailyGoalsEmoji: "🏃",
            ailyGoalsTitle: "Movement Boosts Mood",
            ailyGoalsSubtitle: "Body → mind",
            ailyGoalsBody: "Even ten minutes of movement can lift mood and sharpen focus by increasing blood flow and endorphins. Link a tiny movement habit to an existing cue: after morning coffee, stretch; after lunch, walk. Fitness goals feel lighter when they ride on routines you already own.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "E45E70"), Color(ailyGoalsHex: "F2A94A")]
        ),
        ailyGoalsFactItem(
            id: 9,
            ailyGoalsEmoji: "🤝",
            ailyGoalsTitle: "Accountability Multiplies Odds",
            ailyGoalsSubtitle: "Social fuel",
            ailyGoalsBody: "Sharing a goal with someone supportive increases follow-through. You do not need public pressure — a weekly check-in is enough. Use progress cards and streaks as personal accountability, and celebrate wins out loud. Community turns lonely discipline into shared energy.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "7657F6"), Color(ailyGoalsHex: "20B486")]
        ),
        ailyGoalsFactItem(
            id: 10,
            ailyGoalsEmoji: "🌟",
            ailyGoalsTitle: "Identity Drives Habits",
            ailyGoalsSubtitle: "Become the person",
            ailyGoalsBody: "The strongest habits come from identity: “I am someone who shows up.” Every checkmark is a vote for that identity. Missed days do not erase the identity if you return. Design habits that match who you want to become, not who you feel obligated to impress. Small daily votes build remarkable years.",
            ailyGoalsGradient: [Color(ailyGoalsHex: "6042E8"), Color(ailyGoalsHex: "F2A94A")]
        )
    ]
}

struct ailyGoalsFactsView: View {
    @State private var ailyGoalsSelectedFact: ailyGoalsFactItem?

    private let ailyGoalsColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ailyGoalsHeroBanner(
                        ailyGoalsEmoji: "✨",
                        ailyGoalsTitle: "Daily Facts",
                        ailyGoalsSubtitle: "10 colorful cards packed with motivation science. Tap any card to open the full story.",
                        ailyGoalsColors: [Color(ailyGoalsHex: "A66BFA"), Color(ailyGoalsHex: "4389F7")]
                    )

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["🧠 Brain", "🔥 Habits", "🎯 Goals", "🧘 Rest", "✍️ Focus"], id: \.self) { ailyGoalsTag in
                                Text(ailyGoalsTag)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(ailyGoalsAppTheme.ailyGoalsBorder, lineWidth: 1))
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "📚",
                            ailyGoalsValue: "\(ailyGoalsFactsCatalog.ailyGoalsItems.count)",
                            ailyGoalsLabel: "Facts ready",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftLavender
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "💡",
                            ailyGoalsValue: "1 tap",
                            ailyGoalsLabel: "Opens full story",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftBlue
                        )
                    }

                    Text("🌈 Pick a bright card")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)

                    LazyVGrid(columns: ailyGoalsColumns, spacing: 12) {
                        ForEach(ailyGoalsFactsCatalog.ailyGoalsItems) { ailyGoalsFact in
                            Button {
                                ailyGoalsSelectedFact = ailyGoalsFact
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(ailyGoalsFact.ailyGoalsEmoji)
                                        .font(.system(size: 34))
                                    Text(ailyGoalsFact.ailyGoalsTitle)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3)
                                    Text(ailyGoalsFact.ailyGoalsSubtitle)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                                .background(
                                    LinearGradient(
                                        colors: ailyGoalsFact.ailyGoalsGradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: ailyGoalsFact.ailyGoalsGradient.first?.opacity(0.35) ?? .clear, radius: 10, x: 0, y: 6)
                            }
                            .buttonStyle(ailyGoalsScaleButtonStyle())
                            .accessibilityLabel("\(ailyGoalsFact.ailyGoalsTitle). \(ailyGoalsFact.ailyGoalsSubtitle)")
                        }
                    }

                    ailyGoalsTipCard(
                        ailyGoalsEmoji: "🚀",
                        ailyGoalsTitle: "Make it real",
                        ailyGoalsMessage: "After reading a fact, create one task or habit that applies it today. Knowledge sticks when it becomes action."
                    )
                }
                .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
            }
            .background(
                LinearGradient(
                    colors: [Color(ailyGoalsHex: "F7F8FD"), Color(ailyGoalsHex: "F0EBFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .sheet(item: $ailyGoalsSelectedFact) { ailyGoalsFact in
                ailyGoalsFactDetailView(ailyGoalsFact: ailyGoalsFact)
            }
        }
    }
}

struct ailyGoalsFactDetailView: View {
    let ailyGoalsFact: ailyGoalsFactItem
    @Environment(\.dismiss) private var ailyGoalsDismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: ailyGoalsFact.ailyGoalsGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 220)
                        .overlay(
                            Text(ailyGoalsFact.ailyGoalsEmoji)
                                .font(.system(size: 88))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .padding(24)
                                .opacity(0.95)
                        )
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ailyGoalsFact.ailyGoalsSubtitle.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.85))
                            Text(ailyGoalsFact.ailyGoalsTitle)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(20)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Text(ailyGoalsFact.ailyGoalsBody)
                        .font(.system(size: 17))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                        .lineSpacing(6)
                        .padding(.horizontal, 20)

                    Text("💡 Tip: turn this idea into one tiny action today.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
            }
            .background(ailyGoalsAppTheme.ailyGoalsBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { ailyGoalsDismiss() }
                }
            }
        }
    }
}
