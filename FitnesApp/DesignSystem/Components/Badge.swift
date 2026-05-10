import SwiftUI

enum BadgeStyle {
    case filled
    case outlined
}

struct Badge: View {
    let text: String
    var style: BadgeStyle = .filled
    var size: CGFloat = 28

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: Radii.sm)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radii.sm)
                    .strokeBorder(border, lineWidth: 1)
            )
    }

    private var foreground: Color {
        style == .filled ? Color.App.onPrimary : Color.App.onSurface
    }

    private var background: Color {
        style == .filled ? Color.App.primary : .clear
    }

    private var border: Color {
        style == .filled ? .clear : Color.App.outlineVariant
    }
}

#Preview("Badge") {
    HStack(spacing: Spacing.lg) {
        Badge(text: "1")
        Badge(text: "2", style: .outlined)
        Badge(text: "12", size: 36)
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
