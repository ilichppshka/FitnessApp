import SwiftUI

struct AnimationPlayerCard: View {
    let animationAssetName: String?

    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            animationArea
            controlsRow
        }
        .background(Color.App.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: Radii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radii.lg)
                .strokeBorder(Color.App.primary.opacity(0.5), lineWidth: 1)
        )
        .neonGlow(radius: 10, opacity: 0.25, isActive: true)
    }

    private var cardHeader: some View {
        HStack(spacing: Spacing.xs) {
            StatusDot(pulses: isPlaying)
            SectionLabel(text: String(localized: "library.detail.player.label"))
            Spacer()
            if let name = animationAssetName {
                Text("[\(name)]")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.25))
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }

    private var animationArea: some View {
        ZStack {
            gridBackground
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(Color.App.primary.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    private var gridBackground: some View {
        Canvas { context, size in
            let step: CGFloat = 24
            var x: CGFloat = 0
            while x <= size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.App.outlineVariant.opacity(0.25)), lineWidth: 0.5)
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.App.outlineVariant.opacity(0.25)), lineWidth: 0.5)
                y += step
            }
        }
    }

    private var controlsRow: some View {
        HStack(spacing: Spacing.md) {
            Button {
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.App.onPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.App.primary))
            }

            Capsule()
                .fill(Color.App.outlineVariant.opacity(0.45))
                .frame(height: 3)

            Text("0:00 / 0:12")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.4))
                .monospacedDigit()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
    }
}

#if DEBUG
#Preview("Animation Player Card") {
    AnimationPlayerCard(animationAssetName: "bench_press.lottie")
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.App.surface)
        .preferredColorScheme(.dark)
}
#endif
