import SwiftUI

struct ProfileCard: View {
    let initial: String
    let name: String
    let secondary: String
    let stats: [StatItem]
    var avatarImage: Image?
    var action: (() -> Void)?

    var body: some View {
        PerformanceCard(action: action) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack(alignment: .top, spacing: Spacing.md) {
                    AvatarCircle(
                        initial: initial,
                        size: 72,
                        image: avatarImage,
                        overlayBadge: Image(systemName: "chevron.left")
                    )

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(name)
                            .font(Font.App.titleLg)
                            .foregroundStyle(Color.App.onSurface)
                        Text(secondary)
                            .font(Font.App.bodyMd)
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    }

                    Spacer(minLength: 0)
                }

                StatTriple(items: stats)
            }
        }
    }
}

#Preview("Profile Card") {
    VStack {
        ProfileCard(
            initial: "A",
            name: "Alex Morgan",
            secondary: "alex@kinetic.app · Member since Feb 2024",
            stats: [
                StatItem(value: "78", unit: "kg", label: "Weight"),
                StatItem(value: "182", unit: "cm", label: "Height"),
                StatItem(value: "3", label: "Level")
            ]
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
