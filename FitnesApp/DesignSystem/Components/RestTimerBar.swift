import SwiftUI

struct RestTimerBar: View {
    let label: String
    let timeText: String
    var onMinus15: () -> Void
    var onPlus15: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(alignment: .center) {
                HStack(spacing: Spacing.xs) {
                    StatusDot(pulses: true)
                    Text(label.uppercased())
                        .font(Font.App.labelSm)
                        .foregroundStyle(Color.App.onSurface.opacity(0.7))
                }

                Spacer()

                Text(timeText)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.App.primary)
                    .monospacedDigit()
            }

            HStack(spacing: Spacing.sm) {
                Chip(title: "-15s", style: .subtle, leadingSystemName: "minus", action: onMinus15)
                Chip(title: "+15s", style: .subtle, leadingSystemName: "plus", action: onPlus15)
                Spacer()
                Chip(title: "Skip", style: .subtle, leadingSystemName: "checkmark", action: onSkip)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerLow)
        )
    }
}

#Preview("Rest Timer Bar") {
    VStack {
        RestTimerBar(
            label: "Rest · next set in",
            timeText: "1:23",
            onMinus15: {},
            onPlus15: {},
            onSkip: {}
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
