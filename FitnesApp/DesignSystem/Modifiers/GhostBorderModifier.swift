import SwiftUI

extension View {
    /// Spec §4: accessibility border via outline-variant @ 15% opacity.
    /// Rim-light variant (nav pill): pass `color: .App.primary, opacity: 0.10, lineWidth: 0.5`.
    func ghostBorder(
        color: Color = Color.App.outlineVariant,
        opacity: Double = 0.15,
        cornerRadius: CGFloat = Radii.md,
        lineWidth: CGFloat = 1
    ) -> some View {
        modifier(GhostBorderModifier(color: color, opacity: opacity, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}

private struct GhostBorderModifier: ViewModifier {
    let color: Color
    let opacity: Double
    let cornerRadius: CGFloat
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(color.opacity(opacity), lineWidth: lineWidth)
        )
    }
}

#Preview("Ghost Border") {
    VStack(spacing: Spacing.lg) {
        RoundedRectangle(cornerRadius: Radii.md)
            .fill(Color.App.surfaceContainerHigh)
            .frame(height: 80)
            .ghostBorder()
            .overlay(Text("Default (15%)").font(Font.App.bodyMd).foregroundStyle(Color.App.onSurface))

        RoundedRectangle(cornerRadius: Radii.pill)
            .fill(Color.App.surfaceContainerHighest.opacity(0.7))
            .frame(height: 56)
            .ghostBorder(color: Color.App.primary, opacity: 0.10, cornerRadius: Radii.pill, lineWidth: 0.5)
            .overlay(Text("Rim light (primary 10%)").font(Font.App.bodyMd).foregroundStyle(Color.App.onSurface))
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
