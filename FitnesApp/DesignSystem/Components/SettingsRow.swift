import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let systemName: String
    let title: String
    var action: (() -> Void)?
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(SettingsRowPressStyle())
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: Spacing.md) {
            IconChip(systemName: systemName, size: 36, iconSize: 14, foreground: Color.App.primary)

            Text(title)
                .font(Font.system(size: 16, weight: .medium))
                .foregroundStyle(Color.App.onSurface)

            Spacer()

            trailing()
        }
        .padding(.horizontal, Spacing.md)
        .frame(minHeight: 56)
    }
}

extension SettingsRow where Trailing == AnyView {
    init(systemName: String, title: String, value: String, action: (() -> Void)? = nil) {
        self.init(
            systemName: systemName,
            title: title,
            action: action,
            trailing: {
                AnyView(
                    HStack(spacing: Spacing.xs) {
                        Text(value)
                            .font(Font.App.bodyMd)
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                        if action != nil {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.App.onSurface.opacity(0.3))
                        }
                    }
                )
            }
        )
    }
}

private struct SettingsRowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.App.onSurface.opacity(configuration.isPressed ? 0.05 : 0)
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview("Settings Row") {
    @Previewable @State var autoStart = true

    return VStack(spacing: 0) {
        SettingsRow(
            systemName: "clock",
            title: "Default rest timer",
            value: "01:30",
            action: {}
        )
        Divider().background(Color.App.outlineVariant.opacity(0.2))
        SettingsRow(
            systemName: "scalemass",
            title: "Weight unit",
            value: "Kilograms",
            action: {}
        )
        Divider().background(Color.App.outlineVariant.opacity(0.2))
        SettingsRow(
            systemName: "checkmark.circle",
            title: "Auto-start rest timer",
            trailing: { KineticToggle(isOn: $autoStart) }
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
