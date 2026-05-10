import SwiftUI

struct SetRow: View {
    let index: Int
    @Binding var weight: String
    @Binding var reps: String
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text("\(index)")
                .font(Font.App.titleLg)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                .frame(width: 24, alignment: .leading)

            SetCell(value: $weight, unit: "kg")
                .frame(maxWidth: .infinity)

            SetCell(value: $reps, unit: "reps", keyboardType: .numberPad)
                .frame(maxWidth: .infinity)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Set Row") {
    @Previewable @State var weight1 = "60"
    @Previewable @State var reps1 = "12"
    @Previewable @State var weight2 = "70"
    @Previewable @State var reps2 = "10"

    return VStack(spacing: Spacing.sm) {
        HStack(spacing: Spacing.sm) {
            Text("SET")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                .frame(width: 24, alignment: .leading)
            Text("WEIGHT")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .center)
            Text("REPS")
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer().frame(width: 28)
        }
        SetRow(index: 1, weight: $weight1, reps: $reps1, onRemove: {})
        SetRow(index: 2, weight: $weight2, reps: $reps2, onRemove: {})
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
