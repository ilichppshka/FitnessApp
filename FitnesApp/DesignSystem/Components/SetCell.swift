import SwiftUI

struct SetCell: View {
    @Binding var value: String
    var unit: String?
    var placeholder: String = "0"
    var keyboardType: UIKeyboardType = .decimalPad
    var width: CGFloat?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            TextField(placeholder, text: $value)
                .font(Font.App.titleLg)
                .foregroundStyle(Color.App.onSurface)
                .multilineTextAlignment(.center)
                .keyboardType(keyboardType)
                .tint(Color.App.primary)
                .focused($isFocused)

            if let unit {
                Text(unit)
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .frame(width: width)
        .background(
            RoundedRectangle(cornerRadius: Radii.sm)
                .fill(Color.App.surfaceContainerLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radii.sm)
                .strokeBorder(
                    isFocused ? Color.App.primary : Color.App.outlineVariant.opacity(0.4),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

#Preview("Set Cell") {
    @Previewable @State var weight = "75"
    @Previewable @State var reps = "8"
    @Previewable @State var empty = ""

    return VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.sm) {
            SetCell(value: $weight, unit: "kg")
            SetCell(value: $reps, unit: "reps", keyboardType: .numberPad)
            SetCell(value: $empty, unit: "kg")
        }
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
