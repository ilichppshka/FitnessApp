import SwiftUI

struct SearchField: View {
    let placeholder: String
    @Binding var text: String
    var trailingMeta: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.App.onSurface.opacity(0.5))

            TextField(placeholder, text: $text)
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface)
                .tint(Color.App.primary)
                .focused($isFocused)

            if let trailingMeta {
                Text(trailingMeta)
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.4))
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 44)
        .background(Capsule().fill(Color.App.surfaceContainerHigh))
        .overlay(
            Capsule().strokeBorder(
                isFocused ? Color.App.primary : .clear,
                lineWidth: 1
            )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview("Search Field") {
    @Previewable @State var query = ""

    return VStack(spacing: Spacing.lg) {
        SearchField(
            placeholder: "Search 258 exercises...",
            text: $query,
            trailingMeta: "3K"
        )
        SearchField(placeholder: "Поиск", text: .constant(""))
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
