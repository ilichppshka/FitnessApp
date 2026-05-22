import SwiftUI

struct MascotPickerGrid: View {
    @Binding var selection: MascotOption

    var body: some View {
        HStack(spacing: Spacing.md) {
            ForEach(MascotOption.allCases) { option in
                MascotPickerCell(
                    option: option,
                    isSelected: option == selection
                ) {
                    selection = option
                }
            }
        }
    }
}

private struct MascotPickerCell: View {
    let option: MascotOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: option.systemImage)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(isSelected ? Color.App.primary : Color.App.onSurface.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.App.onPrimary)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(Color.App.primary))
                            .padding(Spacing.xs)
                    }
                }

                Text(option.titleResource)
                    .font(Font.App.bodyMd)
                    .foregroundStyle(isSelected ? Color.App.onSurface : Color.App.onSurface.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radii.md)
                    .fill(Color.App.surfaceContainerHigh)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .strokeBorder(
                        isSelected ? Color.App.primary : Color.App.outlineVariant.opacity(0.4),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Mascot Picker Grid") {
    @Previewable @State var selection: MascotOption = .athlete

    return MascotPickerGrid(selection: $selection)
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.App.surface)
        .preferredColorScheme(.dark)
}
