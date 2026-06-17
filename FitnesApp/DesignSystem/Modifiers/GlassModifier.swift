import SwiftUI

extension View {
    /// Spec §5: glassmorphism for floating pills — surfaceContainerHighest @ opacity over ultraThinMaterial.
    func glassBackground(
        cornerRadius: CGFloat = Radii.pill,
        opacity: Double = 0.7
    ) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

private struct GlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content.background(
            ZStack {
                // System blur layer (approximates 25px backdrop blur)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                // Tinted overlay to hit spec's surfaceContainerHighest @ 70%
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.App.surfaceContainerHighest.opacity(opacity))
            }
        )
    }
}

#Preview("Glass Background") {
    ZStack {
        // Simulate content behind the pill
        LinearGradient(
            colors: [Color.App.primary.opacity(0.2), Color.App.surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: Spacing.xl) {
            Text("Floating pill")
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .glassBackground()
                .ghostBorder(color: Color.App.primary, opacity: 0.10, cornerRadius: Radii.pill, lineWidth: 0.5)
                .tintedShadow()

            Text("Card glass (r24)")
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface)
                .padding(Spacing.xl)
                .frame(maxWidth: .infinity)
                .glassBackground(cornerRadius: Radii.lg)
                .ghostBorder(cornerRadius: Radii.lg)
        }
        .padding(Spacing.xl)
    }
    .preferredColorScheme(.dark)
}
