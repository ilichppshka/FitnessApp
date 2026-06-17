import SwiftUI

/// Spec §5: filled text field — surfaceContainerLow background, ghost border, optional label above.
struct GhostInputField: View {
    var label: String?
    let placeholder: String
    @Binding var text: String
    var suffix: String?
    var font: Font = Font.App.titleLg
    var keyboardType: UIKeyboardType = .default
    var alignment: TextAlignment = .leading

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let label {
                Text(label)
                    .kineticText(.labelSm)
                    .foregroundStyle(Color.App.onSurfaceMuted)
            }

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                TextField(placeholder, text: $text)
                    .font(font)
                    .foregroundStyle(Color.App.onSurface)
                    .multilineTextAlignment(alignment)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
                    .tint(Color.App.primary)

                if let suffix {
                    Text(suffix)
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurfaceMuted)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm + 2)
            .background(Color.App.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: Radii.sm))
            .ghostBorder(
                color: isFocused ? Color.App.primary : Color.App.outlineVariant,
                opacity: isFocused ? 0.6 : 0.15,
                cornerRadius: Radii.sm
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

#Preview("Ghost Input Field") {
    @Previewable @State var name = ""
    @Previewable @State var weight = "80"
    @Previewable @State var reps = ""

    return VStack(spacing: Spacing.xl) {
        GhostInputField(
            label: "YOUR NAME",
            placeholder: "Имя",
            text: $name
        )

        HStack(spacing: Spacing.lg) {
            GhostInputField(
                label: "WEIGHT",
                placeholder: "0",
                text: $weight,
                suffix: "кг",
                keyboardType: .decimalPad,
                alignment: .center
            )

            GhostInputField(
                label: "REPS",
                placeholder: "0",
                text: $reps,
                suffix: "повт",
                keyboardType: .numberPad,
                alignment: .center
            )
        }

        GhostInputField(
            placeholder: "Заметка к тренировке",
            text: .constant(""),
            font: Font.App.bodyMd
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
