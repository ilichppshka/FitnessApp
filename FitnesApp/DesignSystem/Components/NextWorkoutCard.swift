import SwiftUI

private let heroHeight: CGFloat = 160

struct NextWorkoutCard: View {
    let scheduleTag: String
    let focusLabel: String
    let title: String
    let stats: [StatItem]
    let muscleGroups: [String]
    var ctaTitle: String = "Start Workout"
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            heroBlock
            statsBlock
            muscleChips
            KineticButton(
                title: ctaTitle,
                trailingSystemName: "chevron.right",
                action: onStart
            )
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radii.lg)
                .fill(Color.App.surfaceContainerHigh)
        )
    }

    private var heroBlock: some View {
        ZStack(alignment: .bottomLeading) {
            beam
                .clipShape(RoundedRectangle(cornerRadius: Radii.md))

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Chip(title: scheduleTag, style: .subtle, leadingSystemName: "circle.fill")
                Text(focusLabel.uppercased())
                    .font(Font.App.labelSm)
                    .foregroundStyle(Color.App.onSurface.opacity(0.6))
                Text(title)
                    .font(Font.App.headlineLg)
                    .foregroundStyle(Color.App.onSurface)
            }
            .padding(Spacing.lg)
        }
        .frame(height: heroHeight)
    }

    private var beam: some View {
        ZStack {
            Color.App.surfaceContainerLow

            LinearGradient(
                colors: [
                    Color.App.primary.opacity(0.0),
                    Color.App.primary.opacity(0.65),
                    Color.App.primary.opacity(0.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 24)
            .rotationEffect(.degrees(-12))
        }
    }

    private var statsBlock: some View {
        StatTriple(
            items: stats,
            valueFont: Font.App.headlineLg,
            unitFont: Font.App.bodyMd
        )
    }

    private var muscleChips: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(muscleGroups, id: \.self) { group in
                Chip(title: group, style: .outline)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview("Next Workout Card") {
    VStack {
        NextWorkoutCard(
            scheduleTag: "TODAY · WEEK 3",
            focusLabel: "Muscle Focus",
            title: "Back Day",
            stats: [
                StatItem(value: "6", label: "Exercises"),
                StatItem(value: "45", unit: "min", label: "Time"),
                StatItem(value: "22", label: "Sets")
            ],
            muscleGroups: ["Lats", "Rhomboids", "Rear Delts", "Biceps"],
            onStart: {}
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
