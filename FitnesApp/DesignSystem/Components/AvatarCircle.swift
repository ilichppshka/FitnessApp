import SwiftUI

struct AvatarCircle: View {
    let initial: String
    var size: CGFloat = 40
    var image: Image?
    var overlayBadge: Image?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .frame(width: size, height: size)
                .background(Circle().fill(Color.App.surfaceContainerHigh))
                .overlay(
                    Circle().strokeBorder(
                        Color.App.outlineVariant.opacity(0.4),
                        lineWidth: 1
                    )
                )
                .clipShape(Circle())

            if let overlayBadge {
                overlayBadge
                    .font(.system(size: size * 0.18, weight: .bold))
                    .foregroundStyle(Color.App.onPrimary)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .background(Circle().fill(Color.App.primary))
                    .overlay(
                        Circle().strokeBorder(Color.App.surface, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            image
                .resizable()
                .scaledToFill()
        } else {
            Text(initial)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(Color.App.onSurface)
        }
    }
}

#Preview("Avatar Circle") {
    HStack(spacing: Spacing.lg) {
        AvatarCircle(initial: "A")
        AvatarCircle(initial: "AM", size: 56)
        AvatarCircle(
            initial: "A",
            size: 72,
            overlayBadge: Image(systemName: "chevron.left")
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
