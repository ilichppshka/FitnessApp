import SwiftUI

enum TextButtonStyle {
    case plain
    case pill
}

struct TextButton: View {
    let title: String
    var style: TextButtonStyle = .plain
    var trailingSystemName: String?
    var foreground: Color = Color.App.primary
    var font: Font = Font.system(size: 14, weight: .semibold)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(title)
                    .font(font)
                if let trailingSystemName {
                    Image(systemName: trailingSystemName)
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, style == .pill ? Spacing.md : 0)
            .padding(.vertical, style == .pill ? Spacing.sm : 0)
            .background(
                Capsule().fill(
                    style == .pill ? Color.App.surfaceContainerHigh : .clear
                )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Text Button") {
    VStack(spacing: Spacing.lg) {
        TextButton(title: "Edit", action: {})
        TextButton(title: "Sort", trailingSystemName: "arrow.up.arrow.down", action: {})
        TextButton(title: "This week", trailingSystemName: "arrow.up", action: {})
        TextButton(title: "Save Draft", style: .pill, foreground: Color.App.onSurface, action: {})
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
