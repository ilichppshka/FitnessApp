import SwiftUI

struct ExerciseListItem: View {
    let title: String
    let subtitle: String
    var difficulty: String?
    var prText: String?
    var thumbnailSystemName: String = "play.fill"
    var onTap: (() -> Void)?
    var onAdd: (() -> Void)?

    var body: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radii.sm)
                    .fill(Color.App.surfaceContainerLow)
                Image(systemName: thumbnailSystemName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.App.primary)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.App.onSurface)
                    .lineLimit(1)

                Text(subtitle)
                    .font(Font.App.bodyMd)
                    .foregroundStyle(Color.App.onSurface.opacity(0.5))
                    .lineLimit(1)

                if difficulty != nil || prText != nil {
                    HStack(spacing: Spacing.sm) {
                        if let difficulty {
                            HStack(spacing: 2) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 8, weight: .bold))
                                Text(difficulty)
                                    .font(Font.App.labelSm)
                            }
                            .foregroundStyle(Color.App.onSurface.opacity(0.5))
                        }
                        if let prText {
                            Text("PR \(prText)")
                                .font(Font.App.labelSm)
                                .foregroundStyle(Color.App.primary)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            if let onAdd {
                IconChip(
                    systemName: "plus",
                    size: 32,
                    iconSize: 14,
                    action: onAdd
                )
            }
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Radii.md)
                .fill(Color.App.surfaceContainerHigh)
        )
    }
}

#Preview("Exercise List Item") {
    VStack(spacing: Spacing.sm) {
        ExerciseListItem(
            title: "Barbell Deadlift",
            subtitle: "Posterior chain · Glutes · Hams",
            difficulty: "Advanced",
            prText: "142.5kg",
            onTap: {},
            onAdd: {}
        )
        ExerciseListItem(
            title: "Pull-up",
            subtitle: "Lats · Biceps",
            difficulty: "Intermediate",
            prText: "+15kg",
            onTap: {},
            onAdd: {}
        )
        ExerciseListItem(
            title: "Barbell Bench Press",
            subtitle: "Chest · Triceps · Front delts",
            onTap: {}
        )
    }
    .padding(Spacing.lg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.App.surface)
    .preferredColorScheme(.dark)
}
