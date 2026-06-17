import SwiftUI

extension View {
    /// Spec §4: tinted ambient shadow for floating elements.
    /// Uses `glow` tint at 8% opacity — never black shadows.
    func tintedShadow(
        color: Color = Color.App.glow,
        opacity: Double = 0.08,
        radius: CGFloat = 32,
        y: CGFloat = 16
    ) -> some View {
        modifier(TintedShadowModifier(color: color, opacity: opacity, radius: radius, y: y))
    }
}

private struct TintedShadowModifier: ViewModifier {
    let color: Color
    let opacity: Double
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(color: color.opacity(opacity), radius: radius, y: y)
    }
}

#Preview("Tinted Shadow") {
    VStack(spacing: Spacing.xxl) {
        RoundedRectangle(cornerRadius: Radii.pill)
            .fill(Color.App.surfaceContainerHighest.opacity(0.7))
            .frame(height: 56)
            .tintedShadow()
            .overlay(Text("Floating pill").font(Font.App.bodyMd).foregroundStyle(Color.App.onSurface))
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
