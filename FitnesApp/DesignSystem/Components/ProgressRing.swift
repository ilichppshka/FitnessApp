import SwiftUI

struct ProgressRing<Label: View>: View {
    let progress: Double
    var lineWidth: CGFloat = 4
    var size: CGFloat = 64
    var trackOpacity: Double = 0.25
    @ViewBuilder var label: () -> Label

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.App.outlineVariant.opacity(trackOpacity),
                    lineWidth: lineWidth
                )

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    Color.App.primary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            label()
        }
        .frame(width: size, height: size)
    }
}

extension ProgressRing where Label == EmptyView {
    init(progress: Double, lineWidth: CGFloat = 4, size: CGFloat = 64, trackOpacity: Double = 0.25) {
        self.init(
            progress: progress,
            lineWidth: lineWidth,
            size: size,
            trackOpacity: trackOpacity
        ) {
            EmptyView()
        }
    }
}

#Preview("Progress Ring") {
    HStack(spacing: Spacing.xl) {
        ProgressRing(progress: 0.6, size: 56) {
            VStack(spacing: 0) {
                Text("3/5")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.App.onSurface)
            }
        }

        ProgressRing(progress: 0.25)

        ProgressRing(progress: 1.0, lineWidth: 6, size: 80) {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.App.primary)
        }
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
