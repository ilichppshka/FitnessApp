import SwiftUI

struct ExecutionStepRow: View {
    let number: Int
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .center, spacing: Spacing.sm) {
                Text("\(number)")
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onPrimary)
                    .frame(width: 22, height: 22)
                    .background(RoundedRectangle(cornerRadius: Radii.sm).fill(Color.App.primary))
                Text(title.uppercased())
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface)
                    .tracking(0.8)
            }
            Text(text)
                .font(Font.App.bodyMd)
                .foregroundStyle(Color.App.onSurface.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("Execution Step Row") {
    VStack(alignment: .leading, spacing: Spacing.lg) {
        ExecutionStepRow(
            number: 1,
            title: "Descent",
            text: "Lower the bar to your mid-chest, keeping elbows at roughly 45° to the floor."
        )
        ExecutionStepRow(
            number: 2,
            title: "Press",
            text: "Drive the bar back up explosively while maintaining contact with the bench."
        )
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
#endif
