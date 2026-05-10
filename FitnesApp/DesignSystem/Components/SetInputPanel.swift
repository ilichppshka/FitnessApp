import SwiftUI

struct SetInputColumn {
    let label: String
    var unit: String?
    var deltaText: String?
}

struct SetInputPanel: View {
    var weightColumn: SetInputColumn = SetInputColumn(label: "Weight", unit: "kg")
    var repsColumn: SetInputColumn = SetInputColumn(label: "Reps", unit: "reps")
    @Binding var weight: Double
    @Binding var reps: Int
    var weightStep: Double = 2.5
    var repsStep: Int = 1

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            column(
                config: weightColumn,
                valueText: weight.cleanString,
                onMinus: { weight = max(0, weight - weightStep) },
                onPlus: { weight += weightStep }
            )

            column(
                config: repsColumn,
                valueText: "\(reps)",
                onMinus: { reps = max(0, reps - repsStep) },
                onPlus: { reps += repsStep }
            )
        }
    }

    private func column(
        config: SetInputColumn,
        valueText: String,
        onMinus: @escaping () -> Void,
        onPlus: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                SectionLabel(text: config.label)
                if let delta = config.deltaText {
                    DeltaPill(direction: .up, value: delta)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(valueText)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color.App.onSurface)
                if let unit = config.unit {
                    Text(unit)
                        .font(Font.App.bodyMd)
                        .foregroundStyle(Color.App.onSurface.opacity(0.5))
                }
            }

            HStack(spacing: Spacing.sm) {
                StepperButton(kind: .minus, action: onMinus)
                StepperButton(kind: .plus, action: onPlus)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerHigh)
        )
    }
}

private extension Double {
    var cleanString: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(self))
            : String(format: "%.1f", self)
    }
}

#Preview("Set Input Panel") {
    @Previewable @State var weight: Double = 75
    @Previewable @State var reps: Int = 8

    return SetInputPanel(
        weightColumn: SetInputColumn(label: "Weight", unit: "kg", deltaText: "+5kg"),
        repsColumn: SetInputColumn(label: "Reps", unit: "reps"),
        weight: $weight,
        reps: $reps
    )
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
