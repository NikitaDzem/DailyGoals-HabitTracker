import SwiftUI

struct ailyGoalsMainTabView: View {
    @ObservedObject var ailyGoalsViewModel: ailyGoalsAppViewModel

    var body: some View {
        TabView(selection: $ailyGoalsViewModel.ailyGoalsSelectedTab) {
            ailyGoalsTodayView(ailyGoalsViewModel: ailyGoalsViewModel)
                .tabItem {
                    Label("Today", systemImage: "checkmark.circle.fill")
                }
                .tag(0)
            ailyGoalsCalendarView(ailyGoalsViewModel: ailyGoalsViewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            ailyGoalsTrackView(ailyGoalsViewModel: ailyGoalsViewModel)
                .tabItem {
                    Label("Track", systemImage: "flame.fill")
                }
                .tag(2)
            ailyGoalsFactsView()
                .tabItem {
                    Label("Facts", systemImage: "sparkles")
                }
                .tag(3)
            ailyGoalsProfileView(ailyGoalsViewModel: ailyGoalsViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(ailyGoalsAppTheme.ailyGoalsPrimaryPurple)
        .onAppear {
            let ailyGoalsAppearance = UITabBarAppearance()
            ailyGoalsAppearance.configureWithOpaqueBackground()
            ailyGoalsAppearance.backgroundColor = UIColor(ailyGoalsAppTheme.ailyGoalsSurface)
            UITabBar.appearance().standardAppearance = ailyGoalsAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = ailyGoalsAppearance
            }
        }
    }
}
