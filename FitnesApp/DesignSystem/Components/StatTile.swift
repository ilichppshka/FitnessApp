import SwiftUI

struct StatTile: View {
    let systemName: String
    let label: String
    let value: String
    var unit: String?
    var delta: DeltaPill?
    var action: (() -> Void)?

    var body: some View {
        PerformanceCard(action: action) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(alignment: .top) {
                    IconChip(
                        systemName: systemName,
                        size: 32,
                        iconSize: 14,
                        foreground: Color.App.primary
                    )
                    Spacer()
                    delta
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    SectionLabel(text: label)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value)
                            .font(Font.App.headlineLg)
                            .foregroundStyle(Color.App.onSurface)
                        if let unit {
                            Text(unit)
                                .font(Font.App.bodyMd)
                                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
}

#Preview("Stat Tile") {
    HStack(spacing: Spacing.sm) {
        StatTile(
            systemName: "dumbbell.fill",
            label: "Sessions",
            value: "14",
            delta: DeltaPill(direction: .up, value: "+2")
        )
        StatTile(
            systemName: "clock",
            label: "Time",
            value: "11h 24m",
            delta: DeltaPill(direction: .up, value: "+1h")
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
