import SwiftUI

struct NeonGlowModifier: ViewModifier {
    var color: Color = Color.App.primary
    var radius: CGFloat = 12
    var opacity: Double = 0.6
    var isActive: Bool = true

    func body(content: Content) -> some View {
        content
            .shadow(
                color: isActive ? color.opacity(opacity) : .clear,
                radius: isActive ? radius : 0
            )
            .shadow(
                color: isActive ? color.opacity(opacity * 0.5) : .clear,
                radius: isActive ? radius * 2 : 0
            )
    }
}

extension View {
    func neonGlow(
        color: Color = Color.App.primary,
        radius: CGFloat = 12,
        opacity: Double = 0.6,
        isActive: Bool = true
    ) -> some View {
        modifier(
            NeonGlowModifier(
                color: color,
                radius: radius,
                opacity: opacity,
                isActive: isActive
            )
        )
    }
}

#Preview("Neon Glow") {
    VStack(spacing: Spacing.xl) {
        Circle()
            .fill(Color.App.primary)
            .frame(width: 80, height: 80)
            .neonGlow()

        RoundedRectangle(cornerRadius: Radii.md)
            .fill(Color.App.surfaceContainerHigh)
            .frame(width: 200, height: 56)
            .overlay(
                Text("ACTIVE")
                    .font(.App.labelSm)
                    .foregroundStyle(Color.App.primary)
            )
            .neonGlow(radius: 16, opacity: 0.5)

        RoundedRectangle(cornerRadius: Radii.md)
            .fill(Color.App.surfaceContainerHigh)
            .frame(width: 200, height: 56)
            .overlay(
                Text("INACTIVE")
                    .font(.App.labelSm)
                    .foregroundStyle(Color.App.onSurface)
            )
            .neonGlow(isActive: false)
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
