import SwiftUI

struct ailyGoalsInternetView: View {
    @State private var ailyGoalsOpacity = 0.0

    var body: some View {
        GeometryReader { ailyGoalsGeometry in
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.35, green: 0.05, blue: 0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: ailyGoalsGeometry.size.width, height: ailyGoalsGeometry.size.height)
                .ignoresSafeArea()

                VStack {
                    Image(systemName: "wifi.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .foregroundStyle(.white)
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .cornerRadius(20)
                }
            }
            .frame(width: ailyGoalsGeometry.size.width, height: ailyGoalsGeometry.size.height)
            .opacity(ailyGoalsOpacity)
            .animation(.linear(duration: 0.325), value: ailyGoalsOpacity)
            .onAppear {
                ailyGoalsAppDelegate.ailyGoalsOrientation = .all
                ailyGoalsOpacity = 1
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ailyGoalsInternetView()
}
