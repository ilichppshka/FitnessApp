import SwiftUI

struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: title)
                .padding(.horizontal, Spacing.md)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: Radii.md)
                    .fill(Color.App.surfaceContainerLow)
            )
        }
    }
}

#Preview("Settings Group") {
    @Previewable @State var autoStart = true
    @Previewable @State var haptic = true

    return VStack(spacing: Spacing.xl) {
        SettingsGroup(title: "Training") {
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

        SettingsGroup(title: "Notifications & Feedback") {
            SettingsRow(
                systemName: "bell",
                title: "Rest timer alerts",
                trailing: { KineticToggle(isOn: .constant(false)) }
            )
            Divider().background(Color.App.outlineVariant.opacity(0.2))
            SettingsRow(
                systemName: "waveform",
                title: "Haptic feedback",
                trailing: { KineticToggle(isOn: $haptic) }
            )
        }
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
