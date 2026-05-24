import SwiftUI

struct MuscleGroupChipsSection: View {
    let primaryNames: [String]
    let secondaryNames: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: String(localized: "library.detail.section.muscles"))
            FlowLayout(spacing: Spacing.sm, lineSpacing: Spacing.sm) {
                ForEach(primaryNames, id: \.self) { name in
                    primaryChip(name)
                }
                ForEach(secondaryNames, id: \.self) { name in
                    Chip(title: name, style: .subtle)
                }
            }
        }
    }

    private func primaryChip(_ name: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(Color.App.primary)
                .frame(width: 6, height: 6)
            Text(name)
                .font(Font.App.labelSm)
                .foregroundStyle(Color.App.onSurface)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Capsule().fill(Color.clear))
        .overlay(Capsule().strokeBorder(Color.App.outlineVariant, lineWidth: 1))
    }
}

#if DEBUG
#Preview("Muscle Group Chips Section") {
    MuscleGroupChipsSection(
        primaryNames: ["Chest", "Front Shoulders"],
        secondaryNames: ["Triceps", "Core"]
    )
    .padding(Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
#endif
