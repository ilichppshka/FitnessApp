import SwiftUI

struct RestRow: View {
    let label: String
    let timeText: String
    var action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "clock")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.App.primary)

            Text(label)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.7))

            Spacer()

            Text(timeText)
                .font(Font.App.titleLg)
                .foregroundStyle(Color.App.onSurface)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Radii.sm)
                .fill(Color.App.surfaceContainerLow)
        )
    }
}

#Preview("Rest Row") {
    VStack(spacing: Spacing.lg) {
        RestRow(label: "Rest between sets", timeText: "02:00", action: {})
        RestRow(label: "Default rest timer", timeText: "01:30")
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
