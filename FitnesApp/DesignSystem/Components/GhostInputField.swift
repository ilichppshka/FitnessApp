import SwiftUI

struct GhostInputField: View {
    let placeholder: String
    @Binding var text: String
    var suffix: String?
    var font: Font = Font.App.titleLg
    var keyboardType: UIKeyboardType = .default
    var alignment: TextAlignment = .leading

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
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
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
            }
            .padding(.vertical, Spacing.sm)

            Rectangle()
                .fill(isFocused ? Color.App.primary : Color.App.outlineVariant)
                .frame(height: isFocused ? 2 : 1)
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
            placeholder: "Имя",
            text: $name
        )

        HStack(spacing: Spacing.lg) {
            GhostInputField(
                placeholder: "0",
                text: $weight,
                suffix: "кг",
                keyboardType: .decimalPad,
                alignment: .center
            )

            GhostInputField(
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
