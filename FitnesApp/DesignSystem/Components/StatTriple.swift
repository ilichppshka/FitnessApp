import SwiftUI

struct StatItem: Identifiable, Hashable {
    let id: String
    let value: String
    var unit: String?
    let label: String

    init(value: String, unit: String? = nil, label: String) {
        self.id = "\(label)·\(value)"
        self.value = value
        self.unit = unit
        self.label = label
    }
}

struct StatTriple: View {
    let items: [StatItem]
    var valueFont: Font = Font.system(size: 22, weight: .semibold)
    var unitFont: Font = Font.App.bodyMd

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(item.value)
                            .font(valueFont)
                            .foregroundStyle(Color.App.onSurface)
                        if let unit = item.unit {
                            Text(unit)
                                .font(unitFont)
                                .foregroundStyle(Color.App.onSurface.opacity(0.5))
                        }
                    }
                    SectionLabel(text: item.label)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview("Stat Triple") {
    VStack(spacing: Spacing.xl) {
        StatTriple(items: [
            StatItem(value: "6", label: "Exercises"),
            StatItem(value: "45", unit: "min", label: "Time"),
            StatItem(value: "22", label: "Sets")
        ])

        StatTriple(items: [
            StatItem(value: "78", unit: "kg", label: "Weight"),
            StatItem(value: "182", unit: "cm", label: "Height"),
            StatItem(value: "3", label: "Level")
        ])
    }
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
