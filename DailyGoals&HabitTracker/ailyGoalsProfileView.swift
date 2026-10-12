import SwiftUI

struct ailyGoalsProfileView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel
    @State private var ailyGoalsDisplayName: String = ""
    @State private var ailyGoalsShowExport = false
    @State private var ailyGoalsExportURL: URL?
    @State private var ailyGoalsShowResetConfirm = false
    @State private var ailyGoalsShowNotificationExplain = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("👤 Profile")
                            .font(.system(size: 32, weight: .bold))
                        Text("Customize your colorful planner space ✨")
                            .font(.system(size: 14))
                            .opacity(0.92)
                        HStack(spacing: 10) {
                            Text("🌈")
                            Text("🔔")
                            Text("📊")
                            Text("💾")
                        }
                        .font(.system(size: 22))
                    }
                    .foregroundColor(.white)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ailyGoalsAppTheme.ailyGoalsPrimaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: ailyGoalsAppTheme.ailyGoalsPrimaryPurple.opacity(0.28), radius: 12, y: 6)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "✅",
                            ailyGoalsValue: "\(ailyGoalsViewModel.ailyGoalsTasks.count)",
                            ailyGoalsLabel: "Total tasks",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftLavender
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "🔁",
                            ailyGoalsValue: "\(ailyGoalsViewModel.ailyGoalsActiveHabits.count)",
                            ailyGoalsLabel: "Active habits",
                            ailyGoalsTint: ailyGoalsAppTheme.ailyGoalsSoftBlue
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "🎯",
                            ailyGoalsValue: "\(ailyGoalsViewModel.ailyGoalsActiveGoals.count)",
                            ailyGoalsLabel: "Active goals",
                            ailyGoalsTint: Color(ailyGoalsHex: "E8FFF5")
                        )
                        ailyGoalsSnapshotTile(
                            ailyGoalsEmoji: "🔔",
                            ailyGoalsValue: ailyGoalsViewModel.ailyGoalsNotificationStatusText,
                            ailyGoalsLabel: "Notifications",
                            ailyGoalsTint: Color(ailyGoalsHex: "FFE8D6")
                        )
                    }

                    ailyGoalsTipCard(
                        ailyGoalsEmoji: "🎨",
                        ailyGoalsTitle: "Make it yours",
                        ailyGoalsMessage: "Set a display name and week start so greetings and the calendar match your rhythm."
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎨 Personalization")
                            .font(.system(size: 18, weight: .semibold))
                        TextField("Display name", text: $ailyGoalsDisplayName)
                            .padding(12)
                            .background(ailyGoalsAppTheme.ailyGoalsSoftLavender)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onChange(of: ailyGoalsDisplayName) { ailyGoalsValue in
                                var ailyGoalsPrefs = ailyGoalsViewModel.ailyGoalsPreferences
                                ailyGoalsPrefs.ailyGoalsDisplayName = ailyGoalsValue
                                ailyGoalsViewModel.ailyGoalsUpdatePreferences(ailyGoalsPrefs)
                            }
                        Picker("First day of week", selection: Binding(
                            get: { ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsFirstWeekday },
                            set: { ailyGoalsValue in
                                var ailyGoalsPrefs = ailyGoalsViewModel.ailyGoalsPreferences
                                ailyGoalsPrefs.ailyGoalsFirstWeekday = ailyGoalsValue
                                ailyGoalsViewModel.ailyGoalsUpdatePreferences(ailyGoalsPrefs)
                            }
                        )) {
                            Text("Sunday").tag(1)
                            Text("Monday").tag(2)
                        }
                        Toggle("Follow system appearance", isOn: Binding(
                            get: { ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsFollowsSystemAppearance },
                            set: { ailyGoalsValue in
                                var ailyGoalsPrefs = ailyGoalsViewModel.ailyGoalsPreferences
                                ailyGoalsPrefs.ailyGoalsFollowsSystemAppearance = ailyGoalsValue
                                ailyGoalsViewModel.ailyGoalsUpdatePreferences(ailyGoalsPrefs)
                            }
                        ))
                    }
                    .padding(16)
                    .ailyGoalsAppCard()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("⚙️ Preferences")
                            .font(.system(size: 18, weight: .semibold))
                        Toggle("Notifications enabled", isOn: Binding(
                            get: { ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsNotificationsEnabled },
                            set: { ailyGoalsValue in
                                if ailyGoalsValue && ailyGoalsViewModel.ailyGoalsNotificationStatusText != "Allowed" {
                                    ailyGoalsShowNotificationExplain = true
                                } else {
                                    var ailyGoalsPrefs = ailyGoalsViewModel.ailyGoalsPreferences
                                    ailyGoalsPrefs.ailyGoalsNotificationsEnabled = ailyGoalsValue
                                    ailyGoalsViewModel.ailyGoalsUpdatePreferences(ailyGoalsPrefs)
                                }
                            }
                        ))
                        HStack {
                            Text("Permission status")
                            Spacer()
                            Text(ailyGoalsViewModel.ailyGoalsNotificationStatusText)
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                        }
                        if ailyGoalsViewModel.ailyGoalsNotificationStatusText == "Denied" {
                            Button("Open Settings") {
                                ailyGoalsViewModel.ailyGoalsOpenSystemSettings()
                            }
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                        }
                        Toggle("Haptic feedback", isOn: Binding(
                            get: { ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsHapticsEnabled },
                            set: { ailyGoalsValue in
                                var ailyGoalsPrefs = ailyGoalsViewModel.ailyGoalsPreferences
                                ailyGoalsPrefs.ailyGoalsHapticsEnabled = ailyGoalsValue
                                ailyGoalsViewModel.ailyGoalsUpdatePreferences(ailyGoalsPrefs)
                            }
                        ))
                    }
                    .padding(16)
                    .ailyGoalsAppCard()

                    NavigationLink {
                        ailyGoalsStatisticsView(ailyGoalsViewModel: ailyGoalsViewModel)
                    } label: {
                        HStack {
                            Label("📊 Statistics", systemImage: "chart.bar.xaxis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsMutedIcon)
                        }
                        .padding(16)
                        .ailyGoalsAppCard()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("💾 Data")
                            .font(.system(size: 18, weight: .semibold))
                        ailyGoalsSecondaryButton(ailyGoalsTitle: "📤 Export JSON") {
                            ailyGoalsExport()
                        }
                        Button(role: .destructive) {
                            ailyGoalsShowResetConfirm = true
                        } label: {
                            Text("🗑️ Reset all data")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(ailyGoalsAppTheme.ailyGoalsDestructive.opacity(0.12))
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsDestructive)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .ailyGoalsAppCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ℹ️ About")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Daily Goals & Habit Tracker")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryText)
                        Text("Version \(ailyGoalsAppVersion())")
                            .font(.system(size: 13))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                        Text("Plan tasks, build habits, and grow with daily facts — all offline 💫")
                            .font(.system(size: 13))
                            .foregroundColor(ailyGoalsAppTheme.ailyGoalsSecondaryText)
                        if let ailyGoalsPrivacyURL = URL(string: "https://daily-goals-habit-tracker.com/privacy-policy.html") {
                            Link(destination: ailyGoalsPrivacyURL) {
                                HStack(spacing: 8) {
                                    Image(systemName: "hand.raised.fill")
                                    Text("Privacy Policy")
                                        .font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ailyGoalsAppCard()
                }
                .padding(ailyGoalsAppTheme.ailyGoalsScreenPadding)
            }
            .background(ailyGoalsAppTheme.ailyGoalsBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                ailyGoalsDisplayName = ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsDisplayName
                ailyGoalsViewModel.ailyGoalsRefreshNotificationStatus()
            }
            .sheet(isPresented: $ailyGoalsShowExport) {
                if let ailyGoalsExportURL {
                    ailyGoalsShareSheet(ailyGoalsItems: [ailyGoalsExportURL])
                }
            }
            .confirmationDialog("Reset all data?", isPresented: $ailyGoalsShowResetConfirm, titleVisibility: .visible) {
                Button("Reset Everything", role: .destructive) {
                    ailyGoalsViewModel.ailyGoalsResetAllData()
                    ailyGoalsDisplayName = ""
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes tasks, habits, goals, and preferences stored on this device.")
            }
            .alert("Enable Reminders", isPresented: $ailyGoalsShowNotificationExplain) {
                Button("Not Now", role: .cancel) {}
                Button("Continue") {
                    ailyGoalsViewModel.ailyGoalsRequestNotificationPermission()
                }
            } message: {
                Text("Notifications remind you about tasks and habits at the times you choose.")
            }
        }
    }

    private func ailyGoalsExport() {
        guard let ailyGoalsData = ailyGoalsViewModel.ailyGoalsExportData() else { return }
        let ailyGoalsURL = FileManager.default.temporaryDirectory.appendingPathComponent("DailyGoalsExport.json")
        do {
            try ailyGoalsData.write(to: ailyGoalsURL, options: .atomic)
            ailyGoalsExportURL = ailyGoalsURL
            ailyGoalsShowExport = true
        } catch {
            return
        }
    }

    private func ailyGoalsAppVersion() -> String {
        let ailyGoalsVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let ailyGoalsBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(ailyGoalsVersion) (\(ailyGoalsBuild))"
    }
}
