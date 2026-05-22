import SwiftUI

struct ProfileAvatarHero: View {
    let initial: String
    let mascotSystemImage: String
    var size: CGFloat = 180

    var body: some View {
        Circle()
            .strokeBorder(
                Color.App.outlineVariant.opacity(0.55),
                style: StrokeStyle(lineWidth: 1, dash: [3, 7])
            )
            .frame(width: size, height: size)
            .overlay(initialView)
            .overlay(alignment: .bottomTrailing) { badge }
    }

    private var initialView: some View {
        Text(initial)
            .font(.custom("SpaceGrotesk-Bold", size: size * 0.42))
            .foregroundStyle(Color.App.onSurface)
            .minimumScaleFactor(0.5)
    }

    private var badge: some View {
        Image(systemName: mascotSystemImage)
            .font(.system(size: size * 0.16, weight: .semibold))
            .foregroundStyle(Color.App.onPrimary)
            .frame(width: size * 0.28, height: size * 0.28)
            .background(Circle().fill(Color.App.primary))
            .overlay(Circle().strokeBorder(Color.App.surface, lineWidth: 3))
            .neonGlow(radius: 10, opacity: 0.45)
            .offset(x: -size * 0.05, y: -size * 0.1)
    }
}

#Preview("Profile Avatar Hero") {
    HStack(spacing: Spacing.xl) {
        ProfileAvatarHero(
            initial: "A",
            mascotSystemImage: "figure.strengthtraining.traditional"
        )
        ProfileAvatarHero(
            initial: "K",
            mascotSystemImage: "figure.run",
            size: 120
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
