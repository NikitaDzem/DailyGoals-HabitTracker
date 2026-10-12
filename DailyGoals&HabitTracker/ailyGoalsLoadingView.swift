import SwiftUI

struct ailyGoalsLoadingView: View {
    @State private var ailyGoalsPulse = false
    @State private var ailyGoalsRing = false
    @State private var ailyGoalsProgress: CGFloat = 0.08
    @State private var ailyGoalsGlow = false
    @Environment(\.accessibilityReduceMotion) private var ailyGoalsReduceMotion

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(ailyGoalsHex: "5B3FE8"),
                    Color(ailyGoalsHex: "7657F6"),
                    Color(ailyGoalsHex: "4389F7")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -90, y: -180)
                .scaleEffect(ailyGoalsGlow ? 1.12 : 0.92)

            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: 110, y: 220)
                .scaleEffect(ailyGoalsGlow ? 0.95 : 1.1)

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 2)
                        .frame(width: 148, height: 148)
                        .scaleEffect(ailyGoalsRing ? 1.18 : 0.92)
                        .opacity(ailyGoalsRing ? 0 : 0.7)

                    Circle()
                        .stroke(Color.white.opacity(0.28), lineWidth: 2)
                        .frame(width: 124, height: 124)
                        .scaleEffect(ailyGoalsRing ? 1.1 : 0.96)
                        .opacity(ailyGoalsRing ? 0.05 : 0.85)

                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 108, height: 108)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .scaleEffect(ailyGoalsPulse ? 1.04 : 0.96)
                        .shadow(color: Color.black.opacity(0.18), radius: 18, y: 10)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(ailyGoalsPulse ? 1.05 : 0.95)
                }

                VStack(spacing: 10) {
                    Text("Daily Goals")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Habit Tracker")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.82))
                        .tracking(1.2)
                }

                VStack(spacing: 12) {
                    GeometryReader { ailyGoalsProxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.22))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.white)
                                .frame(width: max(18, ailyGoalsProxy.size.width * ailyGoalsProgress), height: 6)
                                .shadow(color: Color.white.opacity(0.45), radius: 6, y: 0)
                        }
                    }
                    .frame(height: 6)
                    .frame(maxWidth: 180)

                    Text("Preparing your day…")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(.top, 8)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            guard !ailyGoalsReduceMotion else {
                ailyGoalsProgress = 1
                return
            }
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                ailyGoalsPulse = true
                ailyGoalsGlow = true
            }
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                ailyGoalsRing = true
            }
            withAnimation(.easeInOut(duration: 1.85)) {
                ailyGoalsProgress = 1
            }
        }
    }
}

#Preview {
    ailyGoalsLoadingView()
}
