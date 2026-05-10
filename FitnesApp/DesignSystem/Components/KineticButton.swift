import SwiftUI

enum KineticButtonStyle {
    case primary
    case secondary
}

struct KineticButton: View {
    let title: String
    var style: KineticButtonStyle = .primary
    var isEnabled: Bool = true
    var trailingSystemName: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Text(title)
                    .font(Font.App.titleLg)
                if let trailingSystemName {
                    Image(systemName: trailingSystemName)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(KineticPressStyle(style: style, isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct KineticPressStyle: ButtonStyle {
    let style: KineticButtonStyle
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .foregroundStyle(foreground)
            .background(
                RoundedRectangle(cornerRadius: Radii.md)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .opacity(isEnabled ? 1.0 : 0.4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .neonGlow(
                radius: isPressed ? 6 : 14,
                opacity: 0.55,
                isActive: style == .primary && isEnabled
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
    }

    private var foreground: Color {
        switch style {
        case .primary: Color.App.onPrimary
        case .secondary: Color.App.onSurface
        }
    }

    private var background: Color {
        switch style {
        case .primary: Color.App.primary
        case .secondary: .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: .clear
        case .secondary: Color.App.outlineVariant
        }
    }
}

#Preview("Kinetic Button") {
    VStack(spacing: Spacing.lg) {
        KineticButton(title: "Quick Start", action: {})

        KineticButton(
            title: "Save Plan",
            trailingSystemName: "chevron.right",
            action: {}
        )

        KineticButton(
            title: "Complete Set",
            trailingSystemName: "checkmark",
            action: {}
        )

        KineticButton(title: "Создать план", style: .secondary, action: {})

        KineticButton(title: "Disabled", isEnabled: false, action: {})

        KineticButton(
            title: "Disabled Secondary",
            style: .secondary,
            isEnabled: false,
            action: {}
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
