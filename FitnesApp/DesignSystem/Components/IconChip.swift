import SwiftUI

struct IconChip: View {
    let systemName: String
    var size: CGFloat = 40
    var iconSize: CGFloat = 16
    var foreground: Color = Color.App.onSurface
    var action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(IconChipPressStyle())
        } else {
            content
        }
    }

    private var content: some View {
        Image(systemName: systemName)
            .font(.system(size: iconSize, weight: .medium))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(Circle().fill(Color.App.surfaceContainerHigh))
            .overlay(
                Circle().strokeBorder(
                    Color.App.outlineVariant.opacity(0.3),
                    lineWidth: 1
                )
            )
    }
}

private struct IconChipPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("Icon Chip") {
    HStack(spacing: Spacing.lg) {
        IconChip(systemName: "chevron.left", action: {})
        IconChip(systemName: "xmark", action: {})
        IconChip(systemName: "ellipsis", action: {})
        IconChip(systemName: "arrow.down.to.line", action: {})
        IconChip(systemName: "line.3.horizontal.decrease", action: {})
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
