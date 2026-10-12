import SwiftUI

@main
struct ailyGoalsDailyGoalsHabitTrackerApp: App {
    @UIApplicationDelegateAdaptor(ailyGoalsAppDelegate.self) private var ailyGoalsDelegate
    @State private var ailyGoalsIsLoading = true
    @AppStorage("hasCompletedOnboardingAilyGoals") private var ailyGoalsHasCompletedOnboarding = false
    @StateObject private var ailyGoalsViewModel = ailyGoalsAppViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if ailyGoalsIsLoading {
                    ailyGoalsLoadingView()
                        .onAppear {
                            ailyGoalsAppDelegate.ailyGoalsOrientation = .all
                            if ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsHasCompletedOnboarding {
                                ailyGoalsHasCompletedOnboarding = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.45)) {
                                    ailyGoalsIsLoading = false
                                }
                            }
                        }
                        .ignoresSafeArea()
                } else if !ailyGoalsHasCompletedOnboarding {
                    ailyGoalsOnboardingView(
                        ailyGoalsHasCompletedOnboarding: $ailyGoalsHasCompletedOnboarding,
                        ailyGoalsViewModel: ailyGoalsViewModel
                    )
                    .onAppear {
                        ailyGoalsAppDelegate.ailyGoalsOrientation = .portrait
                    }
                    .ignoresSafeArea()
                } else {
                    ailyGoalsMainTabView(ailyGoalsViewModel: ailyGoalsViewModel)
                        .onAppear {
                            ailyGoalsAppDelegate.ailyGoalsOrientation = .portrait
                        }
                }
            }
            .preferredColorScheme(
                ailyGoalsViewModel.ailyGoalsPreferences.ailyGoalsFollowsSystemAppearance ? nil : .light
            )
        }
    }
}
