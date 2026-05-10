import SwiftUI

struct TimelineScrubber: View {
    @Binding var progress: Double
    let startText: String
    let currentText: String
    var speedText: String = "1.0×"
    var onSpeedTap: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(startText)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onPrimary.opacity(0.7))
                .monospacedDigit()

            Chip(title: currentText, style: .subtle)

            Slider(value: $progress, in: 0...1)
                .tint(Color.App.onPrimary)

            Chip(title: speedText, style: .subtle, action: onSpeedTap)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            Capsule().fill(Color.App.surface.opacity(0.6))
        )
    }
}

#Preview("Timeline Scrubber") {
    @Previewable @State var progress: Double = 0.45

    return VStack {
        TimelineScrubber(
            progress: $progress,
            startText: "0:00",
            currentText: "2:18",
            onSpeedTap: {}
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.primary)
    .preferredColorScheme(.dark)
}
