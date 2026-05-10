import SwiftUI

struct MascotCard: View {
    let label: String
    let title: String
    let caption: String
    let remainingCount: Int
    var mascotSystemName: String = "figure.strengthtraining.traditional"
    var action: (() -> Void)?

    var body: some View {
        PerformanceCard(action: action) {
            HStack(alignment: .center, spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radii.md)
                        .fill(Color.App.surfaceContainerLow)
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(Color.App.primary.opacity(0.85))
                        .frame(width: 56, height: 56)
                        .neonGlow(radius: 16, opacity: 0.6)

                    Image(systemName: mascotSystemName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.App.onPrimary)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    SectionLabel(text: label)
                    Text(title)
                        .font(Font.App.titleLg)
                        .foregroundStyle(Color.App.onSurface)
                    Text(caption)
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }

                Spacer(minLength: 0)

                Chip(title: "\(remainingCount) LEFT", style: .subtle)
            }
        }
    }
}

#Preview("Mascot Card") {
    VStack {
        MascotCard(
            label: "Your Mascot",
            title: "Athlete · Default",
            caption: "Tap to change character",
            remainingCount: 4,
            action: {}
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
