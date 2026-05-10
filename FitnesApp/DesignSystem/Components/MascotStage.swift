import SwiftUI

enum MascotStageState {
    case idle
    case active
    case complete
}

struct MascotStage: View {
    let state: MascotStageState
    var statusLabel: String = "LIVE · TECHNIQUE"
    var assetName: String?
    var mascotSystemName: String = "figure.strengthtraining.traditional"
    @Binding var scrubProgress: Double
    var startText: String = "0:00"
    var currentText: String = "0:00"

    var body: some View {
        ZStack(alignment: .topLeading) {
            stageBackground

            mascotIcon
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            topRow
                .padding(Spacing.md)

            VStack {
                Spacer()
                TimelineScrubber(
                    progress: $scrubProgress,
                    startText: startText,
                    currentText: currentText
                )
                .padding(Spacing.md)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: Radii.lg))
        .neonGlow(radius: state == .active ? 24 : 0, opacity: 0.6, isActive: state == .active)
    }

    private var stageBackground: some View {
        ZStack {
            Color.App.primary
            RadialGradient(
                colors: [
                    Color.App.primary,
                    Color.App.primary.opacity(0.7)
                ],
                center: .center,
                startRadius: 20,
                endRadius: 240
            )
        }
    }

    private var mascotIcon: some View {
        Image(systemName: mascotSystemName)
            .font(.system(size: 96, weight: .bold))
            .foregroundStyle(Color.App.onPrimary.opacity(0.65))
            .symbolEffect(.bounce, options: .repeating, value: state == .active)
    }

    private var topRow: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                StatusDot(color: Color.App.onPrimary, pulses: state == .active)
                Text(statusLabel)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onPrimary)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Capsule().fill(Color.App.surface.opacity(0.4)))

            Spacer()

            if let assetName {
                Text(assetName)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onPrimary.opacity(0.6))
                    .lineLimit(1)
            }
        }
    }
}

#Preview("Mascot Stage") {
    @Previewable @State var progress: Double = 0.45

    return VStack {
        MascotStage(
            state: .active,
            statusLabel: "LIVE · TECHNIQUE",
            assetName: "_bench_press.lottie",
            scrubProgress: $progress,
            startText: "0:00",
            currentText: "2:18"
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
