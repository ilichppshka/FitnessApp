import SwiftUI

struct StatusDot: View {
    var color: Color = Color.App.primary
    var size: CGFloat = 8
    var pulses: Bool = false

    @State private var animating: Bool = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(pulses && animating ? 0.4 : 1.0)
            .scaleEffect(pulses && animating ? 1.3 : 1.0)
            .animation(
                pulses
                    ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                    : .default,
                value: animating
            )
            .onAppear {
                if pulses {
                    animating = true
                }
            }
    }
}

#Preview("Status Dot") {
    HStack(spacing: Spacing.lg) {
        StatusDot()
        StatusDot(pulses: true)
        StatusDot(color: .red, size: 10, pulses: true)
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
